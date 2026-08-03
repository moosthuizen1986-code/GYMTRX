import '../models/workout_session.dart';
import '../models/workout_set.dart';
import '../models/exercise.dart';

class PerformanceAnalyticsService {
  final List<WorkoutSession> sessions;
  final List<Exercise> exercises;

  PerformanceAnalyticsService({
    required this.sessions,
    required this.exercises,
  });

  // ==============================
  // 1️⃣ ESTIMATED 1RM (Epley)
  // ==============================

  double calculate1RM(double weight, int reps) {
    if (weight <= 0 || reps <= 0) return 0;
    return weight * (1 + reps / 30);
  }

  double getBestLifetime1RM(String exerciseName) {
    double best = 0;

    for (final session in sessions) {
      final sets = session.exercises[exerciseName];
      if (sets == null) continue;

      for (final set in sets) {
        final estimated = calculate1RM(set.weight, set.reps);
        if (estimated > best) {
          best = estimated;
        }
      }
    }

    return best;
  }

  // ==============================
  // 2️⃣ TREND ANALYSIS (IMPROVED)
  // ==============================

  double getExerciseTrendPercent(String exerciseName) {
    final exerciseSessions = sessions
        .where((s) =>
            s.finishedAt != null &&
            s.exercises.containsKey(exerciseName))
        .toList();

    if (exerciseSessions.length < 2) return 0;

    exerciseSessions.sort(
        (a, b) => a.finishedAt!.compareTo(b.finishedAt!));

    int compareCount;

    if (exerciseSessions.length >= 6) {
      compareCount = 3;
    } else if (exerciseSessions.length >= 4) {
      compareCount = 2;
    } else {
      compareCount = 1;
    }

    final recent = exerciseSessions.takeLast(compareCount);
    final previous = exerciseSessions
        .take(exerciseSessions.length - compareCount)
        .takeLast(compareCount);

    if (previous.isEmpty) return 0;

    final recentAvg = _average1RM(recent, exerciseName);
    final previousAvg = _average1RM(previous, exerciseName);

    if (previousAvg == 0) return 0;

    return ((recentAvg - previousAvg) / previousAvg) * 100;
  }

  double _average1RM(
      Iterable<WorkoutSession> sessions,
      String exerciseName) {
    double total = 0;
    int count = 0;

    for (final session in sessions) {
      final sets = session.exercises[exerciseName];
      if (sets == null) continue;

      for (final set in sets) {
        total += calculate1RM(set.weight, set.reps);
        count++;
      }
    }

    if (count == 0) return 0;
    return total / count;
  }

  // ==============================
  // 3️⃣ WEEKLY MUSCLE VOLUME
  // ==============================

  Map<String, double> getWeeklyMuscleVolume() {
    final now = DateTime.now();
    final weekAgo = now.subtract(const Duration(days: 7));

    final Map<String, double> volumeMap = {};

    for (final session in sessions) {
      if (session.finishedAt == null) continue;
      if (session.finishedAt!.isBefore(weekAgo)) continue;

      session.exercises.forEach((exerciseName, sets) {
        final exercise = exercises.firstWhere(
          (e) => e.name == exerciseName,
          orElse: () => Exercise(
            name: exerciseName,
            muscleGroup: "Unknown",
            sets: [],
          ),
        );

        final muscle = exercise.muscleGroup;

        double volume = 0;
        for (final set in sets) {
          volume += set.reps * set.weight;
        }

        volumeMap[muscle] =
            (volumeMap[muscle] ?? 0) + volume;
      });
    }

    return volumeMap;
  }

  // ==============================
  // 4️⃣ STRENGTH STATUS LABEL
  // ==============================

  String getTrendLabel(double percent) {
    if (percent > 2) return "Improving";
    if (percent < -2) return "Declining";
    return "Stable";
  }
}

// ==============================
// EXTENSION FOR TAKE LAST
// ==============================

extension IterableExtensions<T> on Iterable<T> {
  Iterable<T> takeLast(int count) {
    final list = toList();
    if (count >= list.length) return list;
    return list.sublist(list.length - count);
  }
}