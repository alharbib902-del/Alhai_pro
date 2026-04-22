/// Create a new inter-branch stock transfer (M4 companion).
///
/// Minimal but functional form:
///   - dropdown of destination stores (excluding the current one)
///   - add-item sub-dialog (product + qty)
///   - notes field
///   - Save → `StockTransfersDao.upsertTransfer` with status `pending`,
///     approvalStatus `pending`. Stock is not moved here — a separate
///     service owns the actual inventory_movements when the transfer is
///     approved / in-transit / received.
library;

import 'dart:convert';

import 'package:alhai_auth/alhai_auth.dart'
    show currentStoreIdProvider, currentUserProvider;
import 'package:alhai_database/alhai_database.dart';
import 'package:alhai_design_system/alhai_design_system.dart';
import 'package:alhai_l10n/alhai_l10n.dart';
import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';

final _candidateStoresProvider =
    FutureProvider.autoDispose<List<StoresTableData>>((ref) async {
  final currentStoreId = ref.watch(currentStoreIdProvider);
  final db = GetIt.I<AppDatabase>();
  final all = await db.storesDao.getActiveStores();
  return all.where((s) => s.id != currentStoreId).toList(growable: false);
});

final _pickableProductsProvider =
    FutureProvider.autoDispose<List<ProductsTableData>>((ref) async {
  final storeId = ref.watch(currentStoreIdProvider);
  if (storeId == null) return const [];
  final db = GetIt.I<AppDatabase>();
  return db.productsDao.getAllProducts(storeId);
});

/// One line in the transfer's items list.
class _TransferLine {
  final String productId;
  final String productName;
  final double qty;

  const _TransferLine({
    required this.productId,
    required this.productName,
    required this.qty,
  });

  Map<String, dynamic> toJson() =>
      {'product_id': productId, 'name': productName, 'qty': qty};
}

class StockTransferFormScreen extends ConsumerStatefulWidget {
  const StockTransferFormScreen({super.key});

  @override
  ConsumerState<StockTransferFormScreen> createState() =>
      _StockTransferFormScreenState();
}

class _StockTransferFormScreenState
    extends ConsumerState<StockTransferFormScreen> {
  String? _toStoreId;
  final _notesController = TextEditingController();
  final List<_TransferLine> _lines = [];
  bool _saving = false;

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _addLine() async {
    final products = ref.read(_pickableProductsProvider).valueOrNull;
    if (products == null || products.isEmpty) return;

    final picked = await showDialog<_TransferLine>(
      context: context,
      builder: (ctx) => _AddItemDialog(products: products),
    );
    if (picked != null) {
      setState(() => _lines.add(picked));
    }
  }

  Future<void> _submit() async {
    if (_saving) return;
    final l10n = AppLocalizations.of(context);
    final storeId = ref.read(currentStoreIdProvider);
    if (storeId == null || _toStoreId == null || _lines.isEmpty) return;

    setState(() => _saving = true);
    final messenger = ScaffoldMessenger.of(context);
    final router = GoRouter.of(context);
    final db = GetIt.I<AppDatabase>();
    final currentUser = ref.read(currentUserProvider);
    final now = DateTime.now();

    try {
      final id = 'st_${now.millisecondsSinceEpoch}';
      final number =
          'TRF-${now.year}${now.month.toString().padLeft(2, '0')}'
          '${now.day.toString().padLeft(2, '0')}-'
          '${now.millisecondsSinceEpoch % 10000}';
      await db.stockTransfersDao.upsertTransfer(
        StockTransfersTableCompanion.insert(
          id: id,
          transferNumber: number,
          fromStoreId: storeId,
          toStoreId: _toStoreId!,
          items: jsonEncode(_lines.map((l) => l.toJson()).toList()),
          notes: Value(
            _notesController.text.trim().isEmpty
                ? null
                : _notesController.text.trim(),
          ),
          createdBy: Value(currentUser?.id),
          createdAt: now,
        ),
      );
      if (!mounted) return;
      messenger.showSnackBar(
        SnackBar(
          content: Text(l10n.stockTransferCreatedSuccess),
          backgroundColor: AppColors.success,
        ),
      );
      router.pop(true);
    } catch (e) {
      if (kDebugMode) debugPrint('Create transfer failed: $e');
      if (!mounted) return;
      messenger.showSnackBar(
        SnackBar(
          content: Text(l10n.errorWithDetails('$e')),
          backgroundColor: AppColors.error,
        ),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final storesAsync = ref.watch(_candidateStoresProvider);
    final canSubmit =
        _toStoreId != null && _lines.isNotEmpty && !_saving;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.stockTransferNewTitle),
        actions: [
          FilledButton.icon(
            onPressed: canSubmit ? _submit : null,
            icon: _saving
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.check_rounded, size: 18),
            label: Text(l10n.stockTransferCreate),
          ),
          const SizedBox(width: AlhaiSpacing.sm),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(AlhaiSpacing.md),
        children: [
          storesAsync.when(
            loading: () => const LinearProgressIndicator(),
            error: (err, _) => Text(l10n.errorWithDetails('$err')),
            data: (stores) => DropdownButtonFormField<String>(
              initialValue: _toStoreId,
              items: stores
                  .map(
                    (s) => DropdownMenuItem(
                      value: s.id,
                      child: Text(s.name),
                    ),
                  )
                  .toList(),
              onChanged: (v) => setState(() => _toStoreId = v),
              decoration: InputDecoration(
                labelText: l10n.stockTransferToStore,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          const SizedBox(height: AlhaiSpacing.lg),
          Row(
            children: [
              Text(
                l10n.stockTransferAddItem,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              OutlinedButton.icon(
                onPressed: _addLine,
                icon: const Icon(Icons.add_rounded, size: 18),
                label: Text(l10n.stockTransferAddItem),
              ),
            ],
          ),
          const SizedBox(height: AlhaiSpacing.sm),
          if (_lines.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: AlhaiSpacing.md),
              child: Text(
                l10n.stockTransferNoItems,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            )
          else
            ..._lines.asMap().entries.map(
              (e) => Card(
                child: ListTile(
                  title: Text(e.value.productName),
                  subtitle: Text(e.value.qty.toStringAsFixed(0)),
                  trailing: IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () =>
                        setState(() => _lines.removeAt(e.key)),
                  ),
                ),
              ),
            ),
          const SizedBox(height: AlhaiSpacing.lg),
          TextField(
            controller: _notesController,
            decoration: InputDecoration(
              labelText: l10n.notes,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            maxLines: 3,
          ),
        ],
      ),
    );
  }
}

class _AddItemDialog extends StatefulWidget {
  final List<ProductsTableData> products;

  const _AddItemDialog({required this.products});

  @override
  State<_AddItemDialog> createState() => _AddItemDialogState();
}

class _AddItemDialogState extends State<_AddItemDialog> {
  String _query = '';
  ProductsTableData? _selected;
  final _qtyController = TextEditingController(text: '1');

  @override
  void dispose() {
    _qtyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final filtered = _query.isEmpty
        ? widget.products.take(50).toList()
        : widget.products
              .where(
                (p) =>
                    p.name.toLowerCase().contains(_query.toLowerCase()) ||
                    (p.barcode?.contains(_query) ?? false),
              )
              .take(50)
              .toList();

    return AlertDialog(
      title: Text(l10n.stockTransferAddItem),
      content: SizedBox(
        width: 400,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: InputDecoration(
                hintText: l10n.searchByNameOrBarcode,
                prefixIcon: const Icon(Icons.search_rounded),
              ),
              onChanged: (v) => setState(() {
                _query = v.trim();
                _selected = null;
              }),
            ),
            const SizedBox(height: AlhaiSpacing.sm),
            if (_selected == null)
              SizedBox(
                height: 240,
                child: ListView.builder(
                  itemCount: filtered.length,
                  itemBuilder: (_, i) => ListTile(
                    dense: true,
                    title: Text(filtered[i].name),
                    subtitle: Text(filtered[i].barcode ?? ''),
                    onTap: () => setState(() => _selected = filtered[i]),
                  ),
                ),
              )
            else
              Card(
                child: ListTile(
                  title: Text(_selected!.name),
                  trailing: IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => setState(() => _selected = null),
                  ),
                ),
              ),
            const SizedBox(height: AlhaiSpacing.sm),
            TextField(
              controller: _qtyController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
              ],
              decoration: InputDecoration(
                labelText: l10n.quantity,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l10n.cancel),
        ),
        FilledButton(
          onPressed: _selected == null
              ? null
              : () {
                  final qty = double.tryParse(_qtyController.text) ?? 0;
                  if (qty <= 0) return;
                  Navigator.pop(
                    context,
                    _TransferLine(
                      productId: _selected!.id,
                      productName: _selected!.name,
                      qty: qty,
                    ),
                  );
                },
          child: Text(l10n.stockTransferAddItem),
        ),
      ],
    );
  }
}
