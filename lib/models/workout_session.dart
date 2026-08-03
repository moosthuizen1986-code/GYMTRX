import 'workout_set.dart';
import 'workout_template.dart';

class WorkoutSession {
  final String templateId;
  final String templateName;

  /// exerciseName -> list of sets
  final Map<String, List<WorkoutSetEntry>> exercises;

  /// Tracks if each exercise is finished
  final Map<String, bool> exerciseCompleted;

  /// ⭐ NEW — BLOCK ORDER (SUPPORTS SUPERSETS)
  final List<List<String>> blockOrder;

  DateTime? finishedAt;
  int? totalSets;
  double? totalVolume;
  int workoutSeconds;

  WorkoutSession({
    required this.templateId,
    required this.templateName,
    required this.exercises,
    required this.blockOrder,
    Map<String, bool>? exerciseCompleted,
    this.finishedAt,
    this.totalSets,
    this.totalVolume,
    this.workoutSeconds = 0,
  }) : exerciseCompleted = exerciseCompleted ??
            Map<String, bool>.fromEntries(
              exercises.keys.map((k) => MapEntry(k, false)),
            );

  // ================= NEW SESSION =================
  factory WorkoutSession.fromTemplate(WorkoutTemplate template) {

    final exerciseMap = <String, List<WorkoutSetEntry>>{};
    final blocks = <List<String>>[];

    /// KEEP BLOCK STRUCTURE
    for (final block in template.blocks) {

      final blockExercises = <String>[];

      for (final id in block.exerciseIds) {
        exerciseMap[id] = <WorkoutSetEntry>[];
        blockExercises.add(id);
      }

      blocks.add(blockExercises);
    }

    return WorkoutSession(
      templateId: template.id,
      templateName: template.name,
      exercises: exerciseMap,
      blockOrder: blocks,
      exerciseCompleted: {
        for (final name in exerciseMap.keys) name: false
      },
    );
  }

  // ================= LOAD FROM STORAGE =================
  factory WorkoutSession.fromJson(Map<String, dynamic> json) {
    final exercisesRaw =
        Map<String, dynamic>.from(json['exercises'] as Map);

    final exercisesParsed = exercisesRaw.map<String, List<WorkoutSetEntry>>(
      (key, value) => MapEntry(
        key,
        (value as List)
            .map((e) => WorkoutSetEntry.fromJson(
                Map<String, dynamic>.from(e)))
            .toList(),
      ),
    );

    Map<String, bool> completed;

    if (json['exerciseCompleted'] != null) {
      completed = Map<String, bool>.from(json['exerciseCompleted']);
    } else {
      completed = {for (var k in exercisesParsed.keys) k: false};
    }

    /// LOAD BLOCK ORDER
    List<List<String>> blocks = [];
    if (json['blockOrder'] != null) {
      blocks = (json['blockOrder'] as List)
          .map<List<String>>((b) => List<String>.from(b))
          .toList();
    } else {
      // backward compatibility (old workouts)
      blocks = exercisesParsed.keys.map((e) => [e]).toList();
    }

    return WorkoutSession(
      templateId: json['templateId'],
      templateName: json['templateName'],
      exercises: exercisesParsed,
      blockOrder: blocks,
      exerciseCompleted: completed,
      finishedAt: json['finishedAt'] != null
          ? DateTime.parse(json['finishedAt'])
          : null,
      totalSets: json['totalSets'],
      totalVolume: (json['totalVolume'] as num?)?.toDouble(),
      workoutSeconds: json['workoutSeconds'] ?? 0,
    );
  }

  // ================= SAVE =================
  Map<String, dynamic> toJson() {
    return {
      'templateId': templateId,
      'templateName': templateName,
      'finishedAt': finishedAt?.toIso8601String(),
      'totalSets': totalSets,
      'totalVolume': totalVolume,
      'workoutSeconds': workoutSeconds,
      'exerciseCompleted': exerciseCompleted,
      'blockOrder': blockOrder,
      'exercises': exercises.map(
        (key, value) => MapEntry(
          key,
          value.map((s) => s.toJson()).toList(),
        ),
      ),
    };
  }

  // ================= HELPERS =================

  bool isExerciseDone(String name) => exerciseCompleted[name] == true;

  void markExerciseDone(String name) {
    exerciseCompleted[name] = true;
  }

  void markExerciseUndone(String name) {
    exerciseCompleted[name] = false;
  }

  /// ⭐ Returns the superset group of an exercise
  List<String>? getBlockOf(String exercise) {
    for (final block in blockOrder) {
      if (block.contains(exercise)) return block;
    }
    return null;
  }
}