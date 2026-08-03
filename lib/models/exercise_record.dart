class ExerciseRecord {
  final String exerciseName;

  double bestWeight;
  int bestReps;
  double bestVolume;

  ExerciseRecord({
    required this.exerciseName,
    this.bestWeight = 0,
    this.bestReps = 0,
    this.bestVolume = 0,
  });

  factory ExerciseRecord.fromJson(Map<String, dynamic> json) {
    return ExerciseRecord(
      exerciseName: json['exerciseName'],
      bestWeight: (json['bestWeight'] as num).toDouble(),
      bestReps: json['bestReps'],
      bestVolume: (json['bestVolume'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'exerciseName': exerciseName,
      'bestWeight': bestWeight,
      'bestReps': bestReps,
      'bestVolume': bestVolume,
    };
  }
}