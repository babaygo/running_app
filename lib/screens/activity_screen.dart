import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:running_app/models/activity.dart';
import 'package:running_app/services/activity_service.dart';
import 'package:running_app/widgets/activity_card.dart';
import 'package:running_app/widgets/activity_map.dart';
import 'package:latlong2/latlong.dart';
import 'dart:async';

class ActivityScreen extends StatefulWidget {
  const ActivityScreen({super.key});

  @override
  State<ActivityScreen> createState() => _ActivityScreenState();
}

class _ActivityScreenState extends State<ActivityScreen> {
  late ActivityService _activityService;
  Position? _currentPosition;
  Position? _previousPosition;
  bool _isGPSConnected = false;
  bool _isLoadingGPS = false;
  bool _isActivityRunning = false;
  Activity? _currentActivity;
  Timer? _timer;
  int _elapsedSeconds = 0;
  double _totalDistance = 0.0;
  double _elevationGain = 0.0;
  int _calories = 0;
  int _lastKmSeconds = 0;
  late StreamSubscription<Position> _positionStream;
  String _selectedActivityType = 'running';
  List<KmSplit> _splits = [];
  double _minAltitude = double.infinity;
  double _maxAltitude = double.negativeInfinity;
  List<LatLng> _routePoints = [];

  @override
  void initState() {
    super.initState();
    _activityService = ActivityService();
    _initializeGPS();
  }

  Future<void> _initializeGPS() async {
    setState(() => _isLoadingGPS = true);
    
    try {
      // Vérifier les permissions
      LocationPermission permission = await Geolocator.checkPermission();
      
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied ||
            permission == LocationPermission.deniedForever) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Permission GPS refusée')),
            );
          }
          setState(() => _isLoadingGPS = false);
          return;
        }
      }

      // Vérifier si le service de localisation est activé
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Service de localisation désactivé')),
          );
        }
        setState(() => _isLoadingGPS = false);
        return;
      }

      // Obtenir la position actuelle
      Position position = await Geolocator.getCurrentPosition();

      if (mounted) {
        setState(() {
          _currentPosition = position;
          _isGPSConnected = true;
          _isLoadingGPS = false;
        });
      }

      // Écouter les mises à jour de position
      _positionStream = Geolocator.getPositionStream().listen((position) {
        if (mounted && _isActivityRunning) {
          setState(() {
            _currentPosition = position;
            _isGPSConnected = true;

            // Ajouter le point à la route
            _routePoints.add(
              LatLng(position.latitude, position.longitude),
            );

            // Calculer la distance depuis le dernier point
            if (_previousPosition != null) {
              final distance = Geolocator.distanceBetween(
                _previousPosition!.latitude,
                _previousPosition!.longitude,
                position.latitude,
                position.longitude,
              );
              _totalDistance += distance / 1000; // Convertir en km

              // Calculer le dénivelé si l'altitude est disponible
              if (_previousPosition!.altitude > 0 && position.altitude > 0) {
                final elevationDiff = position.altitude - _previousPosition!.altitude;
                if (elevationDiff > 0) {
                  _elevationGain += elevationDiff;
                }
                _minAltitude = _minAltitude > position.altitude ? position.altitude : _minAltitude;
                _maxAltitude = _maxAltitude < position.altitude ? position.altitude : _maxAltitude;
              }

              // Vérifier si on a complété un km
              _checkKmSplit();
            }

            _previousPosition = position;
          });
        }
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur GPS: $e')),
        );
        setState(() => _isLoadingGPS = false);
      }
    }
  }

  void _startActivity() {
    setState(() {
      _isActivityRunning = true;
      _elapsedSeconds = 0;
      _totalDistance = 0.0;
      _elevationGain = 0.0;
      _calories = 0;
      _splits = [];
      _lastKmSeconds = 0;
      _previousPosition = null;
      _minAltitude = double.infinity;
      _maxAltitude = double.negativeInfinity;
      _routePoints = [];
      _currentActivity = Activity(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        type: _selectedActivityType,
        startTime: DateTime.now(),
        route: [],
      );
    });

    // Démarrer le minuteur
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _elapsedSeconds++;
        // Simulation du calcul des calories (à adapter selon le type d'activité)
        _calories = (_elapsedSeconds * 12) ~/ 60;
      });
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Activité démarrée!'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _checkKmSplit() {
    final kmCompleted = _totalDistance.toInt();
    if (kmCompleted > _splits.length && kmCompleted > 0) {
      final splitTime = _elapsedSeconds - _lastKmSeconds;
      final elevationForThisKm = _elevationGain; // À affiner pour chaque km
      
      _splits.add(
        KmSplit(
          kmNumber: kmCompleted,
          durationSeconds: splitTime,
          elevationGain: elevationForThisKm,
        ),
      );
      
      _lastKmSeconds = _elapsedSeconds;
    }
  }

  void _stopActivity() {
    _timer?.cancel();

    if (_currentActivity != null) {
      final completedActivity = _currentActivity!.copyWith(
        endTime: DateTime.now(),
        duration: _elapsedSeconds,
        distance: _totalDistance,
        calories: _calories,
        elevationGain: _elevationGain,
        splits: _splits,
      );

      _activityService.addActivity(completedActivity);

      setState(() {
        _isActivityRunning = false;
        _currentActivity = null;
        _elapsedSeconds = 0;
        _totalDistance = 0.0;
        _elevationGain = 0.0;
        _calories = 0;
        _splits = [];
        _previousPosition = null;
        _routePoints = [];
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Activité enregistrée!'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  String _formatDuration(int seconds) {
    final hours = seconds ~/ 3600;
    final minutes = (seconds % 3600) ~/ 60;
    final secs = seconds % 60;

    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
    }
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  String _formatPace(double paceMinPerKm) {
    final minutes = paceMinPerKm.toInt();
    final seconds = ((paceMinPerKm - minutes) * 60).toInt();
    return '$minutes\'${seconds.toString().padLeft(2, '0')}"';
  }

  @override
  void dispose() {
    _timer?.cancel();
    _positionStream.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Enregistrer une Activité'),
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Type d'activité
              if (!_isActivityRunning)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Type d\'activité',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 12),
                    SegmentedButton<String>(
                      segments: const [
                        ButtonSegment(
                          value: 'running',
                          label: Text('🏃 Course'),
                        ),
                        ButtonSegment(
                          value: 'cycling',
                          label: Text('🚴 Cyclisme'),
                        )
                      ],
                      selected: {_selectedActivityType},
                      onSelectionChanged: (newSelection) {
                        setState(() {
                          _selectedActivityType = newSelection.first;
                        });
                      },
                    ),
                    const SizedBox(height: 24),
                  ],
                ),

              // Vraie carte avec flutter_map
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: SizedBox(
                  height: 350,
                  child: ActivityMap(
                    currentPosition: _currentPosition,
                    routePoints: _routePoints,
                    isRecording: _isActivityRunning,
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Indicateur GPS
              GPSIndicator(
                isConnected: _isGPSConnected,
                isLoading: _isLoadingGPS,
                accuracy: _currentPosition?.accuracy.toStringAsFixed(1),
              ),
              const SizedBox(height: 24),

              // Statistiques en temps réel
              if (_isActivityRunning)
                Column(
                  children: [
                    // Ligne 1: Durée et Distance
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _StatBox(
                          label: 'Durée',
                          value: _formatDuration(_elapsedSeconds),
                        ),
                        _StatBox(
                          label: 'Distance',
                          value: '${_totalDistance.toStringAsFixed(2)} km',
                        ),
                        _StatBox(
                          label: 'Allure',
                          value: _totalDistance > 0 && _elapsedSeconds > 0 
                            ? _formatPace((_elapsedSeconds / 60) / _totalDistance)
                            : '0\'00"',
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Ligne 2: Dénivelé et Calories
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _StatBox(
                          label: 'Dénivelé +',
                          value: '${_elevationGain.toStringAsFixed(0)} m',
                        ),
                        _StatBox(
                          label: 'Calories',
                          value: '$_calories kcal',
                        ),
                        _StatBox(
                          label: 'KMs',
                          value: '${_totalDistance.toInt()}/${_splits.length}',
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    // Afficher les splits complétés
                    if (_splits.isNotEmpty)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Temps par kilomètre',
                            style: Theme.of(context).textTheme.titleSmall,
                          ),
                          const SizedBox(height: 12),
                          SizedBox(
                            height: 100,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: _splits.length,
                              itemBuilder: (context, index) {
                                final split = _splits[index];
                                return Padding(
                                  padding: const EdgeInsets.only(right: 8.0),
                                  child: Container(
                                    width: 80,
                                    decoration: BoxDecoration(
                                      color: Colors.blue.shade50,
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        color: Colors.blue.shade200,
                                      ),
                                    ),
                                    padding: const EdgeInsets.all(8),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Text(
                                          'Km ${split.kmNumber}',
                                          style: const TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          split.paceFormatted,
                                          style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          '/km',
                                          style: const TextStyle(
                                            fontSize: 9,
                                            color: Colors.grey,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                          const SizedBox(height: 20),
                        ],
                      ),
                  ],
                ),

              // Boutons d'action
              SizedBox(
                width: double.infinity,
                child: _isActivityRunning
                    ? ElevatedButton.icon(
                        onPressed: _isGPSConnected ? _stopActivity : null,
                        icon: const Icon(Icons.stop),
                        label: const Text('Arrêter l\'activité'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                      )
                    : ElevatedButton.icon(
                        onPressed: _isGPSConnected && !_isLoadingGPS ? _startActivity : null,
                        icon: const Icon(Icons.play_arrow),
                        label: const Text('Démarrer l\'activité'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatBox extends StatelessWidget {
  final String label;
  final String value;

  const _StatBox({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
