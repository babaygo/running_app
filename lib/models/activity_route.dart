import 'package:isar/isar.dart';
import 'trackpoint.dart';

part 'activity_route.g.dart';

@collection
class ActivityRoute {
  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  String? activityUuid;

  List<TrackPoint>? points;

  ActivityRoute({this.activityUuid, this.points});
}
