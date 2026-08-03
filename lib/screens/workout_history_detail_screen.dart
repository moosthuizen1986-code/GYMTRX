import 'package:flutter/material.dart';

import '../models/workout_session.dart';
import '../models/workout_template.dart';
import '../services/workout_template_repository.dart';
import '../services/workout_history_repository.dart';
import 'exercise_progress_screen.dart';

class WorkoutHistoryDetailScreen extends StatelessWidget {
  final WorkoutSession session;
  final WorkoutTemplateRepository templateRepository;
  final WorkoutHistoryRepository historyRepository;

  const WorkoutHistoryDetailScreen({
    super.key,
    required this.session,
    required this.templateRepository,
    required this.historyRepository,
  });

  WorkoutTemplate? _getTemplate() {
    return templateRepository.getById(session.templateId);
  }

  @override
  Widget build(BuildContext context) {
    final template = _getTemplate();

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(
          session.templateName,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: template == null
          ? const Center(
              child: Text(
                "Template not found",
                style: TextStyle(color: Colors.white70),
              ),
            )
          : ListView(
              padding: const EdgeInsets.all(12),
              children: [
                _summaryCard(),
                const SizedBox(height: 8),
                ...template.blocks.map((block) => _buildBlock(context, block)),
              ],
            ),
    );
  }

  Widget _summaryCard() {
    return Card(
      color: const Color(0xFF1E1E1E),
      margin: const EdgeInsets.symmetric(vertical: 6),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Workout Summary',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Total Sets: ${session.totalSets ?? 0}',
              style: const TextStyle(color: Colors.white70),
            ),
            Text(
              'Total Volume: ${session.totalVolume?.toStringAsFixed(1) ?? "0"} kg',
              style: const TextStyle(color: Colors.white70),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBlock(BuildContext context, WorkoutBlock block) {
    if (block.isSuperset) {
      return _supersetCard(context, block);
    } else {
      return _exerciseCard(context, block.exerciseIds.first);
    }
  }

  Widget _exerciseCard(BuildContext context, String exerciseName) {
    final sets = session.exercises[exerciseName] ?? [];

    double totalVolume = 0;
    for (var s in sets) {
      totalVolume += s.reps * s.weight;
    }

    return Card(
      color: const Color(0xFF1E1E1E),
      margin: const EdgeInsets.symmetric(vertical: 6),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ExerciseProgressScreen(
                exerciseName: exerciseName,
                historyRepository: historyRepository,
              ),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                exerciseName,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Sets: ${sets.length}',
                style: const TextStyle(color: Colors.white70),
              ),
              Text(
                'Volume: ${totalVolume.toStringAsFixed(1)} kg',
                style: const TextStyle(color: Colors.white70),
              ),
              const SizedBox(height: 10),
              ...sets.asMap().entries.map((entry) {
                final i = entry.key + 1;
                final set = entry.value;

                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 36,
                        child: Text("S$i",
                            style: const TextStyle(color: Colors.white38)),
                      ),
                      Expanded(
                        child: Text("${set.reps} reps",
                            style: const TextStyle(color: Colors.white70)),
                      ),
                      Text("${set.weight} kg",
                          style: const TextStyle(
                              color: Colors.redAccent,
                              fontWeight: FontWeight.w600)),
                    ],
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  Widget _supersetCard(BuildContext context, WorkoutBlock block) {
    return Card(
      color: const Color(0xFF2A1A00),
      margin: const EdgeInsets.symmetric(vertical: 6),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: Colors.orangeAccent, width: 1.2),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("SUPERSET",
                style: TextStyle(
                    color: Colors.orangeAccent,
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            ...block.exerciseIds.map((e) => _exerciseCard(context, e)),
          ],
        ),
      ),
    );
  }
}