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
    // On lance le chargement des données au démarrage de la page
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
      appBar: AppBar(title: const Text("Bonjour, Athlete")),
      body: FutureBuilder<List<Activity>>(
        future: _activitiesFuture,
        builder: (context, snapshot) {
          // 1. Cas de chargement
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // 2. Récupération des données brutes
          final allActivities = snapshot.data ?? [];

          // 3. LOGIQUE DE FILTRE : "Cette semaine"
          // On calcule la date du Lundi de la semaine en cours à 00:00:00
          final now = DateTime.now();
          // weekday: Lundi = 1, ... Dimanche = 7
          // Si on est Mercredi (3), on retire 2 jours pour revenir à Lundi
          final startOfWeek = DateTime(
            now.year,
            now.month,
            now.day - (now.weekday - 1),
          );

          // On ne garde que les activités après ce Lundi minuit
          final weeklyActivities = allActivities.where((activity) {
            return activity.startTime.isAfter(startOfWeek);
          }).toList();

          // 4. Calcul des Stats
          final count = weeklyActivities.length;
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
                  "Cette semaine",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),

                // CARTE DE RÉSUMÉ
                Card(
                  color: Colors.deepOrange.shade50,
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Colonne Nombre
                        Column(
                          children: [
                            Text(
                              "$count",
                              style: const TextStyle(
                                fontSize: 30,
                                fontWeight: FontWeight.bold,
                                color: Colors.deepOrange,
                              ),
                            ),
                            const Text("Sorties"),
                          ],
                        ),
                        // Séparateur vertical visuel
                        Container(
                          width: 1,
                          height: 40,
                          color: Colors.deepOrange.shade200,
                        ),

                        // Colonne Distance
                        Column(
                          children: [
                            Text(
                              (totalDistance / 1000).toStringAsFixed(1),
                              style: const TextStyle(
                                fontSize: 30,
                                fontWeight: FontWeight.bold,
                                color: Colors.deepOrange,
                              ),
                            ),
                            const Text("km totaux"),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 30),

                // (Optionnel) Ajout d'un message si vide
                if (count == 0)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.only(top: 20.0),
                      child: Text(
                        "Pas encore de sport cette semaine.\nAllez, on s'y met !",
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
