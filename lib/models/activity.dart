import 'package:isar/isar.dart';
import 'split.dart';

part 'activity.g.dart';

@collection
class Activity {
  Id isarId = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  String uuid;

  @Enumerated(EnumType.name)
  ActivityType type;

  DateTime startTime;
  DateTime endTime;
  double distanceMeters;
  double elevationGain;

  int elapsedTimeMicros;
  int movingTimeMicros;

  List<Split>? splits;

  Activity({
    required this.uuid,
    required this.type,
    required this.startTime,
    required this.endTime,
    required this.distanceMeters,
    required this.elapsedTimeMicros,
    required this.movingTimeMicros,
    this.elevationGain = 0.0,
    this.splits,
  });

  @ignore
  Duration get elapsedTime => Duration(microseconds: elapsedTimeMicros);

  @ignore
  Duration get movingTime => Duration(microseconds: movingTimeMicros);

  @ignore
  double get avgSpeedKmh {
    if (movingTime.inSeconds == 0) return 0.0;
    return (distanceMeters / 1000) / (movingTime.inSeconds / 3600);
  }

  @ignore
  double get avgPaceMinPerKm {
    if (distanceMeters == 0) return 0.0;
    double totalMinutes = movingTime.inSeconds / 60;
    double pace = totalMinutes / (distanceMeters / 1000);
    return pace;
  }
}

enum ActivityType { running, cycling, swimming }
