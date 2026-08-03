import 'dart:ui';
import 'package:flutter/material.dart';

import '../services/exercise_repository.dart';
import '../services/workout_template_repository.dart';
import '../services/workout_history_repository.dart';
import '../services/measurement_repository.dart';

import 'home_screen.dart';
import 'workout_templates_screen.dart';
import 'exercises_screen.dart';
import 'performance_insights_screen.dart';
import 'workout_history_screen.dart';
import 'measurements_screen.dart';

class MainTabShell extends StatefulWidget {
  final ExerciseRepository exerciseRepository;
  final WorkoutTemplateRepository templateRepository;
  final WorkoutHistoryRepository historyRepository;
  final MeasurementRepository measurementRepository;

  const MainTabShell({
    super.key,
    required this.exerciseRepository,
    required this.templateRepository,
    required this.historyRepository,
    required this.measurementRepository,
  });

  @override
  State<MainTabShell> createState() => _MainTabShellState();
}

class _MainTabShellState extends State<MainTabShell> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final tabs = [
      HomeScreen(
        exerciseRepository: widget.exerciseRepository,
        templateRepository: widget.templateRepository,
        historyRepository: widget.historyRepository,
        measurementRepository: widget.measurementRepository,
      ),
      WorkoutTemplatesScreen(
        templateRepository: widget.templateRepository,
        exerciseRepository: widget.exerciseRepository,
      ),
      ExercisesScreen(
        exerciseRepository: widget.exerciseRepository,
        historyRepository: widget.historyRepository,
      ),
      PerformanceInsightsScreen(
        historyRepository: widget.historyRepository,
        exerciseRepository: widget.exerciseRepository,
      ),
      MeasurementsScreen(
        repo: widget.measurementRepository,
      ),
      WorkoutHistoryScreen(
        historyRepository: widget.historyRepository,
        templateRepository: widget.templateRepository,
      ),
    ];

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: tabs,
      ),

      bottomNavigationBar: ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.65),
              border: Border(
                top: BorderSide(
                  color: Colors.redAccent.withOpacity(0.35),
                  width: 1,
                ),
              ),
            ),
            child: BottomNavigationBar(
              type: BottomNavigationBarType.fixed,
              backgroundColor: Colors.transparent,
              elevation: 0,
              iconSize: 26,
              selectedItemColor: const Color(0xFFFF3B30),
              unselectedItemColor: Colors.white54,
              showSelectedLabels: true,
              showUnselectedLabels: true,
              selectedLabelStyle: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
              currentIndex: _currentIndex,
              onTap: (index) {
                setState(() {
                  _currentIndex = index;
                });
              },
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.home),
                  label: "Home",
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.list_alt),
                  label: "Templates",
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.fitness_center),
                  label: "Exercises",
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.analytics),
                  label: "Performance",
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.straighten),
                  label: "Measurements",
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.history),
                  label: "History",
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}