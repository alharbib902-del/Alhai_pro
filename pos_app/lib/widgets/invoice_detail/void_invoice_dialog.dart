import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../l10n/generated/app_localizations.dart';

class VoidInvoiceDialog extends StatefulWidget {
  final VoidCallback onConfirm;

  const VoidInvoiceDialog({super.key, required this.onConfirm});

  @override
  State<VoidInvoiceDialog> createState() => _VoidInvoiceDialogState();
}

class _VoidInvoiceDialogState extends State<VoidInvoiceDialog> {
  String _selectedReason = 'entry';

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;

    return Dialog(
      backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: 400,
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Warning icon
            Container(
              width: 64, height: 64,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isDark ? AppColors.error.withValues(alpha: 0.15) : AppColors.errorLight,
              ),
              child: const Icon(Icons.block_rounded, size: 32, color: AppColors.error),
            ),
            const SizedBox(height: 16),
            Text(l10n.voidInvoiceConfirm, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: isDark ? Colors.white : AppColors.textPrimary)),
            const SizedBox(height: 8),
            Text(l10n.voidInvoiceMsg, textAlign: TextAlign.center, style: TextStyle(fontSize: 13, color: isDark ? AppColors.textMutedDark : AppColors.textMuted)),
            const SizedBox(height: 20),
            // Reason dropdown
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l10n.voidReasonLabel, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: isDark ? Colors.white : AppColors.textPrimary)),
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF0F172A) : AppColors.backgroundSecondary,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: isDark ? Colors.white.withValues(alpha: 0.1) : AppColors.border),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _selectedReason,
                      isExpanded: true,
                      dropdownColor: isDark ? const Color(0xFF1E293B) : Colors.white,
                      style: TextStyle(fontSize: 13, color: isDark ? Colors.white : AppColors.textPrimary),
                      items: [
                        DropdownMenuItem(value: 'entry', child: Text(l10n.voidReasonEntry)),
                        DropdownMenuItem(value: 'customer', child: Text(l10n.voidReasonCustomer)),
                        DropdownMenuItem(value: 'damaged', child: Text(l10n.voidReasonDamaged)),
                        DropdownMenuItem(value: 'other', child: Text(l10n.voidReasonOther)),
                      ],
                      onChanged: (v) => setState(() => _selectedReason = v ?? 'entry'),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            // Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      side: BorderSide(color: isDark ? Colors.white.withValues(alpha: 0.1) : AppColors.border),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      foregroundColor: isDark ? Colors.white : AppColors.textPrimary,
                    ),
                    child: Text(l10n.cancel),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton(
                    onPressed: widget.onConfirm,
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      backgroundColor: AppColors.error,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 4,
                      shadowColor: AppColors.error.withValues(alpha: 0.3),
                    ),
                    child: Text(l10n.confirmVoid),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
