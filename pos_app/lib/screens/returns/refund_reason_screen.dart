import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import 'package:pos_app/widgets/common/adaptive_icon.dart';

import '../../data/local/app_database.dart';
import '../../di/injection.dart';
import '../../providers/auth_providers.dart';
import '../../providers/products_providers.dart';
import '../../providers/returns_providers.dart';
import '../../services/manager_approval_service.dart';
import 'refund_request_screen.dart';

const _uuid = Uuid();

/// شاشة اختيار سبب الإرجاع
class RefundReasonScreen extends ConsumerStatefulWidget {
  const RefundReasonScreen({super.key});

  @override
  ConsumerState<RefundReasonScreen> createState() => _RefundReasonScreenState();
}

class _RefundReasonScreenState extends ConsumerState<RefundReasonScreen> {
  String? _selectedReason;
  final _notesController = TextEditingController();
  bool _isProcessing = false;

  final List<Map<String, dynamic>> _reasons = [
    {'id': 'damaged', 'label': 'منتج تالف', 'icon': Icons.broken_image},
    {'id': 'wrong', 'label': 'خطأ في الطلب', 'icon': Icons.error_outline},
    {'id': 'changed_mind', 'label': 'تغيير رأي العميل', 'icon': Icons.sentiment_dissatisfied},
    {'id': 'expired', 'label': 'منتج منتهي الصلاحية', 'icon': Icons.schedule},
    {'id': 'quality', 'label': 'جودة غير مرضية', 'icon': Icons.thumb_down},
    {'id': 'other', 'label': 'سبب آخر', 'icon': Icons.more_horiz},
  ];

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final pendingRefund = ref.watch(pendingRefundProvider);

    if (pendingRefund == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('سبب الإرجاع')),
        body: const Center(
          child: Text('لا توجد بيانات إرجاع. يرجى العودة واختيار المنتجات.'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('سبب الإرجاع'),
      ),
      body: Column(
        children: [
          // Refund summary banner
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.orange.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.orange.shade200),
            ),
            child: Row(
              children: [
                Icon(Icons.receipt_long, color: Colors.orange.shade700),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'فاتورة: ${pendingRefund.receiptNo}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        '${pendingRefund.items.length} منتج - ${pendingRefund.amount.toStringAsFixed(2)} ر.س',
                        style: TextStyle(color: Colors.grey.shade700, fontSize: 13),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                const Text(
                  'اختر سبب الإرجاع',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),

                // Reason options
                ...List.generate(_reasons.length, (index) {
                  final reason = _reasons[index];
                  final isSelected = _selectedReason == reason['id'];

                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    color: isSelected ? Colors.blue.shade50 : null,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(
                        color: isSelected ? Colors.blue : Colors.transparent,
                        width: 2,
                      ),
                    ),
                    child: ListTile(
                      onTap: () => setState(() => _selectedReason = reason['id'] as String),
                      leading: CircleAvatar(
                        backgroundColor: isSelected ? Colors.blue : Colors.grey.shade200,
                        child: Icon(
                          reason['icon'] as IconData,
                          color: isSelected ? Colors.white : Colors.grey,
                        ),
                      ),
                      title: Text(
                        reason['label'] as String,
                        style: TextStyle(
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                      trailing: isSelected
                          ? const Icon(Icons.check_circle, color: Colors.blue)
                          : const Icon(Icons.radio_button_unchecked, color: Colors.grey),
                    ),
                  );
                }),

                const SizedBox(height: 24),

                // Notes
                const Text(
                  'ملاحظات إضافية (اختياري)',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _notesController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    hintText: 'أضف أي ملاحظات إضافية...',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ],
            ),
          ),

          // Bottom action
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, -2))],
            ),
            child: SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: (_selectedReason == null || _isProcessing) ? null : _proceedToApproval,
                icon: _isProcessing
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : const AdaptiveIcon(Icons.arrow_forward),
                label: Text(_isProcessing ? 'جاري المعالجة...' : 'التالي - موافقة المشرف'),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _proceedToApproval() async {
    final pendingRefund = ref.read(pendingRefundProvider);
    if (pendingRefund == null || _selectedReason == null) return;

    // 1. Request supervisor PIN approval
    final approved = await ManagerApprovalService.requestPinApproval(
      context: context,
      action: 'refund',
    );

    if (!approved || !mounted) return;

    // 2. Create return record in DB
    setState(() => _isProcessing = true);

    try {
      final db = getIt<AppDatabase>();
      final storeId = ref.read(currentStoreIdProvider) ?? '';
      final user = ref.read(currentUserProvider);
      final userId = user?.id ?? '';

      final returnId = _uuid.v4();
      final returnNumber = 'RET-${DateTime.now().millisecondsSinceEpoch}';

      // Insert return header
      await db.returnsDao.insertReturn(ReturnsTableCompanion(
        id: Value(returnId),
        returnNumber: Value(returnNumber),
        saleId: Value(pendingRefund.saleId),
        storeId: Value(storeId),
        reason: Value(_selectedReason!),
        notes: Value(_notesController.text.isEmpty ? null : _notesController.text),
        totalRefund: Value(pendingRefund.amount),
        status: const Value('completed'),
        createdBy: Value(userId),
        createdAt: Value(DateTime.now()),
      ));

      // Insert return items
      final returnItems = pendingRefund.items.map((item) {
        return ReturnItemsTableCompanion(
          id: Value('RTI-${_uuid.v4()}'),
          returnId: Value(returnId),
          productId: Value(item.productId),
          productName: Value(item.productName),
          qty: Value(item.qty),
          unitPrice: Value(item.unitPrice),
          refundAmount: Value(item.qty * item.unitPrice),
        );
      }).toList();

      await db.returnsDao.insertReturnItems(returnItems);

      // Restore inventory via movement records
      for (final item in pendingRefund.items) {
        await db.inventoryDao.insertMovement(InventoryMovementsTableCompanion.insert(
          id: 'INV-RTN-${_uuid.v4()}',
          productId: item.productId,
          storeId: storeId,
          type: 'return',
          qty: item.qty,
          previousQty: 0, // actual previous qty not tracked here
          newQty: 0, // actual new qty not tracked here
          referenceType: const Value('return'),
          referenceId: Value(returnId),
          userId: Value(userId),
          reason: Value('return: $_selectedReason'),
          createdAt: DateTime.now(),
        ));
      }

      // Invalidate the returns list so it refreshes
      ref.invalidate(returnsListProvider);

      // Clear pending refund data
      ref.read(pendingRefundProvider.notifier).state = null;

      // 3. Navigate to receipt screen
      if (mounted) {
        context.go('/returns/receipt/$returnId');
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isProcessing = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('خطأ في إنشاء الإرجاع: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
