import 'package:drift/drift.dart' hide Column;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../data/local/app_database.dart';
import '../../di/injection.dart';
import '../../providers/products_providers.dart';
import '../../providers/inventory_advanced_providers.dart';

/// شاشة تتبع تاريخ انتهاء الصلاحية
class ExpiryTrackingScreen extends ConsumerStatefulWidget {
  const ExpiryTrackingScreen({super.key});

  @override
  ConsumerState<ExpiryTrackingScreen> createState() =>
      _ExpiryTrackingScreenState();
}

class _ExpiryTrackingScreenState extends ConsumerState<ExpiryTrackingScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Dialog controllers
  final _barcodeController = TextEditingController();
  final _batchController = TextEditingController();
  final _quantityController = TextEditingController(text: '1');
  final _notesController = TextEditingController();
  DateTime? _selectedExpiryDate;
  String? _selectedProductId;
  String? _selectedProductName;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _barcodeController.dispose();
    _batchController.dispose();
    _quantityController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final expiryAsync = ref.watch(expiryTrackingProvider);

    return expiryAsync.when(
      loading: () => Scaffold(
        appBar: AppBar(title: const Text('تتبع الصلاحية')),
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (error, _) => Scaffold(
        appBar: AppBar(title: const Text('تتبع الصلاحية')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64, color: Colors.red.shade300),
              const SizedBox(height: 16),
              Text('خطأ في تحميل بيانات الصلاحية',
                  style: TextStyle(color: Colors.red.shade600, fontSize: 16)),
              const SizedBox(height: 8),
              Text('$error', style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
              const SizedBox(height: 16),
              TextButton.icon(
                onPressed: () => ref.invalidate(expiryTrackingProvider),
                icon: const Icon(Icons.refresh),
                label: const Text('إعادة المحاولة'),
              ),
            ],
          ),
        ),
      ),
      data: (allItems) {
        // تصنيف العناصر حسب الفترة
        final now = DateTime.now();
        final in7Days = now.add(const Duration(days: 7));
        final in30Days = now.add(const Duration(days: 30));

        final expired = <ExpiryItemData>[];
        final within7 = <ExpiryItemData>[];
        final within30 = <ExpiryItemData>[];

        for (final item in allItems) {
          if (item.expiry.expiryDate.isBefore(now)) {
            expired.add(item);
          } else if (item.expiry.expiryDate.isBefore(in7Days)) {
            within7.add(item);
          } else if (item.expiry.expiryDate.isBefore(in30Days)) {
            within30.add(item);
          }
        }

        return Scaffold(
          appBar: AppBar(
            title: const Text('تتبع الصلاحية'),
            bottom: TabBar(
              controller: _tabController,
              tabs: [
                Tab(
                  icon: Badge(
                    label: Text('${within7.length}'),
                    backgroundColor: Colors.red,
                    child: const Icon(Icons.warning_amber),
                  ),
                  text: 'قريب الانتهاء',
                ),
                Tab(
                  icon: Badge(
                    label: Text('${within30.length}'),
                    backgroundColor: Colors.orange,
                    child: const Icon(Icons.schedule),
                  ),
                  text: 'خلال شهر',
                ),
                Tab(
                  icon: Badge(
                    label: Text('${expired.length}'),
                    backgroundColor: Colors.grey,
                    child: const Icon(Icons.dangerous),
                  ),
                  text: 'منتهية',
                ),
              ],
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: () => ref.invalidate(expiryTrackingProvider),
                tooltip: 'تحديث',
              ),
            ],
          ),
          body: TabBarView(
            controller: _tabController,
            children: [
              _buildExpiryList(within7, Colors.red, 'لا توجد منتجات تنتهي خلال 7 أيام'),
              _buildExpiryList(within30, Colors.orange, 'لا توجد منتجات تنتهي خلال شهر'),
              _buildExpiryList(expired, Colors.grey, 'لا توجد منتجات منتهية الصلاحية'),
            ],
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: _showAddExpiryDialog,
            icon: const Icon(Icons.add),
            label: const Text('إضافة منتج'),
          ),
        );
      },
    );
  }

  Widget _buildExpiryList(
      List<ExpiryItemData> items, Color statusColor, String emptyMessage) {
    if (items.isEmpty) {
      return _buildEmptyState(emptyMessage);
    }

    return RefreshIndicator(
      onRefresh: () async => ref.invalidate(expiryTrackingProvider),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: items.length,
        itemBuilder: (context, index) {
          final item = items[index];
          return _buildExpiryCard(item, statusColor);
        },
      ),
    );
  }

  Widget _buildExpiryCard(ExpiryItemData item, Color statusColor) {
    final daysLeft = item.expiry.expiryDate.difference(DateTime.now()).inDays;
    final dateFormatter = DateFormat('yyyy/MM/dd');
    final isExpired = daysLeft < 0;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: statusColor.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    isExpired ? Icons.dangerous : Icons.schedule,
                    color: statusColor,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.productName,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          if (item.expiry.batchNumber != null) ...[
                            Icon(Icons.inventory,
                                size: 14, color: Colors.grey.shade600),
                            const SizedBox(width: 4),
                            Text(
                              'باتش: ${item.expiry.batchNumber}',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade600,
                              ),
                            ),
                            const SizedBox(width: 16),
                          ],
                          Icon(Icons.inventory_2,
                              size: 14, color: Colors.grey.shade600),
                          const SizedBox(width: 4),
                          Text(
                            'الكمية: ${item.expiry.quantity}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    isExpired
                        ? 'منتهي منذ ${-daysLeft} يوم'
                        : 'باقي $daysLeft يوم',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: statusColor,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.calendar_today,
                    size: 14, color: Colors.grey.shade600),
                const SizedBox(width: 4),
                Text(
                  'تاريخ الانتهاء: ${dateFormatter.format(item.expiry.expiryDate)}',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade600,
                  ),
                ),
                const Spacer(),
                // Action buttons
                TextButton.icon(
                  onPressed: () => _showDiscountDialog(item),
                  icon: const Icon(Icons.local_offer, size: 16),
                  label: const Text('خصم', style: TextStyle(fontSize: 12)),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.blue,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  ),
                ),
                const SizedBox(width: 4),
                TextButton.icon(
                  onPressed: () => _confirmRemove(item),
                  icon: const Icon(Icons.delete_outline, size: 16),
                  label: const Text('إزالة', style: TextStyle(fontSize: 12)),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.red,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.check_circle_outline, size: 64, color: Colors.green.shade300),
          const SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'اضغط + لإضافة تتبع صلاحية جديد',
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }

  void _showDiscountDialog(ExpiryItemData item) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('تطبيق خصم على "${item.productName}" - قريباً'),
        backgroundColor: Colors.blue,
      ),
    );
  }

  void _confirmRemove(ExpiryItemData item) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('تأكيد الإزالة'),
        content: Text(
            'هل تريد إزالة تتبع صلاحية "${item.productName}"?\n'
            'باتش: ${item.expiry.batchNumber ?? "-"}\n'
            'الكمية: ${item.expiry.quantity}'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('إلغاء'),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await _removeExpiry(item);
            },
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('إزالة'),
          ),
        ],
      ),
    );
  }

  Future<void> _removeExpiry(ExpiryItemData item) async {
    // استخدام المزود مع SyncQueue
    final success = await deleteExpiryRecord(ref, item.expiry.id);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(success ? 'تم إزالة تتبع الصلاحية' : 'خطأ في إزالة تتبع الصلاحية'),
          backgroundColor: success ? Colors.green : Colors.red,
        ),
      );
    }
  }

  void _showAddExpiryDialog() {
    _barcodeController.clear();
    _batchController.clear();
    _quantityController.text = '1';
    _notesController.clear();
    _selectedExpiryDate = null;
    _selectedProductId = null;
    _selectedProductName = null;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text('إضافة تاريخ صلاحية'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Product search by barcode
                TextField(
                  controller: _barcodeController,
                  decoration: InputDecoration(
                    labelText: 'الباركود أو اسم المنتج',
                    prefixIcon: const Icon(Icons.qr_code_scanner),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.search),
                      onPressed: () async {
                        await _searchProduct(
                            _barcodeController.text, setDialogState);
                      },
                    ),
                    border: const OutlineInputBorder(),
                  ),
                  onSubmitted: (value) =>
                      _searchProduct(value, setDialogState),
                ),
                if (_selectedProductName != null) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.green.shade200),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.check_circle,
                            size: 16, color: Colors.green.shade700),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _selectedProductName!,
                            style: TextStyle(
                              color: Colors.green.shade700,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 16),
                // Expiry date
                InkWell(
                  onTap: () async {
                    final date = await showDatePicker(
                      context: ctx,
                      initialDate:
                          DateTime.now().add(const Duration(days: 30)),
                      firstDate: DateTime.now(),
                      lastDate:
                          DateTime.now().add(const Duration(days: 365 * 5)),
                    );
                    if (date != null) {
                      setDialogState(() => _selectedExpiryDate = date);
                    }
                  },
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      labelText: 'تاريخ الانتهاء',
                      prefixIcon: Icon(Icons.calendar_today),
                      border: OutlineInputBorder(),
                    ),
                    child: Text(
                      _selectedExpiryDate != null
                          ? DateFormat('yyyy/MM/dd')
                              .format(_selectedExpiryDate!)
                          : 'اختر التاريخ',
                      style: TextStyle(
                        color: _selectedExpiryDate != null
                            ? null
                            : Colors.grey,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _batchController,
                  decoration: const InputDecoration(
                    labelText: 'رقم الباتش (اختياري)',
                    prefixIcon: Icon(Icons.inventory),
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _quantityController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'الكمية',
                    prefixIcon: Icon(Icons.format_list_numbered),
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _notesController,
                  maxLines: 2,
                  decoration: const InputDecoration(
                    labelText: 'ملاحظات (اختياري)',
                    prefixIcon: Icon(Icons.notes),
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('إلغاء'),
            ),
            FilledButton(
              onPressed: (_selectedProductId != null &&
                      _selectedExpiryDate != null)
                  ? () async {
                      Navigator.pop(ctx);
                      await _addExpiry();
                    }
                  : null,
              child: const Text('إضافة'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _searchProduct(
      String query, void Function(void Function()) setDialogState) async {
    if (query.isEmpty) return;

    final db = getIt<AppDatabase>();
    final storeId = ref.read(currentStoreIdProvider);
    if (storeId == null) return;

    // Try barcode first
    final byBarcode = await (db.select(db.productsTable)
          ..where((p) =>
              p.barcode.equals(query) & p.storeId.equals(storeId)))
        .getSingleOrNull();

    if (byBarcode != null) {
      setDialogState(() {
        _selectedProductId = byBarcode.id;
        _selectedProductName = byBarcode.name;
      });
      return;
    }

    // Try name search
    final byName = await (db.select(db.productsTable)
          ..where(
              (p) => p.name.contains(query) & p.storeId.equals(storeId))
          ..limit(1))
        .getSingleOrNull();

    if (byName != null) {
      setDialogState(() {
        _selectedProductId = byName.id;
        _selectedProductName = byName.name;
      });
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('لم يتم العثور على المنتج'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    }
  }

  Future<void> _addExpiry() async {
    if (_selectedProductId == null || _selectedExpiryDate == null) return;

    final quantity = int.tryParse(_quantityController.text) ?? 1;

    // استخدام المزود مع SyncQueue
    final result = await addExpiryRecord(
      ref,
      productId: _selectedProductId!,
      expiryDate: _selectedExpiryDate!,
      quantity: quantity,
      batchNumber: _batchController.text.isEmpty ? null : _batchController.text,
      notes: _notesController.text.isEmpty ? null : _notesController.text,
    );

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result != null ? 'تم إضافة تتبع الصلاحية بنجاح' : 'خطأ في إضافة تتبع الصلاحية'),
          backgroundColor: result != null ? Colors.green : Colors.red,
        ),
      );
    }
  }
}
