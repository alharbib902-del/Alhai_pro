/// Tests for Lite Dashboard Providers
///
/// Covers liteStatsProvider and recentActivityProvider.
library;

import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:alhai_database/alhai_database.dart';
import 'package:alhai_shared_ui/alhai_shared_ui.dart';

import 'package:admin_lite/providers/lite_dashboard_providers.dart';
import '../helpers/mock_database.dart';
import '../helpers/mock_providers.dart';
import '../helpers/test_helpers.dart';
import '../helpers/test_factories.dart';

// =============================================================================
// MOCKS FOR DRIFT customSelect
// =============================================================================

class MockSelectable extends Mock implements Selectable<QueryRow> {}

class FakeQueryRow extends Fake implements QueryRow {
  final Map<String, dynamic> _data;
  FakeQueryRow(this._data);

  @override
  Map<String, dynamic> get data => _data;
}

void main() {
  setUpAll(() => registerLiteFallbackValues());

  late MockAppDatabase db;
  late MockSalesDao salesDao;
  late MockProductsDao productsDao;
  late MockOrdersDao ordersDao;
  late MockShiftsDao shiftsDao;
  late MockAuditLogDao auditLogDao;

  setUp(() {
    salesDao = MockSalesDao();
    productsDao = MockProductsDao();
    ordersDao = MockOrdersDao();
    shiftsDao = MockShiftsDao();
    auditLogDao = MockAuditLogDao();
    db = setupMockDatabase(
      salesDao: salesDao,
      productsDao: productsDao,
      ordersDao: ordersDao,
      shiftsDao: shiftsDao,
      auditLogDao: auditLogDao,
    );
  });

  tearDown(() => tearDownTestGetIt());

  // ===========================================================================
  // liteStatsProvider
  // ===========================================================================

  group('liteStatsProvider', () {
    test('returns default LiteStatsData when storeId is null', () async {
      setupTestGetIt(mockDb: db);
      final container = ProviderContainer(
        overrides: [currentStoreIdProvider.overrideWith((ref) => null)],
      );
      addTearDown(container.dispose);

      final result = await container.read(liteStatsProvider.future);

      expect(result.pendingApprovals, 0);
      expect(result.todaySales, 0);
      expect(result.lowStockCount, 0);
      expect(result.activeShifts, 0);
      expect(result.todayOrders, 0);
      expect(result.salesChangePercent, 0);
    });

    test('returns stats with correct values from DAOs', () async {
      // Stub pending approvals (customSelect)
      final pendingSelectable = MockSelectable();
      when(
        () => db.customSelect(any(), variables: any(named: 'variables')),
      ).thenReturn(pendingSelectable);
      when(
        () => pendingSelectable.getSingle(),
      ).thenAnswer((_) async => FakeQueryRow({'count': 3}));

      // Stub today's sales stats
      when(
        () => salesDao.getSalesStats(
          any(),
          startDate: any(named: 'startDate'),
          endDate: any(named: 'endDate'),
        ),
      ).thenAnswer(
        (_) async => const SalesStats(
          count: 12,
          total: 1500.0,
          average: 125.0,
          maxSale: 300.0,
          minSale: 50.0,
        ),
      );

      // Stub low stock products
      when(() => productsDao.getLowStockProducts(any())).thenAnswer(
        (_) async => [
          createTestProduct(id: 'p1'),
          createTestProduct(id: 'p2'),
          createTestProduct(id: 'p3'),
        ],
      );

      setupTestGetIt(mockDb: db);
      final container = ProviderContainer(
        overrides: [...defaultProviderOverrides(storeId: 'test-store-1')],
      );
      addTearDown(container.dispose);

      final result = await container.read(liteStatsProvider.future);

      expect(result.lowStockCount, 3);
      expect(result.todayOrders, 12);
      expect(result.todaySales, 1500.0);
    });

    test('calculates sales change percent correctly', () async {
      final pendingSelectable = MockSelectable();
      when(
        () => db.customSelect(any(), variables: any(named: 'variables')),
      ).thenReturn(pendingSelectable);
      when(
        () => pendingSelectable.getSingle(),
      ).thenAnswer((_) async => FakeQueryRow({'count': 0}));

      // Yesterday: 1000, Today: 1500 => change = 50%
      var callCount = 0;
      when(
        () => salesDao.getSalesStats(
          any(),
          startDate: any(named: 'startDate'),
          endDate: any(named: 'endDate'),
        ),
      ).thenAnswer((_) async {
        callCount++;
        if (callCount == 1) {
          // Today's stats
          return const SalesStats(
            count: 10,
            total: 1500.0,
            average: 150.0,
            maxSale: 300.0,
            minSale: 50.0,
          );
        } else {
          // Yesterday's stats
          return const SalesStats(
            count: 8,
            total: 1000.0,
            average: 125.0,
            maxSale: 200.0,
            minSale: 30.0,
          );
        }
      });

      when(
        () => productsDao.getLowStockProducts(any()),
      ).thenAnswer((_) async => []);

      setupTestGetIt(mockDb: db);
      final container = ProviderContainer(
        overrides: [...defaultProviderOverrides(storeId: 'test-store-1')],
      );
      addTearDown(container.dispose);

      final result = await container.read(liteStatsProvider.future);

      expect(result.salesChangePercent, 50.0);
    });

    test(
      'sales change is 100% when yesterday is 0 but today has sales',
      () async {
        final pendingSelectable = MockSelectable();
        when(
          () => db.customSelect(any(), variables: any(named: 'variables')),
        ).thenReturn(pendingSelectable);
        when(
          () => pendingSelectable.getSingle(),
        ).thenAnswer((_) async => FakeQueryRow({'count': 0}));

        var callCount = 0;
        when(
          () => salesDao.getSalesStats(
            any(),
            startDate: any(named: 'startDate'),
            endDate: any(named: 'endDate'),
          ),
        ).thenAnswer((_) async {
          callCount++;
          if (callCount == 1) {
            return const SalesStats(
              count: 5,
              total: 500.0,
              average: 100.0,
              maxSale: 200.0,
              minSale: 50.0,
            );
          } else {
            return const SalesStats(
              count: 0,
              total: 0,
              average: 0,
              maxSale: 0,
              minSale: 0,
            );
          }
        });

        when(
          () => productsDao.getLowStockProducts(any()),
        ).thenAnswer((_) async => []);

        setupTestGetIt(mockDb: db);
        final container = ProviderContainer(
          overrides: [...defaultProviderOverrides(storeId: 'test-store-1')],
        );
        addTearDown(container.dispose);

        final result = await container.read(liteStatsProvider.future);

        expect(result.salesChangePercent, 100.0);
      },
    );

    test('sales change is 0% when both days have zero sales', () async {
      final pendingSelectable = MockSelectable();
      when(
        () => db.customSelect(any(), variables: any(named: 'variables')),
      ).thenReturn(pendingSelectable);
      when(
        () => pendingSelectable.getSingle(),
      ).thenAnswer((_) async => FakeQueryRow({'count': 0}));

      when(
        () => salesDao.getSalesStats(
          any(),
          startDate: any(named: 'startDate'),
          endDate: any(named: 'endDate'),
        ),
      ).thenAnswer(
        (_) async => const SalesStats(
          count: 0,
          total: 0,
          average: 0,
          maxSale: 0,
          minSale: 0,
        ),
      );

      when(
        () => productsDao.getLowStockProducts(any()),
      ).thenAnswer((_) async => []);

      setupTestGetIt(mockDb: db);
      final container = ProviderContainer(
        overrides: [...defaultProviderOverrides(storeId: 'test-store-1')],
      );
      addTearDown(container.dispose);

      final result = await container.read(liteStatsProvider.future);

      expect(result.salesChangePercent, 0);
    });
  });

  // ===========================================================================
  // recentActivityProvider
  // ===========================================================================

  group('recentActivityProvider', () {
    test('returns empty list when storeId is null', () async {
      setupTestGetIt(mockDb: db);
      final container = ProviderContainer(
        overrides: [currentStoreIdProvider.overrideWith((ref) => null)],
      );
      addTearDown(container.dispose);

      final result = await container.read(recentActivityProvider.future);

      expect(result, isEmpty);
    });

    test('returns activities mapped from audit log', () async {
      final logs = [
        createTestAuditLog(
          id: 'log-1',
          action: 'saleCreate',
          description: 'Created sale',
        ),
        createTestAuditLog(
          id: 'log-2',
          action: 'login',
          description: 'User logged in',
        ),
      ];

      when(
        () => auditLogDao.getLogs(any(), limit: any(named: 'limit')),
      ).thenAnswer((_) async => logs);

      setupTestGetIt(mockDb: db);
      final container = ProviderContainer(
        overrides: [...defaultProviderOverrides(storeId: 'test-store-1')],
      );
      addTearDown(container.dispose);

      final result = await container.read(recentActivityProvider.future);

      expect(result.length, 2);
      expect(result[0].id, 'log-1');
      expect(result[0].action, 'saleCreate');
      expect(result[0].description, 'Created sale');
      expect(result[1].id, 'log-2');
    });

    test('returns empty list when audit log throws', () async {
      when(
        () => auditLogDao.getLogs(any(), limit: any(named: 'limit')),
      ).thenThrow(Exception('Database error'));

      setupTestGetIt(mockDb: db);
      final container = ProviderContainer(
        overrides: [...defaultProviderOverrides(storeId: 'test-store-1')],
      );
      addTearDown(container.dispose);

      final result = await container.read(recentActivityProvider.future);

      expect(result, isEmpty);
    });

    test(
      'maps all fields correctly from AuditLogTableData to ActivityEntry',
      () async {
        final timestamp = DateTime(2026, 2, 20, 10, 30);
        final logs = [
          createTestAuditLog(
            id: 'log-x',
            userName: 'Ahmed',
            action: 'productEdit',
            description: 'Edited product price',
            createdAt: timestamp,
          ),
        ];

        when(
          () => auditLogDao.getLogs(any(), limit: any(named: 'limit')),
        ).thenAnswer((_) async => logs);

        setupTestGetIt(mockDb: db);
        final container = ProviderContainer(
          overrides: [...defaultProviderOverrides(storeId: 'test-store-1')],
        );
        addTearDown(container.dispose);

        final result = await container.read(recentActivityProvider.future);

        expect(result.length, 1);
        final activity = result.first;
        expect(activity.id, 'log-x');
        expect(activity.userName, 'Ahmed');
        expect(activity.action, 'productEdit');
        expect(activity.description, 'Edited product price');
        expect(activity.timestamp, timestamp);
      },
    );
  });

  // ===========================================================================
  // Data model tests
  // ===========================================================================

  group('LiteStatsData', () {
    test('has correct default values', () {
      const stats = LiteStatsData();
      expect(stats.pendingApprovals, 0);
      expect(stats.todaySales, 0);
      expect(stats.lowStockCount, 0);
      expect(stats.activeShifts, 0);
      expect(stats.todayOrders, 0);
      expect(stats.salesChangePercent, 0);
    });
  });

  group('ActivityEntry', () {
    test('stores all fields correctly', () {
      final timestamp = DateTime(2026, 1, 15, 14, 30);
      final entry = ActivityEntry(
        id: 'a1',
        userName: 'Test User',
        action: 'saleCreate',
        description: 'Created a sale',
        timestamp: timestamp,
      );
      expect(entry.id, 'a1');
      expect(entry.userName, 'Test User');
      expect(entry.action, 'saleCreate');
      expect(entry.description, 'Created a sale');
      expect(entry.timestamp, timestamp);
    });

    test('description can be null', () {
      final entry = ActivityEntry(
        id: 'a2',
        userName: 'User',
        action: 'login',
        timestamp: DateTime.now(),
      );
      expect(entry.description, isNull);
    });
  });
}
