/// Split Receipt Screen - View split payment breakdown
///
/// Shows breakdown of each payment method used for an order.
/// QR code placeholder, print button, share button.
/// Supports: RTL Arabic, dark/light theme, responsive layout.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:get_it/get_it.dart';
import 'package:alhai_shared_ui/alhai_shared_ui.dart';
import 'package:alhai_l10n/alhai_l10n.dart';
import 'package:alhai_database/alhai_database.dart';
import 'package:alhai_design_system/alhai_design_system.dart' show AlhaiBreakpoints, AlhaiSpacing;
// alhai_design_system is re-exported via alhai_shared_ui
import '../../core/services/sentry_service.dart';
import '../../widgets/zatca_qr_widget.dart';

/// شاشة إيصال الدفع المجزأ
class SplitReceiptScreen extends ConsumerStatefulWidget {
  final String orderId;

  const SplitReceiptScreen({super.key, required this.orderId});

  @override
  ConsumerState<SplitReceiptScreen> createState() =>
      _SplitReceiptScreenState();
}

class _SplitReceiptScreenState extends ConsumerState<SplitReceiptScreen> {
  final _db = GetIt.I<AppDatabase>();
  SalesTableData? _order;
  StoresTableData? _store;
  bool _isLoading = true;
  String? _error;
  bool _isPrinting = false;

  // Simulated split payment data
  List<_PaymentSplit> _splits = [];

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
      // Load store data for ZATCA QR
      final storeId = ref.read(currentStoreIdProvider);
      StoresTableData? store;
      if (storeId != null) {
        store = await _db.storesDao.getStoreById(storeId);
      }
      if (mounted) {
        setState(() {
          _order = order;
          _store = store;
          if (order != null) {
            // Build payment splits from order data
            _splits = _buildSplits(order);
          }
          _isLoading = false;
        });
      }
    } catch (e, stack) {
      reportError(e, stackTrace: stack, hint: 'Load split receipt data');
      if (mounted) {
        setState(() {
          _isLoading = false;
          _error = '$e';
        });
      }
    }
  }

  List<_PaymentSplit> _buildSplits(SalesTableData order) {
    // If the order has a single payment method, show it as one split
    // In a real app, this would come from a payments table
    final method = order.paymentMethod;
    if (method == 'split') {
      // Simulate split payment
      final half = order.total / 2;
      return [
        _PaymentSplit(method: 'cash', amount: half, reference: null),
        _PaymentSplit(
            method: 'card',
            amount: order.total - half,
            reference: '**** 4532'),
      ];
    }
    return [
      _PaymentSplit(method: method, amount: order.total, reference: null),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isWideScreen = size.width >= AlhaiBreakpoints.desktop;
    final isMediumScreen = size.width >= AlhaiBreakpoints.tablet;
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
                        context, message: _error!, onRetry: _loadData)
                    : _order == null
                        ? _buildNotFound(isDark, l10n)
                        : SingleChildScrollView(
                        padding: EdgeInsets.all(isMediumScreen ? AlhaiSpacing.lg : AlhaiSpacing.md),
                        child: isWideScreen
                            ? _buildWideLayout(isDark, l10n)
                            : _buildNarrowLayout(
                                isDark, l10n, isMediumScreen),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopBar(bool isDark, AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AlhaiSpacing.md, vertical: AlhaiSpacing.sm),
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
              tooltip: l10n.back,
              style: IconButton.styleFrom(
                backgroundColor: AppColors.getSurfaceVariant(isDark),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(width: AlhaiSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Split Receipt',
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

  Widget _buildNotFound(bool isDark, AppLocalizations l10n) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.receipt_long_outlined,
              size: 64,
              color: AppColors.getTextMuted(isDark).withValues(alpha: 0.4)),
          const SizedBox(height: AlhaiSpacing.md),
          Text(l10n.orderNotFound,
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
          child: Column(
            children: [
              _buildOrderSummaryCard(isDark, l10n),
              const SizedBox(height: AlhaiSpacing.lg),
              _buildPaymentBreakdownCard(isDark, l10n),
            ],
          ),
        ),
        const SizedBox(width: AlhaiSpacing.lg),
        Expanded(
          flex: 2,
          child: Column(
            children: [
              _buildQrCodeCard(isDark, l10n),
              const SizedBox(height: AlhaiSpacing.lg),
              _buildActionsCard(isDark, l10n),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildNarrowLayout(
      bool isDark, AppLocalizations l10n, bool isMediumScreen) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildOrderSummaryCard(isDark, l10n),
        SizedBox(height: isMediumScreen ? AlhaiSpacing.lg : AlhaiSpacing.md),
        _buildPaymentBreakdownCard(isDark, l10n),
        SizedBox(height: isMediumScreen ? AlhaiSpacing.lg : AlhaiSpacing.md),
        _buildQrCodeCard(isDark, l10n),
        const SizedBox(height: AlhaiSpacing.lg),
        _buildActionsCard(isDark, l10n),
        const SizedBox(height: AlhaiSpacing.lg),
      ],
    );
  }

  Widget _buildOrderSummaryCard(bool isDark, AppLocalizations l10n) {
    final order = _order!;
    final date =
        '${order.createdAt.day}/${order.createdAt.month}/${order.createdAt.year}';
    final time =
        '${order.createdAt.hour.toString().padLeft(2, '0')}:${order.createdAt.minute.toString().padLeft(2, '0')}';

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
                child: const Icon(Icons.receipt_long_rounded,
                    color: AppColors.info, size: 20),
              ),
              const SizedBox(width: AlhaiSpacing.sm),
              Text(
                l10n.invoiceDetails,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.getTextPrimary(isDark),
                ),
              ),
            ],
          ),
          const SizedBox(height: AlhaiSpacing.md),
          _buildInfoRow(l10n.invoiceNumber,
              '#${order.id.length > 8 ? order.id.substring(0, 8) : order.id}',
              isDark),
          Divider(height: 20, color: AppColors.getBorder(isDark)),
          _buildInfoRow(l10n.date, '$date $time', isDark),
          Divider(height: 20, color: AppColors.getBorder(isDark)),
          _buildInfoRow(l10n.customerName,
              order.customerId ?? l10n.cashCustomer, isDark),
          Divider(height: 20, color: AppColors.getBorder(isDark)),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: AlhaiSpacing.xxs),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(l10n.totalAmountLabel,
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: AppColors.getTextPrimary(isDark))),
                Text(
                  '${order.total.toStringAsFixed(2)} ${l10n.sar}',
                  style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: AppColors.primary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AlhaiSpacing.xxs),
      child: Row(
        children: [
          Text('$label:',
              style: TextStyle(
                  fontSize: 13,
                  color: AppColors.getTextSecondary(isDark))),
          const Spacer(),
          Text(value,
              style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.getTextPrimary(isDark))),
        ],
      ),
    );
  }

  Widget _buildPaymentBreakdownCard(bool isDark, AppLocalizations l10n) {
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
                  color: AppColors.success.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.payments_rounded,
                    color: AppColors.success, size: 20),
              ),
              const SizedBox(width: AlhaiSpacing.sm),
              Text(
                'Payment Breakdown',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.getTextPrimary(isDark),
                ),
              ),
            ],
          ),
          const SizedBox(height: AlhaiSpacing.md),
          ..._splits.map((split) => _buildSplitRow(split, isDark, l10n)),
        ],
      ),
    );
  }

  Widget _buildSplitRow(
      _PaymentSplit split, bool isDark, AppLocalizations l10n) {
    final icon = _getPaymentIcon(split.method);
    final color = _getPaymentColor(split.method);
    final label = _getPaymentLabel(split.method, l10n);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AlhaiSpacing.xs),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
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
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.getTextPrimary(isDark),
                  ),
                ),
                if (split.reference != null)
                  Text(
                    split.reference!,
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.getTextMuted(isDark),
                    ),
                  ),
              ],
            ),
          ),
          Text(
            '${split.amount.toStringAsFixed(2)} ${l10n.sar}',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQrCodeCard(bool isDark, AppLocalizations l10n) {
    final order = _order!;
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
                child: const Icon(Icons.qr_code_rounded,
                    color: AppColors.primary, size: 20),
              ),
              const SizedBox(width: AlhaiSpacing.sm),
              Text(
                'ZATCA QR',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.getTextPrimary(isDark),
                ),
              ),
            ],
          ),
          const SizedBox(height: AlhaiSpacing.mdl),
          ZatcaQrWidget(
            sellerName: _store?.name ?? 'Al-HAI Store',
            vatNumber: _store?.taxNumber ?? '300000000000003',
            timestamp: order.createdAt,
            totalWithVat: order.total,
            vatAmount: order.tax,
            size: 140,
          ),
        ],
      ),
    );
  }

  Widget _buildActionsCard(bool isDark, AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            onPressed: _isPrinting ? null : () => _printReceipt(l10n),
            icon: _isPrinting
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: AppColors.textOnPrimary),
                  )
                : const Icon(Icons.print_rounded, size: 20),
            label: Text(l10n.reprintReceipt,
                style: const TextStyle(
                    fontSize: 16, fontWeight: FontWeight.w600)),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.textOnPrimary,
              padding: const EdgeInsets.symmetric(vertical: AlhaiSpacing.md),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ),
        const SizedBox(height: AlhaiSpacing.sm),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: null,
            icon: const Icon(Icons.share_rounded, size: 20),
            label: Text(l10n.share,
                style: const TextStyle(
                    fontSize: 16, fontWeight: FontWeight.w600)),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.primary,
              side: const BorderSide(color: AppColors.primary),
              padding: const EdgeInsets.symmetric(vertical: AlhaiSpacing.md),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _printReceipt(AppLocalizations l10n) async {
    setState(() => _isPrinting = true);
    try {
      await Future.delayed(const Duration(seconds: 1));
      addBreadcrumb(message: 'Receipt printed', category: 'sale');

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.receiptPrinted),
          backgroundColor: AppColors.success,
        ),
      );
    } catch (e, stack) {
      reportError(e, stackTrace: stack, hint: 'Print split receipt');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.errorWithDetails('$e')),
          backgroundColor: AppColors.error,
        ),
      );
    } finally {
      if (mounted) setState(() => _isPrinting = false);
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
      case 'transfer':
        return Icons.swap_horiz_rounded;
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
      case 'transfer':
        return AppColors.purple;
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
      case 'transfer':
        return 'Bank Transfer';
      default:
        return method;
    }
  }
}

class _PaymentSplit {
  final String method;
  final double amount;
  final String? reference;

  const _PaymentSplit({
    required this.method,
    required this.amount,
    this.reference,
  });
}
