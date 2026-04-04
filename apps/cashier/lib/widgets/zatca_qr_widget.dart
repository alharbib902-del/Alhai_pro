import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:alhai_shared_ui/alhai_shared_ui.dart';
import 'package:alhai_design_system/alhai_design_system.dart' show AlhaiSpacing;

import '../services/zatca/zatca_qr_service.dart';

/// ويدجت عرض QR Code متوافق مع ZATCA
///
/// يعرض QR Code مع بيانات الفاتورة الضريبية وفق معيار ZATCA
class ZatcaQrWidget extends StatelessWidget {
  final String sellerName;
  final String vatNumber;
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
    final qrData = ZatcaQrService.generateQrData(
      sellerName: sellerName,
      vatNumber: vatNumber,
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
            border: Border.all(
              color: AppColors.getBorder(isDark),
            ),
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
        if (ZatcaQrService.isValidVatNumber(vatNumber))
          Text(
            ZatcaQrService.formatVatNumber(vatNumber),
            style: TextStyle(
              fontSize: 9,
              color: AppColors.getTextMuted(isDark),
            ),
          ),
        ],
      ),
    );
  }
}
