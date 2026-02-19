/// خدمة الصلاحيات وإدارة الأدوار
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';

/// أنواع الأدوار في النظام
enum UserRole {
  cashier,    // كاشير - صلاحيات محدودة
  supervisor, // مشرف - صلاحيات متوسطة
  manager,    // مدير - صلاحيات عالية
  owner,      // مالك - كل الصلاحيات
}

/// صلاحيات النظام
enum Permission {
  // Sales
  createSale,
  viewSales,
  cancelSale,
  applyDiscount,
  applyLargeDiscount, // > 20%
  
  // Refunds
  createRefund,
  approveRefund,
  
  // Products
  viewProducts,
  createProduct,
  editProduct,
  deleteProduct,
  
  // Inventory
  viewInventory,
  adjustInventory,
  
  // Purchases
  viewPurchases,
  createPurchase,
  
  // Suppliers
  viewSuppliers,
  manageSuppliers,
  
  // Customers
  viewCustomers,
  manageCustomers,
  
  // Reports
  viewBasicReports,
  viewFullReports,
  exportReports,
  
  // Settings
  viewSettings,
  editSettings,
  manageUsers,
  
  // Finance
  viewCashDrawer,
  openCloseShift,
  viewProfits,
}

/// خريطة صلاحيات كل دور
class RolePermissions {
  static const Map<UserRole, Set<Permission>> permissions = {
    UserRole.cashier: {
      Permission.createSale,
      Permission.viewSales,
      Permission.applyDiscount,
      Permission.viewProducts,
      Permission.viewCustomers,
      Permission.viewSettings,
      Permission.openCloseShift,
      Permission.viewCashDrawer,
    },
    
    UserRole.supervisor: {
      // All cashier permissions
      Permission.createSale,
      Permission.viewSales,
      Permission.cancelSale,
      Permission.applyDiscount,
      Permission.applyLargeDiscount,
      Permission.viewProducts,
      Permission.viewCustomers,
      Permission.viewSettings,
      Permission.openCloseShift,
      Permission.viewCashDrawer,
      // Additional supervisor permissions
      Permission.createRefund,
      Permission.viewInventory,
      Permission.viewBasicReports,
      Permission.viewPurchases,
      Permission.viewSuppliers,
    },
    
    UserRole.manager: {
      // All supervisor permissions
      Permission.createSale,
      Permission.viewSales,
      Permission.cancelSale,
      Permission.applyDiscount,
      Permission.applyLargeDiscount,
      Permission.viewProducts,
      Permission.viewCustomers,
      Permission.viewSettings,
      Permission.openCloseShift,
      Permission.viewCashDrawer,
      Permission.createRefund,
      Permission.viewInventory,
      Permission.viewBasicReports,
      Permission.viewPurchases,
      Permission.viewSuppliers,
      // Additional manager permissions
      Permission.approveRefund,
      Permission.createProduct,
      Permission.editProduct,
      Permission.adjustInventory,
      Permission.createPurchase,
      Permission.manageSuppliers,
      Permission.manageCustomers,
      Permission.viewFullReports,
      Permission.exportReports,
      Permission.editSettings,
    },
    
    UserRole.owner: {
      // كل الصلاحيات
      Permission.createSale,
      Permission.viewSales,
      Permission.cancelSale,
      Permission.applyDiscount,
      Permission.applyLargeDiscount,
      Permission.createRefund,
      Permission.approveRefund,
      Permission.viewProducts,
      Permission.createProduct,
      Permission.editProduct,
      Permission.deleteProduct,
      Permission.viewInventory,
      Permission.adjustInventory,
      Permission.viewPurchases,
      Permission.createPurchase,
      Permission.viewSuppliers,
      Permission.manageSuppliers,
      Permission.viewCustomers,
      Permission.manageCustomers,
      Permission.viewBasicReports,
      Permission.viewFullReports,
      Permission.exportReports,
      Permission.viewSettings,
      Permission.editSettings,
      Permission.manageUsers,
      Permission.viewCashDrawer,
      Permission.openCloseShift,
      Permission.viewProfits,
    },
  };
  
  /// التحقق من وجود صلاحية
  static bool hasPermission(UserRole role, Permission permission) {
    return permissions[role]?.contains(permission) ?? false;
  }
  
  /// الحصول على كل صلاحيات دور معين
  static Set<Permission> getPermissions(UserRole role) {
    return permissions[role] ?? {};
  }
  
  /// الحصول على اسم الدور بالعربية
  static String getRoleName(UserRole role) {
    switch (role) {
      case UserRole.cashier:
        return 'كاشير';
      case UserRole.supervisor:
        return 'مشرف';
      case UserRole.manager:
        return 'مدير';
      case UserRole.owner:
        return 'مالك';
    }
  }
}

/// حالة المستخدم الحالي
class CurrentUser {
  final String id;
  final String name;
  final UserRole role;
  final String storeId;
  
  const CurrentUser({
    required this.id,
    required this.name,
    required this.role,
    required this.storeId,
  });
  
  bool hasPermission(Permission permission) {
    return RolePermissions.hasPermission(role, permission);
  }
  
  bool get isCashier => role == UserRole.cashier;
  bool get isSupervisor => role == UserRole.supervisor;
  bool get isManager => role == UserRole.manager;
  bool get isOwner => role == UserRole.owner;
  
  bool get canManageInventory => hasPermission(Permission.adjustInventory);
  bool get canApproveRefunds => hasPermission(Permission.approveRefund);
  bool get canViewReports => hasPermission(Permission.viewBasicReports);
  bool get canManageUsers => hasPermission(Permission.manageUsers);
}

// =============================================================================
// PROVIDERS
// =============================================================================

/// مزود المستخدم الحالي
final currentUserProvider = StateProvider<CurrentUser?>((ref) => null);

/// مزود الدور الحالي
final currentRoleProvider = Provider<UserRole?>((ref) {
  return ref.watch(currentUserProvider)?.role;
});

/// مزود التحقق من صلاحية معينة
final hasPermissionProvider = Provider.family<bool, Permission>((ref, permission) {
  final user = ref.watch(currentUserProvider);
  return user?.hasPermission(permission) ?? false;
});

/// مزود قائمة الصلاحيات المتاحة
final availablePermissionsProvider = Provider<Set<Permission>>((ref) {
  final role = ref.watch(currentRoleProvider);
  if (role == null) return {};
  return RolePermissions.getPermissions(role);
});
