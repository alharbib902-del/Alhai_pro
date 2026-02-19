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
        _error = 'لم يتم تحديد رقم الفاتورة';
      });
      return;
    }

    try {
      final db = getIt<AppDatabase>();
      final sale = await db.salesDao.getSaleById(widget.saleId!);

      if (sale == null) {
        setState(() {
          _isLoading = false;
          _error = 'الفاتورة غير موجودة';
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
        title: const Text('الإيصال'),
        automaticallyImplyLeading: false,
      ),
      body: _buildBody(context),
    );
  }

  Widget _buildBody(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red.shade300),
            const SizedBox(height: 16),
            Text(_error!, style: const TextStyle(color: Colors.red)),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: () => context.go(AppRoutes.pos),
              icon: const Icon(Icons.point_of_sale),
              label: const Text('بيع جديد'),
            ),
          ],
        ),
      );
    }

    final sale = _sale!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final dateFormat = DateFormat('yyyy/MM/dd HH:mm', 'ar');

    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 400),
        margin: const EdgeInsets.all(24),
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
              'تمت العملية بنجاح!',
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
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.orange.shade300),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.cloud_upload_outlined,
                        size: 18, color: Colors.orange.shade700),
                    const SizedBox(width: 8),
                    Text(
                      'في انتظار المزامنة',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Colors.orange.shade700,
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
                        const Text(
                          'فاتورة ضريبية مبسطة',
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
                              avatar: Icon(Icons.sync,
                                  size: 16, color: Colors.orange.shade700),
                              label: Text(
                                'غير مزامنة',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.orange.shade700,
                                ),
                              ),
                              backgroundColor: Colors.orange.shade50,
                              side: BorderSide(color: Colors.orange.shade200),
                              padding: EdgeInsets.zero,
                              visualDensity: VisualDensity.compact,
                            ),
                          ),
                        const SizedBox(height: 4),
                        Text(
                          'رقم: ${sale.receiptNo}',
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
                                child: Text('الصنف',
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
                                child: Text('الكمية',
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
                                child: Text('المجموع',
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
                        _totalRow('المجموع الفرعي',
                            '${sale.subtotal.toStringAsFixed(2)} ر.س', isDark),
                        const SizedBox(height: 4),
                        _totalRow(
                            'ضريبة القيمة المضافة (15%)',
                            '${sale.tax.toStringAsFixed(2)} ر.س',
                            isDark),
                        if (sale.discount > 0) ...[
                          const SizedBox(height: 4),
                          _totalRow(
                              'الخصم',
                              '-${sale.discount.toStringAsFixed(2)} ر.س',
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
                              const Text(
                                'الإجمالي',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                '${sale.total.toStringAsFixed(2)} ر.س',
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
                        _totalRow('طريقة الدفع',
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
                            'رمز ZATCA الضريبي',
                            style: TextStyle(
                              fontSize: 11,
                              color: isDark
                                  ? AppColors.textSecondaryDark
                                  : AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'يشمل ضريبة القيمة المضافة 15%',
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
                    label: const Text('طباعة'),
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
                          : Icon(Icons.chat, color: Colors.green.shade600),
                      label: Text(_whatsAppSent ? 'تم الإرسال \u2713' : 'واتساب'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        side: BorderSide(color: Colors.green.shade600),
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
                    label: const Text('بيع جديد'),
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
        return 'نقداً';
      case 'card':
        return 'بطاقة';
      case 'mixed':
        return 'مختلط';
      case 'credit':
        return 'آجل';
      case 'wallet':
        return 'محفظة';
      case 'banktransfer':
        return 'تحويل بنكي';
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
          const SnackBar(
            content: Text('تم إرسال الإيصال عبر واتساب \u2713'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSendingWhatsApp = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('فشل الإرسال: $e'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    }
  }

  Future<void> _printReceipt() async {
    if (widget.saleId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('لا يمكن الطباعة - رقم الفاتورة غير متوفر'),
          backgroundColor: Colors.orange,
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
        const SnackBar(
          content: Text('تمت إضافة الفاتورة لقائمة الطباعة'),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }
}
