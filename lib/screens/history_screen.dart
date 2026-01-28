import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:running_app/models/activity.dart';
import 'package:running_app/services/activity_service.dart';
import 'package:running_app/widgets/activity_card.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  late ActivityService _activityService;
  String _filterType = 'all';

  @override
  void initState() {
    super.initState();
    _activityService = ActivityService();
  }

  List<Activity> _getFilteredActivities() {
    var activities = _activityService.activities
        .where((a) => a.endTime != null)
        .toList();

    if (_filterType != 'all') {
      activities = activities
          .where((a) => a.type.toLowerCase() == _filterType.toLowerCase())
          .toList();
    }

    // Trier par date décroissante
    activities.sort((a, b) => b.startTime.compareTo(a.startTime));

    return activities;
  }

  void _showActivityDetails(Activity activity) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _ActivityDetailsSheet(activity: activity),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filteredActivities = _getFilteredActivities();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Historique'),
        centerTitle: true,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Filtres
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
              child: Row(
                children: [
                  _FilterChip(
                    label: 'Tous',
                    isSelected: _filterType == 'all',
                    onSelected: () {
                      setState(() => _filterType = 'all');
                    },
                  ),
                  const SizedBox(width: 8),
                  _FilterChip(
                    label: '🏃 Course',
                    isSelected: _filterType == 'running',
                    onSelected: () {
                      setState(() => _filterType = 'running');
                    },
                  ),
                  const SizedBox(width: 8),
                  _FilterChip(
                    label: '🚴 Cyclisme',
                    isSelected: _filterType == 'cycling',
                    onSelected: () {
                      setState(() => _filterType = 'cycling');
                    },
                  ),
                  const SizedBox(width: 8),
                  _FilterChip(
                    label: '🚶 Marche',
                    isSelected: _filterType == 'walking',
                    onSelected: () {
                      setState(() => _filterType = 'walking');
                    },
                  ),
                ],
              ),
            ),
          ),

          // Résumé des statistiques filtrées
          if (filteredActivities.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue.shade200),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _SummaryItem(
                      label: 'Activités',
                      value: filteredActivities.length.toString(),
                    ),
                    _SummaryItem(
                      label: 'Distance',
                      value: filteredActivities
                          .fold<double>(0, (sum, a) => sum + a.distance)
                          .toStringAsFixed(1),
                      unit: 'km',
                    ),
                    _SummaryItem(
                      label: 'Calories',
                      value: filteredActivities
                          .fold<int>(0, (sum, a) => sum + a.calories)
                          .toString(),
                      unit: 'kcal',
                    ),
                  ],
                ),
              ),
            ),

          // Liste des activités
          Expanded(
            child: filteredActivities.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.history_outlined,
                          size: 48,
                          color: Colors.grey.shade300,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Aucune activité trouvée',
                          style: TextStyle(color: Colors.grey.shade600),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.only(bottom: 16),
                    itemCount: filteredActivities.length,
                    itemBuilder: (context, index) {
                      return ActivityCard(
                        activity: filteredActivities[index],
                        onTap: () {
                          _showActivityDetails(filteredActivities[index]);
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onSelected;

  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => onSelected(),
      backgroundColor: Colors.grey.shade100,
      selectedColor: Colors.blue.shade300,
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : Colors.black,
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
      ),
    );
  }
}

class _SummaryItem extends StatelessWidget {
  final String label;
  final String value;
  final String? unit;

  const _SummaryItem({
    required this.label,
    required this.value,
    this.unit,
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
        Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(
              value,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (unit != null)
              Padding(
                padding: const EdgeInsets.only(left: 4.0),
                child: Text(
                  unit!,
                  style: const TextStyle(fontSize: 10),
                ),
              ),
          ],
        ),
      ],
    );
  }
}

class _ActivityDetailsSheet extends StatelessWidget {
  final Activity activity;

  const _ActivityDetailsSheet({required this.activity});

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

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Text(
                  _getActivityIcon(activity.type),
                  style: const TextStyle(fontSize: 32),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _getActivityLabel(activity.type),
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      DateFormat('dd MMM yyyy à HH:mm', 'fr_FR')
                          .format(activity.startTime),
                      style: TextStyle(
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 24),
            // Première ligne: Distance, Durée, Allure
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _DetailBox(
                  icon: Icons.straighten,
                  label: 'Distance',
                  value: '${activity.distance.toStringAsFixed(2)} km',
                ),
                _DetailBox(
                  icon: Icons.timer,
                  label: 'Durée',
                  value: activity.durationFormatted,
                ),
                _DetailBox(
                  icon: Icons.speed,
                  label: 'Allure',
                  value: '${activity.paceFormatted}/km',
                ),
              ],
            ),
            const SizedBox(height: 20),
            // Deuxième ligne: Dénivelé et Calories
            if (activity.elevationGain > 0 || activity.calories > 0)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (activity.elevationGain > 0)
                    _DetailBox(
                      icon: Icons.terrain,
                      label: 'Dénivelé +',
                      value: '${activity.elevationGain.toStringAsFixed(0)} m',
                    ),
                  _DetailBox(
                    icon: Icons.local_fire_department,
                    label: 'Calories',
                    value: '${activity.calories} kcal',
                  ),
                ],
              ),
            const SizedBox(height: 24),
            // Splits
            if (activity.splits.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Temps par kilomètre',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 12),
                  Column(
                    children: activity.splits.map((split) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade50,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.blue.shade200),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Km ${split.kmNumber}',
                                style: const TextStyle(fontWeight: FontWeight.w600),
                              ),
                              Text(
                                split.paceFormatted,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              if (split.elevationGain != null && split.elevationGain! > 0)
                                Text(
                                  '↑ ${split.elevationGain!.toStringAsFixed(0)}m',
                                  style: TextStyle(
                                    color: Colors.orange.shade600,
                                    fontSize: 12,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Fermer'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailBox extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _DetailBox({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(icon, size: 20, color: Colors.grey.shade600),
            const SizedBox(height: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey.shade600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
