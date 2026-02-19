import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../core/router/routes.dart';
import '../../core/theme/app_colors.dart';
import '../../data/local/app_database.dart';
import '../../di/injection.dart';
import '../../services/zatca_service.dart';
import '../../services/receipt_printer_service.dart';
import '../../services/whatsapp_receipt_service.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../providers/print_providers.dart';
import '../../providers/whatsapp_queue_providers.dart';

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
      final db = getIt<AppDatabase>();
      final sale = await db.salesDao.getSaleById(widget.saleId!);

      if (sale == null) {
        setState(() {
          _isLoading = false;
          _error = 'invoiceNotFound';
        });
        return;
      }

      final items = await db.saleItemsDao.getItemsBySaleId(widget.saleId!);

      // توليد QR Code بيانات ZATCA
      final qrData = ZatcaService.generateQrData(
        sellerName: 'Al-HAI Store',
        vatNumber: '300000000000003',
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
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.receiptTitle),
        automaticallyImplyLeading: false,
      ),
      body: _buildBody(context),
    );
  }

  Widget _buildBody(BuildContext context) {
    final theme = Theme.of(context);
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: theme.colorScheme.error.withValues(alpha: 0.7)),
            const SizedBox(height: 16),
            Text(
              _error == 'invoiceNotSpecified' ? AppLocalizations.of(context)!.invoiceNotSpecified
                : _error == 'invoiceNotFound' ? AppLocalizations.of(context)!.invoiceNotFound
                : _error!,
              style: TextStyle(color: theme.colorScheme.error),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: () => context.go(AppRoutes.pos),
              icon: const Icon(Icons.point_of_sale),
              label: Text(AppLocalizations.of(context)!.newSale),
            ),
          ],
        ),
      );
    }

    final sale = _sale!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final dateFormat = DateFormat('yyyy/MM/dd HH:mm', 'ar');
    final screenWidth = MediaQuery.of(context).size.width;
    final maxWidth = screenWidth > 600 ? 480.0 : 400.0;

    return Center(
      child: Container(
        constraints: BoxConstraints(maxWidth: maxWidth),
        margin: EdgeInsets.all(screenWidth > 600 ? 32 : 16),
        child: Column(
          children: [
            // Success icon
            Container(
              padding: const EdgeInsets.all(24),
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
            const SizedBox(height: 16),
            Text(
              AppLocalizations.of(context)!.paymentSuccessful,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),

            // Pending sync indicator for offline sales
            if (sale.syncedAt == null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.warningSurface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.warning.withValues(alpha: 0.5)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.cloud_upload_outlined,
                        size: 18, color: AppColors.warning),
                    const SizedBox(width: 8),
                    Text(
                      AppLocalizations.of(context)!.pendingSync,
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

            const SizedBox(height: 24),

            // Receipt card
            Expanded(
              child: SingleChildScrollView(
                child: Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      children: [
                        // Receipt header
                        Text(
                          AppLocalizations.of(context)!.simplifiedTaxInvoice,
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
                              avatar: const Icon(Icons.sync,
                                  size: 16, color: AppColors.warning),
                              label: Text(
                                AppLocalizations.of(context)!.notSynced,
                                style: TextStyle(
                                  fontSize: 11,
                                  color: AppColors.warning,
                                ),
                              ),
                              backgroundColor: AppColors.warningSurface,
                              side: BorderSide(color: AppColors.warning.withValues(alpha: 0.3)),
                              padding: EdgeInsets.zero,
                              visualDensity: VisualDensity.compact,
                            ),
                          ),
                        const SizedBox(height: 4),
                        Text(
                          AppLocalizations.of(context)!.receiptNumberLabel(sale.receiptNo),
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
                                child: Text(AppLocalizations.of(context)!.itemColumnHeader,
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: isDark
                                          ? AppColors.textSecondaryDark
                                          : AppColors.textSecondary,
                                    )),
                              ),
                              SizedBox(
                                width: 40,
                                child: Text(AppLocalizations.of(context)!.quantityLabel,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: isDark
                                          ? AppColors.textSecondaryDark
                                          : AppColors.textSecondary,
                                    )),
                              ),
                              SizedBox(
                                width: 60,
                                child: Text(AppLocalizations.of(context)!.totalLabel,
                                    textAlign: TextAlign.start,
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: isDark
                                          ? AppColors.textSecondaryDark
                                          : AppColors.textSecondary,
                                    )),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          ..._items.map((item) => Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 3),
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
                                        item.total.toStringAsFixed(2),
                                        textAlign: TextAlign.start,
                                        style: const TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              )),
                          const Divider(height: 20),
                        ],

                        // Totals
                        _totalRow(AppLocalizations.of(context)!.subtotalLabel,
                            '${sale.subtotal.toStringAsFixed(2)} ${AppLocalizations.of(context)!.sar}', isDark),
                        const SizedBox(height: 4),
                        _totalRow(
                            AppLocalizations.of(context)!.vatLabel,
                            '${sale.tax.toStringAsFixed(2)} ${AppLocalizations.of(context)!.sar}',
                            isDark),
                        if (sale.discount > 0) ...[
                          const SizedBox(height: 4),
                          _totalRow(
                              AppLocalizations.of(context)!.discountLabel,
                              '-${sale.discount.toStringAsFixed(2)} ${AppLocalizations.of(context)!.sar}',
                              isDark,
                              color: AppColors.success),
                        ],
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              vertical: 8, horizontal: 12),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                AppLocalizations.of(context)!.totalAmount,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                '${sale.total.toStringAsFixed(2)} ${AppLocalizations.of(context)!.sar}',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),

                        // Payment method
                        _totalRow(AppLocalizations.of(context)!.paymentMethodField,
                            _getPaymentMethodLabel(sale.paymentMethod), isDark),
                        const Divider(height: 24),

                        // QR Code - ZATCA
                        if (_qrData != null) ...[
                          QrImageView(
                            data: _qrData!,
                            version: QrVersions.auto,
                            size: 140,
                            backgroundColor: Colors.white,
                            eyeStyle: const QrEyeStyle(
                              eyeShape: QrEyeShape.square,
                              color: Colors.black,
                            ),
                            dataModuleStyle: const QrDataModuleStyle(
                              dataModuleShape: QrDataModuleShape.square,
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            AppLocalizations.of(context)!.zatcaQrCode,
                            style: TextStyle(
                              fontSize: 11,
                              color: isDark
                                  ? AppColors.textSecondaryDark
                                  : AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            AppLocalizations.of(context)!.includesVat15,
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

            const SizedBox(height: 16),

            // Actions
            Row(
              children: [
                // زر الطباعة
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _printReceipt,
                    icon: const Icon(Icons.print_outlined),
                    label: Text(AppLocalizations.of(context)!.printAction),
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
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed:
                          _isSendingWhatsApp ? null : _sendWhatsAppReceipt,
                      icon: _isSendingWhatsApp
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2))
                          : const Icon(Icons.chat, color: AppColors.success),
                      label: Text(_whatsAppSent ? AppLocalizations.of(context)!.whatsappSentLabel : AppLocalizations.of(context)!.whatsappLabel),
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
                const SizedBox(width: 8),
                // زر بيع جديد
                Expanded(
                  flex: _customerPhone != null ? 1 : 2,
                  child: FilledButton.icon(
                    onPressed: () {
                      ref.read(receiptPhoneProvider.notifier).state = null;
                      context.go(AppRoutes.pos);
                    },
                    icon: const Icon(Icons.add),
                    label: Text(AppLocalizations.of(context)!.newSale),
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

  Widget _totalRow(String label, String value, bool isDark,
      {Color? color}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            color: color ??
                (isDark ? AppColors.textSecondaryDark : AppColors.textSecondary),
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
    switch (method.toLowerCase()) {
      case 'cash':
        return AppLocalizations.of(context)!.cashMethod;
      case 'card':
        return AppLocalizations.of(context)!.cardMethod;
      case 'mixed':
        return AppLocalizations.of(context)!.mixedMethod;
      case 'credit':
        return AppLocalizations.of(context)!.creditMethod;
      case 'wallet':
        return AppLocalizations.of(context)!.walletMethod;
      case 'banktransfer':
        return AppLocalizations.of(context)!.bankTransferMethod;
      default:
        return method;
    }
  }

  Future<void> _sendWhatsAppReceipt() async {
    if (_sale == null || _customerPhone == null) return;

    setState(() => _isSendingWhatsApp = true);

    try {
      final receiptText = WhatsAppReceiptService.formatReceipt(
        storeName: 'المتجر',
        receiptNo: _sale!.receiptNo,
        date: _sale!.createdAt,
        items: _items
            .map((i) => ReceiptLineItem(
                  name: i.productName,
                  quantity: i.qty,
                  total: i.total,
                ))
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
            content: Text(AppLocalizations.of(context)!.whatsappReceiptSent),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSendingWhatsApp = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.whatsappSendFailed(e.toString())),
            backgroundColor: AppColors.warning,
          ),
        );
      }
    }
  }

  Future<void> _printReceipt() async {
    if (widget.saleId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.cannotPrintNoInvoice),
          backgroundColor: AppColors.warning,
        ),
      );
      return;
    }

    try {
      await ReceiptPrinterService.printReceipt(context, widget.saleId!);
    } catch (e) {
      // إضافة الفاتورة لقائمة الطباعة عند فشل الطباعة
      ref.read(printQueueProvider.notifier).addJob(PrintJob(
            id: 'PJ-${DateTime.now().millisecondsSinceEpoch}',
            saleId: widget.saleId!,
            receiptNo: _sale?.receiptNo ?? '',
            type: 'receipt',
            status: 'failed',
            errorMessage: e.toString(),
            createdAt: DateTime.now(),
          ));

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.invoiceAddedToPrintQueue),
          backgroundColor: AppColors.warning,
        ),
      );
    }
  }
}
