// مكون نجاح الدفع - Payment Success Dialog
//
// يظهر بعد إتمام الدفع مع خيارات:
// - إرسال الفاتورة عبر واتساب
// - طباعة الإيصال
// - بدء بيع جديدة
import 'package:flutter/material.dart';
import 'package:alhai_design_system/alhai_design_system.dart';
import 'package:alhai_database/alhai_database.dart';
import 'package:get_it/get_it.dart';
import 'package:alhai_l10n/alhai_l10n.dart';
import 'package:alhai_shared_ui/alhai_shared_ui.dart' show CurrencyFormatter;
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
      duration: AlhaiMotion.durationExtraLong,
    );
    _scaleAnimation = CurvedAnimation(
      parent: _animController,
      curve: AlhaiMotion.spring,
    );
    _animController.forward();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.of(context).disableAnimations) {
      _animController.value = 1.0; // Skip to end state
    }
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
        SnackBar(
          content: Text(AppLocalizations.of(context)!.enterPhoneNumber),
          backgroundColor: AlhaiColors.warning,
        ),
      );
      return;
    }

    setState(() => _isSending = true);

    try {
      final db = GetIt.I<AppDatabase>();
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
            content: Text(
                AppLocalizations.of(context)!.whatsappSendError(e.toString())),
            backgroundColor: Theme.of(context).colorScheme.error,
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
          padding: const EdgeInsets.all(AlhaiSpacing.lg),
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
              const SizedBox(height: AlhaiSpacing.md),

              // العنوان
              Text(
                AppLocalizations.of(context)!.paymentSuccessful,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.success,
                ),
              ),
              const SizedBox(height: AlhaiSpacing.xs),

              // تفاصيل
              Text(
                widget.paymentMethodLabel,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: isDark ? Colors.white60 : AppColors.textMuted,
                ),
              ),
              const SizedBox(height: AlhaiSpacing.md),

              // المبلغ ورقم الفاتورة
              Container(
                padding: const EdgeInsets.all(AlhaiSpacing.md),
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
                          AppLocalizations.of(context)!.invoiceNumberTitle,
                          style: TextStyle(
                            color:
                                isDark ? Colors.white60 : AppColors.textMuted,
                          ),
                        ),
                        Text(
                          widget.receiptNumber,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                    const SizedBox(height: AlhaiSpacing.xs),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          AppLocalizations.of(context)!.amountPaidTitle,
                          style: TextStyle(
                            color:
                                isDark ? Colors.white60 : AppColors.textMuted,
                          ),
                        ),
                        Text(
                          CurrencyFormatter.formatWithContext(
                              context, widget.amount),
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
              const SizedBox(height: AlhaiSpacing.mdl),

              // قسم الواتساب
              Divider(color: isDark ? Colors.white12 : AppColors.grey200),
              const SizedBox(height: AlhaiSpacing.sm),

              Text(
                AppLocalizations.of(context)!.sendReceiptViaWhatsapp,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: AlhaiSpacing.xs),

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
                    horizontal: AlhaiSpacing.md,
                    vertical: AlhaiSpacing.sm,
                  ),
                  isDense: true,
                ),
              ),
              const SizedBox(height: AlhaiSpacing.xs),

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
                            color: AppColors.textOnPrimary,
                          ),
                        )
                      : Icon(
                          _sent ? Icons.check : Icons.send,
                          size: 18,
                        ),
                  label: Text(_sent
                      ? AppLocalizations.of(context)!.sentLabel
                      : AppLocalizations.of(context)!.sendWhatsapp),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.whatsappGreen,
                    foregroundColor: AppColors.textOnPrimary,
                    padding:
                        const EdgeInsets.symmetric(vertical: AlhaiSpacing.sm),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: AlhaiSpacing.mdl),

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
                        padding: const EdgeInsets.symmetric(
                            vertical: AlhaiSpacing.sm),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: AlhaiSpacing.sm),
                  // بيع جديدة
                  Expanded(
                    flex: 2,
                    child: FilledButton.icon(
                      onPressed: () {
                        Navigator.pop(context, PaymentSuccessAction.newSale);
                      },
                      icon: const Icon(Icons.add_shopping_cart, size: 18),
                      label: Text(AppLocalizations.of(context)!.newSaleButton),
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            vertical: AlhaiSpacing.sm),
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
