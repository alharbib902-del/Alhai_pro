import 'package:flutter_test/flutter_test.dart';
import 'package:super_admin/main.dart';

void main() {
  testWidgets('App starts successfully', (WidgetTester tester) async {
    await tester.pumpWidget(const SuperAdminApp());
    expect(find.text('Splash'), findsOneWidget);
  });
}
