import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../repositories/data_repository.dart';
import 'activity_detail_page.dart'; // Ta page précédente !

class HistoryPage extends StatelessWidget {
  const HistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final activities = DataRepository().activities;

    return Scaffold(
      appBar: AppBar(title: const Text("Historique")),
      body: ListView.separated(
        itemCount: activities.length,
        separatorBuilder: (context, index) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final activity = activities[index];

          return ListTile(
            leading: const CircleAvatar(
              backgroundColor: Colors.black,
              child: Icon(Icons.directions_run, color: Colors.white),
            ),
            title: Text(DateFormat.yMMMd().format(activity.startTime)),
            subtitle: Text(
              "${(activity.distanceMeters / 1000).toStringAsFixed(2)} km - ${_formatDuration(activity.movingTime)}",
            ),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              // Navigation vers ta page de détail existante
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ActivityDetailPage(activity: activity),
                ),
              );
            },
          );
        },
      ),
    );
  }

  String _formatDuration(Duration d) {
    return "${d.inMinutes}:${(d.inSeconds % 60).toString().padLeft(2, '0')}";
  }
}
