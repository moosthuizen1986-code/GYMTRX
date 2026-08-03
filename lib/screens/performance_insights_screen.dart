import 'package:flutter/material.dart';
import '../services/performance_analytics_service.dart';
import '../services/workout_history_repository.dart';
import '../services/exercise_repository.dart';
import '../models/exercise.dart';

class PerformanceInsightsScreen extends StatelessWidget {
  final WorkoutHistoryRepository historyRepository;
  final ExerciseRepository exerciseRepository;

  const PerformanceInsightsScreen({
    super.key,
    required this.historyRepository,
    required this.exerciseRepository,
  });

  @override
  Widget build(BuildContext context) {
    final analytics = PerformanceAnalyticsService(
      sessions: historyRepository.sessions,
      exercises: exerciseRepository.exercises,
    );

    final muscleVolume = analytics.getWeeklyMuscleVolume();
    final exercises = exerciseRepository.exercises;

    final Map<String, double> best1RMs = {};

    for (final e in exercises) {
      final best = analytics.getBestLifetime1RM(e.name);
      if (best > 0) {
        best1RMs[e.name] = best;
      }
    }

    final sortedBest = best1RMs.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final topThree = sortedBest.take(3).toList();

    int improving = 0;
    int declining = 0;

    for (final e in exercises) {
      final trend = analytics.getExerciseTrendPercent(e.name);
      final label = analytics.getTrendLabel(trend);

      if (label == "Improving") improving++;
      if (label == "Declining") declining++;
    }

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text(
          "Performance Insights",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [

          // ==============================
          // STRENGTH OVERVIEW
          // ==============================

          const Text(
            "Strength Overview",
            style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),

          _infoCard(
            "Exercises Improving",
            "$improving",
            Colors.greenAccent,
          ),
          const SizedBox(height: 8),
          _infoCard(
            "Exercises Declining",
            "$declining",
            Colors.redAccent,
          ),

          const SizedBox(height: 24),

          // ==============================
          // TOP LIFTS
          // ==============================

          const Text(
            "Top Lifetime Lifts (1RM)",
            style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),

          if (topThree.isEmpty)
            const Text(
              "Not enough data yet",
              style: TextStyle(color: Colors.white70),
            )
          else
            ...topThree.map(
              (e) => _liftTile(e.key, e.value),
            ),

          const SizedBox(height: 24),

          // ==============================
          // WEEKLY MUSCLE VOLUME
          // ==============================

          const Text(
            "Weekly Muscle Volume",
            style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),

          if (muscleVolume.isEmpty)
            const Text(
              "No workouts this week",
              style: TextStyle(color: Colors.white70),
            )
          else
            ...muscleVolume.entries.map(
              (e) => _volumeTile(e.key, e.value),
            ),
        ],
      ),
    );
  }

  Widget _infoCard(String title, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(color: Colors.white70)),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
        ],
      ),
    );
  }

  Widget _liftTile(String exercise, double value) {
    return Card(
      color: const Color(0xFF1E1E1E),
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: ListTile(
        title: Text(
          exercise,
          style: const TextStyle(color: Colors.white),
        ),
        trailing: Text(
          "${value.toStringAsFixed(1)} kg",
          style: const TextStyle(
              color: Colors.redAccent,
              fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _volumeTile(String muscle, double volume) {
    return Card(
      color: const Color(0xFF1E1E1E),
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: ListTile(
        title: Text(
          muscle,
          style: const TextStyle(color: Colors.white),
        ),
        trailing: Text(
          "${volume.toStringAsFixed(0)} kg",
          style: const TextStyle(
              color: Colors.redAccent,
              fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}