import '../models/activity.dart';

class DataRepository {
  // Singleton : Une seule instance pour toute l'appli
  static final DataRepository _instance = DataRepository._internal();
  factory DataRepository() => _instance;
  DataRepository._internal();

  final List<Activity> _activities = [];

  // Getter : On retourne une liste non modifiable pour protéger les données
  List<Activity> get activities => List.unmodifiable(_activities);

  void addActivity(Activity activity) {
    _activities.add(activity);
    // On trie par date décroissante (la plus récente en haut)
    _activities.sort((a, b) => b.startTime.compareTo(a.startTime));
  }

  // Simulation : Pour l'instant, on charge ton GPX ici au démarrage
}
