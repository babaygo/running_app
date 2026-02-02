import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/activity.dart';
import '../repositories/data_repository.dart';
import 'activity_detail_page.dart';
import '../widgets/activities_chart.dart';

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
                StatsTab(activities: activities),
                _ListTab(activities: activities),
              ],
            ),
          ),
        );
      },
    );
  }
}

class StatsTab extends StatefulWidget {
  final List<Activity> activities;

  const StatsTab({super.key, required this.activities});

  @override
  State<StatsTab> createState() => _StatsTabState();
}

class _StatsTabState extends State<StatsTab> {
  @override
  Widget build(BuildContext context) {
    if (widget.activities.isEmpty) {
      return const Center(child: Text("Pas assez de données pour les stats"));
    }

    return SingleChildScrollView(
      child: Column(
        children: [
          const SizedBox(height: 20),

          ActivitiesChart(activities: widget.activities),

          const SizedBox(height: 20),
        ],
      ),
    );
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
