import 'package:flutter/material.dart';
import '../services/exercise_repository.dart';
import '../services/workout_template_repository.dart';
import '../services/workout_history_repository.dart';
import '../services/measurement_repository.dart';

import '../models/workout_session.dart';
import 'start_workout_screen.dart';
import 'workout_session_screen.dart';
import 'workout_history_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  final ExerciseRepository exerciseRepository;
  final WorkoutTemplateRepository templateRepository;
  final WorkoutHistoryRepository historyRepository;
  final MeasurementRepository measurementRepository;

  const HomeScreen({
    super.key,
    required this.exerciseRepository,
    required this.templateRepository,
    required this.historyRepository,
    required this.measurementRepository,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  WorkoutSession? _activeSession;

  @override
  void initState() {
    super.initState();
    _loadActiveSession();
  }

  Future<void> _loadActiveSession() async {
    final session = await widget.historyRepository.loadActiveSession();
    if (!mounted) return;
    setState(() => _activeSession = session);
  }

  String _formatSeconds(int seconds) {
    final h = (seconds ~/ 3600).toString().padLeft(2, '0');
    final m = ((seconds % 3600) ~/ 60).toString().padLeft(2, '0');
    final s = (seconds % 60).toString().padLeft(2, '0');
    return "$h:$m:$s";
  }

  Map<String, String> _getWeeklyStats() {
    final now = DateTime.now();
    final weekAgo = now.subtract(const Duration(days: 7));

    int sessionsThisWeek = 0;
    double totalVolume = 0;

    for (var s in widget.historyRepository.sessions) {
      if (s.finishedAt != null && s.finishedAt!.isAfter(weekAgo)) {
        sessionsThisWeek++;
        totalVolume += s.totalVolume ?? 0;
      }
    }

    return {
      "sessions": "$sessionsThisWeek",
      "volume": totalVolume.toStringAsFixed(0),
    };
  }

  String _getWeeklyPRs() {
    final now = DateTime.now();
    final weekAgo = now.subtract(const Duration(days: 7));

    int prCount = 0;

    for (var s in widget.historyRepository.sessions) {
      if (s.finishedAt != null && s.finishedAt!.isAfter(weekAgo)) {
        if ((s.totalVolume ?? 0) > 0) {
          prCount++;
        }
      }
    }

    return "$prCount";
  }

  int _getStreak() {
    if (widget.historyRepository.sessions.isEmpty) return 0;

    final sessions = widget.historyRepository.sessions
        .where((s) => s.finishedAt != null)
        .toList()
      ..sort((a, b) => b.finishedAt!.compareTo(a.finishedAt!));

    int streak = 0;
    DateTime? lastDate;

    for (var s in sessions) {
      final date = DateTime(
        s.finishedAt!.year,
        s.finishedAt!.month,
        s.finishedAt!.day,
      );

      if (lastDate == null) {
        lastDate = date;
        streak = 1;
      } else {
        if (lastDate.difference(date).inDays == 1) {
          streak++;
          lastDate = date;
        } else {
          break;
        }
      }
    }

    return streak;
  }

  void _openWorkout(WorkoutSession session) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => WorkoutHistoryDetailScreen(
          session: session,
          historyRepository: widget.historyRepository,
          templateRepository: widget.templateRepository,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final weekly = _getWeeklyStats();
    final prCount = _getWeeklyPRs();
    final streak = _getStreak();
    final sessions = widget.historyRepository.sessions.reversed.take(3);

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [

          /// TEXTURE BACKGROUND
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage("assets/ui/background_texture.png"),
                  repeat: ImageRepeat.repeat,
                ),
              ),
            ),
          ),

          /// DARK OVERLAY
          Positioned.fill(
            child: Container(
              color: Colors.black.withOpacity(0.35),
            ),
          ),

          SafeArea(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              children: [

                const SizedBox(height: 10),

                /// LOGO
                Center(
                  child: Image.asset(
                    "assets/ui/gymtrx_logo.png",
                    height: 150,
                  ),
                ),

                const SizedBox(height: 10),

                const Text(
                  "Welcome back!",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 18),

                /// START WORKOUT BUTTON
                Container(
                  height: 56,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(18),
                    gradient: const LinearGradient(
                      colors: [Color(0xFFFF3B30), Color(0xFFB00020)],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.redAccent.withOpacity(0.7),
                        blurRadius: 12,
                        spreadRadius: 1,
                      )
                    ],
                  ),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(18),
                    onTap: () {
                      if (_activeSession != null) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => WorkoutSessionScreen(
                              session: _activeSession!,
                              historyRepository: widget.historyRepository,
                              templateRepository: widget.templateRepository,
                              exerciseRepository: widget.exerciseRepository,
                            ),
                          ),
                        ).then((_) => _loadActiveSession());
                      } else {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => StartWorkoutScreen(
                              templateRepository: widget.templateRepository,
                              historyRepository: widget.historyRepository,
                              exerciseRepository: widget.exerciseRepository,
                            ),
                          ),
                        ).then((_) => _loadActiveSession());
                      }
                    },
                    child: Center(
                      child: Text(
                        _activeSession != null
                            ? "CONTINUE WORKOUT • ${_formatSeconds(_activeSession!.workoutSeconds)}"
                            : "START WORKOUT",
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 30),

                /// DIVIDER
                Container(
                  height: 2,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.transparent,
                        Colors.redAccent,
                        Colors.transparent
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                const Text(
                  "Statistics",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 16),

                Row(
                  children: [
                    _StatCard(Icons.local_fire_department, weekly["sessions"]!, "Sessions"),
                    _StatCard(Icons.bar_chart, weekly["volume"]!, "Volume"),
                    _StatCard(Icons.emoji_events, prCount, "PBs"),
                    _StatCard(Icons.calendar_today, "$streak", "Streak"),
                  ],
                ),

                const SizedBox(height: 32),

                const Text(
                  "Recent Activity",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 16),

                ...sessions.map(
                  (s) => _RecentTile(
                    session: s,
                    onTap: () => _openWorkout(s),
                  ),
                ),

                const SizedBox(height: 40),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;

  const _StatCard(this.icon, this.value, this.label);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 5),
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.55),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: Colors.redAccent.withOpacity(0.35),
          ),
        ),
        child: Column(
          children: [
            Icon(icon, color: Colors.redAccent, size: 24),
            const SizedBox(height: 6),
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            ),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RecentTile extends StatelessWidget {
  final WorkoutSession session;
  final VoidCallback onTap;

  const _RecentTile({
    required this.session,
    required this.onTap,
  });

  String _formatTime(int seconds) {
    final m = (seconds ~/ 60).toString();
    return "$m mins";
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.55),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Colors.redAccent.withOpacity(0.3),
          ),
        ),
        child: Row(
          children: [
            const Icon(Icons.local_fire_department, color: Colors.redAccent),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    session.templateName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Completed • ${_formatTime(session.workoutSeconds)} • ${session.totalVolume?.toStringAsFixed(0) ?? 0} kg",
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.white54),
          ],
        ),
      ),
    );
  }
}