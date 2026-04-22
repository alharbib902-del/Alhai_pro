import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:alhai_l10n/alhai_l10n.dart';
import '../../core/router/routes.dart';
import '../../core/utils/currency_formatter.dart';
import 'package:alhai_design_system/alhai_design_system.dart';
import '../../widgets/layout/app_header.dart';
import '../../providers/shifts_providers.dart';
import 'package:alhai_database/alhai_database.dart';

/// شاشة ملخص الوردية (بعد الإغلاق)
class ShiftSummaryScreen extends ConsumerStatefulWidget {
  const ShiftSummaryScreen({super.key});

  @override
  ConsumerState<ShiftSummaryScreen> createState() => _ShiftSummaryScreenState();
}

class _ShiftSummaryScreenState extends ConsumerState<ShiftSummaryScreen> {
  /// الحصول على آخر وردية مغلقة من قائمة ورديات اليوم
  ShiftsTableData? _getLastClosedShift(List<ShiftsTableData> shifts) {
    try {
      return shifts.firstWhere((s) => s.status == 'closed');
    } catch (_) {
      return null;
    }
  }

  /// حساب مدة الوردية بصيغة نصية
  String _formatDuration(
    DateTime openedAt,
    DateTime? closedAt,
    AppLocalizations l10n,
  ) {
    final end = closedAt ?? DateTime.now();
    final duration = end.difference(openedAt);
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    if (hours > 0 && minutes > 0) {
      return l10n.hoursAndMinutes(hours, minutes);
    } else if (hours > 0) {
      return l10n.hoursOnly(hours);
    } else {
      return l10n.minutesOnly(minutes);
    }
  }

  /// تنسيق المبلغ المالي
  String _formatAmount(double amount) {
    return CurrencyFormatter.formatNumber(amount, decimalDigits: 0);
  }

  @override
  Widget build(BuildContext context) {
    final isWideScreen = context.isDesktop;
    final isMediumScreen = !context.isMobile;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context);

    // مراقبة ورديات اليوم للحصول على آخر وردية مغلقة
    final todayShiftsAsync = ref.watch(todayShiftsProvider);
    final shift = todayShiftsAsync.whenOrNull(
      data: (shifts) => _getLastClosedShift(shifts),
    );

    return Column(
      children: [
        AppHeader(
          title: l10n.shiftSummary,
          subtitle: _getDateSubtitle(l10n),
          showSearch: false,
          searchHint: l10n.searchPlaceholder,
          onMenuTap: isWideScreen
              ? null
              : () => Scaffold.of(context).openDrawer(),
          onNotificationsTap: () => context.push('/notifications'),
          notificationsCount: 3,
          userName: l10n.defaultUserName,
          userRole: l10n.branchManager,
          onUserTap: () {},
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(
              isMediumScreen ? AlhaiSpacing.lg : AlhaiSpacing.md,
            ),
            child: _buildContent(
              isWideScreen,
              isMediumScreen,
              isDark,
              l10n,
              shift,
            ),
          ),
        ),
      ],
    );
  }

  String _getDateSubtitle(AppLocalizations l10n) {
    final now = DateTime.now();
    final dateStr = '${now.day}/${now.month}/${now.year}';
    return '$dateStr • ${l10n.mainBranch}';
  }

  Widget _buildContent(
    bool isWideScreen,
    bool isMediumScreen,
    bool isDark,
    AppLocalizations l10n,
    ShiftsTableData? shift,
  ) {
    if (isWideScreen) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 3,
            child: Column(
              children: [
                _buildSuccessCard(isDark, l10n, shift),
                SizedBox(height: AlhaiSpacing.lg),
                _buildStatsCard(isDark, l10n, shift),
              ],
            ),
          ),
          SizedBox(width: AlhaiSpacing.lg),
          Expanded(
            flex: 2,
            child: Column(
              children: [
                _buildCashStatusCard(isDark, l10n, shift),
                SizedBox(height: AlhaiSpacing.lg),
                _buildActionButtons(isDark, l10n),
              ],
            ),
          ),
        ],
      );
    }

    return Column(
      children: [
        _buildSuccessCard(isDark, l10n, shift),
        SizedBox(height: isMediumScreen ? AlhaiSpacing.lg : AlhaiSpacing.md),
        _buildStatsCard(isDark, l10n, shift),
        SizedBox(height: isMediumScreen ? AlhaiSpacing.lg : AlhaiSpacing.md),
        _buildCashStatusCard(isDark, l10n, shift),
        SizedBox(height: AlhaiSpacing.lg),
        _buildActionButtons(isDark, l10n),
      ],
    );
  }

  Widget _buildSuccessCard(
    bool isDark,
    AppLocalizations l10n,
    ShiftsTableData? shift,
  ) {
    // عرض وقت الإغلاق الفعلي من بيانات الوردية أو الوقت الحالي
    final closedTime = shift?.closedAt ?? DateTime.now();
    return Container(
      padding: const EdgeInsets.all(AlhaiSpacing.lg),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF22C55E), Color(0xFF16A34A)],
          begin: AlignmentDirectional.topStart,
          end: AlignmentDirectional.bottomEnd,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.check_circle_rounded,
              size: 40,
              color: Colors.white,
            ),
          ),
          SizedBox(height: AlhaiSpacing.md),
          Text(
            l10n.shiftClosedSuccessfully,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white.withValues(alpha: 0.95),
            ),
          ),
          SizedBox(height: AlhaiSpacing.xs),
          Text(
            closedTime.toString().substring(0, 16),
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.75),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsCard(
    bool isDark,
    AppLocalizations l10n,
    ShiftsTableData? shift,
  ) {
    // حساب القيم من بيانات الوردية الفعلية
    final duration = shift != null
        ? _formatDuration(shift.openedAt, shift.closedAt, l10n)
        : '--';
    final invoiceCount = shift?.totalSales ?? 0;
    // C-4 Session 3: shifts money columns are int cents; display as SAR.
    final totalSales = (shift?.totalSalesAmount ?? 0) / 100.0;
    final refunds = (shift?.totalRefundsAmount ?? 0) / 100.0;
    // مبيعات البطاقة والنقدية غير متوفرة مباشرة - نعرض إجمالي المبيعات ناقص المرتجعات كصافي
    // TODO: إضافة حقول مبيعات البطاقة والنقدية في جدول الورديات مستقبلاً
    final cashSales = shift != null
        ? ((shift.closingCash ?? 0) - shift.openingCash) / 100.0
        : 0.0;
    final cardSales = shift != null
        ? totalSales - cashSales.clamp(0, totalSales)
        : 0.0;

    return Container(
      padding: const EdgeInsets.all(AlhaiSpacing.mdl),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AlhaiSpacing.xs),
                decoration: BoxDecoration(
                  color: AppColors.info.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.analytics_rounded,
                  color: AppColors.info,
                  size: 20,
                ),
              ),
              SizedBox(width: AlhaiSpacing.sm),
              Text(
                l10n.shiftStatsLabel,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ],
          ),
          SizedBox(height: AlhaiSpacing.md),
          _StatRow(
            icon: Icons.timer_rounded,
            label: l10n.shiftDurationLabel,
            value: duration,
            color: AppColors.info,
            isDark: isDark,
          ),
          Divider(height: 20, color: Theme.of(context).dividerColor),
          _StatRow(
            icon: Icons.receipt_long_rounded,
            label: l10n.invoiceCountLabel,
            value: '$invoiceCount ${l10n.invoiceUnit}',
            color: AppColors.primary,
            isDark: isDark,
          ),
          Divider(height: 20, color: Theme.of(context).dividerColor),
          _StatRow(
            icon: Icons.trending_up_rounded,
            label: l10n.totalSales,
            value: '${_formatAmount(totalSales)} ${l10n.sar}',
            color: AppColors.success,
            isDark: isDark,
          ),
          Divider(height: 20, color: Theme.of(context).dividerColor),
          _StatRow(
            icon: Icons.credit_card_rounded,
            label: l10n.cardSalesLabel,
            value: '${_formatAmount(cardSales)} ${l10n.sar}',
            color: AppColors.card,
            isDark: isDark,
          ),
          Divider(height: 20, color: Theme.of(context).dividerColor),
          _StatRow(
            icon: Icons.money_rounded,
            label: l10n.cashSalesLabel,
            value:
                '${_formatAmount(cashSales.clamp(0, double.infinity))} ${l10n.sar}',
            color: AppColors.cash,
            isDark: isDark,
          ),
          Divider(height: 20, color: Theme.of(context).dividerColor),
          _StatRow(
            icon: Icons.assignment_return_rounded,
            label: l10n.refundsLabel,
            value: '${_formatAmount(refunds)} ${l10n.sar}',
            color: AppColors.error,
            isDark: isDark,
          ),
        ],
      ),
    );
  }

  Widget _buildCashStatusCard(
    bool isDark,
    AppLocalizations l10n,
    ShiftsTableData? shift,
  ) {
    // حساب قيم الصندوق من بيانات الوردية الفعلية
    // C-4 Session 3: shifts money columns are int cents; display as SAR.
    final expectedCash = (shift?.expectedCash ?? 0) / 100.0;
    final actualCash = (shift?.closingCash ?? 0) / 100.0;
    final difference = (shift?.difference ?? 0) / 100.0;

    // تحديد لون ورمز الفرق بناءً على القيمة
    final isBalanced = difference == 0;
    final isPositive = difference >= 0;
    final diffColor = isBalanced
        ? AppColors.success
        : (isPositive ? AppColors.info : AppColors.error);
    final diffIcon = isBalanced
        ? Icons.check_circle_rounded
        : (isPositive
              ? Icons.arrow_upward_rounded
              : Icons.arrow_downward_rounded);

    return Container(
      padding: const EdgeInsets.all(AlhaiSpacing.mdl),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AlhaiSpacing.xs),
                decoration: BoxDecoration(
                  color: AppColors.success.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.account_balance_wallet_rounded,
                  color: AppColors.success,
                  size: 20,
                ),
              ),
              SizedBox(width: AlhaiSpacing.sm),
              Text(
                l10n.drawerStatus,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ],
          ),
          SizedBox(height: AlhaiSpacing.md),
          _CashRow(
            label: l10n.expectedInDrawerLabel,
            value: '${_formatAmount(expectedCash)} ${l10n.sar}',
            isDark: isDark,
          ),
          const SizedBox(height: 10),
          _CashRow(
            label: l10n.actualInDrawerLabel,
            value: '${_formatAmount(actualCash)} ${l10n.sar}',
            isDark: isDark,
          ),
          Divider(height: 24, color: Theme.of(context).dividerColor),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                l10n.differenceLabel,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AlhaiSpacing.md,
                  vertical: AlhaiSpacing.xs,
                ),
                decoration: BoxDecoration(
                  color: diffColor.withValues(alpha: isDark ? 0.15 : 0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: diffColor.withValues(alpha: 0.3)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(diffIcon, color: diffColor, size: 16),
                    const SizedBox(width: 6),
                    Text(
                      '${_formatAmount(difference)} ${l10n.sar}',
                      style: TextStyle(
                        color: diffColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(bool isDark, AppLocalizations l10n) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _ActionButton(
                icon: Icons.print_rounded,
                label: l10n.printReport,
                color: AppColors.info,
                isDark: isDark,
                onTap: () {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text(l10n.printingReport)));
                },
              ),
            ),
            SizedBox(width: AlhaiSpacing.sm),
            Expanded(
              child: _ActionButton(
                icon: Icons.share_rounded,
                label: l10n.shareAction,
                color: AppColors.secondary,
                isDark: isDark,
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(l10n.sharingInProgress)),
                  );
                },
              ),
            ),
          ],
        ),
        SizedBox(height: AlhaiSpacing.md),
        SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            onPressed: () => context.go(AppRoutes.home),
            icon: const Icon(Icons.add_rounded, size: 20),
            label: Text(
              l10n.openNewShift,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: AlhaiSpacing.md),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () => context.go('/login'),
            icon: Icon(
              Icons.logout_rounded,
              size: 20,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            label: Text(
              l10n.logout,
              style: TextStyle(
                fontSize: 15,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              side: BorderSide(color: Theme.of(context).dividerColor),
            ),
          ),
        ),
      ],
    );
  }
}

class _StatRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  final bool isDark;

  const _StatRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AlhaiSpacing.xxs),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 16, color: color),
          ),
          SizedBox(width: AlhaiSpacing.sm),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}

class _CashRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isDark;

  const _CashRow({
    required this.label,
    required this.value,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final bool isDark;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: AlhaiSpacing.md),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.withValues(alpha: 0.3)),
          ),
          child: Column(
            children: [
              Icon(icon, color: color, size: 28),
              SizedBox(height: AlhaiSpacing.xs),
              Text(
                label,
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
