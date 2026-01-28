import 'package:flutter/material.dart';
import '../repositories/data_repository.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    // Accès aux données
    final activities = DataRepository().activities;
    // TODO: Ici tu ajouteras plus tard un filtre "activités de la semaine"

    return Scaffold(
      appBar: AppBar(title: const Text("Bonjour, Athlete")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Cette semaine",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            // Une carte de résumé (Placeholder)
            Card(
              color: Colors.deepOrange.shade50,
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      children: [
                        Text(
                          "${activities.length}",
                          style: const TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Text("Sorties"),
                      ],
                    ),
                    Column(
                      children: [
                        // On somme les distances (Exemple d'algo simple en UI)
                        Text(
                          (activities.fold(0.0, (sum, item) => sum + item.distanceMeters) / 1000).toStringAsFixed(1),
                          style: const TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Text("km totaux"),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
