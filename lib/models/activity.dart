import 'package:running_app/models/split.dart';

enum ActivityType { running, cycling, swimming }

class Activity {
  final String id; // UUID
  final ActivityType type;

  final DateTime startTime;
  final DateTime endTime;

  // --- Métriques ---
  final double distanceMeters;

  // Temps écoulé total (Chrono start -> Chrono stop)
  final Duration elapsedTime;

  // Temps en mouvement (Elapsed - temps passé au feu rouge/pauses)
  // C'est celui-ci qu'on utilise pour calculer l'allure moyenne affichée.
  final Duration movingTime;

  // Dénivelé positif cumulé (important pour le trail/vélo)
  final double elevationGain;

  // --- Relations ---

  // Les splits sont légers, on les garde ici pour l'affichage rapide des graphes
  final List<Split> splits;

  // CONCEPTEUR NOTE :
  // La liste des TrackPoints n'est pas ici.
  // Dans ta BDD NoSQL, tu auras une méthode séparée :
  // Future<List<TrackPoint>> getRoute() async { ... }

  Activity({
    required this.id,
    required this.type,
    required this.startTime,
    required this.endTime,
    required this.distanceMeters,
    required this.elapsedTime,
    required this.movingTime,
    this.elevationGain = 0.0,
    required this.splits,
  });

  // Calculs dérivés (Getters intelligents)
  double get avgSpeedKmh {
    if (movingTime.inSeconds == 0) return 0.0;
    return (distanceMeters / 1000) / (movingTime.inSeconds / 3600);
  }
}
