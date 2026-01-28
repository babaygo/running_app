class Split {
  final int index; // Km 1, Km 2...
  final double
  distanceMeters; // La distance exacte du split (parfois un peu +/- 1000m)
  final Duration duration; // Temps mis pour parcourir ce split

  // Allure moyenne sur ce split (ex: 5:30 min/km)
  // C'est souvent redondant avec duration si le split fait exactement 1km,
  // mais utile si le dernier split fait 500m.
  final Duration pace;

  final double avgAltitude; // Altitude moyenne ou D+ sur ce split
  final DateTime completedAt; // Heure de fin du split

  Split({
    required this.index,
    required this.distanceMeters,
    required this.duration,
    required this.pace,
    required this.avgAltitude,
    required this.completedAt,
  });
}
