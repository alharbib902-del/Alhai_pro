/// معلومات العميل السريعة - Customer Quick Info
///
/// يعرض ملخص سريع للعميل عند ربطه بالفاتورة:
/// - الاسم ونوع العميل
/// - عدد الزيارات السابقة
/// - إجمالي المشتريات
/// - الرصيد المستحق (إن وجد)
/// - نقاط الولاء (إن وجدت)
library;

import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:alhai_database/alhai_database.dart';
import 'package:alhai_design_system/alhai_design_system.dart';

/// بيانات ملخص العميل المحملة من قاعدة البيانات
class _CustomerSummary {
  final String name;
  final String type;
  final int visitCount;
  final double totalSpent;
  final double balance;
  final int? loyaltyPoints;

  const _CustomerSummary({
    required this.name,
    required this.type,
    required this.visitCount,
    required this.totalSpent,
    required this.balance,
    this.loyaltyPoints,
  });
}

/// معلومات العميل السريعة - تظهر كبطاقة مدمجة
class CustomerQuickInfo extends StatefulWidget {
  final String customerId;
  final String storeId;
  final VoidCallback? onTap;

  const CustomerQuickInfo({
    super.key,
    required this.customerId,
    required this.storeId,
    this.onTap,
  });

  @override
  State<CustomerQuickInfo> createState() => _CustomerQuickInfoState();
}

class _CustomerQuickInfoState extends State<CustomerQuickInfo> {
  late Future<_CustomerSummary?> _summaryFuture;

  @override
  void initState() {
    super.initState();
    _summaryFuture = _loadCustomerSummary();
  }

  @override
  void didUpdateWidget(covariant CustomerQuickInfo oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.customerId != widget.customerId ||
        oldWidget.storeId != widget.storeId) {
      _summaryFuture = _loadCustomerSummary();
    }
  }

  Future<_CustomerSummary?> _loadCustomerSummary() async {
    final db = GetIt.I<AppDatabase>();

    // 1) بيانات العميل الأساسية + إحصائيات المبيعات
    final stats = await db.customersDao.getCustomerWithStats(
      widget.customerId,
      widget.storeId,
    );
    if (stats == null) return null;

    // 2) رصيد الحساب
    double balance = 0;
    try {
      final account = await db.accountsDao.getCustomerAccount(
        widget.customerId,
        widget.storeId,
      );
      if (account != null) {
        balance = account.balance;
      }
    } catch (_) {
      // لا يوجد حساب - الرصيد صفر
    }

    // 3) نقاط الولاء
    int? loyaltyPoints;
    try {
      final loyalty = await db.loyaltyDao.getCustomerLoyalty(
        widget.customerId,
        widget.storeId,
      );
      if (loyalty != null) {
        loyaltyPoints = loyalty.currentPoints;
      }
    } catch (_) {
      // نظام الولاء غير مفعل أو لا توجد نقاط
    }

    return _CustomerSummary(
      name: stats.customer.name,
      type: stats.customer.type,
      visitCount: stats.totalPurchases,
      totalSpent: stats.totalSpent,
      balance: balance,
      loyaltyPoints: loyaltyPoints,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.customerId.isEmpty) return const SizedBox.shrink();

    return FutureBuilder<_CustomerSummary?>(
      future: _summaryFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: AlhaiSpacing.xxs),
            child: SizedBox(
              height: 24,
              child: Center(
                child: SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            ),
          );
        }

        if (snapshot.hasError || snapshot.data == null) {
          return const SizedBox.shrink();
        }

        return _buildCard(context, snapshot.data!);
      },
    );
  }

  Widget _buildCard(BuildContext context, _CustomerSummary summary) {
    final colorScheme = Theme.of(context).colorScheme;
    final hasDebt = summary.balance > 0;

    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: AlhaiSpacing.xs),
        padding: const EdgeInsets.all(AlhaiSpacing.xs),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(AlhaiRadius.md),
          border: Border.all(
            color: hasDebt
                ? AppColors.warning.withValues(alpha: 0.5)
                : colorScheme.outlineVariant,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // اسم العميل ونوعه
            _buildCustomerHeader(context, summary, hasDebt),
            const SizedBox(height: AlhaiSpacing.xxs),
            // صف الإحصائيات
            _buildStatsRow(context, summary),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomerHeader(
    BuildContext context,
    _CustomerSummary summary,
    bool hasDebt,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    final isBusiness = summary.type == 'business';

    return Row(
      children: [
        Icon(
          isBusiness ? Icons.business_rounded : Icons.person_rounded,
          size: 14,
          color: colorScheme.onSurfaceVariant,
        ),
        const SizedBox(width: AlhaiSpacing.xxs),
        Expanded(
          child: Text(
            summary.name,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurface,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        if (hasDebt)
          Icon(Icons.warning_amber_rounded, size: 14, color: AppColors.warning),
        if (isBusiness) ...[
          const SizedBox(width: AlhaiSpacing.xxs),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
            decoration: BoxDecoration(
              color: AppColors.info.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AlhaiRadius.xs),
            ),
            child: const Text(
              'شركة',
              style: TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.w600,
                color: AppColors.info,
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildStatsRow(BuildContext context, _CustomerSummary summary) {
    final hasDebt = summary.balance > 0;
    final hasLoyalty =
        summary.loyaltyPoints != null && summary.loyaltyPoints! > 0;

    return Row(
      children: [
        _buildStatItem(
          context,
          label: 'الزيارات',
          value: summary.visitCount.toString(),
          icon: Icons.receipt_long_outlined,
        ),
        _buildDivider(context),
        _buildStatItem(
          context,
          label: 'المشتريات',
          value: '${summary.totalSpent.toStringAsFixed(0)} ر.س',
          icon: Icons.shopping_bag_outlined,
        ),
        _buildDivider(context),
        _buildStatItem(
          context,
          label: 'المستحق',
          value: '${summary.balance.toStringAsFixed(0)} ر.س',
          icon: Icons.account_balance_wallet_outlined,
          valueColor: hasDebt ? AppColors.error : AppColors.success,
        ),
        if (hasLoyalty) ...[
          _buildDivider(context),
          _buildStatItem(
            context,
            label: 'النقاط',
            value: summary.loyaltyPoints.toString(),
            icon: Icons.stars_rounded,
            valueColor: AppColors.secondary,
          ),
        ],
      ],
    );
  }

  Widget _buildStatItem(
    BuildContext context, {
    required String label,
    required String value,
    required IconData icon,
    Color? valueColor,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return Expanded(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: colorScheme.onSurfaceVariant),
          const SizedBox(height: 1),
          Text(
            value,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: valueColor ?? colorScheme.onSurface,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            label,
            style: TextStyle(fontSize: 9, color: colorScheme.onSurfaceVariant),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider(BuildContext context) {
    return Container(
      width: 1,
      height: 28,
      color: Theme.of(context).colorScheme.outlineVariant,
    );
  }
}
