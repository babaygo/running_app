import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
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
    return FutureBuilder<List<Activity>>(
      future: _activitiesFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            body: const Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError) {
          return Scaffold(
            appBar: AppBar(title: const Text("Erreur")),
            body: Center(child: Text("Erreur: ${snapshot.error}")),
          );
        }

        final activities = snapshot.data ?? [];

        return DefaultTabController(
          length: 2,
          child: Scaffold(
            appBar: AppBar(
              bottom: const TabBar(
                indicatorColor: Colors.deepOrange,
                labelColor: Colors.deepOrange,
                unselectedLabelColor: Colors.grey,
                tabs: [
                  Tab(icon: Icon(Icons.bar_chart), text: "Progression"),
                  Tab(icon: Icon(Icons.list), text: "Activités"),
                ],
              ),
            ),
            body: TabBarView(
              children: [
                _StatsTab(activities: activities),
                _ListTab(activities: activities),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _StatsTab extends StatelessWidget {
  final List<Activity> activities;

  const _StatsTab({required this.activities});

  @override
  Widget build(BuildContext context) {
    if (activities.isEmpty) {
      return const Center(child: Text("Pas assez de données pour les stats"));
    }

    final totalDist = activities.fold(
      0.0,
      (sum, act) => sum + act.distanceMeters,
    );
    final totalTime = activities.fold(
      0,
      (sum, act) => sum + act.movingTime.inSeconds,
    );
    final totalRuns = activities
        .where((a) => a.type == ActivityType.running)
        .length;
    final totalRides = activities
        .where((a) => a.type == ActivityType.cycling)
        .length;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildSummaryCard(
            "Total Distance",
            "${(totalDist / 1000).toStringAsFixed(1)} km",
            Icons.map,
          ),
          const SizedBox(height: 10),
          _buildSummaryCard(
            "Temps Total",
            _formatDurationGlobal(Duration(seconds: totalTime)),
            Icons.timer,
          ),

          const SizedBox(height: 20),
          const Divider(),
          const SizedBox(height: 20),

          Row(
            children: [
              Expanded(
                child: _buildStatBox(
                  "Courses",
                  "$totalRuns",
                  Icons.directions_run,
                  Colors.orange,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildStatBox(
                  "Sorties Vélo",
                  "$totalRides",
                  Icons.directions_bike,
                  Colors.blue,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(String title, String value, IconData icon) {
    return Card(
      elevation: 3,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.deepOrange.shade100,
          child: Icon(icon, color: Colors.deepOrange),
        ),
        title: Text(title, style: const TextStyle(color: Colors.grey)),
        subtitle: Text(
          value,
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildStatBox(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 30),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(label, style: TextStyle(color: color)),
        ],
      ),
    );
  }

  String _formatDurationGlobal(Duration d) {
    return "${d.inHours}h ${d.inMinutes % 60}m";
  }
}

class _ListTab extends StatelessWidget {
  final List<Activity> activities;

  const _ListTab({required this.activities});

  @override
  Widget build(BuildContext context) {
    if (activities.isEmpty) {
      return const Center(child: Text("Aucune activité enregistrée"));
    }

    return ListView.separated(
      itemCount: activities.length,
      separatorBuilder: (context, index) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final activity = activities[index];
        return ListTile(
          leading: CircleAvatar(
            backgroundColor: Colors.black,
            child: Icon(_getIconForType(activity.type), color: Colors.white),
          ),
          title: Text(DateFormat.yMMMd().format(activity.startTime)),
          subtitle: Text(
            "${(activity.distanceMeters / 1000).toStringAsFixed(2)} km - ${_formatDuration(activity.movingTime)}",
          ),
          trailing: const Icon(Icons.chevron_right),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ActivityDetailPage(activity: activity),
              ),
            );
          },
        );
      },
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
