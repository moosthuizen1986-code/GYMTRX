import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/workout_template.dart';

class WorkoutTemplateRepository {
  static const _storageKey = 'workout_templates';

  final List<WorkoutTemplate> _templates = [];

  List<WorkoutTemplate> get templates =>
      List.unmodifiable(_templates);

  /// Load templates from local storage
  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_storageKey);

    if (raw == null) return;

    final List decoded = jsonDecode(raw);
    _templates
      ..clear()
      ..addAll(
        decoded.map(
          (e) => WorkoutTemplate.fromJson(
            e as Map<String, dynamic>,
          ),
        ),
      );
  }

  /// Persist templates
  Future<void> save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _storageKey,
      jsonEncode(
        _templates.map((e) => e.toJson()).toList(),
      ),
    );
  }

  Future<void> addTemplate(WorkoutTemplate template) async {
    _templates.add(template);
    await save();
  }

  Future<void> deleteTemplate(String id) async {
    _templates.removeWhere((t) => t.id == id);
    await save();
  }

  WorkoutTemplate? getById(String id) {
    try {
      return _templates.firstWhere((t) => t.id == id);
    } catch (_) {
      return null;
    }
  }
}