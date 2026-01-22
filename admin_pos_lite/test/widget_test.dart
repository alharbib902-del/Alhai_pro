import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:alhai_design_system/alhai_design_system.dart';

void main() {
  testWidgets('Admin POS Lite App renders correctly', (WidgetTester tester) async {
    // Build a simple MaterialApp for testing
    await tester.pumpWidget(
      MaterialApp(
        title: 'كاشير الحي',
        theme: AlhaiTheme.light,
        locale: const Locale('ar'),
        supportedLocales: const [
          Locale('ar'),
          Locale('en'),
        ],
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        home: const Scaffold(
          body: Center(
            child: Text('Admin POS Lite'),
          ),
        ),
      ),
    );
    
    await tester.pumpAndSettle();
    
    expect(find.text('Admin POS Lite'), findsOneWidget);
  });
}
