import 'dart:math';
import 'package:xml/xml.dart';
import 'package:uuid/uuid.dart';
import '../models/activity.dart';
import '../models/trackpoint.dart';
import '../models/split.dart';
import '../models/activity_route.dart';

/// Classe conteneur pour renvoyer les deux objets après parsing
class ParsedActivityData {
  final Activity activity;
  final ActivityRoute route;

  ParsedActivityData({required this.activity, required this.route});
}

class GpxService {
  final Uuid _uuid = const Uuid();

  /// Fonction principale : XML String -> Objets Métier
  ParsedActivityData parseGpx(String xmlContent) {
    final document = XmlDocument.parse(xmlContent);

    // On récupère tous les points <trkpt>
    // Note: On ignore les segments (<trkseg>) pour simplifier, on aplatit tout.
    final trkpts = document.findAllElements('trkpt');

    List<TrackPoint> trackPoints = [];
    List<Split> splits = [];

    double totalDistance = 0.0;
    double elevationGain = 0.0;

    DateTime? startTime;
    DateTime? endTime;

    // Variables temporaires pour la boucle
    TrackPoint? prevPoint;
    DateTime? lastSplitTime;
    double lastSplitDistance = 0.0; // Distance au dernier split
    int currentSplitIndex = 1;

    for (var node in trkpts) {
      // 1. Extraction des attributs bruts
      final lat = double.parse(node.getAttribute('lat')!);
      final lon = double.parse(node.getAttribute('lon')!);

      // Extraction des enfants (elevation, time)
      final eleVal = node.findElements('ele').firstOrNull?.innerText;
      final timeVal = node.findElements('time').firstOrNull?.innerText;

      final alt = eleVal != null ? double.parse(eleVal) : 0.0;
      final time = timeVal != null ? DateTime.parse(timeVal) : DateTime.now();

      // Initialisation du startTime au premier point
      startTime ??= time;
      lastSplitTime ??= time;

      // 2. Calculs différentiels (Delta)
      double distDelta = 0.0;
      double speed = 0.0;

      if (prevPoint != null) {
        // Calcul de la distance parcourue depuis le dernier point
        distDelta = _calculateHaversineDistance(
          prevPoint.latitude!,
          prevPoint.longitude!,
          lat,
          lon,
        );

        totalDistance += distDelta;

        // Calcul du D+ (Dénivelé positif uniquement)
        if (alt > prevPoint.altitude!) {
          elevationGain += (alt - prevPoint.altitude!);
        }

        // Calcul vitesse instantanée (m/s) = distance / temps
        final timeDeltaSeconds = time.difference(prevPoint.timestamp!).inSeconds;
        if (timeDeltaSeconds > 0) {
          speed = distDelta / timeDeltaSeconds;
        }
      }

      // 3. Création du TrackPoint enrichi
      final newPoint = TrackPoint(
        timestamp: time,
        latitude: lat,
        longitude: lon,
        altitude: alt,
        speed: speed,
        accuracy: 10.0, // Valeur simulée car le GPX est "parfait"
      );

      trackPoints.add(newPoint);

      // 4. Gestion des Splits (Tous les 1000m)
      // On vérifie si on vient de franchir un kilomètre entier
      if ((totalDistance / 1000).floor() >
          ((totalDistance - distDelta) / 1000).floor()) {
        final splitDistance = totalDistance - lastSplitDistance;
        final splitDuration = time.difference(lastSplitTime);

        splits.add(
          Split(
            index: currentSplitIndex,
            distanceMeters: splitDistance,
            totalDistance:
                totalDistance,
            duration: splitDuration,
            pace: splitDuration, // Simplification pour le MVP
            currentKm: currentSplitIndex,
            altitude: alt, // Altitude à la fin du split
            timestamp: time,
            avgAltitude: 0.0, // À calculer si besoin
            completedAt: DateTime.timestamp()
          ),
        );

        // Reset pour le prochain split
        lastSplitDistance = totalDistance;
        lastSplitTime = time;
        currentSplitIndex++;
      }

      prevPoint = newPoint;
      endTime = time;
    }

    // 5. Construction de l'objet Activity final
    final activityId = _uuid.v4();

    final activity = Activity(
      uuid: activityId,
      type: ActivityType.running, // Hardcodé pour le test
      startTime: startTime ?? DateTime.now(),
      endTime: endTime ?? DateTime.now(),
      distanceMeters: totalDistance,
      elapsedTimeMicros: endTime!.difference(startTime!).inMicroseconds,
      movingTimeMicros: endTime.difference(startTime).inMicroseconds,
      elevationGain: elevationGain,
      splits: splits,
    );

    // 6. Construction de l'objet Route (Lourd)
    final route = ActivityRoute(activityUuid: activityId, points: trackPoints);

    return ParsedActivityData(activity: activity, route: route);
  }

  /// Formule de Haversine : Distance entre deux points GPS sur une sphère
  /// Retourne la distance en mètres.
  double _calculateHaversineDistance(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    const r = 6371000.0; // Rayon de la Terre en mètres

    // Conversion en radians
    final phi1 = lat1 * pi / 180;
    final phi2 = lat2 * pi / 180;
    final deltaPhi = (lat2 - lat1) * pi / 180;
    final deltaLambda = (lon2 - lon1) * pi / 180;

    final a =
        sin(deltaPhi / 2) * sin(deltaPhi / 2) +
        cos(phi1) * cos(phi2) * sin(deltaLambda / 2) * sin(deltaLambda / 2);

    final c = 2 * atan2(sqrt(a), sqrt(1 - a));

    return r * c;
  }
}
