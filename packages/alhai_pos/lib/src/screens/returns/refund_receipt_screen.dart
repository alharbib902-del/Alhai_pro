import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:alhai_design_system/alhai_design_system.dart';
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
      final l10n = AppLocalizations.of(context)!;
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
    final l10n = AppLocalizations.of(context)!;

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
        error: (e, _) => Center(child: Text(l10n.errorLabel(e.toString()))),
        data: (detail) {
          if (detail == null) {
            return Center(child: Text(l10n.refundNotFound));
          }
          return _buildReceiptContent(context, detail.returnData, detail.items);
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

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
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
              child: const Icon(Icons.check_circle, size: 48, color: AppColors.success),
            ),
            const SizedBox(height: 16),
            Text(AppLocalizations.of(context)!.refundSuccessful, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(
              AppLocalizations.of(context)!.refundNumberLabel(returnData.returnNumber),
              style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
            ),
            const SizedBox(height: 32),

            // Receipt card
            Card(
              child: Container(
                width: 340,
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Text(AppLocalizations.of(context)!.refundReceipt, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const Divider(height: 24),
                    _ReceiptRow(label: AppLocalizations.of(context)!.originalInvoiceNumber, value: returnData.saleId),
                    _ReceiptRow(label: AppLocalizations.of(context)!.refundDate, value: _formatDate(returnData.createdAt)),
                    if (returnData.createdBy != null && returnData.createdBy!.isNotEmpty)
                      _ReceiptRow(label: AppLocalizations.of(context)!.cashierLabel, value: returnData.createdBy!),
                    if (returnData.refundMethod.isNotEmpty)
                      _ReceiptRow(label: AppLocalizations.of(context)!.refundMethodField, value: _getRefundMethodLabel(context, returnData.refundMethod)),
                    const Divider(height: 24),
                    Text(AppLocalizations.of(context)!.returnedProducts, style: const TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),

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
                        Text(AppLocalizations.of(context)!.totalRefund, style: const TextStyle(fontWeight: FontWeight.bold)),
                        Text(
                          '${totalRefund.toStringAsFixed(2)} ${AppLocalizations.of(context)!.sar}',
                          style: TextStyle(fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.error, fontSize: 18),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    if (returnData.reason != null && returnData.reason!.isNotEmpty)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(AppLocalizations.of(context)!.reasonLabel, style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant)),
                          Text(_getReasonLabel(context, returnData.reason!)),
                        ],
                      ),
                    if (returnData.notes != null && returnData.notes!.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(AppLocalizations.of(context)!.notesLabel, style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant)),
                          Flexible(child: Text(returnData.notes!, textAlign: TextAlign.end)),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Actions
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                OutlinedButton.icon(
                  onPressed: () => _printReceipt(context, returnData.saleId),
                  icon: const Icon(Icons.print),
                  label: Text(AppLocalizations.of(context)!.printAction),
                  style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12)),
                ),
                const SizedBox(width: 12),
                FilledButton.icon(
                  onPressed: () => context.go('/returns'),
                  icon: const Icon(Icons.home),
                  label: Text(AppLocalizations.of(context)!.homeAction),
                  style: FilledButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12)),
                ),
              ],
            ),
          ],
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
            content: Text(AppLocalizations.of(context)!.printError(e.toString())),
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
    final l10n = AppLocalizations.of(context)!;
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
    final l10n = AppLocalizations.of(context)!;
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
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, fontSize: 13)),
          Flexible(child: Text(value, style: const TextStyle(fontSize: 13), textAlign: TextAlign.end)),
        ],
      ),
    );
  }
}

class _ProductRow extends StatelessWidget {
  final String name;
  final int qty;
  final double price;
  const _ProductRow({required this.name, required this.qty, required this.price});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(child: Text(name)),
          Text('$qty × ${price.toStringAsFixed(2)}', style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant)),
        ],
      ),
    );
  }
}
