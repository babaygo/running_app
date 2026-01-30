import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';

import '../models/activity.dart';
import '../models/activity_route.dart';
import '../models/trackpoint.dart';

class DataRepository {
  // Singleton standard
  static final DataRepository _instance = DataRepository._internal();
  factory DataRepository() => _instance;
  DataRepository._internal();

  late Isar _isar;
  bool _isReady = false;

  ActivityRoute? demoRoute;

  // 1. Initialisation : Ouvre le fichier sur le disque
  Future<void> init() async {
    if (_isReady) return;

    final dir = await getApplicationDocumentsDirectory();

    // On ouvre Isar avec tous les Schémas générés
    _isar = await Isar.open([
      ActivitySchema,
      ActivityRouteSchema,
    ], directory: dir.path);

    _isReady = true;
  }

  // 2. Écriture : Sauvegarde une activité ET sa route en même temps
  Future<void> saveActivity(Activity activity, List<TrackPoint> points) async {
    final route = ActivityRoute(activityUuid: activity.uuid, points: points);

    // .writeTxn assure que l'opération est Atomique (Tout ou Rien)
    await _isar.writeTxn(() async {
      await _isar.activitys.put(activity); // Sauvegarde les métadonnées
      await _isar.activityRoutes.put(
        route,
      ); // Sauvegarde les milliers de points
    });
  }

  // 3. Lecture : Récupérer l'historique (sans les points GPS lourds)
  Future<List<Activity>> getAllActivities() async {
    if (!_isReady) await init();

    return await _isar.activitys
        .where()
        .sortByStartTimeDesc() // Tri automatique du plus récent au plus ancien
        .findAll();
  }

  // 4. Lecture : Récupérer la trace GPS d'une activité spécifique
  Future<List<TrackPoint>?> getRouteForActivity(String uuid) async {
    final route = await _isar.activityRoutes
        .filter()
        .activityUuidEqualTo(uuid)
        .findFirst();

    return route?.points;
  }

  Future<void> clearAll() async {
    await _isar.writeTxn(() async {
      await _isar.clear();
    });
  }
}
