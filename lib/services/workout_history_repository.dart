import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/exercise_record.dart';
import '../models/workout_session.dart';
import '../models/workout_set.dart';

class WorkoutHistoryRepository {
  static const _storageKey = 'workout_history';
  static const _activeSessionKey = 'active_workout';
  static const _recordsKey = 'exercise_records';

  final List<WorkoutSession> _sessions = [];
  final Map<String, ExerciseRecord> _records = {};

  List<WorkoutSession> get sessions => List.unmodifiable(_sessions);

  Map<String, ExerciseRecord> get records => _records;

  /// Returns the record for an exercise.
  /// If one doesn't exist yet, an empty record is created.
  ExerciseRecord getRecord(String exerciseName) {
    return _records.putIfAbsent(
      exerciseName,
      () => ExerciseRecord(exerciseName: exerciseName),
    );
  }

  // =====================================================
  // LOAD
  // =====================================================

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();

    final raw = prefs.getString(_storageKey);

    if (raw != null) {
      final List decoded = jsonDecode(raw);

      _sessions
        ..clear()
        ..addAll(
          decoded.map(
            (e) => WorkoutSession.fromJson(e),
          ),
        );
    }

    final rawRecords = prefs.getString(_recordsKey);

    if (rawRecords != null) {
      final Map decoded = jsonDecode(rawRecords);

      _records.clear();

      decoded.forEach((key, value) {
        _records[key] =
            ExerciseRecord.fromJson(value);
      });
    }
  }

  // =====================================================
  // HISTORY
  // =====================================================

  Future<void> addSession(
      WorkoutSession session) async {
    _sessions.add(session);
    await _saveSessions();
  }

  Future<void> deleteSession(
      WorkoutSession session) async {
    _sessions.remove(session);
    await _saveSessions();
  }

  Future<void> clearHistory() async {
    _sessions.clear();

    final prefs =
        await SharedPreferences.getInstance();

    await prefs.remove(_storageKey);
  }

  Future<void> _saveSessions() async {
    final prefs =
        await SharedPreferences.getInstance();

    await prefs.setString(
      _storageKey,
      jsonEncode(
        _sessions
            .map((s) => s.toJson())
            .toList(),
      ),
    );
  }

  // =====================================================
  // ACTIVE WORKOUT
  // =====================================================

  Future<void> saveActiveSession(
      WorkoutSession session) async {
    final prefs =
        await SharedPreferences.getInstance();

    await prefs.setString(
      _activeSessionKey,
      jsonEncode(session.toJson()),
    );
  }

  Future<WorkoutSession?> loadActiveSession() async {
    final prefs =
        await SharedPreferences.getInstance();

    final raw =
        prefs.getString(_activeSessionKey);

    if (raw == null) {
      return null;
    }

    final session =
        WorkoutSession.fromJson(jsonDecode(raw));

    if (session.finishedAt != null) {
      await clearActiveSession();
      return null;
    }

    return session;
  }

  Future<void> clearActiveSession() async {
    final prefs =
        await SharedPreferences.getInstance();

    await prefs.remove(_activeSessionKey);
  }

  // =====================================================
  // PERSONAL RECORDS
  // =====================================================

  Future<bool> checkForPR(
    String exerciseName,
    WorkoutSetEntry set,
  ) async {
    if (set.reps <= 0 || set.weight <= 0) {
      return false;
    }

    final record = getRecord(exerciseName);

    bool isPR = false;

    final volume =
        set.weight * set.reps;

    final estimated1RM =
        set.weight *
            (1 + (set.reps / 30));
    if (set.weight > record.bestWeight) {
      record.bestWeight = set.weight;
      isPR = true;
    }

    if (set.reps > record.bestReps) {
      record.bestReps = set.reps;
      isPR = true;
    }

    if (volume > record.bestVolume) {
      record.bestVolume = volume;
      isPR = true;
    }

    if (estimated1RM > record.bestEstimated1RM) {
      record.bestEstimated1RM = estimated1RM;
      record.bestSetWeight = set.weight;
      record.bestSetReps = set.reps;
      record.bestSetDate = DateTime.now();
      isPR = true;
    }

    if (isPR) {
      await _saveRecords();
    }

    return isPR;
  }

  Future<void> _saveRecords() async {
    final prefs =
        await SharedPreferences.getInstance();

    final map =
        _records.map((k, v) => MapEntry(k, v.toJson()));

    await prefs.setString(
      _recordsKey,
      jsonEncode(map),
    );
  }

  // =====================================================
  // HOME DASHBOARD
  // =====================================================

  Map<String, String> getWeeklyStats() {
    final now = DateTime.now();
    final weekAgo =
        now.subtract(const Duration(days: 7));

    int sessionsThisWeek = 0;
    double totalVolume = 0;

    for (final s in _sessions) {
      if (s.finishedAt != null &&
          s.finishedAt!.isAfter(weekAgo)) {
        sessionsThisWeek++;
        totalVolume += s.totalVolume ?? 0;
      }
    }

    return {
      "sessions": "$sessionsThisWeek",
      "volume":
          "${totalVolume.toStringAsFixed(0)} kg",
    };
  }

  String getWeeklyPRCount() {
    final now = DateTime.now();
    final weekAgo =
        now.subtract(const Duration(days: 7));

    int prCount = 0;

    for (final s in _sessions) {
      if (s.finishedAt != null &&
          s.finishedAt!.isAfter(weekAgo)) {
        if ((s.totalVolume ?? 0) > 0) {
          prCount++;
        }
      }
    }

    return "$prCount";
  }

  Map<String, String> getLastWorkoutInfo() {
    if (_sessions.isEmpty) {
      return {
        "title": "No workouts yet",
        "subtitle":
            "Start your first session today",
      };
    }

    final last = _sessions.last;
    final time =
        _formatSeconds(last.workoutSeconds);

    return {
      "title": last.templateName,
      "subtitle": "Last workout • $time",
    };
  }

  String _formatSeconds(int seconds) {
    final h =
        (seconds ~/ 3600).toString().padLeft(2, '0');

    final m = ((seconds % 3600) ~/ 60)
        .toString()
        .padLeft(2, '0');

    final s = (seconds % 60)
        .toString()
        .padLeft(2, '0');

    return "$h:$m:$s";
  }

  // =====================================================
  // EXERCISE HISTORY
  // =====================================================

  List<WorkoutSession> getSessionsForExercise(
      String exerciseName) {
    return _sessions
        .where(
          (s) =>
              s.exercises.containsKey(exerciseName),
        )
        .toList()
      ..sort(
        (a, b) => (a.finishedAt ?? DateTime.now())
            .compareTo(
          b.finishedAt ?? DateTime.now(),
        ),
      );
  }

  List<double> getExerciseBestWeights(
      String exerciseName) {
    final sessions =
        getSessionsForExercise(exerciseName);

    return sessions.map((session) {
      final sets =
          session.exercises[exerciseName] ?? [];

      double best = 0;

      for (final s in sets) {
        if (s.weight > best) {
          best = s.weight;
        }
      }

      return best;
    }).toList();
  }

  List<double> getExerciseVolumes(
      String exerciseName) {
    final sessions =
        getSessionsForExercise(exerciseName);

    return sessions.map((session) {
      final sets =
          session.exercises[exerciseName] ?? [];

      double total = 0;

      for (final s in sets) {
        total += s.weight * s.reps;
      }

      return total;
    }).toList();
  }

  List<String> getExerciseDates(
      String exerciseName) {
    final sessions =
        getSessionsForExercise(exerciseName);

    return sessions.map((s) {
      final d =
          s.finishedAt ?? DateTime.now();

      return "${d.day}/${d.month}";
    }).toList();
  }
}