class Split {
  final int index;
  final double distanceMeters; // La distance exacte du split (parfois un peu +/- 1000m)
  final double totalDistance;
  final Duration duration; // Temps mis pour parcourir ce split

  // Allure moyenne sur ce split (ex: 5:30 min/km)
  // C'est souvent redondant avec duration si le split fait exactement 1km,
  // mais utile si le dernier split fait 500m.
  final Duration pace;
  final int currentKm;

  final double altitude;
  final double avgAltitude; // Altitude moyenne ou D+ sur ce split
  final DateTime timestamp;
  final DateTime completedAt; // Heure de fin du split

  Split({
    required this.index,
    required this.distanceMeters,
    required this.totalDistance,
    required this.duration,
    required this.pace,
    required this.avgAltitude,
    required this.completedAt,
    required this.currentKm,
    required this.altitude,
    required this.timestamp,
  });
}
