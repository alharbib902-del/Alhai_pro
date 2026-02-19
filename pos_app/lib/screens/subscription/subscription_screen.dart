import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../data/local/app_database.dart';
import '../../di/injection.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../providers/products_providers.dart';
import '../../providers/settings_db_providers.dart';
import '../../widgets/layout/app_header.dart';

class SubscriptionScreen extends ConsumerStatefulWidget {
  const SubscriptionScreen({super.key});

  @override
  ConsumerState<SubscriptionScreen> createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends ConsumerState<SubscriptionScreen> {
  bool _isLoading = true;
  String? _error;
  OrganizationsTableData? _organization;
  SubscriptionsTableData? _subscription;
  int _storesCount = 0;
  int _usersCount = 0;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final db = getIt<AppDatabase>();
      final storeId = ref.read(currentStoreIdProvider);
      if (storeId == null) {
        setState(() {
          _isLoading = false;
          _error = 'لم يتم تحديد المتجر';
        });
        return;
      }

      // Try to get organization ID from settings
      final orgId = await getSettingValue(db, storeId, 'organization_id');

      OrganizationsTableData? org;
      SubscriptionsTableData? sub;

      if (orgId != null) {
        org = await db.organizationsDao.getOrganizationById(orgId);
        sub = await db.organizationsDao.getActiveSubscription(orgId);
        // If no active subscription, try to get any subscription
        sub ??= await db.organizationsDao.getSubscription(orgId);
      }

      // Get usage stats
      final stores = await db.storesDao.getAllStores();
      final users = await db.usersDao.getAllUsers(storeId);

      if (mounted) {
        setState(() {
          _organization = org;
          _subscription = sub;
          _storesCount = stores.length;
          _usersCount = users.length;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _error = 'حدث خطأ أثناء تحميل بيانات الاشتراك: $e';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final size = MediaQuery.of(context).size;
    final isWide = size.width > 900;
    final l10n = AppLocalizations.of(context)!;

    return Column(
      children: [
        AppHeader(
          title: l10n.subscription,
          onMenuTap: isWide ? null : () => Scaffold.of(context).openDrawer(),
          onNotificationsTap: () => context.push('/notifications'),
          notificationsCount: 0,
          userName: l10n.defaultUserName,
          userRole: l10n.branchManager,
        ),
        Expanded(
          child: _buildBody(isDark, l10n),
        ),
      ],
    );
  }

  Widget _buildBody(bool isDark, AppLocalizations l10n) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: AppColors.error.withValues(alpha: 0.7)),
            const SizedBox(height: 16),
            Text(
              _error!,
              style: TextStyle(fontSize: 16, color: isDark ? Colors.white54 : AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: _loadData,
              icon: const Icon(Icons.refresh),
              label: Text(l10n.retry),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Current plan card
          _buildCurrentPlanCard(isDark),
          const SizedBox(height: 24),
          // Usage stats
          _buildUsageStats(isDark),
          const SizedBox(height: 24),
          // Features list (if subscription exists)
          if (_subscription != null) ...[
            _buildFeaturesSection(isDark),
            const SizedBox(height: 24),
          ],
          Text('الخطط المتاحة', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: isDark ? Colors.white : AppColors.textPrimary)),
          const SizedBox(height: 16),
          // Plans grid
          LayoutBuilder(
            builder: (context, constraints) {
              final crossCount = constraints.maxWidth > 800 ? 4 : (constraints.maxWidth > 500 ? 2 : 1);
              return GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: crossCount,
                crossAxisSpacing: 12, mainAxisSpacing: 12,
                childAspectRatio: 0.75,
                children: [
                  _buildPlanCard('مجانية', '0', ['10 منتجات', 'فرع واحد', 'موظف واحد', 'تقارير أساسية'], false, isDark),
                  _buildPlanCard('أساسية', '99', ['100 منتج', '3 فروع', '5 موظفين', 'تقارير متقدمة', 'دعم بريدي'], false, isDark),
                  _buildPlanCard('احترافية', '199', ['منتجات غير محدودة', '10 فروع', '20 موظف', 'كل التقارير', 'دعم فوري', 'AI ميزات'], true, isDark),
                  _buildPlanCard('مؤسسية', '499', ['كل شيء غير محدود', 'فروع غير محدودة', 'موظفين غير محدود', 'API متقدم', 'مدير حساب خاص', 'تخصيص كامل'], false, isDark),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentPlanCard(bool isDark) {
    if (_subscription == null) {
      // No active subscription
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: [Colors.grey.shade600, Colors.grey.shade800]),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text('خطتك الحالية', style: TextStyle(color: Colors.white70, fontSize: 14)),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(color: Colors.white.withValues(alpha:0.2), borderRadius: BorderRadius.circular(20)),
                  child: const Text('غير مشترك', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text('لا يوجد اشتراك نشط', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Row(
              children: [
                Icon(Icons.info_outline, color: Colors.white70, size: 18),
                SizedBox(width: 6),
                Text('اختر خطة للبدء', style: TextStyle(color: Colors.white70, fontSize: 14)),
              ],
            ),
          ],
        ),
      );
    }

    final sub = _subscription!;
    final planName = sub.plan;
    final status = sub.status;
    final isActive = status == 'active';
    final endDate = sub.currentPeriodEnd;
    final startDate = sub.currentPeriodStart;
    final price = sub.amount;
    final currency = sub.currency == 'SAR' ? 'ر.س' : sub.currency;

    // Calculate remaining days
    final totalDays = endDate.difference(startDate).inDays;
    int remainingDays = endDate.difference(DateTime.now()).inDays;
    if (remainingDays < 0) remainingDays = 0;
    double progress = 0.0;
    if (totalDays > 0) {
      progress = 1.0 - (remainingDays / totalDays);
      if (progress < 0) progress = 0;
      if (progress > 1) progress = 1;
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [AppColors.primary, Color(0xFF5B2D8E)]),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('خطتك الحالية', style: TextStyle(color: Colors.white70, fontSize: 14)),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(color: Colors.white.withValues(alpha:0.2), borderRadius: BorderRadius.circular(20)),
                child: Text(
                  isActive ? 'نشط' : status,
                  style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(planName, style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
          if (price > 0) ...[
            const SizedBox(height: 4),
            Text('${price.toStringAsFixed(0)} $currency / شهر', style: const TextStyle(color: Colors.white70, fontSize: 14)),
          ],
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.timer_outlined, color: Colors.white70, size: 18),
              const SizedBox(width: 6),
              Text(
                'متبقي $remainingDays يوم',
                style: TextStyle(
                  color: remainingDays <= 7 ? Colors.orange.shade200 : Colors.white70,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          LinearProgressIndicator(
            value: progress,
            backgroundColor: Colors.white24,
            color: remainingDays <= 7 ? Colors.orange.shade300 : Colors.greenAccent,
            minHeight: 6,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Text(
                'من: ${_formatDate(startDate)}',
                style: const TextStyle(color: Colors.white54, fontSize: 12),
              ),
              const SizedBox(width: 16),
              Text(
                'إلى: ${_formatDate(endDate)}',
                style: const TextStyle(color: Colors.white54, fontSize: 12),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildUsageStats(bool isDark) {
    final maxStores = _organization?.maxStores;
    final maxUsers = _organization?.maxUsers;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('إحصائيات الاستخدام', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: isDark ? Colors.white : AppColors.textPrimary)),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildUsageTile(
                'الفروع',
                '$_storesCount',
                maxStores != null ? 'من $maxStores' : 'غير محدود',
                Icons.store_outlined,
                maxStores != null && _storesCount >= maxStores ? Colors.red : Colors.blue,
                isDark,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildUsageTile(
                'الموظفين',
                '$_usersCount',
                maxUsers != null ? 'من $maxUsers' : 'غير محدود',
                Icons.people_outlined,
                maxUsers != null && _usersCount >= maxUsers ? Colors.red : Colors.green,
                isDark,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildUsageTile(String title, String value, String limit, IconData icon, Color color, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isDark ? Colors.white.withValues(alpha: 0.1) : AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 24),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: color.withValues(alpha:0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(limit, style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.w500)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(value, style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: isDark ? Colors.white : AppColors.textPrimary)),
          const SizedBox(height: 4),
          Text(title, style: TextStyle(fontSize: 13, color: isDark ? Colors.white54 : AppColors.textSecondary)),
        ],
      ),
    );
  }

  Widget _buildFeaturesSection(bool isDark) {
    final featuresRaw = _subscription?.features ?? '';
    List<String> features = [];
    if (featuresRaw.isNotEmpty && featuresRaw != '{}') {
      // features may be comma-separated or JSON array string
      if (featuresRaw.startsWith('[')) {
        // Try to parse as simple list
        features = featuresRaw
            .replaceAll('[', '')
            .replaceAll(']', '')
            .replaceAll('"', '')
            .split(',')
            .map((s) => s.trim())
            .where((s) => s.isNotEmpty)
            .toList();
      } else {
        features = featuresRaw.split(',').map((s) => s.trim()).where((s) => s.isNotEmpty).toList();
      }
    }

    if (features.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('ميزات الاشتراك', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: isDark ? Colors.white : AppColors.textPrimary)),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E293B) : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: isDark ? Colors.white.withValues(alpha: 0.1) : AppColors.border),
          ),
          child: Column(
            children: features.map((f) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  const Icon(Icons.check_circle, color: Colors.green, size: 18),
                  const SizedBox(width: 8),
                  Expanded(child: Text(f, style: TextStyle(color: isDark ? Colors.white70 : Colors.black87))),
                ],
              ),
            )).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildPlanCard(String name, String price, List<String> features, bool isPopular, bool isDark) {
    final isCurrentPlan = _subscription?.plan.toLowerCase() == name.toLowerCase();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isPopular ? AppColors.primary : (isCurrentPlan ? Colors.green : (isDark ? Colors.white12 : Colors.grey.shade200)),
          width: isPopular || isCurrentPlan ? 2 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isPopular) Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            margin: const EdgeInsets.only(bottom: 8),
            decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(8)),
            child: const Text('الأكثر شيوعاً', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
          ),
          if (isCurrentPlan) Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            margin: const EdgeInsets.only(bottom: 8),
            decoration: BoxDecoration(color: Colors.green, borderRadius: BorderRadius.circular(8)),
            child: const Text('خطتك الحالية', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
          ),
          Text(name, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: isDark ? Colors.white : AppColors.textPrimary)),
          const SizedBox(height: 4),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(price, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: AppColors.primary)),
              const SizedBox(width: 4),
              Text('ر.س/شهر', style: TextStyle(fontSize: 12, color: isDark ? Colors.white54 : AppColors.textSecondary)),
            ],
          ),
          const SizedBox(height: 12),
          ...features.map((f) => Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.green, size: 16),
                const SizedBox(width: 6),
                Expanded(child: Text(f, style: TextStyle(fontSize: 12, color: isDark ? Colors.white70 : Colors.black54))),
              ],
            ),
          )),
          const Spacer(),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: isCurrentPlan ? null : () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: isCurrentPlan
                    ? Colors.grey
                    : (isPopular ? AppColors.primary : (isDark ? Colors.white12 : Colors.grey.shade100)),
                foregroundColor: isCurrentPlan
                    ? Colors.white
                    : (isPopular ? Colors.white : (isDark ? Colors.white : Colors.black87)),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: Text(isCurrentPlan ? 'الخطة الحالية' : 'اختيار'),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.year}/${date.month.toString().padLeft(2, '0')}/${date.day.toString().padLeft(2, '0')}';
  }
}
