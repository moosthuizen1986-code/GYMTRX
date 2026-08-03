class MeasurementEntry {
  final String id;
  final DateTime date;

  double bodyWeight;
  double chest;
  double arms;
  double waist;
  double hips;
  double thighs;

  // NEW
  double neck;
  double height;
  double bodyFat;

  String notes;
  String? photoPath;

  MeasurementEntry({
    required this.id,
    required this.date,
    required this.bodyWeight,
    required this.chest,
    required this.arms,
    required this.waist,
    required this.hips,
    required this.thighs,
    required this.neck,
    required this.height,
    required this.bodyFat,
    this.notes = '',
    this.photoPath,
  });

  // ================= FROM JSON =================

  factory MeasurementEntry.fromJson(Map<String, dynamic> json) {
    return MeasurementEntry(
      id: json['id'],
      date: DateTime.parse(json['date']),

      bodyWeight: (json['bodyWeight'] as num?)?.toDouble() ?? 0,
      chest: (json['chest'] as num?)?.toDouble() ?? 0,
      arms: (json['arms'] as num?)?.toDouble() ?? 0,
      waist: (json['waist'] as num?)?.toDouble() ?? 0,
      hips: (json['hips'] as num?)?.toDouble() ?? 0,
      thighs: (json['thighs'] as num?)?.toDouble() ?? 0,

      neck: (json['neck'] as num?)?.toDouble() ?? 0,
      height: (json['height'] as num?)?.toDouble() ?? 0,
      bodyFat: (json['bodyFat'] as num?)?.toDouble() ?? 0,

      notes: json['notes'] ?? '',
      photoPath: json['photoPath'],
    );
  }

  // ================= TO JSON =================

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date.toIso8601String(),

      'bodyWeight': bodyWeight,
      'chest': chest,
      'arms': arms,
      'waist': waist,
      'hips': hips,
      'thighs': thighs,

      'neck': neck,
      'height': height,
      'bodyFat': bodyFat,

      'notes': notes,
      'photoPath': photoPath,
    };
  }
}