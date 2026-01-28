import 'package:flutter/material.dart' hide Split;
import 'package:intl/intl.dart';
import '../models/activity.dart';
import '../models/split.dart';

class ActivityDetailPage extends StatelessWidget {
  final Activity activity;

  const ActivityDetailPage({super.key, required this.activity});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(DateFormat.yMMMd().add_Hm().format(activity.startTime)),
      ),
      body: Column(
        children: [
          _buildSummaryCard(),

          Expanded(
            child: ListView.builder(
              itemCount: activity.splits.length,
              itemBuilder: (context, index) {
                final split = activity.splits[index];
                return _buildSplitItem(split);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard() {
    // Card : Un panneau avec une légère ombre (Material Design)
    return Card(
      margin: const EdgeInsets.all(16),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildStatItem(
              "Distance",
              "${(activity.distanceMeters / 1000).toStringAsFixed(2)} km",
            ),
            _buildStatItem("Durée", _formatDuration(activity.movingTime)),
            _buildStatItem(
              "Allure",
              "${activity.avgSpeedKmh.toStringAsFixed(1)} km/h",
            ),
            // Note: Pour l'allure en min/km, il faudrait une petite fonction de conversion ici
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        Text(label, style: const TextStyle(color: Colors.grey)),
      ],
    );
  }

  Widget _buildSplitItem(Split split) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: Colors.deepOrange.shade100,
        child: Text(
          "${split.index}",
          style: const TextStyle(color: Colors.deepOrange),
        ),
      ),
      title: Text("Km ${split.index}"),
      subtitle: Text("Altitude: ${split.altitude.toStringAsFixed(0)}m"),
      trailing: Text(
        _formatDuration(split.duration),
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
