/// Payment Reports Screen - Payment method breakdown
///
/// Date range filter, breakdown by method (cash, card, credit),
/// pie chart visualization, total and count per method.
/// Supports: RTL Arabic, dark/light theme, responsive layout.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:get_it/get_it.dart';
import 'package:alhai_shared_ui/alhai_shared_ui.dart';
import 'package:alhai_l10n/alhai_l10n.dart';
import 'package:alhai_database/alhai_database.dart';
import 'package:alhai_auth/alhai_auth.dart';
import 'package:alhai_design_system/alhai_design_system.dart' show AlhaiBreakpoints, AlhaiSpacing;
// alhai_design_system is re-exported via alhai_shared_ui
import 'dart:math' as math;
import '../../core/services/sentry_service.dart';

/// شاشة تقارير المدفوعات
class PaymentReportsScreen extends ConsumerStatefulWidget {
  const PaymentReportsScreen({super.key});

  @override
  ConsumerState<PaymentReportsScreen> createState() =>
      _PaymentReportsScreenState();
}

class _PaymentReportsScreenState
    extends ConsumerState<PaymentReportsScreen> {
  final _db = GetIt.I<AppDatabase>();

  bool _isLoading = true;
  String? _error;
  String _dateFilter = 'today';
  DateTimeRange? _customRange;

  // Payment data
  double _cashTotal = 0;
  double _cardTotal = 0;
  double _creditTotal = 0;
  int _cashCount = 0;
  int _cardCount = 0;
  int _creditCount = 0;

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
      final storeId = ref.read(currentStoreIdProvider);
      if (storeId == null) return;

      final orders = await _db.salesDao.getAllSales(storeId);
      final now = DateTime.now();
      final todayStart = DateTime(now.year, now.month, now.day);

      final filtered = orders.where((order) {
        if (_dateFilter == 'today') {
          return order.createdAt.isAfter(todayStart);
        } else if (_dateFilter == 'week') {
          return order.createdAt.isAfter(todayStart.subtract(const Duration(days: 7)));
        } else if (_dateFilter == 'month') {
          return order.createdAt.month == now.month && order.createdAt.year == now.year;
        } else if (_dateFilter == 'custom' && _customRange != null) {
          return order.createdAt.isAfter(_customRange!.start) &&
              order.createdAt.isBefore(_customRange!.end.add(const Duration(days: 1)));
        }
        return true;
      }).toList();

      double cash = 0, card = 0, credit = 0;
      int cashC = 0, cardC = 0, creditC = 0;

      for (final order in filtered) {
        final method = order.paymentMethod;
        if (method == 'cash') {
          cash += order.total;
          cashC++;
        } else if (method == 'card' || method == 'mada') {
          card += order.total;
          cardC++;
        } else {
          credit += order.total;
          creditC++;
        }
      }

      if (mounted) {
        setState(() {
          _cashTotal = cash;
          _cardTotal = card;
          _creditTotal = credit;
          _cashCount = cashC;
          _cardCount = cardC;
          _creditCount = creditC;
          _isLoading = false;
        });
      }
    } catch (e, stack) {
      reportError(e, stackTrace: stack, hint: 'Load payment reports');
      if (mounted) {
        setState(() {
          _error = '$e';
          _isLoading = false;
        });
      }
    }
  }

  double get _grandTotal => _cashTotal + _cardTotal + _creditTotal;
  int get _totalCount => _cashCount + _cardCount + _creditCount;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isWideScreen = size.width >= AlhaiBreakpoints.desktop;
    final isMediumScreen = size.width >= AlhaiBreakpoints.tablet;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context);
    final user = ref.watch(currentUserProvider);

    return Column(
      children: [
        AppHeader(
          title: 'Payment Reports',
          subtitle: _getDateSubtitle(l10n),
          showSearch: false,
          searchHint: l10n.searchPlaceholder,
          onMenuTap: isWideScreen
              ? null
              : () => Scaffold.of(context).openDrawer(),
          onNotificationsTap: () => context.push('/notifications'),
          notificationsCount: 3,
          userName: user?.name ?? l10n.cashCustomer,
          userRole: l10n.branchManager,
          onUserTap: () {},
        ),
        Expanded(
          child: _isLoading
              ? const AppLoadingState()
              : _error != null
                  ? AppErrorState.general(context, message: _error!, onRetry: _loadData)
                  : SingleChildScrollView(
                  padding: EdgeInsets.all(isMediumScreen ? AlhaiSpacing.lg : AlhaiSpacing.md),
                  child: _buildContent(
                      isWideScreen, isMediumScreen, isDark, l10n),
                ),
        ),
      ],
    );
  }

  String _getDateSubtitle(AppLocalizations l10n) {
    final now = DateTime.now();
    return '${now.day}/${now.month}/${now.year} \u2022 ${l10n.mainBranch}';
  }

  Widget _buildContent(
      bool isWideScreen, bool isMediumScreen, bool isDark, AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Date filter
        _buildDateFilter(isDark, l10n),
        SizedBox(height: isMediumScreen ? AlhaiSpacing.lg : AlhaiSpacing.md),
        // Content
        if (isWideScreen)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(flex: 3, child: _buildChart(isDark, l10n)),
              const SizedBox(width: AlhaiSpacing.lg),
              Expanded(flex: 2, child: _buildBreakdown(isDark, l10n)),
            ],
          )
        else ...[
          _buildChart(isDark, l10n),
          SizedBox(height: isMediumScreen ? AlhaiSpacing.lg : AlhaiSpacing.md),
          _buildBreakdown(isDark, l10n),
        ],
        SizedBox(height: isMediumScreen ? AlhaiSpacing.lg : AlhaiSpacing.md),
        _buildGrandTotalCard(isDark, l10n),
      ],
    );
  }

  Widget _buildDateFilter(bool isDark, AppLocalizations l10n) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _buildChip(l10n.today, _dateFilter == 'today', () {
            setState(() => _dateFilter = 'today');
            _loadData();
          }, isDark),
          const SizedBox(width: AlhaiSpacing.xs),
          _buildChip(l10n.thisWeek, _dateFilter == 'week', () {
            setState(() => _dateFilter = 'week');
            _loadData();
          }, isDark),
          const SizedBox(width: AlhaiSpacing.xs),
          _buildChip(l10n.thisMonthPeriod, _dateFilter == 'month', () {
            setState(() => _dateFilter = 'month');
            _loadData();
          }, isDark),
          const SizedBox(width: AlhaiSpacing.xs),
          _buildChip(l10n.dateFromTo, _dateFilter == 'custom', () async {
            final picked = await showDateRangePicker(
              context: context,
              firstDate: DateTime(2020),
              lastDate: DateTime.now(),
              initialDateRange: _customRange,
            );
            if (picked != null) {
              setState(() {
                _dateFilter = 'custom';
                _customRange = picked;
              });
              _loadData();
            }
          }, isDark, icon: Icons.date_range_outlined),
        ],
      ),
    );
  }

  Widget _buildChip(
      String label, bool isSelected, VoidCallback onTap, bool isDark,
      {IconData? icon}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: AlhaiSpacing.xs),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.getSurfaceVariant(isDark),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: isSelected ? AppColors.primary : AppColors.getBorder(isDark)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 14,
                  color: isSelected ? Colors.white : AppColors.getTextSecondary(isDark)),
              const SizedBox(width: 6),
            ],
            Text(label,
                style: TextStyle(fontSize: 13,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    color: isSelected ? Colors.white : AppColors.getTextSecondary(isDark))),
          ],
        ),
      ),
    );
  }

  Widget _buildChart(bool isDark, AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(AlhaiSpacing.mdl),
      decoration: BoxDecoration(
        color: AppColors.getSurface(isDark),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.getBorder(isDark)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AlhaiSpacing.xs),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.pie_chart_rounded,
                    color: AppColors.primary, size: 20),
              ),
              const SizedBox(width: AlhaiSpacing.sm),
              Text('Payment Distribution',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold,
                      color: AppColors.getTextPrimary(isDark))),
            ],
          ),
          const SizedBox(height: AlhaiSpacing.lg),
          // Custom pie chart using colored containers
          SizedBox(
            width:200,
            height: 200,
            child: _grandTotal > 0
                ? CustomPaint(
                    size: const Size(200, 200),
                    painter: _PieChartPainter(
                      values: [_cashTotal, _cardTotal, _creditTotal],
                      colors: const [
                        AppColors.success,
                        Color(0xFF3B82F6),
                        Color(0xFFF97316),
                      ],
                    ),
                  )
                : Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.pie_chart_outline_rounded, size: 48,
                            color: AppColors.getTextMuted(isDark).withValues(alpha: 0.3)),
                        const SizedBox(height: AlhaiSpacing.xs),
                        Text(l10n.noData,
                            style: TextStyle(fontSize: 13,
                                color: AppColors.getTextMuted(isDark))),
                      ],
                    ),
                  ),
          ),
          const SizedBox(height: AlhaiSpacing.lg),
          // Legend
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildLegendItem(l10n.cash, AppColors.success, isDark),
              const SizedBox(width: AlhaiSpacing.lg),
              _buildLegendItem(l10n.card, const Color(0xFF3B82F6), isDark),
              const SizedBox(width: AlhaiSpacing.lg),
              _buildLegendItem(l10n.credit, const Color(0xFFF97316), isDark),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color, bool isDark) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12, height: 12,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(label,
            style: TextStyle(fontSize: 12,
                color: AppColors.getTextSecondary(isDark))),
      ],
    );
  }

  Widget _buildBreakdown(bool isDark, AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(AlhaiSpacing.mdl),
      decoration: BoxDecoration(
        color: AppColors.getSurface(isDark),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.getBorder(isDark)),
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
                child: const Icon(Icons.list_alt_rounded,
                    color: AppColors.info, size: 20),
              ),
              const SizedBox(width: AlhaiSpacing.sm),
              Text('Breakdown',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold,
                      color: AppColors.getTextPrimary(isDark))),
            ],
          ),
          const SizedBox(height: AlhaiSpacing.mdl),
          _buildPaymentMethodRow(
            l10n.cash,
            Icons.money_rounded,
            AppColors.success,
            _cashTotal,
            _cashCount,
            isDark,
            l10n,
          ),
          const SizedBox(height: AlhaiSpacing.sm),
          _buildPaymentMethodRow(
            l10n.card,
            Icons.credit_card_rounded,
            const Color(0xFF3B82F6),
            _cardTotal,
            _cardCount,
            isDark,
            l10n,
          ),
          const SizedBox(height: AlhaiSpacing.sm),
          _buildPaymentMethodRow(
            l10n.credit,
            Icons.account_balance_rounded,
            const Color(0xFFF97316),
            _creditTotal,
            _creditCount,
            isDark,
            l10n,
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentMethodRow(
    String label,
    IconData icon,
    Color color,
    double total,
    int count,
    bool isDark,
    AppLocalizations l10n,
  ) {
    final percentage = _grandTotal > 0
        ? (total / _grandTotal * 100).toStringAsFixed(1)
        : '0.0';

    return Container(
      padding: const EdgeInsets.all(AlhaiSpacing.md),
      decoration: BoxDecoration(
        color: color.withValues(alpha: isDark ? 0.08 : 0.04),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 40, height: 40,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                alignment: Alignment.center,
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(label,
                        style: TextStyle(fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.getTextPrimary(isDark))),
                    Text('$count Transactions',
                        style: TextStyle(fontSize: 12,
                            color: AppColors.getTextMuted(isDark))),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('${total.toStringAsFixed(0)} ${l10n.sar}',
                      style: TextStyle(fontSize: 16,
                          fontWeight: FontWeight.w700, color: color)),
                  Text('$percentage%',
                      style: TextStyle(fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: AppColors.getTextSecondary(isDark))),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),
          // Progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: _grandTotal > 0 ? total / _grandTotal : 0,
              backgroundColor: AppColors.getBorder(isDark),
              valueColor: AlwaysStoppedAnimation(color),
              minHeight: 6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGrandTotalCard(bool isDark, AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(AlhaiSpacing.mdl),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary.withValues(alpha: isDark ? 0.2 : 0.1),
            AppColors.primary.withValues(alpha: isDark ? 0.08 : 0.03),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l10n.grandTotal,
                    style: TextStyle(fontSize: 14,
                        color: AppColors.getTextSecondary(isDark))),
                const SizedBox(height: AlhaiSpacing.xxs),
                Text('${_grandTotal.toStringAsFixed(0)} ${l10n.sar}',
                    style: const TextStyle(fontSize: 28,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primary)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(l10n.totalTransactions,
                  style: TextStyle(fontSize: 12,
                      color: AppColors.getTextSecondary(isDark))),
              const SizedBox(height: AlhaiSpacing.xxs),
              Text('$_totalCount',
                  style: TextStyle(fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: AppColors.getTextPrimary(isDark))),
            ],
          ),
        ],
      ),
    );
  }
}

class _PieChartPainter extends CustomPainter {
  final List<double> values;
  final List<Color> colors;

  _PieChartPainter({required this.values, required this.colors});

  @override
  void paint(Canvas canvas, Size size) {
    final total = values.fold(0.0, (sum, v) => sum + v);
    if (total <= 0) return;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2 - 4;
    var startAngle = -math.pi / 2;

    for (var i = 0; i < values.length; i++) {
      final sweepAngle = (values[i] / total) * 2 * math.pi;
      final paint = Paint()
        ..color = colors[i]
        ..style = PaintingStyle.fill;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        true,
        paint,
      );

      // White separator line
      final separatorPaint = Paint()
        ..color = Colors.white
        ..strokeWidth = 2
        ..style = PaintingStyle.stroke;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        true,
        separatorPaint,
      );

      startAngle += sweepAngle;
    }

    // Inner circle for donut effect
    final innerPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, radius * 0.55, innerPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
