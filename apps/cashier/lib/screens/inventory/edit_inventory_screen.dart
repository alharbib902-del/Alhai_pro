/// Edit Inventory Screen - Adjust stock for a specific product
///
/// Current stock display, adjustment amount (+/-), reason dropdown,
/// note field. Save creates inventory movement record.
/// Supports: RTL Arabic, dark/light theme, responsive layout.
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:get_it/get_it.dart';
import 'package:alhai_shared_ui/alhai_shared_ui.dart';
import 'package:alhai_auth/alhai_auth.dart';
import 'package:alhai_l10n/alhai_l10n.dart';
import 'package:alhai_database/alhai_database.dart';
import 'package:uuid/uuid.dart';
import 'package:alhai_design_system/alhai_design_system.dart'
    show AlhaiBreakpoints, AlhaiSnackbar, AlhaiSpacing;
// alhai_design_system is re-exported via alhai_shared_ui
import '../../core/services/sentry_service.dart';
import '../../core/services/audit_service.dart';

/// شاشة تعديل المخزون
class EditInventoryScreen extends ConsumerStatefulWidget {
  final String productId;

  const EditInventoryScreen({super.key, required this.productId});

  @override
  ConsumerState<EditInventoryScreen> createState() =>
      _EditInventoryScreenState();
}

class _EditInventoryScreenState extends ConsumerState<EditInventoryScreen> {
  final _db = GetIt.I<AppDatabase>();
  final _adjustmentController = TextEditingController();
  final _noteController = TextEditingController();

  ProductsTableData? _product;
  bool _isLoading = true;
  bool _isSaving = false;
  String? _error;
  bool _isAdding = true; // true = add, false = subtract
  String _reason = 'received';

  @override
  void initState() {
    super.initState();
    _loadProduct();
  }

  @override
  void dispose() {
    _adjustmentController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _loadProduct() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final product = await _db.productsDao.getProductById(widget.productId);
      if (mounted) {
        setState(() {
          _product = product;
          _isLoading = false;
        });
      }
    } catch (e, stack) {
      reportError(
        e,
        stackTrace: stack,
        hint: 'Load product for edit inventory',
      );
      if (mounted) {
        setState(() {
          _isLoading = false;
          _error = '$e';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isWideScreen = size.width >= AlhaiBreakpoints.desktop;
    final isMediumScreen = size.width >= AlhaiBreakpoints.tablet;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context);
    final user = ref.watch(currentUserProvider);

    return Column(
      children: [
        AppHeader(
          title: 'Edit Inventory',
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
              ? _buildNotFound(isDark, l10n)
              : SingleChildScrollView(
                  padding: EdgeInsets.all(
                    isMediumScreen ? AlhaiSpacing.lg : AlhaiSpacing.md,
                  ),
                  child: _buildContent(
                    isWideScreen,
                    isMediumScreen,
                    isDark,
                    l10n,
                  ),
                ),
        ),
      ],
    );
  }

  Widget _buildNotFound(bool isDark, AppLocalizations l10n) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off_rounded,
            size: 64,
            color: AppColors.getTextMuted(isDark).withValues(alpha: 0.4),
          ),
          const SizedBox(height: AlhaiSpacing.md),
          Text(
            l10n.productNotFound,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: AppColors.getTextMuted(isDark),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(
    bool isWideScreen,
    bool isMediumScreen,
    bool isDark,
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
                _buildCurrentStockCard(isDark, l10n),
                const SizedBox(height: AlhaiSpacing.lg),
                _buildAdjustmentCard(isDark, l10n),
              ],
            ),
          ),
          const SizedBox(width: AlhaiSpacing.lg),
          Expanded(
            flex: 2,
            child: Column(
              children: [
                _buildReasonCard(isDark, l10n),
                const SizedBox(height: AlhaiSpacing.lg),
                _buildNoteCard(isDark, l10n),
                const SizedBox(height: AlhaiSpacing.lg),
                _buildSaveButton(isDark, l10n),
              ],
            ),
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildCurrentStockCard(isDark, l10n),
        SizedBox(height: isMediumScreen ? AlhaiSpacing.lg : AlhaiSpacing.md),
        _buildAdjustmentCard(isDark, l10n),
        SizedBox(height: isMediumScreen ? AlhaiSpacing.lg : AlhaiSpacing.md),
        _buildReasonCard(isDark, l10n),
        SizedBox(height: isMediumScreen ? AlhaiSpacing.lg : AlhaiSpacing.md),
        _buildNoteCard(isDark, l10n),
        const SizedBox(height: AlhaiSpacing.lg),
        _buildSaveButton(isDark, l10n),
      ],
    );
  }

  Widget _buildCurrentStockCard(bool isDark, AppLocalizations l10n) {
    final product = _product!;
    final double stock = product.stockQty;
    final double adjustment =
        double.tryParse(_adjustmentController.text) ?? 0.0;
    final double newStock = _isAdding ? stock + adjustment : stock - adjustment;

    return Container(
      padding: const EdgeInsets.all(AlhaiSpacing.mdl),
      decoration: BoxDecoration(
        color: AppColors.getSurface(isDark),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.getBorder(isDark)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                alignment: Alignment.center,
                child: const Icon(
                  Icons.inventory_2_rounded,
                  color: AppColors.primary,
                  size: 24,
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
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.getTextPrimary(isDark),
                      ),
                    ),
                    if (product.barcode != null)
                      Text(
                        product.barcode!,
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.getTextMuted(isDark),
                          fontFamily: 'monospace',
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AlhaiSpacing.mdl),
          Row(
            children: [
              Expanded(
                child: _buildStockInfo(
                  l10n.currentStock,
                  stock.toStringAsFixed(2),
                  stock > 5 ? AppColors.success : AppColors.error,
                  isDark,
                ),
              ),
              Container(
                width: 1,
                height: 50,
                color: AppColors.getBorder(isDark),
              ),
              Expanded(
                child: _buildStockInfo(
                  l10n.adjustment,
                  '${_isAdding ? '+' : '-'}${adjustment.toStringAsFixed(2)}',
                  _isAdding ? AppColors.success : AppColors.error,
                  isDark,
                ),
              ),
              Container(
                width: 1,
                height: 50,
                color: AppColors.getBorder(isDark),
              ),
              Expanded(
                // P2: When the subtract would drive stock below zero,
                // wrap the preview in a Tooltip so hover/long-press
                // explains why the save button (and tx re-read guard)
                // will refuse. Visible text still colours error-red.
                child: Tooltip(
                  message: newStock < 0
                      ? 'المخزون غير كافٍ — الكمية المطلوبة أكبر من المتاح'
                      : '',
                  child: _buildStockInfo(
                    l10n.newStock,
                    newStock.toStringAsFixed(2),
                    newStock >= 0 ? AppColors.info : AppColors.error,
                    isDark,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStockInfo(String label, String value, Color color, bool isDark) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: AppColors.getTextSecondary(isDark),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          value,
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildAdjustmentCard(bool isDark, AppLocalizations l10n) {
    final activeColor = _isAdding ? AppColors.success : AppColors.error;

    return Container(
      padding: const EdgeInsets.all(AlhaiSpacing.mdl),
      decoration: BoxDecoration(
        color: AppColors.getSurface(isDark),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.getBorder(isDark)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AlhaiSpacing.xs),
                decoration: BoxDecoration(
                  color: activeColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(Icons.tune_rounded, color: activeColor, size: 20),
              ),
              const SizedBox(width: AlhaiSpacing.sm),
              Text(
                l10n.adjustQuantity,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.getTextPrimary(isDark),
                ),
              ),
            ],
          ),
          const SizedBox(height: AlhaiSpacing.mdl),
          // Add / Subtract toggle
          Row(
            children: [
              Expanded(
                child: InkWell(
                  onTap: () => setState(() => _isAdding = true),
                  borderRadius: BorderRadius.circular(12),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(
                      vertical: AlhaiSpacing.md,
                    ),
                    decoration: BoxDecoration(
                      color: _isAdding
                          ? AppColors.success.withValues(alpha: 0.1)
                          : AppColors.getSurfaceVariant(isDark),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: _isAdding
                            ? AppColors.success
                            : AppColors.getBorder(isDark),
                        width: _isAdding ? 2 : 1,
                      ),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          Icons.add_circle_rounded,
                          size: 28,
                          color: _isAdding
                              ? AppColors.success
                              : AppColors.getTextSecondary(isDark),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          l10n.add,
                          style: TextStyle(
                            fontWeight: _isAdding
                                ? FontWeight.w700
                                : FontWeight.w500,
                            color: _isAdding
                                ? AppColors.success
                                : AppColors.getTextSecondary(isDark),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: AlhaiSpacing.sm),
              Expanded(
                child: InkWell(
                  onTap: () => setState(() => _isAdding = false),
                  borderRadius: BorderRadius.circular(12),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(
                      vertical: AlhaiSpacing.md,
                    ),
                    decoration: BoxDecoration(
                      color: !_isAdding
                          ? AppColors.error.withValues(alpha: 0.1)
                          : AppColors.getSurfaceVariant(isDark),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: !_isAdding
                            ? AppColors.error
                            : AppColors.getBorder(isDark),
                        width: !_isAdding ? 2 : 1,
                      ),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          Icons.remove_circle_rounded,
                          size: 28,
                          color: !_isAdding
                              ? AppColors.error
                              : AppColors.getTextSecondary(isDark),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          l10n.subtract,
                          style: TextStyle(
                            fontWeight: !_isAdding
                                ? FontWeight.w700
                                : FontWeight.w500,
                            color: !_isAdding
                                ? AppColors.error
                                : AppColors.getTextSecondary(isDark),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AlhaiSpacing.mdl),
          TextField(
            controller: _adjustmentController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(
                RegExp(r'^\d+(\.\d{0,2})?$'),
              ),
            ],
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: AppColors.getTextPrimary(isDark),
            ),
            textAlign: TextAlign.center,
            onChanged: (_) => setState(() {}),
            decoration: InputDecoration(
              hintText: '0',
              hintStyle: TextStyle(
                color: AppColors.getTextMuted(isDark),
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
              prefixIcon: Padding(
                padding: const EdgeInsets.all(AlhaiSpacing.sm),
                child: Icon(
                  _isAdding ? Icons.add_rounded : Icons.remove_rounded,
                  size: 28,
                  color: activeColor,
                ),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: AppColors.getBorder(isDark)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: AppColors.getBorder(isDark)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: activeColor, width: 2),
              ),
              filled: true,
              fillColor: AppColors.getSurfaceVariant(isDark),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReasonCard(bool isDark, AppLocalizations l10n) {
    final reasons = [
      {
        'value': 'received',
        'label': 'Received',
        'icon': Icons.local_shipping_rounded,
      },
      {
        'value': 'damaged',
        'label': l10n.damaged,
        'icon': Icons.broken_image_rounded,
      },
      {
        'value': 'counted',
        'label': l10n.counted,
        'icon': Icons.checklist_rounded,
      },
      {'value': 'other', 'label': l10n.other, 'icon': Icons.more_horiz_rounded},
    ];

    return Container(
      padding: const EdgeInsets.all(AlhaiSpacing.mdl),
      decoration: BoxDecoration(
        color: AppColors.getSurface(isDark),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.getBorder(isDark)),
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
                  Icons.list_alt_rounded,
                  color: AppColors.warning,
                  size: 20,
                ),
              ),
              const SizedBox(width: AlhaiSpacing.sm),
              Text(
                l10n.reason,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.getTextPrimary(isDark),
                ),
              ),
            ],
          ),
          const SizedBox(height: AlhaiSpacing.md),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: reasons.map((r) {
              final isSelected = _reason == r['value'];
              return InkWell(
                onTap: () => setState(() => _reason = r['value'] as String),
                borderRadius: BorderRadius.circular(10),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.primary.withValues(alpha: 0.1)
                        : AppColors.getSurfaceVariant(isDark),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: isSelected
                          ? AppColors.primary
                          : AppColors.getBorder(isDark),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        r['icon'] as IconData,
                        size: 16,
                        color: isSelected
                            ? AppColors.primary
                            : AppColors.getTextSecondary(isDark),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        r['label'] as String,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: isSelected
                              ? FontWeight.w600
                              : FontWeight.w500,
                          color: isSelected
                              ? AppColors.primary
                              : AppColors.getTextSecondary(isDark),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildNoteCard(bool isDark, AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(AlhaiSpacing.mdl),
      decoration: BoxDecoration(
        color: AppColors.getSurface(isDark),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.getBorder(isDark)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.noteLabel,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.getTextPrimary(isDark),
            ),
          ),
          const SizedBox(height: AlhaiSpacing.sm),
          TextField(
            controller: _noteController,
            maxLines: 3,
            style: TextStyle(color: AppColors.getTextPrimary(isDark)),
            decoration: InputDecoration(
              hintText: l10n.optionalNoteHint,
              hintStyle: TextStyle(color: AppColors.getTextMuted(isDark)),
              filled: true,
              fillColor: AppColors.getSurfaceVariant(isDark),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: AppColors.getBorder(isDark)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: AppColors.getBorder(isDark)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: AppColors.primary,
                  width: 2,
                ),
              ),
              contentPadding: const EdgeInsets.all(AlhaiSpacing.md),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSaveButton(bool isDark, AppLocalizations l10n) {
    final hasAmount =
        _adjustmentController.text.isNotEmpty &&
        (double.tryParse(_adjustmentController.text) ?? 0) > 0;

    return SizedBox(
      width: double.infinity,
      child: FilledButton.icon(
        onPressed: _isSaving || !hasAmount ? null : _saveAdjustment,
        icon: _isSaving
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColors.textOnPrimary,
                ),
              )
            : const Icon(Icons.save_rounded, size: 20),
        label: Text(
          l10n.saveAdjustment,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.textOnPrimary,
          padding: const EdgeInsets.symmetric(vertical: AlhaiSpacing.md),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  Future<void> _saveAdjustment() async {
    final l10n = AppLocalizations.of(context);
    final double adjustment =
        double.tryParse(_adjustmentController.text) ?? 0.0;
    if (adjustment <= 0) return;

    setState(() => _isSaving = true);

    try {
      final storeId = ref.read(currentStoreIdProvider);
      if (storeId == null) return;
      final double currentStock = _product?.stockQty ?? 0.0;
      final double signedAdjustment =
          _isAdding ? adjustment : -adjustment;
      final double newStock = currentStock + signedAdjustment;

      // Defence-in-depth: refuse an adjustment that would leave stock
      // below zero. UI mirrors this check, but race-safe re-read also
      // enforces it in case another sync bumped stock down while the
      // form was open.
      if (newStock < 0) {
        if (mounted) {
          AlhaiSnackbar.error(
            context,
            'المخزون غير كافٍ: المتاح ${currentStock.toStringAsFixed(2)}، المطلوب سحبه ${adjustment.toStringAsFixed(2)}',
          );
        }
        setState(() => _isSaving = false);
        return;
      }

      final movementId = const Uuid().v4();
      // Wave 7 (P0-19/20): unify type to canonical 'adjust' (was
      // 'addition'/'subtraction'). The qty already carries the sign, so
      // a single bucket is enough — directional info is preserved by
      // qty's sign and reports use that. Wrap the read+write in a
      // transaction with TOCTOU re-read so a concurrent sync that
      // bumped stock between screen-open and submit doesn't leave a
      // wrong-previousQty row in the ledger.
      late double freshPrev;
      late double freshNew;
      await _db.transaction(() async {
        final fresh = await _db.productsDao.getProductById(widget.productId);
        if (fresh == null) {
          throw StateError('المنتج لم يعد موجوداً');
        }
        freshPrev = fresh.stockQty;
        freshNew = freshPrev + signedAdjustment;
        if (freshNew < 0) {
          throw StateError(
            'المخزون غير كافٍ: المتاح ${freshPrev.toStringAsFixed(2)}، '
            'المطلوب سحبه ${adjustment.toStringAsFixed(2)}',
          );
        }
        await _db.inventoryDao.insertMovement(
          InventoryMovementsTableCompanion.insert(
            id: movementId,
            storeId: storeId,
            productId: widget.productId,
            type: 'adjust',
            qty: signedAdjustment,
            previousQty: freshPrev,
            newQty: freshNew,
            reason: Value(_reason),
            notes: Value(
              _noteController.text.isNotEmpty ? _noteController.text : null,
            ),
            createdAt: DateTime.now(),
          ),
        );
        await _db.productsDao.updateStock(widget.productId, freshNew);
      });
      // Reflect the post-tx values in the rest of the closure (audit log,
      // success message). The pre-tx `currentStock` / `newStock` are
      // stale once the re-read happened.
      final actualPrev = freshPrev;
      final actualNew = freshNew;

      // Audit log
      final user = ref.read(currentUserProvider);
      auditService.logStockAdjust(
        storeId: storeId,
        userId: user?.id ?? 'unknown',
        userName: user?.name ?? 'unknown',
        productId: widget.productId,
        productName: _product?.name ?? widget.productId,
        oldQty: actualPrev,
        newQty: actualNew,
        reason: _reason,
      );

      if (!mounted) return;

      AlhaiSnackbar.success(
        context,
        AppLocalizations.of(context).inventoryUpdatedMsg,
      );

      context.pop();
    } catch (e, stack) {
      reportError(e, stackTrace: stack, hint: 'Save edit inventory adjustment');
      if (!mounted) return;
      AlhaiSnackbar.error(context, l10n.errorWithDetails('$e'));
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }
}
