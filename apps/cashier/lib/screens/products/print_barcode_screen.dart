/// Print Barcode Screen - Barcode label printing
///
/// Search/scan product, show barcode preview, quantity input, print button.
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
import 'package:alhai_design_system/alhai_design_system.dart'
    show AlhaiBreakpoints, AlhaiSnackbar, AlhaiSpacing;
// alhai_design_system is re-exported via alhai_shared_ui
import '../../core/services/sentry_service.dart';

/// شاشة طباعة الباركود
class PrintBarcodeScreen extends ConsumerStatefulWidget {
  const PrintBarcodeScreen({super.key});

  @override
  ConsumerState<PrintBarcodeScreen> createState() => _PrintBarcodeScreenState();
}

class _PrintBarcodeScreenState extends ConsumerState<PrintBarcodeScreen> {
  final _db = GetIt.I<AppDatabase>();
  final _searchController = TextEditingController();
  final _quantityController = TextEditingController(text: '1');

  List<ProductsTableData> _searchResults = [];
  ProductsTableData? _selectedProduct;
  bool _isSearching = false;
  bool _isPrinting = false;

  @override
  void dispose() {
    _searchController.dispose();
    _quantityController.dispose();
    super.dispose();
  }

  Future<void> _searchProducts(String query) async {
    if (query.isEmpty) {
      setState(() => _searchResults = []);
      return;
    }
    setState(() => _isSearching = true);
    try {
      final storeId = ref.read(currentStoreIdProvider);
      if (storeId == null) return;
      final products = await _db.productsDao.searchProducts(query, storeId);
      if (mounted) {
        setState(() {
          _searchResults = products;
          _isSearching = false;
        });
      }
    } catch (e, stack) {
      reportError(
        e,
        stackTrace: stack,
        hint: 'Search products for barcode print',
      );
      if (mounted) {
        setState(() => _isSearching = false);
        AlhaiSnackbar.error(
          context,
          AppLocalizations.of(context).errorOccurred,
        );
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
          // P2 #16 (2026-04-24): hardcoded English replaced with Arabic.
          title: 'طباعة الباركود',
          subtitle: _getDateSubtitle(l10n),
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
          child: SingleChildScrollView(
            padding: EdgeInsets.all(
              isMediumScreen ? AlhaiSpacing.lg : AlhaiSpacing.md,
            ),
            child: _buildContent(isWideScreen, isMediumScreen, isDark, l10n),
          ),
        ),
      ],
    );
  }

  String _getDateSubtitle(AppLocalizations l10n) {
    final now = DateTime.now();
    return '${now.day}/${now.month}/${now.year} \u2022 ${l10n.mainBranch}';
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
                _buildSearchCard(isDark, l10n),
                const SizedBox(height: AlhaiSpacing.lg),
                if (_searchResults.isNotEmpty && _selectedProduct == null)
                  _buildSearchResults(isDark, l10n),
              ],
            ),
          ),
          const SizedBox(width: AlhaiSpacing.lg),
          Expanded(
            flex: 2,
            child: Column(
              children: [
                _buildBarcodePreview(isDark, l10n),
                const SizedBox(height: AlhaiSpacing.lg),
                _buildQuantityCard(isDark, l10n),
                const SizedBox(height: AlhaiSpacing.lg),
                _buildPrintButton(isDark, l10n),
              ],
            ),
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildSearchCard(isDark, l10n),
        SizedBox(height: isMediumScreen ? AlhaiSpacing.lg : AlhaiSpacing.md),
        if (_searchResults.isNotEmpty && _selectedProduct == null) ...[
          _buildSearchResults(isDark, l10n),
          SizedBox(height: isMediumScreen ? AlhaiSpacing.lg : AlhaiSpacing.md),
        ],
        _buildBarcodePreview(isDark, l10n),
        SizedBox(height: isMediumScreen ? AlhaiSpacing.lg : AlhaiSpacing.md),
        _buildQuantityCard(isDark, l10n),
        const SizedBox(height: AlhaiSpacing.lg),
        _buildPrintButton(isDark, l10n),
      ],
    );
  }

  Widget _buildSearchCard(bool isDark, AppLocalizations l10n) {
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
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.search_rounded,
                  color: AppColors.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: AlhaiSpacing.sm),
              Text(
                l10n.searchProduct,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.getTextPrimary(isDark),
                ),
              ),
            ],
          ),
          const SizedBox(height: AlhaiSpacing.mdl),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _searchController,
                  style: TextStyle(color: AppColors.getTextPrimary(isDark)),
                  onChanged: _searchProducts,
                  decoration: InputDecoration(
                    hintText: l10n.searchByNameOrBarcode,
                    hintStyle: TextStyle(color: AppColors.getTextMuted(isDark)),
                    prefixIcon: Icon(
                      Icons.search_rounded,
                      color: AppColors.getTextMuted(isDark),
                    ),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            onPressed: () {
                              _searchController.clear();
                              setState(() {
                                _searchResults = [];
                                _selectedProduct = null;
                              });
                            },
                            icon: Icon(
                              Icons.clear_rounded,
                              color: AppColors.getTextMuted(isDark),
                            ),
                            tooltip: l10n.clearField,
                          )
                        : null,
                    filled: true,
                    fillColor: AppColors.getSurfaceVariant(isDark),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: AppColors.getBorder(isDark),
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: AppColors.getBorder(isDark),
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: AppColors.primary,
                        width: 2,
                      ),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: AlhaiSpacing.md,
                      vertical: 14,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: AlhaiSpacing.sm),
              // P1 #17 (2026-04-24): the previous "مسح" button only surfaced
                  // a snackbar asking the user to type the barcode manually —
                  // effectively a no-op. Disabled the button and wrapped it in
                  // a Tooltip so the "coming soon" state is explicit rather
                  // than deceptive. Re-enable when the camera/scanner
                  // integration lands.
              Tooltip(
                message: '${l10n.comingSoon} — ${l10n.scan}',
                child: SizedBox(
                  height: 56,
                  child: FilledButton.icon(
                    onPressed: null,
                    icon: const Icon(Icons.qr_code_scanner_rounded, size: 20),
                    label: Text(l10n.scan),
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.info,
                      foregroundColor: AppColors.textOnPrimary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          if (_isSearching)
            const Padding(
              padding: EdgeInsetsDirectional.only(top: AlhaiSpacing.md),
              child: Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }

  Widget _buildSearchResults(bool isDark, AppLocalizations l10n) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.getSurface(isDark),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.getBorder(isDark)),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: _searchResults.take(5).map((product) {
          return InkWell(
            onTap: () {
              setState(() {
                _selectedProduct = product;
                _searchController.text = product.name;
                _searchResults = [];
              });
            },
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AlhaiSpacing.mdl,
                vertical: 14,
              ),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: AppColors.getBorder(isDark).withValues(alpha: 0.5),
                  ),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    alignment: Alignment.center,
                    child: const Icon(
                      Icons.inventory_2_outlined,
                      color: AppColors.primary,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          product.name,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
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
                  Text(
                    // C-4 Stage B: products.price is int cents.
                    '${(product.price / 100.0).toStringAsFixed(2)} ${l10n.sar}',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildBarcodePreview(bool isDark, AppLocalizations l10n) {
    final product = _selectedProduct;
    final barcode = product?.barcode ?? '';

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
                padding: const EdgeInsets.all(AlhaiSpacing.xs),
                decoration: BoxDecoration(
                  color: AppColors.info.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.qr_code_rounded,
                  color: AppColors.info,
                  size: 20,
                ),
              ),
              const SizedBox(width: AlhaiSpacing.sm),
              // P2 #16 (2026-04-24): hardcoded English replaced with Arabic.
              Text(
                'معاينة الباركود',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.getTextPrimary(isDark),
                ),
              ),
            ],
          ),
          const SizedBox(height: AlhaiSpacing.lg),
          if (product == null)
            Center(
              child: Column(
                children: [
                  Icon(
                    Icons.qr_code_2_rounded,
                    size: 64,
                    color: AppColors.getTextMuted(
                      isDark,
                    ).withValues(alpha: 0.3),
                  ),
                  const SizedBox(height: AlhaiSpacing.sm),
                  Text(
                    l10n.selectProductFirst,
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.getTextMuted(isDark),
                    ),
                  ),
                ],
              ),
            )
          else ...[
            // P1 #18 (2026-04-24): the barcode visualization below is a
            // decorative stripe pattern (`i % 4 == 0`), NOT a real EAN-13
            // encoding of the product's barcode. Stamp a caption so users
            // don't mistake the on-screen graphic for the eventual print
            // output. When PrinterService lands and the preview is rendered
            // from a real barcode generator (e.g. zebra_pdf or sunmi_barcode)
            // this caption can be removed.
            Text(
              'معاينة توضيحية فقط',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: AppColors.getTextMuted(isDark),
              ),
            ),
            const SizedBox(height: AlhaiSpacing.xs),
            // Barcode visualization - paper preview (stays white/black in both
            // themes to mimic printed output)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AlhaiSpacing.mdl),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.getBorder(isDark)),
              ),
              child: Column(
                children: [
                  // Simulated barcode lines
                  SizedBox(
                    height: 60,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(30, (i) {
                        final width = (i % 3 == 0) ? 2.0 : 1.0;
                        return Container(
                          width: width,
                          height: 60,
                          margin: const EdgeInsets.symmetric(horizontal: 1),
                          // Paper-preview bars: white = gap, black = bar
                          color: (i % 4 == 0) ? Colors.white : Colors.black,
                        );
                      }),
                    ),
                  ),
                  const SizedBox(height: AlhaiSpacing.xs),
                  Text(
                    barcode.isNotEmpty ? barcode : 'N/A',
                    style: TextStyle(
                      fontSize: 14,
                      fontFamily: 'monospace',
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.onSurface,
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(height: AlhaiSpacing.xxs),
                  Text(
                    product.name,
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withValues(alpha: 0.54),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AlhaiSpacing.xxxs),
                  Text(
                    // C-4 Stage B: products.price is int cents.
                    '${(product.price / 100.0).toStringAsFixed(2)} ${l10n.sar}',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AlhaiSpacing.sm),
            // Barcode format info
            Container(
              padding: const EdgeInsets.all(AlhaiSpacing.sm),
              decoration: BoxDecoration(
                color: AppColors.getSurfaceVariant(isDark),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline_rounded,
                    size: 16,
                    color: AppColors.getTextMuted(isDark),
                  ),
                  const SizedBox(width: AlhaiSpacing.xs),
                  // P2 #16 (2026-04-24): format label — "EAN-13" stays as
                  // the technical identifier, preceded by Arabic prefix.
                  Text(
                    'الصيغة: EAN-13',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.getTextSecondary(isDark),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildQuantityCard(bool isDark, AppLocalizations l10n) {
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
                  Icons.content_copy_rounded,
                  color: AppColors.warning,
                  size: 20,
                ),
              ),
              const SizedBox(width: AlhaiSpacing.sm),
              // P2 #16 (2026-04-24): hardcoded English replaced with Arabic.
              Text(
                'عدد الملصقات',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.getTextPrimary(isDark),
                ),
              ),
            ],
          ),
          const SizedBox(height: AlhaiSpacing.mdl),
          TextField(
            controller: _quantityController,
            keyboardType: TextInputType.number,
            // P1 #16 (2026-04-24): only digits allowed; matches the 1-500
            // clamp enforced at print time.
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
            ],
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: AppColors.getTextPrimary(isDark),
            ),
            textAlign: TextAlign.center,
            onChanged: (_) => setState(() {}),
            decoration: InputDecoration(
              hintText: '1',
              hintStyle: TextStyle(
                color: AppColors.getTextMuted(isDark),
                fontSize: 22,
                fontWeight: FontWeight.bold,
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
                borderSide: const BorderSide(
                  color: AppColors.primary,
                  width: 2,
                ),
              ),
              filled: true,
              fillColor: AppColors.getSurfaceVariant(isDark),
            ),
          ),
          const SizedBox(height: AlhaiSpacing.md),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [1, 5, 10, 20, 50].map((qty) {
              final isSelected = _quantityController.text == qty.toString();
              return Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    _quantityController.text = qty.toString();
                    setState(() {});
                  },
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AlhaiSpacing.md,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.primary.withValues(alpha: 0.1)
                          : AppColors.getSurfaceVariant(isDark),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: isSelected
                            ? AppColors.primary.withValues(alpha: 0.5)
                            : AppColors.getBorder(isDark),
                      ),
                    ),
                    child: Text(
                      '$qty',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: isSelected
                            ? AppColors.primary
                            : AppColors.getTextSecondary(isDark),
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildPrintButton(bool isDark, AppLocalizations l10n) {
    return SizedBox(
      width: double.infinity,
      child: FilledButton.icon(
        onPressed: _isPrinting || _selectedProduct == null
            ? null
            : _printBarcode,
        icon: _isPrinting
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColors.textOnPrimary,
                ),
              )
            : const Icon(Icons.print_rounded, size: 20),
        label: Text(
          l10n.printLabels,
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

  Future<void> _printBarcode() async {
    final l10n = AppLocalizations.of(context);
    final qty = int.tryParse(_quantityController.text) ?? 1;

    // P1 #16 (2026-04-24): hardening for the stub implementation.
    //  - Reject 0/negative qty (the FAB was otherwise bypassable via keyboard).
    //  - Cap at 500 to keep UI responsive when the real printer lands — any
    //    larger job should go through a background queue, not this screen.
    if (qty <= 0) {
      AlhaiSnackbar.warning(context, 'الكمية يجب أن تكون أكبر من صفر');
      return;
    }
    if (qty > 500) {
      AlhaiSnackbar.warning(context, 'الحد الأقصى 500 ملصق في عملية واحدة');
      return;
    }

    setState(() => _isPrinting = true);

    try {
      // P1 #16 (2026-04-24): no real PrinterService integration yet. Surface
      // an explicit "coming soon" message so the user isn't misled by a
      // success snackbar that used to fire after a fake `Future.delayed(1s)`.
      await Future<void>.delayed(const Duration(milliseconds: 200));

      if (!mounted) return;

      AlhaiSnackbar.info(context, '${l10n.comingSoon} — طباعة الباركود');
    } catch (e, stack) {
      reportError(e, stackTrace: stack, hint: 'Print barcode labels');
      if (!mounted) return;
      AlhaiSnackbar.error(context, l10n.errorWithDetails('$e'));
    } finally {
      if (mounted) setState(() => _isPrinting = false);
    }
  }
}
