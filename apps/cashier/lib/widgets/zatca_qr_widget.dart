import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:alhai_l10n/alhai_l10n.dart';
import 'package:alhai_shared_ui/alhai_shared_ui.dart';
import 'package:alhai_design_system/alhai_design_system.dart' show AlhaiSpacing;

import '../core/services/zatca/zatca_qr_service.dart';

/// ويدجت عرض QR Code متوافق مع ZATCA
///
/// يعرض QR Code مع بيانات الفاتورة الضريبية وفق معيار ZATCA
class ZatcaQrWidget extends StatelessWidget {
  final String sellerName;
  final String? vatNumber;
  final DateTime timestamp;
  final double totalWithVat;
  final double vatAmount;
  final double size;

  const ZatcaQrWidget({
    super.key,
    required this.sellerName,
    required this.vatNumber,
    required this.timestamp,
    required this.totalWithVat,
    required this.vatAmount,
    this.size = 140,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final vat = vatNumber;
    if (vat == null || !ZatcaQrService.isValidVatNumber(vat)) {
      return _buildMissingVatCard(context, isDark);
    }
    final qrData = ZatcaQrService.generateQrData(
      sellerName: sellerName,
      vatNumber: vat,
      timestamp: timestamp,
      totalWithVat: totalWithVat,
      vatAmount: vatAmount,
    );

    return Semantics(
      label: 'ZATCA QR Code - $sellerName',
      image: true,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(AlhaiSpacing.sm),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.getBorder(isDark)),
            ),
            child: QrImageView(
              data: qrData,
              version: QrVersions.auto,
              size: size,
              backgroundColor: Colors.white,
              eyeStyle: const QrEyeStyle(
                eyeShape: QrEyeShape.square,
                color: Color(0xFF1A1A2E),
              ),
              dataModuleStyle: const QrDataModuleStyle(
                dataModuleShape: QrDataModuleShape.square,
                color: Color(0xFF1A1A2E),
              ),
            ),
          ),
          const SizedBox(height: AlhaiSpacing.xs),
          Text(
            'ZATCA E-Invoice',
            style: TextStyle(
              fontSize: 10,
              color: AppColors.getTextMuted(isDark),
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            ZatcaQrService.formatVatNumber(vat),
            style: TextStyle(
              fontSize: 9,
              color: AppColors.getTextMuted(isDark),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMissingVatCard(BuildContext context, bool isDark) {
    final l10n = AppLocalizations.of(context);
    final isRtl = Directionality.of(context) == TextDirection.rtl;
    final mutedStyle = TextStyle(
      fontSize: 11,
      color: AppColors.getTextMuted(isDark),
    );

    return Container(
      padding: const EdgeInsets.all(AlhaiSpacing.md),
      constraints: BoxConstraints(minWidth: size, minHeight: size),
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.warning.withValues(alpha: 0.12)
            : AppColors.warningSurface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.warning.withValues(alpha: 0.4),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.gpp_bad_outlined,
            size: 32,
            color: AppColors.warning,
          ),
          const SizedBox(height: AlhaiSpacing.xs),
          Text(
            l10n.vatNumberMissing,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.getTextPrimary(isDark),
            ),
          ),
          const SizedBox(height: AlhaiSpacing.xs),
          Semantics(
            container: true,
            label: '${l10n.settings}, ${l10n.taxSettings}',
            excludeSemantics: true,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(l10n.settings, style: mutedStyle),
                const SizedBox(width: 4),
                Icon(
                  isRtl ? Icons.chevron_left : Icons.chevron_right,
                  size: 14,
                  color: AppColors.getTextMuted(isDark),
                ),
                const SizedBox(width: 4),
                Text(l10n.taxSettings, style: mutedStyle),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
