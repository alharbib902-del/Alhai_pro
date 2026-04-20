import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide User;
import 'package:supabase_flutter/supabase_flutter.dart' as supa show User;

import 'package:driver_app/features/auth/data/driver_auth_datasource.dart';

// ---------------------------------------------------------------------------
// Inline fakes for SupabaseClient chain used by updateProfile().
//
// The driver_app datasource awaits builders directly (no .timeout() terminator
// like customer_app) and we can't add a test-only constructor here (hard rule:
// no datasource edits), so mocktail chain-stubbing doesn't fit. We implement
// the minimal fake surface with Future<T> so `await` resolves natively.
// ---------------------------------------------------------------------------

class _FakeSupabaseClient extends Fake implements SupabaseClient {
  _FakeSupabaseClient({
    required this.fakeAuth,
    required this.usersTable,
    required this.driversTable,
  });

  final _FakeAuth fakeAuth;
  final _FakeQueryBuilder usersTable;
  final _FakeQueryBuilder driversTable;

  @override
  GoTrueClient get auth => fakeAuth;

  @override
  SupabaseQueryBuilder from(String table) {
    switch (table) {
      case 'users':
        return usersTable;
      case 'drivers':
        return driversTable;
      default:
        throw StateError('_FakeSupabaseClient: no fake for table "$table"');
    }
  }
}

class _FakeAuth extends Fake implements GoTrueClient {
  _FakeAuth({this.fakeUser});
  final supa.User? fakeUser;

  @override
  supa.User? get currentUser => fakeUser;
}

class _FakeUser extends Fake implements supa.User {
  _FakeUser({required this.id, this.phone});
  @override
  final String id;
  @override
  final String? phone;
}

// ignore: must_be_immutable
class _FakeQueryBuilder extends Fake implements SupabaseQueryBuilder {
  Map<String, dynamic>? selectSingleResult;

  Map<String, dynamic>? capturedUpsertPayload;
  String? capturedUpsertOnConflict;
  final List<Map<String, dynamic>> capturedUpdates = [];

  @override
  PostgrestFilterBuilder<List<Map<String, dynamic>>> update(
    Map<dynamic, dynamic> values, {
    bool defaultToNull = true,
  }) {
    capturedUpdates.add(Map<String, dynamic>.from(values));
    return _FakeAwaitableBuilder();
  }

  @override
  PostgrestFilterBuilder<List<Map<String, dynamic>>> select([
    String columns = '*',
  ]) {
    return _FakeSelectBuilder(singleResult: selectSingleResult);
  }

  @override
  PostgrestFilterBuilder<List<Map<String, dynamic>>> upsert(
    Object values, {
    bool ignoreDuplicates = false,
    bool defaultToNull = true,
    String? onConflict,
  }) {
    if (values is Map) {
      capturedUpsertPayload = Map<String, dynamic>.from(values);
    }
    capturedUpsertOnConflict = onConflict;
    return _FakeAwaitableBuilder();
  }
}

/// Used where the code awaits `builder.eq(...)` directly after update/upsert
/// (no single()). Resolves to an empty list.
class _FakeAwaitableBuilder extends Fake
    implements
        PostgrestFilterBuilder<List<Map<String, dynamic>>>,
        Future<List<Map<String, dynamic>>> {
  Future<List<Map<String, dynamic>>> _resolve() async =>
      <Map<String, dynamic>>[];

  @override
  PostgrestFilterBuilder<List<Map<String, dynamic>>> eq(
    String column,
    Object value,
  ) =>
      this;

  @override
  Stream<List<Map<String, dynamic>>> asStream() => _resolve().asStream();

  @override
  Future<List<Map<String, dynamic>>> catchError(
    Function onError, {
    bool Function(Object)? test,
  }) =>
      _resolve().catchError(onError, test: test);

  @override
  Future<R> then<R>(
    FutureOr<R> Function(List<Map<String, dynamic>>) onValue, {
    Function? onError,
  }) =>
      _resolve().then(onValue, onError: onError);

  @override
  Future<List<Map<String, dynamic>>> timeout(
    Duration timeLimit, {
    FutureOr<List<Map<String, dynamic>>> Function()? onTimeout,
  }) =>
      _resolve().timeout(timeLimit, onTimeout: onTimeout);

  @override
  Future<List<Map<String, dynamic>>> whenComplete(
    FutureOr<void> Function() action,
  ) =>
      _resolve().whenComplete(action);
}

/// Used for `select('store_id').eq(...).single()`. Returns a `_FakeSingleBuilder`
/// configured with the pre-set `singleResult` from the owning `_FakeQueryBuilder`.
class _FakeSelectBuilder extends Fake
    implements
        PostgrestFilterBuilder<List<Map<String, dynamic>>>,
        Future<List<Map<String, dynamic>>> {
  _FakeSelectBuilder({this.singleResult});
  final Map<String, dynamic>? singleResult;

  Future<List<Map<String, dynamic>>> _resolve() async => [
        if (singleResult != null) singleResult!,
      ];

  @override
  PostgrestFilterBuilder<List<Map<String, dynamic>>> eq(
    String column,
    Object value,
  ) =>
      this;

  @override
  PostgrestTransformBuilder<Map<String, dynamic>> single() =>
      _FakeSingleBuilder(singleResult ?? <String, dynamic>{});

  @override
  Stream<List<Map<String, dynamic>>> asStream() => _resolve().asStream();

  @override
  Future<List<Map<String, dynamic>>> catchError(
    Function onError, {
    bool Function(Object)? test,
  }) =>
      _resolve().catchError(onError, test: test);

  @override
  Future<R> then<R>(
    FutureOr<R> Function(List<Map<String, dynamic>>) onValue, {
    Function? onError,
  }) =>
      _resolve().then(onValue, onError: onError);

  @override
  Future<List<Map<String, dynamic>>> timeout(
    Duration timeLimit, {
    FutureOr<List<Map<String, dynamic>>> Function()? onTimeout,
  }) =>
      _resolve().timeout(timeLimit, onTimeout: onTimeout);

  @override
  Future<List<Map<String, dynamic>>> whenComplete(
    FutureOr<void> Function() action,
  ) =>
      _resolve().whenComplete(action);
}

class _FakeSingleBuilder extends Fake
    implements
        PostgrestTransformBuilder<Map<String, dynamic>>,
        Future<Map<String, dynamic>> {
  _FakeSingleBuilder(this.result);
  final Map<String, dynamic> result;

  Future<Map<String, dynamic>> _resolve() async => result;

  @override
  Stream<Map<String, dynamic>> asStream() => _resolve().asStream();

  @override
  Future<Map<String, dynamic>> catchError(
    Function onError, {
    bool Function(Object)? test,
  }) =>
      _resolve().catchError(onError, test: test);

  @override
  Future<R> then<R>(
    FutureOr<R> Function(Map<String, dynamic>) onValue, {
    Function? onError,
  }) =>
      _resolve().then(onValue, onError: onError);

  @override
  Future<Map<String, dynamic>> timeout(
    Duration timeLimit, {
    FutureOr<Map<String, dynamic>> Function()? onTimeout,
  }) =>
      _resolve().timeout(timeLimit, onTimeout: onTimeout);

  @override
  Future<Map<String, dynamic>> whenComplete(
    FutureOr<void> Function() action,
  ) =>
      _resolve().whenComplete(action);
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  const userId = 'user-abc';
  const phone = '+966555123456';
  const storeId = 'store-123';

  late _FakeQueryBuilder usersTable;
  late _FakeQueryBuilder driversTable;
  late DriverAuthDatasource sut;

  setUp(() {
    usersTable = _FakeQueryBuilder();
    driversTable = _FakeQueryBuilder();
    final client = _FakeSupabaseClient(
      fakeAuth: _FakeAuth(fakeUser: _FakeUser(id: userId, phone: phone)),
      usersTable: usersTable,
      driversTable: driversTable,
    );
    sut = DriverAuthDatasource(client);
  });

  group('DriverAuthDatasource.updateProfile — drivers S-1 store_id closure', () {
    test(
      'happy path: fetches users.store_id and includes it in drivers upsert',
      () async {
        usersTable.selectSingleResult = {'store_id': storeId};

        await sut.updateProfile(vehicleType: 'motorcycle');

        expect(driversTable.capturedUpsertPayload, isNotNull);
        final payload = driversTable.capturedUpsertPayload!;
        expect(payload['store_id'], storeId);
        expect(payload['id'], userId);
        expect(payload['vehicle_type'], 'motorcycle');
        expect(driversTable.capturedUpsertOnConflict, 'id');
      },
    );

    test(
      'null store_id throws Arabic "السائق غير مرتبط بمتجر" and skips drivers upsert',
      () async {
        usersTable.selectSingleResult = {'store_id': null};

        await expectLater(
          sut.updateProfile(vehicleType: 'car'),
          throwsA(
            isA<Exception>().having(
              (e) => e.toString(),
              'message',
              contains('السائق غير مرتبط بمتجر'),
            ),
          ),
        );

        expect(driversTable.capturedUpsertPayload, isNull);
      },
    );

    test(
      'empty store_id throws same Arabic exception and skips drivers upsert',
      () async {
        usersTable.selectSingleResult = {'store_id': ''};

        await expectLater(
          sut.updateProfile(vehiclePlate: 'ABC-123'),
          throwsA(
            isA<Exception>().having(
              (e) => e.toString(),
              'message',
              contains('السائق غير مرتبط بمتجر'),
            ),
          ),
        );

        expect(driversTable.capturedUpsertPayload, isNull);
      },
    );

    test(
      'multiple vehicle fields: both vehicle_type and vehicle_plate present with store_id',
      () async {
        usersTable.selectSingleResult = {'store_id': storeId};

        await sut.updateProfile(
          name: 'أحمد',
          vehicleType: 'truck',
          vehiclePlate: 'XYZ-789',
        );

        final payload = driversTable.capturedUpsertPayload;
        expect(payload, isNotNull);
        expect(payload!['store_id'], storeId);
        expect(payload['id'], userId);
        expect(payload['phone'], phone);
        expect(payload['name'], 'أحمد');
        expect(payload['vehicle_type'], 'truck');
        expect(payload['vehicle_plate'], 'XYZ-789');
      },
    );
  });
}
