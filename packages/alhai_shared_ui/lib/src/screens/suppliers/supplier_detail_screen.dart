import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:alhai_design_system/alhai_design_system.dart';
import '../../core/theme/app_sizes.dart';
import '../../core/router/routes.dart';
import 'package:alhai_database/alhai_database.dart';
import 'package:get_it/get_it.dart';
import 'package:alhai_l10n/alhai_l10n.dart';
import '../../providers/suppliers_providers.dart';
import '../../widgets/layout/app_header.dart';
import '../../widgets/common/shimmer_loading.dart';

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
    final db = GetIt.I<AppDatabase>();
    final supplier = await db.suppliersDao.getSupplierById(widget.supplierId!);
    List<PurchasesTableData> purchases = [];
    try {
      // Query purchases for this supplier
      final allPurchases = await db.purchasesDao.getAllPurchases(
        supplier?.storeId ?? '',
      );
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
    final isWideScreen = context.isDesktop;
    final isMediumScreen = !context.isMobile;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context);

    return Column(
      children: [
        // Header
        AppHeader(
          title: l10n.supplierDetailTitle,
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
              ? const Padding(
                  padding: EdgeInsets.all(AlhaiSpacing.md),
                  child: ShimmerList(itemCount: 5, itemHeight: 72),
                )
              : _supplier == null
              ? Center(
                  child: Text(
                    l10n.supplierNotFoundMsg,
                    style: TextStyle(
                      fontSize: 16,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                )
              : SingleChildScrollView(
                  padding: EdgeInsets.all(
                    isMediumScreen ? AlhaiSpacing.lg : AlhaiSpacing.md,
                  ),
                  child: _buildContent(isDark, isMediumScreen, l10n),
                ),
        ),
      ],
    );
  }

  Widget _buildContent(
    bool isDark,
    bool isMediumScreen,
    AppLocalizations l10n,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Action buttons row
        Row(
          children: [
            // Back button
            _ActionButton(
              icon: Icons.arrow_forward_rounded,
              label: l10n.back,
              isDark: isDark,
              onTap: () => context.go(AppRoutes.suppliers),
            ),
            const Spacer(),
            _ActionButton(
              icon: Icons.edit_outlined,
              label: l10n.edit,
              isDark: isDark,
              onTap: _editSupplier,
            ),
            SizedBox(width: AlhaiSpacing.xs),
            _ActionButton(
              icon: Icons.add_shopping_cart_rounded,
              label: l10n.newPurchaseInvoice,
              isDark: isDark,
              isPrimary: true,
              onTap: _newPurchase,
            ),
            SizedBox(width: AlhaiSpacing.xs),
            _ActionButton(
              icon: Icons.delete_outline_rounded,
              label: l10n.delete,
              isDark: isDark,
              isDestructive: true,
              onTap: _deleteSupplier,
            ),
          ],
        ),
        SizedBox(height: AlhaiSpacing.mdl),

        // Supplier info + Balance cards
        if (isMediumScreen)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(flex: 2, child: _buildSupplierInfoCard(isDark)),
              SizedBox(width: AlhaiSpacing.md),
              Expanded(
                child: Column(
                  children: [
                    _buildBalanceCard(isDark),
                    SizedBox(height: AlhaiSpacing.md),
                    _buildStatsCards(isDark),
                  ],
                ),
              ),
            ],
          )
        else ...[
          _buildSupplierInfoCard(isDark),
          SizedBox(height: AlhaiSpacing.md),
          _buildBalanceCard(isDark),
          SizedBox(height: AlhaiSpacing.md),
          _buildStatsCards(isDark),
        ],

        SizedBox(height: AlhaiSpacing.lg),

        // Recent purchases section
        _buildRecentPurchasesSection(isDark),
      ],
    );
  }

  Widget _buildSupplierInfoCard(bool isDark) {
    final l10n = AppLocalizations.of(context);
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(AlhaiSpacing.mdl),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.outlineVariant),
        boxShadow: AppShadows.of(context, size: ShadowSize.md),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row
          Row(
            children: [
              // Avatar
              Hero(
                tag: 'supplier-avatar-${widget.supplierId ?? ''}',
                child: Container(
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
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onPrimary,
                    ),
                  ),
                ),
              ),
              SizedBox(width: AlhaiSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _supplier!.name,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    SizedBox(height: AlhaiSpacing.xxs),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: AlhaiSpacing.xxs,
                      ),
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

          SizedBox(height: AlhaiSpacing.mdl),
          Divider(color: colorScheme.outlineVariant),
          SizedBox(height: AlhaiSpacing.md),

          // Contact info
          _InfoRow(
            icon: Icons.phone_outlined,
            label: l10n.phone,
            value: _supplier!.phone ?? '-',
            isDark: isDark,
          ),
          SizedBox(height: AlhaiSpacing.sm),
          _InfoRow(
            icon: Icons.email_outlined,
            label: l10n.supplierEmail,
            value: _supplier!.email ?? '-',
            isDark: isDark,
          ),
          SizedBox(height: AlhaiSpacing.sm),
          _InfoRow(
            icon: Icons.location_on_outlined,
            label: l10n.supplierAddress,
            value: _supplier!.address ?? '-',
            isDark: isDark,
          ),
        ],
      ),
    );
  }

  Widget _buildBalanceCard(bool isDark) {
    final l10n = AppLocalizations.of(context);
    final colorScheme = Theme.of(context).colorScheme;
    final balance = _supplier!.balance;
    final isNegative = balance < 0;
    final balanceColor = isNegative ? AppColors.error : AppColors.success;

    return Container(
      padding: const EdgeInsets.all(AlhaiSpacing.mdl),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: balanceColor.withValues(alpha: 0.3)),
        boxShadow: AppShadows.of(context, size: ShadowSize.md),
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
              SizedBox(width: AlhaiSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isNegative ? l10n.duePayments : l10n.balance,
                      style: TextStyle(
                        color: colorScheme.onSurfaceVariant,
                        fontSize: 13,
                      ),
                    ),
                    SizedBox(height: AlhaiSpacing.xxs),
                    Text(
                      '${balance.abs().toStringAsFixed(0)} ${l10n.sar}',
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
            SizedBox(height: AlhaiSpacing.md),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: _paySupplier,
                icon: const Icon(Icons.payment_rounded, size: 18),
                label: Text(l10n.registerPayment),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.error,
                  padding: const EdgeInsets.symmetric(
                    vertical: AlhaiSpacing.sm,
                  ),
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
    final l10n = AppLocalizations.of(context);
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
            label: l10n.totalPurchasesLabel,
            value: '${totalPurchases.toStringAsFixed(0)} ${l10n.sar}',
            color: AppColors.info,
            isDark: isDark,
          ),
        ),
        SizedBox(width: AlhaiSpacing.sm),
        Expanded(
          child: _StatCard(
            icon: Icons.calendar_today_outlined,
            label: l10n.lastPurchaseLabel,
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
    final l10n = AppLocalizations.of(context);
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              l10n.recentPurchasesLabel,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
            ),
            TextButton.icon(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(l10n.viewAllPurchases), // عرض جميع المشتريات
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                );
              },
              icon: const Icon(Icons.arrow_back_ios_rounded, size: 14),
              label: Text(l10n.viewAllPurchases), // عرض جميع المشتريات
              style: TextButton.styleFrom(foregroundColor: AppColors.primary),
            ),
          ],
        ),
        SizedBox(height: AlhaiSpacing.sm),

        // Purchase list
        if (_recentPurchases.isEmpty)
          Padding(
            padding: const EdgeInsets.all(AlhaiSpacing.xl),
            child: Center(
              child: Column(
                children: [
                  Icon(
                    Icons.shopping_cart_outlined,
                    size: 48,
                    color: colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
                  ),
                  SizedBox(height: AlhaiSpacing.sm),
                  Text(
                    l10n.noPurchasesLabel, // لا توجد مشتريات
                    style: TextStyle(color: colorScheme.onSurfaceVariant),
                  ),
                ],
              ),
            ),
          )
        else
          ...List.generate(_recentPurchases.length, (index) {
            final purchase = _recentPurchases[index];
            final isCompleted =
                purchase.status == 'received' || purchase.status == 'completed';
            final statusColor = isCompleted
                ? AppColors.success
                : AppColors.warning;

            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(AlhaiSpacing.md),
              decoration: BoxDecoration(
                color: colorScheme.surface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: colorScheme.outlineVariant),
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
                            color: colorScheme.onSurface,
                          ),
                        ),
                        SizedBox(height: AlhaiSpacing.xxs),
                        Text(
                          _formatDate(purchase.createdAt),
                          style: TextStyle(
                            color: colorScheme.onSurfaceVariant,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Status badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: AlhaiSpacing.xxs,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      isCompleted
                          ? l10n.completedLabel
                          : l10n.pendingStatusLabel,
                      style: TextStyle(
                        color: statusColor,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  SizedBox(width: AlhaiSpacing.sm),

                  // Amount
                  Text(
                    '${purchase.total.toStringAsFixed(0)} ${l10n.sar}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: colorScheme.onSurface,
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
    final l10n = AppLocalizations.of(context);
    final colorScheme = Theme.of(context).colorScheme;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: colorScheme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          l10n.deleteSupplier,
          style: TextStyle(color: colorScheme.onSurface),
        ),
        content: Text(
          l10n.deleteSupplierConfirm,
          style: TextStyle(color: colorScheme.onSurfaceVariant),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              l10n.deleteConfirmCancel,
              style: TextStyle(color: colorScheme.onSurfaceVariant),
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
                        content: Text(l10n.supplierDeletedMsg),
                        backgroundColor: AppColors.error,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    );
                    context.go(AppRoutes.suppliers);
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(l10n.errorDuringDeleteMsg(e)),
                        backgroundColor: AppColors.error,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
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
            child: Text(l10n.deleteConfirmBtn),
          ),
        ],
      ),
    );
  }

  void _paySupplier() {
    final colorScheme = Theme.of(context).colorScheme;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(AppLocalizations.of(context).registerPayment),
        backgroundColor: colorScheme.inverseSurface,
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
    final colorScheme = Theme.of(context).colorScheme;
    Color bgColor;
    Color fgColor;
    Color borderColor;

    if (isPrimary) {
      bgColor = AppColors.primary;
      fgColor = colorScheme.onPrimary;
      borderColor = AppColors.primary;
    } else if (isDestructive) {
      bgColor = AppColors.error.withValues(alpha: 0.1);
      fgColor = AppColors.error;
      borderColor = AppColors.error.withValues(alpha: 0.3);
    } else {
      bgColor = colorScheme.surface;
      fgColor = colorScheme.onSurfaceVariant;
      borderColor = colorScheme.outlineVariant;
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
              SizedBox(width: AlhaiSpacing.xs),
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
    final colorScheme = Theme.of(context).colorScheme;
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(AlhaiSpacing.xs),
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 18, color: colorScheme.onSurfaceVariant),
        ),
        SizedBox(width: AlhaiSpacing.sm),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            SizedBox(height: AlhaiSpacing.xxxs),
            Text(
              value,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: colorScheme.onSurface,
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
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(AlhaiSpacing.md),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(AlhaiSpacing.xs),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          SizedBox(height: AlhaiSpacing.sm),
          Text(
            label,
            style: TextStyle(fontSize: 11, color: colorScheme.onSurfaceVariant),
          ),
          SizedBox(height: AlhaiSpacing.xxs),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}
