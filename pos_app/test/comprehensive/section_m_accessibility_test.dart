library;

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart' show KeyEventResult;
import 'package:flutter_test/flutter_test.dart';

import 'package:pos_app/core/accessibility/semantic_labels.dart';
import 'package:pos_app/core/utils/keyboard_shortcuts.dart';
import 'package:pos_app/core/validators/phone_validator.dart';
import 'package:pos_app/core/validators/email_validator.dart';
import 'package:pos_app/core/validators/price_validator.dart';

import 'fixtures/test_fixtures.dart';

// ============================================================================
// Section M: إمكانية الوصول (Accessibility)
// ============================================================================

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // --------------------------------------------------------------------------
  // M01: التنقل بالكيبورد - التحقق من تسجيل الاختصارات بشكل صحيح
  // --------------------------------------------------------------------------
  group('القسم م - إمكانية الوصول', () {
    test('م01: اختصارات الكيبورد - التحقق من أن PosKeyboardShortcuts تعالج جميع المفاتيح المسجلة بشكل صحيح', () {
      // تتبع الاختصارات التي تم استدعاؤها
      final calledActions = <String>[];

      void onSearch() => calledActions.add('search');
      void onNewSale() => calledActions.add('newSale');
      void onCheckout() => calledActions.add('checkout');
      void onUndo() => calledActions.add('undo');
      void onCancel() => calledActions.add('cancel');
      void onQuickAdd(int n) => calledActions.add('quickAdd:$n');
      void onQuantityChange(bool inc) =>
          calledActions.add(inc ? 'increase' : 'decrease');

      KeyEventResult handle(LogicalKeyboardKey key) {
        final event = KeyDownEvent(
          physicalKey: PhysicalKeyboardKey.f1,
          logicalKey: key,
          timeStamp: Duration.zero,
        );
        return PosKeyboardShortcuts.handleKeyEvent(
          event,
          onSearch: onSearch,
          onNewSale: onNewSale,
          onCheckout: onCheckout,
          onUndo: onUndo,
          onCancel: onCancel,
          onQuickAdd: onQuickAdd,
          onQuantityChange: onQuantityChange,
        );
      }

      // F1 → بحث
      var result = handle(LogicalKeyboardKey.f1);
      expect(result, KeyEventResult.handled);
      expect(calledActions.last, 'search');

      // F2 → بيع جديد
      result = handle(LogicalKeyboardKey.f2);
      expect(result, KeyEventResult.handled);
      expect(calledActions.last, 'newSale');

      // Enter → دفع
      result = handle(LogicalKeyboardKey.enter);
      expect(result, KeyEventResult.handled);
      expect(calledActions.last, 'checkout');

      // Escape → إلغاء
      result = handle(LogicalKeyboardKey.escape);
      expect(result, KeyEventResult.handled);
      expect(calledActions.last, 'cancel');

      // أرقام 1-9 → إضافة سريعة
      result = handle(LogicalKeyboardKey.digit3);
      expect(result, KeyEventResult.handled);
      expect(calledActions.last, 'quickAdd:3');

      result = handle(LogicalKeyboardKey.numpad7);
      expect(result, KeyEventResult.handled);
      expect(calledActions.last, 'quickAdd:7');

      // + → زيادة كمية
      result = handle(LogicalKeyboardKey.numpadAdd);
      expect(result, KeyEventResult.handled);
      expect(calledActions.last, 'increase');

      // - → نقصان كمية
      result = handle(LogicalKeyboardKey.minus);
      expect(result, KeyEventResult.handled);
      expect(calledActions.last, 'decrease');

      // مفتاح غير مسجل → يتم تجاهله
      result = handle(LogicalKeyboardKey.keyA);
      expect(result, KeyEventResult.ignored);

      // التأكد من أن جميع الإجراءات المتوقعة تم استدعاؤها
      expect(calledActions, containsAll([
        'search',
        'newSale',
        'checkout',
        'cancel',
        'quickAdd:3',
        'quickAdd:7',
        'increase',
        'decrease',
      ]));
    });

    // --------------------------------------------------------------------------
    // M02: وضوح التركيز - التحقق من أن SemanticLabels تحتوي على تسميات
    //       لجميع عناصر الواجهة الحرجة (أزرار، حقول إدخال، إلخ)
    // --------------------------------------------------------------------------
    test('م02: التسميات الدلالية - التحقق من وجود تسميات عربية لجميع عناصر الواجهة الحرجة', () {
      // ---- تسميات التنقل ----
      expect(NavigationLabels.home, isNotEmpty);
      expect(NavigationLabels.pos, isNotEmpty);
      expect(NavigationLabels.products, isNotEmpty);
      expect(NavigationLabels.inventory, isNotEmpty);
      expect(NavigationLabels.reports, isNotEmpty);
      expect(NavigationLabels.settings, isNotEmpty);
      expect(NavigationLabels.logout, isNotEmpty);
      expect(NavigationLabels.back, isNotEmpty);
      expect(NavigationLabels.close, isNotEmpty);
      expect(NavigationLabels.drawer, isNotEmpty);

      // التحقق من أن التسميات عربية (تحتوي على أحرف عربية)
      final arabicPattern = RegExp(r'[\u0600-\u06FF]');
      expect(arabicPattern.hasMatch(NavigationLabels.home), isTrue,
          reason: 'تسمية الشاشة الرئيسية يجب أن تكون بالعربية');
      expect(arabicPattern.hasMatch(NavigationLabels.pos), isTrue,
          reason: 'تسمية نقطة البيع يجب أن تكون بالعربية');

      // ---- تسميات نقطة البيع (أزرار وحقول إدخال) ----
      expect(POSLabels.searchProduct, isNotEmpty);
      expect(POSLabels.barcodeScanner, isNotEmpty);
      expect(POSLabels.cart, isNotEmpty);
      expect(POSLabels.emptyCart, isNotEmpty);
      expect(POSLabels.clearCart, isNotEmpty);
      expect(POSLabels.checkout, isNotEmpty);
      expect(POSLabels.selectPaymentMethod, isNotEmpty);
      expect(POSLabels.cash, isNotEmpty);
      expect(POSLabels.card, isNotEmpty);
      expect(POSLabels.mada, isNotEmpty);
      expect(POSLabels.printReceipt, isNotEmpty);
      expect(POSLabels.newSale, isNotEmpty);
      expect(POSLabels.holdInvoice, isNotEmpty);
      expect(POSLabels.retrieveInvoice, isNotEmpty);

      // التسميات الديناميكية
      expect(POSLabels.addToCart('بيبسي'), contains('بيبسي'));
      expect(POSLabels.removeFromCart('أرز'), contains('أرز'));
      expect(POSLabels.increaseQuantity('حليب', 3), contains('3'));
      expect(POSLabels.decreaseQuantity('حليب', 5), contains('5'));
      expect(POSLabels.productPrice(7.00), contains('7.00'));
      expect(POSLabels.cartTotal(100.50, 3), contains('100.50'));
      expect(POSLabels.confirmPayment(250.00), contains('250.00'));

      // ---- تسميات النماذج (حقول الإدخال والأزرار) ----
      expect(FormLabels.nameField, isNotEmpty);
      expect(FormLabels.priceField, isNotEmpty);
      expect(FormLabels.quantityField, isNotEmpty);
      expect(FormLabels.barcodeField, isNotEmpty);
      expect(FormLabels.descriptionField, isNotEmpty);
      expect(FormLabels.searchField, isNotEmpty);
      expect(FormLabels.saveButton, isNotEmpty);
      expect(FormLabels.cancelButton, isNotEmpty);
      expect(FormLabels.deleteButton, isNotEmpty);
      expect(FormLabels.requiredField, isNotEmpty);
      expect(FormLabels.fieldError('خطأ'), contains('خطأ'));

      // ---- تسميات الحوارات ----
      expect(DialogLabels.confirm, isNotEmpty);
      expect(DialogLabels.cancel, isNotEmpty);
      expect(DialogLabels.ok, isNotEmpty);
      expect(DialogLabels.yes, isNotEmpty);
      expect(DialogLabels.no, isNotEmpty);
      expect(DialogLabels.warning, isNotEmpty);
      expect(DialogLabels.error, isNotEmpty);
      expect(DialogLabels.success, isNotEmpty);
      expect(DialogLabels.loading, isNotEmpty);
      expect(DialogLabels.confirmExit, isNotEmpty);
      expect(DialogLabels.confirmDelete('المنتج'), contains('المنتج'));

      // ---- تسميات الحالات ----
      expect(StatusLabels.online, isNotEmpty);
      expect(StatusLabels.offline, isNotEmpty);
      expect(StatusLabels.synced, isNotEmpty);
      expect(StatusLabels.syncFailed, isNotEmpty);
      expect(StatusLabels.lowMemory, isNotEmpty);
      expect(StatusLabels.syncing(5), contains('5'));
      expect(StatusLabels.pendingSync(10), contains('10'));

      // ---- تلميحات إمكانية الوصول ----
      expect(AccessibilityHints.doubleTapToActivate, isNotEmpty);
      expect(AccessibilityHints.swipeRightForOptions, isNotEmpty);
      expect(AccessibilityHints.swipeLeftToDelete, isNotEmpty);
      expect(AccessibilityHints.longPressForOptions, isNotEmpty);
      expect(AccessibilityHints.volumeToChangeQty, isNotEmpty);

      // التأكد من أن جميع التلميحات بالعربية
      expect(arabicPattern.hasMatch(AccessibilityHints.doubleTapToActivate), isTrue);
      expect(arabicPattern.hasMatch(AccessibilityHints.swipeLeftToDelete), isTrue);
    });

    // --------------------------------------------------------------------------
    // M03: رسائل الخطأ بالعربية - التحقق من أن المدققين يعيدون
    //       رسائل خطأ عربية وليس أكواد أو إنجليزية
    // --------------------------------------------------------------------------
    test('م03: رسائل الخطأ بالعربية - التحقق من أن المدققين يعيدون رسائل عربية مفهومة وليس أكواد', () {
      final arabicPattern = RegExp(r'[\u0600-\u06FF]');

      // ---- التحقق من الهاتف ----
      // حقل فارغ
      final phoneEmpty = PhoneValidator.validateMobile(null);
      expect(phoneEmpty.isValid, isFalse);
      expect(phoneEmpty.errorAr, isNotNull);
      expect(arabicPattern.hasMatch(phoneEmpty.errorAr!), isTrue,
          reason: 'رسالة خطأ الهاتف الفارغ يجب أن تكون بالعربية');
      expect(phoneEmpty.errorAr, contains('مطلوب'));
      // التأكد من أن getError('ar') يعيد العربية وليس الكود
      expect(phoneEmpty.getError('ar'), isNot(equals(phoneEmpty.errorCode)));

      // صيغة خاطئة
      final phoneInvalid = PhoneValidator.validateMobile('1234');
      expect(phoneInvalid.isValid, isFalse);
      expect(phoneInvalid.errorAr, isNotNull);
      expect(arabicPattern.hasMatch(phoneInvalid.errorAr!), isTrue,
          reason: 'رسالة خطأ الصيغة يجب أن تكون بالعربية');
      expect(phoneInvalid.errorAr, contains('غير صحيح'));

      // رقم صحيح
      final phoneValid = PhoneValidator.validateMobile('0512345678');
      expect(phoneValid.isValid, isTrue);
      expect(phoneValid.errorAr, isNull);

      // ---- التحقق من البريد الإلكتروني ----
      final emailEmpty = EmailValidator.validate(null);
      expect(emailEmpty.isValid, isFalse);
      expect(emailEmpty.errorAr, isNotNull);
      expect(arabicPattern.hasMatch(emailEmpty.errorAr!), isTrue,
          reason: 'رسالة خطأ البريد الفارغ يجب أن تكون بالعربية');
      expect(emailEmpty.errorAr, contains('مطلوب'));

      final emailInvalid = EmailValidator.validate('not-an-email');
      expect(emailInvalid.isValid, isFalse);
      expect(emailInvalid.errorAr, isNotNull);
      expect(arabicPattern.hasMatch(emailInvalid.errorAr!), isTrue,
          reason: 'رسالة خطأ البريد غير الصحيح يجب أن تكون بالعربية');

      // ---- التحقق من السعر ----
      final priceEmpty = PriceValidator.validate(null);
      expect(priceEmpty.isValid, isFalse);
      expect(priceEmpty.errorAr, isNotNull);
      expect(arabicPattern.hasMatch(priceEmpty.errorAr!), isTrue,
          reason: 'رسالة خطأ السعر الفارغ يجب أن تكون بالعربية');
      expect(priceEmpty.errorAr, contains('مطلوب'));

      final priceNegative = PriceValidator.validate('-10');
      expect(priceNegative.isValid, isFalse);
      expect(priceNegative.errorAr, isNotNull);
      expect(arabicPattern.hasMatch(priceNegative.errorAr!), isTrue,
          reason: 'رسالة خطأ السعر السالب يجب أن تكون بالعربية');
      expect(priceNegative.errorAr, contains('سالب'));

      final priceInvalidFormat = PriceValidator.validate('abc');
      expect(priceInvalidFormat.isValid, isFalse);
      expect(priceInvalidFormat.errorAr, isNotNull);
      expect(arabicPattern.hasMatch(priceInvalidFormat.errorAr!), isTrue);

      // التحقق من أن الكمية الفارغة تعيد عربية
      final qtyEmpty = PriceValidator.validateQuantity(null);
      expect(qtyEmpty.isValid, isFalse);
      expect(qtyEmpty.errorAr, isNotNull);
      expect(arabicPattern.hasMatch(qtyEmpty.errorAr!), isTrue,
          reason: 'رسالة خطأ الكمية الفارغة يجب أن تكون بالعربية');
      expect(qtyEmpty.errorAr, contains('مطلوب'));

      // التحقق من أن نسبة الخصم خارج النطاق تعيد عربية
      final discountInvalid = PriceValidator.validateDiscount('150');
      expect(discountInvalid.isValid, isFalse);
      expect(discountInvalid.errorAr, isNotNull);
      expect(arabicPattern.hasMatch(discountInvalid.errorAr!), isTrue,
          reason: 'رسالة خطأ نسبة الخصم يجب أن تكون بالعربية');

      // ---- التحقق من أن getError('ar') دائماً يعيد العربية وليس الإنجليزية ----
      final allFailures = [
        phoneEmpty,
        phoneInvalid,
        emailEmpty,
        emailInvalid,
        priceEmpty,
        priceNegative,
        priceInvalidFormat,
        qtyEmpty,
        discountInvalid,
      ];

      for (final failure in allFailures) {
        final arMsg = failure.getError('ar');
        final enMsg = failure.getError('en');

        expect(arMsg, isNotNull, reason: 'كل خطأ يجب أن يحتوي على رسالة عربية');
        expect(enMsg, isNotNull, reason: 'كل خطأ يجب أن يحتوي على رسالة إنجليزية');

        // الرسالة العربية يجب أن تكون مختلفة عن الإنجليزية
        expect(arMsg, isNot(equals(enMsg)),
            reason: 'الرسالة العربية يجب أن تختلف عن الإنجليزية: $arMsg');

        // الرسالة العربية يجب أن تحتوي على أحرف عربية
        expect(arabicPattern.hasMatch(arMsg!), isTrue,
            reason: 'الرسالة "$arMsg" يجب أن تحتوي على أحرف عربية');

        // الرسالة العربية يجب أن لا تكون مجرد كود خطأ
        expect(arMsg, isNot(equals(failure.errorCode)),
            reason: 'الرسالة العربية يجب أن لا تكون كود خطأ: ${failure.errorCode}');
      }
    });
  });
}
