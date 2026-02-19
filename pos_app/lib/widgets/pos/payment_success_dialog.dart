// مكون نجاح الدفع - Payment Success Dialog
//
// يظهر بعد إتمام الدفع مع خيارات:
// - إرسال الفاتورة عبر واتساب
// - طباعة الإيصال
// - بدء بيع جديدة
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../data/local/app_database.dart';
import '../../di/injection.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../services/whatsapp_service.dart';
import '../../services/whatsapp/phone_validation_service.dart';
import '../../services/whatsapp/wasender_api_client.dart';
import '../../services/receipt_printer_service.dart';

/// نتيجة dialog النجاح
enum PaymentSuccessAction { newSale, print }

/// Dialog نجاح الدفع
class PaymentSuccessDialog extends StatefulWidget {
  final String receiptNumber;
  final double amount;
  final String paymentMethodLabel;
  final String? customerPhone;
  final String? customerName;
  final String storeName;
  final String? saleId;

  const PaymentSuccessDialog({
    super.key,
    required this.receiptNumber,
    required this.amount,
    required this.paymentMethodLabel,
    this.customerPhone,
    this.customerName,
    this.storeName = 'Al-HAI POS',
    this.saleId,
  });

  /// عرض Dialog النجاح
  static Future<PaymentSuccessAction?> show({
    required BuildContext context,
    required String receiptNumber,
    required double amount,
    required String paymentMethodLabel,
    String? customerPhone,
    String? customerName,
    String storeName = 'Al-HAI POS',
    String? saleId,
  }) {
    return showDialog<PaymentSuccessAction>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => PaymentSuccessDialog(
        receiptNumber: receiptNumber,
        amount: amount,
        paymentMethodLabel: paymentMethodLabel,
        customerPhone: customerPhone,
        customerName: customerName,
        storeName: storeName,
        saleId: saleId,
      ),
    );
  }

  @override
  State<PaymentSuccessDialog> createState() => _PaymentSuccessDialogState();
}

class _PaymentSuccessDialogState extends State<PaymentSuccessDialog>
    with SingleTickerProviderStateMixin {
  final _phoneController = TextEditingController();
  bool _isSending = false;
  bool _sent = false;
  late AnimationController _animController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    if (widget.customerPhone != null && widget.customerPhone!.isNotEmpty) {
      _phoneController.text = widget.customerPhone!;
    }
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _scaleAnimation = CurvedAnimation(
      parent: _animController,
      curve: Curves.elasticOut,
    );
    _animController.forward();
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _animController.dispose();
    super.dispose();
  }

  Future<void> _sendWhatsApp() async {
    final phone = _phoneController.text.trim();
    if (phone.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('أدخل رقم الجوال'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isSending = true);

    try {
      final db = getIt<AppDatabase>();
      final service = WhatsAppService(
        messagesDao: db.whatsAppMessagesDao,
        phoneValidator: PhoneValidationService(
          apiClient: WaSenderApiClient(),
        ),
      );

      await service.sendReceipt(
        phoneNumber: phone,
        customerName: widget.customerName ?? '',
        receiptNumber: widget.receiptNumber,
        total: widget.amount,
        storeName: widget.storeName,
      );

      if (mounted) {
        setState(() {
          _isSending = false;
          _sent = true;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSending = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('تعذر إرسال واتساب: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // أيقونة النجاح
              ScaleTransition(
                scale: _scaleAnimation,
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.success.withValues(alpha: 0.1),
                  ),
                  child: const Icon(
                    Icons.check_circle,
                    color: AppColors.success,
                    size: 56,
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // العنوان
              Text(
                'تم الدفع بنجاح!',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.success,
                ),
              ),
              const SizedBox(height: 8),

              // تفاصيل
              Text(
                widget.paymentMethodLabel,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: isDark ? Colors.white60 : AppColors.textMuted,
                ),
              ),
              const SizedBox(height: 16),

              // المبلغ ورقم الفاتورة
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.05)
                      : AppColors.grey50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'رقم الفاتورة',
                          style: TextStyle(
                            color: isDark ? Colors.white60 : AppColors.textMuted,
                          ),
                        ),
                        Text(
                          widget.receiptNumber,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'المبلغ المدفوع',
                          style: TextStyle(
                            color: isDark ? Colors.white60 : AppColors.textMuted,
                          ),
                        ),
                        Text(
                          'ر.س ${widget.amount.toStringAsFixed(2)}',
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.success,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // قسم الواتساب
              Divider(color: isDark ? Colors.white12 : AppColors.grey200),
              const SizedBox(height: 12),

              Text(
                'إرسال الفاتورة عبر واتساب',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),

              // حقل رقم الجوال
              TextField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                textDirection: TextDirection.ltr,
                decoration: InputDecoration(
                  hintText: '05XXXXXXXX',
                  prefixIcon: const Icon(Icons.phone_outlined, size: 20),
                  suffixIcon: _sent
                      ? const Icon(Icons.check_circle, color: AppColors.success)
                      : null,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  isDense: true,
                ),
              ),
              const SizedBox(height: 8),

              // زر واتساب
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _isSending ? null : _sendWhatsApp,
                  icon: _isSending
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Icon(
                          _sent ? Icons.check : Icons.send,
                          size: 18,
                        ),
                  label: Text(_sent ? 'تم الإرسال' : 'إرسال واتساب'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF25D366), // WhatsApp green
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // أزرار الإجراءات
              Row(
                children: [
                  // طباعة
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () async {
                        if (widget.saleId != null) {
                          await ReceiptPrinterService.printReceipt(
                            context,
                            widget.saleId!,
                          );
                        }
                        if (context.mounted) {
                          Navigator.pop(context, PaymentSuccessAction.print);
                        }
                      },
                      icon: const Icon(Icons.print_outlined, size: 18),
                      label: Text(AppLocalizations.of(context)!.print),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // بيع جديدة
                  Expanded(
                    flex: 2,
                    child: FilledButton.icon(
                      onPressed: () {
                        Navigator.pop(context, PaymentSuccessAction.newSale);
                      },
                      icon: const Icon(Icons.add_shopping_cart, size: 18),
                      label: const Text('بيع جديدة'),
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
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
      ),
    );
  }
}
