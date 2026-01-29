import 'package:isar/isar.dart';

part 'split.g.dart';

@embedded
class Split {
  int? index;
  double? distanceMeters;
  double? totalDistance;

  DateTime? completedAt;
  DateTime? timestamp;

  int? currentKm;
  double? altitude;
  double? avgAltitude;

  int? durationMicros;
  int? paceMicros;

  Split({
    this.index,
    this.distanceMeters,
    this.totalDistance,
    this.avgAltitude,
    this.currentKm,
    this.altitude,
    this.timestamp,
    this.completedAt,
    Duration? duration,
    Duration? pace,
  }) {
    if (duration != null) durationMicros = duration.inMicroseconds;
    if (pace != null) paceMicros = pace.inMicroseconds;
  }

  @ignore
  Duration get duration => Duration(microseconds: durationMicros ?? 0);

  @ignore
  Duration get pace => Duration(microseconds: paceMicros ?? 0);
}
