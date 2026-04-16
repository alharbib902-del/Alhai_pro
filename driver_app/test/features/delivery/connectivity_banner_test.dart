import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:alhai_design_system/alhai_design_system.dart';

import 'package:driver_app/shared/widgets/connectivity_banner.dart';
import 'package:driver_app/core/providers/app_providers.dart';

void main() {
  group('M3 — Connectivity Banner', () {
    Widget buildTestWidget({required bool isOnline}) {
      return ProviderScope(
        overrides: [
          connectivityProvider.overrideWith((ref) {
            return Stream.value(isOnline);
          }),
        ],
        child: MaterialApp(
          locale: const Locale('ar'),
          supportedLocales: const [Locale('ar')],
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          theme: AlhaiTheme.light,
          home: const Scaffold(body: ConnectivityBanner()),
        ),
      );
    }

    testWidgets('shows offline banner when disconnected', (tester) async {
      await tester.pumpWidget(buildTestWidget(isOnline: false));
      await tester.pumpAndSettle();

      expect(find.text('لا يوجد اتصال بالإنترنت'), findsOneWidget);
      expect(find.byIcon(Icons.wifi_off_rounded), findsOneWidget);
    });

    testWidgets('hides banner when online', (tester) async {
      await tester.pumpWidget(buildTestWidget(isOnline: true));
      await tester.pumpAndSettle();

      expect(find.text('لا يوجد اتصال بالإنترنت'), findsNothing);
    });
  });
}
