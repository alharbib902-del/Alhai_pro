/// Unit tests for shifts providers
///
/// Tests: provider definitions and data flow
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';
import 'package:get_it/get_it.dart';

import 'package:alhai_database/alhai_database.dart';
import 'package:alhai_shared_ui/alhai_shared_ui.dart';

// ---------------------------------------------------------------------------
// Mocks
// ---------------------------------------------------------------------------

class MockAppDatabase extends Mock implements AppDatabase {}

class MockShiftsDao extends Mock implements ShiftsDao {}

class MockAuditLogDao extends Mock implements AuditLogDao {}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  late MockAppDatabase mockDb;
  late MockShiftsDao mockShiftsDao;
  late MockAuditLogDao mockAuditLogDao;

  setUp(() {
    mockDb = MockAppDatabase();
    mockShiftsDao = MockShiftsDao();
    mockAuditLogDao = MockAuditLogDao();

    when(() => mockDb.shiftsDao).thenReturn(mockShiftsDao);
    when(() => mockDb.auditLogDao).thenReturn(mockAuditLogDao);

    final getIt = GetIt.instance;
    if (getIt.isRegistered<AppDatabase>()) {
      getIt.unregister<AppDatabase>();
    }
    getIt.registerSingleton<AppDatabase>(mockDb);
  });

  tearDown(() {
    final getIt = GetIt.instance;
    if (getIt.isRegistered<AppDatabase>()) {
      getIt.unregister<AppDatabase>();
    }
  });

  group('openShiftProvider', () {
    test('returns null when no store id', () async {
      final container = ProviderContainer(overrides: [
        currentStoreIdProvider.overrideWith((ref) => null),
      ]);
      addTearDown(container.dispose);

      final result = await container.read(openShiftProvider.future);
      expect(result, isNull);
    });

    test('returns shift from dao', () async {
      when(() => mockShiftsDao.getAnyOpenShift('store-1'))
          .thenAnswer((_) async => null);

      final container = ProviderContainer(overrides: [
        currentStoreIdProvider.overrideWith((ref) => 'store-1'),
      ]);
      addTearDown(container.dispose);

      final result = await container.read(openShiftProvider.future);
      expect(result, isNull);
    });
  });

  group('todayShiftsProvider', () {
    test('returns empty list when no store id', () async {
      final container = ProviderContainer(overrides: [
        currentStoreIdProvider.overrideWith((ref) => null),
      ]);
      addTearDown(container.dispose);

      final result = await container.read(todayShiftsProvider.future);
      expect(result, isEmpty);
    });

    test('returns shifts from dao', () async {
      when(() => mockShiftsDao.getTodayShifts('store-1'))
          .thenAnswer((_) async => []);

      final container = ProviderContainer(overrides: [
        currentStoreIdProvider.overrideWith((ref) => 'store-1'),
      ]);
      addTearDown(container.dispose);

      final result = await container.read(todayShiftsProvider.future);
      expect(result, isEmpty);
    });
  });

  group('shiftMovementsProvider', () {
    test('returns movements for shift', () async {
      when(() => mockShiftsDao.getShiftMovements('shift-1'))
          .thenAnswer((_) async => []);

      final container = ProviderContainer(overrides: [
        currentStoreIdProvider.overrideWith((ref) => 'store-1'),
      ]);
      addTearDown(container.dispose);

      final result =
          await container.read(shiftMovementsProvider('shift-1').future);
      expect(result, isEmpty);
    });
  });
}
