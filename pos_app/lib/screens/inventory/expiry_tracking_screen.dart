import 'package:flutter/material.dart';

/// شاشة تتبع تاريخ انتهاء الصلاحية
class ExpiryTrackingScreen extends StatefulWidget {
  const ExpiryTrackingScreen({super.key});

  @override
  State<ExpiryTrackingScreen> createState() => _ExpiryTrackingScreenState();
}

class _ExpiryTrackingScreenState extends State<ExpiryTrackingScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _filterCategory = 'الكل';

  // Mock data
  final List<Map<String, dynamic>> _products = [
    {
      'name': 'حليب طازج 1 لتر',
      'barcode': '6281100123456',
      'category': 'ألبان',
      'quantity': 25,
      'expiryDate': DateTime.now().add(const Duration(days: 5)),
      'batchNumber': 'B2026-001',
    },
    {
      'name': 'زبادي فواكه',
      'barcode': '6281100123457',
      'category': 'ألبان',
      'quantity': 40,
      'expiryDate': DateTime.now().add(const Duration(days: 3)),
      'batchNumber': 'B2026-002',
    },
    {
      'name': 'جبنة بيضاء',
      'barcode': '6281100123458',
      'category': 'ألبان',
      'quantity': 15,
      'expiryDate': DateTime.now().add(const Duration(days: 12)),
      'batchNumber': 'B2026-003',
    },
    {
      'name': 'عصير برتقال',
      'barcode': '6281100123459',
      'category': 'مشروبات',
      'quantity': 30,
      'expiryDate': DateTime.now().add(const Duration(days: 25)),
      'batchNumber': 'B2026-004',
    },
    {
      'name': 'رقائق بطاطس',
      'barcode': '6281100123460',
      'category': 'سناكس',
      'quantity': 50,
      'expiryDate': DateTime.now().add(const Duration(days: 45)),
      'batchNumber': 'B2026-005',
    },
    {
      'name': 'لحم مفروم',
      'barcode': '6281100123461',
      'category': 'لحوم',
      'quantity': 10,
      'expiryDate': DateTime.now().add(const Duration(days: 2)),
      'batchNumber': 'B2026-006',
    },
  ];

  final List<String> _categories = ['الكل', 'ألبان', 'مشروبات', 'سناكس', 'لحوم'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> get _filteredProducts {
    var products = _products;
    if (_filterCategory != 'الكل') {
      products = products.where((p) => p['category'] == _filterCategory).toList();
    }
    return products;
  }

  List<Map<String, dynamic>> get _expiringSoon {
    return _filteredProducts.where((p) {
      final daysLeft = (p['expiryDate'] as DateTime).difference(DateTime.now()).inDays;
      return daysLeft <= 7 && daysLeft >= 0;
    }).toList()
      ..sort((a, b) => (a['expiryDate'] as DateTime).compareTo(b['expiryDate'] as DateTime));
  }

  List<Map<String, dynamic>> get _expiringLater {
    return _filteredProducts.where((p) {
      final daysLeft = (p['expiryDate'] as DateTime).difference(DateTime.now()).inDays;
      return daysLeft > 7 && daysLeft <= 30;
    }).toList()
      ..sort((a, b) => (a['expiryDate'] as DateTime).compareTo(b['expiryDate'] as DateTime));
  }

  List<Map<String, dynamic>> get _expired {
    return _filteredProducts.where((p) {
      final daysLeft = (p['expiryDate'] as DateTime).difference(DateTime.now()).inDays;
      return daysLeft < 0;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('تتبع الصلاحية'),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(
              icon: Badge(
                label: Text('${_expiringSoon.length}'),
                backgroundColor: Colors.red,
                child: const Icon(Icons.warning_amber),
              ),
              text: 'قريب الانتهاء',
            ),
            Tab(
              icon: Badge(
                label: Text('${_expiringLater.length}'),
                backgroundColor: Colors.orange,
                child: const Icon(Icons.schedule),
              ),
              text: 'خلال شهر',
            ),
            Tab(
              icon: Badge(
                label: Text('${_expired.length}'),
                backgroundColor: Colors.grey,
                child: const Icon(Icons.dangerous),
              ),
              text: 'منتهية',
            ),
          ],
        ),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.filter_list),
            onSelected: (category) {
              setState(() => _filterCategory = category);
            },
            itemBuilder: (context) => _categories.map((c) => PopupMenuItem(
              value: c,
              child: Row(
                children: [
                  if (c == _filterCategory)
                    const Icon(Icons.check, size: 18),
                  const SizedBox(width: 8),
                  Text(c),
                ],
              ),
            )).toList(),
          ),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildProductList(_expiringSoon, Colors.red),
          _buildProductList(_expiringLater, Colors.orange),
          _buildProductList(_expired, Colors.grey),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddExpiryDialog,
        icon: const Icon(Icons.add),
        label: const Text('إضافة منتج'),
      ),
    );
  }

  Widget _buildProductList(List<Map<String, dynamic>> products, Color alertColor) {
    if (products.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check_circle, size: 64, color: Colors.green.shade300),
            const SizedBox(height: 16),
            const Text('لا توجد منتجات في هذه الفئة'),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: products.length,
      itemBuilder: (context, index) {
        final product = products[index];
        final expiryDate = product['expiryDate'] as DateTime;
        final daysLeft = expiryDate.difference(DateTime.now()).inDays;

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: alertColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Text(
                  daysLeft < 0 ? '!' : '$daysLeft',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: alertColor,
                  ),
                ),
              ),
            ),
            title: Text(product['name'] as String),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('الكمية: ${product['quantity']} | الباتش: ${product['batchNumber']}'),
                Text(
                  daysLeft < 0
                      ? 'منتهي منذ ${-daysLeft} يوم'
                      : daysLeft == 0
                          ? 'ينتهي اليوم!'
                          : 'ينتهي بعد $daysLeft يوم',
                  style: TextStyle(color: alertColor, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            trailing: PopupMenuButton<String>(
              onSelected: (action) => _handleAction(action, product),
              itemBuilder: (context) => [
                const PopupMenuItem(value: 'discount', child: Text('إنشاء خصم')),
                const PopupMenuItem(value: 'remove', child: Text('إزالة من المخزون')),
                const PopupMenuItem(value: 'notify', child: Text('إرسال تنبيه')),
              ],
            ),
            isThreeLine: true,
          ),
        );
      },
    );
  }

  void _handleAction(String action, Map<String, dynamic> product) {
    switch (action) {
      case 'discount':
        _showDiscountDialog(product);
        break;
      case 'remove':
        _confirmRemove(product);
        break;
      case 'notify':
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('تم إرسال تنبيه لـ ${product['name']}')),
        );
        break;
    }
  }

  void _showDiscountDialog(Map<String, dynamic> product) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('خصم على ${product['name']}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('خصم 20%'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('تم تطبيق خصم 20% على ${product['name']}')),
                );
              },
            ),
            ListTile(
              title: const Text('خصم 30%'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('تم تطبيق خصم 30% على ${product['name']}')),
                );
              },
            ),
            ListTile(
              title: const Text('خصم 50%'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('تم تطبيق خصم 50% على ${product['name']}')),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _confirmRemove(Map<String, dynamic> product) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تأكيد الإزالة'),
        content: Text('هل تريد إزالة ${product['name']} من المخزون؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _products.removeWhere((p) => p['barcode'] == product['barcode']);
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('تمت إزالة ${product['name']}')),
              );
            },
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('إزالة'),
          ),
        ],
      ),
    );
  }

  void _showAddExpiryDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('إضافة تاريخ صلاحية'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: InputDecoration(
                labelText: 'الباركود',
                prefixIcon: Icon(Icons.qr_code_scanner),
              ),
            ),
            SizedBox(height: 16),
            TextField(
              decoration: InputDecoration(
                labelText: 'تاريخ الانتهاء',
                prefixIcon: Icon(Icons.calendar_today),
              ),
            ),
            SizedBox(height: 16),
            TextField(
              decoration: InputDecoration(
                labelText: 'رقم الباتش',
                prefixIcon: Icon(Icons.inventory),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('تمت الإضافة بنجاح ✅')),
              );
            },
            child: const Text('إضافة'),
          ),
        ],
      ),
    );
  }
}
