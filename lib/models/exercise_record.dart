class ExerciseRecord {
  final String exerciseName;

  // Existing records
  double bestWeight;
  int bestReps;
  double bestVolume;

  // NEW - Best overall performance
  double bestSetWeight;
  int bestSetReps;
  double bestEstimated1RM;
  DateTime? bestSetDate;

  ExerciseRecord({
    required this.exerciseName,
    this.bestWeight = 0,
    this.bestReps = 0,
    this.bestVolume = 0,
    this.bestSetWeight = 0,
    this.bestSetReps = 0,
    this.bestEstimated1RM = 0,
    this.bestSetDate,
  });

  factory ExerciseRecord.fromJson(Map<String, dynamic> json) {
    return ExerciseRecord(
      exerciseName: json['exerciseName'],
      bestWeight: (json['bestWeight'] ?? 0).toDouble(),
      bestReps: json['bestReps'] ?? 0,
      bestVolume: (json['bestVolume'] ?? 0).toDouble(),

      bestSetWeight: (json['bestSetWeight'] ?? 0).toDouble(),
      bestSetReps: json['bestSetReps'] ?? 0,
      bestEstimated1RM:
          (json['bestEstimated1RM'] ?? 0).toDouble(),

      bestSetDate: json['bestSetDate'] != null
          ? DateTime.parse(json['bestSetDate'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'exerciseName': exerciseName,
      'bestWeight': bestWeight,
      'bestReps': bestReps,
      'bestVolume': bestVolume,

      'bestSetWeight': bestSetWeight,
      'bestSetReps': bestSetReps,
      'bestEstimated1RM': bestEstimated1RM,

      'bestSetDate':
          bestSetDate?.toIso8601String(),
    };
  }
}