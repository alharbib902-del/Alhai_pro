/// Tests for the tamper-evident hash chain in AuditLogDao.
///
/// Covers:
///   1. Happy path — append 3 entries, verifyChain returns null.
///   2. Tamper detection — mutate middle row's payload, verifyChain returns its id.
///   3. First-row invariant — previousHash == ''.
///   4. Canonical JSON stability — identical inputs produce identical hashes.
///   5. Chain link break — mutate a stored previousHash, verifyChain catches it.
///   6. Legacy rows coexist — rows without __meta__ are skipped, chain stays intact.
///
/// Regulatory value: a ZATCA auditor can re-run verifyChain at any time; if
/// any historical row was modified, verification points to the first broken row.
library;

import 'dart:convert';

import 'package:alhai_database/alhai_database.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/database_test_helpers.dart';

void main() {
  late AppDatabase db;

  setUp(() {
    db = createTestDatabase();
  });

  tearDown(() async {
    await db.close();
  });

  group('AuditLogDao hash chain', () {
    test('happy path: three entries, verifyChain returns null (intact)',
        () async {
      await db.auditLogDao.appendLogWithHashChain(
        storeId: 'store-1',
        userId: 'user-1',
        userName: 'أحمد',
        action: AuditAction.login,
        payload: {'ip': '10.0.0.1'},
      );
      await db.auditLogDao.appendLogWithHashChain(
        storeId: 'store-1',
        userId: 'user-1',
        userName: 'أحمد',
        action: AuditAction.saleCreate,
        payload: {'saleId': 'sale-1', 'total': 100.0},
      );
      await db.auditLogDao.appendLogWithHashChain(
        storeId: 'store-1',
        userId: 'user-1',
        userName: 'أحمد',
        action: AuditAction.logout,
        payload: {},
      );

      final brokenId = await db.auditLogDao.verifyChain(storeId: 'store-1');
      expect(brokenId, isNull, reason: 'intact chain must return null');

      final logs = await db.auditLogDao.getLogs('store-1');
      expect(logs, hasLength(3));
      for (final row in logs) {
        final decoded = jsonDecode(row.newValue!) as Map<String, dynamic>;
        expect(decoded[kAuditHashMetaKey], isNotNull);
        final meta = decoded[kAuditHashMetaKey] as Map<String, dynamic>;
        expect(meta['contentHash'], isA<String>());
        expect((meta['contentHash'] as String).length, 64); // SHA-256 hex
        expect(meta['hashVersion'], kAuditHashVersion);
      }
    });

    test('tamper detection: mutating middle row payload breaks verifyChain',
        () async {
      final id1 = await db.auditLogDao.appendLogWithHashChain(
        storeId: 'store-1',
        userId: 'u',
        userName: 'U',
        action: AuditAction.saleCreate,
        payload: {'saleId': 's1', 'total': 10.0},
      );
      final id2 = await db.auditLogDao.appendLogWithHashChain(
        storeId: 'store-1',
        userId: 'u',
        userName: 'U',
        action: AuditAction.saleCreate,
        payload: {'saleId': 's2', 'total': 20.0},
      );
      final id3 = await db.auditLogDao.appendLogWithHashChain(
        storeId: 'store-1',
        userId: 'u',
        userName: 'U',
        action: AuditAction.saleCreate,
        payload: {'saleId': 's3', 'total': 30.0},
      );

      // Tamper: change middle row's total from 20 → 999 while leaving the
      // stored __meta__ (contentHash) untouched. This is the exact threat
      // the hash chain defends against.
      final middle = await (db.select(db.auditLogTable)
            ..where((l) => l.id.equals(id2)))
          .getSingle();
      final decoded = jsonDecode(middle.newValue!) as Map<String, dynamic>;
      decoded['total'] = 999.0;
      await (db.update(db.auditLogTable)..where((l) => l.id.equals(id2))).write(
        AuditLogTableCompanion(newValue: Value(jsonEncode(decoded))),
      );

      final broken = await db.auditLogDao.verifyChain(storeId: 'store-1');
      expect(broken, id2, reason: 'tampered middle row must be flagged');

      // Sanity — id1 and id3 are still known anchors.
      expect(id1, isNot(id2));
      expect(id3, isNot(id2));
    });

    test('first row has previousHash == ""', () async {
      final id = await db.auditLogDao.appendLogWithHashChain(
        storeId: 'store-A',
        userId: 'u',
        userName: 'U',
        action: AuditAction.login,
        payload: {'ip': '1.1.1.1'},
      );

      final row = await (db.select(db.auditLogTable)
            ..where((l) => l.id.equals(id)))
          .getSingle();
      final decoded = jsonDecode(row.newValue!) as Map<String, dynamic>;
      final meta = decoded[kAuditHashMetaKey] as Map<String, dynamic>;

      expect(meta['previousHash'], '',
          reason: 'first chain row must anchor at empty string');
      expect(meta['contentHash'], isNotEmpty);
    });

    test('canonical JSON stability: same input produces same hash', () {
      // Key order and whitespace must not affect the canonical bytes.
      final a = AuditLogDao.canonicalJsonForTest({
        'b': 2,
        'a': 1,
        'nested': {'z': 9, 'y': 8},
      });
      final b = AuditLogDao.canonicalJsonForTest({
        'nested': {'y': 8, 'z': 9},
        'a': 1,
        'b': 2,
      });
      expect(a, b, reason: 'keys must be sorted at every level');

      // And the string should be the sorted-keys form.
      expect(a, '{"a":1,"b":2,"nested":{"y":8,"z":9}}');

      // Lists preserve order.
      final listCase = AuditLogDao.canonicalJsonForTest({
        'items': [3, 1, 2],
      });
      expect(listCase, '{"items":[3,1,2]}');
    });

    test('chain link break: rewriting a stored previousHash is detected',
        () async {
      await db.auditLogDao.appendLogWithHashChain(
        storeId: 'store-2',
        userId: 'u',
        userName: 'U',
        action: AuditAction.login,
        payload: {},
      );
      final id2 = await db.auditLogDao.appendLogWithHashChain(
        storeId: 'store-2',
        userId: 'u',
        userName: 'U',
        action: AuditAction.saleCreate,
        payload: {'total': 50.0},
      );
      await db.auditLogDao.appendLogWithHashChain(
        storeId: 'store-2',
        userId: 'u',
        userName: 'U',
        action: AuditAction.logout,
        payload: {},
      );

      // Attacker rewrites only the previousHash of row 2 to a fake value.
      final row = await (db.select(db.auditLogTable)
            ..where((l) => l.id.equals(id2)))
          .getSingle();
      final decoded = jsonDecode(row.newValue!) as Map<String, dynamic>;
      final meta = Map<String, dynamic>.from(
        decoded[kAuditHashMetaKey] as Map<String, dynamic>,
      );
      meta['previousHash'] =
          '0000000000000000000000000000000000000000000000000000000000000000';
      decoded[kAuditHashMetaKey] = meta;
      await (db.update(db.auditLogTable)..where((l) => l.id.equals(id2))).write(
        AuditLogTableCompanion(newValue: Value(jsonEncode(decoded))),
      );

      final broken = await db.auditLogDao.verifyChain(storeId: 'store-2');
      expect(broken, id2);
    });

    test('legacy rows without __meta__ are skipped; chain remains verifiable',
        () async {
      // A legacy row via the old `log` method.
      await db.auditLogDao.log(
        storeId: 'store-3',
        userId: 'u',
        userName: 'U',
        action: AuditAction.login,
        description: 'legacy row (no hash)',
      );

      // Then a chain row — its previousHash should be '' because no prior
      // chain row exists (legacy row is ignored by _getLastContentHash).
      final id = await db.auditLogDao.appendLogWithHashChain(
        storeId: 'store-3',
        userId: 'u',
        userName: 'U',
        action: AuditAction.saleCreate,
        payload: {'total': 5.0},
      );

      final row = await (db.select(db.auditLogTable)
            ..where((l) => l.id.equals(id)))
          .getSingle();
      final decoded = jsonDecode(row.newValue!) as Map<String, dynamic>;
      final meta = decoded[kAuditHashMetaKey] as Map<String, dynamic>;
      expect(meta['previousHash'], '',
          reason: 'legacy rows must not be treated as chain anchors');

      // Chain remains intact.
      expect(await db.auditLogDao.verifyChain(storeId: 'store-3'), isNull);
    });

    test('verifyChain is scoped per storeId', () async {
      // Two stores, independent chains.
      await db.auditLogDao.appendLogWithHashChain(
        storeId: 'store-X',
        userId: 'u',
        userName: 'U',
        action: AuditAction.login,
        payload: {},
      );
      final yId = await db.auditLogDao.appendLogWithHashChain(
        storeId: 'store-Y',
        userId: 'u',
        userName: 'U',
        action: AuditAction.login,
        payload: {},
      );

      // Tamper with store-Y.
      final row = await (db.select(db.auditLogTable)
            ..where((l) => l.id.equals(yId)))
          .getSingle();
      final decoded = jsonDecode(row.newValue!) as Map<String, dynamic>;
      decoded['tampered'] = true;
      await (db.update(db.auditLogTable)..where((l) => l.id.equals(yId))).write(
        AuditLogTableCompanion(newValue: Value(jsonEncode(decoded))),
      );

      expect(await db.auditLogDao.verifyChain(storeId: 'store-X'), isNull);
      expect(await db.auditLogDao.verifyChain(storeId: 'store-Y'), yId);
    });
  });
}
