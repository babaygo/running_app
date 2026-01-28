import 'package:running_app/models/split.dart';
import 'package:running_app/models/trackpoint.dart';

enum ActivityType { running }

class Activity {
  final String id;
  final ActivityType type;

  final DateTime startTime;
  final DateTime endTime;

  final double distanceMeters;
  final Duration duration;

  final List<TrackPoint> track;
  final List<Split> splits;

  Activity({
    required this.id,
    required this.type,
    required this.startTime,
    required this.endTime,
    required this.distanceMeters,
    required this.duration,
    required this.track,
    required this.splits,
  });
}

extension PaceFormat on Duration {
  String toPaceString() {
    final minutes = inMinutes;
    final seconds = inSeconds % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')} /km';
  }
}
