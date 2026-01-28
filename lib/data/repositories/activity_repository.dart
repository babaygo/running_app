import 'package:running_app/data/db/database_helper.dart';
import 'package:running_app/models/activity.dart';

Future<void> insertActivity(Activity activity) async {
  final db = await DatabaseHelper.instance.database;

  await db.transaction((txn) async {
    await txn.insert('activities', {
      'id': activity.id,
      'start_time': activity.startTime.toIso8601String(),
      'end_time': activity.endTime.toIso8601String(),
      'distance_meters': activity.distanceMeters,
      'duration_seconds': activity.duration.inSeconds,
    });

    for (final point in activity.track) {
      await txn.insert('track_points', {
        'activity_id': activity.id,
        'latitude': point.latitude,
        'longitude': point.longitude,
        'altitude': point.altitude,
        'timestamp': point.timestamp.toIso8601String(),
      });
    }

    for (final split in activity.splits) {
      await txn.insert('splits', {
        'activity_id': activity.id,
        'split_index': split.index,
        'distance_meters': split.distanceMeters,
        'total_distance': split.totalDistance,
        'duration_seconds': split.duration.inSeconds,
        'pace_seconds': split.pace.inSeconds,
        'current_km': split.currentKm,
        'altitude': split.altitude,
        'timestamp': split.timestamp.toIso8601String(),
      });
    }
  });
}

// Future<List<Activity>> getActivities() async {
//   final db = await DatabaseHelper.instance.database;

//   final activities = await db.query('activities', orderBy: 'start_time DESC');

//   return activities.map(_mapActivity).toList();
// }
