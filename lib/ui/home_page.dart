import 'package:flutter/material.dart';
import '../repositories/data_repository.dart';
import '../models/activity.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late Future<List<Activity>> _activitiesFuture;

  @override
  void initState() {
    super.initState();
    _refreshData();
  }

  void _refreshData() {
    setState(() {
      _activitiesFuture = DataRepository().getAllActivities();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<List<Activity>>(
        future: _activitiesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final allActivities = snapshot.data ?? [];
          final now = DateTime.now();
          final startOfWeek = DateTime(
            now.year,
            now.month,
            now.day - (now.weekday - 1),
          );

          final weeklyActivities = allActivities.where((activity) {
            return activity.startTime.isAfter(startOfWeek);
          }).toList();

          final count = weeklyActivities.length;
          final totalTime = weeklyActivities.fold(
            0.0,
            (sum, act) => sum + act.movingTimeMicros,
          );
          final totalDistance = weeklyActivities.fold(
            0.0,
            (sum, act) => sum + act.distanceMeters,
          );

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Résumé hebdomadaire",
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),

                Card(
                  color: Colors.white,
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          children: [
                            const Text("Activités"),
                            Text(
                              "$count",
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                          ],
                        ),

                        Column(
                          children: [
                            const Text("Temps"),
                            Text(
                              // Afficher le temps sous ce format : 37 min 4s
                              "${(totalTime / 60000000).toStringAsFixed(0)}min${((totalTime % 60000000) / 1000000).toStringAsFixed(0)}s",
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                          ],
                        ),

                        Column(
                          children: [
                            const Text("Distance"),
                            Text(
                              "${(totalDistance / 1000).toStringAsFixed(1)} km",
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 30),

                if (count == 0)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.only(top: 20.0),
                      child: Text(
                        "Aucune activité cette semaine.",
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey, fontSize: 16),
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}
