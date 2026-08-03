import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart'; // ✅ ADDED

import 'services/exercise_repository.dart';
import 'services/workout_template_repository.dart';
import 'services/workout_history_repository.dart';
import 'services/measurement_repository.dart';
import 'screens/splash_screen.dart';

/// ✅ GLOBAL NOTIFICATION PLUGIN
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ✅ INITIALIZE NOTIFICATIONS
  const androidSettings =
      AndroidInitializationSettings('@mipmap/ic_launcher');

  const initializationSettings =
      InitializationSettings(android: androidSettings);

  await flutterLocalNotificationsPlugin.initialize(initializationSettings);

  final exerciseRepo = ExerciseRepository();
  final templateRepo = WorkoutTemplateRepository();
  final historyRepo = WorkoutHistoryRepository();
  final measurementRepo = MeasurementRepository();

  // 🔒 Safe loading (prevents silent data corruption crashes)
  try {
    await exerciseRepo.load();
    await templateRepo.load();
    await historyRepo.load();
    await measurementRepo.load();
  } catch (e) {
    debugPrint("Repository load error: $e");
  }

  runApp(MyApp(
    exerciseRepository: exerciseRepo,
    templateRepository: templateRepo,
    historyRepository: historyRepo,
    measurementRepository: measurementRepo,
  ));
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
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0B0F14),
        primaryColor: Colors.redAccent,

        colorScheme: const ColorScheme.dark(
          primary: Colors.redAccent,
          secondary: Colors.redAccent,
          surface: Color(0xFF11161C),
        ),

        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF11161C),
          elevation: 2,
          centerTitle: true,
        ),

        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.redAccent,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),

        cardTheme: CardThemeData(
          color: const Color(0xFF11161C),
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
      home: SplashScreen(
        exerciseRepository: exerciseRepository,
        templateRepository: templateRepository,
        historyRepository: historyRepository,
        measurementRepository: measurementRepository,
      ),
    );
  }
}