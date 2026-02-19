import 'package:pos_app/widgets/common/adaptive_icon.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../widgets/layout/app_header.dart';

/// شاشة التوافق مع ZATCA
class ZatcaComplianceScreen extends ConsumerStatefulWidget {
  const ZatcaComplianceScreen({super.key});

  @override
  ConsumerState<ZatcaComplianceScreen> createState() => _ZatcaComplianceScreenState();
}

class _ZatcaComplianceScreenState extends ConsumerState<ZatcaComplianceScreen> {
  bool _eInvoicingEnabled = true;
  bool _qrCodeEnabled = true;
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isWideScreen = size.width > 900;
    final isMediumScreen = size.width > 600;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;

    return Column(children: [
          AppHeader(
            title: l10n.zatcaCompliance,
            onMenuTap: isWideScreen
                      ? null
                      : () => Scaffold.of(context).openDrawer(),
            onNotificationsTap: () => context.push('/notifications'),
            notificationsCount: 3, userName: l10n.defaultUserName, userRole: l10n.branchManager,
          ),
          Expanded(child: SingleChildScrollView(
            padding: EdgeInsets.all(isMediumScreen ? 24 : 16),
            child: _buildContent(isDark, l10n),
          )),
        ]);
  }
  Widget _buildContent(bool isDark, AppLocalizations l10n) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      // Status
      Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.success.withValues(alpha: isDark ? 0.15 : 0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.success.withValues(alpha: 0.3)),
        ),
        child: Row(children: [
          const Icon(Icons.verified_rounded, color: AppColors.success, size: 24),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(l10n.zatcaRegistered, style: const TextStyle(color: AppColors.success, fontWeight: FontWeight.bold)),
            Text(l10n.zatcaPhase2Active, style: TextStyle(color: AppColors.success.withValues(alpha: 0.8), fontSize: 12)),
          ])),
        ]),
      ),

      const SizedBox(height: 24),

      // Registration info
      _buildGroup(l10n.registrationInfo, [
        _tile(Icons.badge_rounded, l10n.taxNumber, '300123456789003', isDark),
        _tile(Icons.business_rounded, l10n.businessName, l10n.businessNameValue, isDark),
        _tile(Icons.location_on_rounded, l10n.branchCode, 'BR-001', isDark),
      ], isDark),

      // E-invoicing
      _buildGroup(l10n.eInvoicing, [
        SwitchListTile(
          secondary: Container(padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
            child: const Icon(Icons.description_rounded, color: AppColors.primary, size: 20)),
          title: Text(l10n.eInvoicing, style: TextStyle(color: isDark ? Colors.white : AppColors.textPrimary, fontWeight: FontWeight.w500)),
          subtitle: Text(_eInvoicingEnabled ? l10n.enabled : l10n.disabled,
            style: TextStyle(color: isDark ? Colors.white.withValues(alpha: 0.5) : AppColors.textSecondary, fontSize: 12)),
          value: _eInvoicingEnabled, onChanged: (v) => setState(() => _eInvoicingEnabled = v),
        ),
      ], isDark),

      // QR code
      _buildGroup(l10n.qrCode, [
        SwitchListTile(
          secondary: Container(padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
            child: const Icon(Icons.qr_code_rounded, color: AppColors.primary, size: 20)),
          title: Text(l10n.qrCodeOnInvoice, style: TextStyle(color: isDark ? Colors.white : AppColors.textPrimary, fontWeight: FontWeight.w500)),
          subtitle: Text(_qrCodeEnabled ? l10n.qrCodeOnInvoice : l10n.disabledLabel,
            style: TextStyle(color: isDark ? Colors.white.withValues(alpha: 0.5) : AppColors.textSecondary, fontSize: 12)),
          value: _qrCodeEnabled, onChanged: (v) => setState(() => _qrCodeEnabled = v),
        ),
      ], isDark),

      // Certificates
      _buildGroup(l10n.certificates, [
        _tile(Icons.security_rounded, l10n.csidCertificate, l10n.valid, isDark,
            trailing: const Icon(Icons.check_circle_rounded, color: AppColors.success)),
        _tile(Icons.key_rounded, l10n.privateKey, l10n.configured, isDark,
            trailing: const Icon(Icons.check_circle_rounded, color: AppColors.success)),
      ], isDark),
    ]);
  }

  Widget _buildGroup(String title, List<Widget> children, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? Colors.white.withValues(alpha: 0.1) : AppColors.border),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Padding(padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
          child: Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : AppColors.textPrimary))),
        ...children,
      ]),
    );
  }

  Widget _tile(IconData icon, String title, String? subtitle, bool isDark, {Widget? trailing}) {
    return ListTile(
      leading: Container(padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
        child: Icon(icon, color: AppColors.primary, size: 20)),
      title: Text(title, style: TextStyle(color: isDark ? Colors.white : AppColors.textPrimary, fontWeight: FontWeight.w500)),
      subtitle: subtitle != null ? Text(subtitle, style: TextStyle(
          color: isDark ? Colors.white.withValues(alpha: 0.5) : AppColors.textSecondary, fontSize: 12)) : null,
      trailing: trailing ?? AdaptiveIcon(Icons.chevron_left_rounded,
          color: isDark ? Colors.white.withValues(alpha: 0.3) : AppColors.textTertiary),
    );
  }
}
