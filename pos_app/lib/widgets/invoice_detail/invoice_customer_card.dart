import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../screens/invoices/invoice_detail_screen.dart';

class InvoiceCustomerCard extends StatelessWidget {
  final InvoiceDetailData invoice;
  final bool isDark;

  const InvoiceCustomerCard({super.key, required this.invoice, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? Colors.white.withValues(alpha: 0.1) : AppColors.border),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(l10n.customerInfo, style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: isDark ? Colors.white : AppColors.textPrimary)),
              InkWell(
                onTap: () {},
                child: Text(l10n.editBtn, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.primary)),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Customer info row
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF0F172A) : AppColors.backgroundSecondary,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                // Avatar
                Container(
                  width: 48, height: 48,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.primary.withValues(alpha: 0.1),
                  ),
                  child: Center(child: Text(invoice.customerName.isNotEmpty ? invoice.customerName[0] : '?', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.primary))),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(invoice.customerName, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: isDark ? Colors.white : AppColors.textPrimary)),
                      const SizedBox(height: 2),
                      Text(l10n.vipSince(invoice.customerSince), style: TextStyle(fontSize: 11, color: isDark ? AppColors.textMutedDark : AppColors.textMuted)),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(color: AppColors.successLight, borderRadius: BorderRadius.circular(4)),
                            child: Text(l10n.activeStatus, style: const TextStyle(fontSize: 10, color: AppColors.success, fontWeight: FontWeight.w600)),
                          ),
                          const SizedBox(width: 8),
                          Text('ID: ${invoice.customerId}', style: TextStyle(fontSize: 11, color: isDark ? AppColors.textMutedDark : AppColors.textMuted, fontFamily: 'Source Code Pro')),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          // Action buttons row
          Row(
            children: [
              Expanded(
                child: _actionButton(Icons.phone_rounded, l10n.callBtn, isDark),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _actionButton(Icons.description_outlined, l10n.recordBtn, isDark),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _actionButton(IconData icon, String label, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: isDark ? Colors.white.withValues(alpha: 0.1) : AppColors.border),
      ),
      child: Column(
        children: [
          Icon(icon, size: 16, color: isDark ? Colors.white : AppColors.textPrimary),
          const SizedBox(height: 4),
          Text(label, style: TextStyle(fontSize: 11, color: isDark ? Colors.white : AppColors.textPrimary)),
        ],
      ),
    );
  }
}
