import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:alhai_design_system/alhai_design_system.dart';
import 'package:alhai_shared_ui/alhai_shared_ui.dart';
import 'package:alhai_database/alhai_database.dart';
import '../../providers/returns_providers.dart';
import 'package:alhai_l10n/alhai_l10n.dart';
import '../../services/receipt_printer_service.dart';

/// شاشة إيصال الإرجاع
class RefundReceiptScreen extends ConsumerWidget {
  final String? refundId;
  const RefundReceiptScreen({super.key, this.refundId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (refundId == null || refundId!.isEmpty) {
      final l10n = AppLocalizations.of(context);
      return Scaffold(
        appBar: AppBar(
          title: Text(l10n.refundReceiptTitle),
          automaticallyImplyLeading: false,
          actions: [
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: () => context.go('/returns'),
            ),
          ],
        ),
        body: Center(child: Text(l10n.noRefundId)),
      );
    }

    final returnDetailAsync = ref.watch(returnDetailProvider(refundId!));
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.refundReceiptTitle),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => context.go('/returns'),
          ),
        ],
      ),
      body: SafeArea(
        top: false,
        child: returnDetailAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => AppErrorState.general(
            context,
            message: e.toString(),
            onRetry: () => ref.invalidate(returnDetailProvider(refundId!)),
          ),
          data: (detail) {
            if (detail == null) {
              return Center(child: Text(l10n.refundNotFound));
            }
            return _buildReceiptContent(
                context, detail.returnData, detail.items);
          },
        ),
      ),
    );
  }

  Widget _buildReceiptContent(
    BuildContext context,
    ReturnsTableData returnData,
    List<ReturnItemsTableData> items,
  ) {
    final totalRefund = returnData.totalRefund;
    final l10n = AppLocalizations.of(context);
    final screenWidth = MediaQuery.sizeOf(context).width;
    final isMobile = screenWidth < AlhaiBreakpoints.tablet;
    // Responsive receipt width: fill on mobile, constrained on larger screens
    final receiptMaxWidth = isMobile ? double.infinity : 440.0;
    final padding = isMobile ? AlhaiSpacing.md : AlhaiSpacing.lg;

    return Center(
      child: SingleChildScrollView(
        padding: EdgeInsets.all(padding),
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: receiptMaxWidth),
          child: Column(
            children: [
              // Success icon
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: AppColors.success.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check_circle,
                    size: 48, color: AppColors.success),
              ),
              const SizedBox(height: AlhaiSpacing.md),
              Text(
                l10n.refundSuccessful,
                style:
                    const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: AlhaiSpacing.xs),
              Text(
                l10n.refundNumberLabel(returnData.returnNumber),
                style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurfaceVariant),
              ),
              const SizedBox(height: AlhaiSpacing.xl),

              // Receipt card — responsive width
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(AlhaiSpacing.mdl),
                  child: Column(
                    children: [
                      Text(l10n.refundReceipt,
                          style: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold)),
                      const Divider(height: 24),
                      _ReceiptRow(
                          label: l10n.originalInvoiceNumber,
                          value: returnData.saleId),
                      _ReceiptRow(
                          label: l10n.refundDate,
                          value: _formatDate(returnData.createdAt)),
                      if (returnData.createdBy != null &&
                          returnData.createdBy!.isNotEmpty)
                        _ReceiptRow(
                            label: l10n.cashierLabel,
                            value: returnData.createdBy!),
                      if (returnData.refundMethod.isNotEmpty)
                        _ReceiptRow(
                            label: l10n.refundMethodField,
                            value: _getRefundMethodLabel(
                                context, returnData.refundMethod)),
                      const Divider(height: 24),
                      Text(l10n.returnedProducts,
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: AlhaiSpacing.xs),

                      // Items list
                      ...items.map((item) => _ProductRow(
                            name: item.productName,
                            qty: item.qty.toInt(),
                            price: item.unitPrice,
                          )),

                      const Divider(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(l10n.totalRefund,
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold)),
                          Text(
                            '${totalRefund.toStringAsFixed(2)} ${l10n.sar}',
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.error,
                                fontSize: 18),
                          ),
                        ],
                      ),
                      const SizedBox(height: AlhaiSpacing.sm),
                      if (returnData.reason != null &&
                          returnData.reason!.isNotEmpty)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(l10n.reasonLabel,
                                style: TextStyle(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurfaceVariant)),
                            Text(_getReasonLabel(context, returnData.reason!)),
                          ],
                        ),
                      if (returnData.notes != null &&
                          returnData.notes!.isNotEmpty) ...[
                        const SizedBox(height: AlhaiSpacing.xs),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(l10n.notesLabel,
                                style: TextStyle(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurfaceVariant)),
                            Flexible(
                                child: Text(returnData.notes!,
                                    textAlign: TextAlign.end)),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AlhaiSpacing.lg),

              // Actions — wrap on narrow screens
              Wrap(
                alignment: WrapAlignment.center,
                spacing: AlhaiSpacing.sm,
                runSpacing: AlhaiSpacing.sm,
                children: [
                  OutlinedButton.icon(
                    onPressed: () => _printReceipt(context, returnData.saleId),
                    icon: const Icon(Icons.print),
                    label: Text(l10n.printAction),
                    style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            horizontal: AlhaiSpacing.lg,
                            vertical: AlhaiSpacing.sm)),
                  ),
                  FilledButton.icon(
                    onPressed: () => context.go('/returns'),
                    icon: const Icon(Icons.home),
                    label: Text(l10n.homeAction),
                    style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            horizontal: AlhaiSpacing.lg,
                            vertical: AlhaiSpacing.sm)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _printReceipt(BuildContext context, String saleId) async {
    try {
      await ReceiptPrinterService.printReceipt(context, saleId);
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                Text(AppLocalizations.of(context).printError(e.toString())),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }

  String _getReasonLabel(BuildContext context, String reason) {
    final l10n = AppLocalizations.of(context);
    switch (reason) {
      case 'damaged':
        return l10n.damagedProduct;
      case 'wrong':
        return l10n.wrongOrder;
      case 'changed_mind':
        return l10n.customerChangedMind;
      case 'expired':
        return l10n.expiredProduct;
      case 'quality':
        return l10n.unsatisfactoryQuality;
      case 'other':
        return l10n.otherReason;
      default:
        return reason;
    }
  }

  String _getRefundMethodLabel(BuildContext context, String method) {
    final l10n = AppLocalizations.of(context);
    switch (method) {
      case 'cash':
        return l10n.cashRefundMethod;
      case 'card':
        return l10n.cardRefundMethod;
      case 'wallet':
        return l10n.walletRefundMethod;
      default:
        return method;
    }
  }
}

class _ReceiptRow extends StatelessWidget {
  final String label;
  final String value;
  const _ReceiptRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AlhaiSpacing.xxs),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  fontSize: 13)),
          Flexible(
              child: Text(value,
                  style: const TextStyle(fontSize: 13),
                  textAlign: TextAlign.end)),
        ],
      ),
    );
  }
}

class _ProductRow extends StatelessWidget {
  final String name;
  final int qty;
  final double price;
  const _ProductRow(
      {required this.name, required this.qty, required this.price});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AlhaiSpacing.xxs),
      child: Row(
        children: [
          Expanded(child: Text(name)),
          Text('$qty × ${price.toStringAsFixed(2)}',
              style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurfaceVariant)),
        ],
      ),
    );
  }
}
