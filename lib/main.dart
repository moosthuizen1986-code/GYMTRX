import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'services/exercise_repository.dart';
import 'services/workout_template_repository.dart';
import 'services/workout_history_repository.dart';
import 'services/measurement_repository.dart';

import 'screens/splash_screen.dart';

import 'theme/app_theme.dart';

/// GLOBAL NOTIFICATION PLUGIN
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  const androidSettings =
      AndroidInitializationSettings('@mipmap/ic_launcher');

  const initializationSettings =
      InitializationSettings(android: androidSettings);

  await flutterLocalNotificationsPlugin.initialize(
    initializationSettings,
  );

  final exerciseRepo = ExerciseRepository();
  final templateRepo = WorkoutTemplateRepository();
  final historyRepo = WorkoutHistoryRepository();
  final measurementRepo = MeasurementRepository();

  try {
    await exerciseRepo.load();
    await templateRepo.load();
    await historyRepo.load();
    await measurementRepo.load();
  } catch (e) {
    debugPrint("Repository load error: $e");
  }

  runApp(
    MyApp(
      exerciseRepository: exerciseRepo,
      templateRepository: templateRepo,
      historyRepository: historyRepo,
      measurementRepository: measurementRepo,
    ),
  );
}

class MyApp extends StatelessWidget {
  final ExerciseRepository exerciseRepository;
  final WorkoutTemplateRepository templateRepository;
  final WorkoutHistoryRepository historyRepository;
  final MeasurementRepository measurementRepository;

  const MyApp({
    super.key,
    required this.exerciseRepository,
    required this.templateRepository,
    required this.historyRepository,
    required this.measurementRepository,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GYMTRX',
      debugShowCheckedModeBanner: false,

      theme: AppTheme.dark,

      home: SplashScreen(
        exerciseRepository: exerciseRepository,
        templateRepository: templateRepository,
        historyRepository: historyRepository,
        measurementRepository: measurementRepository,
      ),
    );
  }
}