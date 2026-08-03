import 'dart:io';
import 'package:flutter/material.dart';
import '../models/measurement_entry.dart';

class MeasurementDetailScreen extends StatelessWidget {
  final MeasurementEntry entry;

  const MeasurementDetailScreen({
    super.key,
    required this.entry,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text(
          'Measurement Detail',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            Text(
              entry.date.toLocal().toString().split(' ')[0],
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 12),
            Text('Body Weight: ${entry.bodyWeight} kg',
                style: const TextStyle(color: Colors.white70)),
            Text('Chest: ${entry.chest} cm',
                style: const TextStyle(color: Colors.white70)),
            Text('Arms: ${entry.arms} cm',
                style: const TextStyle(color: Colors.white70)),
            Text('Waist: ${entry.waist} cm',
                style: const TextStyle(color: Colors.white70)),
            Text('Hips: ${entry.hips} cm',
                style: const TextStyle(color: Colors.white70)),
            Text('Thighs: ${entry.thighs} cm',
                style: const TextStyle(color: Colors.white70)),
            Text('Body Fat: ${entry.bodyFat} %',
                style: const TextStyle(color: Colors.white70)),
            const SizedBox(height: 12),
            Text(
              'Notes: ${entry.notes.isEmpty ? "—" : entry.notes}',
              style: const TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 16),
            if (entry.photoPath != null)
              Image.file(
                File(entry.photoPath!),
                height: 250,
                fit: BoxFit.cover,
              ),
          ],
        ),
      ),
    );
  }
}