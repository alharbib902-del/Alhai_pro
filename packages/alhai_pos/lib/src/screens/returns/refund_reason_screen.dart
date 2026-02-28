import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import 'package:alhai_shared_ui/alhai_shared_ui.dart';
import 'package:alhai_database/alhai_database.dart';
import 'package:get_it/get_it.dart';
import 'package:alhai_auth/alhai_auth.dart';
import '../../providers/returns_providers.dart';
import 'package:alhai_l10n/alhai_l10n.dart';
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

  List<Map<String, dynamic>> _getReasons(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return [
      {'id': 'damaged', 'label': l10n.damagedProduct, 'icon': Icons.broken_image},
      {'id': 'wrong', 'label': l10n.wrongOrder, 'icon': Icons.error_outline},
      {'id': 'changed_mind', 'label': l10n.customerChangedMind, 'icon': Icons.sentiment_dissatisfied},
      {'id': 'expired', 'label': l10n.expiredProduct, 'icon': Icons.schedule},
      {'id': 'quality', 'label': l10n.unsatisfactoryQuality, 'icon': Icons.thumb_down},
      {'id': 'other', 'label': l10n.otherReason, 'icon': Icons.more_horiz},
    ];
  }

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
        appBar: AppBar(title: Text(AppLocalizations.of(context)!.refundReasonTitle)),
        body: Center(
          child: Text(AppLocalizations.of(context)!.noRefundData),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.refundReasonTitle),
      ),
      body: SafeArea(
        top: false,
        child: LayoutBuilder(
        builder: (context, constraints) {
          final isMobile = constraints.maxWidth < 600;
          final isDesktop = constraints.maxWidth >= 1200;
          final padding = isMobile ? 12.0 : isDesktop ? 24.0 : 16.0;

          return Column(
        children: [
          // Refund summary banner
          Container(
            margin: EdgeInsets.all(padding),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.warning.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.warning.withValues(alpha: 0.3)),
            ),
            child: Row(
              children: [
                const Icon(Icons.receipt_long, color: AppColors.warning),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppLocalizations.of(context)!.invoiceFieldLabel(pendingRefund.receiptNo),
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        AppLocalizations.of(context)!.productsCountAmount(pendingRefund.items.length, pendingRefund.amount.toStringAsFixed(2)),
                        style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, fontSize: 13),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: ListView(
              padding: EdgeInsets.symmetric(horizontal: padding),
              children: [
                Text(
                  AppLocalizations.of(context)!.selectRefundReason,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),

                // Reason options
                ...List.generate(_getReasons(context).length, (index) {
                  final reason = _getReasons(context)[index];
                  final isSelected = _selectedReason == reason['id'];

                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    color: isSelected ? AppColors.info.withValues(alpha: 0.1) : null,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(
                        color: isSelected ? AppColors.info : Colors.transparent,
                        width: 2,
                      ),
                    ),
                    child: ListTile(
                      onTap: () => setState(() => _selectedReason = reason['id'] as String),
                      leading: CircleAvatar(
                        backgroundColor: isSelected ? AppColors.info : Theme.of(context).colorScheme.surfaceContainerHighest,
                        child: Icon(
                          reason['icon'] as IconData,
                          color: isSelected ? Theme.of(context).colorScheme.surface : Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                      title: Text(
                        reason['label'] as String,
                        style: TextStyle(
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                      trailing: isSelected
                          ? const Icon(Icons.check_circle, color: AppColors.info)
                          : Icon(Icons.radio_button_unchecked, color: Theme.of(context).colorScheme.onSurfaceVariant),
                    ),
                  );
                }),

                const SizedBox(height: 24),

                // Notes
                Text(
                  AppLocalizations.of(context)!.additionalNotesOptional,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _notesController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    hintText: AppLocalizations.of(context)!.addNotesHint,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ],
            ),
          ),

          // Bottom action
          Container(
            padding: EdgeInsets.all(padding),
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              boxShadow: [BoxShadow(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.12), blurRadius: 8, offset: const Offset(0, -2))],
            ),
            child: SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: (_selectedReason == null || _isProcessing) ? null : _proceedToApproval,
                icon: _isProcessing
                    ? SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Theme.of(context).colorScheme.surface),
                      )
                    : const AdaptiveIcon(Icons.arrow_forward),
                label: Text(_isProcessing ? AppLocalizations.of(context)!.processingAction : AppLocalizations.of(context)!.nextSupervisorApproval),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
          ),
        ],
          );
        },
      ),
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
      final db = GetIt.I<AppDatabase>();
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
            content: Text(AppLocalizations.of(context)!.refundCreationError(e.toString())),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }
}
