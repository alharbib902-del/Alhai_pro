/// شاشة إلغاء عملية بيع - Void Transaction Screen
///
/// تعرض نموذج إلغاء فاتورة مع:
/// - بحث عن فاتورة بالرقم أو الباركود
/// - عرض تفاصيل الفاتورة والأصناف
/// - اختيار سبب الإلغاء
/// - موافقة المدير (PIN)
/// - تأكيد الإلغاء
/// متوافقة مع جميع الشاشات (desktop + tablet + mobile)
/// تدعم الوضع الفاتح والداكن
library;

import 'package:flutter/material.dart';
import 'package:alhai_auth/alhai_auth.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:alhai_design_system/alhai_design_system.dart';
import 'package:alhai_database/alhai_database.dart';
import 'package:get_it/get_it.dart';
import 'package:alhai_l10n/alhai_l10n.dart';

import '../../services/manager_approval_service.dart';

// ============================================================================
// VIEW DATA MODELS - نماذج عرض بيانات الفاتورة
// ============================================================================

class _InvoiceItem {
  final String name;
  final String sku;
  final IconData icon;
  final int qty;
  final double price;
  double get total => qty * price;

  const _InvoiceItem({
    required this.name,
    required this.sku,
    required this.icon,
    required this.qty,
    required this.price,
  });
}

class _InvoiceData {
  final String id;
  final String customer;
  final String customerInitial;
  final DateTime date;
  final double total;
  final String paymentMethod;
  final List<_InvoiceItem> items;

  const _InvoiceData({
    required this.id,
    required this.customer,
    required this.customerInitial,
    required this.date,
    required this.total,
    required this.paymentMethod,
    required this.items,
  });
}

// ============================================================================
// VOID TRANSACTION SCREEN
// ============================================================================

class VoidTransactionScreen extends ConsumerStatefulWidget {
  const VoidTransactionScreen({super.key});

  @override
  ConsumerState<VoidTransactionScreen> createState() => _VoidTransactionScreenState();
}

class _VoidTransactionScreenState extends ConsumerState<VoidTransactionScreen> {

  // Search state
  final _invoiceController = TextEditingController();
  bool _isSearching = false;
  _InvoiceData? _invoiceData;
  bool _showNotFound = false;

  // Form state
  String? _selectedReason;
  final _notesController = TextEditingController();
  final _pinController = TextEditingController();
  bool _confirmed = false;

  final List<String> _reasonKeys = [
    'customer_request',
    'wrong_items',
    'duplicate',
    'system_error',
    'other',
  ];

  @override
  void dispose() {
    _invoiceController.dispose();
    _notesController.dispose();
    _pinController.dispose();
    super.dispose();
  }

  // ============================================================================
  // ACTIONS
  // ============================================================================

  Future<void> _searchInvoice() async {
    final searchText = _invoiceController.text.trim();
    if (searchText.isEmpty) return;

    setState(() {
      _isSearching = true;
      _showNotFound = false;
      _invoiceData = null;
    });

    try {
      final db = GetIt.I<AppDatabase>();
      final storeId = ref.read(currentStoreIdProvider);

      // البحث عن الفاتورة بالمعرف أو رقم الإيصال
      SalesTableData? sale;

      // محاولة البحث بالمعرف أولاً
      sale = await db.salesDao.getSaleById(searchText);

      // إذا لم يُعثر عليها، نبحث برقم الإيصال
      if (sale == null && storeId != null) {
        sale = await db.salesDao.getSaleByReceiptNo(searchText, storeId);
      }

      if (sale == null || sale.status == 'voided') {
        // الفاتورة غير موجودة أو ملغاة مسبقاً
        setState(() {
          _isSearching = false;
          _showNotFound = true;
        });
        return;
      }

      // تحميل عناصر الفاتورة
      final saleItems = await db.saleItemsDao.getItemsBySaleId(sale.id);

      // تحويل البيانات إلى نماذج العرض
      final items = saleItems.map((item) => _InvoiceItem(
        name: item.productName,
        sku: item.productSku ?? item.productBarcode ?? '',
        icon: Icons.shopping_bag_outlined,
        qty: item.qty.toInt(),
        price: item.unitPrice,
      )).toList();

      final invoiceData = _InvoiceData(
        id: sale.receiptNo,
        customer: sale.customerName ?? '',
        customerInitial: (sale.customerName ?? '').isNotEmpty
            ? sale.customerName![0]
            : '؟',
        date: sale.createdAt,
        total: sale.total,
        paymentMethod: sale.paymentMethod,
        items: items,
      );

      setState(() {
        _isSearching = false;
        _invoiceData = invoiceData;
        _selectedReason = null;
        _notesController.clear();
        _pinController.clear();
        _confirmed = false;
      });
    } catch (e) {
      // خطأ في البحث
      setState(() {
        _isSearching = false;
        _showNotFound = true;
      });
    }
  }

  void _resetForm() {
    setState(() {
      _invoiceController.clear();
      _invoiceData = null;
      _showNotFound = false;
      _selectedReason = null;
      _notesController.clear();
      _pinController.clear();
      _confirmed = false;
    });
  }

  bool get _isFormValid {
    return _selectedReason != null && _confirmed;
  }

  Future<void> _confirmVoid() async {
    if (!_isFormValid || _invoiceData == null) return;
    final l10n = AppLocalizations.of(context)!;

    // طلب موافقة المشرف عبر PIN قبل تنفيذ الإلغاء
    final approved = await ManagerApprovalService.requestPinApproval(
      context: context,
      action: 'void_sale',
    );

    if (!approved || !mounted) return;

    try {
      final db = GetIt.I<AppDatabase>();
      final searchText = _invoiceController.text.trim();
      final storeId = ref.read(currentStoreIdProvider);

      // البحث عن الفاتورة لتحديد المعرف الحقيقي
      SalesTableData? sale;
      sale = await db.salesDao.getSaleById(searchText);
      if (sale == null && storeId != null) {
        sale = await db.salesDao.getSaleByReceiptNo(searchText, storeId);
      }

      if (sale == null) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.invoiceNotFound),
            backgroundColor: AppColors.error,
          ),
        );
        return;
      }

      // إلغاء الفاتورة في قاعدة البيانات
      await db.salesDao.voidSale(sale.id);

      // إضافة للطابور المزامنة
      final syncId = const Uuid().v4();
      await db.syncQueueDao.enqueue(
        id: syncId,
        tableName: 'sales',
        recordId: sale.id,
        operation: 'UPDATE',
        payload: '{"id":"${sale.id}","status":"voided","reason":"${_selectedReason ?? ''}","notes":"${_notesController.text}"}',
        idempotencyKey: 'void_sale_${sale.id}',
      );

      if (!mounted) return;

      // عرض رسالة النجاح
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.white, size: 20),
              const SizedBox(width: 8),
              Text(l10n.voidSuccess, style: const TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          duration: const Duration(seconds: 3),
        ),
      );
      _resetForm();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error_outline, color: Colors.white, size: 20),
              const SizedBox(width: 8),
              Expanded(child: Text('$e')),
            ],
          ),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }

  void _copyToClipboard(String text) {
    Clipboard.setData(ClipboardData(text: text));
    final l10n = AppLocalizations.of(context)!;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white, size: 18),
            const SizedBox(width: 8),
            Text(l10n.copiedSuccess),
          ],
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  String _getReasonText(String key, AppLocalizations l10n) {
    switch (key) {
      case 'customer_request':
        return l10n.customerRequestReason;
      case 'wrong_items':
        return l10n.wrongItemsReason;
      case 'duplicate':
        return l10n.duplicateInvoiceReason;
      case 'system_error':
        return l10n.systemErrorReason;
      case 'other':
        return l10n.otherReasonVoid;
      default:
        return key;
    }
  }

  // ============================================================================
  // BUILD
  // ============================================================================

  @override
  Widget build(BuildContext context) {
    final isWideScreen = context.isDesktop;
    final isMediumScreen = !context.isMobile;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;

    return Column(
              children: [
                _buildHeader(context, isWideScreen, isDark, l10n),
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.all(isMediumScreen ? 32 : 16),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 1400),
                      child: Column(
                        children: [
                          // Warning Banner
                          _buildWarningBanner(isDark, l10n, isMediumScreen),
                          SizedBox(height: isMediumScreen ? 32 : 16),

                          if (_invoiceData == null && !_showNotFound) ...[
                            // Search Section
                            _buildSearchSection(isDark, l10n, isMediumScreen),
                          ] else if (_showNotFound) ...[
                            // Not Found
                            _buildNotFoundSection(isDark, l10n),
                          ] else ...[
                            // Invoice Details + Void Form
                            if (isWideScreen)
                              _buildDesktopLayout(isDark, l10n)
                            else
                              _buildMobileLayout(isDark, l10n, isMediumScreen),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            );
  }

  // ============================================================================
  // HEADER
  // ============================================================================

  Widget _buildHeader(BuildContext context, bool isWideScreen, bool isDark, AppLocalizations l10n) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border(bottom: BorderSide(color: isDark ? colorScheme.outlineVariant.withValues(alpha: 0.2) : AppColors.border)),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: isWideScreen
                ? null
                : () => Scaffold.of(context).openDrawer(),
            icon: Icon(Icons.menu_rounded, color: colorScheme.onSurfaceVariant),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              l10n.voidSaleTransaction,
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: colorScheme.onSurface),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
          const SizedBox(width: 8),
          // Search in header (desktop)
          if (isWideScreen)
            SizedBox(
              width: 280,
              child: TextField(
                decoration: InputDecoration(
                  hintText: l10n.quickSearch,
                  hintStyle: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: 14),
                  prefixIcon: Icon(Icons.search, color: colorScheme.onSurfaceVariant),
                  filled: true,
                  fillColor: isDark ? const Color(0xFF0F172A) : AppColors.backgroundSecondary,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                ),
                style: TextStyle(color: colorScheme.onSurface, fontSize: 14),
              ),
            ),
          const SizedBox(width: 8),
          IconButton(
            onPressed: () {},
            icon: Badge(
              smallSize: 8,
              backgroundColor: AppColors.secondary,
              child: Icon(Icons.notifications_outlined, color: colorScheme.onSurfaceVariant),
            ),
          ),
          IconButton(
            onPressed: () {},
            icon: Icon(
              isDark ? Icons.light_mode : Icons.dark_mode,
              color: isDark ? const Color(0xFFFBBF24) : AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================================
  // WARNING BANNER
  // ============================================================================

  Widget _buildWarningBanner(bool isDark, AppLocalizations l10n, bool isMediumScreen) {
    return Container(
      padding: EdgeInsets.all(isMediumScreen ? 24 : 16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF7F1D1D).withValues(alpha: 0.2) : const Color(0xFFFEF2F2),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? const Color(0xFF991B1B).withValues(alpha: 0.4) : const Color(0xFFFECACA)),
      ),
      child: Row(
        crossAxisAlignment: isMediumScreen ? CrossAxisAlignment.center : CrossAxisAlignment.start,
        children: [
          Container(
            width: isMediumScreen ? 56 : 40,
            height: isMediumScreen ? 56 : 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isDark ? const Color(0xFF7F1D1D).withValues(alpha: 0.5) : const Color(0xFFFEE2E2),
            ),
            child: Icon(
              Icons.warning_amber_rounded,
              size: isMediumScreen ? 28 : 20,
              color: isDark ? const Color(0xFFF87171) : const Color(0xFFDC2626),
            ),
          ),
          SizedBox(width: isMediumScreen ? 16 : 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isMediumScreen ? l10n.voidWarningTitle : l10n.warning,
                  style: TextStyle(
                    fontSize: isMediumScreen ? 16 : 14,
                    fontWeight: FontWeight.bold,
                    color: isDark ? const Color(0xFFFCA5A5) : const Color(0xFF991B1B),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  isMediumScreen ? l10n.voidWarningDesc : l10n.voidWarningShort,
                  style: TextStyle(
                    fontSize: isMediumScreen ? 14 : 12,
                    color: isDark ? const Color(0xFFFCA5A5).withValues(alpha: 0.8) : const Color(0xFFB91C1C),
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================================
  // SEARCH SECTION
  // ============================================================================

  Widget _buildSearchSection(bool isDark, AppLocalizations l10n, bool isMediumScreen) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: EdgeInsets.all(isMediumScreen ? 32 : 20),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isDark ? colorScheme.outlineVariant.withValues(alpha: 0.15) : AppColors.border),
      ),
      child: Column(
        children: [
          if (isMediumScreen) ...[
            // Desktop: centered with title
            Text(
              l10n.enterInvoiceToVoid,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.searchByInvoiceOrBarcode,
              style: TextStyle(
                fontSize: 14,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 24),
            // Search row
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 700),
              child: Row(
                children: [
                  Expanded(child: _buildSearchInput(isDark, l10n)),
                  const SizedBox(width: 12),
                  _buildSearchButton(isDark, l10n, large: true),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Barcode link
            TextButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.qr_code_scanner, size: 16, color: AppColors.primary),
              label: Text(
                l10n.activateBarcode,
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.primary),
              ),
            ),
          ] else ...[
            // Mobile: compact
            Text(
              l10n.enterInvoiceToVoid,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 12),
            _buildSearchInput(isDark, l10n),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: _buildSearchButton(isDark, l10n, large: false)),
              ],
            ),
            const SizedBox(height: 12),
            // Barcode button
            OutlinedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.qr_code_scanner, size: 18),
              label: Text(l10n.scanBarcodeMobile),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                minimumSize: const Size(double.infinity, 0),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                side: BorderSide(color: isDark ? colorScheme.outlineVariant.withValues(alpha: 0.25) : AppColors.border),
                foregroundColor: colorScheme.onSurfaceVariant,
              ),
            ),
          ],

          // Empty state
          if (_invoiceData == null && !_showNotFound) ...[
            SizedBox(height: isMediumScreen ? 40 : 24),
            Container(
              width: isMediumScreen ? 120 : 80,
              height: isMediumScreen ? 120 : 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
              ),
              child: Icon(
                Icons.search_rounded,
                size: isMediumScreen ? 48 : 32,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              l10n.searchForInvoiceToVoid,
              style: TextStyle(
                fontSize: isMediumScreen ? 18 : 15,
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.enterNumberOrScan,
              style: TextStyle(
                fontSize: 13,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSearchInput(bool isDark, AppLocalizations l10n) {
    final colorScheme = Theme.of(context).colorScheme;
    return TextField(
      controller: _invoiceController,
      textDirection: TextDirection.ltr,
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        fontFamily: 'Courier',
        color: colorScheme.onSurface,
      ),
      decoration: InputDecoration(
        hintText: l10n.invoiceExampleVoid,
        hintStyle: TextStyle(
          color: colorScheme.onSurfaceVariant,
          fontWeight: FontWeight.normal,
          fontSize: 16,
        ),
        prefixIcon: Icon(Icons.receipt_long, color: colorScheme.onSurfaceVariant),
        suffixIcon: _invoiceController.text.isNotEmpty
            ? IconButton(
                onPressed: () => setState(() => _invoiceController.clear()),
                icon: Icon(Icons.clear, color: colorScheme.onSurfaceVariant),
              )
            : null,
        filled: true,
        fillColor: isDark ? const Color(0xFF0F172A) : AppColors.grey50,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: isDark ? colorScheme.outlineVariant.withValues(alpha: 0.25) : AppColors.border, width: 2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: isDark ? colorScheme.outlineVariant.withValues(alpha: 0.25) : AppColors.border, width: 2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
      ),
      onSubmitted: (_) => _searchInvoice(),
      onChanged: (_) => setState(() {}),
    );
  }

  Widget _buildSearchButton(bool isDark, AppLocalizations l10n, {required bool large}) {
    final colorScheme = Theme.of(context).colorScheme;
    return FilledButton.icon(
      onPressed: _isSearching ? null : _searchInvoice,
      icon: _isSearching
          ? SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: colorScheme.onPrimary))
          : const Icon(Icons.search, size: 20),
      label: Text(l10n.search, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      style: FilledButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: colorScheme.onPrimary,
        padding: EdgeInsets.symmetric(horizontal: large ? 32 : 24, vertical: large ? 20 : 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        elevation: 2,
      ),
    );
  }

  // ============================================================================
  // NOT FOUND
  // ============================================================================

  Widget _buildNotFoundSection(bool isDark, AppLocalizations l10n) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(48),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isDark ? colorScheme.outlineVariant.withValues(alpha: 0.15) : AppColors.border),
      ),
      child: Column(
        children: [
          Container(
            width: 96,
            height: 96,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
            ),
            child: Icon(Icons.cancel_outlined, size: 40, color: colorScheme.onSurfaceVariant),
          ),
          const SizedBox(height: 16),
          Text(
            l10n.invoiceNotFound,
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: colorScheme.onSurface),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.invoiceNotFoundDesc,
            style: TextStyle(fontSize: 14, color: colorScheme.onSurfaceVariant),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: _resetForm,
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: colorScheme.onPrimary,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
            child: Text(l10n.trySearchAgain, style: const TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  // ============================================================================
  // DESKTOP LAYOUT (3-column grid)
  // ============================================================================

  Widget _buildDesktopLayout(bool isDark, AppLocalizations l10n) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Left: Invoice summary + Items
        Expanded(
          flex: 2,
          child: Column(
            children: [
              _buildInvoiceSummaryCard(isDark, l10n, isMobile: false),
              const SizedBox(height: 24),
              _buildItemsList(isDark, l10n),
            ],
          ),
        ),
        const SizedBox(width: 24),
        // Right: Reason + PIN + Confirm + Buttons
        Expanded(
          flex: 1,
          child: Column(
            children: [
              _buildReasonCard(isDark, l10n),
              const SizedBox(height: 24),
              _buildManagerPinCard(isDark, l10n),
              const SizedBox(height: 24),
              _buildConfirmCheckbox(isDark, l10n),
              const SizedBox(height: 24),
              _buildDesktopButtons(isDark, l10n),
            ],
          ),
        ),
      ],
    );
  }

  // ============================================================================
  // MOBILE LAYOUT
  // ============================================================================

  Widget _buildMobileLayout(bool isDark, AppLocalizations l10n, bool isMediumScreen) {
    return Column(
      children: [
        _buildInvoiceSummaryCard(isDark, l10n, isMobile: true),
        const SizedBox(height: 16),
        _buildImpactAlert(isDark, l10n),
        const SizedBox(height: 16),
        _buildReasonCard(isDark, l10n),
        const SizedBox(height: 16),
        _buildManagerPinCard(isDark, l10n),
        const SizedBox(height: 16),
        _buildConfirmCheckbox(isDark, l10n),
        const SizedBox(height: 80), // Space for bottom bar
      ],
    );
  }

  // ============================================================================
  // INVOICE SUMMARY CARD
  // ============================================================================

  Widget _buildInvoiceSummaryCard(bool isDark, AppLocalizations l10n, {required bool isMobile}) {
    final colorScheme = Theme.of(context).colorScheme;
    final inv = _invoiceData!;
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isDark ? colorScheme.outlineVariant.withValues(alpha: 0.15) : AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Invoice type + ID + Total
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        l10n.salesInvoice,
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: colorScheme.onSurfaceVariant),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            inv.id,
                            style: TextStyle(
                              fontSize: isMobile ? 18 : 22,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Courier',
                              color: colorScheme.onSurface,
                            ),
                            textDirection: TextDirection.ltr,
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ),
                        const SizedBox(width: 8),
                        GestureDetector(
                          onTap: () => _copyToClipboard(inv.id),
                          child: Icon(Icons.copy_rounded, size: 16, color: colorScheme.onSurfaceVariant),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      l10n.paidCash,
                      style: TextStyle(fontSize: 13, color: colorScheme.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
              // Total amount
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    l10n.grandTotal,
                    style: TextStyle(fontSize: 12, color: colorScheme.onSurfaceVariant),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        inv.total.toStringAsFixed(2),
                        style: TextStyle(
                          fontSize: isMobile ? 24 : 28,
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        l10n.sar,
                        style: TextStyle(fontSize: 14, color: colorScheme.onSurfaceVariant),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.success.withValues(alpha: 0.15) : const Color(0xFFDCFCE7),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      l10n.invoiceCompleted,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: isDark ? const Color(0xFF4ADE80) : const Color(0xFF15803D),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 20),
          Divider(color: isDark ? colorScheme.outlineVariant.withValues(alpha: 0.15) : AppColors.divider),
          const SizedBox(height: 16),

          // Customer & Date
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.customerLabel,
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: colorScheme.onSurfaceVariant, letterSpacing: 0.5),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Container(
                          width: 30,
                          height: 30,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.primary.withValues(alpha: 0.15),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            inv.customerInitial,
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.primary),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            inv.customer,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: colorScheme.onSurface,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      l10n.dateAndTimeLabel,
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: colorScheme.onSurfaceVariant, letterSpacing: 0.5),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '${inv.date.year}/${inv.date.month.toString().padLeft(2, '0')}/${inv.date.day.toString().padLeft(2, '0')} - ${inv.date.hour}:${inv.date.minute.toString().padLeft(2, '0')}',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Courier',
                        color: colorScheme.onSurface,
                      ),
                      textDirection: TextDirection.ltr,
                    ),
                  ],
                ),
              ),
            ],
          ),

          // Impact alert (desktop only - inline)
          if (!isMobile) ...[
            const SizedBox(height: 20),
            _buildImpactAlert(isDark, l10n),
          ],
        ],
      ),
    );
  }

  // ============================================================================
  // IMPACT ALERT
  // ============================================================================

  Widget _buildImpactAlert(bool isDark, AppLocalizations l10n) {
    final inv = _invoiceData!;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF78350F).withValues(alpha: 0.2) : const Color(0xFFFFFBEB),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: isDark ? const Color(0xFFB45309).withValues(alpha: 0.3) : const Color(0xFFFDE68A)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline, size: 18, color: isDark ? const Color(0xFFFBBF24) : const Color(0xFFD97706)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.voidImpactSummary,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: isDark ? const Color(0xFFFDE68A) : const Color(0xFF92400E),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.check, size: 14, color: isDark ? const Color(0xFFFBBF24) : const Color(0xFFD97706)),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        l10n.voidImpactItemsReturn(inv.items.length),
                        style: TextStyle(fontSize: 12, color: isDark ? const Color(0xFFFDE68A).withValues(alpha: 0.9) : const Color(0xFF92400E)),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.replay, size: 14, color: isDark ? const Color(0xFFFBBF24) : const Color(0xFFD97706)),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        l10n.voidImpactRefund(inv.total.toStringAsFixed(2), l10n.sar),
                        style: TextStyle(fontSize: 12, color: isDark ? const Color(0xFFFDE68A).withValues(alpha: 0.9) : const Color(0xFF92400E)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================================
  // ITEMS LIST
  // ============================================================================

  Widget _buildItemsList(bool isDark, AppLocalizations l10n) {
    final colorScheme = Theme.of(context).colorScheme;
    final inv = _invoiceData!;
    final visibleItems = inv.items.take(2).toList();
    final remainingCount = inv.items.length - 2;
    final remainingTotal = inv.items.skip(2).fold(0.0, (sum, item) => sum + item.total);

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isDark ? colorScheme.outlineVariant.withValues(alpha: 0.15) : AppColors.border),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF0F172A).withValues(alpha: 0.3) : AppColors.grey50,
              border: Border(bottom: BorderSide(color: isDark ? colorScheme.outlineVariant.withValues(alpha: 0.15) : AppColors.divider)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  l10n.returnedItems(inv.items.length),
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: colorScheme.onSurface),
                ),
                TextButton(
                  onPressed: () {},
                  child: Text(l10n.viewAllItems, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.primary)),
                ),
              ],
            ),
          ),
          // Items
          ...visibleItems.map((item) => _buildItemRow(item, isDark, l10n)),
          // More items hint
          if (remainingCount > 0)
            Container(
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF0F172A).withValues(alpha: 0.3) : AppColors.grey50,
              ),
              child: Center(
                child: Text(
                  l10n.moreItemsHint(remainingCount, remainingTotal.toStringAsFixed(2), l10n.sar),
                  style: TextStyle(fontSize: 12, color: colorScheme.onSurfaceVariant),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildItemRow(_InvoiceItem item, bool isDark, AppLocalizations l10n) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: isDark ? colorScheme.outlineVariant.withValues(alpha: 0.1) : AppColors.divider)),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
            ),
            child: Icon(item.icon, size: 18, color: colorScheme.onSurfaceVariant),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.name, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: colorScheme.onSurface), overflow: TextOverflow.ellipsis, maxLines: 1),
                Text(
                  'SKU: ${item.sku}',
                  style: TextStyle(fontSize: 11, fontFamily: 'Courier', color: colorScheme.onSurfaceVariant),
                  textDirection: TextDirection.ltr,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${item.total.toStringAsFixed(2)} ${l10n.sar}',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: colorScheme.onSurface),
              ),
              Text(
                l10n.qtyLabel(item.qty),
                style: TextStyle(fontSize: 11, color: colorScheme.onSurfaceVariant),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ============================================================================
  // REASON CARD
  // ============================================================================

  Widget _buildReasonCard(bool isDark, AppLocalizations l10n) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isDark ? colorScheme.outlineVariant.withValues(alpha: 0.15) : AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.help_outline, size: 18, color: AppColors.primary),
              const SizedBox(width: 8),
              Text(
                l10n.voidReason,
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: colorScheme.onSurface),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Reason options
          ...List.generate(_reasonKeys.length, (i) {
            final key = _reasonKeys[i];
            final isSelected = _selectedReason == key;
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: GestureDetector(
                onTap: () => setState(() => _selectedReason = key),
                child: AnimatedContainer(
                  duration: AlhaiDurations.standard,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? (isDark ? AppColors.error.withValues(alpha: 0.1) : const Color(0xFFFEF2F2))
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected
                          ? AppColors.error
                          : (isDark ? colorScheme.outlineVariant.withValues(alpha: 0.2) : AppColors.border),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isSelected ? AppColors.error : (isDark ? colorScheme.outlineVariant.withValues(alpha: 0.4) : AppColors.textMuted),
                            width: isSelected ? 6 : 2,
                          ),
                          color: isSelected ? colorScheme.onPrimary : Colors.transparent,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _getReasonText(key, l10n),
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                            color: isDark ? colorScheme.onSurface.withValues(alpha: 0.8) : AppColors.textSecondary,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
          // Notes
          const SizedBox(height: 8),
          TextField(
            controller: _notesController,
            maxLines: 3,
            decoration: InputDecoration(
              hintText: _selectedReason == 'other' ? l10n.additionalDetailsRequired : l10n.additionalNotesVoid,
              hintStyle: TextStyle(fontSize: 13, color: colorScheme.onSurfaceVariant),
              filled: true,
              fillColor: isDark ? const Color(0xFF0F172A) : AppColors.grey50,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: isDark ? colorScheme.outlineVariant.withValues(alpha: 0.2) : AppColors.border),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: isDark ? colorScheme.outlineVariant.withValues(alpha: 0.2) : AppColors.border),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: AppColors.error.withValues(alpha: 0.5)),
              ),
            ),
            style: TextStyle(fontSize: 13, color: colorScheme.onSurface),
          ),
        ],
      ),
    );
  }

  // ============================================================================
  // MANAGER PIN CARD
  // ============================================================================

  Widget _buildManagerPinCard(bool isDark, AppLocalizations l10n) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E3A5F).withValues(alpha: 0.3) : const Color(0xFFEFF6FF),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isDark ? const Color(0xFF1D4ED8).withValues(alpha: 0.3) : const Color(0xFFBFDBFE)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.shield_outlined, size: 18, color: isDark ? const Color(0xFF60A5FA) : const Color(0xFF1D4ED8)),
              const SizedBox(width: 8),
              Text(
                l10n.managerApproval,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: isDark ? const Color(0xFF93C5FD) : const Color(0xFF1E40AF),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            l10n.operationRequiresApproval,
            style: TextStyle(
              fontSize: 12,
              color: isDark ? const Color(0xFF93C5FD).withValues(alpha: 0.8) : const Color(0xFF1E3A8A),
            ),
          ),
          const SizedBox(height: 16),
          // إشعار: سيُطلب PIN عند الضغط على زر التأكيد
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isDark ? const Color(0xFF1D4ED8).withValues(alpha: 0.3) : const Color(0xFFBFDBFE),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.lock_rounded,
                  size: 20,
                  color: isDark ? const Color(0xFF60A5FA) : const Color(0xFF3B82F6),
                ),
                const SizedBox(width: 8),
                Text(
                  l10n.pinRequired,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isDark ? const Color(0xFF93C5FD) : const Color(0xFF1E40AF),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================================
  // CONFIRM CHECKBOX
  // ============================================================================

  Widget _buildConfirmCheckbox(bool isDark, AppLocalizations l10n) {
    final colorScheme = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: () => setState(() => _confirmed = !_confirmed),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: _confirmed
                ? AppColors.error
                : (isDark ? colorScheme.outlineVariant.withValues(alpha: 0.15) : AppColors.border),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 24,
              height: 24,
              child: Checkbox(
                value: _confirmed,
                onChanged: (v) => setState(() => _confirmed = v ?? false),
                activeColor: AppColors.error,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.confirmVoidAction,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    l10n.confirmVoidDesc,
                    style: TextStyle(fontSize: 12, color: colorScheme.onSurfaceVariant),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================================
  // DESKTOP BUTTONS
  // ============================================================================

  Widget _buildDesktopButtons(bool isDark, AppLocalizations l10n) {
    final colorScheme = Theme.of(context).colorScheme;
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: _resetForm,
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              side: BorderSide(color: isDark ? colorScheme.outlineVariant.withValues(alpha: 0.25) : AppColors.border),
              foregroundColor: colorScheme.onSurfaceVariant,
            ),
            child: Text(l10n.cancelAction, style: const TextStyle(fontWeight: FontWeight.bold)),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          flex: 2,
          child: FilledButton.icon(
            onPressed: _isFormValid ? _confirmVoid : null,
            icon: const Icon(Icons.block, size: 18),
            label: Text(l10n.confirmFinalVoid, style: const TextStyle(fontWeight: FontWeight.bold)),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: colorScheme.onPrimary,
              disabledBackgroundColor: isDark ? AppColors.error.withValues(alpha: 0.3) : AppColors.error.withValues(alpha: 0.4),
              disabledForegroundColor: colorScheme.onSurface.withValues(alpha: 0.5),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              elevation: _isFormValid ? 4 : 0,
            ),
          ),
        ),
      ],
    );
  }

  // ============================================================================
  // DRAWER (mobile)
  // ============================================================================
}
