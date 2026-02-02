import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../models/activity.dart';
import '../models/trackpoint.dart';
import '../repositories/data_repository.dart';

class ActivityDetailPage extends StatefulWidget {
  final Activity activity;

  const ActivityDetailPage({super.key, required this.activity});

  @override
  State<ActivityDetailPage> createState() => _ActivityDetailPageState();
}

class _ActivityDetailPageState extends State<ActivityDetailPage> {
  late Future<List<TrackPoint>?> _routeFuture;

  @override
  void initState() {
    super.initState();
    _routeFuture = DataRepository().getRouteForActivity(widget.activity.uuid);
  }

  LatLngBounds _calculateBounds(List<TrackPoint> points) {
    if (points.isEmpty) {
      return LatLngBounds(const LatLng(0, 0), const LatLng(0, 0));
    }

    double minLat = points.first.latitude!;
    double maxLat = points.first.latitude!;
    double minLon = points.first.longitude!;
    double maxLon = points.first.longitude!;

    for (var p in points) {
      if (p.latitude == null || p.longitude == null) continue;
      if (p.latitude! < minLat) minLat = p.latitude!;
      if (p.latitude! > maxLat) maxLat = p.latitude!;
      if (p.longitude! < minLon) minLon = p.longitude!;
      if (p.longitude! > maxLon) maxLon = p.longitude!;
    }

    return LatLngBounds(LatLng(minLat, minLon), LatLng(maxLat, maxLon));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Sortie du ${widget.activity.startTime.day}/${widget.activity.startTime.month}",
        ),
      ),
      body: Column(
        children: [
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.4,
            child: FutureBuilder<List<TrackPoint>?>(
              future: _routeFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final points = snapshot.data;

                if (points == null || points.isEmpty) {
                  return const Center(
                    child: Text("Pas de tracé GPS disponible"),
                  );
                }

                final latLngPoints = points
                    .map((p) => LatLng(p.latitude!, p.longitude!))
                    .toList();

                final bounds = _calculateBounds(points);

                return FlutterMap(
                  options: MapOptions(
                    initialCameraFit: CameraFit.bounds(
                      bounds: bounds,
                      padding: const EdgeInsets.all(40),
                    ),
                    interactionOptions: const InteractionOptions(
                      flags: InteractiveFlag.none,
                    ),
                  ),
                  children: [
                    TileLayer(
                      urlTemplate:
                          'https://{s}.basemaps.cartocdn.com/rastertiles/voyager/{z}/{x}/{y}.png',
                      subdomains: const ['a', 'b', 'c'],
                    ),
                    PolylineLayer(
                      polylines: [
                        Polyline(
                          points: latLngPoints,
                          strokeWidth: 4.0,
                          color: Colors.deepOrange,
                        ),
                      ],
                    ),
                    MarkerLayer(
                      markers: [
                        Marker(
                          point: latLngPoints.first,
                          child: const Icon(
                            Icons.circle,
                            color: Colors.green,
                            size: 15,
                          ),
                        ),
                        Marker(
                          point: latLngPoints.last,
                          child: const Icon(
                            Icons.circle,
                            color: Colors.white,
                            size: 15,
                          ),
                        ),
                      ],
                    ),
                  ],
                );
              },
            ),
          ),

          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: GridView.count(
                crossAxisCount: 2,
                childAspectRatio: 2,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                children: [
                  _buildStatCard(
                    "Distance",
                    "${(widget.activity.distanceMeters / 1000).toStringAsFixed(2)} km",
                    Icons.straighten,
                  ),
                  _buildStatCard(
                    "Durée",
                    _formatDuration(widget.activity.movingTime),
                    Icons.timer,
                  ),
                  _buildStatCard(
                    "Allure",
                    "${widget.activity.avgPaceMinPerKm.toStringAsFixed(1)} min/km",
                    Icons.speed,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.deepOrange),
            const SizedBox(height: 5),
            Text(
              value,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(
              title,
              style: const TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDuration(Duration d) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(d.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(d.inSeconds.remainder(60));
    return "${twoDigits(d.inHours)}:$twoDigitMinutes:$twoDigitSeconds";
  }
}
