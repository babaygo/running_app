import 'package:running_app/models/activity.dart';

class ActivityService {
  static final ActivityService _instance = ActivityService._internal();
  
  late List<Activity> _activities;
  
  factory ActivityService() {
    return _instance;
  }
  
  ActivityService._internal() {
    _activities = _generateMockData();
  }

  List<Activity> get activities => _activities;

  List<Activity> getRecentActivities({int limit = 5}) {
    final activities = _activities
        .where((a) => a.endTime != null)
        .toList();
    activities.sort((a, b) => b.startTime.compareTo(a.startTime));
    return activities.take(limit).toList();
  }

  WeeklyStats getWeeklyStats() {
    final now = DateTime.now();
    final weekAgo = now.subtract(const Duration(days: 7));
    
    final weekActivities = _activities
        .where((a) => a.startTime.isAfter(weekAgo) && a.endTime != null)
        .toList();
    
    final totalDistance = weekActivities.fold<double>(0, (sum, a) => sum + a.distance);
    final totalDuration = weekActivities.fold<int>(0, (sum, a) => sum + a.duration);
    final totalCalories = weekActivities.fold<int>(0, (sum, a) => sum + a.calories);
    
    return WeeklyStats(
      totalActivities: weekActivities.length,
      totalDistance: totalDistance,
      totalDuration: totalDuration,
      totalCalories: totalCalories,
      activities: weekActivities,
    );
  }

  Activity addActivity(Activity activity) {
    _activities.add(activity);
    return activity;
  }

  void updateActivity(Activity activity) {
    final index = _activities.indexWhere((a) => a.id == activity.id);
    if (index != -1) {
      _activities[index] = activity;
    }
  }

  Activity? getActivityById(String id) {
    try {
      return _activities.firstWhere((a) => a.id == id);
    } catch (e) {
      return null;
    }
  }

  List<Activity> _generateMockData() {
    final now = DateTime.now();
    
    return [
      Activity(
        id: '1',
        type: 'running',
        startTime: now.subtract(const Duration(days: 1)),
        endTime: now.subtract(const Duration(days: 1, hours: 1)),
        distance: 10.5,
        duration: 3600,
        calories: 750,
        elevationGain: 142.5,
        splits: [
          KmSplit(kmNumber: 1, durationSeconds: 345, elevationGain: 15),
          KmSplit(kmNumber: 2, durationSeconds: 355, elevationGain: 20),
          KmSplit(kmNumber: 3, durationSeconds: 348, elevationGain: 18),
          KmSplit(kmNumber: 4, durationSeconds: 352, elevationGain: 22),
          KmSplit(kmNumber: 5, durationSeconds: 350, elevationGain: 19),
          KmSplit(kmNumber: 6, durationSeconds: 346, elevationGain: 16),
          KmSplit(kmNumber: 7, durationSeconds: 349, elevationGain: 17),
          KmSplit(kmNumber: 8, durationSeconds: 353, elevationGain: 21),
          KmSplit(kmNumber: 9, durationSeconds: 351, elevationGain: 19),
          KmSplit(kmNumber: 10, durationSeconds: 348, elevationGain: 18),
        ],
        route: [],
      ),
      Activity(
        id: '2',
        type: 'cycling',
        startTime: now.subtract(const Duration(days: 2)),
        endTime: now.subtract(const Duration(days: 2, hours: 2)),
        distance: 45.0,
        duration: 7200,
        calories: 1200,
        elevationGain: 280.0,
        splits: [
          KmSplit(kmNumber: 1, durationSeconds: 156, elevationGain: 28),
          KmSplit(kmNumber: 2, durationSeconds: 164, elevationGain: 32),
          KmSplit(kmNumber: 3, durationSeconds: 158, elevationGain: 25),
        ],
        route: [],
      ),
      Activity(
        id: '3',
        type: 'running',
        startTime: now.subtract(const Duration(days: 3)),
        endTime: now.subtract(const Duration(days: 3, hours: 1, minutes: 30)),
        distance: 12.0,
        duration: 5400,
        calories: 850,
        elevationGain: 95.0,
        splits: [
          KmSplit(kmNumber: 1, durationSeconds: 450, elevationGain: 8),
          KmSplit(kmNumber: 2, durationSeconds: 448, elevationGain: 9),
          KmSplit(kmNumber: 3, durationSeconds: 452, elevationGain: 10),
          KmSplit(kmNumber: 4, durationSeconds: 446, elevationGain: 7),
          KmSplit(kmNumber: 5, durationSeconds: 450, elevationGain: 8),
          KmSplit(kmNumber: 6, durationSeconds: 448, elevationGain: 9),
          KmSplit(kmNumber: 7, durationSeconds: 449, elevationGain: 9),
          KmSplit(kmNumber: 8, durationSeconds: 447, elevationGain: 8),
          KmSplit(kmNumber: 9, durationSeconds: 451, elevationGain: 10),
          KmSplit(kmNumber: 10, durationSeconds: 448, elevationGain: 9),
          KmSplit(kmNumber: 11, durationSeconds: 450, elevationGain: 8),
          KmSplit(kmNumber: 12, durationSeconds: 449, elevationGain: 9),
        ],
        route: [],
      ),
      Activity(
        id: '4',
        type: 'walking',
        startTime: now.subtract(const Duration(days: 4)),
        endTime: now.subtract(const Duration(days: 4, hours: 1)),
        distance: 5.2,
        duration: 3600,
        calories: 300,
        elevationGain: 45.0,
        splits: [
          KmSplit(kmNumber: 1, durationSeconds: 708, elevationGain: 8),
          KmSplit(kmNumber: 2, durationSeconds: 716, elevationGain: 9),
          KmSplit(kmNumber: 3, durationSeconds: 702, elevationGain: 7),
          KmSplit(kmNumber: 4, durationSeconds: 710, elevationGain: 8),
          KmSplit(kmNumber: 5, durationSeconds: 704, elevationGain: 7),
        ],
        route: [],
      ),
      Activity(
        id: '5',
        type: 'running',
        startTime: now.subtract(const Duration(days: 5)),
        endTime: now.subtract(const Duration(days: 5, hours: 1, minutes: 20)),
        distance: 11.0,
        duration: 4800,
        calories: 800,
        elevationGain: 120.0,
        splits: [
          KmSplit(kmNumber: 1, durationSeconds: 436, elevationGain: 10),
          KmSplit(kmNumber: 2, durationSeconds: 441, elevationGain: 11),
          KmSplit(kmNumber: 3, durationSeconds: 438, elevationGain: 10),
          KmSplit(kmNumber: 4, durationSeconds: 443, elevationGain: 12),
          KmSplit(kmNumber: 5, durationSeconds: 439, elevationGain: 11),
          KmSplit(kmNumber: 6, durationSeconds: 437, elevationGain: 10),
          KmSplit(kmNumber: 7, durationSeconds: 442, elevationGain: 11),
          KmSplit(kmNumber: 8, durationSeconds: 440, elevationGain: 11),
          KmSplit(kmNumber: 9, durationSeconds: 438, elevationGain: 10),
          KmSplit(kmNumber: 10, durationSeconds: 441, elevationGain: 11),
          KmSplit(kmNumber: 11, durationSeconds: 439, elevationGain: 10),
        ],
        route: [],
      ),
    ];
  }
}
