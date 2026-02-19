import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../l10n/generated/app_localizations.dart';

class InvoiceTechnicalData extends StatelessWidget {
  final bool isDark;

  const InvoiceTechnicalData({super.key, required this.isDark});

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
          Text(l10n.technicalData, style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: isDark ? Colors.white : AppColors.textPrimary)),
          const SizedBox(height: 16),
          _dataRow(l10n.deviceIdLabel, 'POS-01-KSA'),
          const SizedBox(height: 12),
          _dataRow(l10n.terminalLabel, 'T-8823'),
          const SizedBox(height: 12),
          _dataRow(l10n.softwareVersion, 'v2.4.1'),
        ],
      ),
    );
  }

  Widget _dataRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(fontSize: 12, color: isDark ? AppColors.textMutedDark : AppColors.textMuted)),
        Text(value, style: TextStyle(fontSize: 12, fontFamily: 'Source Code Pro', color: isDark ? Colors.white : AppColors.textPrimary)),
      ],
    );
  }
}
