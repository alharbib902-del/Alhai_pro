import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/router/routes.dart';
import '../../data/local/app_database.dart';
import '../../di/injection.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../providers/suppliers_providers.dart';
import '../../widgets/layout/app_header.dart';

/// شاشة تفاصيل المورد
class SupplierDetailScreen extends ConsumerStatefulWidget {
  final String? supplierId;
  const SupplierDetailScreen({super.key, this.supplierId});

  @override
  ConsumerState<SupplierDetailScreen> createState() =>
      _SupplierDetailScreenState();
}

class _SupplierDetailScreenState extends ConsumerState<SupplierDetailScreen> {

  SuppliersTableData? _supplier;
  List<PurchasesTableData> _recentPurchases = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    if (widget.supplierId == null) {
      setState(() => _isLoading = false);
      return;
    }
    final db = getIt<AppDatabase>();
    final supplier = await db.suppliersDao.getSupplierById(widget.supplierId!);
    List<PurchasesTableData> purchases = [];
    try {
      // Query purchases for this supplier
      final allPurchases = await db.purchasesDao.getAllPurchases(supplier?.storeId ?? '');
      purchases = allPurchases
          .where((p) => p.supplierId == widget.supplierId)
          .toList();
    } catch (_) {}
    if (mounted) {
      setState(() {
        _supplier = supplier;
        _recentPurchases = purchases;
        _isLoading = false;
      });
    }
  }
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isWideScreen = screenWidth > 900;
    final isMediumScreen = screenWidth > 600;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;

    return Column(
              children: [
                // Header
                AppHeader(
                  title: 'تفاصيل المورد', // TODO: localize
                  subtitle: _supplier?.name ?? '',
                  onMenuTap: isWideScreen
                      ? null
                      : () => Scaffold.of(context).openDrawer(),
                  onNotificationsTap: () {},
                  notificationsCount: 3,
                  userName: 'أحمد',
                  userRole: l10n.dashboard,
                ),

                // Content
                Expanded(
                  child: _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : _supplier == null
                          ? Center(
                              child: Text(
                                'لم يتم العثور على المورد',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: isDark
                                      ? Colors.white.withValues(alpha: 0.6)
                                      : AppColors.textSecondary,
                                ),
                              ),
                            )
                          : SingleChildScrollView(
                              padding: EdgeInsets.all(isMediumScreen ? 24 : 16),
                              child:
                                  _buildContent(isDark, isMediumScreen, l10n),
                            ),
                ),
              ],
            );
  }

  Widget _buildContent(
      bool isDark, bool isMediumScreen, AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Action buttons row
        Row(
          children: [
            // Back button
            _ActionButton(
              icon: Icons.arrow_forward_rounded,
              label: 'رجوع', // TODO: localize
              isDark: isDark,
              onTap: () => context.go(AppRoutes.suppliers),
            ),
            const Spacer(),
            _ActionButton(
              icon: Icons.edit_outlined,
              label: 'تعديل', // TODO: localize
              isDark: isDark,
              onTap: _editSupplier,
            ),
            const SizedBox(width: 8),
            _ActionButton(
              icon: Icons.add_shopping_cart_rounded,
              label: 'طلب شراء جديد', // TODO: localize
              isDark: isDark,
              isPrimary: true,
              onTap: _newPurchase,
            ),
            const SizedBox(width: 8),
            _ActionButton(
              icon: Icons.delete_outline_rounded,
              label: 'حذف', // TODO: localize
              isDark: isDark,
              isDestructive: true,
              onTap: _deleteSupplier,
            ),
          ],
        ),
        const SizedBox(height: 20),

        // Supplier info + Balance cards
        if (isMediumScreen)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 2,
                child: _buildSupplierInfoCard(isDark),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  children: [
                    _buildBalanceCard(isDark),
                    const SizedBox(height: 16),
                    _buildStatsCards(isDark),
                  ],
                ),
              ),
            ],
          )
        else ...[
          _buildSupplierInfoCard(isDark),
          const SizedBox(height: 16),
          _buildBalanceCard(isDark),
          const SizedBox(height: 16),
          _buildStatsCards(isDark),
        ],

        const SizedBox(height: 24),

        // Recent purchases section
        _buildRecentPurchasesSection(isDark),
      ],
    );
  }

  Widget _buildSupplierInfoCard(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.08)
              : AppColors.border,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row
          Row(
            children: [
              // Avatar
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: AlignmentDirectional.topStart,
                    end: AlignmentDirectional.bottomEnd,
                    colors: [
                      AppColors.primary,
                      AppColors.primary.withValues(alpha: 0.7),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                alignment: Alignment.center,
                child: Text(
                  _supplier!.name.isNotEmpty ? _supplier!.name[0] : '?',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _supplier!.name,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        _supplier!.id,
                        style: const TextStyle(
                          color: AppColors.primary,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),
          Divider(
            color: isDark
                ? Colors.white.withValues(alpha: 0.08)
                : AppColors.border,
          ),
          const SizedBox(height: 16),

          // Contact info
          _InfoRow(
            icon: Icons.phone_outlined,
            label: 'الهاتف', // TODO: localize
            value: _supplier!.phone ?? '-',
            isDark: isDark,
          ),
          const SizedBox(height: 12),
          _InfoRow(
            icon: Icons.email_outlined,
            label: 'البريد', // TODO: localize
            value: _supplier!.email ?? '-',
            isDark: isDark,
          ),
          const SizedBox(height: 12),
          _InfoRow(
            icon: Icons.location_on_outlined,
            label: 'العنوان', // TODO: localize
            value: _supplier!.address ?? '-',
            isDark: isDark,
          ),
        ],
      ),
    );
  }

  Widget _buildBalanceCard(bool isDark) {
    final balance = _supplier!.balance;
    final isNegative = balance < 0;
    final balanceColor = isNegative ? AppColors.error : AppColors.success;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: balanceColor.withValues(alpha: 0.3),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: balanceColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  isNegative
                      ? Icons.trending_down_rounded
                      : Icons.trending_up_rounded,
                  color: balanceColor,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isNegative
                          ? 'مستحق للمورد' // TODO: localize
                          : 'رصيد لصالحنا', // TODO: localize
                      style: TextStyle(
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.6)
                            : AppColors.textSecondary,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${balance.abs().toStringAsFixed(0)} ر.س',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: balanceColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (isNegative) ...[
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: _paySupplier,
                icon: const Icon(Icons.payment_rounded, size: 18),
                label: const Text('سداد'), // TODO: localize
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.error,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatsCards(bool isDark) {
    final totalPurchases = _recentPurchases.fold<double>(
      0.0,
      (sum, p) => sum + p.total,
    );
    final lastPurchaseDate = _recentPurchases.isNotEmpty
        ? _recentPurchases.first.createdAt
        : null;

    return Row(
      children: [
        Expanded(
          child: _StatCard(
            icon: Icons.shopping_cart_outlined,
            label: 'إجمالي المشتريات', // TODO: localize
            value: '${totalPurchases.toStringAsFixed(0)} ر.س',
            color: AppColors.info,
            isDark: isDark,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatCard(
            icon: Icons.calendar_today_outlined,
            label: 'آخر شراء', // TODO: localize
            value: lastPurchaseDate != null
                ? _formatDate(lastPurchaseDate)
                : '-',
            color: AppColors.primary,
            isDark: isDark,
          ),
        ),
      ],
    );
  }

  Widget _buildRecentPurchasesSection(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'آخر المشتريات', // TODO: localize
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : AppColors.textPrimary,
              ),
            ),
            TextButton.icon(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('\u0639\u0631\u0636 \u062C\u0645\u064A\u0639 \u0627\u0644\u0645\u0634\u062A\u0631\u064A\u0627\u062A'), // عرض جميع المشتريات
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                );
              },
              icon: const Icon(Icons.arrow_back_ios_rounded, size: 14),
              label: const Text('\u0639\u0631\u0636 \u062C\u0645\u064A\u0639 \u0627\u0644\u0645\u0634\u062A\u0631\u064A\u0627\u062A'), // عرض جميع المشتريات
              style: TextButton.styleFrom(
                foregroundColor: AppColors.primary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Purchase list
        if (_recentPurchases.isEmpty)
          Padding(
            padding: const EdgeInsets.all(32),
            child: Center(
              child: Column(
                children: [
                  Icon(
                    Icons.shopping_cart_outlined,
                    size: 48,
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.3)
                        : AppColors.textSecondary.withValues(alpha: 0.4),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '\u0644\u0627 \u062A\u0648\u062C\u062F \u0645\u0634\u062A\u0631\u064A\u0627\u062A', // لا توجد مشتريات
                    style: TextStyle(
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.5)
                          : AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          )
        else
          ...List.generate(_recentPurchases.length, (index) {
            final purchase = _recentPurchases[index];
            final isCompleted = purchase.status == 'received' ||
                purchase.status == 'completed';
            final statusColor =
                isCompleted ? AppColors.success : AppColors.warning;

            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E293B) : Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.08)
                      : AppColors.border,
                ),
              ),
              child: Row(
                children: [
                  // Status icon
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      isCompleted
                          ? Icons.check_rounded
                          : Icons.schedule_rounded,
                      color: statusColor,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 14),

                  // Purchase info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          purchase.purchaseNumber,
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color:
                                isDark ? Colors.white : AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _formatDate(purchase.createdAt),
                          style: TextStyle(
                            color: isDark
                                ? Colors.white.withValues(alpha: 0.5)
                                : AppColors.textSecondary,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Status badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      isCompleted
                          ? 'مكتمل' // TODO: localize
                          : 'معلق', // TODO: localize
                      style: TextStyle(
                        color: statusColor,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Amount
                  Text(
                    '${purchase.total.toStringAsFixed(0)} ر.س',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: isDark ? Colors.white : AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            );
          }),
      ],
    );
  }
  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void _editSupplier() {
    if (widget.supplierId != null) {
      context.push('/suppliers/${widget.supplierId}/edit');
    }
  }

  bool get isDark => Theme.of(context).brightness == Brightness.dark;

  void _deleteSupplier() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor:
            isDark ? const Color(0xFF1E293B) : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'حذف المورد', // TODO: localize
          style: TextStyle(
            color: isDark ? Colors.white : AppColors.textPrimary,
          ),
        ),
        content: Text(
          'هل تريد حذف هذا المورد؟ لا يمكن التراجع عن هذا الإجراء.', // TODO: localize
          style: TextStyle(
            color: isDark
                ? Colors.white.withValues(alpha: 0.7)
                : AppColors.textSecondary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'إلغاء', // TODO: localize
              style: TextStyle(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.7)
                    : AppColors.textSecondary,
              ),
            ),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.pop(ctx);
              if (widget.supplierId != null) {
                try {
                  await deleteSupplier(ref, widget.supplierId!);
                  if (mounted) {
                    HapticFeedback.mediumImpact();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text('تم حذف المورد'), // TODO: localize
                        backgroundColor: AppColors.error,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                    );
                    context.go(AppRoutes.suppliers);
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('حدث خطأ أثناء الحذف: $e'),
                        backgroundColor: AppColors.error,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                    );
                  }
                }
              }
            },
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.error,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text('حذف'), // TODO: localize
          ),
        ],
      ),
    );
  }

  void _paySupplier() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('تسجيل دفعة للمورد'), // TODO: localize
        backgroundColor: isDark ? const Color(0xFF334155) : null,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _newPurchase() {
    context.push(AppRoutes.purchaseForm);
  }
}

// =============================================================================
// HELPER WIDGETS
// =============================================================================

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isDark;
  final VoidCallback? onTap;
  final bool isPrimary;
  final bool isDestructive;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.isDark,
    this.onTap,
    this.isPrimary = false,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    Color bgColor;
    Color fgColor;
    Color borderColor;

    if (isPrimary) {
      bgColor = AppColors.primary;
      fgColor = Colors.white;
      borderColor = AppColors.primary;
    } else if (isDestructive) {
      bgColor = AppColors.error.withValues(alpha: 0.1);
      fgColor = AppColors.error;
      borderColor = AppColors.error.withValues(alpha: 0.3);
    } else {
      bgColor = isDark ? const Color(0xFF1E293B) : Colors.white;
      fgColor = isDark ? Colors.white.withValues(alpha: 0.8) : AppColors.textSecondary;
      borderColor = isDark
          ? Colors.white.withValues(alpha: 0.08)
          : AppColors.border;
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: borderColor),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 18, color: fgColor),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  color: fgColor,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool isDark;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isDark
                ? Colors.white.withValues(alpha: 0.05)
                : AppColors.backgroundSecondary,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            size: 18,
            color: isDark
                ? Colors.white.withValues(alpha: 0.5)
                : AppColors.textSecondary,
          ),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: isDark
                    ? Colors.white.withValues(alpha: 0.4)
                    : AppColors.textTertiary,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              value,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: isDark ? Colors.white : AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  final bool isDark;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.08)
              : AppColors.border,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 12),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: isDark
                  ? Colors.white.withValues(alpha: 0.5)
                  : AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: isDark ? Colors.white : AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
