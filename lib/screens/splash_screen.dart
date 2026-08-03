import 'package:flutter/material.dart';

import '../services/exercise_repository.dart';
import '../services/workout_template_repository.dart';
import '../services/workout_history_repository.dart';
import '../services/measurement_repository.dart';

import 'main_tab_shell.dart';
import 'workout_session_screen.dart';

class SplashScreen extends StatelessWidget {
  final ExerciseRepository exerciseRepository;
  final WorkoutTemplateRepository templateRepository;
  final WorkoutHistoryRepository historyRepository;
  final MeasurementRepository measurementRepository;

  const SplashScreen({
    super.key,
    required this.exerciseRepository,
    required this.templateRepository,
    required this.historyRepository,
    required this.measurementRepository,
  });

  Future<void> _handleEnter(BuildContext context) async {
    final activeSession =
        await historyRepository.loadActiveSession();

    if (!context.mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => MainTabShell(
          exerciseRepository: exerciseRepository,
          templateRepository: templateRepository,
          historyRepository: historyRepository,
          measurementRepository: measurementRepository,
        ),
      ),
    );

    if (activeSession != null) {
      await Future.delayed(const Duration(milliseconds: 300));

      if (!context.mounted) return;

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => WorkoutSessionScreen(
            session: activeSession,
            historyRepository: historyRepository,
            templateRepository: templateRepository,
            exerciseRepository: exerciseRepository,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,

      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/ui/background_texture.png"),
            fit: BoxFit.cover,
          ),
        ),

        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.black.withOpacity(0.35),
                Colors.black.withOpacity(0.7),
              ],
            ),
          ),

          child: Column(
            children: [

              const Spacer(flex: 2),

              // LOGO
              Center(
                child: Image.asset(
                  'assets/logo.png',
                  width: 1300,
                  fit: BoxFit.contain,
                ),
              ),

              const Spacer(flex: 3),

              // ENTER BUTTON
              Padding(
                padding: const EdgeInsets.only(bottom: 70),
                child: Material(
                  borderRadius: BorderRadius.circular(18),
                  elevation: 10,
                  shadowColor: Colors.redAccent.withOpacity(0.6),

                  child: InkWell(
                    borderRadius: BorderRadius.circular(18),
                    onTap: () => _handleEnter(context),

                    child: Container(
                      width: 260,
                      height: 56,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(18),

                        gradient: const LinearGradient(
                          colors: [
                            Color(0xFFFF3B30),
                            Color(0xFFB00020),
                          ],
                        ),

                        boxShadow: [
                          BoxShadow(
                            color: Colors.redAccent.withOpacity(0.5),
                            blurRadius: 20,
                            spreadRadius: 1,
                          ),
                        ],
                      ),

                      child: const Center(
                        child: Text(
                          'ENTER',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.5,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),

            ],
          ),
        ),
      ),
    );
  }
}