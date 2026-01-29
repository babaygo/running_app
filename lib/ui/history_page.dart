import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Pour formater la date
import '../models/activity.dart';
import '../repositories/data_repository.dart';
import 'activity_detail_page.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  late Future<List<Activity>> _activitiesFuture;

  @override
  void initState() {
    super.initState();
    _refreshList();
  }

  void _refreshList() {
    setState(() {
      _activitiesFuture = DataRepository().getAllActivities();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Historique")),
      // FutureBuilder gère l'attente de la BDD
      body: FutureBuilder<List<Activity>>(
        future: _activitiesFuture,
        builder: (context, snapshot) {
          // Cas 1 : Ça charge
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // Cas 2 : Erreur
          if (snapshot.hasError) {
            return Center(child: Text("Erreur: ${snapshot.error}"));
          }

          final activities = snapshot.data ?? [];

          // Cas 3 : Liste vide
          if (activities.isEmpty) {
            return const Center(child: Text("Aucune activité enregistrée"));
          }

          // Cas 4 : Affichage de la liste
          return ListView.separated(
            itemCount: activities.length,
            separatorBuilder: (context, index) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final activity = activities[index];
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.black,
                  // On récupère le type (running, cycling...)
                  child: Icon(
                    _getIconForType(activity.type),
                    color: Colors.white,
                  ),
                ),
                title: Text(
                  DateFormat.yMMMd().format(activity.startTime),
                ), // Ex: Jan 28, 2026
                subtitle: Text(
                  "${(activity.distanceMeters / 1000).toStringAsFixed(2)} km - ${_formatDuration(activity.movingTime)}",
                ),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          ActivityDetailPage(activity: activity),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  IconData _getIconForType(ActivityType type) {
    switch (type) {
      case ActivityType.cycling:
        return Icons.directions_bike;
      case ActivityType.swimming:
        return Icons.pool;
      default:
        return Icons.directions_run;
    }
  }

  String _formatDuration(Duration d) {
    return "${d.inHours.toString().padLeft(2, '0')}:${(d.inMinutes % 60).toString().padLeft(2, '0')}";
  }
}
