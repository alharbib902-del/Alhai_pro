import 'package:flutter_test/flutter_test.dart';
import 'package:alhai_pos/src/screens/pos/phone_entry_dialog.dart';

void main() {
  // ==========================================================================
  // PhoneEntryResult - النتائج
  // ==========================================================================

  group('PhoneEntryResult', () {
    test('skipped() يعيد نتيجة بدون رقم هاتف', () {
      const result = PhoneEntryResult.skipped();

      expect(result.phone, isNull);
      expect(result.customerId, isNull);
      expect(result.customerName, isNull);
    });

    test('skipped() wasSkipped يعود true', () {
      const result = PhoneEntryResult.skipped();

      expect(result.wasSkipped, isTrue);
    });

    test('skipped() hasExistingCustomer يعود false', () {
      const result = PhoneEntryResult.skipped();

      expect(result.hasExistingCustomer, isFalse);
    });

    test('نتيجة مع رقم هاتف فقط', () {
      const result = PhoneEntryResult(phone: '0512345678');

      expect(result.phone, equals('0512345678'));
      expect(result.customerId, isNull);
      expect(result.customerName, isNull);
      expect(result.wasSkipped, isFalse);
      expect(result.hasExistingCustomer, isFalse);
    });

    test('نتيجة مع عميل موجود', () {
      const result = PhoneEntryResult(
        phone: '0512345678',
        customerId: 'cust-123',
        customerName: 'أحمد محمد',
      );

      expect(result.phone, equals('0512345678'));
      expect(result.customerId, equals('cust-123'));
      expect(result.customerName, equals('أحمد محمد'));
      expect(result.wasSkipped, isFalse);
      expect(result.hasExistingCustomer, isTrue);
    });

    test('hasExistingCustomer يعود true فقط عند وجود customerId', () {
      const withId = PhoneEntryResult(
        phone: '0512345678',
        customerId: 'id-1',
      );
      const withoutId = PhoneEntryResult(
        phone: '0512345678',
      );

      expect(withId.hasExistingCustomer, isTrue);
      expect(withoutId.hasExistingCustomer, isFalse);
    });

    test('wasSkipped يعتمد على phone فقط', () {
      const withPhone = PhoneEntryResult(phone: '05');
      const withoutPhone = PhoneEntryResult();

      expect(withPhone.wasSkipped, isFalse);
      expect(withoutPhone.wasSkipped, isTrue);
    });

    test('المُنشئ الافتراضي بدون معاملات يشبه skipped', () {
      const result = PhoneEntryResult();

      expect(result.phone, isNull);
      expect(result.customerId, isNull);
      expect(result.customerName, isNull);
      expect(result.wasSkipped, isTrue);
      expect(result.hasExistingCustomer, isFalse);
    });
  });

  // ==========================================================================
  // PhoneEntryResult - أرقام سعودية
  // ==========================================================================

  group('PhoneEntryResult - أنماط الأرقام', () {
    test('رقم سعودي بصيغة 05xxxxxxxx', () {
      const result = PhoneEntryResult(phone: '0512345678');

      expect(result.phone, equals('0512345678'));
      expect(result.phone!.length, equals(10));
      expect(result.phone!.startsWith('05'), isTrue);
    });

    test('رقم سعودي بصيغة +966', () {
      const result = PhoneEntryResult(phone: '+966512345678');

      expect(result.phone, equals('+966512345678'));
      expect(result.phone!.startsWith('+966'), isTrue);
    });

    test('رقم قصير', () {
      const result = PhoneEntryResult(phone: '0512');

      expect(result.phone, equals('0512'));
      expect(result.wasSkipped, isFalse); // لا يزال يعتبر "لم يتخطّ"
    });
  });

  // ==========================================================================
  // Phone validation logic (اختبار منطق التحقق المستخرج)
  // ==========================================================================

  // استخراج منطق التحقق من _PhoneEntryDialogState._isPhoneValid
  // لاختبار وحدة مستقلة بدون widget
  group('منطق التحقق من صحة رقم الهاتف', () {
    // نسخة من منطق _isPhoneValid للاختبار
    bool isPhoneValid(String phone) {
      if (phone.isEmpty) return false;
      if (phone.startsWith('05') && phone.length == 10) return true;
      if (phone.startsWith('+966') && phone.length >= 13) return true;
      if (phone.replaceAll('+', '').length >= 8) return true;
      return false;
    }

    test('رقم فارغ غير صالح', () {
      expect(isPhoneValid(''), isFalse);
    });

    test('صيغة سعودية 05xxxxxxxx صالحة', () {
      expect(isPhoneValid('0512345678'), isTrue);
    });

    test('صيغة سعودية 05 قصيرة جداً غير صالحة', () {
      expect(isPhoneValid('05123'), isFalse); // 5 أرقام فقط < 8
      expect(isPhoneValid('0512345'), isFalse); // 7 أرقام < 8
    });

    test('صيغة 05 بـ 9 أرقام تمرّ بالقاعدة المرنة (>= 8)', () {
      // 051234567 ليس 10 أرقام فلا يطابق قاعدة 05، لكنه 9 أرقام >= 8
      expect(isPhoneValid('051234567'), isTrue);
    });

    test('صيغة دولية +966 صالحة', () {
      expect(isPhoneValid('+966512345678'), isTrue); // 13 حرف
    });

    test('صيغة دولية +966 قصيرة غير صالحة', () {
      expect(isPhoneValid('+96651'), isFalse); // أقل من 13
    });

    test('رقم بـ 8 أرقام أو أكثر صالح (مرن)', () {
      expect(isPhoneValid('12345678'), isTrue); // 8 أرقام بالضبط
      expect(isPhoneValid('123456789'), isTrue); // 9 أرقام
    });

    test('رقم أقل من 8 أرقام غير صالح', () {
      expect(isPhoneValid('1234567'), isFalse); // 7 أرقام
      expect(isPhoneValid('123'), isFalse); // 3 أرقام
    });

    test('رقم يبدأ بـ + مع 8 أرقام بعدها صالح', () {
      expect(isPhoneValid('+12345678'), isTrue); // + لا يُحسب
    });
  });
}
