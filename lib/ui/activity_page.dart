import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:running_app/utils/ui_utils.dart';
import 'package:provider/provider.dart';
import '../services/recorder_service.dart';
import 'dart:math' as math;

class ActivityPage extends StatefulWidget {
  const ActivityPage({super.key});

  @override
  State<ActivityPage> createState() => _ActivityPageState();
}

class _ActivityPageState extends State<ActivityPage> {
  // 1. Contrôleur pour bouger la carte programmatiquement
  final MapController _mapController = MapController();

  String _selectedSport = "Running";

  // 2. État de la position
  LatLng _center = const LatLng(48.8566, 2.3522); // Paris par défaut
  LatLng? _userPosition; // Null tant qu'on n'a pas le GPS
  bool _hasPermission = false;
  double? _heading = 0.0;

  @override
  void initState() {
    super.initState();
    // Au démarrage de la page, on lance la recherche GPS
    _determinePosition();

    FlutterCompass.events?.listen((CompassEvent event) {
      // Le capteur renvoie null si l'appareil n'a pas de boussole
      setState(() {
        _heading = event.heading;
      });
    });
  }

  // Fonction utilitaire standard de la doc Geolocator
  Future<void> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // A. Le GPS est-il allumé ?
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return; // On reste sur Paris
    }

    // B. A-t-on la permission ?
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return; // Permission refusée, on reste sur Paris
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return; // Refus permanent
    }

    // C. Si on arrive ici, on a le droit !
    setState(() {
      _hasPermission = true;
    });

    // On récupère la position actuelle
    final position = await Geolocator.getCurrentPosition();

    // On met à jour l'UI
    setState(() {
      _userPosition = LatLng(position.latitude, position.longitude);
      _center = _userPosition!; // On centre sur l'utilisateur
    });

    // D. On déplace la caméra de la carte (Animation fluide)
    _mapController.move(_center, 15.0);
  }

  @override
  Widget build(BuildContext context) {
    // On récupère l'instance sans écouter pour les appels de méthodes (start/stop)
    final recorder = Provider.of<RecorderService>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Activité"),
        actions: [
          // BOUTON DE DEBUG (Simulation)
          IconButton(
            icon: const Icon(
              Icons.science,
              color: Colors.deepOrange,
            ), // Icone "Eprouvette"
            tooltip: "Simuler un parcours (Debug PC)",
            onPressed: () {
              recorder.startSimulation();
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          Consumer<RecorderService>(
            builder: (context, service, child) {
              // LOGIQUE DE DÉCISION DE LA POSITION
              LatLng? displayPosition;
              double displayHeading = 0.0;

              // Cas A : On enregistre/simule -> On prend la position du Service
              if (service.isRecording && service.currentPosition != null) {
                final p = service.currentPosition!;
                displayPosition = LatLng(p.latitude!, p.longitude!);
                // Optionnel : Si tu veux que la caméra suive le point automatiquement
                // _mapController.move(displayPosition, _mapController.camera.zoom);
              }
              // Cas B : On est au repos -> On prend la position réelle (GPS PC/Tel)
              else if (_userPosition != null) {
                displayPosition = _userPosition;
                displayHeading = _heading ?? 0.0; // La boussole réelle
              }

              return FlutterMap(
                mapController: _mapController,
                options: MapOptions(
                  initialCenter: _center,
                  initialZoom: 15.0,
                  interactionOptions: const InteractionOptions(
                    flags: InteractiveFlag.all & ~InteractiveFlag.rotate,
                  ),
                ),
                children: [
                  TileLayer(
                    urlTemplate:
                        'https://{s}.basemaps.cartocdn.com/rastertiles/voyager/{z}/{x}/{y}.png',
                    subdomains: const ['a', 'b', 'c'],
                    userAgentPackageName: 'com.example.running_app',
                  ),

                  if (service.currentPath.isNotEmpty)
                    PolylineLayer(
                      polylines: [
                        Polyline(
                          points: service.currentPath
                              .map((p) => LatLng(p.latitude!, p.longitude!))
                              .toList(),
                          strokeWidth: 4.0,
                          color: Colors.deepOrange,
                        ),
                      ],
                    ),

                  if (displayPosition != null)
                    MarkerLayer(
                      markers: [
                        Marker(
                          point: displayPosition,
                          width: 120,
                          height: 120,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              if (displayHeading != 0)
                                Transform.rotate(
                                  angle: (displayHeading * (math.pi / 180)),
                                  child: SizedBox(
                                    width: 100,
                                    height: 100,
                                    child: CustomPaint(
                                      painter: BeamPainter(color: Colors.blue),
                                    ),
                                  ),
                                ),

                              Container(
                                width: 20,
                                height: 20,
                                decoration: BoxDecoration(
                                  color: Colors.blue,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.white,
                                    width: 3,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black,
                                      blurRadius: 5,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                ],
              );
            },
          ),

          Positioned(
            bottom: 30,
            left: 20,
            right: 20,
            child: Consumer<RecorderService>(
              builder: (context, service, child) {
                if (!service.isRecording) {
                  return Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(color: Colors.black12, blurRadius: 10),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _selectedSport,
                            items: ["Running", "Cycling", "Swimming"]
                                .map(
                                  (v) => DropdownMenuItem(
                                    value: v,
                                    child: Text(v),
                                  ),
                                )
                                .toList(),
                            onChanged: (v) =>
                                setState(() => _selectedSport = v!),
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            recorder.startRecording(_selectedSport);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.deepOrange,
                            foregroundColor: Colors.white,
                            shape: const CircleBorder(),
                            padding: const EdgeInsets.all(15),
                          ),
                          child: const Text("GO"),
                        ),
                      ],
                    ),
                  );
                } else {
                  return Column(
                    children: [
                      Container(
                        margin: const EdgeInsets.only(bottom: 20),
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.black87,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildLiveStat(
                              "Durée",
                              _formatDuration(service.currentDuration),
                            ),
                            _buildLiveStat(
                              "Dist (km)",
                              (service.currentDistance / 1000).toStringAsFixed(
                                2,
                              ),
                            ),
                            _buildLiveStat(
                              "Vitesse",
                              "${(service.currentSpeed * 3.6).toStringAsFixed(1)} km/h",
                            ),
                          ],
                        ),
                      ),

                      GestureDetector(
                        onLongPress: () {
                          recorder.stopRecording();
                          // Optionnel : Naviguer vers le détail ou afficher un SnackBar
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Activité enregistrée !"),
                            ),
                          );
                        },
                        child: CircleAvatar(
                          radius: 40,
                          backgroundColor: Colors.red,
                          child: const Icon(
                            Icons.stop,
                            color: Colors.white,
                            size: 40,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        "Appui long pour stopper",
                        style: TextStyle(
                          color: Colors.white,
                          shadows: [Shadow(blurRadius: 2, color: Colors.black)],
                        ),
                      ),
                    ],
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}

Widget _buildLiveStat(String label, String value) {
  return Column(
    children: [
      Text(
        value,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 24,
          fontWeight: FontWeight.bold,
          fontFamily: 'Monospace',
        ),
      ),
      Text(label, style: const TextStyle(color: Colors.white70, fontSize: 12)),
    ],
  );
}

String _formatDuration(Duration d) {
  String twoDigits(int n) => n.toString().padLeft(2, "0");
  String twoDigitMinutes = twoDigits(d.inMinutes.remainder(60));
  String twoDigitSeconds = twoDigits(d.inSeconds.remainder(60));
  return "${twoDigits(d.inHours)}:$twoDigitMinutes:$twoDigitSeconds";
}
