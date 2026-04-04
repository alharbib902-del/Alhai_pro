/// Distributor Pricing Management Screen
///
/// Manage product prices with editable fields, last updated dates,
/// and a save button. Wired to real Supabase data via Riverpod.
/// Supports: RTL Arabic, dark/light theme, responsive layout.
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:alhai_design_system/alhai_design_system.dart';
import 'package:alhai_l10n/alhai_l10n.dart';
import 'package:intl/intl.dart' show NumberFormat, DateFormat;

import '../../data/models.dart';
import '../../providers/distributor_providers.dart';
import '../../ui/skeleton_loading.dart';

// ─── Screen ──────────────────────────────────────────────────────

/// شاشة إدارة الأسعار للموزع
class DistributorPricingScreen extends ConsumerStatefulWidget {
  const DistributorPricingScreen({super.key});

  @override
  ConsumerState<DistributorPricingScreen> createState() =>
      _DistributorPricingScreenState();
}

class _DistributorPricingScreenState
    extends ConsumerState<DistributorPricingScreen> {
  final Map<String, TextEditingController> _controllers = {};
  bool _isSaving = false;
  bool _hasChanges = false;

  // Sorting state
  int _sortColumnIndex = 0; // default sort by product name
  bool _sortAscending = true;

  /// Ensure a controller exists for every product. Called each build
  /// so new data from a refresh is picked up without losing in-flight edits.
  void _ensureControllers(List<DistributorProduct> products) {
    for (final p in products) {
      _controllers.putIfAbsent(p.id, () => TextEditingController());
    }
    // Remove controllers for products that no longer exist.
    final ids = products.map((p) => p.id).toSet();
    _controllers.keys.where((k) => !ids.contains(k)).toList().forEach((k) {
      _controllers[k]?.dispose();
      _controllers.remove(k);
    });
  }

  @override
  void dispose() {
    for (final c in _controllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  int _changedCount(List<DistributorProduct> products) {
    int count = 0;
    for (final p in products) {
      final text = _controllers[p.id]?.text ?? '';
      if (text.isNotEmpty && double.tryParse(text) != null) {
        count++;
      }
    }
    return count;
  }

  List<DistributorProduct> _sortProducts(List<DistributorProduct> products) {
    final sorted = List<DistributorProduct>.from(products);
    sorted.sort((a, b) {
      int result;
      switch (_sortColumnIndex) {
        case 0: // product name
          result = a.name.compareTo(b.name);
        case 1: // current price
          result = a.price.compareTo(b.price);
        default:
          result = 0;
      }
      return _sortAscending ? result : -result;
    });
    return sorted;
  }

  Future<bool> _onWillPop() async {
    if (!_hasChanges) return true;
    final l10n = AppLocalizations.of(context);
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n?.distributorUnsavedChanges ?? 'تغييرات غير محفوظة'),
        content: Text(l10n?.distributorUnsavedChangesMessage ??
            'لديك تغييرات غير محفوظة. هل تريد المغادرة بدون حفظ؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n?.distributorStay ?? 'البقاء'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: AppColors.textOnPrimary,
            ),
            child: Text(l10n?.distributorLeave ?? 'مغادرة'),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isWide = size.width >= AlhaiBreakpoints.desktop;
    final isMedium = size.width >= AlhaiBreakpoints.tablet;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cs = Theme.of(context).colorScheme;

    final l10n = AppLocalizations.of(context);
    final productsAsync = ref.watch(productsProvider);

    return PopScope(
      canPop: !_hasChanges,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        final shouldPop = await _onWillPop();
        if (shouldPop && context.mounted) {
          Navigator.of(context).pop();
        }
      },
      child: CallbackShortcuts(
        bindings: <ShortcutActivator, VoidCallback>{
          const SingleActivator(LogicalKeyboardKey.keyS, control: true): () {
            final products = productsAsync.valueOrNull;
            if (products != null && _changedCount(products) > 0 && !_isSaving) {
              _savePrices(products);
            }
          },
        },
        child: Focus(
          autofocus: true,
          child: Scaffold(
            backgroundColor: AppColors.getBackground(isDark),
            appBar: AppBar(
              title: Text(
                l10n?.distributorPricing ?? 'إدارة الأسعار',
                style:
                    TextStyle(fontWeight: FontWeight.bold, color: cs.onSurface),
              ),
              centerTitle: false,
              actions: [
                if (productsAsync.valueOrNull != null &&
                    _changedCount(productsAsync.valueOrNull!) > 0)
                  Container(
                    margin:
                        const EdgeInsets.symmetric(vertical: AlhaiSpacing.sm),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.warning.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(AlhaiRadius.md),
                    ),
                    child: Center(
                      child: Text(
                        '${_changedCount(productsAsync.valueOrNull!)} تغيير',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.warning,
                        ),
                      ),
                    ),
                  ),
                const SizedBox(width: AlhaiSpacing.sm),
              ],
            ),
            body: productsAsync.when(
              loading: () => const TableSkeleton(rows: 8, columns: 5),
              error: (e, _) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline,
                        size: 48, color: AppColors.getTextMuted(isDark)),
                    const SizedBox(height: AlhaiSpacing.md),
                    Text(
                      l10n?.distributorLoadError ?? 'حدث خطأ في تحميل البيانات',
                      style: TextStyle(
                        fontSize: 16,
                        color: AppColors.getTextSecondary(isDark),
                      ),
                    ),
                    const SizedBox(height: AlhaiSpacing.md),
                    FilledButton.icon(
                      onPressed: () => ref.invalidate(productsProvider),
                      icon: const Icon(Icons.refresh, size: 18),
                      label: Text(l10n?.distributorRetry ?? 'إعادة المحاولة'),
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: AppColors.textOnPrimary,
                      ),
                    ),
                  ],
                ),
              ),
              data: (products) {
                if (products.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.price_change_outlined,
                            size: 64, color: AppColors.getTextMuted(isDark)),
                        const SizedBox(height: AlhaiSpacing.md),
                        Text(
                          l10n?.distributorNoProducts ?? 'لا توجد منتجات',
                          style: TextStyle(
                            fontSize: 16,
                            color: AppColors.getTextSecondary(isDark),
                          ),
                        ),
                      ],
                    ),
                  );
                }
                _ensureControllers(products);
                final changed = _changedCount(products);
                final sortedProducts = _sortProducts(products);

                return Column(
                  children: [
                    _buildSummaryHeader(isDark, isMedium, products, changed),
                    Expanded(
                      child: RefreshIndicator(
                        onRefresh: () async => ref.invalidate(productsProvider),
                        child: isWide
                            ? _buildPricingTable(isDark, sortedProducts)
                            : _buildPricingCards(
                                isDark, isMedium, sortedProducts),
                      ),
                    ),
                    _buildSaveBar(isDark, isMedium, products, changed),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryHeader(bool isDark, bool isMedium,
      List<DistributorProduct> products, int changed) {
    return Container(
      padding: EdgeInsets.all(isMedium ? AlhaiSpacing.mdl : AlhaiSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.getSurface(isDark),
        border: Border(
          bottom: BorderSide(color: AppColors.getBorder(isDark)),
        ),
      ),
      child: Row(
        children: [
          _summaryCard(Icons.inventory_2_rounded, '${products.length}',
              'إجمالي المنتجات', AppColors.primary, isDark),
          const SizedBox(width: AlhaiSpacing.sm),
          _summaryCard(Icons.edit_rounded, '$changed', 'تغييرات معلقة',
              AppColors.warning, isDark),
          if (isMedium) ...[
            const SizedBox(width: AlhaiSpacing.sm),
            _summaryCard(
                Icons.update_rounded,
                DateFormat('dd/MM', 'ar').format(DateTime.now()),
                'آخر تحديث',
                AppColors.info,
                isDark),
          ],
        ],
      ),
    );
  }

  Widget _summaryCard(
      IconData icon, String value, String label, Color color, bool isDark) {
    return Expanded(
      child: Semantics(
        label: '$label: $value',
        child: Container(
          padding: const EdgeInsets.all(AlhaiSpacing.sm),
          decoration: BoxDecoration(
            color: color.withValues(alpha: isDark ? 0.1 : 0.05),
            borderRadius: BorderRadius.circular(AlhaiRadius.md),
            border: Border.all(color: color.withValues(alpha: 0.2)),
          ),
          child: Row(
            children: [
              ExcludeSemantics(child: Icon(icon, color: color, size: 20)),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(value,
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: color)),
                    Text(label,
                        style: TextStyle(
                            fontSize: 11,
                            color: AppColors.getTextSecondary(isDark))),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPricingTable(bool isDark, List<DistributorProduct> products) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AlhaiSpacing.mdl),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.getSurface(isDark),
          borderRadius: BorderRadius.circular(AlhaiRadius.lg),
          border: Border.all(color: AppColors.getBorder(isDark)),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: AlhaiSpacing.mdl, vertical: AlhaiSpacing.sm),
              decoration: BoxDecoration(
                color: AppColors.getSurfaceVariant(isDark),
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(16)),
              ),
              child: Row(
                children: [
                  _tHeader('المنتج', 4, isDark, sortIndex: 0),
                  _tHeader('السعر الحالي', 2, isDark, sortIndex: 1),
                  _tHeader('السعر الجديد', 3, isDark),
                  _tHeader('آخر تحديث', 2, isDark),
                  _tHeaderWithHelp('الفرق', 2, isDark,
                      helpText:
                          'الفرق بين السعر الجديد والسعر الحالي. أخضر = انخفاض، أحمر = زيادة'),
                ],
              ),
            ),
            ...List.generate(products.length, (index) {
              final product = products[index];
              final controller = _controllers[product.id]!;
              final newPrice = double.tryParse(controller.text);
              final hasDiff = newPrice != null && newPrice != product.price;
              final diff = hasDiff ? newPrice - product.price : 0.0;

              return Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: AlhaiSpacing.mdl, vertical: AlhaiSpacing.sm),
                decoration: BoxDecoration(
                  color: hasDiff
                      ? AppColors.warning
                          .withValues(alpha: isDark ? 0.05 : 0.02)
                      : null,
                  border: index < products.length - 1
                      ? Border(
                          bottom: BorderSide(
                              color: AppColors.getBorder(isDark)
                                  .withValues(alpha: 0.5)))
                      : null,
                ),
                child: Row(
                  children: [
                    Expanded(
                        flex: 4,
                        child: Text(product.name,
                            style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: AppColors.getTextPrimary(isDark)))),
                    Expanded(
                        flex: 2,
                        child: Text(
                            '${NumberFormat('#,##0.00').format(product.price)} ر.س',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontSize: 14,
                                color: AppColors.getTextSecondary(isDark)))),
                    Expanded(
                      flex: 3,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: AlhaiSpacing.md),
                        child: TextField(
                          controller: controller,
                          keyboardType: TextInputType.number,
                          textAlign: TextAlign.center,
                          onChanged: (_) => setState(() => _hasChanges = true),
                          style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: AppColors.getTextPrimary(isDark)),
                          decoration: InputDecoration(
                            hintText: product.price.toStringAsFixed(2),
                            hintStyle: TextStyle(
                                color: AppColors.getTextMuted(isDark)),
                            suffixText: 'ر.س',
                            suffixStyle: TextStyle(
                                fontSize: 11,
                                color: AppColors.getTextMuted(isDark)),
                            filled: true,
                            fillColor: AppColors.getSurfaceVariant(isDark),
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 10),
                            border: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.circular(AlhaiRadius.sm + 2),
                                borderSide: BorderSide(
                                    color: AppColors.getBorder(isDark))),
                            enabledBorder: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.circular(AlhaiRadius.sm + 2),
                                borderSide: BorderSide(
                                    color: AppColors.getBorder(isDark))),
                            focusedBorder: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.circular(AlhaiRadius.sm + 2),
                                borderSide: const BorderSide(
                                    color: AppColors.primary, width: 2)),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                        flex: 2,
                        child: Text(
                            product.updatedAt != null
                                ? DateFormat('dd/MM/yyyy', 'ar')
                                    .format(product.updatedAt!)
                                : '-',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontSize: 12,
                                color: AppColors.getTextMuted(isDark)))),
                    Expanded(
                      flex: 2,
                      child: hasDiff
                          ? Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                  color: (diff > 0
                                          ? AppColors.error
                                          : AppColors.success)
                                      .withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(
                                      AlhaiRadius.sm - 2)),
                              child: Text(
                                  '${diff > 0 ? '+' : ''}${NumberFormat('#,##0.00').format(diff)}',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: diff > 0
                                          ? AppColors.error
                                          : AppColors.success)))
                          : Text('-',
                              textAlign: TextAlign.center,
                              style:
                                  TextStyle(color: AppColors.getTextMuted(isDark))),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _tHeader(String text, int flex, bool isDark, {int? sortIndex}) {
    final isSorted = sortIndex != null && _sortColumnIndex == sortIndex;
    return Expanded(
      flex: flex,
      child: sortIndex != null
          ? InkWell(
              onTap: () {
                setState(() {
                  if (_sortColumnIndex == sortIndex) {
                    _sortAscending = !_sortAscending;
                  } else {
                    _sortColumnIndex = sortIndex;
                    _sortAscending = true;
                  }
                });
              },
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(text,
                      style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: isSorted
                              ? AppColors.primary
                              : AppColors.getTextSecondary(isDark))),
                  if (isSorted)
                    Icon(
                        _sortAscending
                            ? Icons.arrow_upward
                            : Icons.arrow_downward,
                        size: 14,
                        color: AppColors.primary),
                ],
              ),
            )
          : Text(text,
              style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.getTextSecondary(isDark))),
    );
  }

  Widget _tHeaderWithHelp(String text, int flex, bool isDark,
      {required String helpText}) {
    return Expanded(
      flex: flex,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(text,
              style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.getTextSecondary(isDark))),
          const SizedBox(width: 4),
          Tooltip(
            message: helpText,
            preferBelow: false,
            child: Semantics(
              label: 'Help: $helpText',
              child: Icon(
                Icons.help_outline_rounded,
                size: 14,
                color: AppColors.getTextMuted(isDark),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPricingCards(
      bool isDark, bool isMedium, List<DistributorProduct> products) {
    final l10n = AppLocalizations.of(context);
    return ListView.separated(
      padding: EdgeInsets.all(isMedium ? AlhaiSpacing.mdl : AlhaiSpacing.md),
      itemCount: products.length,
      separatorBuilder: (_, __) => const SizedBox(height: AlhaiSpacing.xs + 2),
      itemBuilder: (_, index) {
        final product = products[index];
        final controller = _controllers[product.id]!;
        final newPrice = double.tryParse(controller.text);
        final hasDiff = newPrice != null && newPrice != product.price;

        return Container(
          padding: const EdgeInsets.all(AlhaiSpacing.md),
          decoration: BoxDecoration(
            color: AppColors.getSurface(isDark),
            borderRadius: BorderRadius.circular(AlhaiRadius.md + 2),
            border: Border.all(
                color: hasDiff
                    ? AppColors.warning.withValues(alpha: 0.4)
                    : AppColors.getBorder(isDark)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                Expanded(
                    child: Text(product.name,
                        style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: AppColors.getTextPrimary(isDark)))),
                Text(
                    product.updatedAt != null
                        ? DateFormat('dd/MM', 'ar').format(product.updatedAt!)
                        : '-',
                    style: TextStyle(
                        fontSize: 11, color: AppColors.getTextMuted(isDark))),
              ]),
              const SizedBox(height: AlhaiSpacing.sm),
              Row(children: [
                Expanded(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                      Text(l10n?.distributorCurrentPrice ?? 'السعر الحالي',
                          style: TextStyle(
                              fontSize: 11,
                              color: AppColors.getTextMuted(isDark))),
                      const SizedBox(height: AlhaiSpacing.xxs),
                      Text(
                          '${NumberFormat('#,##0.00').format(product.price)} ر.س',
                          style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: AppColors.getTextSecondary(isDark))),
                    ])),
                Icon(Icons.arrow_forward_rounded,
                    color: AppColors.getTextMuted(isDark), size: 18),
                const SizedBox(width: AlhaiSpacing.sm),
                Expanded(
                  child: TextField(
                    controller: controller,
                    keyboardType: TextInputType.number,
                    onChanged: (_) => setState(() => _hasChanges = true),
                    style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: AppColors.getTextPrimary(isDark)),
                    decoration: InputDecoration(
                      labelText: 'السعر الجديد',
                      labelStyle: TextStyle(
                          fontSize: 12, color: AppColors.getTextMuted(isDark)),
                      hintText: product.price.toStringAsFixed(2),
                      hintStyle:
                          TextStyle(color: AppColors.getTextMuted(isDark)),
                      suffixText: 'ر.س',
                      suffixStyle: TextStyle(
                          fontSize: 11, color: AppColors.getTextMuted(isDark)),
                      filled: true,
                      fillColor: AppColors.getSurfaceVariant(isDark),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 12),
                      border: OutlineInputBorder(
                          borderRadius:
                              BorderRadius.circular(AlhaiRadius.sm + 2),
                          borderSide:
                              BorderSide(color: AppColors.getBorder(isDark))),
                      enabledBorder: OutlineInputBorder(
                          borderRadius:
                              BorderRadius.circular(AlhaiRadius.sm + 2),
                          borderSide:
                              BorderSide(color: AppColors.getBorder(isDark))),
                      focusedBorder: OutlineInputBorder(
                          borderRadius:
                              BorderRadius.circular(AlhaiRadius.sm + 2),
                          borderSide: const BorderSide(
                              color: AppColors.primary, width: 2)),
                    ),
                  ),
                ),
              ]),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSaveBar(bool isDark, bool isMedium,
      List<DistributorProduct> products, int changed) {
    if (changed == 0 && !_hasChanges) return const SizedBox.shrink();
    final l10n = AppLocalizations.of(context);

    return Container(
      padding: EdgeInsets.all(isMedium ? AlhaiSpacing.mdl : AlhaiSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.getSurface(isDark),
        border: Border(top: BorderSide(color: AppColors.getBorder(isDark))),
        boxShadow: [
          ...AppColors.getElevatedShadow(isDark),
        ],
      ),
      child: SafeArea(
        child: Row(children: [
          if (changed > 0)
            Expanded(
                child: Text(
                    l10n?.distributorProductsWillUpdate(changed) ??
                        '$changed منتج سيتم تحديث سعره',
                    style: TextStyle(
                        fontSize: 13,
                        color: AppColors.getTextSecondary(isDark)))),
          SizedBox(
            width: isMedium ? 200 : 160,
            child: Semantics(
              button: true,
              label: l10n?.distributorSaveCtrlS ?? 'حفظ التغييرات (Ctrl+S)',
              child: FilledButton.icon(
                onPressed: _isSaving || changed == 0
                    ? null
                    : () => _savePrices(products),
                icon: _isSaving
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: AppColors.textOnPrimary))
                    : const Icon(Icons.save_rounded, size: 18),
                label: Text(l10n?.distributorSaveChanges ?? 'حفظ التغييرات',
                    style:
                        TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.textOnPrimary,
                    padding:
                        const EdgeInsets.symmetric(vertical: AlhaiSpacing.sm),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AlhaiRadius.md))),
              ),
            ),
          ),
        ]),
      ),
    );
  }

  Future<void> _savePrices(List<DistributorProduct> products) async {
    final l10n = AppLocalizations.of(context);
    setState(() => _isSaving = true);

    final prices = <String, double>{};
    for (final product in products) {
      final controller = _controllers[product.id];
      final newPrice = double.tryParse(controller?.text ?? '');
      if (newPrice != null && newPrice != product.price) {
        prices[product.id] = newPrice;
      }
    }

    if (prices.isNotEmpty) {
      try {
        final ds = ref.read(distributorDatasourceProvider);
        await ds.updateProductPrices(prices);

        if (!mounted) return;

        for (final c in _controllers.values) {
          c.clear();
        }
        ref.invalidate(productsProvider);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  l10n?.distributorChangesSaved ?? 'تم حفظ التغييرات بنجاح'),
              backgroundColor: AppColors.success),
        );
      } catch (_) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  l10n?.distributorSaveError ?? 'حدث خطأ أثناء حفظ الأسعار'),
              backgroundColor: AppColors.error),
        );
      }
    }

    if (!mounted) return;
    setState(() {
      _isSaving = false;
      _hasChanges = false;
    });
  }
}
