import 'package:flutter/material.dart';

import '../models/exercise.dart';
import '../services/exercise_repository.dart';
import '../services/workout_history_repository.dart';
import '../models/exercise_record.dart';

class ExerciseDetailScreen extends StatefulWidget {
  final Exercise exercise;
  final ExerciseRepository exerciseRepository;
  final WorkoutHistoryRepository historyRepository;

  const ExerciseDetailScreen({
    super.key,
    required this.exercise,
    required this.exerciseRepository,
    required this.historyRepository,
  });

  @override
  State<ExerciseDetailScreen> createState() => _ExerciseDetailScreenState();
}

class _ExerciseDetailScreenState extends State<ExerciseDetailScreen> {
  late TextEditingController _nameController;
  late TextEditingController _muscleController;

  ExerciseRecord? record;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.exercise.name);
    _muscleController =
        TextEditingController(text: widget.exercise.muscleGroup);

    record = widget.historyRepository.records[widget.exercise.name];
  }

  Future<void> _saveExercise() async {
    setState(() {
      widget.exercise.name = _nameController.text.trim();
      widget.exercise.muscleGroup = _muscleController.text.trim();
    });

    await widget.exerciseRepository.save();

    if (!mounted) return;
    Navigator.pop(context);
  }

  Widget _buildRecordTile(String label, String value) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              color: Colors.redAccent,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecordsCard() {
    if (record == null) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFF1E1E1E),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Text(
          "No records yet — complete a workout to generate stats",
          style: TextStyle(color: Colors.white70),
          textAlign: TextAlign.center,
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          const Text(
            "Lifetime Records",
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildRecordTile("Best Weight", "${record!.bestWeight} kg"),
              _buildRecordTile("Best Reps", record!.bestReps.toString()),
              _buildRecordTile(
                "Best Volume",
                record!.bestVolume.toStringAsFixed(0),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _editSet(ExerciseSet set) {
    final repsController =
        TextEditingController(text: set.reps.toString());
    final weightController =
        TextEditingController(text: set.weight.toString());

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        title: const Text(
          'Edit Set',
          style: TextStyle(color: Colors.white),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: repsController,
              keyboardType: TextInputType.number,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(labelText: 'Reps'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: weightController,
              keyboardType: TextInputType.number,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(labelText: 'Weight'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'CANCEL',
              style: TextStyle(color: Colors.white70),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
            ),
            onPressed: () async {
              setState(() {
                set.reps =
                    int.tryParse(repsController.text) ?? set.reps;
                set.weight =
                    double.tryParse(weightController.text) ?? set.weight;
              });

              await widget.exerciseRepository.save();

              if (!mounted) return;
              Navigator.pop(context);
            },
            child: const Text('SAVE'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _muscleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text('Exercise'),
        actions: [
          IconButton(
            icon: const Icon(Icons.check, color: Colors.redAccent),
            onPressed: _saveExercise,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildRecordsCard(),
            const SizedBox(height: 20),
            TextField(
              controller: _nameController,
              style: const TextStyle(color: Colors.white),
              decoration:
                  const InputDecoration(labelText: 'Exercise name'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _muscleController,
              style: const TextStyle(color: Colors.white),
              decoration:
                  const InputDecoration(labelText: 'Muscle group'),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: ListView.builder(
                itemCount: widget.exercise.sets.length,
                itemBuilder: (context, index) {
                  final set = widget.exercise.sets[index];

                  return Card(
                    color: const Color(0xFF1E1E1E),
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    child: ListTile(
                      title: Text(
                        '${set.reps} reps @ ${set.weight} kg',
                        style: const TextStyle(color: Colors.white),
                      ),
                      onTap: () => _editSet(set),
                      trailing: IconButton(
                        icon: const Icon(
                          Icons.delete,
                          color: Colors.redAccent,
                        ),
                        onPressed: () async {
                          setState(() {
                            widget.exercise.sets.removeAt(index);
                          });
                          await widget.exerciseRepository.save();
                        },
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}