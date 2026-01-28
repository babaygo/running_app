class Split {
  final int index;
  final double distanceMeters;
  final double totalDistance;

  final Duration duration;
  final Duration pace;

  final int currentKm;
  final double altitude;

  final DateTime timestamp;

  Split({
    required this.index,
    required this.distanceMeters,
    required this.totalDistance,
    required this.duration,
    required this.pace,
    required this.currentKm,
    required this.altitude,
    required this.timestamp,
  });
}
