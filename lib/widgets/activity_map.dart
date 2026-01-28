import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';

class ActivityMap extends StatefulWidget {
  final Position? currentPosition;
  final List<LatLng> routePoints;
  final bool isRecording;

  const ActivityMap({
    super.key,
    this.currentPosition,
    this.routePoints = const [],
    this.isRecording = false,
  });

  @override
  State<ActivityMap> createState() => _ActivityMapState();
}

class _ActivityMapState extends State<ActivityMap> {
  late MapController _mapController;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
  }

  @override
  void didUpdateWidget(ActivityMap oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Centrer la map sur la position actuelle si elle change
    if (widget.currentPosition != null) {
      _mapController.move(
        LatLng(widget.currentPosition!.latitude,
            widget.currentPosition!.longitude),
        16.0,
      );
    }
  }

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final initialPosition = widget.currentPosition;
    final initialLatLng = initialPosition != null
        ? LatLng(initialPosition.latitude, initialPosition.longitude)
        : const LatLng(48.8566, 2.3522); // Paris par défaut

    return FlutterMap(
      mapController: _mapController,
      options: MapOptions(
        initialCenter: initialLatLng,
        initialZoom: 16.0,
        minZoom: 3.0,
        maxZoom: 18.0,
      ),
      children: [
        // Couche OpenStreetMap
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.running_app',
          retinaMode: true,
          maxNativeZoom: 19,
        ),
        // Couche de la route parcourue
        if (widget.routePoints.isNotEmpty)
          PolylineLayer(
            polylines: [
              Polyline(
                points: widget.routePoints,
                color: Colors.blue,
                strokeWidth: 3.0,
              ),
            ],
          ),
        // Marqueur de position actuelle
        if (widget.currentPosition != null)
          MarkerLayer(
            markers: [
              Marker(
                point: LatLng(widget.currentPosition!.latitude,
                    widget.currentPosition!.longitude),
                width: 80,
                height: 80,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        color: Colors.blue,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.blue.withValues(alpha: 0.5),
                            blurRadius: 8,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                    ),
                    if (widget.isRecording)
                      Padding(
                        padding: const EdgeInsets.only(top: 4.0),
                        child: Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        // Cercle de précision
        if (widget.currentPosition != null)
          CircleLayer(
            circles: [
              CircleMarker(
                point: LatLng(widget.currentPosition!.latitude,
                    widget.currentPosition!.longitude),
                radius: widget.currentPosition!.accuracy / 2,
                useRadiusInMeter: true,
                color: Colors.blue.withValues(alpha: 0.1),
                borderColor: Colors.blue.withValues(alpha: 0.3),
                borderStrokeWidth: 1,
              ),
            ],
          ),
        // Contrôles
        Positioned(
          right: 16,
          bottom: 16,
          child: Column(
            children: [
              FloatingActionButton(
                mini: true,
                heroTag: 'map_zoom_in',
                onPressed: () {
                  _mapController.move(
                    _mapController.camera.center,
                    _mapController.camera.zoom + 1,
                  );
                },
                child: const Icon(Icons.add),
              ),
              const SizedBox(height: 8),
              FloatingActionButton(
                mini: true,
                heroTag: 'map_zoom_out',
                onPressed: () {
                  _mapController.move(
                    _mapController.camera.center,
                    _mapController.camera.zoom - 1,
                  );
                },
                child: const Icon(Icons.remove),
              ),
              const SizedBox(height: 8),
              FloatingActionButton(
                mini: true,
                heroTag: 'map_center',
                onPressed: () {
                  if (widget.currentPosition != null) {
                    _mapController.move(
                      LatLng(widget.currentPosition!.latitude,
                          widget.currentPosition!.longitude),
                      16.0,
                    );
                  }
                },
                child: const Icon(Icons.my_location),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
