import 'dart:convert';
import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import 'package:alhai_shared_ui/alhai_shared_ui.dart';
import 'package:alhai_l10n/alhai_l10n.dart';
import 'package:alhai_database/alhai_database.dart';
import 'package:get_it/get_it.dart';
import '../../providers/purchases_providers.dart';

/// Receiving Goods Screen - شاشة استلام البضاعة
class ReceivingGoodsScreen extends ConsumerStatefulWidget {
  final String purchaseId;

  const ReceivingGoodsScreen({super.key, required this.purchaseId});

  @override
  ConsumerState<ReceivingGoodsScreen> createState() =>
      _ReceivingGoodsScreenState();
}

class _ReceivingGoodsScreenState extends ConsumerState<ReceivingGoodsScreen> {
  final _receiverNameController = TextEditingController();
  final _notesController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  // Focus nodes for field navigation (M59)
  final _receiverNameFocus = FocusNode();
  final _notesFocus = FocusNode();

  /// Map of item id -> received quantity controller
  final Map<String, TextEditingController> _qtyControllers = {};
  bool _isSaving = false;
  bool _isDirty = false; // M65: unsaved changes tracking

  @override
  void dispose() {
    _receiverNameController.dispose();
    _notesController.dispose();
    _receiverNameFocus.dispose();
    _notesFocus.dispose();
    for (final c in _qtyControllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  /// Ensure controllers exist for each item
  void _ensureControllers(List<PurchaseItemsTableData> items) {
    for (final item in items) {
      if (!_qtyControllers.containsKey(item.id)) {
        _qtyControllers[item.id] = TextEditingController(
          text: '${item.qty}',
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isWide = size.width > 900;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;

    final asyncDetail = ref.watch(purchaseDetailProvider(widget.purchaseId));

    return PopScope(
      canPop: !_isDirty,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        final shouldPop = await showDialog<bool>(
          context: context,
          builder: (context) => ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: AlertDialog(
              title: const Text('تغييرات غير محفوظة'),
              content: const Text('هل تريد المغادرة بدون حفظ التغييرات؟'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('إلغاء'),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: const Text('مغادرة'),
                ),
              ],
            ),
          ),
        );
        if (shouldPop == true && context.mounted) Navigator.pop(context);
      },
      child: Column(
        children: [
          AppHeader(
            title: 'استلام البضاعة',
            onMenuTap: isWide ? null : () => Scaffold.of(context).openDrawer(),
            onNotificationsTap: () =>
                context.push(AppRoutes.notificationsCenter),
            notificationsCount: 0,
            userName: l10n.cashCustomer,
            userRole: l10n.branchManager,
          ),
          Expanded(
            child: asyncDetail.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => _buildError(isDark, e.toString()),
              data: (data) {
                if (data == null) {
                  return _buildError(isDark, 'لم يتم العثور على طلب الشراء');
                }
                _ensureControllers(data.items);
                return _buildContent(context, data, isWide, isDark, l10n);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildError(bool isDark, String message) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error_outline, size: 48, color: AppColors.error),
          const SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(
              fontSize: 16,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: () =>
                context.go(AppRoutes.purchaseDetailPath(widget.purchaseId)),
            icon: const Icon(Icons.arrow_back),
            label: const Text('العودة'),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    PurchaseDetailData data,
    bool isWide,
    bool isDark,
    AppLocalizations l10n,
  ) {
    final purchase = data.purchase;
    final items = data.items;

    // M121: constrain form width on desktop
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1000),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: EdgeInsets.all(isWide ? 24 : 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Back button
            Row(
              children: [
                IconButton(
                  onPressed: () =>
                      context.go(AppRoutes.purchaseDetailPath(widget.purchaseId)),
                  icon: Icon(
                    Icons.arrow_back_rounded,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'استلام البضاعة - ${purchase.purchaseNumber}',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            if (isWide)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 2,
                    child: Column(
                      children: [
                        _buildPurchaseInfoCard(purchase, isDark),
                        const SizedBox(height: 16),
                        _buildItemsTable(items, isDark, isWide),
                      ],
                    ),
                  ),
                  const SizedBox(width: 24),
                  Expanded(
                    flex: 1,
                    child: Column(
                      children: [
                        _buildReceiverCard(isDark),
                        const SizedBox(height: 16),
                        _buildConfirmButton(isDark),
                      ],
                    ),
                  ),
                ],
              )
            else
              Column(
                children: [
                  _buildPurchaseInfoCard(purchase, isDark),
                  const SizedBox(height: 16),
                  _buildItemsTable(items, isDark, isWide),
                  const SizedBox(height: 16),
                  _buildReceiverCard(isDark),
                  const SizedBox(height: 16),
                  _buildConfirmButton(isDark),
                ],
              ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Purchase info header (read only)
  // ---------------------------------------------------------------------------
  Widget _buildPurchaseInfoCard(PurchasesTableData purchase, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).dividerColor,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.receipt_long_rounded,
                    color: AppColors.primary, size: 20),
              ),
              const SizedBox(width: 12),
              Text(
                'بيانات الطلب',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _infoRow('رقم الطلب', purchase.purchaseNumber, isDark),
          const SizedBox(height: 8),
          _infoRow('المورد', purchase.supplierName ?? '-', isDark),
          const SizedBox(height: 8),
          _infoRow(
            'الإجمالي',
            '${purchase.total.toStringAsFixed(2)} ر.س',
            isDark,
            valueColor: isDark ? AppColors.primaryLight : AppColors.primaryDark,
          ),
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value, bool isDark, {Color? valueColor}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: valueColor ?? (Theme.of(context).colorScheme.onSurface),
          ),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // Items table with editable received quantity
  // ---------------------------------------------------------------------------
  Widget _buildItemsTable(
    List<PurchaseItemsTableData> items,
    bool isDark,
    bool isWide,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).dividerColor,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.info.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.inventory_2_rounded,
                    color: AppColors.info, size: 20),
              ),
              const SizedBox(width: 12),
              Text(
                'الأصناف المستلمة',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Divider(
            color: Theme.of(context).dividerColor,
          ),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: items.length,
            separatorBuilder: (_, __) => Divider(
              height: 1,
              color: Theme.of(context).dividerColor,
            ),
            itemBuilder: (context, index) {
              final item = items[index];
              final qtyCtrl = _qtyControllers[item.id]!;
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: isWide
                    ? Row(
                        children: [
                          // Product name
                          Expanded(
                            flex: 3,
                            child: Text(
                              item.productName,
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                            ),
                          ),
                          // Ordered qty
                          Expanded(
                            child: Text(
                              'الطلب: ${item.qty}',
                              style: TextStyle(
                                fontSize: 13,
                                color: Theme.of(context).colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ),
                          // Received qty (editable)
                          SizedBox(
                            width: 100,
                            child: TextFormField(
                              controller: qtyCtrl,
                              keyboardType: TextInputType.number,
                              textInputAction: TextInputAction.next,
                              onChanged: (_) {
                                if (!_isDirty) setState(() => _isDirty = true);
                              },
                              decoration: InputDecoration(
                                labelText: 'المستلم',
                                isDense: true,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 8,
                                ),
                              ),
                            ),
                          ),
                          // Unit cost
                          Expanded(
                            child: Text(
                              '${item.unitCost.toStringAsFixed(2)} ر.س',
                              textAlign: TextAlign.end,
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                            ),
                          ),
                        ],
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.productName,
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Text(
                                'الطلب: ${item.qty}',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                '${item.unitCost.toStringAsFixed(2)} ر.س/وحدة',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                                ),
                              ),
                              const Spacer(),
                              SizedBox(
                                width: 90,
                                child: TextFormField(
                                  controller: qtyCtrl,
                                  keyboardType: TextInputType.number,
                                  textInputAction: TextInputAction.next,
                                  onChanged: (_) {
                                    if (!_isDirty) setState(() => _isDirty = true);
                                  },
                                  decoration: InputDecoration(
                                    labelText: 'المستلم',
                                    isDense: true,
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    contentPadding:
                                        const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 8,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
              );
            },
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Receiver info card
  // ---------------------------------------------------------------------------
  Widget _buildReceiverCard(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).dividerColor,
        ),
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
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.person_rounded,
                    color: AppColors.warning, size: 20),
              ),
              const SizedBox(width: 12),
              Text(
                'بيانات الاستلام',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Receiver name (required)
          TextFormField(
            controller: _receiverNameController,
            focusNode: _receiverNameFocus,
            textInputAction: TextInputAction.next,
            onFieldSubmitted: (_) => _notesFocus.requestFocus(),
            onChanged: (_) {
              if (!_isDirty) setState(() => _isDirty = true);
            },
            maxLength: 100,
            validator: FormValidators.name(isRequired: true),
            decoration: InputDecoration(
              labelText: 'اسم المستلم *',
              prefixIcon: const Icon(Icons.person_outline),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          const SizedBox(height: 12),
          // Notes (optional)
          TextFormField(
            controller: _notesController,
            focusNode: _notesFocus,
            textInputAction: TextInputAction.done,
            onChanged: (_) {
              if (!_isDirty) setState(() => _isDirty = true);
            },
            maxLines: 3,
            maxLength: 500,
            validator: FormValidators.notes(),
            decoration: InputDecoration(
              labelText: 'ملاحظات الاستلام',
              prefixIcon: const Icon(Icons.notes_rounded),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              alignLabelWithHint: true,
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Confirm receipt button
  // ---------------------------------------------------------------------------
  Widget _buildConfirmButton(bool isDark) {
    return SizedBox(
      width: double.infinity,
      child: FilledButton.icon(
        onPressed: _isSaving ? null : _confirmReceipt,
        icon: _isSaving
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : const Icon(Icons.check_circle_rounded),
        label: Text(_isSaving ? 'جاري التأكيد...' : 'تأكيد الاستلام'),
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.primary,
          padding: const EdgeInsets.symmetric(vertical: 16),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Confirm receipt logic
  // ---------------------------------------------------------------------------
  Future<void> _confirmReceipt() async {
    if (!_formKey.currentState!.validate()) return;
    if (_isSaving) return;

    setState(() => _isSaving = true);
    final l10n = AppLocalizations.of(context)!;

    try {
      final db = GetIt.I<AppDatabase>();
      final storeId = ref.read(currentStoreIdProvider) ?? '';
      const uuid = Uuid();

      // 1. Mark purchase as received
      await db.purchasesDao.receivePurchase(widget.purchaseId);

      // 2. Update notes with receiver info
      final receiverData = jsonEncode({
        'receivedBy': InputSanitizer.sanitizeName(_receiverNameController.text.trim()),
        'receiveNotes': InputSanitizer.sanitize(_notesController.text.trim()),
        'receivedAt': DateTime.now().toIso8601String(),
      });

      final existingPurchase =
          await db.purchasesDao.getPurchaseById(widget.purchaseId);
      if (existingPurchase != null) {
        final currentNotes = existingPurchase.notes ?? '';
        final updatedNotes = currentNotes.isEmpty
            ? receiverData
            : '$currentNotes\n---\n$receiverData';

        await db.purchasesDao.updatePurchase(existingPurchase.copyWith(
          notes: Value(updatedNotes),
        ));
      }

      // 3. Update product stock for each item
      final asyncDetail =
          ref.read(purchaseDetailProvider(widget.purchaseId)).valueOrNull;
      if (asyncDetail != null) {
        for (final item in asyncDetail.items) {
          final receivedQty =
              int.tryParse(_qtyControllers[item.id]?.text ?? '0') ?? 0;
          if (receivedQty <= 0) continue;

          try {
            final product =
                await db.productsDao.getProductById(item.productId);
            if (product != null) {
              final previousQty = product.stockQty;
              final newQty = previousQty + receivedQty;
              await db.productsDao.updateStock(item.productId, newQty);

              // Record inventory movement
              await db.inventoryDao.recordPurchaseMovement(
                id: uuid.v4(),
                productId: item.productId,
                storeId: storeId,
                qty: receivedQty.toDouble(),
                previousQty: previousQty.toDouble(),
                purchaseId: widget.purchaseId,
              );
            }
          } catch (e) {
            debugPrint('خطأ في تحديث المخزون: ${item.productId}: $e');
          }
        }
      }

      // 4. Sync and invalidate
      try {
        await ref.read(syncServiceProvider).enqueueUpdate(
          tableName: 'purchases',
          recordId: widget.purchaseId,
          changes: {
            'id': widget.purchaseId,
            'status': 'received',
            'received_at': DateTime.now().toIso8601String(),
          },
        );
      } catch (e) {
        debugPrint('Sync enqueue error: $e');
      }

      ref.invalidate(purchasesListProvider);
      ref.invalidate(purchaseDetailProvider(widget.purchaseId));

      // 5. Show success and navigate back
      if (mounted) {
        setState(() {
          _isSaving = false;
          _isDirty = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.success),
            backgroundColor: AppColors.success,
          ),
        );
        context.go(AppRoutes.purchaseDetailPath(widget.purchaseId));
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSaving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.errorWithDetails('$e')),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }
}
