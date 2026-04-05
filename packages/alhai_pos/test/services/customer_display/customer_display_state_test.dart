import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:alhai_pos/src/services/customer_display/customer_display_state.dart';

void main() {
  // ==========================================================================
  // CustomerDisplayPhase
  // ==========================================================================

  group('CustomerDisplayPhase', () {
    test('يحتوي على جميع المراحل المتوقعة', () {
      expect(CustomerDisplayPhase.values, hasLength(7));
      expect(CustomerDisplayPhase.values, contains(CustomerDisplayPhase.idle));
      expect(CustomerDisplayPhase.values, contains(CustomerDisplayPhase.cart));
      expect(
          CustomerDisplayPhase.values, contains(CustomerDisplayPhase.phoneEntry));
      expect(
          CustomerDisplayPhase.values, contains(CustomerDisplayPhase.payment));
      expect(
          CustomerDisplayPhase.values, contains(CustomerDisplayPhase.nfcWaiting));
      expect(
          CustomerDisplayPhase.values, contains(CustomerDisplayPhase.success));
      expect(
          CustomerDisplayPhase.values, contains(CustomerDisplayPhase.failure));
    });
  });

  // ==========================================================================
  // NfcDisplayStatus
  // ==========================================================================

  group('NfcDisplayStatus', () {
    test('يحتوي على جميع الحالات المتوقعة', () {
      expect(NfcDisplayStatus.values, hasLength(7));
      expect(NfcDisplayStatus.values, contains(NfcDisplayStatus.waitingForTap));
      expect(NfcDisplayStatus.values, contains(NfcDisplayStatus.reading));
      expect(NfcDisplayStatus.values, contains(NfcDisplayStatus.processing));
      expect(NfcDisplayStatus.values, contains(NfcDisplayStatus.success));
      expect(NfcDisplayStatus.values, contains(NfcDisplayStatus.failed));
      expect(NfcDisplayStatus.values, contains(NfcDisplayStatus.cancelled));
      expect(NfcDisplayStatus.values, contains(NfcDisplayStatus.timeout));
    });
  });

  // ==========================================================================
  // DisplayCartItem
  // ==========================================================================

  group('DisplayCartItem', () {
    test('toJson() ينتج JSON صحيح', () {
      const item = DisplayCartItem(
        productName: 'قهوة عربية',
        quantity: 2,
        unitPrice: 15.0,
        lineTotal: 30.0,
      );

      final json = item.toJson();

      expect(json['productName'], equals('قهوة عربية'));
      expect(json['quantity'], equals(2));
      expect(json['unitPrice'], equals(15.0));
      expect(json['lineTotal'], equals(30.0));
    });

    test('fromJson() يعيد العنصر بشكل صحيح', () {
      final json = {
        'productName': 'شاي أخضر',
        'quantity': 3,
        'unitPrice': 10.0,
        'lineTotal': 30.0,
      };

      final item = DisplayCartItem.fromJson(json);

      expect(item.productName, equals('شاي أخضر'));
      expect(item.quantity, equals(3));
      expect(item.unitPrice, equals(10.0));
      expect(item.lineTotal, equals(30.0));
    });

    test('fromJson() يتعامل مع القيم الناقصة بقيم افتراضية', () {
      final item = DisplayCartItem.fromJson(<String, dynamic>{});

      expect(item.productName, equals(''));
      expect(item.quantity, equals(0));
      expect(item.unitPrice, equals(0));
      expect(item.lineTotal, equals(0));
    });

    test('toJson() → fromJson() رحلة ذهاب وإياب', () {
      const original = DisplayCartItem(
        productName: 'كابتشينو',
        quantity: 1,
        unitPrice: 22.5,
        lineTotal: 22.5,
      );

      final roundtripped = DisplayCartItem.fromJson(original.toJson());

      expect(roundtripped.productName, equals(original.productName));
      expect(roundtripped.quantity, equals(original.quantity));
      expect(roundtripped.unitPrice, equals(original.unitPrice));
      expect(roundtripped.lineTotal, equals(original.lineTotal));
    });
  });

  // ==========================================================================
  // CustomerDisplayState - Factory constructors
  // ==========================================================================

  group('CustomerDisplayState - factory constructors', () {
    test('idle ينتج المرحلة الصحيحة', () {
      const state = CustomerDisplayState.idle(storeName: 'متجر الاختبار');

      expect(state.phase, equals(CustomerDisplayPhase.idle));
      expect(state.storeName, equals('متجر الاختبار'));
      expect(state.items, isEmpty);
      expect(state.total, equals(0));
    });

    test('idle بدون اسم متجر يستخدم قيمة فارغة', () {
      const state = CustomerDisplayState.idle();

      expect(state.phase, equals(CustomerDisplayPhase.idle));
      expect(state.storeName, equals(''));
    });

    test('cart ينتج المرحلة الصحيحة مع بيانات السلة', () {
      final items = [
        const DisplayCartItem(
          productName: 'منتج 1',
          quantity: 2,
          unitPrice: 10.0,
          lineTotal: 20.0,
        ),
      ];

      final state = CustomerDisplayState.cart(
        items: items,
        subtotal: 20.0,
        discount: 2.0,
        tax: 2.7,
        total: 20.7,
        storeName: 'متجر',
      );

      expect(state.phase, equals(CustomerDisplayPhase.cart));
      expect(state.items, hasLength(1));
      expect(state.subtotal, equals(20.0));
      expect(state.discount, equals(2.0));
      expect(state.tax, equals(2.7));
      expect(state.total, equals(20.7));
    });

    test('phoneEntry ينتج المرحلة الصحيحة', () {
      final state = CustomerDisplayState.phoneEntry(
        items: const [],
        total: 50.0,
        storeName: 'متجر',
      );

      expect(state.phase, equals(CustomerDisplayPhase.phoneEntry));
      expect(state.total, equals(50.0));
    });

    test('nfcWaiting ينتج المرحلة الصحيحة', () {
      final state = CustomerDisplayState.nfcWaiting(
        total: 100.0,
        nfcStatus: NfcDisplayStatus.waitingForTap,
        nfcMessage: 'قرّب البطاقة',
      );

      expect(state.phase, equals(CustomerDisplayPhase.nfcWaiting));
      expect(state.total, equals(100.0));
      expect(state.nfcStatus, equals(NfcDisplayStatus.waitingForTap));
      expect(state.nfcMessage, equals('قرّب البطاقة'));
    });

    test('nfcWaiting بدون رسالة يستخدم القيم الافتراضية', () {
      final state = CustomerDisplayState.nfcWaiting(total: 75.0);

      expect(state.nfcStatus, equals(NfcDisplayStatus.waitingForTap));
      expect(state.nfcMessage, isNull);
    });

    test('success ينتج المرحلة الصحيحة', () {
      final state = CustomerDisplayState.success(
        total: 200.0,
        resultMessage: 'تم الدفع بنجاح',
      );

      expect(state.phase, equals(CustomerDisplayPhase.success));
      expect(state.total, equals(200.0));
      expect(state.resultMessage, equals('تم الدفع بنجاح'));
    });

    test('failure ينتج المرحلة الصحيحة', () {
      final state = CustomerDisplayState.failure(
        resultMessage: 'فشل الدفع',
        storeName: 'متجر',
      );

      expect(state.phase, equals(CustomerDisplayPhase.failure));
      expect(state.resultMessage, equals('فشل الدفع'));
      expect(state.storeName, equals('متجر'));
    });

    test('failure بدون رسالة يقبل null', () {
      final state = CustomerDisplayState.failure();

      expect(state.phase, equals(CustomerDisplayPhase.failure));
      expect(state.resultMessage, isNull);
    });
  });

  // ==========================================================================
  // CustomerDisplayState - Default constructor
  // ==========================================================================

  group('CustomerDisplayState - القيم الافتراضية', () {
    test('المُنشئ الافتراضي يستخدم القيم الصحيحة', () {
      const state = CustomerDisplayState();

      expect(state.phase, equals(CustomerDisplayPhase.idle));
      expect(state.storeName, equals(''));
      expect(state.items, isEmpty);
      expect(state.subtotal, equals(0));
      expect(state.discount, equals(0));
      expect(state.tax, equals(0));
      expect(state.total, equals(0));
      expect(state.paymentMethodName, isNull);
      expect(state.nfcStatus, isNull);
      expect(state.nfcMessage, isNull);
      expect(state.resultMessage, isNull);
    });
  });

  // ==========================================================================
  // CustomerDisplayState - copyWith
  // ==========================================================================

  group('CustomerDisplayState - copyWith', () {
    test('copyWith ينسخ بتعديل الحقول المطلوبة فقط', () {
      const original = CustomerDisplayState(
        phase: CustomerDisplayPhase.cart,
        storeName: 'متجر',
        total: 100.0,
      );

      final copied = original.copyWith(total: 200.0);

      expect(copied.phase, equals(CustomerDisplayPhase.cart));
      expect(copied.storeName, equals('متجر'));
      expect(copied.total, equals(200.0));
    });

    test('copyWith يغير المرحلة', () {
      const original = CustomerDisplayState(
        phase: CustomerDisplayPhase.cart,
      );

      final copied = original.copyWith(
        phase: CustomerDisplayPhase.nfcWaiting,
        nfcStatus: NfcDisplayStatus.reading,
      );

      expect(copied.phase, equals(CustomerDisplayPhase.nfcWaiting));
      expect(copied.nfcStatus, equals(NfcDisplayStatus.reading));
    });
  });

  // ==========================================================================
  // CustomerDisplayState - Serialization (toJson / fromJson)
  // ==========================================================================

  group('CustomerDisplayState - التسلسل', () {
    test('idle: toJson → fromJson رحلة ذهاب وإياب', () {
      const original = CustomerDisplayState.idle(storeName: 'متجر الاختبار');
      final json = original.toJson();
      final restored = CustomerDisplayState.fromJson(json);

      expect(restored.phase, equals(CustomerDisplayPhase.idle));
      expect(restored.storeName, equals('متجر الاختبار'));
      expect(restored.items, isEmpty);
    });

    test('cart: toJson → fromJson رحلة ذهاب وإياب', () {
      final original = CustomerDisplayState.cart(
        items: const [
          DisplayCartItem(
            productName: 'قهوة',
            quantity: 2,
            unitPrice: 15.0,
            lineTotal: 30.0,
          ),
          DisplayCartItem(
            productName: 'كعكة',
            quantity: 1,
            unitPrice: 25.0,
            lineTotal: 25.0,
          ),
        ],
        subtotal: 55.0,
        discount: 5.0,
        tax: 7.5,
        total: 57.5,
        storeName: 'كافيه',
      );

      final json = original.toJson();
      final restored = CustomerDisplayState.fromJson(json);

      expect(restored.phase, equals(CustomerDisplayPhase.cart));
      expect(restored.storeName, equals('كافيه'));
      expect(restored.items, hasLength(2));
      expect(restored.items[0].productName, equals('قهوة'));
      expect(restored.items[0].quantity, equals(2));
      expect(restored.items[1].productName, equals('كعكة'));
      expect(restored.subtotal, equals(55.0));
      expect(restored.discount, equals(5.0));
      expect(restored.tax, equals(7.5));
      expect(restored.total, equals(57.5));
    });

    test('phoneEntry: toJson → fromJson رحلة ذهاب وإياب', () {
      final original = CustomerDisplayState.phoneEntry(
        items: const [
          DisplayCartItem(
            productName: 'منتج',
            quantity: 1,
            unitPrice: 50.0,
            lineTotal: 50.0,
          ),
        ],
        total: 50.0,
        storeName: 'متجر',
      );

      final json = original.toJson();
      final restored = CustomerDisplayState.fromJson(json);

      expect(restored.phase, equals(CustomerDisplayPhase.phoneEntry));
      expect(restored.total, equals(50.0));
      expect(restored.items, hasLength(1));
    });

    test('nfcWaiting: toJson → fromJson رحلة ذهاب وإياب', () {
      final original = CustomerDisplayState.nfcWaiting(
        total: 99.99,
        nfcStatus: NfcDisplayStatus.reading,
        nfcMessage: 'جاري القراءة',
        storeName: 'متجر',
      );

      final json = original.toJson();
      final restored = CustomerDisplayState.fromJson(json);

      expect(restored.phase, equals(CustomerDisplayPhase.nfcWaiting));
      expect(restored.total, equals(99.99));
      expect(restored.nfcStatus, equals(NfcDisplayStatus.reading));
      expect(restored.nfcMessage, equals('جاري القراءة'));
    });

    test('success: toJson → fromJson رحلة ذهاب وإياب', () {
      final original = CustomerDisplayState.success(
        total: 150.0,
        resultMessage: 'تم بنجاح',
        storeName: 'متجر',
      );

      final json = original.toJson();
      final restored = CustomerDisplayState.fromJson(json);

      expect(restored.phase, equals(CustomerDisplayPhase.success));
      expect(restored.total, equals(150.0));
      expect(restored.resultMessage, equals('تم بنجاح'));
    });

    test('failure: toJson → fromJson رحلة ذهاب وإياب', () {
      final original = CustomerDisplayState.failure(
        resultMessage: 'خطأ في الاتصال',
        storeName: 'متجر',
      );

      final json = original.toJson();
      final restored = CustomerDisplayState.fromJson(json);

      expect(restored.phase, equals(CustomerDisplayPhase.failure));
      expect(restored.resultMessage, equals('خطأ في الاتصال'));
    });

    test('fromJson يتعامل مع مرحلة غير معروفة ويعود لـ idle', () {
      final json = <String, dynamic>{
        'phase': 'unknown_phase',
        'storeName': '',
      };

      final state = CustomerDisplayState.fromJson(json);

      expect(state.phase, equals(CustomerDisplayPhase.idle));
    });

    test('fromJson يتعامل مع nfcStatus غير معروف ويعود لـ waitingForTap', () {
      final json = <String, dynamic>{
        'phase': 'nfcWaiting',
        'nfcStatus': 'unknown_status',
      };

      final state = CustomerDisplayState.fromJson(json);

      expect(state.nfcStatus, equals(NfcDisplayStatus.waitingForTap));
    });

    test('fromJson يتعامل مع nfcStatus بقيمة null', () {
      final json = <String, dynamic>{
        'phase': 'idle',
        'nfcStatus': null,
      };

      final state = CustomerDisplayState.fromJson(json);

      expect(state.nfcStatus, isNull);
    });

    test('fromJson يتعامل مع قائمة عناصر فارغة', () {
      final json = <String, dynamic>{
        'phase': 'cart',
        'items': <dynamic>[],
      };

      final state = CustomerDisplayState.fromJson(json);

      expect(state.items, isEmpty);
    });

    test('fromJson يتعامل مع عدم وجود قائمة عناصر', () {
      final json = <String, dynamic>{
        'phase': 'cart',
      };

      final state = CustomerDisplayState.fromJson(json);

      expect(state.items, isEmpty);
    });
  });

  // ==========================================================================
  // CustomerDisplayState - toJsonString / fromJsonString
  // ==========================================================================

  group('CustomerDisplayState - JSON String serialization', () {
    test('toJsonString ينتج JSON string صالح', () {
      const state = CustomerDisplayState.idle(storeName: 'متجر');

      final jsonString = state.toJsonString();
      final decoded = jsonDecode(jsonString) as Map<String, dynamic>;

      expect(decoded['phase'], equals('idle'));
      expect(decoded['storeName'], equals('متجر'));
    });

    test('toJsonString → fromJsonString رحلة ذهاب وإياب', () {
      final original = CustomerDisplayState.cart(
        items: const [
          DisplayCartItem(
            productName: 'عصير',
            quantity: 3,
            unitPrice: 8.0,
            lineTotal: 24.0,
          ),
        ],
        subtotal: 24.0,
        discount: 0,
        tax: 3.6,
        total: 27.6,
        storeName: 'مشروبات',
      );

      final jsonString = original.toJsonString();
      final restored = CustomerDisplayState.fromJsonString(jsonString);

      expect(restored.phase, equals(CustomerDisplayPhase.cart));
      expect(restored.items, hasLength(1));
      expect(restored.items[0].productName, equals('عصير'));
      expect(restored.items[0].quantity, equals(3));
      expect(restored.subtotal, equals(24.0));
      expect(restored.total, equals(27.6));
      expect(restored.storeName, equals('مشروبات'));
    });

    test('toJsonString → fromJsonString مع nfc حالة كاملة', () {
      final original = CustomerDisplayState.nfcWaiting(
        total: 45.0,
        nfcStatus: NfcDisplayStatus.processing,
        nfcMessage: 'جاري المعالجة',
        storeName: 'متجر',
      );

      final jsonString = original.toJsonString();
      final restored = CustomerDisplayState.fromJsonString(jsonString);

      expect(restored.phase, equals(CustomerDisplayPhase.nfcWaiting));
      expect(restored.nfcStatus, equals(NfcDisplayStatus.processing));
      expect(restored.nfcMessage, equals('جاري المعالجة'));
    });
  });

  // ==========================================================================
  // CustomerDisplayState - toJson output structure
  // ==========================================================================

  group('CustomerDisplayState - بنية toJson', () {
    test('toJson يحتوي على جميع المفاتيح المتوقعة', () {
      final state = CustomerDisplayState.nfcWaiting(
        total: 100.0,
        nfcStatus: NfcDisplayStatus.waitingForTap,
        nfcMessage: 'انتظار',
        storeName: 'متجر',
      );

      final json = state.toJson();

      expect(json.containsKey('phase'), isTrue);
      expect(json.containsKey('storeName'), isTrue);
      expect(json.containsKey('items'), isTrue);
      expect(json.containsKey('subtotal'), isTrue);
      expect(json.containsKey('discount'), isTrue);
      expect(json.containsKey('tax'), isTrue);
      expect(json.containsKey('total'), isTrue);
      expect(json.containsKey('paymentMethodName'), isTrue);
      expect(json.containsKey('nfcStatus'), isTrue);
      expect(json.containsKey('nfcMessage'), isTrue);
      expect(json.containsKey('resultMessage'), isTrue);
    });

    test('toJson يستخدم اسم المرحلة كـ string', () {
      const state = CustomerDisplayState(
        phase: CustomerDisplayPhase.nfcWaiting,
      );

      final json = state.toJson();

      expect(json['phase'], equals('nfcWaiting'));
    });

    test('toJson يستخدم اسم nfcStatus كـ string', () {
      const state = CustomerDisplayState(
        nfcStatus: NfcDisplayStatus.processing,
      );

      final json = state.toJson();

      expect(json['nfcStatus'], equals('processing'));
    });

    test('toJson يعطي null لـ nfcStatus عندما يكون null', () {
      const state = CustomerDisplayState();

      final json = state.toJson();

      expect(json['nfcStatus'], isNull);
    });
  });
}
