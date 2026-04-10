import 'package:flutter_test/flutter_test.dart';

import 'package:alhai_zatca/src/chaining/chain_store.dart';
import 'package:alhai_zatca/src/chaining/invoice_chain_service.dart';
import 'package:alhai_zatca/src/signing/invoice_hasher.dart';

/// Tests for [ChainStore] and [InMemoryChainStore].
///
/// The package only ships an in-memory implementation of [ChainStore].
/// A persistent implementation (e.g. SharedPreferences-backed) would
/// require integration tests — those are out of scope here.
///
/// These tests also cover [InvoiceChainService] since it is the primary
/// consumer of [ChainStore] and exercises the PIH chaining behavior
/// described by ZATCA Phase 2.
void main() {
  group('InMemoryChainStore', () {
    late InMemoryChainStore store;

    setUp(() {
      store = InMemoryChainStore();
    });

    group('getLastHash', () {
      test('returns null on first call for a store', () async {
        final result = await store.getLastHash(storeId: 'store-1');
        expect(result, isNull);
      });

      test('returns null for an unknown store', () async {
        await store.saveLastHash(storeId: 'store-1', hash: 'hash-1');
        final result = await store.getLastHash(storeId: 'store-other');
        expect(result, isNull);
      });
    });

    group('saveLastHash', () {
      test('stores the hash and returns it on subsequent read', () async {
        await store.saveLastHash(storeId: 'store-1', hash: 'abc-123');
        final result = await store.getLastHash(storeId: 'store-1');
        expect(result, 'abc-123');
      });

      test('overwrites an existing hash (chain update)', () async {
        await store.saveLastHash(storeId: 'store-1', hash: 'old-hash');
        await store.saveLastHash(storeId: 'store-1', hash: 'new-hash');
        final result = await store.getLastHash(storeId: 'store-1');
        expect(result, 'new-hash');
      });

      test('keeps hashes for different stores isolated', () async {
        await store.saveLastHash(storeId: 'store-a', hash: 'hash-a');
        await store.saveLastHash(storeId: 'store-b', hash: 'hash-b');

        expect(await store.getLastHash(storeId: 'store-a'), 'hash-a');
        expect(await store.getLastHash(storeId: 'store-b'), 'hash-b');
      });
    });

    group('deleteLastHash', () {
      test('clears the chain for the specified store', () async {
        await store.saveLastHash(storeId: 'store-1', hash: 'abc');
        await store.deleteLastHash(storeId: 'store-1');
        final result = await store.getLastHash(storeId: 'store-1');
        expect(result, isNull);
      });

      test('does not throw when deleting a non-existent store', () async {
        // Should be safe to call on a store that was never saved
        await expectLater(
          store.deleteLastHash(storeId: 'never-existed'),
          completes,
        );
      });

      test('does not affect other stores', () async {
        await store.saveLastHash(storeId: 'store-a', hash: 'hash-a');
        await store.saveLastHash(storeId: 'store-b', hash: 'hash-b');

        await store.deleteLastHash(storeId: 'store-a');

        expect(await store.getLastHash(storeId: 'store-a'), isNull);
        expect(await store.getLastHash(storeId: 'store-b'), 'hash-b');
      });
    });

    group('round-trip', () {
      test('supports multiple save/read/delete cycles', () async {
        const storeId = 'cycle-test';
        for (var i = 0; i < 5; i++) {
          await store.saveLastHash(storeId: storeId, hash: 'hash-$i');
          expect(
            await store.getLastHash(storeId: storeId),
            'hash-$i',
            reason: 'Failed at cycle $i',
          );
        }
        await store.deleteLastHash(storeId: storeId);
        expect(await store.getLastHash(storeId: storeId), isNull);
      });
    });
  });

  group('InvoiceChainService (ChainStore consumer)', () {
    late InMemoryChainStore store;
    late InvoiceChainService service;

    setUp(() {
      store = InMemoryChainStore();
      service = InvoiceChainService(store: store);
    });

    test('returns the initial seed hash on first call', () async {
      final hash = await service.getPreviousHash(storeId: 'new-store');
      expect(hash, InvoiceChainService.seedHash);
    });

    test('seed hash is Base64(SHA-256("0")) per ZATCA spec', () {
      // ZATCA requires the seed to be Base64(SHA-256("0"))
      // This should be consistent with InvoiceHasher.hashString('0')
      expect(
        InvoiceChainService.seedHash,
        InvoiceHasher.hashString('0'),
      );
      // Sanity: it should be a valid 44-char base64 string
      expect(InvoiceChainService.seedHash.length, 44);
    });

    test('returns the stored hash after an invoice was registered',
        () async {
      await service.updateLastHash(
        storeId: 'store-1',
        invoiceHash: 'INV-HASH-1',
      );

      final hash = await service.getPreviousHash(storeId: 'store-1');
      expect(hash, 'INV-HASH-1');
    });

    test('chain updates sequentially as invoices are added', () async {
      const storeId = 'store-chain';
      final hashes = ['H1', 'H2', 'H3', 'H4'];

      // Initially returns seed
      expect(
        await service.getPreviousHash(storeId: storeId),
        InvoiceChainService.seedHash,
      );

      for (final h in hashes) {
        await service.updateLastHash(storeId: storeId, invoiceHash: h);
        expect(await service.getPreviousHash(storeId: storeId), h);
      }
    });

    test('different stores maintain independent chains', () async {
      await service.updateLastHash(storeId: 'A', invoiceHash: 'A-last');
      await service.updateLastHash(storeId: 'B', invoiceHash: 'B-last');

      expect(await service.getPreviousHash(storeId: 'A'), 'A-last');
      expect(await service.getPreviousHash(storeId: 'B'), 'B-last');
    });

    test('clearing the chain reverts to seed hash', () async {
      await service.updateLastHash(
        storeId: 'store-1',
        invoiceHash: 'some-hash',
      );
      await store.deleteLastHash(storeId: 'store-1');

      final hash = await service.getPreviousHash(storeId: 'store-1');
      expect(hash, InvoiceChainService.seedHash);
    });
  });

  group('ChainStore contract (via InMemoryChainStore)', () {
    // These tests document the contract that any persistent
    // ChainStore implementation should satisfy.

    test('conforms to abstract ChainStore interface', () {
      final store = InMemoryChainStore();
      expect(store, isA<ChainStore>());
    });

    test('getLastHash is idempotent (reading does not mutate)', () async {
      final store = InMemoryChainStore();
      await store.saveLastHash(storeId: 's', hash: 'H');

      // Multiple reads should return the same value
      for (var i = 0; i < 3; i++) {
        expect(await store.getLastHash(storeId: 's'), 'H');
      }
    });

    test('empty storeId is treated as a valid (distinct) store', () async {
      final store = InMemoryChainStore();
      await store.saveLastHash(storeId: '', hash: 'empty-store');
      await store.saveLastHash(storeId: 'other', hash: 'other-store');

      expect(await store.getLastHash(storeId: ''), 'empty-store');
      expect(await store.getLastHash(storeId: 'other'), 'other-store');
    });
  });
}
