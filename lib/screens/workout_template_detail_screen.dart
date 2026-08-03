import 'package:flutter/material.dart';

import '../models/workout_template.dart';
import '../services/workout_template_repository.dart';
import '../services/exercise_repository.dart';
import '../models/exercise.dart';

class WorkoutTemplateDetailScreen extends StatefulWidget {
  final WorkoutTemplate template;
  final WorkoutTemplateRepository templateRepository;
  final ExerciseRepository exerciseRepository;

  const WorkoutTemplateDetailScreen({
    super.key,
    required this.template,
    required this.templateRepository,
    required this.exerciseRepository,
  });

  @override
  State<WorkoutTemplateDetailScreen> createState() =>
      _WorkoutTemplateDetailScreenState();
}

class _WorkoutTemplateDetailScreenState
    extends State<WorkoutTemplateDetailScreen> {
  late TextEditingController _nameController;

  String _searchQuery = "";
  String _selectedMuscle = "All";
  final Set<String> _selectedForAdd = {};

  static const List<String> _muscleFilters = [
    "All",
    "Chest",
    "Back",
    "Shoulders",
    "Legs",
    "Arms",
    "Core",
    "Cardio",
  ];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.template.name);
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    widget.template.name = _nameController.text.trim();
    await widget.templateRepository.save();

    if (!mounted) return;
    Navigator.pop(context);
  }

  List<Exercise> _getFilteredExercises() {
    return widget.exerciseRepository.exercises.where((e) {
      final matchesSearch =
          e.name.toLowerCase().contains(_searchQuery.toLowerCase());

      final matchesFilter = _selectedMuscle == "All" ||
          e.muscleGroup
              .toLowerCase()
              .contains(_selectedMuscle.toLowerCase());

      return matchesSearch && matchesFilter;
    }).toList();
  }

  void _addExerciseDialog() {
    _selectedForAdd.clear();

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) {
          final filtered = _getFilteredExercises();
          final creatingSuperset = _selectedForAdd.length >= 2;

          return AlertDialog(
            backgroundColor: const Color(0xFF1E1E1E),
            title: const Text(
              'Add Exercises',
              style: TextStyle(color: Colors.white),
            ),
            content: SizedBox(
              width: double.maxFinite,
              height: 520,
              child: Column(
                children: [
                  TextField(
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      labelText: "Search exercises",
                      prefixIcon:
                          Icon(Icons.search, color: Colors.white70),
                    ),
                    onChanged: (value) =>
                        setDialogState(() => _searchQuery = value),
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    initialValue: _selectedMuscle,
                    dropdownColor: const Color(0xFF1E1E1E),
                    style: const TextStyle(color: Colors.white),
                    items: _muscleFilters
                        .map(
                          (m) => DropdownMenuItem(
                            value: m,
                            child: Text(m),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      if (value == null) return;
                      setDialogState(() => _selectedMuscle = value);
                    },
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: ListView.builder(
                      itemCount: filtered.length,
                      itemBuilder: (context, index) {
                        final exercise = filtered[index];
                        final isSelected =
                            _selectedForAdd.contains(exercise.name);

                        return ListTile(
                          title: Text(
                            exercise.name,
                            style:
                                const TextStyle(color: Colors.white),
                          ),
                          subtitle: Text(
                            exercise.muscleGroup,
                            style: const TextStyle(
                                color: Colors.white70),
                          ),
                          trailing: Icon(
                            isSelected
                                ? Icons.check_circle
                                : Icons.circle_outlined,
                            color: isSelected
                                ? Colors.redAccent
                                : Colors.white54,
                          ),
                          onTap: () {
                            setDialogState(() {
                              if (isSelected) {
                                _selectedForAdd.remove(exercise.name);
                              } else {
                                _selectedForAdd.add(exercise.name);
                              }
                            });
                          },
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent,
                      minimumSize:
                          const Size(double.infinity, 46),
                    ),
                    onPressed: _selectedForAdd.isEmpty
                        ? null
                        : () async {
                            final navigator =
                                Navigator.of(dialogContext);

                            setState(() {
                              if (_selectedForAdd.length == 1) {
                                widget.template.addExercise(
                                    _selectedForAdd.first);
                              } else {
                                widget.template.addSuperset(
                                    _selectedForAdd.toList());
                              }
                            });

                            await widget.templateRepository.save();

                            if (!mounted) return;
                            navigator.pop();
                          },
                    child: Text(
                      creatingSuperset
                          ? "Create Superset (${_selectedForAdd.length})"
                          : "Add Exercise",
                      style: const TextStyle(
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildBlockTile(
      WorkoutBlock block, int index) {
    final isSuperset = block.isSuperset;
    final title = isSuperset
        ? block.exerciseIds.join("  +  ")
        : block.exerciseIds.first;

    return Card(
      color: const Color(0xFF1E1E1E),
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: ListTile(
        leading: Icon(
          isSuperset ? Icons.link : Icons.fitness_center,
          color:
              isSuperset ? Colors.redAccent : Colors.white70,
        ),
        title: Text(
          title,
          style: const TextStyle(color: Colors.white),
        ),
        subtitle: isSuperset
            ? const Text(
                "Superset",
                style:
                    TextStyle(color: Colors.redAccent),
              )
            : null,
        trailing: IconButton(
          icon: const Icon(Icons.delete,
              color: Colors.redAccent),
          onPressed: () async {
            setState(() {
              widget.template.blocks.removeAt(index);
            });

            await widget.templateRepository.save();

            if (!mounted) return;
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final blocks = widget.template.blocks;

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text('Edit Template'),
        actions: [
          IconButton(
            icon: const Icon(Icons.check,
                color: Colors.redAccent),
            onPressed: _save,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              style:
                  const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                  labelText: 'Workout name'),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment:
                  MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Exercises',
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight:
                          FontWeight.bold,
                      color: Colors.white),
                ),
                IconButton(
                  icon: const Icon(Icons.add,
                      color: Colors.redAccent),
                  onPressed: _addExerciseDialog,
                ),
              ],
            ),
            Expanded(
              child: blocks.isEmpty
                  ? const Center(
                      child: Text(
                        'No exercises added yet',
                        style: TextStyle(color: Colors.grey),
                      ),
                    )
                  : ListView.builder(
                      itemCount: blocks.length,
                      itemBuilder: (context, index) =>
                          _buildBlockTile(
                              blocks[index], index),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}