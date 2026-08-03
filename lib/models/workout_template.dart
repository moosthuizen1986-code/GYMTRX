import 'package:uuid/uuid.dart';

class WorkoutBlock {
  List<String> exerciseIds;
  bool isSuperset;

  WorkoutBlock({
    required this.exerciseIds,
    this.isSuperset = false,
  });

  factory WorkoutBlock.single(String id) =>
      WorkoutBlock(exerciseIds: [id], isSuperset: false);

  factory WorkoutBlock.superset(List<String> ids) =>
      WorkoutBlock(exerciseIds: ids, isSuperset: true);

  factory WorkoutBlock.fromJson(Map<String, dynamic> json) {
    return WorkoutBlock(
      exerciseIds: List<String>.from(json['exerciseIds']),
      isSuperset: json['isSuperset'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'exerciseIds': exerciseIds,
      'isSuperset': isSuperset,
    };
  }
}

class WorkoutTemplate {
  final String id;
  String name;

  /// NEW STRUCTURE (supports supersets)
  final List<WorkoutBlock> blocks;

  WorkoutTemplate({
    String? id,
    required this.name,
    List<WorkoutBlock>? blocks,
  })  : id = id ?? const Uuid().v4(),
        blocks = blocks ?? [];

  // ===== BACKWARD COMPATIBILITY =====
  factory WorkoutTemplate.fromJson(Map<String, dynamic> json) {

    // OLD VERSION SUPPORT
    if (json.containsKey('exerciseIds')) {
      final oldIds = List<String>.from(json['exerciseIds']);

      return WorkoutTemplate(
        id: json['id'],
        name: json['name'],
        blocks: oldIds.map((e) => WorkoutBlock.single(e)).toList(),
      );
    }

    // NEW VERSION
    return WorkoutTemplate(
      id: json['id'],
      name: json['name'],
      blocks: (json['blocks'] as List)
          .map((b) => WorkoutBlock.fromJson(b))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'blocks': blocks.map((b) => b.toJson()).toList(),
    };
  }

  // ===== HELPERS =====

  /// Flat list (for compatibility with rest of app)
  List<String> get allExerciseIds =>
      blocks.expand((b) => b.exerciseIds).toList();

  /// Add normal exercise
  void addExercise(String id) {
    blocks.add(WorkoutBlock.single(id));
  }

  /// Add superset
  void addSuperset(List<String> ids) {
    blocks.add(WorkoutBlock.superset(ids));
  }

  /// Remove exercise (fixes your error)
  void removeExercise(String id) {
    for (final block in blocks) {
      block.exerciseIds.remove(id);
    }
    blocks.removeWhere((b) => b.exerciseIds.isEmpty);
  }
}