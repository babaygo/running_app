import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:running_app/models/activity.dart';

class ActivityCard extends StatelessWidget {
  final Activity activity;
  final VoidCallback? onTap;

  const ActivityCard({
    super.key,
    required this.activity,
    this.onTap,
  });

  String _getActivityIcon(String type) {
    switch (type.toLowerCase()) {
      case 'running':
        return '🏃';
      case 'cycling':
        return '🚴';
      case 'walking':
        return '🚶';
      default:
        return '🏃';
    }
  }

  String _getActivityLabel(String type) {
    switch (type.toLowerCase()) {
      case 'running':
        return 'Course';
      case 'cycling':
        return 'Cyclisme';
      case 'walking':
        return 'Marche';
      default:
        return type;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      elevation: 2,
      child: ListTile(
        onTap: onTap,
        leading: Text(
          _getActivityIcon(activity.type),
          style: const TextStyle(fontSize: 24),
        ),
        title: Text(
          _getActivityLabel(activity.type),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              DateFormat('dd MMM yyyy à HH:mm', 'fr_FR').format(activity.startTime),
              style: const TextStyle(fontSize: 12),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Text('${activity.distance.toStringAsFixed(2)} km'),
                const SizedBox(width: 12),
                Text('${activity.paceFormatted}/km'),
                const SizedBox(width: 12),
                Text(activity.durationFormatted),
              ],
            ),
            if (activity.elevationGain > 0)
              Padding(
                padding: const EdgeInsets.only(top: 4.0),
                child: Text(
                  '↑ ${activity.elevationGain.toStringAsFixed(0)} m',
                  style: TextStyle(fontSize: 11, color: Colors.orange.shade600),
                ),
              ),
          ],
        ),
        trailing: const Icon(Icons.chevron_right),
        isThreeLine: activity.elevationGain > 0,
      ),
    );
  }
}

class StatCard extends StatelessWidget {
  final String label;
  final String value;
  final String? unit;
  final IconData icon;
  final Color color;

  const StatCard({
    super.key,
    required this.label,
    required this.value,
    this.unit,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 24),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (unit != null)
                  Padding(
                    padding: const EdgeInsets.only(left: 4.0),
                    child: Text(
                      unit!,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class GPSIndicator extends StatelessWidget {
  final bool isConnected;
  final bool isLoading;
  final String? accuracy;

  const GPSIndicator({
    super.key,
    required this.isConnected,
    this.isLoading = false,
    this.accuracy,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: isConnected ? Colors.green.shade50 : Colors.orange.shade50,
        border: Border.all(
          color: isConnected ? Colors.green : Colors.orange,
          width: 1,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isLoading)
            const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          else
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: isConnected ? Colors.green : Colors.orange,
                shape: BoxShape.circle,
              ),
            ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                isConnected ? 'GPS Connecté' : 'GPS en recherche',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: isConnected ? Colors.green : Colors.orange,
                ),
              ),
              if (accuracy != null)
                Text(
                  'Précision: $accuracy m',
                  style: const TextStyle(fontSize: 10, color: Colors.grey),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
