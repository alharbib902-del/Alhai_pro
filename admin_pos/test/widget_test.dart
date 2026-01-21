import 'package:flutter_test/flutter_test.dart';
import 'package:admin_pos/main.dart';

void main() {
  testWidgets('App starts successfully', (WidgetTester tester) async {
    await tester.pumpWidget(const AdminPosApp());
    expect(find.text('Splash'), findsOneWidget);
  });
}
