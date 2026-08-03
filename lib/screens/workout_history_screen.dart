import 'package:flutter/material.dart';

import '../services/workout_history_repository.dart';
import '../services/workout_template_repository.dart';
import 'workout_history_detail_screen.dart';

class WorkoutHistoryScreen extends StatefulWidget {
  final WorkoutHistoryRepository historyRepository;
  final WorkoutTemplateRepository templateRepository;

  const WorkoutHistoryScreen({
    super.key,
    required this.historyRepository,
    required this.templateRepository,
  });

  @override
  State<WorkoutHistoryScreen> createState() => _WorkoutHistoryScreenState();
}

class _WorkoutHistoryScreenState extends State<WorkoutHistoryScreen> {

  // ================= DELETE SINGLE =================

  Future<bool> _confirmDelete(session) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        title: const Text("Delete Workout",
            style: TextStyle(color: Colors.white)),
        content: const Text(
          "Are you sure you want to permanently delete this workout?",
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            child: const Text("CANCEL", style: TextStyle(color: Colors.white70)),
            onPressed: () => Navigator.pop(context, false),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            child: const Text("DELETE"),
            onPressed: () => Navigator.pop(context, true),
          ),
        ],
      ),
    );

    return confirm ?? false;
  }

  // ================= DELETE ALL =================

  Future<void> _confirmDeleteAll() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        title: const Text("Delete ALL History",
            style: TextStyle(color: Colors.white)),
        content: const Text(
          "This will permanently remove all workouts.\nThis cannot be undone.",
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            child: const Text("CANCEL", style: TextStyle(color: Colors.white70)),
            onPressed: () => Navigator.pop(context, false),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            child: const Text("DELETE ALL"),
            onPressed: () => Navigator.pop(context, true),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await widget.historyRepository.clearHistory();
      if (mounted) setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final sessions = widget.historyRepository.sessions;

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text(
          'Workout History',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          PopupMenuButton(
            icon: const Icon(Icons.more_vert),
            color: const Color(0xFF1E1E1E),
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'delete_all',
                child: Row(
                  children: [
                    Icon(Icons.delete_forever, color: Colors.redAccent),
                    SizedBox(width: 10),
                    Text("Delete All History",
                        style: TextStyle(color: Colors.white)),
                  ],
                ),
              ),
            ],
            onSelected: (value) {
              if (value == 'delete_all') {
                _confirmDeleteAll();
              }
            },
          )
        ],
      ),
      body: sessions.isEmpty
          ? const Center(
              child: Text(
                'No completed workouts yet',
                style: TextStyle(color: Colors.white70),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: sessions.length,
              itemBuilder: (context, index) {
                final session = sessions[index];

                return Dismissible(
                  key: ValueKey(session.hashCode),
                  direction: DismissDirection.endToStart,

                  confirmDismiss: (_) async {
                    final approved = await _confirmDelete(session);
                    if (approved) {
                      await widget.historyRepository.deleteSession(session);
                      setState(() {});
                    }
                    return approved;
                  },

                  background: Container(
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.redAccent,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 20),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Icon(Icons.delete, color: Colors.white),
                        SizedBox(width: 8),
                        Text(
                          "Delete",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        )
                      ],
                    ),
                  ),

                  child: Card(
                    color: const Color(0xFF1E1E1E),
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListTile(
                      title: Text(
                        session.templateName,
                        style: const TextStyle(color: Colors.white),
                      ),
                      subtitle: Text(
                        session.finishedAt == null
                            ? 'In progress'
                            : session.finishedAt!
                                .toLocal()
                                .toString()
                                .split('.')[0],
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
                            builder: (_) => WorkoutHistoryDetailScreen(
                              session: session,
                              templateRepository: widget.templateRepository,
                              historyRepository: widget.historyRepository, // ⭐ FIX
                            ),
                          ),
                        ).then((_) => setState(() {}));
                      },
                    ),
                  ),
                );
              },
            ),
    );
  }
}