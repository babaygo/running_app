import 'package:isar/isar.dart';

part 'trackpoint.g.dart';

@embedded
class TrackPoint {
  double latitude;
  double longitude;
  double altitude;
  DateTime timestamp;

  double? speed;
  double? accuracy;

  TrackPoint({
    required this.latitude,
    required this.longitude,
    required this.altitude,
    required this.timestamp,
    this.speed = 0.0,
    this.accuracy = 0.0,
  });

  @override
  String toString() => 'Pt(t: $timestamp, lat: $latitude, lon: $longitude)';
}
