import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:alhai_l10n/alhai_l10n.dart';
import 'package:alhai_auth/alhai_auth.dart';

void main() {
  group('ManagerApprovalScreen', () {
    Widget buildTestableWidget({
      ManagerApprovalMode mode = ManagerApprovalMode.verify,
      String? action,
    }) {
      return ProviderScope(
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('ar'),
          home: ManagerApprovalScreen(mode: mode, action: action),
        ),
      );
    }

    testWidgets('renders in verify mode', (tester) async {
      await tester.pumpWidget(buildTestableWidget());
      await tester.pumpAndSettle();

      expect(find.byType(ManagerApprovalScreen), findsOneWidget);
    });

    testWidgets('shows keypad buttons 0-9', (tester) async {
      await tester.pumpWidget(buildTestableWidget());
      await tester.pumpAndSettle();

      // Verify number buttons are present
      for (var i = 0; i <= 9; i++) {
        expect(find.text('$i'), findsWidgets);
      }
    });

    testWidgets('shows C (clear) button', (tester) async {
      await tester.pumpWidget(buildTestableWidget());
      await tester.pumpAndSettle();

      expect(find.text('C'), findsOneWidget);
    });

    testWidgets('shows backspace icon', (tester) async {
      await tester.pumpWidget(buildTestableWidget());
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.backspace_outlined), findsOneWidget);
    });

    testWidgets('renders in dialog mode with action text', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            locale: const Locale('ar'),
            home: Builder(
              builder: (context) => Scaffold(
                body: ElevatedButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (_) => const ManagerApprovalScreen(
                        mode: ManagerApprovalMode.dialog,
                        action: 'Test Action',
                      ),
                    );
                  },
                  child: const Text('Open Dialog'),
                ),
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      await tester.tap(find.text('Open Dialog'));
      await tester.pumpAndSettle();

      expect(find.text('Test Action'), findsOneWidget);
    });
  });

  group('ManagerApprovalMode', () {
    test('has setup, verify, dialog values', () {
      expect(ManagerApprovalMode.values, hasLength(3));
      expect(ManagerApprovalMode.values, contains(ManagerApprovalMode.setup));
      expect(ManagerApprovalMode.values, contains(ManagerApprovalMode.verify));
      expect(ManagerApprovalMode.values, contains(ManagerApprovalMode.dialog));
    });
  });
}
