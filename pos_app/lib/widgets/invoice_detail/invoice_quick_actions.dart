import 'package:flutter/material.dart';
import '../../core/responsive/responsive_utils.dart';
import '../../core/theme/app_colors.dart';
import '../../l10n/generated/app_localizations.dart';

class InvoiceQuickActions extends StatelessWidget {
  final bool isDark;
  final VoidCallback? onWhatsApp;
  final VoidCallback? onEmail;
  final VoidCallback? onDownloadPdf;
  final VoidCallback? onShareLink;

  const InvoiceQuickActions({
    super.key,
    required this.isDark,
    this.onWhatsApp,
    this.onEmail,
    this.onDownloadPdf,
    this.onShareLink,
  });

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
          Text(l10n.quickActions, style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: isDark ? Colors.white : AppColors.textPrimary)),
          const SizedBox(height: 16),
          GridView.count(
            crossAxisCount: getResponsiveGridColumns(context, mobile: 2, desktop: 3),
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.6,
            children: [
              _actionTile(Icons.message_rounded, l10n.sendWhatsappAction, const Color(0xFF25D366), isDark, onWhatsApp),
              _actionTile(Icons.email_outlined, l10n.sendEmailAction, AppColors.info, isDark, onEmail),
              _actionTile(Icons.picture_as_pdf_rounded, l10n.downloadPdfAction, AppColors.error, isDark, onDownloadPdf),
              _actionTile(Icons.share_rounded, l10n.shareLinkAction, const Color(0xFF8B5CF6), isDark, onShareLink),
            ],
          ),
        ],
      ),
    );
  }

  Widget _actionTile(IconData icon, String label, Color iconColor, bool isDark, VoidCallback? onTap) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF0F172A) : AppColors.backgroundSecondary,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: isDark ? Colors.white.withValues(alpha: 0.1) : AppColors.border),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 28, color: iconColor),
              const SizedBox(height: 8),
              Text(label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: isDark ? Colors.white : AppColors.textPrimary), textAlign: TextAlign.center, maxLines: 1, overflow: TextOverflow.ellipsis),
            ],
          ),
        ),
      ),
    );
  }
}
