/// أدوات التحقق الموحدة لـ TextFormField
///
/// تغلف validators الموجودة بصيغة `String? Function(String?)`
/// للاستخدام المباشر مع خاصية `validator` في TextFormField
///
/// **This is the canonical validation system (L65).**
/// The deprecated [AlhaiValidators] in `alhai_design_system/lib/src/utils/validators.dart`
/// should not be used for new code. All new validation should use [FormValidators]
/// and the individual validator classes exported from this package.
library;

import 'phone_validator.dart';
import 'email_validator.dart';
import 'price_validator.dart';
import 'barcode_validator.dart';
import 'iban_validator.dart';
import 'input_sanitizer.dart';

/// أدوات التحقق المركزية للنماذج
class FormValidators {
  FormValidators._();

  // =========================================================
  // أغلفة للـ validators الموجودة
  // =========================================================

  /// التحقق من رقم الهاتف السعودي
  static String? Function(String?) phone({
    String locale = 'ar',
    bool required = true,
  }) {
    return PhoneValidator.formValidator(locale: locale, required: required);
  }

  /// التحقق من البريد الإلكتروني
  static String? Function(String?) email({
    String locale = 'ar',
    bool required = true,
  }) {
    return EmailValidator.formValidator(locale: locale, required: required);
  }

  /// التحقق من السعر / المبلغ المالي
  static String? Function(String?) price({
    String locale = 'ar',
    bool required = true,
    bool allowZero = true,
    double? maxValue,
  }) {
    return PriceValidator.formValidator(
      locale: locale,
      required: required,
      allowZero: allowZero,
      maxValue: maxValue,
    );
  }

  /// التحقق من الباركود
  static String? Function(String?) barcode({
    String locale = 'ar',
    bool required = true,
  }) {
    return BarcodeValidator.formValidator(locale: locale, required: required);
  }

  /// التحقق من IBAN السعودي
  static String? Function(String?) iban({
    String locale = 'ar',
    bool required = true,
  }) {
    return IbanValidator.formValidator(locale: locale, required: required);
  }

  /// التحقق من الكمية
  static String? Function(String?) quantity({
    String locale = 'ar',
    bool required = true,
    bool allowDecimal = false,
    int? maxValue,
    bool allowZero = false,
  }) {
    return (String? value) {
      if (!required && (value == null || value.isEmpty)) return null;
      final result = PriceValidator.validateQuantity(
        value,
        allowZero: allowZero,
        allowDecimal: allowDecimal,
        maxValue: maxValue,
      );
      return result.getError(locale);
    };
  }

  /// التحقق من نسبة الخصم (0-100)
  static String? Function(String?) discount({String locale = 'ar'}) {
    return (String? value) {
      if (value == null || value.isEmpty) return null;
      final result = PriceValidator.validateDiscount(value);
      return result.getError(locale);
    };
  }

  // =========================================================
  // validators جديدة
  // =========================================================

  /// حقل مطلوب مع حد أقصى للطول + فحص محتوى خطر
  static String? Function(String?) requiredField({
    String locale = 'ar',
    int maxLength = 200,
    String? fieldName,
  }) {
    return (String? value) {
      if (value == null || value.trim().isEmpty) {
        final name = fieldName ?? (locale == 'ar' ? 'هذا الحقل' : 'This field');
        return locale == 'ar' ? '$name مطلوب' : '$name is required';
      }
      if (value.length > maxLength) {
        return locale == 'ar'
            ? 'الحد الأقصى $maxLength حرف'
            : 'Maximum $maxLength characters';
      }
      if (InputSanitizer.containsDangerousContent(value)) {
        return locale == 'ar'
            ? 'المدخل يحتوي على محتوى غير مسموح'
            : 'Input contains disallowed content';
      }
      return null;
    };
  }

  /// التحقق من الاسم (عربي/إنجليزي + مسافات + شرطات)
  static String? Function(String?) name({
    String locale = 'ar',
    bool isRequired = true,
    int minLength = 2,
    int maxLength = 100,
  }) {
    return (String? value) {
      if (!isRequired && (value == null || value.trim().isEmpty)) return null;
      if (isRequired && (value == null || value.trim().isEmpty)) {
        return locale == 'ar' ? 'الاسم مطلوب' : 'Name is required';
      }
      if (value!.trim().length < minLength) {
        return locale == 'ar'
            ? 'الاسم يجب أن يكون $minLength حرف على الأقل'
            : 'Name must be at least $minLength characters';
      }
      if (value.length > maxLength) {
        return locale == 'ar'
            ? 'الحد الأقصى $maxLength حرف'
            : 'Maximum $maxLength characters';
      }
      // السماح بالعربية والإنجليزية والمسافات والشرطات فقط
      if (!RegExp(r'^[a-zA-Z\u0600-\u06FF\s\-\.]+$').hasMatch(value.trim())) {
        return locale == 'ar'
            ? 'يُسمح بالحروف والمسافات فقط'
            : 'Only letters and spaces allowed';
      }
      if (InputSanitizer.containsDangerousContent(value)) {
        return locale == 'ar'
            ? 'المدخل يحتوي على محتوى غير مسموح'
            : 'Input contains disallowed content';
      }
      return null;
    };
  }

  /// التحقق من الملاحظات / النصوص الاختيارية
  static String? Function(String?) notes({
    String locale = 'ar',
    int maxLength = 500,
  }) {
    return (String? value) {
      if (value == null || value.trim().isEmpty) return null;
      if (value.length > maxLength) {
        return locale == 'ar'
            ? 'الحد الأقصى $maxLength حرف'
            : 'Maximum $maxLength characters';
      }
      if (InputSanitizer.containsDangerousContent(value)) {
        return locale == 'ar'
            ? 'المدخل يحتوي على محتوى غير مسموح'
            : 'Input contains disallowed content';
      }
      return null;
    };
  }

  /// التحقق من رقم صحيح
  static String? Function(String?) numeric({
    String locale = 'ar',
    bool isRequired = true,
    int? max,
    bool allowZero = false,
  }) {
    return (String? value) {
      if (!isRequired && (value == null || value.trim().isEmpty)) return null;
      if (isRequired && (value == null || value.trim().isEmpty)) {
        return locale == 'ar' ? 'الرقم مطلوب' : 'Number is required';
      }
      final num = int.tryParse(value!);
      if (num == null) {
        return locale == 'ar'
            ? 'يجب إدخال رقم صحيح'
            : 'Must be a valid integer';
      }
      if (num < 0) {
        return locale == 'ar'
            ? 'الرقم لا يمكن أن يكون سالباً'
            : 'Number cannot be negative';
      }
      if (!allowZero && num == 0) {
        return locale == 'ar'
            ? 'الرقم يجب أن يكون أكبر من صفر'
            : 'Number must be greater than zero';
      }
      if (max != null && num > max) {
        return locale == 'ar'
            ? 'الحد الأقصى $max'
            : 'Maximum value is $max';
      }
      return null;
    };
  }

  /// التحقق من رمز المنتج (SKU)
  static String? Function(String?) sku({
    String locale = 'ar',
    bool isRequired = false,
    int maxLength = 50,
  }) {
    return (String? value) {
      if (!isRequired && (value == null || value.trim().isEmpty)) return null;
      if (isRequired && (value == null || value.trim().isEmpty)) {
        return locale == 'ar' ? 'رمز المنتج مطلوب' : 'SKU is required';
      }
      if (value!.length > maxLength) {
        return locale == 'ar'
            ? 'الحد الأقصى $maxLength حرف'
            : 'Maximum $maxLength characters';
      }
      if (!RegExp(r'^[a-zA-Z0-9\-_]+$').hasMatch(value)) {
        return locale == 'ar'
            ? 'يُسمح بالحروف والأرقام والشرطات فقط'
            : 'Only letters, numbers, and dashes allowed';
      }
      return null;
    };
  }

  /// التحقق من رقم ضريبة القيمة المضافة (VAT) السعودي
  /// 15 رقم يبدأ بـ 3
  static String? Function(String?) vatNumber({
    String locale = 'ar',
    bool isRequired = false,
  }) {
    return (String? value) {
      if (!isRequired && (value == null || value.trim().isEmpty)) return null;
      if (isRequired && (value == null || value.trim().isEmpty)) {
        return locale == 'ar'
            ? 'الرقم الضريبي مطلوب'
            : 'VAT number is required';
      }
      if (!RegExp(r'^\d{15}$').hasMatch(value!)) {
        return locale == 'ar'
            ? 'الرقم الضريبي يجب أن يكون 15 رقم'
            : 'VAT number must be 15 digits';
      }
      if (!value.startsWith('3')) {
        return locale == 'ar'
            ? 'الرقم الضريبي يجب أن يبدأ بـ 3'
            : 'VAT number must start with 3';
      }
      return null;
    };
  }

  /// التحقق من رقم السجل التجاري السعودي
  /// 10 أرقام
  static String? Function(String?) crNumber({
    String locale = 'ar',
    bool isRequired = false,
  }) {
    return (String? value) {
      if (!isRequired && (value == null || value.trim().isEmpty)) return null;
      if (isRequired && (value == null || value.trim().isEmpty)) {
        return locale == 'ar'
            ? 'رقم السجل التجاري مطلوب'
            : 'CR number is required';
      }
      if (!RegExp(r'^\d{10}$').hasMatch(value!)) {
        return locale == 'ar'
            ? 'رقم السجل التجاري يجب أن يكون 10 أرقام'
            : 'CR number must be 10 digits';
      }
      return null;
    };
  }
}
