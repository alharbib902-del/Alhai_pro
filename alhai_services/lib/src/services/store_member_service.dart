import 'package:alhai_core/alhai_core.dart';

/// خدمة إدارة موظفي المتجر
/// تستخدم من: admin_pos, cashier
class StoreMemberService {
  final StoreMembersRepository _membersRepo;

  StoreMemberService(this._membersRepo);

  /// الحصول على موظفي المتجر
  Future<Paginated<StoreMember>> getStoreMembers(
    String storeId, {
    int page = 1,
    int limit = 20,
    bool? activeOnly,
  }) async {
    return await _membersRepo.getStoreMembers(
      storeId,
      page: page,
      limit: limit,
      activeOnly: activeOnly,
    );
  }

  /// الحصول على موظف بالـ ID
  Future<StoreMember> getMember(String id) async {
    return await _membersRepo.getMember(id);
  }

  /// الحصول على موظف بـ User ID
  Future<StoreMember?> getMemberByUserId(String userId, String storeId) async {
    return await _membersRepo.getMemberByUserId(userId, storeId);
  }

  /// إضافة موظف جديد
  Future<StoreMember> addMember({
    required String storeId,
    required String userId,
    required UserRole role,
    String? nickname,
    List<String>? permissions,
  }) async {
    return await _membersRepo.addMember(
      storeId: storeId,
      userId: userId,
      role: role,
      nickname: nickname,
      permissions: permissions,
    );
  }

  /// تحديث صلاحية الموظف
  Future<StoreMember> updateRole(String memberId, UserRole role) async {
    return await _membersRepo.updateRole(memberId, role);
  }

  /// تحديث صلاحيات الموظف
  Future<StoreMember> updatePermissions(
    String memberId,
    List<String> permissions,
  ) async {
    return await _membersRepo.updatePermissions(memberId, permissions);
  }

  /// تعطيل موظف
  Future<void> deactivateMember(String memberId) async {
    await _membersRepo.deactivateMember(memberId);
  }

  /// إعادة تفعيل موظف
  Future<StoreMember> reactivateMember(String memberId) async {
    return await _membersRepo.reactivateMember(memberId);
  }

  /// إزالة موظف من المتجر
  Future<void> removeMember(String memberId) async {
    await _membersRepo.removeMember(memberId);
  }

  /// التحقق من صلاحية
  Future<bool> hasPermission(
    String userId,
    String storeId,
    String permission,
  ) async {
    return await _membersRepo.hasPermission(userId, storeId, permission);
  }

  /// الحصول على جميع الصلاحيات المتاحة
  List<String> getAllPermissions() {
    return StorePermissions.all;
  }
}
