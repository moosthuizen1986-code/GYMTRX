import 'exercise_record.dart';
import 'workout_session.dart';

class ExerciseStats {
  final String exerciseName;

  /// Current Personal Records
  final ExerciseRecord record;

  /// Estimated best 1RM
  final double estimated1RM;

  /// Lifetime stats
  final int totalSets;
  final int totalReps;
  final double totalVolume;
  final int totalSessions;

  /// Last workout containing this exercise
  final WorkoutSession? lastWorkout;

  /// Complete workout history
  final List<WorkoutSession> history;

  const ExerciseStats({
    required this.exerciseName,
    required this.record,
    required this.estimated1RM,
    required this.totalSets,
    required this.totalReps,
    required this.totalVolume,
    required this.totalSessions,
    required this.lastWorkout,
    required this.history,
  });

  bool get hasHistory => history.isNotEmpty;

  bool get hasRecord => record.bestWeight > 0;
}