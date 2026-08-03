class Exercise {
  String name;
  String muscleGroup;
  final List<ExerciseSet> sets;

  Exercise({
    required this.name,
    required this.muscleGroup,
    List<ExerciseSet>? sets,
  }) : sets = sets ?? [];

  factory Exercise.fromJson(Map<String, dynamic> json) {
    return Exercise(
      name: json['name'],
      muscleGroup: json['muscleGroup'],
      sets: (json['sets'] as List<dynamic>)
          .map((s) => ExerciseSet.fromJson(s))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'muscleGroup': muscleGroup,
      'sets': sets.map((s) => s.toJson()).toList(),
    };
  }
}

class ExerciseSet {
  int reps;
  double weight;

  ExerciseSet({
    required this.reps,
    required this.weight,
  });

  factory ExerciseSet.fromJson(Map<String, dynamic> json) {
    return ExerciseSet(
      reps: json['reps'],
      weight: json['weight'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'reps': reps,
      'weight': weight,
    };
  }
}