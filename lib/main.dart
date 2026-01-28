import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'repositories/data_repository.dart';
import 'services/gpx_service.dart';
// Importe tes futures pages ici
import 'ui/home_page.dart';
import 'ui/activity_page.dart';
import 'ui/history_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Initialisation des données (Simulation BDD)
  final String gpxContent = await rootBundle.loadString(
    'assets/data_test_running.gpx',
  );
  final parsedData = GpxService().parseGpx(gpxContent);
  DataRepository().addActivity(parsedData.activity); // On stocke dans le repo

  runApp(const MyApp());
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
  int _currentIndex = 0; // L'état : quel onglet est actif ?

  // Les 3 pages sont instanciées ici
  final List<Widget> _pages = [
    const HomePage(),
    const ActivityPage(),
    const HistoryPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // On affiche la page correspondant à l'index actuel
      body: _pages[_currentIndex],

      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (int index) {
          // setState dit à Flutter de redessiner le Scaffold avec le nouvel index
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
