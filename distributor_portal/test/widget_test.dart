import 'package:flutter_test/flutter_test.dart';
import 'package:distributor_portal/main.dart';

void main() {
  testWidgets('App starts successfully', (WidgetTester tester) async {
    await tester.pumpWidget(const DistributorPortalApp());
    expect(find.text('Splash'), findsOneWidget);
  });
}
