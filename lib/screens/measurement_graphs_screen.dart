import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../services/measurement_repository.dart';
import '../models/measurement_entry.dart';

class MeasurementGraphsScreen extends StatefulWidget {
  final MeasurementRepository repo;

  const MeasurementGraphsScreen({super.key, required this.repo});

  @override
  State<MeasurementGraphsScreen> createState() =>
      _MeasurementGraphsScreenState();
}

class _MeasurementGraphsScreenState extends State<MeasurementGraphsScreen> {
  int _pageIndex = 0;
  bool _showWeekly = true;
  int? _touchedIndex;

  final Map<int, double> _goals = {
    0: 85,
    1: 80,
    2: 110,
    3: 100,
  };

  String _formatDate(DateTime d) {
    return "${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}";
  }

  List<MeasurementEntry> _filteredEntries() {
    final now = DateTime.now();
    final cutoff = _showWeekly
        ? now.subtract(const Duration(days: 7))
        : now.subtract(const Duration(days: 30));

    final list = widget.repo.entries
        .where((e) => e.date.isAfter(cutoff))
        .toList();

    list.sort((a, b) => a.date.compareTo(b.date));
    return list;
  }

  double _getMetricValue(MeasurementEntry e) {
    switch (_pageIndex) {
      case 1:
        return e.waist;
      case 2:
        return e.chest;
      case 3:
        return e.hips;
      default:
        return e.bodyWeight;
    }
  }

  List<FlSpot> _buildSpots(List<MeasurementEntry> entries) {
    return List.generate(
      entries.length,
      (i) => FlSpot(i.toDouble(), _getMetricValue(entries[i])),
    );
  }

  bool _isImproving(List<FlSpot> spots) {
    if (spots.length < 2) return true;

    final goal = _goals[_pageIndex];
    if (goal == null) return true;

    final firstDist = (spots.first.y - goal).abs();
    final lastDist = (spots.last.y - goal).abs();

    return lastDist < firstDist;
  }

  String _metricLabel() {
    switch (_pageIndex) {
      case 1:
        return "Waist (cm)";
      case 2:
        return "Chest (cm)";
      case 3:
        return "Hips (cm)";
      default:
        return "Body Weight (kg)";
    }
  }

  @override
  Widget build(BuildContext context) {
    final entries = _filteredEntries();

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text(
          'Progress',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                _showWeekly = !_showWeekly;
                _touchedIndex = null;
              });
            },
            child: Text(
              _showWeekly ? "Weekly" : "Monthly",
              style: const TextStyle(color: Colors.redAccent),
            ),
          ),
        ],
      ),
      body: entries.isEmpty
          ? const Center(
              child: Text(
                "No recent measurements",
                style: TextStyle(color: Colors.white70),
              ),
            )
          : Column(
              children: [
                const SizedBox(height: 8),
                if (_touchedIndex != null &&
                    _touchedIndex! < entries.length)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Text(
                      "${_metricLabel()}: ${_getMetricValue(entries[_touchedIndex!]).toStringAsFixed(1)} • "
                      "Date: ${_formatDate(entries[_touchedIndex!].date)}",
                      style: const TextStyle(color: Colors.white70),
                    ),
                  ),
                Expanded(
                  child: PageView.builder(
                    itemCount: 4,
                    onPageChanged: (i) {
                      setState(() {
                        _pageIndex = i;
                        _touchedIndex = null;
                      });
                    },
                    itemBuilder: (_, __) => _buildChart(entries),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(4, (i) {
                    return Container(
                      margin:
                          const EdgeInsets.symmetric(horizontal: 4),
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: i == _pageIndex
                            ? Colors.redAccent
                            : Colors.white.withValues(alpha: 0.24),
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 12),
              ],
            ),
    );
  }

  Widget _buildChart(List<MeasurementEntry> entries) {
    final spots = _buildSpots(entries);
    final improving = _isImproving(spots);
    final goal = _goals[_pageIndex];

    final lineColor =
        improving ? Colors.greenAccent : Colors.redAccent;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: LineChart(
        LineChartData(
          extraLinesData: goal == null
              ? const ExtraLinesData()
              : ExtraLinesData(horizontalLines: [
                  HorizontalLine(
                    y: goal,
                    color: Colors.blueAccent,
                    strokeWidth: 2,
                    dashArray: [6, 6],
                  ),
                ]),
          lineTouchData: LineTouchData(
            touchCallback: (event, response) {
              if (!event.isInterestedForInteractions ||
                  response?.lineBarSpots == null ||
                  response!.lineBarSpots!.isEmpty) {
                setState(() => _touchedIndex = null);
                return;
              }
              setState(() => _touchedIndex =
                  response.lineBarSpots!.first.spotIndex);
            },
          ),
          gridData: const FlGridData(show: true),
          borderData: FlBorderData(
            show: true,
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.24),
            ),
          ),
          titlesData: const FlTitlesData(
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            topTitles: AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            rightTitles: AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
          ),
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: true,
              barWidth: 3,
              color: lineColor,
              dotData: const FlDotData(show: true),
              belowBarData: BarAreaData(
                show: true,
                color: lineColor.withValues(alpha: 0.15),
              ),
            ),
          ],
        ),
      ),
    );
  }
}