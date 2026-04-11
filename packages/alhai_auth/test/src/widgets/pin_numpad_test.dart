import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:alhai_l10n/alhai_l10n.dart';
import 'package:alhai_auth/alhai_auth.dart';

void main() {
  group('PinDisplay', () {
    Widget buildPinDisplay({
      int length = 4,
      int filledCount = 0,
      bool hasError = false,
      bool obscure = true,
    }) {
      return MaterialApp(
        home: Scaffold(
          body: PinDisplay(
            length: length,
            filledCount: filledCount,
            hasError: hasError,
            obscure: obscure,
          ),
        ),
      );
    }

    testWidgets('renders correct number of dots', (tester) async {
      await tester.pumpWidget(buildPinDisplay(length: 4));
      await tester.pump();

      // 4 AnimatedContainers for the dots
      expect(find.byType(AnimatedContainer), findsNWidgets(4));
    });

    testWidgets('renders 6 dots when length is 6', (tester) async {
      await tester.pumpWidget(buildPinDisplay(length: 6));
      await tester.pump();

      expect(find.byType(AnimatedContainer), findsNWidgets(6));
    });

    testWidgets('shows filled indicator for entered digits', (tester) async {
      await tester.pumpWidget(buildPinDisplay(length: 4, filledCount: 2));
      await tester.pump();

      // When obscure is true, filled dots have a Container with circle shape
      final containers = tester.widgetList<Container>(find.byType(Container));
      final filledDots = containers.where((c) {
        final decoration = c.decoration;
        if (decoration is BoxDecoration) {
          return decoration.shape == BoxShape.circle;
        }
        return false;
      });
      expect(filledDots.length, 2);
    });
  });

  group('PinNumpad', () {
    Widget buildNumpad({
      ValueChanged<String>? onKeyPressed,
      VoidCallback? onBackspace,
      VoidCallback? onBiometric,
      bool showBiometric = false,
      bool enabled = true,
    }) {
      return MaterialApp(
        home: Scaffold(
          body: PinNumpad(
            onKeyPressed: onKeyPressed ?? (_) {},
            onBackspace: onBackspace ?? () {},
            onBiometric: onBiometric,
            showBiometric: showBiometric,
            enabled: enabled,
          ),
        ),
      );
    }

    testWidgets('renders digits 0-9', (tester) async {
      await tester.pumpWidget(buildNumpad());
      await tester.pump();

      for (var i = 0; i <= 9; i++) {
        expect(find.text('$i'), findsOneWidget);
      }
    });

    testWidgets('renders backspace icon', (tester) async {
      await tester.pumpWidget(buildNumpad());
      await tester.pump();

      expect(find.byIcon(Icons.backspace_outlined), findsOneWidget);
    });

    testWidgets('shows biometric button when enabled', (tester) async {
      await tester.pumpWidget(buildNumpad(showBiometric: true));
      await tester.pump();

      expect(find.byIcon(Icons.fingerprint_rounded), findsOneWidget);
    });

    testWidgets('hides biometric button when disabled', (tester) async {
      await tester.pumpWidget(buildNumpad(showBiometric: false));
      await tester.pump();

      expect(find.byIcon(Icons.fingerprint_rounded), findsNothing);
    });

    testWidgets('calls onKeyPressed when digit tapped', (tester) async {
      String? pressedKey;
      await tester.pumpWidget(
        buildNumpad(onKeyPressed: (key) => pressedKey = key),
      );
      await tester.pump();

      await tester.tap(find.text('5'));
      expect(pressedKey, '5');
    });

    testWidgets('calls onBackspace when backspace tapped', (tester) async {
      bool backspacePressed = false;
      await tester.pumpWidget(
        buildNumpad(onBackspace: () => backspacePressed = true),
      );
      await tester.pump();

      await tester.tap(find.byIcon(Icons.backspace_outlined));
      expect(backspacePressed, isTrue);
    });

    testWidgets('calls onBiometric when fingerprint tapped', (tester) async {
      bool biometricPressed = false;
      await tester.pumpWidget(
        buildNumpad(
          showBiometric: true,
          onBiometric: () => biometricPressed = true,
        ),
      );
      await tester.pump();

      await tester.tap(find.byIcon(Icons.fingerprint_rounded));
      expect(biometricPressed, isTrue);
    });

    testWidgets('all keys work in sequence', (tester) async {
      final pressedKeys = <String>[];
      await tester.pumpWidget(
        buildNumpad(onKeyPressed: (key) => pressedKeys.add(key)),
      );
      await tester.pump();

      await tester.tap(find.text('1'));
      await tester.tap(find.text('2'));
      await tester.tap(find.text('3'));
      await tester.tap(find.text('4'));

      expect(pressedKeys, ['1', '2', '3', '4']);
    });
  });

  group('ManagerApprovalDialog', () {
    testWidgets('renders with action text', (tester) async {
      // Use a taller surface to avoid overflow (dialog content is large)
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('ar'),
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () {
                  ManagerApprovalDialog.show(
                    context: context,
                    action: 'Delete product',
                    onVerify: (_) async => true,
                  );
                },
                child: const Text('Show Dialog'),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Show Dialog'));
      await tester.pumpAndSettle();

      // Dialog should be visible with pin display
      expect(find.byType(PinDisplay), findsOneWidget);
      expect(find.byType(PinNumpad), findsOneWidget);
    });
  });

  group('PinInputField', () {
    testWidgets('renders correct number of fields', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: PinInputField(length: 4, autofocus: false)),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(TextField), findsNWidgets(4));
    });

    testWidgets('renders 6 fields when length is 6', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: PinInputField(length: 6, autofocus: false)),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(TextField), findsNWidgets(6));
    });

    testWidgets('calls onCompleted when all digits entered', (tester) async {
      String? completedPin;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PinInputField(
              length: 4,
              autofocus: false,
              onCompleted: (pin) => completedPin = pin,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final fields = find.byType(TextField);
      for (var i = 0; i < 4; i++) {
        await tester.tap(fields.at(i));
        await tester.enterText(fields.at(i), '${i + 1}');
        await tester.pumpAndSettle();
      }

      expect(completedPin, '1234');
    });
  });
}
