import 'package:flutter/material.dart';
import '../services/measurement_repository.dart';
import 'add_edit_measurement_screen.dart';
import 'measurement_graphs_screen.dart';
import 'measurement_detail_screen.dart';

class MeasurementsScreen extends StatelessWidget {
  final MeasurementRepository repo;

  const MeasurementsScreen({super.key, required this.repo});

  @override
  Widget build(BuildContext context) {
    final entries = repo.entries.reversed.toList(); // newest first

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text(
          'Measurements',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.show_chart, color: Colors.redAccent),
            onPressed: entries.isEmpty
                ? null
                : () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => MeasurementGraphsScreen(repo: repo),
                      ),
                    );
                  },
          ),
        ],
      ),
      body: entries.isEmpty
          ? const Center(
              child: Text(
                'No measurements yet',
                style: TextStyle(color: Colors.white70),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: entries.length,
              itemBuilder: (context, index) {
                final e = entries[index];

                return Dismissible(
                  key: ValueKey(e.id),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 20),
                    color: Colors.red,
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                  confirmDismiss: (_) async {
                    return await showDialog<bool>(
                      context: context,
                      builder: (_) => AlertDialog(
                        backgroundColor: const Color(0xFF1E1E1E),
                        title: const Text(
                          'Delete entry?',
                          style: TextStyle(color: Colors.white),
                        ),
                        content: const Text(
                          'This cannot be undone.',
                          style: TextStyle(color: Colors.white70),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context, false),
                            child: const Text(
                              'CANCEL',
                              style: TextStyle(color: Colors.white70),
                            ),
                          ),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.redAccent,
                            ),
                            onPressed: () => Navigator.pop(context, true),
                            child: const Text('DELETE'),
                          ),
                        ],
                      ),
                    );
                  },
                  onDismissed: (_) async {
                    await repo.deleteEntry(e.id);
                  },
                  child: Card(
                    color: const Color(0xFF1E1E1E),
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListTile(
                      title: Text(
                        '${e.bodyWeight} kg • ${e.date.toLocal().toString().split(' ')[0]}',
                        style: const TextStyle(color: Colors.white),
                      ),
                      subtitle: Text(
                        'Waist: ${e.waist} cm • Body Fat: ${e.bodyFat}%',
                        style: const TextStyle(color: Colors.white70),
                      ),
                      trailing: const Icon(
                        Icons.chevron_right,
                        color: Colors.redAccent,
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                MeasurementDetailScreen(entry: e),
                          ),
                        );
                      },
                      onLongPress: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => AddEditMeasurementScreen(
                              repo: repo,
                              existing: e,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.redAccent,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => AddEditMeasurementScreen(repo: repo),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}