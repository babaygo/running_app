import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:running_app/utils/ui_utils.dart';
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
    return Scaffold(
      body: Stack(
        children: [
          FlutterMap(
            // On lie le contrôleur à la carte
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _center, // Commence à Paris, changera après le GPS
              initialZoom: 13.0,
              interactionOptions: const InteractionOptions(
                flags: InteractiveFlag.all & ~InteractiveFlag.rotate,
              ),
            ),
            children: [
              // COUCHE 1 : Tuiles LIGHT (Positron)
              TileLayer(
                // Positron : Très clair, gris léger, idéal pour superposer des traces colorées
                urlTemplate:
                    'https://{s}.basemaps.cartocdn.com/rastertiles/voyager/{z}/{x}/{y}.png',
                subdomains: const ['a', 'b', 'c'],
                userAgentPackageName: 'com.example.running_app',
              ),

              // COUCHE 2 : Le Point Bleu (Si on a la position)
              if (_userPosition != null)
                MarkerLayer(
                  markers: [
                    Marker(
                      point: _userPosition!,
                      width: 120,
                      height: 120,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          if (_heading != null)
                            Transform.rotate(
                              angle: (_heading! * (math.pi / 180)),
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
                              border: Border.all(color: Colors.white, width: 3),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.2),
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
          ),

          // COUCHE 3 : Interface (Reste inchangée)
          Positioned(
            bottom: 30,
            left: 20,
            right: 20,
            child: Column(
              children: [
                // Bouton de recentrage (Petit bonus UX)
                if (_hasPermission)
                  Align(
                    alignment: Alignment.centerRight,
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 20.0),
                      child: FloatingActionButton.small(
                        backgroundColor: Colors.white,
                        child: const Icon(
                          Icons.my_location,
                          color: Colors.black,
                        ),
                        onPressed: () {
                          if (_userPosition != null) {
                            _mapController.move(_userPosition!, 15.0);
                          }
                        },
                      ),
                    ),
                  ),

                Container(
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
                                (v) =>
                                    DropdownMenuItem(value: v, child: Text(v)),
                              )
                              .toList(),
                          onChanged: (v) => setState(() => _selectedSport = v!),
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          /* TODO Start */
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
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
