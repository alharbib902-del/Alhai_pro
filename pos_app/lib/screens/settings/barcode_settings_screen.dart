import 'package:pos_app/widgets/common/adaptive_icon.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../widgets/layout/app_header.dart';

/// شاشة إعدادات الباركود والماسح الضوئي
class BarcodeSettingsScreen extends ConsumerStatefulWidget {
  const BarcodeSettingsScreen({super.key});

  @override
  ConsumerState<BarcodeSettingsScreen> createState() =>
      _BarcodeSettingsScreenState();
}

class _BarcodeSettingsScreenState extends ConsumerState<BarcodeSettingsScreen> {
  bool _enableBarcodeScanner = true;
  bool _enableCameraScanner = true;
  bool _enableBluetoothScanner = false;
  bool _beepOnScan = true;
  bool _vibrateOnScan = false;
  bool _autoAddToCart = true;
  String _barcodeFormat = 'all';

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isWideScreen = size.width > 900;
    final isMediumScreen = size.width > 600;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;

    return Column(
      children: [
        AppHeader(
          title: l10n.barcodeSettings,
          onMenuTap: isWideScreen ? null : () => Scaffold.of(context).openDrawer(),
          onNotificationsTap: () => context.push('/notifications'),
          notificationsCount: 3,
          userName: l10n.defaultUserName,
          userRole: l10n.branchManager,
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(isMediumScreen ? 24 : 16),
            child: _buildContent(isDark, l10n),
          ),
        ),
      ],
    );
  }

  Widget _buildContent(bool isDark, AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildPageHeader(isDark, l10n),
        const SizedBox(height: 20),

        // Scanner activation
        _buildSettingsGroup(l10n.enableScanner, Icons.qr_code_scanner_rounded,
            const Color(0xFFF59E0B), isDark, [
          SwitchListTile(
            title: Text(l10n.barcodeScanner,
                style: TextStyle(
                    color: isDark ? Colors.white : AppColors.textPrimary)),
            subtitle: Text(l10n.barcodeScannerDesc),
            secondary: const Icon(Icons.qr_code_scanner),
            value: _enableBarcodeScanner,
            onChanged: (v) => setState(() => _enableBarcodeScanner = v),
          ),
          if (_enableBarcodeScanner) ...[
            const Divider(indent: 16, endIndent: 16),
            SwitchListTile(
              title: Text(l10n.deviceCamera,
                  style: TextStyle(
                      color: isDark ? Colors.white : AppColors.textPrimary)),
              secondary: const Icon(Icons.camera_alt),
              value: _enableCameraScanner,
              onChanged: (v) => setState(() => _enableCameraScanner = v),
            ),
            SwitchListTile(
              title: Text(l10n.bluetoothScanner,
                  style: TextStyle(
                      color: isDark ? Colors.white : AppColors.textPrimary)),
              subtitle: Text(l10n.externalScannerConnected),
              secondary: const Icon(Icons.bluetooth),
              value: _enableBluetoothScanner,
              onChanged: (v) => setState(() => _enableBluetoothScanner = v),
            ),
          ],
          const SizedBox(height: 8),
        ]),

        // Feedback settings
        _buildSettingsGroup(
            l10n.alerts, Icons.notifications_active_rounded,
            AppColors.info, isDark, [
          SwitchListTile(
            title: Text(l10n.beepOnScan,
                style: TextStyle(
                    color: isDark ? Colors.white : AppColors.textPrimary)),
            secondary: const Icon(Icons.volume_up),
            value: _beepOnScan,
            onChanged: (v) => setState(() => _beepOnScan = v),
          ),
          SwitchListTile(
            title: Text(l10n.vibrateOnScan,
                style: TextStyle(
                    color: isDark ? Colors.white : AppColors.textPrimary)),
            secondary: const Icon(Icons.vibration),
            value: _vibrateOnScan,
            onChanged: (v) => setState(() => _vibrateOnScan = v),
          ),
          const SizedBox(height: 8),
        ]),

        // Behavior settings
        _buildSettingsGroup(l10n.behavior, Icons.tune_rounded,
            AppColors.success, isDark, [
          SwitchListTile(
            title: Text(l10n.autoAddToCart,
                style: TextStyle(
                    color: isDark ? Colors.white : AppColors.textPrimary)),
            subtitle: Text(l10n.autoAddToCartDesc),
            secondary: const Icon(Icons.add_shopping_cart),
            value: _autoAddToCart,
            onChanged: (v) => setState(() => _autoAddToCart = v),
          ),
          const Divider(indent: 16, endIndent: 16),
          ListTile(
            leading: const Icon(Icons.format_list_numbered),
            title: Text(l10n.barcodeFormats,
                style: TextStyle(
                    color: isDark ? Colors.white : AppColors.textPrimary)),
            subtitle: Text(_getBarcodeFormatName(l10n)),
            trailing: const AdaptiveIcon(Icons.chevron_right),
            onTap: _showBarcodeFormatPicker,
          ),
          const SizedBox(height: 8),
        ]),

        // Test scanner
        _buildSettingsGroup(l10n.testing, Icons.bug_report_rounded,
            AppColors.primary, isDark, [
          ListTile(
            leading: const Icon(Icons.bug_report, color: AppColors.primary),
            title: Text(l10n.testScanner,
                style: TextStyle(
                    color: isDark ? Colors.white : AppColors.textPrimary)),
            subtitle: Text(l10n.testScanBarcode),
            trailing: const AdaptiveIcon(Icons.chevron_right),
            onTap: _testScanner,
          ),
          const SizedBox(height: 8),
        ]),
      ],
    );
  }

  Widget _buildPageHeader(bool isDark, AppLocalizations l10n) {
    return Row(
      children: [
        IconButton(
          onPressed: () => context.pop(),
          icon: Icon(Icons.arrow_back_rounded,
              color: isDark ? Colors.white : AppColors.textPrimary),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: const Color(0xFFF59E0B).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(Icons.qr_code_scanner_rounded,
              color: Color(0xFFF59E0B), size: 24),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.barcodeSettings,
                style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : AppColors.textPrimary)),
            Text(l10n.barcodeSettingsSubtitle,
                style: TextStyle(
                    fontSize: 13,
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.5)
                        : AppColors.textSecondary)),
          ],
        ),
      ],
    );
  }

  Widget _buildSettingsGroup(String title, IconData icon, Color color,
      bool isDark, List<Widget> children) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.1)
              : AppColors.border,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: color, size: 20),
                ),
                const SizedBox(width: 12),
                Text(title,
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color:
                            isDark ? Colors.white : AppColors.textPrimary)),
              ],
            ),
          ),
          ...children,
        ],
      ),
    );
  }

  String _getBarcodeFormatName(AppLocalizations l10n) {
    switch (_barcodeFormat) {
      case 'all':
        return l10n.allFormats;
      case 'ean':
        return 'EAN-8, EAN-13';
      case 'upc':
        return 'UPC-A, UPC-E';
      case 'qr':
        return 'QR Code';
      default:
        return l10n.unspecified;
    }
  }

  void _showBarcodeFormatPicker() {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.barcodeFormats),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<String>(
              title: Text(l10n.allFormats),
              value: 'all',
              // ignore: deprecated_member_use
              groupValue: _barcodeFormat,
              // ignore: deprecated_member_use
              onChanged: (v) {
                setState(() => _barcodeFormat = v!);
                Navigator.pop(ctx);
              },
            ),
            RadioListTile<String>(
              title: const Text('EAN-8, EAN-13'),
              value: 'ean',
              // ignore: deprecated_member_use
              groupValue: _barcodeFormat,
              // ignore: deprecated_member_use
              onChanged: (v) {
                setState(() => _barcodeFormat = v!);
                Navigator.pop(ctx);
              },
            ),
            RadioListTile<String>(
              title: const Text('UPC-A, UPC-E'),
              value: 'upc',
              // ignore: deprecated_member_use
              groupValue: _barcodeFormat,
              // ignore: deprecated_member_use
              onChanged: (v) {
                setState(() => _barcodeFormat = v!);
                Navigator.pop(ctx);
              },
            ),
            RadioListTile<String>(
              title: Text(l10n.qrCodeOnly),
              value: 'qr',
              // ignore: deprecated_member_use
              groupValue: _barcodeFormat,
              // ignore: deprecated_member_use
              onChanged: (v) {
                setState(() => _barcodeFormat = v!);
                Navigator.pop(ctx);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _testScanner() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;
    showModalBottomSheet(
      context: context,
      builder: (ctx) => Container(
        height: 400,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E293B) : Colors.white,
          borderRadius:
              const BorderRadius.vertical(top: Radius.circular(16)),
        ),
        child: Column(
          children: [
            Icon(Icons.qr_code_scanner,
                size: 64,
                color: isDark ? Colors.white70 : AppColors.primary),
            const SizedBox(height: 16),
            Text(l10n.pointCameraAtBarcode,
                style: TextStyle(
                    fontSize: 18,
                    color: isDark ? Colors.white : AppColors.textPrimary)),
            const SizedBox(height: 24),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.05)
                      : Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(l10n.scanArea,
                      style: TextStyle(
                          color: isDark ? Colors.white38 : Colors.grey)),
                ),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () => Navigator.pop(ctx),
                child: Text(l10n.cancel),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
