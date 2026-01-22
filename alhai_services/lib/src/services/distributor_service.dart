import 'package:alhai_core/alhai_core.dart';

/// خدمة إدارة الموزعين
/// تستخدم من: distributor_portal, super_admin
class DistributorService {
  final DistributorsRepository _distributorsRepo;

  DistributorService(this._distributorsRepo);

  // ==================== الموزعين ====================

  /// الحصول على موزع بالـ ID
  Future<Distributor> getDistributor(String id) async {
    return await _distributorsRepo.getDistributor(id);
  }

  /// الحصول على موزع بـ User ID
  Future<Distributor?> getDistributorByUserId(String userId) async {
    return await _distributorsRepo.getByUserId(userId);
  }

  /// الحصول على قائمة الموزعين (للأدمن)
  Future<Paginated<Distributor>> getDistributors({
    int page = 1,
    int limit = 20,
    DistributorStatus? status,
    DistributorTier? tier,
    String? search,
  }) async {
    return await _distributorsRepo.getDistributors(
      page: page,
      limit: limit,
      status: status,
      tier: tier,
      search: search,
    );
  }

  /// تقديم طلب موزع جديد
  Future<Distributor> applyAsDistributor({
    required String userId,
    required String companyName,
    required String commercialRegister,
    required String vatNumber,
    String? companyNameEn,
    String? logoUrl,
    String? address,
    String? city,
    String? phone,
    String? email,
    String? website,
  }) async {
    return await _distributorsRepo.createDistributor(
      userId: userId,
      companyName: companyName,
      commercialRegister: commercialRegister,
      vatNumber: vatNumber,
      companyNameEn: companyNameEn,
      logoUrl: logoUrl,
      address: address,
      city: city,
      phone: phone,
      email: email,
      website: website,
    );
  }

  /// تحديث بيانات الموزع
  Future<Distributor> updateDistributor(String id, Map<String, dynamic> data) async {
    return await _distributorsRepo.updateDistributor(id, data);
  }

  // ==================== إدارة الحالة (Admin) ====================

  /// الموافقة على موزع
  Future<Distributor> approveDistributor(String id, String approvedBy) async {
    return await _distributorsRepo.approveDistributor(id, approvedBy);
  }

  /// رفض موزع
  Future<Distributor> rejectDistributor(String id, String rejectedBy, String reason) async {
    return await _distributorsRepo.rejectDistributor(id, rejectedBy, reason);
  }

  /// إيقاف موزع
  Future<Distributor> suspendDistributor(String id, String reason) async {
    return await _distributorsRepo.suspendDistributor(id, reason);
  }

  /// ترقية مستوى الموزع
  Future<Distributor> upgradeTier(String id, DistributorTier tier) async {
    return await _distributorsRepo.upgradeTier(id, tier);
  }

  /// تبديل حالة المميز
  Future<Distributor> toggleFeatured(String id, bool isFeatured) async {
    return await _distributorsRepo.toggleFeatured(id, isFeatured);
  }

  // ==================== الإحصائيات ====================

  /// إحصائيات الموزع
  Future<DistributorStats> getStats(String distributorId) async {
    return await _distributorsRepo.getStats(distributorId);
  }
}
