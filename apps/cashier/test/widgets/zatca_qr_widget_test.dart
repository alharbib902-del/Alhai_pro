import 'package:cashier/widgets/zatca_qr_widget.dart';
import 'package:alhai_l10n/alhai_l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qr_flutter/qr_flutter.dart';

Widget _wrap(Widget child) {
  return MaterialApp(
    locale: const Locale('en'),
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: Scaffold(body: Center(child: child)),
  );
}

void main() {
  final timestamp = DateTime.utc(2026, 4, 18, 12, 0, 0);

  group('ZatcaQrWidget', () {
    testWidgets('renders warning card when vatNumber is null', (tester) async {
      await tester.pumpWidget(
        _wrap(
          ZatcaQrWidget(
            sellerName: 'Al-HAI Store',
            vatNumber: null,
            timestamp: timestamp,
            totalWithVat: 115,
            vatAmount: 15,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.gpp_bad_outlined), findsOneWidget);
      expect(find.byType(QrImageView), findsNothing);
    });

    testWidgets('renders warning card when vatNumber fails format validation',
        (tester) async {
      await tester.pumpWidget(
        _wrap(
          ZatcaQrWidget(
            sellerName: 'Al-HAI Store',
            vatNumber: '123',
            timestamp: timestamp,
            totalWithVat: 115,
            vatAmount: 15,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.gpp_bad_outlined), findsOneWidget);
      expect(find.byType(QrImageView), findsNothing);
    });

    testWidgets('renders QR code when vatNumber is a valid 15-digit number',
        (tester) async {
      await tester.pumpWidget(
        _wrap(
          ZatcaQrWidget(
            sellerName: 'Al-HAI Store',
            vatNumber: '300000000000003',
            timestamp: timestamp,
            totalWithVat: 115,
            vatAmount: 15,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(QrImageView), findsOneWidget);
      expect(find.byIcon(Icons.gpp_bad_outlined), findsNothing);
    });
  });
}
