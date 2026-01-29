import '../models/activity.dart';
import '../models/activity_route.dart';

class DataRepository {
  static final DataRepository _instance = DataRepository._internal();
  factory DataRepository() => _instance;
  DataRepository._internal();

  final List<Activity> _activities = [];

  ActivityRoute? demoRoute;
  List<Activity> get activities => List.unmodifiable(_activities);

  void addActivity(Activity activity) {
    _activities.insert(0, activity);
    _activities.sort((a, b) => b.startTime.compareTo(a.startTime));
  }
}
