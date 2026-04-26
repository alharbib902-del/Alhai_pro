/// P0-1 (round 2) regression tests for the manager-approval security
/// flow. These prove the fix to the gap that round 1 left behind:
/// device-PIN ownership alone is NOT sufficient to grant approval —
/// the entered PIN must also identify a store user with a managerial
/// role.
///
/// Two test groups:
///
/// 1. **isAuthorizedManagerRole** — pure unit tests covering every
///    role string + the case-insensitive normalisation contract.
///    Fast, no I/O, no driver setup.
///
/// 2. **End-to-end approval flow** — drives the keypad with a real
///    AppDatabase + real PinService (backed by InMemoryStorage) and
///    asserts that:
///      a) lockout still triggers after 5 wrong PINs
///      b) right device PIN + no DB user → REJECT, no audit row
///      c) right device PIN + cashier DB user → REJECT, no audit row
///      d) right device PIN + manager DB user → ACCEPT, audit row
///         participates in the hash chain (verifyChain returns null)
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_it/get_it.dart';
import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';

import 'package:alhai_auth/alhai_auth.dart';
import 'package:alhai_auth/src/screens/manager_approval_screen.dart'
    show isAuthorizedManagerRole, kManagerRoles;
import 'package:alhai_database/alhai_database.dart';
import 'package:alhai_l10n/alhai_l10n.dart';

void main() {
  // ─── 1. Pure helper unit tests ──────────────────────────────────
  group('isAuthorizedManagerRole', () {
    test('returns true for every documented manager role', () {
      // Fail loudly if someone narrows kManagerRoles in the future
      // without realising every role here is a real production value
      // we ship for. Iterating the constant + asserting against the
      // helper means the contract stays in lockstep.
      for (final role in kManagerRoles) {
        expect(
          isAuthorizedManagerRole(role),
          isTrue,
          reason: 'role "$role" is in kManagerRoles but the helper rejected it',
        );
      }
    });

    test('case-insensitive: "ADMIN", "Admin", "admin" all pass', () {
      expect(isAuthorizedManagerRole('ADMIN'), isTrue);
      expect(isAuthorizedManagerRole('Admin'), isTrue);
      expect(isAuthorizedManagerRole('admin'), isTrue);
      expect(isAuthorizedManagerRole('STORE_OWNER'), isTrue);
      expect(isAuthorizedManagerRole('Store_Owner'), isTrue);
    });

    test('rejects cashier / employee / null / empty / unknown roles', () {
      expect(isAuthorizedManagerRole('cashier'), isFalse);
      expect(isAuthorizedManagerRole('employee'), isFalse);
      expect(isAuthorizedManagerRole('staff'), isFalse);
      expect(isAuthorizedManagerRole(''), isFalse);
      expect(isAuthorizedManagerRole(null), isFalse);
      expect(isAuthorizedManagerRole('manage'), isFalse,
          reason: 'partial match must not authorise');
    });
  });

  // ─── 2. End-to-end approval flow ────────────────────────────────
  //
  // Each testWidgets sets up:
  //   - A fresh in-memory AppDatabase, registered in GetIt so the
  //     screen's `getIt<AppDatabase>()` returns it.
  //   - A fresh InMemoryStorage seeded with a known PIN (PIN '1234')
  //     via `PinService.createPin`.
  //   - A ProviderScope override that pins `currentStoreIdProvider`
  //     to 'store-1' so the screen's storeId lookup succeeds.
  //
  // Then it pumps the screen, taps the keypad to enter '1234', and
  // checks the audit table to see whether an approval row was
  // written. The audit row's hash-chain participation is verified
  // via `auditLogDao.verifyChain` (returns null = chain intact).
  group('end-to-end approval flow', () {
    late AppDatabase db;
    late InMemoryStorage storage;

    Future<void> seedUser({
      required String id,
      required String name,
      required String pin,
      required String role,
    }) async {
      await db.usersDao.insertUser(
        UsersTableCompanion.insert(
          id: id,
          name: name,
          storeId: const Value('store-1'),
          email: const Value('test@test.com'),
          phone: const Value('0500000000'),
          role: Value(role),
          pin: Value(pin),
          isActive: const Value(true),
          createdAt: DateTime(2025, 1, 1),
        ),
      );
    }

    setUp(() async {
      // Fresh DB per test so audit chain state doesn't leak across.
      db = AppDatabase.forTesting(NativeDatabase.memory());
      // Seed the store row that users + audit reference via FK.
      await db.storesDao.insertStore(
        StoresTableCompanion.insert(
          id: 'store-1',
          name: 'Test Store',
          createdAt: DateTime(2025, 1, 1),
        ),
      );
      // Re-register the GetIt binding the screen reads.
      if (GetIt.I.isRegistered<AppDatabase>()) {
        await GetIt.I.unregister<AppDatabase>();
      }
      GetIt.I.registerSingleton<AppDatabase>(db);

      // Fresh PinService backing storage. createPin sets the device
      // PIN to '1234' using the current PBKDF2 v2 scheme.
      storage = InMemoryStorage();
      SecureStorageService.setStorage(storage);
      await PinService.createPin('1234');
    });

    tearDown(() async {
      if (GetIt.I.isRegistered<AppDatabase>()) {
        await GetIt.I.unregister<AppDatabase>();
      }
      SecureStorageService.resetStorage();
      await db.close();
    });

    Widget buildScreen() {
      return ProviderScope(
        overrides: [
          currentStoreIdProvider.overrideWith((ref) => 'store-1'),
        ],
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('ar'),
          home: const ManagerApprovalScreen(
            mode: ManagerApprovalMode.verify,
            action: 'void_sale',
          ),
        ),
      );
    }

    Future<void> tapDigit(WidgetTester tester, String digit) async {
      // The keypad uses _KeypadButton (private), but each digit's
      // label text is unique enough to find by text.
      final textFinder = find.text(digit);
      expect(textFinder, findsWidgets,
          reason: 'digit "$digit" not found on keypad');
      await tester.tap(textFinder.first);
      await tester.pump();
    }

    Future<void> enterPin(WidgetTester tester, String pin) async {
      for (final char in pin.split('')) {
        await tapDigit(tester, char);
      }
      // Allow the async _verifyPin to settle.
      await tester.pumpAndSettle(const Duration(milliseconds: 500));
    }

    testWidgets(
      'a) right device PIN but NO matching DB user → REJECT, no audit',
      (tester) async {
        // No user seeded. PinService accepts '1234' (we created it in
        // setUp). The flow must fail at the DB-lookup gate.
        await tester.pumpWidget(buildScreen());
        await tester.pumpAndSettle();

        await enterPin(tester, '1234');

        final logs = await db.auditLogDao.getLogs('store-1');
        expect(
          logs,
          isEmpty,
          reason:
              'PinService verified the device PIN but no DB user exists — '
              'the screen MUST NOT write an approval row',
        );
      },
    );

    testWidgets(
      'b) right device PIN + cashier DB user → REJECT, no audit',
      (tester) async {
        // Cashier with the same PIN as the device. Even though gates
        // 1 + 2 (DB lookup) pass, gate 3 (role check) must reject.
        await seedUser(
          id: 'user-cashier',
          name: 'كاشير 1',
          pin: '1234',
          role: 'cashier',
        );

        await tester.pumpWidget(buildScreen());
        await tester.pumpAndSettle();

        await enterPin(tester, '1234');

        final logs = await db.auditLogDao.getLogs('store-1');
        expect(
          logs,
          isEmpty,
          reason:
              'a cashier knowing the device PIN must NOT be able to grant '
              'manager approval',
        );
      },
    );

    testWidgets(
      'c) right device PIN + manager DB user → ACCEPT + hash-chained audit',
      (tester) async {
        await seedUser(
          id: 'user-manager',
          name: 'مدير المتجر',
          pin: '1234',
          role: 'manager',
        );

        await tester.pumpWidget(buildScreen());
        await tester.pumpAndSettle();

        await enterPin(tester, '1234');

        // Approval audit row exists, attributed to the matched manager.
        final logs = await db.auditLogDao.getLogs('store-1');
        expect(logs, hasLength(1));
        expect(logs.first.userId, 'user-manager');
        expect(logs.first.userName, 'مدير المتجر');
        expect(logs.first.action, AuditAction.settingsChange.name);

        // And it participates in the hash chain.
        final brokenId = await db.auditLogDao.verifyChain(storeId: 'store-1');
        expect(
          brokenId,
          isNull,
          reason:
              'approval row must be written via appendLogWithHashChain — '
              'verifyChain returning a non-null id means the row was '
              'inserted via the legacy log() path that bypasses __meta__',
        );
      },
    );

    testWidgets(
      'd) when PinService is already locked out, screen rejects + no audit',
      (tester) async {
        // Seed a manager — proves the lockout gate runs INDEPENDENTLY
        // of the DB authorization gate. A real attacker who knows the
        // store has a manager record (and the device PIN!) still can't
        // get past the rate limiter once it has fired.
        //
        // We set up the lockout state directly via PinService rather
        // than driving 5 wrong-PIN UI loops because the keypad-tap
        // path through the Flutter test framework can have button
        // position drift between attempts. The lockout *mechanism* is
        // owned by PinService (covered exhaustively in
        // pin_service_test.dart). What this test asserts is the
        // SCREEN CONTRACT: a locked PinService → no approval, no audit.
        await seedUser(
          id: 'user-manager',
          name: 'مدير',
          pin: '1234',
          role: 'manager',
        );

        // Drive PinService into the locked state by feeding it 5
        // wrong attempts directly.
        for (var i = 0; i < 5; i++) {
          await PinService.verifyPin('0000');
        }
        expect(
          await PinService.isLockedOut(),
          isTrue,
          reason:
              'precondition: PinService should be locked out after 5 wrong '
              'attempts — if this fails, kMaxPinAttempts changed and this '
              'test needs updating',
        );

        // Now pump the screen and try the (correct!) PIN. Even though
        // the device PIN matches AND a manager record exists in the
        // DB, the screen must reject because PinService is locked.
        await tester.pumpWidget(buildScreen());
        await tester.pumpAndSettle();

        await enterPin(tester, '1234');

        final logs = await db.auditLogDao.getLogs('store-1');
        expect(
          logs,
          isEmpty,
          reason:
              'lockout in PinService MUST short-circuit the approval flow — '
              'an audit row here would mean the screen bypassed the gate',
        );
      },
    );
  });
}
