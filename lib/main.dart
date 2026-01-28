import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'services/gpx_service.dart';
import 'ui/activity_detail_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  initializeDateFormatting('fr_FR', null);

  String gpxContent = await rootBundle.loadString('./datas/data_test_running.gpx');
  final parsedData = GpxService().parseGpx(gpxContent);

  runApp(
    MaterialApp(
      theme: ThemeData(primarySwatch: Colors.deepOrange),
      home: ActivityDetailPage(activity: parsedData.activity),
    ),
  );
}
