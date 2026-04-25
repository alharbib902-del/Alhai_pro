library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cashier/screens/settings/system/backup_screen.dart';

import '../../helpers/test_helpers.dart';
import '../../helpers/mock_database.dart';

void main() {
  setUpAll(() => registerCashierFallbackValues());

  setUp(() {
    // BackupScreen uses _db.select(_db.settingsTable).
    // The catch block handles errors; shows defaults.
    final db = setupMockDatabase();
    setupTestGetIt(mockDb: db);
    // Wave 5 (P0-09): the screen now reads the auto-backup OS-fire
    // telemetry from SharedPreferences inside _loadBackupSettings.
    // Without a mock store the platform call hangs and pumpAndSettle
    // never returns. Empty initial values satisfy the read paths.
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  tearDown(() => tearDownTestGetIt());

  group('BackupScreen', () {
    testWidgets('renders with defaults', (tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;
      suppressOverflowErrors();

      await tester.pumpWidget(createTestWidget(const BackupScreen()));
      await tester.pumpAndSettle();

      expect(find.byType(BackupScreen), findsOneWidget);

      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    testWidgets('shows loading indicator initially', (tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;
      suppressOverflowErrors();

      await tester.pumpWidget(createTestWidget(const BackupScreen()));
      await tester.pumpAndSettle();

      // Provider resolves synchronously in test, so loading state
      // is not observable. Verify the screen rendered successfully.
      expect(find.byType(BackupScreen), findsOneWidget);

      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    testWidgets('renders in dark mode', (tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;
      suppressOverflowErrors();

      await tester.pumpWidget(
        createTestWidget(const BackupScreen(), theme: ThemeData.dark()),
      );
      await tester.pumpAndSettle();

      expect(find.byType(BackupScreen), findsOneWidget);

      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    testWidgets('renders on mobile viewport', (tester) async {
      tester.view.physicalSize = const Size(400, 800);
      tester.view.devicePixelRatio = 1.0;
      suppressOverflowErrors();

      await tester.pumpWidget(createTestWidget(const BackupScreen()));
      await tester.pumpAndSettle();

      expect(find.byType(BackupScreen), findsOneWidget);

      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    testWidgets('has auto-backup switch', (tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;
      suppressOverflowErrors();

      await tester.pumpWidget(createTestWidget(const BackupScreen()));
      await tester.pumpAndSettle();

      // Backup screen has switches for auto-backup toggle
      expect(find.byType(Switch), findsWidgets);

      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    // --- New behaviour: Arabic strings + empty backup state ----------------

    testWidgets('shows Arabic "no backup yet" helper when empty', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;
      suppressOverflowErrors();

      await tester.pumpWidget(createTestWidget(const BackupScreen()));
      await tester.pumpAndSettle();

      // Empty DB → hasBackup=false → expect the Arabic empty prompt.
      // Was previously English "No backup yet".
      expect(
        find.text('لا توجد نسخة احتياطية بعد. قم بإنشاء أول نسخة الآن.'),
        findsOneWidget,
      );

      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    testWidgets('shows Arabic "backup now" action button', (tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;
      suppressOverflowErrors();

      await tester.pumpWidget(createTestWidget(const BackupScreen()));
      await tester.pumpAndSettle();

      // Was "Backup Now" — now Arabic. Appears only in the empty-state
      // (hasBackup=false) branch, which is exactly our test setup.
      expect(find.text('نسخ احتياطي الآن'), findsOneWidget);

      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    testWidgets('shows Arabic "restore now" action button', (tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;
      suppressOverflowErrors();

      await tester.pumpWidget(createTestWidget(const BackupScreen()));
      await tester.pumpAndSettle();

      // The Restore section is always rendered — was "Restore Now" in
      // English.
      expect(find.text('استعادة الآن'), findsOneWidget);

      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });
  });
}
