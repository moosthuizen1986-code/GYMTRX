import 'package:flutter/material.dart';

import '../models/workout_session.dart';
import '../services/workout_template_repository.dart';
import '../services/workout_history_repository.dart';
import '../services/exercise_repository.dart';
import 'workout_session_screen.dart';

class StartWorkoutScreen extends StatelessWidget {
  final WorkoutTemplateRepository templateRepository;
  final WorkoutHistoryRepository historyRepository;
  final ExerciseRepository exerciseRepository;

  const StartWorkoutScreen({
    super.key,
    required this.templateRepository,
    required this.historyRepository,
    required this.exerciseRepository,
  });

  @override
  Widget build(BuildContext context) {
    final templates = templateRepository.templates;

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        title: const Text(
          'Start Workout',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.black,
      ),
      body: templates.isEmpty
          ? const Center(
              child: Text(
                'No workout templates yet',
                style: TextStyle(color: Colors.white70),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: templates.length,
              itemBuilder: (context, index) {
                final template = templates[index];

                return Card(
                  color: const Color(0xFF1E1E1E),
                  margin: const EdgeInsets.symmetric(vertical: 6),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    title: Text(
                      template.name,
                      style: const TextStyle(color: Colors.white),
                    ),
                    trailing: const Icon(
                      Icons.play_arrow,
                      color: Colors.redAccent,
                    ),
                    onTap: () async {
                      final session =
                          WorkoutSession.fromTemplate(template);

                      await historyRepository.saveActiveSession(session);

                      if (!context.mounted) return;

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => WorkoutSessionScreen(
                            session: session,
                            historyRepository: historyRepository,
                            templateRepository: templateRepository,
                            exerciseRepository: exerciseRepository,
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
    );
  }
}