class WorkoutSetEntry {
  int reps;
  double weight;
  String note;
  bool done;

  WorkoutSetEntry({
    required this.reps,
    required this.weight,
    this.note = '',
    this.done = false,
  });

  factory WorkoutSetEntry.fromJson(Map<String, dynamic> json) {
    return WorkoutSetEntry(
      reps: json['reps'],
      weight: (json['weight'] as num).toDouble(),
      note: json['note'] ?? '',
      done: json['done'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'reps': reps,
      'weight': weight,
      'note': note,
      'done': done,
    };
  }
}