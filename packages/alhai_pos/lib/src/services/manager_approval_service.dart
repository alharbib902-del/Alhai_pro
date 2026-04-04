/// Manager Approval Service - خدمة موافقة المدير
///
/// خدمة للتحقق من صلاحيات المدير عبر PIN
/// تستخدم PinService للتحقق الآمن (PBKDF2 + lockout)
library;

import 'package:flutter/material.dart';
import 'package:alhai_auth/alhai_auth.dart';

/// خدمة موافقة المدير
class ManagerApprovalService {
  ManagerApprovalService._();

  /// طلب موافقة المدير باستخدام PinService (الطريقة المفضلة)
  ///
  /// يعرض حوار إدخال PIN المشرف مع التحقق عبر PinService
  /// (PBKDF2 + lockout بعد 5 محاولات فاشلة لمدة 15 دقيقة)
  ///
  /// إذا لم يكن PIN مُعداً بعد، يعرض شاشة الإعداد أولاً.
  ///
  /// [context] - BuildContext للعرض
  /// [action] - رمز الإجراء (مثل: 'void_sale', 'cash_out')
  ///
  /// Returns: true إذا تم التحقق بنجاح، false إذا أُلغيت أو فشلت
  static Future<bool> requestPinApproval({
    required BuildContext context,
    String? action,
  }) async {
    final description = action != null ? getActionDescription(action) : null;
    return ManagerApprovalScreen.showApprovalDialog(
      context,
      action: description,
    );
  }

  /// طلب موافقة المدير (واجهة قديمة - تستخدم callback)
  ///
  /// يعرض dialog لإدخال PIN المدير والتحقق منه
  /// [context] - BuildContext للعرض
  /// [action] - اسم الإجراء المطلوب (مثل: "حذف منتج")
  /// [description] - وصف إضافي للإجراء (اختياري)
  /// [onVerify] - دالة التحقق من PIN
  ///
  /// Returns: true إذا تم الموافقة، false إذا تم الرفض أو الإلغاء
  static Future<bool> requestApproval({
    required BuildContext context,
    required String action,
    String? description,
    required Future<bool> Function(String pin) onVerify,
  }) async {
    return await ManagerApprovalDialog.show(
      context: context,
      action: action,
      description: description,
      onVerify: onVerify,
    );
  }

  /// طلب موافقة المدير مع التحقق المحلي
  ///
  /// [expectedPin] مطلوب - يجب الحصول عليه من مصدر آمن (خادم أو تخزين آمن)
  /// في الإنتاج يُفضل استخدام [requestPinApproval] مع PinService
  static Future<bool> requestApprovalWithLocalVerification({
    required BuildContext context,
    required String action,
    String? description,
    required String expectedPin,
  }) async {
    return await ManagerApprovalDialog.show(
      context: context,
      action: action,
      description: description,
      onVerify: (pin) async {
        // مقارنة ثابتة الوقت لمنع هجمات التوقيت
        if (pin.length != expectedPin.length) return false;
        int result = 0;
        for (int i = 0; i < pin.length; i++) {
          result |= pin.codeUnitAt(i) ^ expectedPin.codeUnitAt(i);
        }
        return result == 0;
      },
    );
  }

  /// الإجراءات التي تتطلب موافقة المدير
  static const List<String> protectedActions = [
    'delete_product', // حذف منتج
    'delete_customer', // حذف عميل
    'void_sale', // إلغاء فاتورة
    'refund', // استرجاع
    'modify_price', // تعديل السعر
    'apply_discount', // تطبيق خصم
    'discount_over_20', // خصم أكثر من 20%
    'cash_out', // سحب نقدي من الصندوق
    'close_day', // إغلاق اليوم
    'view_reports', // عرض التقارير المالية
    'export_data', // تصدير البيانات
    'modify_inventory', // تعديل المخزون يدوياً
  ];

  /// التحقق مما إذا كان الإجراء يتطلب موافقة المدير
  static bool requiresApproval(String action) {
    return protectedActions.contains(action);
  }

  /// الحصول على وصف الإجراء بالعربية
  static String getActionDescription(String action) {
    switch (action) {
      case 'delete_product':
        return 'حذف منتج من النظام';
      case 'delete_customer':
        return 'حذف عميل من النظام';
      case 'void_sale':
        return 'إلغاء فاتورة بيع';
      case 'refund':
        return 'إجراء عملية استرجاع';
      case 'modify_price':
        return 'تعديل سعر منتج';
      case 'apply_discount':
        return 'تطبيق خصم على الفاتورة';
      case 'discount_over_20':
        return 'تطبيق خصم أكثر من 20% يتطلب موافقة المشرف';
      case 'cash_out':
        return 'سحب نقدي من درج الصندوق';
      case 'close_day':
        return 'إغلاق اليوم وتسوية الصندوق';
      case 'view_reports':
        return 'عرض التقارير المالية';
      case 'export_data':
        return 'تصدير بيانات النظام';
      case 'modify_inventory':
        return 'تعديل كمية المخزون يدوياً';
      default:
        return 'إجراء يتطلب صلاحيات مدير';
    }
  }

  /// الحصول على اسم الإجراء بالعربية
  static String getActionName(String action) {
    switch (action) {
      case 'delete_product':
        return 'حذف منتج';
      case 'delete_customer':
        return 'حذف عميل';
      case 'void_sale':
        return 'إلغاء فاتورة';
      case 'refund':
        return 'استرجاع';
      case 'modify_price':
        return 'تعديل السعر';
      case 'apply_discount':
        return 'تطبيق خصم';
      case 'discount_over_20':
        return 'خصم أكثر من 20%';
      case 'cash_out':
        return 'سحب نقدي';
      case 'close_day':
        return 'إغلاق اليوم';
      case 'view_reports':
        return 'عرض التقارير';
      case 'export_data':
        return 'تصدير البيانات';
      case 'modify_inventory':
        return 'تعديل المخزون';
      default:
        return action;
    }
  }
}

/// Extension لتسهيل طلب الموافقة
extension ManagerApprovalExtension on BuildContext {
  /// طلب موافقة المدير باستخدام PinService (الطريقة المفضلة)
  Future<bool> requestPinApproval({String? action}) {
    return ManagerApprovalService.requestPinApproval(
      context: this,
      action: action,
    );
  }

  /// طلب موافقة المدير (واجهة قديمة مع callback)
  Future<bool> requestManagerApproval({
    required String action,
    String? description,
    required Future<bool> Function(String pin) onVerify,
  }) {
    return ManagerApprovalService.requestApproval(
      context: this,
      action: action,
      description: description,
      onVerify: onVerify,
    );
  }
}
