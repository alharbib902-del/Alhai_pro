/// نظام التحقق المركزي للمدخلات
///
/// يوفر validators موحدة لجميع أنواع المدخلات:
/// - الهاتف السعودي
/// - البريد الإلكتروني
/// - الأسعار والمبالغ
/// - الباركود (EAN-13, EAN-8)
/// - IBAN السعودي
/// - تنظيف المدخلات من XSS/Injection
library;

export 'phone_validator.dart';
export 'email_validator.dart';
export 'price_validator.dart';
export 'barcode_validator.dart';
export 'iban_validator.dart';
export 'input_sanitizer.dart';
export 'validation_result.dart';
export 'form_validators.dart';
