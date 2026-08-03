import '../models/workout_set.dart';
import '../models/exercise_record.dart';

class PerformanceService {
  /// Epley Formula
  /// Estimated 1RM = Weight × (1 + Reps / 30)
  double calculateEstimated1RM(
      double weight,
      int reps,
      ) {
    if (weight <= 0 || reps <= 0) return 0;
    return weight * (1 + reps / 30);
  }

  /// Volume = Weight × Reps
  double calculateVolume(
      double weight,
      int reps,
      ) {
    return weight * reps;
  }

  /// Updates an ExerciseRecord.
  /// Returns true if ANY personal record was broken.
  bool updateExerciseRecord(
      ExerciseRecord record,
      WorkoutSetEntry set,
      ) {
    if (set.weight <= 0 || set.reps <= 0) {
      return false;
    }

    bool newPR = false;

    final volume = calculateVolume(
      set.weight,
      set.reps,
    );

    final estimated1RM = calculateEstimated1RM(
      set.weight,
      set.reps,
    );

    // -------------------------
    // Existing PRs
    // -------------------------

    if (set.weight > record.bestWeight) {
      record.bestWeight = set.weight;
      newPR = true;
    }

    if (set.reps > record.bestReps) {
      record.bestReps = set.reps;
      newPR = true;
    }

    if (volume > record.bestVolume) {
      record.bestVolume = volume;
      newPR = true;
    }

    // -------------------------
    // NEW Best Performance
    // -------------------------

    if (estimated1RM > record.bestEstimated1RM) {
      record.bestEstimated1RM = estimated1RM;
      record.bestSetWeight = set.weight;
      record.bestSetReps = set.reps;
      record.bestSetDate = DateTime.now();

      newPR = true;
    }

    return newPR;
  }
}