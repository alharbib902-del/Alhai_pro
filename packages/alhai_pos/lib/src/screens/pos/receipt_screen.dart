import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:alhai_shared_ui/alhai_shared_ui.dart';
import 'package:alhai_database/alhai_database.dart';
import 'package:get_it/get_it.dart';
import '../../services/zatca_service.dart';
import '../../services/receipt_printer_service.dart';
import '../../services/whatsapp_receipt_service.dart';
import '../../providers/sale_providers.dart';
import 'package:alhai_l10n/alhai_l10n.dart';
import 'package:alhai_design_system/alhai_design_system.dart';

// M160: Locale-aware currency formatting helper for this file
String _fmtCurrency(BuildContext context, double amount) =>
    CurrencyFormatter.formatWithContext(context, amount);

/// شاشة الإيصال
///
/// تعرض تفاصيل الفاتورة بعد الدفع مع خيار الطباعة و QR Code هيئة الزكاة
class ReceiptScreen extends ConsumerStatefulWidget {
  final String? saleId;

  const ReceiptScreen({super.key, this.saleId});

  @override
  ConsumerState<ReceiptScreen> createState() => _ReceiptScreenState();
}

class _ReceiptScreenState extends ConsumerState<ReceiptScreen> {
  SalesTableData? _sale;
  List<SaleItemsTableData> _items = [];
  bool _isLoading = true;
  String? _error;
  String? _qrData;
  String? _customerPhone;
  bool _isSendingWhatsApp = false;
  bool _whatsAppSent = false;

  @override
  void initState() {
    super.initState();
    _loadSaleData();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _customerPhone = ref.read(receiptPhoneProvider);
      if (mounted) setState(() {});
    });
  }

  Future<void> _loadSaleData() async {
    if (widget.saleId == null) {
      setState(() {
        _isLoading = false;
        _error = 'invoiceNotSpecified';
      });
      return;
    }

    try {
      final db = GetIt.I<AppDatabase>();
      final sale = await db.salesDao.getSaleById(widget.saleId!);

      if (sale == null) {
        setState(() {
          _isLoading = false;
          _error = 'invoiceNotFound';
        });
        return;
      }

      final items = await db.saleItemsDao.getItemsBySaleId(widget.saleId!);

      // Load store info for ZATCA QR
      final storeId = ref.read(currentStoreIdProvider) ?? kDefaultStoreId;
      final store = await db.storesDao.getStoreById(storeId);
      final sellerName = store?.name ?? 'Store';
      final vatNumber = store?.taxNumber ?? '';

      // توليد QR Code بيانات ZATCA
      final qrData = ZatcaService.generateQrData(
        sellerName: sellerName,
        vatNumber: vatNumber,
        timestamp: sale.createdAt,
        totalWithVat: sale.total,
        vatAmount: sale.tax,
      );

      setState(() {
        _sale = sale;
        _items = items;
        _qrData = qrData;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _error = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.receiptTitle),
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(top: false, child: _buildBody(context)),
    );
  }

  Widget _buildBody(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return AppErrorState.general(
        context,
        message: _error == 'invoiceNotSpecified'
            ? l10n.invoiceNotSpecified
            : _error == 'invoiceNotFound'
            ? l10n.invoiceNotFound
            : _error,
        onRetry: () {
          setState(() {
            _isLoading = true;
            _error = null;
          });
          _loadSaleData();
        },
      );
    }

    final sale = _sale!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final dateFormat = DateFormat('yyyy/MM/dd HH:mm', 'ar');
    final screenWidth = context.screenWidth;
    final maxWidth = screenWidth > 600 ? 480.0 : 400.0;

    return Center(
      child: Container(
        constraints: BoxConstraints(maxWidth: maxWidth),
        margin: EdgeInsets.all(
          screenWidth > 600 ? AlhaiSpacing.xl : AlhaiSpacing.md,
        ),
        child: Column(
          children: [
            // Success icon
            Container(
              padding: const EdgeInsets.all(AlhaiSpacing.lg),
              decoration: BoxDecoration(
                color: AppColors.success.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_circle,
                color: AppColors.success,
                size: 64,
              ),
            ),
            const SizedBox(height: AlhaiSpacing.md),
            Text(
              l10n.paymentSuccessful,
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),

            // Pending sync indicator for offline sales
            if (sale.syncedAt == null) ...[
              const SizedBox(height: AlhaiSpacing.sm),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AlhaiSpacing.md,
                  vertical: AlhaiSpacing.xs,
                ),
                decoration: BoxDecoration(
                  color: AppColors.warningSurface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: AppColors.warning.withValues(alpha: 0.5),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.cloud_upload_outlined,
                      size: 18,
                      color: AppColors.warning,
                    ),
                    const SizedBox(width: AlhaiSpacing.xs),
                    Text(
                      l10n.pendingSync,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.warning,
                      ),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: AlhaiSpacing.lg),

            // Receipt card
            Expanded(
              child: SingleChildScrollView(
                child: Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(AlhaiSpacing.mdl),
                    child: Column(
                      children: [
                        // Receipt header
                        Text(
                          l10n.simplifiedTaxInvoice,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        // Sync status badge inside receipt card
                        if (sale.syncedAt == null)
                          Padding(
                            padding: const EdgeInsets.only(top: 6),
                            child: Chip(
                              avatar: const Icon(
                                Icons.sync,
                                size: 16,
                                color: AppColors.warning,
                              ),
                              label: Text(
                                l10n.notSynced,
                                style: TextStyle(
                                  fontSize: 11,
                                  color: AppColors.warning,
                                ),
                              ),
                              backgroundColor: AppColors.warningSurface,
                              side: BorderSide(
                                color: AppColors.warning.withValues(alpha: 0.3),
                              ),
                              padding: EdgeInsets.zero,
                              visualDensity: VisualDensity.compact,
                            ),
                          ),
                        const SizedBox(height: AlhaiSpacing.xxs),
                        Text(
                          l10n.receiptNumberLabel(sale.receiptNo),
                          style: TextStyle(
                            fontSize: 13,
                            color: isDark
                                ? AppColors.textSecondaryDark
                                : AppColors.textSecondary,
                          ),
                        ),
                        Text(
                          dateFormat.format(sale.createdAt),
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark
                                ? AppColors.textSecondaryDark
                                : AppColors.textSecondary,
                          ),
                        ),
                        const Divider(height: 24),

                        // Items
                        if (_items.isNotEmpty) ...[
                          // Items header
                          Row(
                            children: [
                              Expanded(
                                flex: 3,
                                child: Text(
                                  l10n.itemColumnHeader,
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: isDark
                                        ? AppColors.textSecondaryDark
                                        : AppColors.textSecondary,
                                  ),
                                ),
                              ),
                              SizedBox(
                                width: 40,
                                child: Text(
                                  l10n.quantityLabel,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: isDark
                                        ? AppColors.textSecondaryDark
                                        : AppColors.textSecondary,
                                  ),
                                ),
                              ),
                              SizedBox(
                                width: 60,
                                child: Text(
                                  l10n.totalLabel,
                                  textAlign: TextAlign.start,
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: isDark
                                        ? AppColors.textSecondaryDark
                                        : AppColors.textSecondary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: AlhaiSpacing.xxs),
                          ..._items.map(
                            (item) => Padding(
                              padding: const EdgeInsets.symmetric(vertical: 3),
                              child: Row(
                                children: [
                                  Expanded(
                                    flex: 3,
                                    child: Text(
                                      item.productName,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(fontSize: 13),
                                    ),
                                  ),
                                  SizedBox(
                                    width: 40,
                                    child: Text(
                                      '${item.qty}',
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(fontSize: 13),
                                    ),
                                  ),
                                  SizedBox(
                                    width: 60,
                                    child: Text(
                                      CurrencyFormatter.formatNumberWithContext(
                                        context,
                                        item.total,
                                      ),
                                      textAlign: TextAlign.start,
                                      style: const TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const Divider(height: 20),
                        ],

                        // Totals
                        _totalRow(
                          l10n.subtotalLabel,
                          _fmtCurrency(context, sale.subtotal),
                          isDark,
                        ),
                        const SizedBox(height: AlhaiSpacing.xxs),
                        _totalRow(
                          l10n.vatLabel,
                          _fmtCurrency(context, sale.tax),
                          isDark,
                        ),
                        if (sale.discount > 0) ...[
                          const SizedBox(height: AlhaiSpacing.xxs),
                          _totalRow(
                            l10n.discountLabel(''),
                            '-${_fmtCurrency(context, sale.discount)}',
                            isDark,
                            color: AppColors.success,
                          ),
                        ],
                        const SizedBox(height: AlhaiSpacing.xs),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            vertical: AlhaiSpacing.xs,
                            horizontal: AlhaiSpacing.sm,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                l10n.totalAmount(''),
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                _fmtCurrency(context, sale.total),
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: AlhaiSpacing.xs),

                        // Payment method
                        _totalRow(
                          l10n.paymentMethodField,
                          _getPaymentMethodLabel(sale.paymentMethod),
                          isDark,
                        ),
                        const Divider(height: 24),

                        // QR Code - ZATCA
                        if (_qrData != null) ...[
                          QrImageView(
                            data: _qrData!,
                            version: QrVersions.auto,
                            size: 140,
                            backgroundColor: Colors.white,
                            eyeStyle: QrEyeStyle(
                              eyeShape: QrEyeShape.square,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                            dataModuleStyle: QrDataModuleStyle(
                              dataModuleShape: QrDataModuleShape.square,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            l10n.zatcaQrCode,
                            style: TextStyle(
                              fontSize: 11,
                              color: isDark
                                  ? AppColors.textSecondaryDark
                                  : AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: AlhaiSpacing.xxs),
                          Text(
                            l10n.includesVat15,
                            style: TextStyle(
                              fontSize: 10,
                              color: isDark
                                  ? AppColors.textSecondaryDark
                                  : AppColors.textMuted,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: AlhaiSpacing.md),

            // Actions
            Row(
              children: [
                // زر الطباعة
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _printReceipt,
                    icon: const Icon(Icons.print_outlined),
                    label: Text(l10n.printAction),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                // زر واتساب (يظهر فقط عند وجود رقم هاتف)
                if (_customerPhone != null) ...[
                  const SizedBox(width: AlhaiSpacing.xs),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _isSendingWhatsApp
                          ? null
                          : _sendWhatsAppReceipt,
                      icon: _isSendingWhatsApp
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.chat, color: AppColors.success),
                      label: Text(
                        _whatsAppSent
                            ? l10n.whatsappSentLabel
                            : l10n.whatsappLabel,
                      ),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        side: const BorderSide(color: AppColors.success),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
                const SizedBox(width: AlhaiSpacing.xs),
                // زر بيع جديد
                Expanded(
                  flex: _customerPhone != null ? 1 : 2,
                  child: FilledButton.icon(
                    onPressed: () {
                      ref.read(receiptPhoneProvider.notifier).state = null;
                      context.go(AppRoutes.pos);
                    },
                    icon: const Icon(Icons.add),
                    label: Text(l10n.newSale),
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _totalRow(String label, String value, bool isDark, {Color? color}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            color:
                color ??
                (isDark
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondary),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
      ],
    );
  }

  String _getPaymentMethodLabel(String method) {
    final l10n = AppLocalizations.of(context);
    switch (method.toLowerCase()) {
      case 'cash':
        return l10n.cashMethod;
      case 'card':
        return l10n.cardMethod;
      case 'mixed':
        return l10n.mixedMethod;
      case 'credit':
        return l10n.creditMethod;
      case 'wallet':
        return l10n.walletMethod;
      case 'banktransfer':
        return l10n.bankTransferMethod;
      default:
        return method;
    }
  }

  Future<void> _sendWhatsAppReceipt() async {
    if (_sale == null || _customerPhone == null) return;
    final l10n = AppLocalizations.of(context);

    setState(() => _isSendingWhatsApp = true);

    try {
      final receiptText = WhatsAppReceiptService.formatReceipt(
        storeName: l10n.storeLabel,
        receiptNo: _sale!.receiptNo,
        date: _sale!.createdAt,
        items: _items
            .map(
              (i) => ReceiptLineItem(
                name: i.productName,
                quantity: i.qty.toInt(),
                total: i.total,
              ),
            )
            .toList(),
        subtotal: _sale!.subtotal,
        tax: _sale!.tax,
        discount: _sale!.discount,
        total: _sale!.total,
        paymentMethod: _getPaymentMethodLabel(_sale!.paymentMethod),
      );

      // إرسال عبر طابور قاعدة البيانات
      final receiptService = ref.read(whatsappReceiptServiceProvider);
      await receiptService.sendReceiptText(
        phone: _customerPhone!,
        receiptText: receiptText,
        saleId: widget.saleId,
      );

      if (mounted) {
        setState(() {
          _whatsAppSent = true;
          _isSendingWhatsApp = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.whatsappReceiptSent),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSendingWhatsApp = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.whatsappSendFailed(e.toString())),
            backgroundColor: AppColors.warning,
          ),
        );
      }
    }
  }

  Future<void> _printReceipt() async {
    final l10n = AppLocalizations.of(context);
    if (widget.saleId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.cannotPrintNoInvoice),
          backgroundColor: AppColors.warning,
        ),
      );
      return;
    }

    try {
      await ReceiptPrinterService.printReceipt(context, widget.saleId!);
    } catch (e) {
      // إضافة الفاتورة لقائمة الطباعة عند فشل الطباعة
      ref
          .read(printQueueProvider.notifier)
          .addJob(
            PrintJob(
              id: 'PJ-${DateTime.now().millisecondsSinceEpoch}',
              saleId: widget.saleId!,
              receiptNo: _sale?.receiptNo ?? '',
              type: 'receipt',
              status: 'failed',
              errorMessage: e.toString(),
              createdAt: DateTime.now(),
            ),
          );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.invoiceAddedToPrintQueue),
          backgroundColor: AppColors.warning,
        ),
      );
    }
  }
}
