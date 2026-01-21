import 'package:flutter_test/flutter_test.dart';
import 'package:admin_pos_lite/main.dart';

void main() {
  testWidgets('App starts successfully', (WidgetTester tester) async {
    await tester.pumpWidget(const AdminPosLiteApp());
    expect(find.text('Splash'), findsOneWidget);
  });
}
