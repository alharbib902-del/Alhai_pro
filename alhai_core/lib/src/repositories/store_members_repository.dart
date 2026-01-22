import '../models/paginated.dart';
import '../models/enums/user_role.dart';

/// Repository contract for store member operations (v2.6.0)
/// Manages store employees and their permissions
abstract class StoreMembersRepository {
  /// Gets all members of a store
  Future<Paginated<StoreMember>> getStoreMembers(
    String storeId, {
    int page = 1,
    int limit = 20,
    bool? activeOnly,
  });

  /// Gets a member by ID
  Future<StoreMember> getMember(String id);

  /// Gets member by user ID
  Future<StoreMember?> getMemberByUserId(String userId, String storeId);

  /// Adds a new member to store
  Future<StoreMember> addMember({
    required String storeId,
    required String userId,
    required UserRole role,
    String? nickname,
    List<String>? permissions,
  });

  /// Updates member role
  Future<StoreMember> updateRole(String memberId, UserRole role);

  /// Updates member permissions
  Future<StoreMember> updatePermissions(String memberId, List<String> permissions);

  /// Deactivates a member
  Future<void> deactivateMember(String memberId);

  /// Reactivates a member
  Future<StoreMember> reactivateMember(String memberId);

  /// Removes a member from store
  Future<void> removeMember(String memberId);

  /// Checks if user has permission
  Future<bool> hasPermission(String userId, String storeId, String permission);
}

/// Store member model
class StoreMember {
  final String id;
  final String storeId;
  final String userId;
  final String? userName;
  final String? userPhone;
  final UserRole role;
  final List<String> permissions;
  final bool isActive;
  final String? nickname;
  final DateTime joinedAt;
  final DateTime? lastActiveAt;

  const StoreMember({
    required this.id,
    required this.storeId,
    required this.userId,
    this.userName,
    this.userPhone,
    required this.role,
    required this.permissions,
    required this.isActive,
    this.nickname,
    required this.joinedAt,
    this.lastActiveAt,
  });
}

/// Available permissions
class StorePermissions {
  static const String viewDashboard = 'view_dashboard';
  static const String manageProducts = 'manage_products';
  static const String manageOrders = 'manage_orders';
  static const String manageInventory = 'manage_inventory';
  static const String manageCustomers = 'manage_customers';
  static const String viewReports = 'view_reports';
  static const String manageRefunds = 'manage_refunds';
  static const String manageDiscounts = 'manage_discounts';
  static const String manageCashDrawer = 'manage_cash_drawer';
  static const String manageMembers = 'manage_members';
  static const String manageSettings = 'manage_settings';
  
  static List<String> get all => [
    viewDashboard,
    manageProducts,
    manageOrders,
    manageInventory,
    manageCustomers,
    viewReports,
    manageRefunds,
    manageDiscounts,
    manageCashDrawer,
    manageMembers,
    manageSettings,
  ];
}
