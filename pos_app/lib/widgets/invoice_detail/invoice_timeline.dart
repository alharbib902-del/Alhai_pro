import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../screens/invoices/invoice_detail_screen.dart';

class InvoiceTimeline extends StatelessWidget {
  final InvoiceDetailData invoice;
  final bool isDark;

  const InvoiceTimeline({super.key, required this.invoice, required this.isDark});

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
          Text(l10n.eventLog, style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: isDark ? Colors.white : AppColors.textPrimary)),
          const SizedBox(height: 20),
          // Timeline events
          _buildTimelineEvent(
            color: AppColors.success,
            title: l10n.paymentCompleted,
            subtitle: l10n.processedViaGateway,
            time: l10n.minutesAgo(30),
            isFirst: true,
            isLast: false,
          ),
          _buildTimelineEvent(
            color: AppColors.primary,
            title: l10n.invoiceCreated,
            subtitle: l10n.byUser(invoice.cashier),
            time: l10n.todayAt('14:30'),
            isFirst: false,
            isLast: false,
          ),
          _buildTimelineEvent(
            color: AppColors.textMuted,
            title: l10n.orderStarted,
            subtitle: l10n.cashierSessionOpened,
            time: l10n.todayAt('14:15'),
            isFirst: false,
            isLast: true,
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineEvent({
    required Color color,
    required String title,
    required String subtitle,
    required String time,
    required bool isFirst,
    required bool isLast,
  }) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Timeline line + dot
          SizedBox(
            width: 24,
            child: Column(
              children: [
                if (!isFirst)
                  Expanded(child: Container(width: 2, color: isDark ? Colors.white.withValues(alpha: 0.1) : AppColors.border)),
                Container(
                  width: 12, height: 12,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: color,
                    border: Border.all(color: isDark ? const Color(0xFF1E293B) : Colors.white, width: 2),
                  ),
                ),
                if (!isLast)
                  Expanded(child: Container(width: 2, color: isDark ? Colors.white.withValues(alpha: 0.1) : AppColors.border)),
              ],
            ),
          ),
          const SizedBox(width: 12),
          // Content
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: isDark ? Colors.white : AppColors.textPrimary)),
                  const SizedBox(height: 2),
                  Text(subtitle, style: TextStyle(fontSize: 11, color: isDark ? AppColors.textMutedDark : AppColors.textMuted)),
                  const SizedBox(height: 4),
                  Text(time, style: TextStyle(fontSize: 10, color: isDark ? AppColors.textMutedDark : AppColors.textMuted)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
