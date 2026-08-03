import 'dart:math';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';

import '../models/measurement_entry.dart';
import '../services/measurement_repository.dart';

class AddEditMeasurementScreen extends StatefulWidget {
  final MeasurementRepository repo;
  final MeasurementEntry? existing;

  const AddEditMeasurementScreen({
    super.key,
    required this.repo,
    this.existing,
  });

  @override
  State<AddEditMeasurementScreen> createState() =>
      _AddEditMeasurementScreenState();
}

class _AddEditMeasurementScreenState
    extends State<AddEditMeasurementScreen> {

  late TextEditingController weight;
  late TextEditingController chest;
  late TextEditingController arms;
  late TextEditingController waist;
  late TextEditingController hips;
  late TextEditingController thighs;
  late TextEditingController neck;
  late TextEditingController height;
  late TextEditingController notes;

  File? photo;

  @override
  void initState() {
    super.initState();

    final e = widget.existing;

    weight = TextEditingController(text: e?.bodyWeight.toString() ?? '');
    chest = TextEditingController(text: e?.chest.toString() ?? '');
    arms = TextEditingController(text: e?.arms.toString() ?? '');
    waist = TextEditingController(text: e?.waist.toString() ?? '');
    hips = TextEditingController(text: e?.hips.toString() ?? '');
    thighs = TextEditingController(text: e?.thighs.toString() ?? '');
    neck = TextEditingController(text: e?.neck.toString() ?? '');
    height = TextEditingController(text: e?.height.toString() ?? '');
    notes = TextEditingController(text: e?.notes ?? '');

    if (e?.photoPath != null) {
      photo = File(e!.photoPath!);
    }
  }

  Future<void> _pickPhoto() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 80,
    );

    if (picked != null) {
      setState(() => photo = File(picked.path));
    }
  }

  Future<void> _save() async {

    final w = double.tryParse(waist.text) ?? 0;
    final n = double.tryParse(neck.text) ?? 0;
    final h = double.tryParse(height.text) ?? 0;

    double calculatedBF = 0;

    if (w > n && h > 0) {
      calculatedBF =
          86.010 * (log(w - n) / ln10) -
          70.041 * (log(h) / ln10) +
          36.76;
    }

    final entry = MeasurementEntry(
      id: widget.existing?.id ?? const Uuid().v4(),
      date: widget.existing?.date ?? DateTime.now(),

      bodyWeight: double.tryParse(weight.text) ?? 0,
      chest: double.tryParse(chest.text) ?? 0,
      arms: double.tryParse(arms.text) ?? 0,
      waist: w,
      hips: double.tryParse(hips.text) ?? 0,
      thighs: double.tryParse(thighs.text) ?? 0,

      neck: n,
      height: h,
      bodyFat: calculatedBF,

      notes: notes.text,
      photoPath: photo?.path,
    );

    if (widget.existing == null) {
      await widget.repo.addEntry(entry);
    } else {
      await widget.repo.updateEntry(entry);
    }

    if (!mounted) return;
    Navigator.pop(context);
  }

  Widget _field(String label, TextEditingController c) {
    return TextField(
      controller: c,
      keyboardType: TextInputType.number,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white70),
      ),
      onChanged: (_) => setState(() {}),
    );
  }

  @override
  Widget build(BuildContext context) {

    double previewBF = 0;
    final w = double.tryParse(waist.text) ?? 0;
    final n = double.tryParse(neck.text) ?? 0;
    final h = double.tryParse(height.text) ?? 0;

    if (w > n && h > 0) {
      previewBF =
          86.010 * (log(w - n) / ln10) -
          70.041 * (log(h) / ln10) +
          36.76;
    }

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(
          widget.existing == null ? 'Add Measurement' : 'Edit Measurement',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.check, color: Colors.redAccent),
            onPressed: _save,
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [

            _field('Body Weight (kg)', weight),
            _field('Chest (cm)', chest),
            _field('Arms (cm)', arms),
            _field('Waist (cm)', waist),
            _field('Neck (cm)', neck),
            _field('Height (cm)', height),
            _field('Hips (cm)', hips),
            _field('Thighs (cm)', thighs),

            const SizedBox(height: 14),

            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFF1E1E1E),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.redAccent),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Calculated Body Fat",
                      style: TextStyle(color: Colors.white70)),
                  Text(
                    previewBF <= 0 ? '-- %' : '${previewBF.toStringAsFixed(1)} %',
                    style: const TextStyle(
                        color: Colors.redAccent,
                        fontWeight: FontWeight.bold,
                        fontSize: 18),
                  )
                ],
              ),
            ),

            const SizedBox(height: 16),

            TextField(
              controller: notes,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(labelText: 'Notes'),
              maxLines: 3,
            ),

            const SizedBox(height: 16),

            if (photo != null)
              Image.file(photo!, height: 200),

            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
              icon: const Icon(Icons.camera_alt),
              label: const Text('Take Photo'),
              onPressed: _pickPhoto,
            ),
          ],
        ),
      ),
    );
  }
}