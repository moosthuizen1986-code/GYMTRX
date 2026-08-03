import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

import '../services/workout_history_repository.dart';

class ExerciseProgressScreen extends StatelessWidget {
  final String exerciseName;
  final WorkoutHistoryRepository historyRepository;

  const ExerciseProgressScreen({
    super.key,
    required this.exerciseName,
    required this.historyRepository,
  });

  @override
  Widget build(BuildContext context) {
    final weights =
        historyRepository.getExerciseBestWeights(exerciseName);
    final volumes =
        historyRepository.getExerciseVolumes(exerciseName);
    final dates =
        historyRepository.getExerciseDates(exerciseName);

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(
          exerciseName,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: weights.isEmpty
          ? const Center(
              child: Text(
                "Not enough data yet",
                style: TextStyle(color: Colors.white70),
              ),
            )
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                const Text(
                  "Best Weight Progress",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                _chart(weights, dates),
                const SizedBox(height: 32),
                const Text(
                  "Total Volume",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                _chart(volumes, dates),
              ],
            ),
    );
  }

  Widget _chart(List<double> values, List<String> labels) {
    return SizedBox(
      height: 260,
      child: LineChart(
        LineChartData(
          gridData: const FlGridData(show: true),
          borderData: FlBorderData(
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.1),
            ),
          ),
          titlesData: FlTitlesData(
            leftTitles: const AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 42,
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                interval: 1,
                getTitlesWidget: (value, meta) {
                  final i = value.toInt();
                  if (i < 0 || i >= labels.length) {
                    return const SizedBox();
                  }

                  return Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(
                      labels[i],
                      style: const TextStyle(
                        color: Colors.white54,
                        fontSize: 10,
                      ),
                    ),
                  );
                },
              ),
            ),
            rightTitles: const AxisTitles(),
            topTitles: const AxisTitles(),
          ),
          lineBarsData: [
            LineChartBarData(
              spots: [
                for (int i = 0; i < values.length; i++)
                  FlSpot(i.toDouble(), values[i]),
              ],
              isCurved: true,
              color: Colors.redAccent,
              barWidth: 3,
              dotData: const FlDotData(show: true),
            ),
          ],
        ),
      ),
    );
  }
}