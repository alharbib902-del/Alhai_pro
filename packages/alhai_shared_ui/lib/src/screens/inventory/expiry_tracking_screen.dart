import 'package:drift/drift.dart' hide Column;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import 'package:alhai_database/alhai_database.dart';
import 'package:get_it/get_it.dart';
import 'package:alhai_l10n/alhai_l10n.dart';
import 'package:alhai_auth/alhai_auth.dart';
import 'package:alhai_design_system/alhai_design_system.dart';
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
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;

    return expiryAsync.when(
      loading: () => Scaffold(
        appBar: AppBar(title: Text(l10n.expiryTracking)),
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (error, _) => Scaffold(
        appBar: AppBar(title: Text(l10n.expiryTracking)),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64, color: colorScheme.error),
              SizedBox(height: AlhaiSpacing.md),
              Text(l10n.errorLoadingExpiryData,
                  style: TextStyle(color: colorScheme.error, fontSize: 16)),
              SizedBox(height: AlhaiSpacing.xs),
              Text('$error', style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: 12)),
              SizedBox(height: AlhaiSpacing.md),
              TextButton.icon(
                onPressed: () => ref.invalidate(expiryTrackingProvider),
                icon: const Icon(Icons.refresh),
                label: Text(l10n.retry),
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
            title: Text(l10n.expiryTracking),
            bottom: TabBar(
              controller: _tabController,
              tabs: [
                Tab(
                  icon: Badge(
                    label: Text('${within7.length}'),
                    backgroundColor: colorScheme.error,
                    child: const Icon(Icons.warning_amber),
                  ),
                  text: l10n.nearExpiry,
                ),
                Tab(
                  icon: Badge(
                    label: Text('${within30.length}'),
                    backgroundColor: AlhaiColors.warning,
                    child: const Icon(Icons.schedule),
                  ),
                  text: l10n.withinMonth,
                ),
                Tab(
                  icon: Badge(
                    label: Text('${expired.length}'),
                    backgroundColor: colorScheme.onSurfaceVariant,
                    child: const Icon(Icons.dangerous),
                  ),
                  text: l10n.expired,
                ),
              ],
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: () => ref.invalidate(expiryTrackingProvider),
                tooltip: l10n.refresh,
              ),
            ],
          ),
          body: LayoutBuilder(
            builder: (context, constraints) {
              final isMobile = constraints.maxWidth < 600;
              final isDesktop = constraints.maxWidth >= 1200;
              final padding = isMobile ? 12.0 : isDesktop ? AlhaiSpacing.lg : AlhaiSpacing.md;
              return TabBarView(
                controller: _tabController,
                children: [
                  _buildExpiryList(within7, colorScheme.error, l10n.noProductsExpiringIn7Days, l10n, padding),
                  _buildExpiryList(within30, AlhaiColors.warning, l10n.noProductsExpiringInMonth, l10n, padding),
                  _buildExpiryList(expired, colorScheme.onSurfaceVariant, l10n.noExpiredProducts, l10n, padding),
                ],
              );
            },
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () => _showAddExpiryDialog(l10n),
            icon: const Icon(Icons.add),
            label: Text(l10n.addProduct),
          ),
        );
      },
    );
  }

  Widget _buildExpiryList(
      List<ExpiryItemData> items, Color statusColor, String emptyMessage, AppLocalizations l10n, double padding) {
    if (items.isEmpty) {
      return _buildEmptyState(emptyMessage, l10n);
    }

    return RefreshIndicator(
      onRefresh: () async => ref.invalidate(expiryTrackingProvider),
      child: ListView.builder(
        padding: EdgeInsets.all(padding),
        itemCount: items.length,
        itemBuilder: (context, index) {
          final item = items[index];
          return _buildExpiryCard(item, statusColor, l10n);
        },
      ),
    );
  }

  Widget _buildExpiryCard(ExpiryItemData item, Color statusColor, AppLocalizations l10n) {
    final daysLeft = item.expiry.expiryDate.difference(DateTime.now()).inDays;
    final dateFormatter = DateFormat('yyyy/MM/dd', 'ar');
    final isExpired = daysLeft < 0;
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      margin: const EdgeInsets.only(bottom: AlhaiSpacing.sm),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: statusColor.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AlhaiSpacing.md),
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
                SizedBox(width: AlhaiSpacing.sm),
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
                      SizedBox(height: AlhaiSpacing.xxs),
                      Row(
                        children: [
                          if (item.expiry.batchNumber != null) ...[
                            Icon(Icons.inventory,
                                size: 14, color: colorScheme.onSurfaceVariant),
                            SizedBox(width: AlhaiSpacing.xxs),
                            Text(
                              '${l10n.batch}: ${item.expiry.batchNumber}',
                              style: TextStyle(
                                fontSize: 12,
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                            SizedBox(width: AlhaiSpacing.md),
                          ],
                          Icon(Icons.inventory_2,
                              size: 14, color: colorScheme.onSurfaceVariant),
                          SizedBox(width: AlhaiSpacing.xxs),
                          Text(
                            '${l10n.quantity}: ${item.expiry.quantity}',
                            style: TextStyle(
                              fontSize: 12,
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: AlhaiSpacing.sm, vertical: 6),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    isExpired
                        ? l10n.expiredSinceDays(-daysLeft)
                        : l10n.remainingDays(daysLeft),
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: statusColor,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: AlhaiSpacing.sm),
            Row(
              children: [
                Icon(Icons.calendar_today,
                    size: 14, color: colorScheme.onSurfaceVariant),
                SizedBox(width: AlhaiSpacing.xxs),
                Text(
                  '${l10n.expiryDate}: ${dateFormatter.format(item.expiry.expiryDate)}',
                  style: TextStyle(
                    fontSize: 13,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                const Spacer(),
                // Action buttons
                TextButton.icon(
                  onPressed: null,
                  icon: const Icon(Icons.local_offer, size: 16),
                  label: Text(l10n.discount, style: const TextStyle(fontSize: 12)),
                  style: TextButton.styleFrom(
                    foregroundColor: colorScheme.primary,
                    padding:
                        const EdgeInsets.symmetric(horizontal: AlhaiSpacing.xs, vertical: AlhaiSpacing.xxs),
                  ),
                ),
                SizedBox(width: AlhaiSpacing.xxs),
                TextButton.icon(
                  onPressed: () => _confirmRemove(item, l10n),
                  icon: const Icon(Icons.delete_outline, size: 16),
                  label: Text(l10n.remove, style: const TextStyle(fontSize: 12)),
                  style: TextButton.styleFrom(
                    foregroundColor: colorScheme.error,
                    padding:
                        const EdgeInsets.symmetric(horizontal: AlhaiSpacing.xs, vertical: AlhaiSpacing.xxs),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(String message, AppLocalizations l10n) {
    final colorScheme = Theme.of(context).colorScheme;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.check_circle_outline, size: 64, color: AlhaiColors.success.withValues(alpha: 0.7)),
          SizedBox(height: AlhaiSpacing.md),
          Text(
            message,
            style: TextStyle(
              fontSize: 16,
              color: colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: AlhaiSpacing.xs),
          Text(
            l10n.pressToAddExpiryTracking,
            style: TextStyle(
              fontSize: 13,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  void _showDiscountDialog(ExpiryItemData item, AppLocalizations l10n) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${l10n.applyDiscountTo} "${item.productName}" - ${l10n.featureNotAvailableNow}'),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
    );
  }

  void _confirmRemove(ExpiryItemData item, AppLocalizations l10n) {
    final colorScheme = Theme.of(context).colorScheme;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.confirmRemoval),
        content: Text(
            '${l10n.removeExpiryTrackingFor} "${item.productName}"?\n'
            '${l10n.batch}: ${item.expiry.batchNumber ?? "-"}\n'
            '${l10n.quantity}: ${item.expiry.quantity}'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await _removeExpiry(item, l10n);
            },
            style: FilledButton.styleFrom(backgroundColor: colorScheme.error),
            child: Text(l10n.remove),
          ),
        ],
      ),
    );
  }

  Future<void> _removeExpiry(ExpiryItemData item, AppLocalizations l10n) async {
    // استخدام المزود مع SyncQueue
    final success = await deleteExpiryRecord(ref, item.expiry.id);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(success ? l10n.expiryTrackingRemoved : l10n.errorRemovingExpiryTracking),
          backgroundColor: success ? AlhaiColors.success : Theme.of(context).colorScheme.error,
        ),
      );
    }
  }

  void _showAddExpiryDialog(AppLocalizations l10n) {
    _barcodeController.clear();
    _batchController.clear();
    _quantityController.text = '1';
    _notesController.clear();
    _selectedExpiryDate = null;
    _selectedProductId = null;
    _selectedProductName = null;

    final colorScheme = Theme.of(context).colorScheme;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: Text(l10n.addExpiryDate),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Product search by barcode
                TextField(
                  controller: _barcodeController,
                  decoration: InputDecoration(
                    labelText: l10n.barcodeOrProductName,
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
                  SizedBox(height: AlhaiSpacing.xs),
                  Container(
                    padding: const EdgeInsets.all(AlhaiSpacing.xs),
                    decoration: BoxDecoration(
                      color: AlhaiColors.success.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AlhaiColors.success.withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.check_circle, size: 16, color: AlhaiColors.success),
                        SizedBox(width: AlhaiSpacing.xs),
                        Expanded(
                          child: Text(
                            _selectedProductName!,
                            style: TextStyle(
                              color: AlhaiColors.success,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                SizedBox(height: AlhaiSpacing.md),
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
                    decoration: InputDecoration(
                      labelText: l10n.expiryDate,
                      prefixIcon: const Icon(Icons.calendar_today),
                      border: const OutlineInputBorder(),
                    ),
                    child: Text(
                      _selectedExpiryDate != null
                          ? DateFormat('yyyy/MM/dd', 'ar')
                              .format(_selectedExpiryDate!)
                          : l10n.selectDate,
                      style: TextStyle(
                        color: _selectedExpiryDate != null
                            ? null
                            : colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: AlhaiSpacing.md),
                TextField(
                  controller: _batchController,
                  decoration: InputDecoration(
                    labelText: l10n.batchNumberOptional,
                    prefixIcon: const Icon(Icons.inventory),
                    border: const OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: AlhaiSpacing.md),
                TextField(
                  controller: _quantityController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: l10n.quantity,
                    prefixIcon: const Icon(Icons.format_list_numbered),
                    border: const OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: AlhaiSpacing.md),
                TextField(
                  controller: _notesController,
                  maxLines: 2,
                  decoration: InputDecoration(
                    labelText: l10n.notesOptional,
                    prefixIcon: const Icon(Icons.notes),
                    border: const OutlineInputBorder(),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(l10n.cancel),
            ),
            FilledButton(
              onPressed: (_selectedProductId != null &&
                      _selectedExpiryDate != null)
                  ? () async {
                      Navigator.pop(ctx);
                      await _addExpiry(l10n);
                    }
                  : null,
              child: Text(l10n.add),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _searchProduct(
      String query, void Function(void Function()) setDialogState) async {
    if (query.isEmpty) return;
    final l10n = AppLocalizations.of(context)!;

    final db = GetIt.I<AppDatabase>();
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
          SnackBar(
            content: Text(l10n.productNotFound),
            backgroundColor: AlhaiColors.warning,
          ),
        );
      }
    }
  }

  Future<void> _addExpiry(AppLocalizations l10n) async {
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
          content: Text(result != null ? l10n.expiryTrackingAdded : l10n.errorAddingExpiryTracking),
          backgroundColor: result != null ? AlhaiColors.success : Theme.of(context).colorScheme.error,
        ),
      );
    }
  }
}
