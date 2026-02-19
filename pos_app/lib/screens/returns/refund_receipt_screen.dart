import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../data/local/app_database.dart';
import '../../providers/returns_providers.dart';
import '../../services/receipt_printer_service.dart';

/// شاشة إيصال الإرجاع
class RefundReceiptScreen extends ConsumerWidget {
  final String? refundId;
  const RefundReceiptScreen({super.key, this.refundId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (refundId == null || refundId!.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('إيصال الإرجاع'),
          automaticallyImplyLeading: false,
          actions: [
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: () => context.go('/returns'),
            ),
          ],
        ),
        body: const Center(child: Text('لا يوجد معرّف إرجاع')),
      );
    }

    final returnDetailAsync = ref.watch(returnDetailProvider(refundId!));

    return Scaffold(
      appBar: AppBar(
        title: const Text('إيصال الإرجاع'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => context.go('/returns'),
          ),
        ],
      ),
      body: returnDetailAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('خطأ: $e')),
        data: (detail) {
          if (detail == null) {
            return const Center(child: Text('لم يتم العثور على بيانات الإرجاع'));
          }
          return _buildReceiptContent(context, detail.returnData, detail.items);
        },
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
                color: Colors.green.shade100,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.check_circle, size: 48, color: Colors.green.shade600),
            ),
            const SizedBox(height: 16),
            const Text('تم الإرجاع بنجاح', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(
              'رقم الإرجاع: ${returnData.returnNumber}',
              style: TextStyle(color: Colors.grey.shade600),
            ),
            const SizedBox(height: 32),

            // Receipt card
            Card(
              child: Container(
                width: 340,
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    const Text('إيصال إرجاع', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const Divider(height: 24),
                    _ReceiptRow(label: 'رقم الفاتورة الأصلية', value: returnData.saleId),
                    _ReceiptRow(label: 'تاريخ الإرجاع', value: _formatDate(returnData.createdAt)),
                    if (returnData.createdBy != null && returnData.createdBy!.isNotEmpty)
                      _ReceiptRow(label: 'الكاشير', value: returnData.createdBy!),
                    if (returnData.refundMethod.isNotEmpty)
                      _ReceiptRow(label: 'طريقة الاسترداد', value: _getRefundMethodLabel(returnData.refundMethod)),
                    const Divider(height: 24),
                    const Text('المنتجات المرتجعة', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),

                    // Items list
                    ...items.map((item) => _ProductRow(
                      name: item.productName,
                      qty: item.qty,
                      price: item.unitPrice,
                    )),

                    const Divider(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('إجمالي الإرجاع', style: TextStyle(fontWeight: FontWeight.bold)),
                        Text(
                          '${totalRefund.toStringAsFixed(2)} ر.س',
                          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red.shade600, fontSize: 18),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    if (returnData.reason != null && returnData.reason!.isNotEmpty)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('السبب', style: TextStyle(color: Colors.grey.shade600)),
                          Text(_getReasonLabel(returnData.reason!)),
                        ],
                      ),
                    if (returnData.notes != null && returnData.notes!.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('ملاحظات', style: TextStyle(color: Colors.grey.shade600)),
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
                  label: const Text('طباعة'),
                  style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12)),
                ),
                const SizedBox(width: 12),
                FilledButton.icon(
                  onPressed: () => context.go('/returns'),
                  icon: const Icon(Icons.home),
                  label: const Text('الرئيسية'),
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
            content: Text('خطأ في الطباعة: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }

  String _getReasonLabel(String reason) {
    switch (reason) {
      case 'damaged':
        return 'منتج تالف';
      case 'wrong':
        return 'خطأ في الطلب';
      case 'changed_mind':
        return 'تغيير رأي العميل';
      case 'expired':
        return 'منتج منتهي الصلاحية';
      case 'quality':
        return 'جودة غير مرضية';
      case 'other':
        return 'سبب آخر';
      default:
        return reason;
    }
  }

  String _getRefundMethodLabel(String method) {
    switch (method) {
      case 'cash':
        return 'نقدي';
      case 'card':
        return 'بطاقة';
      case 'wallet':
        return 'محفظة';
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
          Text(label, style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
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
          Text('$qty × ${price.toStringAsFixed(2)}', style: TextStyle(color: Colors.grey.shade600)),
        ],
      ),
    );
  }
}
