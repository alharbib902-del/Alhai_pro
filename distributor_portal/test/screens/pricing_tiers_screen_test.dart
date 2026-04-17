import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:alhai_design_system/alhai_design_system.dart';
import 'package:alhai_l10n/alhai_l10n.dart';

import 'package:distributor_portal/data/distributor_datasource.dart';
import 'package:distributor_portal/data/models.dart';
import 'package:distributor_portal/providers/distributor_datasource_provider.dart';
import 'package:distributor_portal/screens/pricing/pricing_tiers_screen.dart';

// ─── Fake datasource ─────────────────────────────────────────────

class _FakeDistributorDatasource extends DistributorDatasource {
  final List<PricingTier> fakeTiers;
  final List<StoreTierAssignment> fakeAssignments;
  final List<({String id, String name})> fakeStores;

  _FakeDistributorDatasource({
    this.fakeTiers = const [],
    this.fakeAssignments = const [],
    this.fakeStores = const [],
  });

  @override
  Future<List<PricingTier>> getPricingTiers() async => fakeTiers;

  @override
  Future<List<StoreTierAssignment>> getStoreTierAssignments() async =>
      fakeAssignments;

  @override
  Future<List<({String id, String name})>> getOrgStores() async => fakeStores;

  @override
  Future<PricingTier> createPricingTier({
    required String name,
    String? nameAr,
    required double discountPercent,
    bool isDefault = false,
    int sortOrder = 0,
  }) async {
    return PricingTier(
      id: 'new-tier',
      orgId: 'org-1',
      name: name,
      nameAr: nameAr,
      discountPercent: discountPercent,
      isDefault: isDefault,
      sortOrder: sortOrder,
      createdAt: DateTime.now(),
    );
  }

  @override
  Future<void> deletePricingTier(String tierId) async {}

  @override
  Future<void> assignStoreToTier({
    required String storeId,
    required String tierId,
  }) async {}

  @override
  Future<void> removeStoreFromTier(String storeId) async {}

  @override
  Future<double> getStoreDiscountPercent(String storeId) async => 0;

  // Override methods needed by providers that auto-fire
  @override
  Future<List<DistributorProduct>> getProducts({
    int limit = 50,
    int offset = 0,
  }) async => [];

  @override
  Future<List<String>> getCategories({int limit = 100}) async => [];
}

// ─── Helpers ─────────────────────────────────────────────────────

Widget _buildTestWidget({
  List<PricingTier> tiers = const [],
  List<StoreTierAssignment> assignments = const [],
  List<({String id, String name})> stores = const [],
}) {
  return ProviderScope(
    overrides: [
      distributorDatasourceProvider.overrideWithValue(
        _FakeDistributorDatasource(
          fakeTiers: tiers,
          fakeAssignments: assignments,
          fakeStores: stores,
        ),
      ),
    ],
    child: MaterialApp(
      title: 'Test',
      theme: AlhaiTheme.light,
      locale: const Locale('ar'),
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: const PricingTiersScreen(),
    ),
  );
}

final _sampleTiers = [
  PricingTier(
    id: 'tier-gold',
    orgId: 'org-1',
    name: 'Gold',
    nameAr: 'ذهبي',
    discountPercent: 15,
    isDefault: true,
    sortOrder: 0,
    createdAt: DateTime(2026, 1, 1),
  ),
  PricingTier(
    id: 'tier-silver',
    orgId: 'org-1',
    name: 'Silver',
    nameAr: 'فضي',
    discountPercent: 10,
    isDefault: false,
    sortOrder: 1,
    createdAt: DateTime(2026, 1, 2),
  ),
  PricingTier(
    id: 'tier-regular',
    orgId: 'org-1',
    name: 'Regular',
    nameAr: 'عادي',
    discountPercent: 0,
    isDefault: false,
    sortOrder: 2,
    createdAt: DateTime(2026, 1, 3),
  ),
];

final _sampleStores = [
  (id: 'store-1', name: 'متجر الأمل'),
  (id: 'store-2', name: 'متجر النور'),
  (id: 'store-3', name: 'متجر السلام'),
];

// ─── Tests ───────────────────────────────────────────────────────

void main() {
  group('PricingTiersScreen', () {
    testWidgets('renders without errors', (tester) async {
      await tester.pumpWidget(_buildTestWidget());
      await tester.pump();
      expect(find.byType(Scaffold), findsWidgets);
    });

    testWidgets('shows AppBar with title', (tester) async {
      await tester.pumpWidget(_buildTestWidget());
      await tester.pump();
      expect(find.text('فئات الأسعار'), findsWidgets);
    });

    testWidgets('has two tabs', (tester) async {
      await tester.pumpWidget(_buildTestWidget());
      await tester.pump();
      expect(find.text('الفئات'), findsOneWidget);
      expect(find.text('تعيين المتاجر'), findsOneWidget);
    });

    testWidgets('shows FAB for creating new tier', (tester) async {
      await tester.pumpWidget(_buildTestWidget());
      await tester.pump();
      expect(find.byType(FloatingActionButton), findsOneWidget);
      expect(find.text('فئة جديدة'), findsOneWidget);
    });

    testWidgets('shows empty state when no tiers exist', (tester) async {
      await tester.pumpWidget(_buildTestWidget());
      await tester.pumpAndSettle();
      expect(find.text('لا يوجد فئات بعد'), findsOneWidget);
    });

    testWidgets('displays tier list with correct data', (tester) async {
      await tester.pumpWidget(_buildTestWidget(tiers: _sampleTiers));
      await tester.pumpAndSettle();

      // Tier names
      expect(find.text('ذهبي'), findsOneWidget);
      expect(find.text('فضي'), findsOneWidget);
      expect(find.text('عادي'), findsOneWidget);

      // Default badge
      expect(find.text('افتراضي'), findsOneWidget);
    });

    testWidgets('shows discount info on tier cards', (tester) async {
      await tester.pumpWidget(_buildTestWidget(tiers: _sampleTiers));
      await tester.pumpAndSettle();

      expect(find.text('خصم 15%'), findsOneWidget);
      expect(find.text('خصم 10%'), findsOneWidget);
      expect(find.text('خصم 0%'), findsOneWidget);
    });

    testWidgets('shows popup menu on tier card', (tester) async {
      await tester.pumpWidget(_buildTestWidget(tiers: _sampleTiers));
      await tester.pumpAndSettle();

      // Find the popup menu icons (more_vert)
      expect(find.byIcon(Icons.more_vert), findsNWidgets(3));
    });

    testWidgets('switching to store assignment tab', (tester) async {
      await tester.pumpWidget(
        _buildTestWidget(tiers: _sampleTiers, stores: _sampleStores),
      );
      await tester.pumpAndSettle();

      // Tap store assignment tab
      await tester.tap(find.text('تعيين المتاجر'));
      await tester.pumpAndSettle();

      // Store names should appear
      expect(find.text('متجر الأمل'), findsOneWidget);
      expect(find.text('متجر النور'), findsOneWidget);
      expect(find.text('متجر السلام'), findsOneWidget);
    });

    testWidgets(
      'store assignment tab shows "create tier first" when no tiers',
      (tester) async {
        await tester.pumpWidget(_buildTestWidget(stores: _sampleStores));
        await tester.pumpAndSettle();

        await tester.tap(find.text('تعيين المتاجر'));
        await tester.pumpAndSettle();

        expect(find.text('أنشئ فئة أولاً'), findsOneWidget);
      },
    );

    testWidgets('store assignment shows dropdowns with tier options', (
      tester,
    ) async {
      await tester.pumpWidget(
        _buildTestWidget(tiers: _sampleTiers, stores: _sampleStores),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('تعيين المتاجر'));
      await tester.pumpAndSettle();

      // Dropdowns should exist
      expect(find.byType(DropdownButtonFormField<String?>), findsNWidgets(3));
    });

    testWidgets('FAB tap opens tier form dialog', (tester) async {
      await tester.pumpWidget(_buildTestWidget(tiers: _sampleTiers));
      await tester.pumpAndSettle();

      await tester.tap(find.text('فئة جديدة'));
      await tester.pumpAndSettle();

      // Dialog should appear with form fields
      expect(find.text('فئة سعرية جديدة'), findsOneWidget);
      expect(find.text('اسم الفئة (إنجليزي) *'), findsOneWidget);
      expect(find.text('اسم الفئة (عربي)'), findsOneWidget);
      expect(find.text('نسبة الخصم (%) *'), findsOneWidget);
      expect(find.text('فئة افتراضية'), findsOneWidget);
    });

    testWidgets('tier form validates required fields', (tester) async {
      await tester.pumpWidget(_buildTestWidget(tiers: _sampleTiers));
      await tester.pumpAndSettle();

      await tester.tap(find.text('فئة جديدة'));
      await tester.pumpAndSettle();

      // Try to submit empty form
      await tester.tap(find.text('إنشاء'));
      await tester.pumpAndSettle();

      // Validation errors
      expect(find.text('مطلوب'), findsWidgets);
    });

    testWidgets('tier form validates discount range', (tester) async {
      await tester.pumpWidget(_buildTestWidget(tiers: _sampleTiers));
      await tester.pumpAndSettle();

      await tester.tap(find.text('فئة جديدة'));
      await tester.pumpAndSettle();

      // Fill name
      await tester.enterText(
        find.widgetWithText(TextFormField, 'اسم الفئة (إنجليزي) *'),
        'Test Tier',
      );

      // Enter invalid discount
      await tester.enterText(
        find.widgetWithText(TextFormField, 'نسبة الخصم (%) *'),
        '150',
      );

      await tester.tap(find.text('إنشاء'));
      await tester.pumpAndSettle();

      expect(find.text('بين 0 و 100'), findsOneWidget);
    });

    testWidgets('tier form cancel closes dialog', (tester) async {
      await tester.pumpWidget(_buildTestWidget(tiers: _sampleTiers));
      await tester.pumpAndSettle();

      await tester.tap(find.text('فئة جديدة'));
      await tester.pumpAndSettle();

      expect(find.text('فئة سعرية جديدة'), findsOneWidget);

      await tester.tap(find.text('إلغاء'));
      await tester.pumpAndSettle();

      expect(find.text('فئة سعرية جديدة'), findsNothing);
    });

    testWidgets('is a ConsumerStatefulWidget', (tester) async {
      await tester.pumpWidget(_buildTestWidget());
      await tester.pump();
      expect(find.byType(PricingTiersScreen), findsOneWidget);
    });
  });
}
