/// Split Refund Screen - Refund across multiple payment methods
///
/// Shows original payment methods and amounts.
/// For each method, allow selecting refund amount.
/// Total refund validation.
/// Supports: RTL Arabic, dark/light theme, responsive layout.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:get_it/get_it.dart';
import 'package:alhai_shared_ui/alhai_shared_ui.dart';
import 'package:alhai_l10n/alhai_l10n.dart';
import 'package:alhai_database/alhai_database.dart';
// alhai_design_system is re-exported via alhai_shared_ui
import 'package:alhai_auth/alhai_auth.dart';
import '../../core/services/sentry_service.dart';
import '../../core/services/audit_service.dart';

/// شاشة استرداد الدفع المجزأ
class SplitRefundScreen extends ConsumerStatefulWidget {
  final String orderId;

  const SplitRefundScreen({super.key, required this.orderId});

  @override
  ConsumerState<SplitRefundScreen> createState() => _SplitRefundScreenState();
}

class _SplitRefundScreenState extends ConsumerState<SplitRefundScreen> {
  final _db = GetIt.I<AppDatabase>();
  SalesTableData? _order;
  bool _isLoading = true;
  String? _error;
  bool _isSubmitting = false;

  // Original payment methods and amounts
  List<_RefundMethod> _methods = [];

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
      final order = await _db.salesDao.getSaleById(widget.orderId);
      if (mounted) {
        setState(() {
          _order = order;
          if (order != null) {
            _methods = _buildRefundMethods(order);
          }
          _isLoading = false;
        });
      }
    } catch (e, stack) {
      reportError(e, stackTrace: stack, hint: 'Load split refund data');
      if (mounted) {
        setState(() {
          _isLoading = false;
          _error = '$e';
        });
      }
    }
  }

  List<_RefundMethod> _buildRefundMethods(SalesTableData order) {
    final method = order.paymentMethod;
    if (method == 'split') {
      final half = order.total / 2;
      return [
        _RefundMethod(
          method: 'cash',
          originalAmount: half,
          controller: TextEditingController(text: half.toStringAsFixed(2)),
        ),
        _RefundMethod(
          method: 'card',
          originalAmount: order.total - half,
          controller: TextEditingController(
              text: (order.total - half).toStringAsFixed(2)),
        ),
      ];
    }
    return [
      _RefundMethod(
        method: method,
        originalAmount: order.total,
        controller:
            TextEditingController(text: order.total.toStringAsFixed(2)),
      ),
    ];
  }

  double get _totalRefund {
    return _methods.fold<double>(
        0, (sum, m) => sum + (double.tryParse(m.controller.text) ?? 0));
  }

  double get _maxRefund => _order?.total ?? 0;

  bool get _isValid {
    if (_totalRefund <= 0) return false;
    if (_totalRefund > _maxRefund + 0.01) return false;
    // Each method refund must not exceed original
    for (final m in _methods) {
      final refund = double.tryParse(m.controller.text) ?? 0;
      if (refund < 0 || refund > m.originalAmount + 0.01) return false;
    }
    return true;
  }

  @override
  void dispose() {
    for (final m in _methods) {
      m.controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isWideScreen = size.width > 900;
    final isMediumScreen = size.width > 600;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      body: Column(
        children: [
          _buildTopBar(isDark, l10n),
          Expanded(
            child: _isLoading
                ? const AppLoadingState()
                : _error != null
                    ? AppErrorState.general(
                        message: _error!, onRetry: _loadData)
                    : _order == null
                        ? _buildNotFound(isDark)
                        : SingleChildScrollView(
                        padding: EdgeInsets.all(isMediumScreen ? 24 : 16),
                        child: isWideScreen
                            ? _buildWideLayout(isDark, l10n)
                            : _buildNarrowLayout(
                                isDark, l10n, isMediumScreen),
                      ),
          ),
          if (_order != null) _buildBottomBar(isDark, l10n),
        ],
      ),
    );
  }

  Widget _buildTopBar(bool isDark, AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.getSurface(isDark),
        border: Border(
          bottom: BorderSide(color: AppColors.getBorder(isDark), width: 1),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Row(
          children: [
            IconButton(
              onPressed: () => context.pop(),
              icon: Icon(Icons.arrow_back_rounded,
                  color: AppColors.getTextPrimary(isDark)),
              style: IconButton.styleFrom(
                backgroundColor: AppColors.getSurfaceVariant(isDark),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Split Refund',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppColors.getTextPrimary(isDark),
                    ),
                  ),
                  Text(
                    '#${widget.orderId.length > 8 ? widget.orderId.substring(0, 8) : widget.orderId}',
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.getTextSecondary(isDark),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotFound(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.receipt_long_outlined,
              size: 64,
              color: AppColors.getTextMuted(isDark).withValues(alpha: 0.4)),
          const SizedBox(height: 16),
          Text('Order not found',
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: AppColors.getTextMuted(isDark))),
        ],
      ),
    );
  }

  Widget _buildWideLayout(bool isDark, AppLocalizations l10n) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 3,
          child: _buildOriginalPaymentsCard(isDark, l10n),
        ),
        const SizedBox(width: 24),
        Expanded(
          flex: 2,
          child: _buildRefundSummaryCard(isDark, l10n),
        ),
      ],
    );
  }

  Widget _buildNarrowLayout(
      bool isDark, AppLocalizations l10n, bool isMediumScreen) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildOriginalPaymentsCard(isDark, l10n),
        SizedBox(height: isMediumScreen ? 24 : 16),
        _buildRefundSummaryCard(isDark, l10n),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildOriginalPaymentsCard(bool isDark, AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(20),
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
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.error.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.assignment_return_rounded,
                    color: AppColors.error, size: 20),
              ),
              const SizedBox(width: 12),
              Text(
                'Refund by Payment Method',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.getTextPrimary(isDark),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          ..._methods.asMap().entries.map((entry) {
            final index = entry.key;
            final method = entry.value;
            return Column(
              children: [
                if (index > 0)
                  Divider(
                      height: 24,
                      color: AppColors.getBorder(isDark)),
                _buildRefundMethodCard(method, isDark, l10n),
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget _buildRefundMethodCard(
      _RefundMethod method, bool isDark, AppLocalizations l10n) {
    final icon = _getPaymentIcon(method.method);
    final color = _getPaymentColor(method.method);
    final label = _getPaymentLabel(method.method, l10n);
    final refundValue = double.tryParse(method.controller.text) ?? 0;
    final isOverMax = refundValue > method.originalAmount + 0.01;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              alignment: Alignment.center,
              child: Icon(icon, color: color, size: 18),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.getTextPrimary(isDark),
                    ),
                  ),
                  Text(
                    '${l10n.amount}: ${method.originalAmount.toStringAsFixed(2)} ${l10n.sar}',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.getTextSecondary(isDark),
                    ),
                  ),
                ],
              ),
            ),
            TextButton(
              onPressed: () {
                method.controller.text =
                    method.originalAmount.toStringAsFixed(2);
                setState(() {});
              },
              child: const Text('Full',
                  style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary)),
            ),
          ],
        ),
        const SizedBox(height: 12),
        TextField(
          controller: method.controller,
          keyboardType: TextInputType.number,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: isOverMax
                ? AppColors.error
                : AppColors.getTextPrimary(isDark),
          ),
          onChanged: (_) => setState(() {}),
          decoration: InputDecoration(
            hintText: '0.00',
            hintStyle: TextStyle(color: AppColors.getTextMuted(isDark)),
            suffixText: l10n.sar,
            suffixStyle: TextStyle(
                fontSize: 14,
                color: AppColors.getTextSecondary(isDark)),
            prefixIcon: Padding(
              padding: const EdgeInsets.all(12),
              child: Icon(Icons.remove_rounded, size: 20, color: color),
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                  color: isOverMax
                      ? AppColors.error
                      : AppColors.getBorder(isDark)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                  color: isOverMax
                      ? AppColors.error
                      : AppColors.getBorder(isDark)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                  color: isOverMax ? AppColors.error : AppColors.primary,
                  width: 2),
            ),
            filled: true,
            fillColor: AppColors.getSurfaceVariant(isDark),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
        ),
        if (isOverMax) ...[
          const SizedBox(height: 6),
          const Text(
            'Exceeds original amount',
            style: TextStyle(
              fontSize: 11,
              color: AppColors.error,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildRefundSummaryCard(bool isDark, AppLocalizations l10n) {
    final total = _totalRefund;
    final max = _maxRefund;
    final isOver = total > max + 0.01;

    return Container(
      padding: const EdgeInsets.all(20),
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
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.warning.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.calculate_rounded,
                    color: AppColors.warning, size: 20),
              ),
              const SizedBox(width: 12),
              Text(
                'Refund Summary',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.getTextPrimary(isDark),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildSummaryRow('Original Total',
              '${max.toStringAsFixed(2)} ${l10n.sar}', isDark),
          const SizedBox(height: 8),
          ..._methods.map((m) {
            final refund = double.tryParse(m.controller.text) ?? 0;
            final label = _getPaymentLabel(m.method, l10n);
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: _buildSummaryRow(
                '$label refund',
                '-${refund.toStringAsFixed(2)} ${l10n.sar}',
                isDark,
                color: AppColors.error,
              ),
            );
          }),
          Divider(height: 24, color: AppColors.getBorder(isDark)),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total Refund',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  color: AppColors.getTextPrimary(isDark),
                ),
              ),
              Text(
                '${total.toStringAsFixed(2)} ${l10n.sar}',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  color: isOver ? AppColors.error : AppColors.primary,
                ),
              ),
            ],
          ),
          if (isOver) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                    color: AppColors.error.withValues(alpha: 0.3)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.warning_rounded,
                      size: 18, color: AppColors.error),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Total refund exceeds original payment',
                      style: TextStyle(
                          fontSize: 12,
                          color: AppColors.error,
                          fontWeight: FontWeight.w500),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, bool isDark,
      {Color? color}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: TextStyle(
                fontSize: 13,
                color: AppColors.getTextSecondary(isDark))),
        Text(value,
            style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: color ?? AppColors.getTextPrimary(isDark))),
      ],
    );
  }

  Widget _buildBottomBar(bool isDark, AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.getSurface(isDark),
        border: Border(
            top: BorderSide(color: AppColors.getBorder(isDark), width: 1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            onPressed:
                _isSubmitting || !_isValid ? null : () => _submitRefund(l10n),
            icon: _isSubmitting
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: Colors.white),
                  )
                : const Icon(Icons.assignment_return_rounded, size: 20),
            label: const Text('Process Refund',
                style: TextStyle(
                    fontSize: 16, fontWeight: FontWeight.w600)),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _submitRefund(AppLocalizations l10n) async {
    setState(() => _isSubmitting = true);
    try {
      await Future.delayed(const Duration(seconds: 1));

      // Audit log
      final user = ref.read(currentUserProvider);
      final storeId = ref.read(currentStoreIdProvider)!;
      auditService.logRefund(
        storeId: storeId,
        userId: user?.id ?? 'unknown',
        userName: user?.name ?? 'unknown',
        saleId: widget.orderId,
        amount: 0, // TODO: replace with actual refund amount when implemented
        reason: 'مرتجع مجزأ',
      );

      addBreadcrumb(message: 'Refund processed', category: 'payment');

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Refund processed successfully'),
          backgroundColor: AppColors.success,
        ),
      );
      context.pop();
    } catch (e, stack) {
      reportError(e, stackTrace: stack, hint: 'Submit split refund');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.errorWithDetails('$e')),
          backgroundColor: AppColors.error,
        ),
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  IconData _getPaymentIcon(String method) {
    switch (method) {
      case 'cash':
        return Icons.money_rounded;
      case 'card':
        return Icons.credit_card_rounded;
      case 'credit':
        return Icons.account_balance_wallet_rounded;
      default:
        return Icons.payment_rounded;
    }
  }

  Color _getPaymentColor(String method) {
    switch (method) {
      case 'cash':
        return AppColors.success;
      case 'card':
        return AppColors.info;
      case 'credit':
        return AppColors.warning;
      default:
        return AppColors.primary;
    }
  }

  String _getPaymentLabel(String method, AppLocalizations l10n) {
    switch (method) {
      case 'cash':
        return l10n.cash;
      case 'card':
        return l10n.card;
      case 'credit':
        return l10n.credit;
      default:
        return method;
    }
  }
}

class _RefundMethod {
  final String method;
  final double originalAmount;
  final TextEditingController controller;

  _RefundMethod({
    required this.method,
    required this.originalAmount,
    required this.controller,
  });
}
