import 'package:flutter/material.dart';

/// شاشة إيصال الإرجاع
class RefundReceiptScreen extends StatelessWidget {
  final String? refundId;
  const RefundReceiptScreen({super.key, this.refundId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('إيصال الإرجاع'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.of(context).popUntil((route) => route.isFirst),
          ),
        ],
      ),
      body: Center(
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
              Text('رقم الإرجاع: ${refundId ?? 'REF-001'}', style: TextStyle(color: Colors.grey.shade600)),
              const SizedBox(height: 32),

              // Receipt card
              Card(
                child: Container(
                  width: 300,
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      const Text('إيصال إرجاع', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      const Divider(height: 24),
                      const _ReceiptRow(label: 'رقم الفاتورة الأصلية', value: 'INV-2024-150'),
                      _ReceiptRow(label: 'تاريخ الإرجاع', value: _formatDate(DateTime.now())),
                      const _ReceiptRow(label: 'الكاشير', value: 'أحمد'),
                      const Divider(height: 24),
                      const Text('المنتجات المرتجعة', style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      const _ProductRow(name: 'منتج 1', qty: 2, price: 50),
                      const _ProductRow(name: 'منتج 2', qty: 1, price: 75),
                      const Divider(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('إجمالي الإرجاع', style: TextStyle(fontWeight: FontWeight.bold)),
                          Text('175 ر.س', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red.shade600, fontSize: 18)),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('السبب', style: TextStyle(color: Colors.grey.shade600)),
                          const Text('منتج تالف'),
                        ],
                      ),
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
                    onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('جاري الطباعة...')),
                    ),
                    icon: const Icon(Icons.print),
                    label: const Text('طباعة'),
                    style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12)),
                  ),
                  const SizedBox(width: 12),
                  FilledButton.icon(
                    onPressed: () => Navigator.of(context).popUntil((route) => route.isFirst),
                    icon: const Icon(Icons.home),
                    label: const Text('الرئيسية'),
                    style: FilledButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
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
          Text(value, style: const TextStyle(fontSize: 13)),
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
          Text('$qty × $price', style: TextStyle(color: Colors.grey.shade600)),
        ],
      ),
    );
  }
}
