import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:alhai_shared_ui/alhai_shared_ui.dart';
import 'package:alhai_l10n/alhai_l10n.dart';
import 'package:alhai_database/alhai_database.dart';
import 'package:get_it/get_it.dart';
import '../../providers/purchases_providers.dart';
import 'package:alhai_design_system/alhai_design_system.dart';

/// Send to Distributor Screen - شاشة إرسال الطلب للموزع
class SendToDistributorScreen extends ConsumerStatefulWidget {
  final String purchaseId;

  const SendToDistributorScreen({super.key, required this.purchaseId});

  @override
  ConsumerState<SendToDistributorScreen> createState() =>
      _SendToDistributorScreenState();
}

class _SendToDistributorScreenState
    extends ConsumerState<SendToDistributorScreen> {
  final _notesController = TextEditingController();
  String? _selectedSupplierId;
  bool _isSending = false;
  bool _supplierInitialized = false;

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isWide = size.width > 900;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context);

    final asyncDetail = ref.watch(purchaseDetailProvider(widget.purchaseId));
    final asyncSuppliers = ref.watch(activeSuppliersProvider);

    return Column(
      children: [
        AppHeader(
          title: l10n.sendToDistributor,
          onMenuTap: isWide ? null : () => Scaffold.of(context).openDrawer(),
          onNotificationsTap: () => context.push(AppRoutes.notificationsCenter),
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
                return _buildError(isDark, l10n.purchaseNotFound);
              }
              // Pre-select supplier from purchase if not yet initialized
              if (!_supplierInitialized &&
                  data.purchase.supplierId != null &&
                  data.purchase.supplierId!.isNotEmpty) {
                _selectedSupplierId = data.purchase.supplierId;
                _supplierInitialized = true;
              }
              return _buildContent(
                context,
                data,
                asyncSuppliers,
                isWide,
                isDark,
                l10n,
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildError(bool isDark, String message) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error_outline, size: 48, color: AppColors.error),
          const SizedBox(height: AlhaiSpacing.md),
          Text(
            message,
            style: TextStyle(
              fontSize: 16,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: AlhaiSpacing.md),
          FilledButton.icon(
            onPressed: () =>
                context.go(AppRoutes.purchaseDetailPath(widget.purchaseId)),
            icon: Icon(
              Directionality.of(context) == TextDirection.rtl
                  ? Icons.arrow_forward_rounded
                  : Icons.arrow_back_rounded,
            ),
            label: Text(AppLocalizations.of(context).goBack),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    PurchaseDetailData data,
    AsyncValue<List<SuppliersTableData>> asyncSuppliers,
    bool isWide,
    bool isDark,
    AppLocalizations l10n,
  ) {
    final purchase = data.purchase;
    final items = data.items;

    return SingleChildScrollView(
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
                  Directionality.of(context) == TextDirection.rtl
                      ? Icons.arrow_forward_rounded
                      : Icons.arrow_back_rounded,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
                tooltip: AppLocalizations.of(context).back,
              ),
              const SizedBox(width: AlhaiSpacing.xs),
              Expanded(
                child: Text(
                  AppLocalizations.of(context).sendToDistributorTitle,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AlhaiSpacing.mdl),

          if (isWide)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 2,
                  child: Column(
                    children: [
                      _buildPurchaseInfoCard(purchase, isDark),
                      const SizedBox(height: AlhaiSpacing.md),
                      _buildItemsSummary(items, isDark),
                    ],
                  ),
                ),
                const SizedBox(width: AlhaiSpacing.lg),
                Expanded(
                  flex: 1,
                  child: Column(
                    children: [
                      _buildSupplierCard(asyncSuppliers, isDark, l10n),
                      const SizedBox(height: AlhaiSpacing.md),
                      _buildNotesCard(isDark),
                      const SizedBox(height: AlhaiSpacing.md),
                      _buildSendButton(isDark),
                    ],
                  ),
                ),
              ],
            )
          else
            Column(
              children: [
                _buildPurchaseInfoCard(purchase, isDark),
                const SizedBox(height: AlhaiSpacing.md),
                _buildItemsSummary(items, isDark),
                const SizedBox(height: AlhaiSpacing.md),
                _buildSupplierCard(asyncSuppliers, isDark, l10n),
                const SizedBox(height: AlhaiSpacing.md),
                _buildNotesCard(isDark),
                const SizedBox(height: AlhaiSpacing.md),
                _buildSendButton(isDark),
              ],
            ),

          const SizedBox(height: AlhaiSpacing.xl),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Purchase info (readonly)
  // ---------------------------------------------------------------------------
  Widget _buildPurchaseInfoCard(PurchasesTableData purchase, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(AlhaiSpacing.mdl),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Theme.of(context).dividerColor),
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
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.receipt_long_rounded,
                  color: AppColors.info,
                  size: 20,
                ),
              ),
              const SizedBox(width: AlhaiSpacing.sm),
              Text(
                AppLocalizations.of(context).orderInfo,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: AlhaiSpacing.md),
          _infoRow(
            AppLocalizations.of(context).orderNumber,
            purchase.purchaseNumber,
            isDark,
          ),
          const SizedBox(height: AlhaiSpacing.xs),
          _infoRow(
            AppLocalizations.of(context).currentSupplier,
            purchase.supplierName ?? AppLocalizations.of(context).unspecified,
            isDark,
          ),
          const SizedBox(height: AlhaiSpacing.xs),
          _infoRow(
            AppLocalizations.of(context).totalLabel,
            AppLocalizations.of(
              context,
            ).amountSar(purchase.total.toStringAsFixed(2)),
            isDark,
            valueColor: isDark ? AppColors.primaryLight : AppColors.primaryDark,
          ),
        ],
      ),
    );
  }

  Widget _infoRow(
    String label,
    String value,
    bool isDark, {
    Color? valueColor,
  }) {
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
  // Items summary
  // ---------------------------------------------------------------------------
  Widget _buildItemsSummary(List<PurchaseItemsTableData> items, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(AlhaiSpacing.mdl),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AlhaiSpacing.xs),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.list_alt_rounded,
                  color: AppColors.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: AlhaiSpacing.sm),
              Text(
                AppLocalizations.of(context).itemsSummary,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  AppLocalizations.of(context).itemCountLabel(items.length),
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AlhaiSpacing.md),
          Divider(color: Theme.of(context).dividerColor),
          if (items.isEmpty)
            AppEmptyState.noProducts(context)
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: items.length,
              separatorBuilder: (_, __) =>
                  Divider(height: 1, color: Theme.of(context).dividerColor),
              itemBuilder: (context, index) {
                final item = items[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          item.productName,
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                      ),
                      Text(
                        '${item.qty} \u00D7 ${item.unitCost.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: 13,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(width: AlhaiSpacing.sm),
                      Text(
                        AppLocalizations.of(
                          context,
                        ).amountSar(item.total.toStringAsFixed(2)),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: isDark
                              ? AppColors.primaryLight
                              : AppColors.primaryDark,
                        ),
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
  // Supplier selection
  // ---------------------------------------------------------------------------
  Widget _buildSupplierCard(
    AsyncValue<List<SuppliersTableData>> asyncSuppliers,
    bool isDark,
    AppLocalizations l10n,
  ) {
    return Container(
      padding: const EdgeInsets.all(AlhaiSpacing.mdl),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AlhaiSpacing.xs),
                decoration: BoxDecoration(
                  color: AppColors.secondary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.store_rounded,
                  color: AppColors.secondary,
                  size: 20,
                ),
              ),
              const SizedBox(width: AlhaiSpacing.sm),
              Text(
                AppLocalizations.of(context).distributorSupplier,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: AlhaiSpacing.md),
          asyncSuppliers.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Text(
              l10n.errorLoadingSuppliers(e),
              style: const TextStyle(color: AppColors.error),
            ),
            data: (suppliers) {
              return DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  labelText: l10n.selectSupplierRequired,
                  prefixIcon: const Icon(Icons.store),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                initialValue: _selectedSupplierId,
                items: suppliers
                    .map(
                      (s) => DropdownMenuItem(value: s.id, child: Text(s.name)),
                    )
                    .toList(),
                onChanged: (v) => setState(() => _selectedSupplierId = v),
              );
            },
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Notes card
  // ---------------------------------------------------------------------------
  Widget _buildNotesCard(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(AlhaiSpacing.mdl),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AlhaiSpacing.xs),
                decoration: BoxDecoration(
                  color: AppColors.warning.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.notes_rounded,
                  color: AppColors.warning,
                  size: 20,
                ),
              ),
              const SizedBox(width: AlhaiSpacing.sm),
              Text(
                AppLocalizations.of(context).additionalMessage,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: AlhaiSpacing.md),
          TextFormField(
            controller: _notesController,
            maxLines: 4,
            decoration: InputDecoration(
              hintText: AppLocalizations.of(context).addNotesForDistributor,
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
  // Send button
  // ---------------------------------------------------------------------------
  Widget _buildSendButton(bool isDark) {
    return SizedBox(
      width: double.infinity,
      child: FilledButton.icon(
        onPressed: _isSending ? null : _sendToDistributor,
        icon: _isSending
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : const Icon(Icons.send_rounded),
        label: Text(
          _isSending
              ? AppLocalizations.of(context).sending
              : AppLocalizations.of(context).sendToDistributor,
        ),
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.info,
          padding: const EdgeInsets.symmetric(vertical: AlhaiSpacing.md),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Send logic
  // ---------------------------------------------------------------------------
  Future<void> _sendToDistributor() async {
    if (_selectedSupplierId == null || _selectedSupplierId!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context).pleaseSelectDistributor),
          backgroundColor: AppColors.warning,
        ),
      );
      return;
    }

    if (_isSending) return;
    setState(() => _isSending = true);

    try {
      final db = GetIt.I<AppDatabase>();

      // 1. Update status to 'sent'
      await db.purchasesDao.updateStatus(widget.purchaseId, 'sent');

      // 2. Update supplier if changed and add notes
      final existingPurchase = await db.purchasesDao.getPurchaseById(
        widget.purchaseId,
      );
      if (existingPurchase != null) {
        // Get selected supplier name
        final suppliers = ref.read(activeSuppliersProvider).valueOrNull ?? [];
        final selectedSupplier = suppliers
            .where((s) => s.id == _selectedSupplierId)
            .firstOrNull;
        final supplierName =
            selectedSupplier?.name ?? existingPurchase.supplierName ?? '';

        String updatedNotes = existingPurchase.notes ?? '';
        if (_notesController.text.trim().isNotEmpty) {
          updatedNotes = updatedNotes.isEmpty
              ? _notesController.text.trim()
              : '$updatedNotes\n---\n${_notesController.text.trim()}';
        }

        await db.purchasesDao.updatePurchase(
          existingPurchase.copyWith(
            supplierId: Value(_selectedSupplierId),
            supplierName: Value(supplierName),
            notes: Value(updatedNotes),
          ),
        );
      }

      // 3. Sync
      try {
        await ref
            .read(syncServiceProvider)
            .enqueueUpdate(
              tableName: 'purchases',
              recordId: widget.purchaseId,
              changes: {
                'id': widget.purchaseId,
                'status': 'sent',
                'supplier_id': _selectedSupplierId,
                'updated_at': DateTime.now().toIso8601String(),
              },
            );
      } catch (e) {
        if (kDebugMode) debugPrint('Sync enqueue error: $e');
      }

      // 4. Invalidate providers
      ref.invalidate(purchasesListProvider);
      ref.invalidate(purchaseDetailProvider(widget.purchaseId));
      ref.invalidate(purchasesByStatusProvider('draft'));
      ref.invalidate(purchasesByStatusProvider('sent'));

      // 5. Show success and navigate back
      if (mounted) {
        setState(() => _isSending = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context).orderSentSuccess),
            backgroundColor: AppColors.success,
          ),
        );
        context.go(AppRoutes.purchaseDetailPath(widget.purchaseId));
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSending = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context).errorSendingOrder('$e')),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }
}
