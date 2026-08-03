import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/exercise.dart';

class ExerciseRepository {
  static const _storageKey = 'exercises';

  final List<Exercise> _exercises = [];

  List<Exercise> get exercises => _exercises;

  /// Entry point used by main.dart
  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();

    final stored = prefs.getString(_storageKey);

    if (stored != null) {
      _loadFromStorage(stored);
    } else {
      await _loadFromCsv();
      await save();
    }
  }

  Future<void> _loadFromCsv() async {
    final csv = await rootBundle.loadString('assets/exercises.csv');
    final lines = csv.split('\n');

    _exercises.clear();

    for (int i = 1; i < lines.length; i++) {
      final line = lines[i].trim();
      if (line.isEmpty) continue;

      final parts = line.split(',');

      if (parts.length < 2) continue;

      _exercises.add(
        Exercise(
          name: parts[0].trim(),
          muscleGroup: parts[1].trim(),
        ),
      );
    }
  }

  void _loadFromStorage(String jsonStr) {
    final List data = jsonDecode(jsonStr);
    _exercises
      ..clear()
      ..addAll(data.map((e) => Exercise.fromJson(e)));
  }

  Future<void> save() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = jsonEncode(_exercises.map((e) => e.toJson()).toList());
    await prefs.setString(_storageKey, jsonStr);
  }

  void addExercise(Exercise exercise) {
    _exercises.add(exercise);
  }

  void deleteExercise(Exercise exercise) {
    _exercises.remove(exercise);
  }
}