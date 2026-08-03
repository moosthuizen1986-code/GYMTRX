// ONLY responsibility now: open exercise screens and track workout time
// REST TIMER COMPLETELY REMOVED FROM THIS SCREEN

import 'dart:async';
import 'package:flutter/material.dart';

import '../models/workout_session.dart';
import '../services/workout_history_repository.dart';
import '../services/workout_template_repository.dart';
import '../services/exercise_repository.dart';
import 'workout_session_exercise_screen.dart';

class WorkoutSessionScreen extends StatefulWidget {
  final WorkoutSession session;
  final WorkoutHistoryRepository historyRepository;
  final WorkoutTemplateRepository templateRepository;
  final ExerciseRepository exerciseRepository;

  const WorkoutSessionScreen({
    super.key,
    required this.session,
    required this.historyRepository,
    required this.templateRepository,
    required this.exerciseRepository,
  });

  @override
  State<WorkoutSessionScreen> createState() =>
      _WorkoutSessionScreenState();
}

class _WorkoutSessionScreenState
    extends State<WorkoutSessionScreen> {
  Timer? _workoutTimer;
  bool _isFinishingWorkout = false;

  @override
  void initState() {
    super.initState();
    _startWorkoutTimer();
  }

  void _startWorkoutTimer() {
    _workoutTimer =
        Timer.periodic(const Duration(seconds: 1), (_) async {
      if (!mounted) return;

      setState(() =>
          widget.session.workoutSeconds++);

      if (widget.session.workoutSeconds % 10 == 0) {
        await widget.historyRepository
            .saveActiveSession(widget.session);
      }
    });
  }

  Future<void> _openExercise(String name) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            WorkoutSessionExerciseScreen(
          exerciseName: name,
          sets:
              widget.session.exercises[name]!,
          session: widget.session,
          historyRepository:
              widget.historyRepository,
        ),
      ),
    );

    if (!mounted) return;
    setState(() {});
  }

  Future<bool> _deleteExercise(
      String exerciseName) async {
    final confirm =
        await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor:
            const Color(0xFF1E1E1E),
        title: const Text(
          "Remove Exercise?",
          style: TextStyle(
              color: Colors.white),
        ),
        content: const Text(
          "This will only remove it from this workout.",
          style: TextStyle(
              color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () =>
                Navigator.pop(context,
                    false),
            child: const Text("CANCEL"),
          ),
          ElevatedButton(
            onPressed: () =>
                Navigator.pop(context,
                    true),
            child: const Text("REMOVE"),
          )
        ],
      ),
    );

    if (confirm != true) return false;

    setState(() {
      widget.session.exercises.remove(exerciseName);
      widget.session.exerciseCompleted.remove(exerciseName);

      widget.session.blockOrder.removeWhere((block) {
        block.remove(exerciseName);
        return block.isEmpty;
      });
    });

    await widget.historyRepository
        .saveActiveSession(widget.session);

    return true;
  }

  // 🔥 UPDATED WITH SEARCH
  Future<void> _addExercise() async {
    final allExercises =
        widget.exerciseRepository.exercises;

    final availableExercises =
        allExercises
            .map((e) => e.name)
            .where((name) =>
                !widget.session.exercises
                    .containsKey(name))
            .toList();

    if (availableExercises.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content:
              Text("No more exercises available"),
        ),
      );
      return;
    }

    final selected =
        await showDialog<String>(
      context: context,
      builder: (_) {
        String searchQuery = "";

        return StatefulBuilder(
          builder: (context, setStateDialog) {

            final filtered =
                availableExercises
                    .where((name) =>
                        name
                            .toLowerCase()
                            .contains(
                                searchQuery
                                    .toLowerCase()))
                    .toList();

            return AlertDialog(
              backgroundColor:
                  const Color(0xFF1E1E1E),
              title: const Text(
                "Add Exercise",
                style: TextStyle(
                    color: Colors.white),
              ),
              content: SizedBox(
                width: double.maxFinite,
                height: 400,
                child: Column(
                  children: [

                    // 🔎 SEARCH FIELD
                    TextField(
                      style:
                          const TextStyle(
                              color: Colors.white),
                      decoration:
                          const InputDecoration(
                        hintText:
                            "Search exercise...",
                        hintStyle:
                            TextStyle(
                                color:
                                    Colors.white54),
                        prefixIcon: Icon(
                            Icons.search,
                            color:
                                Colors.white54),
                      ),
                      onChanged: (value) {
                        setStateDialog(() {
                          searchQuery = value;
                        });
                      },
                    ),

                    const SizedBox(height: 12),

                    Expanded(
                      child:
                          filtered.isEmpty
                              ? const Center(
                                  child: Text(
                                    "No exercises found",
                                    style: TextStyle(
                                        color: Colors.white70),
                                  ),
                                )
                              : ListView.builder(
                                  itemCount:
                                      filtered.length,
                                  itemBuilder:
                                      (context, index) {
                                    final name =
                                        filtered[index];

                                    return ListTile(
                                      title: Text(
                                        name,
                                        style: const TextStyle(
                                            color:
                                                Colors.white),
                                      ),
                                      onTap: () =>
                                          Navigator.pop(
                                              context,
                                              name),
                                    );
                                  },
                                ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );

    if (selected == null) return;

    setState(() {
      widget.session.exercises[selected] = [];
      widget.session.exerciseCompleted[selected] =
          false;
      widget.session.blockOrder.add([selected]);
    });

    await widget.historyRepository
        .saveActiveSession(widget.session);
  }

  Future<void> _finishWorkout() async {
    _isFinishingWorkout = true;
    _workoutTimer?.cancel();

    widget.session.finishedAt =
        DateTime.now();

    int totalSets = 0;
    double totalVolume = 0;

    widget.session.exercises
        .forEach((_, sets) {
      totalSets += sets.length;
      for (var s in sets) {
        totalVolume +=
            s.reps * s.weight;
      }
    });

    widget.session.totalSets =
        totalSets;
    widget.session.totalVolume =
        totalVolume;

    await widget.historyRepository
        .addSession(widget.session);
    await widget.historyRepository
        .clearActiveSession();

    if (!mounted) return;

    Navigator.popUntil(
        context, (route) => route.isFirst);
  }

  @override
  void dispose() {
    _workoutTimer?.cancel();
    if (!_isFinishingWorkout) {
      widget.historyRepository
          .saveActiveSession(widget.session);
    }
    super.dispose();
  }

  String _formatTime(int seconds) {
    final m = (seconds ~/ 60)
        .toString()
        .padLeft(2, '0');
    final s = (seconds % 60)
        .toString()
        .padLeft(2, '0');
    return '$m:$s';
  }

  Widget _buildBlock(
      List<String> block) {
    final isSuperset =
        block.length > 1;

    return Container(
      margin:
          const EdgeInsets.symmetric(
              vertical: 8),
      padding:
          const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(
            0xFF181818),
        borderRadius:
            BorderRadius.circular(14),
        border: Border.all(
          color: isSuperset
              ? Colors.redAccent
                  .withValues(alpha: 0.4)
              : Colors.transparent,
        ),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          if (isSuperset)
            const Text(
              "SUPERSET",
              style: TextStyle(
                color:
                    Colors.redAccent,
                fontWeight:
                    FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),
          if (isSuperset)
            const SizedBox(height: 6),
          ...block.map(
            (exerciseName) =>
                Dismissible(
              key:
                  ValueKey(exerciseName),
              direction:
                  DismissDirection
                      .endToStart,
              background:
                  Container(
                alignment:
                    Alignment.centerRight,
                padding:
                    const EdgeInsets
                        .symmetric(
                            horizontal:
                                20),
                color:
                    Colors.redAccent,
                child:
                    const Icon(
                  Icons.delete,
                  color:
                      Colors.white,
                ),
              ),
              confirmDismiss:
                  (_) =>
                      _deleteExercise(
                          exerciseName),
              child:
                  _tile(exerciseName),
            ),
          ),
        ],
      ),
    );
  }

  Widget _tile(String name) {
    final sets =
        widget.session
            .exercises[name]!;
    final done =
        widget.session
            .isExerciseDone(name);

    return Card(
      color:
          const Color(0xFF1E1E1E),
      margin:
          const EdgeInsets.symmetric(
              vertical: 6),
      child: ListTile(
        title: Text(
          name,
          style: TextStyle(
            color: done
                ? Colors.white70
                : Colors.white,
            decoration: done
                ? TextDecoration
                    .lineThrough
                : TextDecoration
                    .none,
          ),
        ),
        subtitle: Text(
          done
              ? "Exercise Completed"
              : "${sets.length} sets",
          style:
              const TextStyle(
                  color: Colors.white70),
        ),
        trailing: Icon(
          done
              ? Icons.check_circle
              : Icons.chevron_right,
          color:
              Colors.redAccent,
        ),
        onTap: done
            ? null
            : () =>
                _openExercise(name),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor:
            Colors.black,
        title: Text(
          widget.session
              .templateName,
          style:
              const TextStyle(
                  fontWeight:
                      FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(
                Icons.flag,
                color: Colors.redAccent),
            onPressed:
                _finishWorkout,
          )
        ],
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding:
                const EdgeInsets.all(12),
            color:
                Colors.black87,
            child: Text(
              'Workout Time: ${_formatTime(widget.session.workoutSeconds)}',
              textAlign:
                  TextAlign.center,
              style:
                  const TextStyle(
                color:
                    Colors.redAccent,
                fontSize: 18,
                fontWeight:
                    FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: ListView(
              padding:
                  const EdgeInsets.all(8),
              children: widget
                  .session
                  .blockOrder
                  .map(_buildBlock)
                  .toList(),
            ),
          ),
        ],
      ),
      floatingActionButton:
          FloatingActionButton(
        backgroundColor:
            Colors.redAccent,
        onPressed:
            _addExercise,
        child:
            const Icon(Icons.add),
      ),
    );
  }
}