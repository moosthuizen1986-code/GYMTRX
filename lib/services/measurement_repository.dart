import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/measurement_entry.dart';

class MeasurementRepository {
  static const _storageKey = 'measurements';

  final List<MeasurementEntry> _entries = [];

  List<MeasurementEntry> get entries =>
      List.unmodifiable(_entries);

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_storageKey);
    if (raw == null) return;

    final List decoded = jsonDecode(raw);
    _entries
      ..clear()
      ..addAll(decoded.map(
        (e) => MeasurementEntry.fromJson(e),
      ));
  }

  Future<void> addEntry(MeasurementEntry entry) async {
    _entries.add(entry);
    await _save();
  }

  Future<void> updateEntry(MeasurementEntry updated) async {
    final index =
        _entries.indexWhere((e) => e.id == updated.id);

    if (index != -1) {
      _entries[index] = updated;
      await _save();
    }
  }

  Future<void> deleteEntry(String id) async {
    _entries.removeWhere((e) => e.id == id);
    await _save();
  }

  MeasurementEntry? get lastEntry =>
      _entries.isEmpty ? null : _entries.last;

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _storageKey,
      jsonEncode(
        _entries.map((e) => e.toJson()).toList(),
      ),
    );
  }
}