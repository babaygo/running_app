// Imports packages
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:intl/date_symbol_data_local.dart';
// Import repository
import 'repositories/data_repository.dart';
// Imports services
import 'services/gpx_service.dart';
import 'services/recorder_service.dart';
// Imports pages
import 'ui/home_page.dart';
import 'ui/activity_page.dart';
import 'ui/history_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await DataRepository().init();

  await initializeDateFormatting('fr_FR', null);

  final String gpxContent = await rootBundle.loadString(
    'assets/data_test_running.gpx',
  );
  final parsedData = GpxService().parseGpx(gpxContent);

  DataRepository().demoRoute = parsedData.route;

  runApp(
    MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => RecorderService())],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Running App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepOrange),
        useMaterial3: true,
      ),
      home: const MainScaffold(),
    );
  }
}

class MainScaffold extends StatefulWidget {
  const MainScaffold({super.key});

  @override
  State<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const HomePage(),
    const ActivityPage(),
    const HistoryPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],

      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (int index) {
          setState(() {
            _currentIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Accueil',
          ),
          NavigationDestination(
            icon: Icon(Icons.map_outlined),
            selectedIcon: Icon(Icons.map),
            label: 'Activité',
          ),
          NavigationDestination(
            icon: Icon(Icons.history_outlined),
            selectedIcon: Icon(Icons.history),
            label: 'Historique',
          ),
        ],
      ),
    );
  }
}
