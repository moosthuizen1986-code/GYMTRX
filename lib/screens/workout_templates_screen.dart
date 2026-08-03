import 'package:flutter/material.dart';

import '../models/workout_template.dart';
import '../services/workout_template_repository.dart';
import '../services/exercise_repository.dart';
import 'workout_template_detail_screen.dart';

class WorkoutTemplatesScreen extends StatefulWidget {
  final WorkoutTemplateRepository templateRepository;
  final ExerciseRepository exerciseRepository;

  const WorkoutTemplatesScreen({
    super.key,
    required this.templateRepository,
    required this.exerciseRepository,
  });

  @override
  State<WorkoutTemplatesScreen> createState() =>
      _WorkoutTemplatesScreenState();
}

class _WorkoutTemplatesScreenState
    extends State<WorkoutTemplatesScreen> {
  List<WorkoutTemplate> get templates =>
      widget.templateRepository.templates;

  void _addTemplate() async {
    final template = WorkoutTemplate(name: 'New Workout');

    await widget.templateRepository.addTemplate(template);

    if (!mounted) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => WorkoutTemplateDetailScreen(
          template: template,
          templateRepository: widget.templateRepository,
          exerciseRepository: widget.exerciseRepository,
        ),
      ),
    ).then((_) => setState(() {}));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text(
          'Workout Templates',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: templates.isEmpty
          ? const Center(
              child: Text(
                'No templates yet\nTap + to add one',
                textAlign: TextAlign.center,
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
                      Icons.chevron_right,
                      color: Colors.redAccent,
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => WorkoutTemplateDetailScreen(
                            template: template,
                            templateRepository:
                                widget.templateRepository,
                            exerciseRepository:
                                widget.exerciseRepository,
                          ),
                        ),
                      ).then((_) => setState(() {}));
                    },
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.redAccent,
        onPressed: _addTemplate,
        child: const Icon(Icons.add),
      ),
    );
  }
}