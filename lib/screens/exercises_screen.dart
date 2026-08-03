import 'package:flutter/material.dart';

import '../models/exercise.dart';
import '../services/exercise_repository.dart';
import '../services/workout_history_repository.dart';
import 'exercise_detail_screen.dart';

class ExercisesScreen extends StatefulWidget {
  final ExerciseRepository exerciseRepository;
  final WorkoutHistoryRepository historyRepository;

  const ExercisesScreen({
    super.key,
    required this.exerciseRepository,
    required this.historyRepository,
  });

  @override
  State<ExercisesScreen> createState() => _ExercisesScreenState();
}

class _ExercisesScreenState extends State<ExercisesScreen> {
  void _openExercise(Exercise exercise) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ExerciseDetailScreen(
          exercise: exercise,
          exerciseRepository: widget.exerciseRepository,
          historyRepository: widget.historyRepository,
        ),
      ),
    );

    setState(() {});
  }

  void _addExercise() async {
    final newExercise = Exercise(name: 'New Exercise', muscleGroup: 'Chest');

    widget.exerciseRepository.addExercise(newExercise);
    await widget.exerciseRepository.save();

    if (!mounted) return;

    _openExercise(newExercise);
  }

  @override
  Widget build(BuildContext context) {
    final exercises = widget.exerciseRepository.exercises;

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text(
          'Exercises',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: exercises.isEmpty
          ? const Center(
              child: Text(
                'No exercises yet',
                style: TextStyle(color: Colors.white70),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: exercises.length,
              itemBuilder: (context, index) {
                final exercise = exercises[index];

                final record =
                    widget.historyRepository.records[exercise.name];

                return Card(
                  color: const Color(0xFF1E1E1E),
                  margin: const EdgeInsets.symmetric(vertical: 6),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    onTap: () => _openExercise(exercise),
                    title: Text(
                      exercise.name,
                      style: const TextStyle(color: Colors.white),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          exercise.muscleGroup,
                          style: const TextStyle(color: Colors.white70),
                        ),
                        if (record != null)
                          Text(
                            'Best: ${record.bestWeight}kg × ${record.bestReps}',
                            style: const TextStyle(
                              color: Colors.greenAccent,
                              fontSize: 12,
                            ),
                          ),
                      ],
                    ),
                    trailing: const Icon(
                      Icons.chevron_right,
                      color: Colors.redAccent,
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.redAccent,
        onPressed: _addExercise,
        child: const Icon(Icons.add),
      ),
    );
  }
}