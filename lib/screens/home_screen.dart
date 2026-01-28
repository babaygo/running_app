import 'package:flutter/material.dart';
import 'package:running_app/services/activity_service.dart';
import 'package:running_app/widgets/activity_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late ActivityService _activityService;

  @override
  void initState() {
    super.initState();
    _activityService = ActivityService();
  }

  @override
  Widget build(BuildContext context) {
    final weeklyStats = _activityService.getWeeklyStats();
    final recentActivities = _activityService.getRecentActivities();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mes Entraînements'),
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Stats de la semaine
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Statistiques de cette semaine',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 16),
                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    children: [
                      StatCard(
                        label: 'Activités',
                        value: weeklyStats.totalActivities.toString(),
                        icon: Icons.directions_run,
                        color: Colors.blue,
                      ),
                      StatCard(
                        label: 'Distance',
                        value: weeklyStats.totalDistance.toStringAsFixed(1),
                        unit: 'km',
                        icon: Icons.map,
                        color: Colors.green,
                      ),
                      StatCard(
                        label: 'Durée',
                        value: weeklyStats.totalDurationFormatted,
                        icon: Icons.timer,
                        color: Colors.orange,
                      ),
                      StatCard(
                        label: 'Calories',
                        value: weeklyStats.totalCalories.toString(),
                        unit: 'kcal',
                        icon: Icons.local_fire_department,
                        color: Colors.red,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Derniers entraînements
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                'Derniers entraînements',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ),
            const SizedBox(height: 8),
            if (recentActivities.isEmpty)
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Center(
                  child: Column(
                    children: [
                      Icon(
                        Icons.directions_run_outlined,
                        size: 48,
                        color: Colors.grey.shade300,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Aucun entraînement enregistré',
                        style: TextStyle(color: Colors.grey.shade600),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: () {
                          // Navigation vers Activity Screen
                        },
                        icon: const Icon(Icons.add),
                        label: const Text('Démarrer une activité'),
                      ),
                    ],
                  ),
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: recentActivities.length,
                itemBuilder: (context, index) {
                  return ActivityCard(
                    activity: recentActivities[index],
                    onTap: () {
                      // Afficher les détails de l'activité
                    },
                  );
                },
              ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
