/// Manager Approval Service - خدمة موافقة المدير
///
/// خدمة للتحقق من صلاحيات المدير عبر PIN
library;

import 'package:flutter/material.dart';
import '../widgets/auth/pin_numpad.dart';

/// خدمة موافقة المدير
class ManagerApprovalService {
  ManagerApprovalService._();

  /// طلب موافقة المدير
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
  /// يستخدم PIN ثابت للتحقق (للاختبار فقط)
  /// في الإنتاج يجب استخدام [requestApproval] مع تحقق من الخادم
  static Future<bool> requestApprovalWithLocalVerification({
    required BuildContext context,
    required String action,
    String? description,
    String expectedPin = '1234', // PIN افتراضي للاختبار
  }) async {
    return await ManagerApprovalDialog.show(
      context: context,
      action: action,
      description: description,
      onVerify: (pin) async {
        // محاكاة تأخير الشبكة
        await Future.delayed(const Duration(milliseconds: 500));
        return pin == expectedPin;
      },
    );
  }

  /// الإجراءات التي تتطلب موافقة المدير
  static const List<String> protectedActions = [
    'delete_product',      // حذف منتج
    'delete_customer',     // حذف عميل
    'void_sale',          // إلغاء فاتورة
    'refund',             // استرجاع
    'modify_price',       // تعديل السعر
    'apply_discount',     // تطبيق خصم
    'close_day',          // إغلاق اليوم
    'view_reports',       // عرض التقارير المالية
    'export_data',        // تصدير البيانات
    'modify_inventory',   // تعديل المخزون يدوياً
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
  /// طلب موافقة المدير
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

  /// طلب موافقة المدير بالاسم
  Future<bool> requestManagerApprovalFor(String actionCode) {
    return ManagerApprovalService.requestApprovalWithLocalVerification(
      context: this,
      action: ManagerApprovalService.getActionName(actionCode),
      description: ManagerApprovalService.getActionDescription(actionCode),
    );
  }
}
