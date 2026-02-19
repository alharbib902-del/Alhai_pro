/// حوار إرسال توصية عبر واتساب - WhatsApp Recommendation Dialog
///
/// حوار لإرسال عرض عبر واتساب مع إدخال الهاتف ومعاينة الرسالة
library;

import 'package:pos_app/widgets/common/adaptive_icon.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/theme/app_colors.dart';

/// حوار إرسال التوصية عبر واتساب
class WhatsAppRecommendationDialog extends StatefulWidget {
  final String customerName;
  final String productName;
  final String? initialPhone;
  final double? price;
  final String? offerMessage;

  const WhatsAppRecommendationDialog({
    super.key,
    required this.customerName,
    required this.productName,
    this.initialPhone,
    this.price,
    this.offerMessage,
  });

  /// عرض الحوار
  static Future<void> show(
    BuildContext context, {
    required String customerName,
    required String productName,
    String? initialPhone,
    double? price,
    String? offerMessage,
  }) {
    return showDialog(
      context: context,
      builder: (context) => WhatsAppRecommendationDialog(
        customerName: customerName,
        productName: productName,
        initialPhone: initialPhone,
        price: price,
        offerMessage: offerMessage,
      ),
    );
  }

  @override
  State<WhatsAppRecommendationDialog> createState() => _WhatsAppRecommendationDialogState();
}

class _WhatsAppRecommendationDialogState extends State<WhatsAppRecommendationDialog> {
  late TextEditingController _phoneController;
  late TextEditingController _messageController;
  bool _isSending = false;

  @override
  void initState() {
    super.initState();
    _phoneController = TextEditingController(text: widget.initialPhone ?? '');
    _messageController = TextEditingController(text: _buildDefaultMessage());
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  String _buildDefaultMessage() {
    final priceText = widget.price != null
        ? ' بسعر ${widget.price!.toStringAsFixed(1)} ر.س'
        : '';
    final offerText = widget.offerMessage ?? 'عرض خاص لك!'; // Special offer for you!

    return 'مرحباً ${widget.customerName}! 👋\n\n'
        '$offerText\n\n'
        'نود أن نذكرك بمنتج ${widget.productName}$priceText\n\n'
        'تفضل بزيارتنا للاستفادة من العرض! 🛒\n\n'
        'شكراً لتسوقك معنا 💚'; // Thank you for shopping with us
  }

  Future<void> _sendWhatsApp() async {
    final phone = _phoneController.text.trim();
    if (phone.isEmpty) return;

    setState(() => _isSending = true);

    final message = Uri.encodeComponent(_messageController.text);
    final cleanPhone = phone.replaceAll(RegExp(r'[^0-9+]'), '');
    final url = Uri.parse('https://wa.me/$cleanPhone?text=$message');

    try {
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
        if (mounted) Navigator.of(context).pop(true);
      }
    } catch (_) {
      // Handle error silently
    } finally {
      if (mounted) setState(() => _isSending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFF25D366).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.message_rounded,
                      color: Color(0xFF25D366),
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'إرسال توصية واتساب', // Send WhatsApp Recommendation
                          style: TextStyle(
                            color: isDark ? Colors.white : AppColors.textPrimary,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          widget.customerName,
                          style: TextStyle(
                            color: isDark ? Colors.white.withValues(alpha: 0.5) : AppColors.textMuted,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(
                      Icons.close_rounded,
                      color: isDark ? Colors.white.withValues(alpha: 0.5) : AppColors.textMuted,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // Phone input
              Text(
                'رقم الهاتف', // Phone Number
                style: TextStyle(
                  color: isDark ? Colors.white.withValues(alpha: 0.7) : AppColors.textSecondary,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 6),
              TextField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                textDirection: TextDirection.ltr,
                style: TextStyle(
                  color: isDark ? Colors.white : AppColors.textPrimary,
                  fontSize: 14,
                ),
                decoration: InputDecoration(
                  hintText: '+966XXXXXXXXX',
                  hintStyle: TextStyle(
                    color: isDark ? Colors.white.withValues(alpha: 0.3) : AppColors.textMuted,
                  ),
                  prefixIcon: const Icon(Icons.phone_rounded, color: AppColors.primary, size: 20),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: isDark ? Colors.white.withValues(alpha: 0.1) : AppColors.border,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: isDark ? Colors.white.withValues(alpha: 0.1) : AppColors.border,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFF25D366)),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  filled: true,
                  fillColor: isDark ? Colors.white.withValues(alpha: 0.05) : AppColors.grey50,
                ),
              ),

              const SizedBox(height: 16),

              // Message preview
              Text(
                'معاينة الرسالة', // Message Preview
                style: TextStyle(
                  color: isDark ? Colors.white.withValues(alpha: 0.7) : AppColors.textSecondary,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 6),
              TextField(
                controller: _messageController,
                maxLines: 6,
                style: TextStyle(
                  color: isDark ? Colors.white : AppColors.textPrimary,
                  fontSize: 13,
                  height: 1.5,
                ),
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: isDark ? Colors.white.withValues(alpha: 0.1) : AppColors.border,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: isDark ? Colors.white.withValues(alpha: 0.1) : AppColors.border,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFF25D366)),
                  ),
                  contentPadding: const EdgeInsets.all(12),
                  filled: true,
                  fillColor: isDark ? Colors.white.withValues(alpha: 0.05) : AppColors.grey50,
                ),
              ),

              const SizedBox(height: 20),

              // Send button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _isSending ? null : _sendWhatsApp,
                  icon: _isSending
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const AdaptiveIcon(Icons.send_rounded, size: 18),
                  label: Text(
                    _isSending ? 'جاري الإرسال...' : 'إرسال عبر واتساب', // Sending... / Send via WhatsApp
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF25D366),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
