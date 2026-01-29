import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart' hide ActivityType;
import 'package:uuid/uuid.dart';
import 'dart:math'; // Pour Haversine (si tu ne l'as pas mis dans une classe utilitaire)

import '../models/activity.dart';
import '../models/trackpoint.dart';
// Si tu gères les splits en live
import '../repositories/data_repository.dart';

class RecorderService extends ChangeNotifier {
  // --- ÉTAT DU SYSTÈME ---
  bool _isRecording = false;
  DateTime? _startTime;
  Duration _currentDuration = Duration.zero;
  double _currentDistance = 0.0;
  double _currentSpeed = 0.0; // m/s

  // Le chemin courant (pour l'affichage polyline sur la map)
  List<TrackPoint> _currentPath = [];

  // Getters pour l'UI
  bool get isRecording => _isRecording;
  Duration get currentDuration => _currentDuration;
  double get currentDistance => _currentDistance;
  double get currentSpeed => _currentSpeed;
  List<TrackPoint> get currentPath => _currentPath;
  TrackPoint? get currentPosition =>
      _currentPath.isNotEmpty ? _currentPath.last : null;

  // --- INTERNES ---
  StreamSubscription<Position>? _positionStream;
  Timer? _timer;
  final Uuid _uuid = const Uuid();

  // --- COMMANDES ---

  void startRecording(String activityType) {
    // activityType servira pour l'enum
    if (_isRecording) return;

    _resetState();
    _isRecording = true;
    _startTime = DateTime.now();

    // 1. Démarrage du Chronomètre (Ticker)
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _currentDuration = DateTime.now().difference(_startTime!);
      notifyListeners(); // Dit à l'UI de rafraîchir le texte "00:00:01"
    });

    // 2. Abonnement au Flux GPS (Haute précision)
    const locationSettings = LocationSettings(
      accuracy: LocationAccuracy.bestForNavigation,
      distanceFilter: 2, // Ne notifie que si on bouge de 2 mètres min
    );

    _positionStream =
        Geolocator.getPositionStream(locationSettings: locationSettings).listen(
          (Position position) {
            _onNewPosition(position);
          },
        );

    notifyListeners();
  }

  Future<void> stopRecording() async {
    if (!_isRecording) return;

    // ... arrêt des timers et subscriptions ...
    _positionStream?.cancel();
    _timer?.cancel();
    _isRecording = false;

    // 1. Création de l'objet Activity (Attention aux types int !)
    final newActivity = Activity(
      uuid: _uuid.v4(),
      type: ActivityType.running, // À rendre dynamique via ton Dropdown
      startTime: _startTime!,
      endTime: DateTime.now(),
      distanceMeters: _currentDistance,
      elapsedTimeMicros: _currentDuration.inMicroseconds, // .inMicroseconds
      movingTimeMicros: _currentDuration.inMicroseconds, // .inMicroseconds
      splits: [], // On gèrera les splits plus tard
    );

    // 2. Sauvegarde PERSISTANTE
    // On passe l'activité ET la liste des points courants
    await DataRepository().saveActivity(newActivity, _currentPath);

    // Nettoyage
    _resetState();
    notifyListeners();
  }

  // --- LOGIQUE MÉTIER (ALGO) ---

  void _onNewPosition(Position pos) {
    // Conversion Position (Geolocator) -> TrackPoint (Ton modèle)
    final newPoint = TrackPoint(
      timestamp: pos.timestamp,
      latitude: pos.latitude,
      longitude: pos.longitude,
      altitude: pos.altitude,
      speed: pos.speed, // Le GPS donne la vitesse Doppler (très précis)
      accuracy: pos.accuracy,
    );

    // Filtrage basique (Si précision pourrie > 20m, on jette)
    if (newPoint.accuracy! > 20.0) return;

    // Calcul de distance cumulée
    if (_currentPath.isNotEmpty) {
      final lastPoint = _currentPath.last;
      final dist = _calculateHaversine(
        lastPoint.latitude!,
        lastPoint.longitude!,
        newPoint.latitude!,
        newPoint.longitude!,
      );
      _currentDistance += dist;
    }

    _currentPath.add(newPoint);
    _currentSpeed = newPoint.speed!; // Mise à jour vitesse instantanée

    notifyListeners(); // Mise à jour de la Map et des stats
  }

  void _resetState() {
    _currentDuration = Duration.zero;
    _currentDistance = 0.0;
    _currentSpeed = 0.0;
    _currentPath = [];
    _startTime = null;
  }

  void startSimulation() {
    // 1. Récupération des données brutes
    final route = DataRepository().demoRoute;
    if (route == null || route.points!.isEmpty) {
      print("Erreur: Pas de route de démo chargée");
      return;
    }

    if (_isRecording) return;
    _resetState();
    _isRecording = true;
    _startTime = DateTime.now();

    // Timer UI (Le chrono qui défile)
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      _currentDuration = DateTime.now().difference(_startTime!);
      notifyListeners();
    });

    // 2. Le Moteur d'injection de données
    // On prend la liste des points du GPX
    final pointsIterator = route.points?.iterator;

    // On crée un Timer rapide pour simuler le déplacement
    // Duration(milliseconds: 200) = 5x plus vite que le temps réel (si 1pt/sec)
    // Duration(seconds: 1) = Temps réel
    Timer.periodic(const Duration(milliseconds: 400), (simTimer) {
      // Si l'utilisateur a appuyé sur STOP ou si on est à la fin du fichier
      if (!_isRecording || !pointsIterator!.moveNext()) {
        simTimer.cancel();
        // Si fin du fichier, on peut arrêter proprement ou laisser tourner le chrono
        if (!pointsIterator!.moveNext() && _isRecording) {
          // Optionnel : auto-stop à la fin
          // stopRecording();
        }
        return;
      }

      final trackPoint = pointsIterator.current;

      // 3. Mapping : On transforme ton TrackPoint en Position GPS "Android/iOS"
      // C'est ici qu'on trompe le système
      final mockPosition = Position(
        longitude: trackPoint.longitude ?? 0.0, // Sécurité null
        latitude: trackPoint.latitude ?? 0.0,
        timestamp: DateTime.now(),
        accuracy: 5.0,
        altitude: trackPoint.altitude ?? 0.0,
        heading: 0.0,
        speed: trackPoint.speed ?? 0.0,
        speedAccuracy: 0.0,
        altitudeAccuracy: 0.0,
        headingAccuracy: 0.0,
        isMocked: true,
        floor: null,
      );

      // 4. On injecte dans ta logique existante
      _onNewPosition(mockPosition);
    });

    notifyListeners();
  }

  // Copie ta fonction Haversine ici ou importe-la
  double _calculateHaversine(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    const r = 6371000.0;
    final p = 0.017453292519943295;
    final a =
        0.5 -
        cos((lat2 - lat1) * p) / 2 +
        cos(lat1 * p) * cos(lat2 * p) * (1 - cos((lon2 - lon1) * p)) / 2;
    return 2 * r * asin(sqrt(a));
  }
}
