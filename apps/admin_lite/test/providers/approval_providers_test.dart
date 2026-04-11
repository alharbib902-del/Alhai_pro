/// Tests for Approval Providers
///
/// Covers pendingRefundsProvider, pendingApprovalsCountProvider,
/// approvalFilterProvider, approveRefund, and rejectRefund.
library;

import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:alhai_database/alhai_database.dart';
import 'package:alhai_shared_ui/alhai_shared_ui.dart';

import 'package:admin_lite/providers/approval_providers.dart';
import '../helpers/mock_database.dart';
import '../helpers/mock_providers.dart';
import '../helpers/test_helpers.dart';
import '../helpers/test_factories.dart';

// =============================================================================
// MOCKS FOR DRIFT customSelect/customStatement
// =============================================================================

class MockSelectable extends Mock implements Selectable<QueryRow> {}

class FakeQueryRow extends Fake implements QueryRow {
  final Map<String, dynamic> _data;
  FakeQueryRow(this._data);

  @override
  Map<String, dynamic> get data => _data;
}

void main() {
  setUpAll(() {
    registerLiteFallbackValues();
    registerFallbackValue(AuditAction.login);
    registerFallbackValue(<Variable>[]);
  });

  late MockAppDatabase db;
  late MockReturnsDao returnsDao;
  late MockAuditLogDao auditLogDao;

  setUp(() {
    returnsDao = MockReturnsDao();
    auditLogDao = MockAuditLogDao();
    db = setupMockDatabase(returnsDao: returnsDao, auditLogDao: auditLogDao);
  });

  tearDown(() => tearDownTestGetIt());

  // ===========================================================================
  // approvalFilterProvider
  // ===========================================================================

  group('approvalFilterProvider', () {
    test('defaults to ApprovalFilter.all', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final filter = container.read(approvalFilterProvider);

      expect(filter, ApprovalFilter.all);
    });

    test('can be updated to pending', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      container.read(approvalFilterProvider.notifier).state =
          ApprovalFilter.pending;

      expect(container.read(approvalFilterProvider), ApprovalFilter.pending);
    });
  });

  // ===========================================================================
  // pendingRefundsProvider
  // ===========================================================================

  group('pendingRefundsProvider', () {
    test('returns empty list when storeId is null', () async {
      setupTestGetIt(mockDb: db);
      final container = ProviderContainer(
        overrides: [currentStoreIdProvider.overrideWith((ref) => null)],
      );
      addTearDown(container.dispose);

      final result = await container.read(pendingRefundsProvider.future);

      expect(result, isEmpty);
    });

    test('returns all returns when filter is all', () async {
      final returns = [
        createTestReturn(id: 'r1', status: 'pending'),
        createTestReturn(id: 'r2', status: 'approved'),
        createTestReturn(id: 'r3', status: 'rejected'),
      ];

      when(
        () => returnsDao.getAllReturns(any()),
      ).thenAnswer((_) async => returns);

      setupTestGetIt(mockDb: db);
      final container = ProviderContainer(
        overrides: [...defaultProviderOverrides(storeId: 'test-store-1')],
      );
      addTearDown(container.dispose);

      final result = await container.read(pendingRefundsProvider.future);

      expect(result.length, 3);
    });

    test('filters to pending only when filter is pending', () async {
      final pendingReturns = [
        createTestReturn(id: 'r1', status: 'pending'),
        createTestReturn(id: 'r4', status: 'pending'),
      ];

      when(
        () => returnsDao.getReturnsByStatus(any(), any()),
      ).thenAnswer((_) async => pendingReturns);

      setupTestGetIt(mockDb: db);
      final container = ProviderContainer(
        overrides: [
          ...defaultProviderOverrides(storeId: 'test-store-1'),
          approvalFilterProvider.overrideWith((ref) => ApprovalFilter.pending),
        ],
      );
      addTearDown(container.dispose);

      final result = await container.read(pendingRefundsProvider.future);

      expect(result.length, 2);
      expect(result.every((r) => r.status == 'pending'), isTrue);
    });

    test('filters to approved when filter is approved', () async {
      final approvedReturns = [
        createTestReturn(id: 'r2', status: 'approved'),
        createTestReturn(id: 'r3', status: 'completed'),
      ];

      when(
        () => returnsDao.getReturnsByStatuses(any(), any()),
      ).thenAnswer((_) async => approvedReturns);

      setupTestGetIt(mockDb: db);
      final container = ProviderContainer(
        overrides: [
          ...defaultProviderOverrides(storeId: 'test-store-1'),
          approvalFilterProvider.overrideWith((ref) => ApprovalFilter.approved),
        ],
      );
      addTearDown(container.dispose);

      final result = await container.read(pendingRefundsProvider.future);

      // approved + completed both match the 'approved' filter
      expect(result.length, 2);
    });

    test('filters to rejected when filter is rejected', () async {
      final rejectedReturns = [createTestReturn(id: 'r2', status: 'rejected')];

      when(
        () => returnsDao.getReturnsByStatus(any(), any()),
      ).thenAnswer((_) async => rejectedReturns);

      setupTestGetIt(mockDb: db);
      final container = ProviderContainer(
        overrides: [
          ...defaultProviderOverrides(storeId: 'test-store-1'),
          approvalFilterProvider.overrideWith((ref) => ApprovalFilter.rejected),
        ],
      );
      addTearDown(container.dispose);

      final result = await container.read(pendingRefundsProvider.future);

      expect(result.length, 1);
      expect(result.first.status, 'rejected');
    });
  });

  // ===========================================================================
  // pendingApprovalsCountProvider
  // ===========================================================================

  group('pendingApprovalsCountProvider', () {
    test('returns 0 when storeId is null', () async {
      setupTestGetIt(mockDb: db);
      final container = ProviderContainer(
        overrides: [currentStoreIdProvider.overrideWith((ref) => null)],
      );
      addTearDown(container.dispose);

      final result = await container.read(pendingApprovalsCountProvider.future);

      expect(result, 0);
    });

    test('returns count from database query', () async {
      final selectable = MockSelectable();
      when(
        () => db.customSelect(any(), variables: any(named: 'variables')),
      ).thenReturn(selectable);
      when(
        () => selectable.getSingle(),
      ).thenAnswer((_) async => FakeQueryRow({'count': 5}));

      setupTestGetIt(mockDb: db);
      final container = ProviderContainer(
        overrides: [...defaultProviderOverrides(storeId: 'test-store-1')],
      );
      addTearDown(container.dispose);

      final result = await container.read(pendingApprovalsCountProvider.future);

      expect(result, 5);
    });

    test('returns 0 when database query throws', () async {
      final selectable = MockSelectable();
      when(
        () => db.customSelect(any(), variables: any(named: 'variables')),
      ).thenReturn(selectable);
      when(() => selectable.getSingle()).thenThrow(Exception('DB error'));

      setupTestGetIt(mockDb: db);
      final container = ProviderContainer(
        overrides: [...defaultProviderOverrides(storeId: 'test-store-1')],
      );
      addTearDown(container.dispose);

      final result = await container.read(pendingApprovalsCountProvider.future);

      expect(result, 0);
    });
  });

  // ===========================================================================
  // approveRefund / rejectRefund
  // ===========================================================================

  group('approveRefund', () {
    test('returns true on success', () async {
      when(() => db.customStatement(any(), any())).thenAnswer((_) async {});
      when(
        () => auditLogDao.log(
          storeId: any(named: 'storeId'),
          userId: any(named: 'userId'),
          userName: any(named: 'userName'),
          action: any(named: 'action'),
          entityType: any(named: 'entityType'),
          entityId: any(named: 'entityId'),
          description: any(named: 'description'),
        ),
      ).thenAnswer((_) async => 1);

      setupTestGetIt(mockDb: db);

      final result = await approveRefund(
        returnId: 'ret-1',
        storeId: 'test-store-1',
        userId: 'user-1',
        userName: 'Admin',
      );

      expect(result, isTrue);
    });

    test('returns false when database throws', () async {
      // Create fresh mocks to avoid matcher leak from previous test
      final freshAuditLogDao = MockAuditLogDao();
      final freshDb = setupMockDatabase(auditLogDao: freshAuditLogDao);

      when(
        () => freshDb.customStatement(any(), any()),
      ).thenThrow(Exception('DB error'));

      setupTestGetIt(mockDb: freshDb);

      final result = await approveRefund(
        returnId: 'ret-1',
        storeId: 'test-store-1',
        userId: 'user-1',
        userName: 'Admin',
      );

      expect(result, isFalse);
    });
  });

  group('rejectRefund', () {
    test('returns true on success', () async {
      when(() => db.customStatement(any(), any())).thenAnswer((_) async {});
      when(
        () => auditLogDao.log(
          storeId: any(named: 'storeId'),
          userId: any(named: 'userId'),
          userName: any(named: 'userName'),
          action: any(named: 'action'),
          entityType: any(named: 'entityType'),
          entityId: any(named: 'entityId'),
          description: any(named: 'description'),
        ),
      ).thenAnswer((_) async => 1);

      setupTestGetIt(mockDb: db);

      final result = await rejectRefund(
        returnId: 'ret-1',
        storeId: 'test-store-1',
        userId: 'user-1',
        userName: 'Admin',
        reason: 'Invalid return',
      );

      expect(result, isTrue);
    });

    test('returns false when database throws', () async {
      // Create fresh mocks to avoid matcher leak from previous test
      final freshAuditLogDao = MockAuditLogDao();
      final freshDb = setupMockDatabase(auditLogDao: freshAuditLogDao);

      when(
        () => freshDb.customStatement(any(), any()),
      ).thenThrow(Exception('DB error'));

      setupTestGetIt(mockDb: freshDb);

      final result = await rejectRefund(
        returnId: 'ret-1',
        storeId: 'test-store-1',
        userId: 'user-1',
        userName: 'Admin',
      );

      expect(result, isFalse);
    });
  });
}
