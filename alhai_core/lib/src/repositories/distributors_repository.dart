import '../models/distributor.dart';
import '../models/paginated.dart';

/// Repository contract for distributor operations (v2.6.0)
/// Referenced by: distributor_portal, super_admin
abstract class DistributorsRepository {
  /// Gets a distributor by ID
  Future<Distributor> getDistributor(String id);

  /// Gets distributor by user ID
  Future<Distributor?> getByUserId(String userId);

  /// Gets all distributors (admin)
  Future<Paginated<Distributor>> getDistributors({
    int page = 1,
    int limit = 20,
    DistributorStatus? status,
    DistributorTier? tier,
    String? search,
  });

  /// Creates a new distributor application
  Future<Distributor> createDistributor({
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
  });

  /// Updates distributor profile
  Future<Distributor> updateDistributor(String id, Map<String, dynamic> data);

  /// Approves a distributor (admin)
  Future<Distributor> approveDistributor(String id, String approvedBy);

  /// Rejects a distributor (admin)
  Future<Distributor> rejectDistributor(
    String id,
    String rejectedBy,
    String reason,
  );

  /// Suspends a distributor (admin)
  Future<Distributor> suspendDistributor(String id, String reason);

  /// Upgrades distributor tier
  Future<Distributor> upgradeTier(String id, DistributorTier tier);

  /// Gets distributor statistics
  Future<DistributorStats> getStats(String id);

  /// Toggles featured status (admin)
  Future<Distributor> toggleFeatured(String id, bool isFeatured);
}

/// Distributor statistics
class DistributorStats {
  final String distributorId;
  final int totalProducts;
  final int activeProducts;
  final int totalOrders;
  final int pendingOrders;
  final double totalRevenue;
  final double monthlyRevenue;
  final int connectedStores;
  final double avgOrderValue;

  const DistributorStats({
    required this.distributorId,
    required this.totalProducts,
    required this.activeProducts,
    required this.totalOrders,
    required this.pendingOrders,
    required this.totalRevenue,
    required this.monthlyRevenue,
    required this.connectedStores,
    required this.avgOrderValue,
  });
}
