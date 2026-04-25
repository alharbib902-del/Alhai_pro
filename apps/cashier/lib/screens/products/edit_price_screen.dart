/// Edit Price Screen - Update product pricing
///
/// Shows current product name/price, input for new price & cost price,
/// price history list, save button.
/// Supports: RTL Arabic, dark/light theme, responsive layout.
library;

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:get_it/get_it.dart';
import 'package:alhai_core/alhai_core.dart' show Money;
import 'package:alhai_shared_ui/alhai_shared_ui.dart';
import 'package:alhai_auth/alhai_auth.dart';
import 'package:alhai_l10n/alhai_l10n.dart';
import 'package:alhai_database/alhai_database.dart';
import 'package:alhai_design_system/alhai_design_system.dart'
    show AlhaiBreakpoints, AlhaiSnackbar, AlhaiSpacing;
// alhai_design_system is re-exported via alhai_shared_ui
import '../../core/services/sentry_service.dart';
import '../../core/services/audit_service.dart';

/// شاشة تعديل السعر
class EditPriceScreen extends ConsumerStatefulWidget {
  final String productId;

  const EditPriceScreen({super.key, required this.productId});

  @override
  ConsumerState<EditPriceScreen> createState() => _EditPriceScreenState();
}

class _EditPriceScreenState extends ConsumerState<EditPriceScreen> {
  final _db = GetIt.I<AppDatabase>();
  final _newPriceController = TextEditingController();
  final _costPriceController = TextEditingController();

  ProductsTableData? _product;
  bool _isLoading = true;
  bool _isSaving = false;
  String? _error;
  final List<Map<String, dynamic>> _priceHistory = [];
  // P1 #7 (2026-04-24): role-based gate. Only store owners / super admins can
  // save edits. The field is populated in initState — evaluating it there
  // avoids a rebuild race where the Save button appears briefly enabled
  // while the user provider is still settling.
  bool _canEditPrice = false;

  @override
  void initState() {
    super.initState();
    // P1 #7 (2026-04-24): check edit-price permission as early as possible
    // so the UI can render with the correct state on first frame.
    // Wave 9 (P0-02/28): route through Permissions instead of inline role
    // comparison. The named gate makes the intent obvious and means a
    // future role addition only updates Permissions.canEditSalePrice.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final user = ref.read(currentUserProvider);
      setState(() {
        _canEditPrice = Permissions.canEditSalePrice(user);
      });
    });
    _loadProduct();
  }

  @override
  void dispose() {
    _newPriceController.dispose();
    _costPriceController.dispose();
    super.dispose();
  }

  Future<void> _loadProduct() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      // Wave 10 (P0-29): tenant-isolated load. Refuses to surface a
      // product from a different store even if the route id resolves —
      // closes the deep-link / URL-tampering vector.
      final storeIdAtLoad = ref.read(currentStoreIdProvider);
      final product = storeIdAtLoad == null
          ? null
          : await _db.productsDao.getByIdForStore(
              widget.productId,
              storeIdAtLoad,
            );
      if (!mounted) {
        return;
      }
      if (product == null) {
        setState(() => _isLoading = false);
        return;
      }

      // P1 #9 (2026-04-24): `_priceHistory` was seeded with a synthetic entry
      // built from `product.updatedAt` which confusingly looked like a real
      // history row. Replaced with the actual `audit_log` rows scoped to this
      // product's priceChange events. Rows older than the current product
      // row (by created_at) are ignored so the list reads oldest→newest.
      final storeId = ref.read(currentStoreIdProvider);
      final history = <Map<String, dynamic>>[];
      if (storeId != null) {
        try {
          final logs = await _db.auditLogDao.getLogsByAction(
            storeId,
            AuditAction.priceChange,
          );
          for (final log in logs) {
            if (log.entityId != widget.productId) continue;
            final raw = log.newValue;
            if (raw == null || raw.isEmpty) continue;
            try {
              final decoded = jsonDecode(raw) as Map<String, dynamic>;
              final price = decoded['price'];
              if (price is num) {
                history.add({
                  'date': log.createdAt,
                  'price': price.toDouble(),
                  'changedBy': log.userName,
                });
              }
            } catch (_) {
              // malformed audit payload — skip silently (hash-chain rows may
              // embed metadata under `__meta__`; primitives remain under
              // `price` so we ignore entries that don't parse cleanly).
            }
          }
        } catch (e, stack) {
          reportError(
            e,
            stackTrace: stack,
            hint: 'Load price history from audit_log',
          );
          // Non-fatal — the card will render empty ("no price history") rather
          // than block editing if audit lookup fails.
        }
      }

      setState(() {
        _product = product;
        // C-4 Stage B: product.price/costPrice are int cents; UI needs SAR doubles.
        _newPriceController.text = (product.price / 100.0).toStringAsFixed(2);
        _costPriceController.text =
            ((product.costPrice ?? 0) / 100.0).toStringAsFixed(2);
        _isLoading = false;
        _priceHistory
          ..clear()
          ..addAll(history);
      });
    } catch (e, stack) {
      reportError(e, stackTrace: stack, hint: 'Load product for price edit');
      if (mounted) {
        setState(() {
          _error = '$e';
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isWideScreen = size.width >= AlhaiBreakpoints.desktop;
    final isMediumScreen = size.width >= AlhaiBreakpoints.tablet;
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context);
    final user = ref.watch(currentUserProvider);

    return Column(
      children: [
        AppHeader(
          title: l10n.editPrice(_product?.name ?? ''),
          subtitle: _product?.name ?? '',
          showSearch: false,
          searchHint: l10n.searchPlaceholder,
          onMenuTap: isWideScreen
              ? null
              : () => Scaffold.of(context).openDrawer(),
          onNotificationsTap: () => context.push('/notifications'),
          notificationsCount: 3,
          userName: user?.name ?? l10n.cashCustomer,
          userRole: l10n.branchManager,
          onUserTap: () {},
        ),
        Expanded(
          child: _isLoading
              ? const AppLoadingState()
              : _error != null
              ? AppErrorState.general(
                  context,
                  message: _error!,
                  onRetry: _loadProduct,
                )
              : _product == null
              ? _buildNotFound(colorScheme, l10n)
              : SingleChildScrollView(
                  padding: EdgeInsets.all(
                    isMediumScreen ? AlhaiSpacing.lg : AlhaiSpacing.md,
                  ),
                  child: _buildContent(
                    isWideScreen,
                    isMediumScreen,
                    colorScheme,
                    l10n,
                  ),
                ),
        ),
      ],
    );
  }

  Widget _buildNotFound(ColorScheme colorScheme, AppLocalizations l10n) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off_rounded,
            size: 64,
            color: colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
          ),
          const SizedBox(height: AlhaiSpacing.md),
          Text(
            l10n.productNotFound,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: AlhaiSpacing.lg),
          FilledButton.icon(
            onPressed: () => context.pop(),
            icon: const Icon(Icons.arrow_back_rounded),
            label: Text(l10n.goBack),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(
    bool isWideScreen,
    bool isMediumScreen,
    ColorScheme colorScheme,
    AppLocalizations l10n,
  ) {
    if (isWideScreen) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 3,
            child: Column(
              children: [
                _buildProductInfoCard(colorScheme, l10n),
                const SizedBox(height: AlhaiSpacing.lg),
                _buildNewPriceCard(colorScheme, l10n),
              ],
            ),
          ),
          const SizedBox(width: AlhaiSpacing.lg),
          Expanded(
            flex: 2,
            child: Column(
              children: [
                _buildPriceComparisonCard(colorScheme, l10n),
                const SizedBox(height: AlhaiSpacing.lg),
                _buildPriceHistoryCard(colorScheme, l10n),
                const SizedBox(height: AlhaiSpacing.lg),
                _buildSaveButton(colorScheme, l10n),
              ],
            ),
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildProductInfoCard(colorScheme, l10n),
        SizedBox(height: isMediumScreen ? AlhaiSpacing.lg : AlhaiSpacing.md),
        _buildNewPriceCard(colorScheme, l10n),
        SizedBox(height: isMediumScreen ? AlhaiSpacing.lg : AlhaiSpacing.md),
        _buildPriceComparisonCard(colorScheme, l10n),
        SizedBox(height: isMediumScreen ? AlhaiSpacing.lg : AlhaiSpacing.md),
        _buildPriceHistoryCard(colorScheme, l10n),
        const SizedBox(height: AlhaiSpacing.lg),
        _buildSaveButton(colorScheme, l10n),
      ],
    );
  }

  Widget _buildProductInfoCard(ColorScheme colorScheme, AppLocalizations l10n) {
    final product = _product!;
    return Container(
      padding: const EdgeInsets.all(AlhaiSpacing.mdl),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(14),
            ),
            alignment: Alignment.center,
            child: const Icon(
              Icons.inventory_2_rounded,
              color: AppColors.primary,
              size: 28,
            ),
          ),
          const SizedBox(width: AlhaiSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: AlhaiSpacing.xxs),
                Row(
                  children: [
                    if (product.barcode != null) ...[
                      Icon(
                        Icons.qr_code_rounded,
                        size: 14,
                        color: colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: AlhaiSpacing.xxs),
                      Text(
                        product.barcode!,
                        style: TextStyle(
                          fontSize: 13,
                          color: colorScheme.onSurfaceVariant,
                          fontFamily: 'monospace',
                        ),
                      ),
                      const SizedBox(width: AlhaiSpacing.sm),
                    ],
                    Icon(
                      Icons.inventory_outlined,
                      size: 14,
                      color: colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: AlhaiSpacing.xxs),
                    Text(
                      '${l10n.stock}: ${product.stockQty}',
                      style: TextStyle(
                        fontSize: 13,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // P1 #11 (2026-04-24): hard-coded English replaced with Arabic
              // copy. `currentPrice` is not a dedicated key in alhai_l10n yet
              // — using an inline Arabic label rather than introducing a new
              // key + full codegen round (11 locales) inside this patch.
              Text(
                'السعر الحالي',
                style: TextStyle(
                  fontSize: 11,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: AlhaiSpacing.xxs),
              Text(
                // C-4 (Session 41): formatMoney wraps the int cents as
                // Money.fromCents — replaces the `product.price / 100.0`
                // boilerplate with a type-safe boundary. `_product` is
                // a Drift `ProductsTableData` (not the domain Product),
                // so we construct Money inline rather than via the
                // .priceMoney getter from alhai_core's Product model.
                CurrencyFormatter.formatMoney(Money.fromCents(product.price)),
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNewPriceCard(ColorScheme colorScheme, AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(AlhaiSpacing.mdl),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AlhaiSpacing.xs),
                decoration: BoxDecoration(
                  color: AppColors.success.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.edit_rounded,
                  color: AppColors.success,
                  size: 20,
                ),
              ),
              const SizedBox(width: AlhaiSpacing.sm),
              Text(
                l10n.newPrice,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: AlhaiSpacing.mdl),
          // Selling price
          Text(
            l10n.sellingPrice,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: AlhaiSpacing.xs),
          TextField(
            controller: _newPriceController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            // P1 #12 (2026-04-24): constrain input to a valid decimal shape —
            // up to 2 fractional digits. Previously any character was accepted
            // which meant the validator in _savePrice had to defensively parse
            // and reject garbage silently.
            inputFormatters: [
              FilteringTextInputFormatter.allow(
                RegExp(r'^\d*(?:\.\d{0,2})?'),
              ),
            ],
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
            onChanged: (_) => setState(() {}),
            decoration: InputDecoration(
              hintText: '0.00',
              hintStyle: TextStyle(
                color: colorScheme.onSurfaceVariant,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
              suffixText: l10n.sar,
              suffixStyle: TextStyle(
                fontSize: 14,
                color: colorScheme.onSurfaceVariant,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: colorScheme.outlineVariant),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: colorScheme.outlineVariant),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: AppColors.primary,
                  width: 2,
                ),
              ),
              filled: true,
              fillColor: colorScheme.surfaceContainerLow,
            ),
          ),
          const SizedBox(height: AlhaiSpacing.mdl),
          // Cost price
          Text(
            l10n.costPrice,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: AlhaiSpacing.xs),
          TextField(
            controller: _costPriceController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(
                RegExp(r'^\d*(?:\.\d{0,2})?'),
              ),
            ],
            style: TextStyle(color: colorScheme.onSurface),
            onChanged: (_) => setState(() {}),
            decoration: InputDecoration(
              hintText: '0.00',
              hintStyle: TextStyle(color: colorScheme.onSurfaceVariant),
              suffixText: l10n.sar,
              suffixStyle: TextStyle(
                fontSize: 14,
                color: colorScheme.onSurfaceVariant,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: colorScheme.outlineVariant),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: colorScheme.outlineVariant),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: AppColors.primary,
                  width: 2,
                ),
              ),
              filled: true,
              fillColor: colorScheme.surfaceContainerLow,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: AlhaiSpacing.md,
                vertical: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceComparisonCard(
    ColorScheme colorScheme,
    AppLocalizations l10n,
  ) {
    // C-4 Stage B: _product.price is int cents; display/math in double SAR.
    final oldPrice = (_product?.price ?? 0) / 100.0;
    final newPrice = double.tryParse(_newPriceController.text) ?? 0;
    final costPrice = double.tryParse(_costPriceController.text) ?? 0;
    final priceDiff = newPrice - oldPrice;
    final margin = newPrice > 0 && costPrice > 0
        ? ((newPrice - costPrice) / newPrice * 100)
        : 0.0;

    return Container(
      padding: const EdgeInsets.all(AlhaiSpacing.mdl),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.outlineVariant),
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
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.compare_arrows_rounded,
                  color: AppColors.info,
                  size: 20,
                ),
              ),
              const SizedBox(width: AlhaiSpacing.sm),
              // P1 #11 (2026-04-24): inline Arabic copy — see `currentPrice`
              // comment above for rationale (no l10n key yet).
              Text(
                'مقارنة الأسعار',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: AlhaiSpacing.mdl),
          _buildComparisonRow(
            'السعر الحالي',
            CurrencyFormatter.format(oldPrice),
            colorScheme,
          ),
          _buildComparisonRow(
            l10n.newPrice,
            CurrencyFormatter.format(newPrice),
            colorScheme,
          ),
          _buildComparisonRow(
            l10n.difference,
            '${priceDiff >= 0 ? '+' : ''}${CurrencyFormatter.format(priceDiff.abs())}',
            colorScheme,
            valueColor: priceDiff >= 0 ? AppColors.success : AppColors.error,
          ),
          Divider(height: 24, color: colorScheme.outlineVariant),
          _buildComparisonRow(
            l10n.profitMargin,
            '${margin.toStringAsFixed(1)}%',
            colorScheme,
            valueColor: margin > 20 ? AppColors.success : AppColors.warning,
          ),
        ],
      ),
    );
  }

  Widget _buildComparisonRow(
    String label,
    String value,
    ColorScheme colorScheme, {
    Color? valueColor,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(fontSize: 13, color: colorScheme.onSurfaceVariant),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: valueColor ?? colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceHistoryCard(
    ColorScheme colorScheme,
    AppLocalizations l10n,
  ) {
    return Container(
      padding: const EdgeInsets.all(AlhaiSpacing.mdl),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.outlineVariant),
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
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.history_rounded,
                  color: AppColors.warning,
                  size: 20,
                ),
              ),
              const SizedBox(width: AlhaiSpacing.sm),
              Text(
                l10n.priceHistory,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: AlhaiSpacing.md),
          if (_priceHistory.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(AlhaiSpacing.md),
                child: Text(
                  l10n.noPriceHistory,
                  style: TextStyle(
                    fontSize: 13,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            )
          else
            ..._priceHistory.map((entry) {
              final date = entry['date'] as DateTime;
              final price = entry['price'] as double;
              return Container(
                margin: const EdgeInsetsDirectional.only(
                  bottom: AlhaiSpacing.xs,
                ),
                padding: const EdgeInsets.all(AlhaiSpacing.sm),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.schedule_rounded,
                      size: 16,
                      color: colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: AlhaiSpacing.xs),
                    Text(
                      '${date.day}/${date.month}/${date.year}',
                      style: TextStyle(
                        fontSize: 12,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      CurrencyFormatter.format(price),
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }

  Widget _buildSaveButton(ColorScheme colorScheme, AppLocalizations l10n) {
    // P1 #7 (2026-04-24): only store owners / super admins can edit price.
    // When permission is missing we render a disabled button with a tooltip
    // so the reason is obvious rather than the button just doing nothing.
    final enabled = _canEditPrice && !_isSaving;
    final button = FilledButton.icon(
      onPressed: enabled ? _savePrice : null,
      icon: _isSaving
          ? SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: colorScheme.onPrimary,
              ),
            )
          : const Icon(Icons.save_rounded, size: 20),
      label: Text(
        l10n.saveChanges,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      ),
      style: FilledButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: colorScheme.onPrimary,
        padding: const EdgeInsets.symmetric(vertical: AlhaiSpacing.md),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
    return SizedBox(
      width: double.infinity,
      child: _canEditPrice
          ? button
          : Tooltip(
              message: 'لا تملك صلاحية تعديل السعر',
              child: button,
            ),
    );
  }

  Future<void> _savePrice() async {
    final newPrice = double.tryParse(_newPriceController.text);
    final costPrice = double.tryParse(_costPriceController.text);
    final l10n = AppLocalizations.of(context);

    // P1 #7 (2026-04-24): defense-in-depth — even if the button somehow fires
    // for an un-privileged user (e.g. race with role resolver), refuse here.
    if (!_canEditPrice) {
      AlhaiSnackbar.warning(context, 'لا تملك صلاحية تعديل السعر');
      return;
    }

    if (newPrice == null || newPrice <= 0) {
      AlhaiSnackbar.warning(context, l10n.enterValidAmount);
      return;
    }

    // P1 #8 (2026-04-24): reject unreasonably large prices. 100M SAR is well
    // above any realistic retail price and also keeps the int-cents value
    // (newPrice * 100) within a safe 64-bit range with headroom for
    // downstream calculations (tax × multiple-line totals, etc.).
    const maxPriceSar = 100000000.0;
    if (newPrice > maxPriceSar) {
      AlhaiSnackbar.warning(context, 'السعر كبير جداً');
      return;
    }
    if (costPrice != null && costPrice > maxPriceSar) {
      AlhaiSnackbar.warning(context, 'سعر التكلفة كبير جداً');
      return;
    }

    setState(() => _isSaving = true);

    try {
      final currentProduct = _product!;
      final user = ref.read(currentUserProvider);
      final storeId = ref.read(currentStoreIdProvider);
      if (storeId == null) {
        if (mounted) setState(() => _isSaving = false);
        return;
      }
      // C-4 Stage B: convert user-typed SAR doubles → int cents for storage.
      final newPriceCents = (newPrice * 100).round();
      final oldPrice = currentProduct.price / 100.0;

      // Wave 10 (P0-30): the cost field is "absent" when the user
      // didn't touch it (we read what's in the controller, but the
      // controller is pre-filled at load time). To preserve cost when
      // the user only edits price, only pass costPrice through to the
      // companion when the value actually differs from what was loaded.
      // Empty input → clear cost (Value(null)); typed value differs →
      // write new value; otherwise → Value.absent() and the SQL UPDATE
      // skips the column entirely.
      final loadedCostCents = currentProduct.costPrice;
      final typedCostCents =
          costPrice == null ? null : (costPrice * 100).round();
      final Value<int?> costPriceArg = (typedCostCents == loadedCostCents)
          ? const Value.absent()
          : Value(typedCostCents);

      // Wave 10 (P0-29): tenant-isolation re-check. The UI loads the
      // product without a store filter (legacy `getProductById`). Even
      // with the role gate above, refusing the write when the loaded
      // product belongs to a different store stops a crafted-route
      // attack from a privileged-but-wrong-store user.
      if (currentProduct.storeId != storeId) {
        if (mounted) {
          AlhaiSnackbar.warning(context, 'لا تملك صلاحية تعديل السعر');
          setState(() => _isSaving = false);
        }
        return;
      }

      // P1 #10 (2026-04-24): run product update + audit log inside the same
      // Drift transaction so a mid-write crash can't leave the tables in a
      // torn state (price updated but no audit row, or vice versa).
      await _db.transaction(() async {
        await _db.productsDao.updatePriceAndCost(
          productId: currentProduct.id,
          priceCents: newPriceCents,
          costPriceCents: costPriceArg,
        );
        await _db.auditLogDao.logPriceChange(
          storeId: storeId,
          userId: user?.id ?? 'unknown',
          userName: user?.name ?? 'unknown',
          productId: currentProduct.id,
          productName: currentProduct.name,
          oldPrice: oldPrice,
          newPrice: newPrice,
        );
      });

      // The legacy auditService.logPriceChange publishes the event to Sentry
      // / sync queue / remote sink — kept outside the transaction because
      // it may fire network I/O that must not hold the SQLite write lock.
      auditService.logPriceChange(
        storeId: storeId,
        userId: user?.id ?? 'unknown',
        userName: user?.name ?? 'unknown',
        productId: currentProduct.id,
        productName: currentProduct.name,
        oldPrice: oldPrice,
        newPrice: newPrice,
      );

      if (!mounted) return;

      AlhaiSnackbar.success(
        context,
        AppLocalizations.of(context).priceUpdatedMsg,
      );

      context.pop();
    } catch (e, stack) {
      reportError(e, stackTrace: stack, hint: 'Save price update');
      if (!mounted) return;
      AlhaiSnackbar.error(context, l10n.errorWithDetails('$e'));
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }
}
