import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:running_app/services/gpx_service.dart';

void main() {
  // 'group' permet d'organiser tes tests par module (comme des dossiers)
  group('GpxService Tests', () {
    // Le composant à tester (Device Under Test)
    late GpxService service;

    // 'setUp' s'exécute avant CHAQUE test. C'est l'initialisation du banc.
    setUp(() {
      service = GpxService();
    });

    test('Doit parser un fichier GPX valide et retourner la bonne distance', () async {
      // 1. ARRANGEMENT (Préparation des entrées)
      // On lit ton fichier réel.
      // ATTENTION : Mets ton fichier 'test.gpx' à la racine du projet pour ce test
      final file = File('./datas/data_test_running.gpx');

      // Si tu n'as pas encore mis le fichier, on utilise une chaine XML simulée pour que le test compile :
      // (Décommente la ligne suivante et commente celle du dessus si pas de fichier)
      // const xmlContent = mockGpxContent;
      final xmlContent = await file.readAsString();

      // 2. ACTION (Exécution de la fonction à tester)
      final result = service.parseGpx(xmlContent);

      // 3. ASSERTION (Vérification des résultats)

      // Vérifions que l'objet n'est pas nul
      expect(result.activity, isNotNull);
      expect(result.route.points, isNotEmpty);

      // Vérification de la cohérence métier
      print('--- RÉSULTATS DU PARSING ---');
      print('Points trouvés : ${result.route.points?.length}');
      print(
        'Distance totale : ${result.activity.distanceMeters.toStringAsFixed(2)} m',
      );
      print('Durée totale : ${result.activity.elapsedTime}');

      // Ici, remplace '10500' par la distance approximative que tu attends (en mètres)
      // Le 'matcher' greaterThan permet de vérifier qu'on a bien lu des données
      expect(result.activity.distanceMeters, greaterThan(0));

      // Vérifions qu'on a bien des splits
      expect(result.activity.splits, isNotEmpty);
      print('Nombre de splits (km) : ${result.activity.splits?.length}');
    });
  });
}
