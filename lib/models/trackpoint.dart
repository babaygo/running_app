class TrackPoint {
  final DateTime timestamp;
  final double latitude;
  final double longitude;
  final double altitude; // En mètres

  // --- Nouveaux champs critiques pour l'algo ---

  // Vitesse instantanée fournie par le GPS (souvent par effet Doppler).
  // Beaucoup plus précise que le calcul (Dist P2 - Dist P1) / Temps.
  final double speed; // En m/s

  // Précision horizontale du signal.
  // Indispensable : Si accuracy > 20m, on ignore le point dans les calculs.
  final double accuracy; // En mètres

  TrackPoint({
    required this.timestamp,
    required this.latitude,
    required this.longitude,
    required this.altitude,
    this.speed = 0.0,
    this.accuracy = 0.0,
  });

  @override
  String toString() => 'Pt(t: $timestamp, acc: $accuracy, lat: $latitude)';
}
