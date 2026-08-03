import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../models/workout_set.dart';
import '../models/workout_session.dart';
import '../services/workout_history_repository.dart';
import '../main.dart';
import '../widgets/exercise/exercise_header.dart';

class WorkoutSessionExerciseScreen extends StatefulWidget {
  final String exerciseName;
  final List<WorkoutSetEntry> sets;
  final WorkoutSession session;
  final WorkoutHistoryRepository historyRepository;

  const WorkoutSessionExerciseScreen({
    super.key,
    required this.exerciseName,
    required this.sets,
    required this.session,
    required this.historyRepository,
  });

  @override
  State<WorkoutSessionExerciseScreen> createState() =>
      _WorkoutSessionExerciseScreenState();
}

class _WorkoutSessionExerciseScreenState
    extends State<WorkoutSessionExerciseScreen> {

  Timer? _restTimer;
  int _restSeconds = 0;
  int _restDefault = 90;

  final Map<int, bool> _prSets = {};

  List<String>? get _block =>
      widget.session.getBlockOf(widget.exerciseName);

  bool get _isSuperset => (_block?.length ?? 0) > 1;
  bool get _isLastExercise => _block?.last == widget.exerciseName;

  String? get _nextExercise {
    if (!_isSuperset) return null;
    final index = _block!.indexOf(widget.exerciseName);
    return _block![(index + 1) % _block!.length];
  }

  // 🔔 Native notification bell
  Future<void> _ringBell() async {
    const androidDetails = AndroidNotificationDetails(
      'rest_timer_channel',
      'Rest Timer',
      channelDescription: 'Rest timer notifications',
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
      sound: RawResourceAndroidNotificationSound('bel'),
      audioAttributesUsage: AudioAttributesUsage.notification,
    );

    const details =
        NotificationDetails(android: androidDetails);

    await flutterLocalNotificationsPlugin.show(
      0,
      'Rest Complete',
      'Time to lift again 💪',
      details,
    );
  }

  // 🔥 CHANGE REST TIME (ADDED BACK)
  void _changeRestTime() {
    final controller =
        TextEditingController(text: _restDefault.toString());

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        title: const Text(
          "Set Rest Time (seconds)",
          style: TextStyle(color: Colors.white),
        ),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            labelText: "Seconds",
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("CANCEL"),
          ),
          ElevatedButton(
            onPressed: () {
              final value =
                  int.tryParse(controller.text);
              if (value != null && value > 0) {
                setState(() {
                  _restDefault = value;
                });
              }
              Navigator.pop(context);
            },
            child: const Text("SAVE"),
          ),
        ],
      ),
    );
  }

  // =============================
  // EDIT SET (WEIGHT FIRST)
  // =============================

  void _editSetValues(WorkoutSetEntry set) {
    final weightController =
        TextEditingController(text: set.weight == 0 ? '' : set.weight.toString());

    final repsController =
        TextEditingController(text: set.reps == 0 ? '' : set.reps.toString());

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        title: const Text('Edit Set',
            style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: weightController,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              style: const TextStyle(color: Colors.white),
              decoration:
                  const InputDecoration(labelText: 'Weight (kg)'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: repsController,
              keyboardType: TextInputType.number,
              style: const TextStyle(color: Colors.white),
              decoration:
                  const InputDecoration(labelText: 'Reps'),
            ),
          ],
        ),
        actions: [
          TextButton(
            child: const Text("CANCEL"),
            onPressed: () => Navigator.pop(context),
          ),
          ElevatedButton(
            onPressed: () async {
              if (weightController.text.isNotEmpty) {
                set.weight =
                    double.tryParse(weightController.text) ??
                        set.weight;
              }
              if (repsController.text.isNotEmpty) {
                set.reps =
                    int.tryParse(repsController.text) ??
                        set.reps;
              }

              setState(() {});
              await widget.historyRepository
                  .saveActiveSession(widget.session);

              if (!mounted) return;
              Navigator.pop(context);
            },
            child: const Text("SAVE"),
          )
        ],
      ),
    );
  }

  // =============================
  // COMPLETE SET
  // =============================

  Future<void> _completeSet(
      int index, WorkoutSetEntry set) async {
    if (set.done) return;

    setState(() => set.done = true);

    final isPR =
        await widget.historyRepository
            .checkForPR(
                widget.exerciseName, set);

    if (!mounted) return;

    if (isPR) {
      setState(() => _prSets[index] = true);

      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          behavior:
              SnackBarBehavior.floating,
          backgroundColor:
              Color(0xFF1A1A1A),
          content: Row(
            children: [
              Icon(Icons.emoji_events,
                  color:
                      Color(0xFFFFC107)),
              SizedBox(width: 10),
              Text(
                "NEW PERSONAL RECORD",
                style: TextStyle(
                    color:
                        Color(0xFFFFC107)),
              ),
            ],
          ),
        ),
      );
    }

    await widget.historyRepository
        .saveActiveSession(widget.session);

    if (!mounted) return;

    if (!_isSuperset) {
      _startRest();
      return;
    }

    if (!_isLastExercise) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) =>
              WorkoutSessionExerciseScreen(
            exerciseName:
                _nextExercise!,
            sets: widget.session
                .exercises[_nextExercise]!,
            session: widget.session,
            historyRepository:
                widget.historyRepository,
          ),
        ),
      );
      return;
    }

    _startRest(
        nextAfterRest: _block!.first);
  }

  void _startRest({String? nextAfterRest}) {
    _restTimer?.cancel();
    setState(() => _restSeconds = _restDefault);

    _restTimer =
        Timer.periodic(const Duration(seconds: 1), (timer) async {
      if (_restSeconds <= 1) {
        timer.cancel();
        setState(() => _restSeconds = 0);

        await _ringBell();

        if (!mounted) return;

        if (nextAfterRest != null) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) =>
                  WorkoutSessionExerciseScreen(
                exerciseName: nextAfterRest,
                sets: widget.session
                    .exercises[nextAfterRest]!,
                session: widget.session,
                historyRepository:
                    widget.historyRepository,
              ),
            ),
          );
        }
      } else {
        setState(() => _restSeconds--);
      }
    });
  }

  Future<void> _finishExercise() async {
    if (_isSuperset) {
      for (final e in _block!) {
        widget.session.exerciseCompleted[e] = true;
      }
    } else {
      widget.session.exerciseCompleted[
          widget.exerciseName] = true;
    }

    await widget.historyRepository
        .saveActiveSession(widget.session);

    if (!mounted) return;
    Navigator.pop(context);
  }

  @override
  void dispose() {
    _restTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          const Color(0xFF121212),
      appBar: AppBar(
  backgroundColor: Colors.black,
  title: const SizedBox.shrink(),
  actions: [
    IconButton(
      icon: const Icon(Icons.timer),
      onPressed: _changeRestTime,
    ),
  ],
),
      body: Column(
        children: [

          ExerciseHeader(
  exerciseName: widget.exerciseName,
  workoutName: widget.session.templateName,
),

          if (_restSeconds > 0)
            Container(
              width: double.infinity,
              padding:
                  const EdgeInsets.all(14),
              color: Colors.black,
              child: Text(
                "REST: $_restSeconds",
                textAlign:
                    TextAlign.center,
                style:
                    const TextStyle(
                        color:
                            Colors.redAccent,
                        fontSize: 22,
                        fontWeight:
                            FontWeight.bold),
              ),
            ),
          Expanded(
            child: ListView.builder(
              padding:
                  const EdgeInsets.all(8),
              itemCount:
                  widget.sets.length,
              itemBuilder:
                  (context, index) {
                final set =
                    widget.sets[index];

                return Dismissible(
                  key: ValueKey(set),
                  direction:
                      DismissDirection.endToStart,
                  background: Container(
                    alignment:
                        Alignment.centerRight,
                    padding:
                        const EdgeInsets.symmetric(
                            horizontal: 20),
                    color: Colors.redAccent,
                    child: const Icon(
                      Icons.delete,
                      color: Colors.white,
                    ),
                  ),
                  confirmDismiss: (_) async {
                    return await showDialog(
                      context: context,
                      builder: (_) => AlertDialog(
                        backgroundColor:
                            const Color(
                                0xFF1E1E1E),
                        title: const Text(
                          "Delete Set?",
                          style: TextStyle(
                              color:
                                  Colors.white),
                        ),
                        content: const Text(
                          "Are you sure you want to remove this set?",
                          style: TextStyle(
                              color:
                                  Colors.white70),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () =>
                                Navigator.pop(
                                    context,
                                    false),
                            child:
                                const Text("CANCEL"),
                          ),
                          ElevatedButton(
                            onPressed: () =>
                                Navigator.pop(
                                    context,
                                    true),
                            child:
                                const Text("DELETE"),
                          )
                        ],
                      ),
                    );
                  },
                  onDismissed: (_) async {
                    widget.sets.removeAt(index);
                    await widget.historyRepository
                        .saveActiveSession(
                            widget.session);
                    setState(() {});
                  },
                  child: Card(
                    color: const Color(
                        0xFF1E1E1E),
                    margin:
                        const EdgeInsets
                            .symmetric(
                                vertical: 6),
                    child: ListTile(
                      onTap: () =>
                          _editSetValues(set),
                      leading: Icon(
                        set.done
                            ? Icons
                                .check_circle
                            : Icons
                                .radio_button_unchecked,
                        color: set.done
                            ? Colors
                                .redAccent
                            : Colors.grey,
                      ),
                      title: Text(
                        '${set.weight == 0 ? "-" : set.weight} kg  •  ${set.reps == 0 ? "-" : set.reps} reps',
                        style:
                            const TextStyle(
                                color: Colors
                                    .white),
                      ),
                   trailing: SizedBox(
  width: 80,
  child: ElevatedButton(
    style: ElevatedButton.styleFrom(
      backgroundColor: Colors.redAccent,
      minimumSize: Size.zero,
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
      ),
    ),
    onPressed: () => _completeSet(index, set),
    child: const Text(
      "DONE",
      style: TextStyle(fontSize: 12),
    ),
  ),
),
                    ),
                  ),
                );
              },
            ),
          ),
          SafeArea(
            minimum:
                const EdgeInsets.fromLTRB(
                    16, 8, 16, 16),
            child: SizedBox(
              width: double.infinity,
              height: 52,
              child:
                  ElevatedButton.icon(
                icon: const Icon(
                    Icons.check_circle,
                    color:
                        Colors.redAccent),
                label: const Text(
                    "EXERCISE DONE"),
                onPressed:
                    _finishExercise,
              ),
            ),
          ),
        ],
      ),
      floatingActionButton:
          FloatingActionButton(
        backgroundColor:
            Colors.redAccent,
        onPressed: _addSet,
        child: const Icon(Icons.add),
      ),
    );
  }

  Future<void> _addSet() async {
    setState(() => widget.sets.add(
        WorkoutSetEntry(
            reps: 0, weight: 0)));
    await widget.historyRepository
        .saveActiveSession(widget.session);
  }
}