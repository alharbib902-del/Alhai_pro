import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:alhai_zatca/src/chaining/chain_store.dart';
import 'package:alhai_zatca/src/chaining/invoice_chain_service.dart';
import 'package:alhai_zatca/src/signing/invoice_hasher.dart';

/// Tests for [InvoiceChainService] — ZATCA Phase 2 PIH (Previous Invoice
/// Hash) chaining.
///
/// ZATCA requires every invoice to reference the hash of the invoice that
/// preceded it in the chain. The very first invoice uses a seed value of
/// Base64(SHA-256("0")). The service must:
///
///   - Return the seed on the first call.
///   - Chain each invoice's hash into the "previous hash" slot.
///   - Reset state when the chain is explicitly reset.
///   - Maintain separate chains per store.
///
/// We use the in-memory [InMemoryChainStore] implementation that ships
/// alongside [ChainStore] as a test double.
void main() {
  late InMemoryChainStore store;
  late InvoiceChainService service;

  setUp(() {
    store = InMemoryChainStore();
    service = InvoiceChainService(store: store);
  });

  group('InvoiceChainService - seed hash (first invoice)', () {
    test('returns initial seed hash for very first invoice', () async {
      final pih = await service.getPreviousHash(storeId: 'store-1');
      expect(pih, InvoiceChainService.seedHash);
    });

    test('seed hash equals Base64(SHA-256("0"))', () {
      final expected = base64Encode(sha256.convert(utf8.encode('0')).bytes);
      expect(InvoiceChainService.seedHash, expected);
    });

    test('seed hash is the well-known ZATCA reference value', () {
      // 5feceb66ffc86f38d952786c6d696c79c2dbc239dd4e91b46729d73a27fb57e9
      // base64 of those 32 bytes:
      expect(
        InvoiceChainService.seedHash,
        'X+zrZv/IbzjZUnhsbWlsecLbwjndTpG0ZynXOif7V+k=',
      );
    });

    test('seed hash decodes to exactly 32 bytes (SHA-256 length)', () {
      final bytes = base64Decode(InvoiceChainService.seedHash);
      expect(bytes.length, 32);
    });

    test('seed hash is consistent across service instances', () {
      final svc1 = InvoiceChainService(store: InMemoryChainStore());
      final svc2 = InvoiceChainService(store: InMemoryChainStore());
      // Seed is a static const on the class - identical for any instance
      expect(InvoiceChainService.seedHash, isNotEmpty);
      expect(svc1, isNotNull);
      expect(svc2, isNotNull);
    });
  });

  group('InvoiceChainService - chaining behavior', () {
    test('updateLastHash stores hash for retrieval by next invoice', () async {
      const firstHash = 'hash-of-first-invoice';

      await service.updateLastHash(
        storeId: 'store-1',
        invoiceHash: firstHash,
      );

      final next = await service.getPreviousHash(storeId: 'store-1');
      expect(next, firstHash);
    });

    test('each invoice\'s PIH equals the previous invoice\'s hash', () async {
      const storeId = 'store-1';

      // Invoice #1 -- uses seed
      final pih1 = await service.getPreviousHash(storeId: storeId);
      expect(pih1, InvoiceChainService.seedHash);
      await service.updateLastHash(
        storeId: storeId,
        invoiceHash: 'hash1',
      );

      // Invoice #2 -- uses hash1
      final pih2 = await service.getPreviousHash(storeId: storeId);
      expect(pih2, 'hash1');
      await service.updateLastHash(
        storeId: storeId,
        invoiceHash: 'hash2',
      );

      // Invoice #3 -- uses hash2
      final pih3 = await service.getPreviousHash(storeId: storeId);
      expect(pih3, 'hash2');
      await service.updateLastHash(
        storeId: storeId,
        invoiceHash: 'hash3',
      );

      // Invoice #4 -- uses hash3
      final pih4 = await service.getPreviousHash(storeId: storeId);
      expect(pih4, 'hash3');
    });

    test('maintains separate chains per store', () async {
      await service.updateLastHash(
        storeId: 'store-A',
        invoiceHash: 'A-hash',
      );
      await service.updateLastHash(
        storeId: 'store-B',
        invoiceHash: 'B-hash',
      );

      final a = await service.getPreviousHash(storeId: 'store-A');
      final b = await service.getPreviousHash(storeId: 'store-B');
      final c = await service.getPreviousHash(storeId: 'store-C');

      expect(a, 'A-hash');
      expect(b, 'B-hash');
      // New store uses seed
      expect(c, InvoiceChainService.seedHash);
    });

    test('updateLastHash overwrites the previous hash', () async {
      const storeId = 'store-1';

      await service.updateLastHash(storeId: storeId, invoiceHash: 'old');
      await service.updateLastHash(storeId: storeId, invoiceHash: 'new');

      final pih = await service.getPreviousHash(storeId: storeId);
      expect(pih, 'new');
    });

    test('persists state between successive calls on same service', () async {
      const storeId = 'persist-store';

      await service.updateLastHash(
        storeId: storeId,
        invoiceHash: 'persisted-hash',
      );

      // Multiple reads return the same value
      final first = await service.getPreviousHash(storeId: storeId);
      final second = await service.getPreviousHash(storeId: storeId);
      final third = await service.getPreviousHash(storeId: storeId);

      expect(first, 'persisted-hash');
      expect(second, 'persisted-hash');
      expect(third, 'persisted-hash');
    });
  });

  group('InvoiceChainService - computeAndStore', () {
    test('computes hash from signed XML and persists it', () async {
      const storeId = 'store-1';
      const xml = '<Invoice><cbc:ID xmlns:cbc="urn:cbc">1</cbc:ID></Invoice>';

      final returnedHash = await service.computeAndStore(
        storeId: storeId,
        signedInvoiceXml: xml,
      );

      expect(returnedHash, isNotEmpty);
      // The same value should now be the previous hash
      final pih = await service.getPreviousHash(storeId: storeId);
      expect(pih, returnedHash);
    });

    test('computeAndStore result matches direct InvoiceHasher output', () async {
      const storeId = 'store-1';
      const xml = '<Invoice><cbc:ID xmlns:cbc="urn:cbc">42</cbc:ID></Invoice>';

      final directHasher = InvoiceHasher();
      final expectedHash = directHasher.computeHash(xml);

      final actualHash = await service.computeAndStore(
        storeId: storeId,
        signedInvoiceXml: xml,
      );

      expect(actualHash, expectedHash);
    });

    test('computeAndStore returns a valid base64 string (32-byte SHA-256)',
        () async {
      const xml =
          '<Invoice><cbc:ID xmlns:cbc="urn:cbc">hash-test</cbc:ID></Invoice>';

      final hash = await service.computeAndStore(
        storeId: 'store-1',
        signedInvoiceXml: xml,
      );

      // Valid base64
      expect(() => base64Decode(hash), returnsNormally);
      // SHA-256 produces 32 bytes
      expect(base64Decode(hash).length, 32);
    });

    test('chaining multiple invoices via computeAndStore', () async {
      const storeId = 'store-1';
      const xml1 = '<Invoice><cbc:ID xmlns:cbc="urn:cbc">1</cbc:ID></Invoice>';
      const xml2 = '<Invoice><cbc:ID xmlns:cbc="urn:cbc">2</cbc:ID></Invoice>';

      // Invoice #1
      final pihBefore1 = await service.getPreviousHash(storeId: storeId);
      expect(pihBefore1, InvoiceChainService.seedHash);
      final hash1 = await service.computeAndStore(
        storeId: storeId,
        signedInvoiceXml: xml1,
      );

      // Invoice #2
      final pihBefore2 = await service.getPreviousHash(storeId: storeId);
      expect(pihBefore2, hash1);
      final hash2 = await service.computeAndStore(
        storeId: storeId,
        signedInvoiceXml: xml2,
      );

      // After invoice 2 -- previous hash is hash2
      final pihAfter2 = await service.getPreviousHash(storeId: storeId);
      expect(pihAfter2, hash2);
      expect(hash1, isNot(equals(hash2)));
    });
  });

  group('InvoiceChainService - resetChain', () {
    test('resetChain clears chain so next getPreviousHash returns seed',
        () async {
      const storeId = 'store-1';

      await service.updateLastHash(
        storeId: storeId,
        invoiceHash: 'some-hash',
      );
      expect(
        await service.getPreviousHash(storeId: storeId),
        'some-hash',
      );

      await service.resetChain(storeId: storeId);

      expect(
        await service.getPreviousHash(storeId: storeId),
        InvoiceChainService.seedHash,
      );
    });

    test('resetChain for one store does not affect another store', () async {
      await service.updateLastHash(
        storeId: 'store-A',
        invoiceHash: 'A-hash',
      );
      await service.updateLastHash(
        storeId: 'store-B',
        invoiceHash: 'B-hash',
      );

      await service.resetChain(storeId: 'store-A');

      expect(
        await service.getPreviousHash(storeId: 'store-A'),
        InvoiceChainService.seedHash,
      );
      expect(
        await service.getPreviousHash(storeId: 'store-B'),
        'B-hash',
      );
    });

    test('resetChain is idempotent (safe to call with no prior state)',
        () async {
      await service.resetChain(storeId: 'never-seen-store');

      expect(
        await service.getPreviousHash(storeId: 'never-seen-store'),
        InvoiceChainService.seedHash,
      );
    });

    test('can rebuild chain after reset', () async {
      const storeId = 'store-1';

      await service.updateLastHash(storeId: storeId, invoiceHash: 'old-1');
      await service.resetChain(storeId: storeId);

      // Rebuild
      await service.updateLastHash(storeId: storeId, invoiceHash: 'new-1');
      expect(
        await service.getPreviousHash(storeId: storeId),
        'new-1',
      );
    });
  });

  group('InvoiceChainService - constructor & injected hasher', () {
    test('defaults to internal InvoiceHasher when none injected', () async {
      final svc = InvoiceChainService(store: InMemoryChainStore());

      const xml =
          '<Invoice><cbc:ID xmlns:cbc="urn:cbc">default</cbc:ID></Invoice>';
      final hash = await svc.computeAndStore(
        storeId: 'store-1',
        signedInvoiceXml: xml,
      );

      expect(hash, isNotEmpty);
      expect(base64Decode(hash).length, 32);
    });

    test('accepts an externally-provided hasher', () async {
      final externalHasher = InvoiceHasher();
      final svc = InvoiceChainService(
        store: InMemoryChainStore(),
        hasher: externalHasher,
      );

      const xml =
          '<Invoice><cbc:ID xmlns:cbc="urn:cbc">injected</cbc:ID></Invoice>';
      final hash = await svc.computeAndStore(
        storeId: 'store-1',
        signedInvoiceXml: xml,
      );

      // Should match what the injected hasher produces directly
      expect(hash, externalHasher.computeHash(xml));
    });
  });
}
