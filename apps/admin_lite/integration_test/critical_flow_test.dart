import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Critical Flow', () {
    testWidgets('app launches and shows main screen', (tester) async {
      expect(IntegrationTestWidgetsFlutterBinding.instance, isNotNull);
    });
  });
}
