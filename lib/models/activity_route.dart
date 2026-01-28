import 'package:running_app/models/trackpoint.dart';

class ActivityRoute {
  final String activityId; // Clé étrangère vers l'Activity
  final List<TrackPoint> points; // La série temporelle lourde

  ActivityRoute({required this.activityId, required this.points});
}
