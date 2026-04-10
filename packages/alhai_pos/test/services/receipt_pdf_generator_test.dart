/// Unit tests for ReceiptPdfGenerator
///
/// Tests: StoreInfo model, default values, currency constant
library;

import 'package:flutter_test/flutter_test.dart';

import 'package:alhai_pos/src/services/receipt_pdf_generator.dart';

void main() {
  group('StoreInfo', () {
    test('constructor creates instance with required fields', () {
      const store = StoreInfo(
        name: 'Test Store',
        address: 'Test Address',
        phone: '0500000000',
        vatNumber: '300000000000003',
      );

      expect(store.name, equals('Test Store'));
      expect(store.address, equals('Test Address'));
      expect(store.phone, equals('0500000000'));
      expect(store.vatNumber, equals('300000000000003'));
      expect(store.crNumber, isNull);
    });

    test('constructor accepts optional crNumber', () {
      const store = StoreInfo(
        name: 'Test Store',
        address: 'Test Address',
        phone: '0500000000',
        vatNumber: '300000000000003',
        crNumber: 'CR12345',
      );

      expect(store.crNumber, equals('CR12345'));
    });

    test('defaultStore has correct values', () {
      const store = StoreInfo.defaultStore;

      expect(store.name, equals('Al-HAI Store'));
      expect(store.address, isNotEmpty);
      expect(store.phone, isNotEmpty);
      expect(store.vatNumber, isNotEmpty);
    });

    test('defaultStore vatNumber is valid format', () {
      const store = StoreInfo.defaultStore;

      // VAT number should be numeric
      expect(store.vatNumber, matches(RegExp(r'^\d+$')));
    });

    test('defaultStore has no crNumber', () {
      const store = StoreInfo.defaultStore;

      expect(store.crNumber, isNull);
    });
  });

  group('StoreInfo equality', () {
    test('two StoreInfo with same values are const-identical', () {
      const store1 = StoreInfo.defaultStore;
      const store2 = StoreInfo.defaultStore;

      expect(identical(store1, store2), isTrue);
    });

    test('custom StoreInfo instances with different values are not identical',
        () {
      const store1 = StoreInfo(
        name: 'Store A',
        address: 'Address A',
        phone: '0501111111',
        vatNumber: '100000000000001',
      );
      const store2 = StoreInfo(
        name: 'Store B',
        address: 'Address B',
        phone: '0502222222',
        vatNumber: '200000000000002',
      );

      expect(identical(store1, store2), isFalse);
    });
  });

  group('StoreInfo fields', () {
    test('name can contain Arabic characters', () {
      const store = StoreInfo(
        name: '\u0645\u062A\u062C\u0631 \u0627\u0644\u062D\u064A',
        address: '\u0627\u0644\u0631\u064A\u0627\u0636',
        phone: '0500000000',
        vatNumber: '300000000000003',
      );

      expect(store.name, isNotEmpty);
    });

    test('all fields are accessible', () {
      const store = StoreInfo(
        name: 'name',
        address: 'address',
        phone: 'phone',
        vatNumber: 'vat',
        crNumber: 'cr',
      );

      expect(store.name, equals('name'));
      expect(store.address, equals('address'));
      expect(store.phone, equals('phone'));
      expect(store.vatNumber, equals('vat'));
      expect(store.crNumber, equals('cr'));
    });
  });
}
