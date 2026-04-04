import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:alhai_shared_ui/alhai_shared_ui.dart';
import 'package:alhai_l10n/alhai_l10n.dart';
import 'package:alhai_database/alhai_database.dart';
import 'package:alhai_core/alhai_core.dart';
import '../../../providers/settings_db_providers.dart';
import 'package:alhai_design_system/alhai_design_system.dart';

// مفاتيح إعدادات الباركود
const String _kEnableBarcodeScanner = 'barcode_enable_scanner';
const String _kEnableCameraScanner = 'barcode_enable_camera';
const String _kEnableBluetoothScanner = 'barcode_enable_bluetooth';
const String _kBeepOnScan = 'barcode_beep_on_scan';
const String _kVibrateOnScan = 'barcode_vibrate_on_scan';
const String _kAutoAddToCart = 'barcode_auto_add_to_cart';
const String _kBarcodeFormat = 'barcode_format';

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
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  /// تحميل الإعدادات من قاعدة البيانات
  Future<void> _loadSettings() async {
    try {
      final storeId = ref.read(currentStoreIdProvider);
      if (storeId == null) {
        if (mounted) setState(() => _isLoading = false);
        return;
      }

      final db = getIt<AppDatabase>();
      final settings = await getSettingsByPrefix(db, storeId, 'barcode_');

      if (mounted) {
        setState(() {
          _enableBarcodeScanner = settings[_kEnableBarcodeScanner] != 'false';
          _enableCameraScanner = settings[_kEnableCameraScanner] != 'false';
          _enableBluetoothScanner =
              settings[_kEnableBluetoothScanner] == 'true';
          _beepOnScan = settings[_kBeepOnScan] != 'false';
          _vibrateOnScan = settings[_kVibrateOnScan] == 'true';
          _autoAddToCart = settings[_kAutoAddToCart] != 'false';
          _barcodeFormat = settings[_kBarcodeFormat] ?? 'all';
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  /// حفظ جميع إعدادات الباركود في قاعدة البيانات مع المزامنة
  Future<void> _saveAllSettings() async {
    final storeId = ref.read(currentStoreIdProvider);
    if (storeId == null) return;

    final db = getIt<AppDatabase>();
    try {
      await saveSettingsBatch(
        db: db,
        storeId: storeId,
        settings: {
          _kEnableBarcodeScanner: _enableBarcodeScanner.toString(),
          _kEnableCameraScanner: _enableCameraScanner.toString(),
          _kEnableBluetoothScanner: _enableBluetoothScanner.toString(),
          _kBeepOnScan: _beepOnScan.toString(),
          _kVibrateOnScan: _vibrateOnScan.toString(),
          _kAutoAddToCart: _autoAddToCart.toString(),
          _kBarcodeFormat: _barcodeFormat,
        },
        ref: ref,
      );
      if (mounted) {
        final l10n = AppLocalizations.of(context);
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.settingsSaved),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 1),
          ),
        );
      }
    } catch (e) {
      // الحفظ في الخلفية - لا نعرض خطأ
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isWideScreen = size.width > 900;
    final isMediumScreen = size.width > 600;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context);

    if (_isLoading) {
      return SafeArea(
          child: Column(
        children: [
          AppHeader(
            title: l10n.barcodeSettings,
            onMenuTap:
                isWideScreen ? null : () => Scaffold.of(context).openDrawer(),
            onNotificationsTap: () => context.push('/notifications'),
            notificationsCount: 3,
            userName: l10n.defaultUserName,
            userRole: l10n.branchManager,
          ),
          const Expanded(
            child: Center(child: CircularProgressIndicator()),
          ),
        ],
      ));
    }

    return SafeArea(
        child: Column(
      children: [
        AppHeader(
          title: l10n.barcodeSettings,
          onMenuTap:
              isWideScreen ? null : () => Scaffold.of(context).openDrawer(),
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
    ));
  }

  Widget _buildContent(bool isDark, AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildPageHeader(isDark, l10n),
        const SizedBox(height: AlhaiSpacing.mdl),

        // Scanner activation
        _buildSettingsGroup(l10n.enableScanner, Icons.qr_code_scanner_rounded,
            const Color(0xFFF59E0B), isDark, [
          SwitchListTile(
            title: Text(l10n.barcodeScanner,
                style:
                    TextStyle(color: Theme.of(context).colorScheme.onSurface)),
            subtitle: Text(l10n.barcodeScannerDesc),
            secondary: const Icon(Icons.qr_code_scanner),
            value: _enableBarcodeScanner,
            onChanged: (v) {
              setState(() => _enableBarcodeScanner = v);
              _saveAllSettings();
            },
          ),
          if (_enableBarcodeScanner) ...[
            const Divider(indent: 16, endIndent: 16),
            SwitchListTile(
              title: Text(l10n.deviceCamera,
                  style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface)),
              secondary: const Icon(Icons.camera_alt),
              value: _enableCameraScanner,
              onChanged: (v) {
                setState(() => _enableCameraScanner = v);
                _saveAllSettings();
              },
            ),
            SwitchListTile(
              title: Text(l10n.bluetoothScanner,
                  style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface)),
              subtitle: Text(l10n.externalScannerConnected),
              secondary: const Icon(Icons.bluetooth),
              value: _enableBluetoothScanner,
              onChanged: (v) {
                setState(() => _enableBluetoothScanner = v);
                _saveAllSettings();
              },
            ),
          ],
          const SizedBox(height: AlhaiSpacing.xs),
        ]),

        // Feedback settings
        _buildSettingsGroup(l10n.alerts, Icons.notifications_active_rounded,
            AppColors.info, isDark, [
          SwitchListTile(
            title: Text(l10n.beepOnScan,
                style:
                    TextStyle(color: Theme.of(context).colorScheme.onSurface)),
            secondary: const Icon(Icons.volume_up),
            value: _beepOnScan,
            onChanged: (v) {
              setState(() => _beepOnScan = v);
              _saveAllSettings();
            },
          ),
          SwitchListTile(
            title: Text(l10n.vibrateOnScan,
                style:
                    TextStyle(color: Theme.of(context).colorScheme.onSurface)),
            secondary: const Icon(Icons.vibration),
            value: _vibrateOnScan,
            onChanged: (v) {
              setState(() => _vibrateOnScan = v);
              _saveAllSettings();
            },
          ),
          const SizedBox(height: AlhaiSpacing.xs),
        ]),

        // Behavior settings
        _buildSettingsGroup(
            l10n.behavior, Icons.tune_rounded, AppColors.success, isDark, [
          SwitchListTile(
            title: Text(l10n.autoAddToCart,
                style:
                    TextStyle(color: Theme.of(context).colorScheme.onSurface)),
            subtitle: Text(l10n.autoAddToCartDesc),
            secondary: const Icon(Icons.add_shopping_cart),
            value: _autoAddToCart,
            onChanged: (v) {
              setState(() => _autoAddToCart = v);
              _saveAllSettings();
            },
          ),
          const Divider(indent: 16, endIndent: 16),
          ListTile(
            leading: const Icon(Icons.format_list_numbered),
            title: Text(l10n.barcodeFormats,
                style:
                    TextStyle(color: Theme.of(context).colorScheme.onSurface)),
            subtitle: Text(_getBarcodeFormatName(l10n)),
            trailing: const AdaptiveIcon(Icons.chevron_right),
            onTap: _showBarcodeFormatPicker,
          ),
          const SizedBox(height: AlhaiSpacing.xs),
        ]),

        // Test scanner
        _buildSettingsGroup(
            l10n.testing, Icons.bug_report_rounded, AppColors.primary, isDark, [
          ListTile(
            leading: const Icon(Icons.bug_report, color: AppColors.primary),
            title: Text(l10n.testScanner,
                style:
                    TextStyle(color: Theme.of(context).colorScheme.onSurface)),
            subtitle: Text(l10n.testScanBarcode),
            trailing: const AdaptiveIcon(Icons.chevron_right),
            onTap: _testScanner,
          ),
          const SizedBox(height: AlhaiSpacing.xs),
        ]),
      ],
    );
  }

  Widget _buildPageHeader(bool isDark, AppLocalizations l10n) {
    return Row(
      children: [
        IconButton(
          onPressed: () => context.pop(),
          icon: Icon(
            Directionality.of(context) == TextDirection.rtl
                ? Icons.arrow_forward_rounded
                : Icons.arrow_back_rounded,
            color: Theme.of(context).colorScheme.onSurface,
          ),
          tooltip: l10n.back,
        ),
        const SizedBox(width: AlhaiSpacing.xs),
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: const Color(0xFFF59E0B).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(Icons.qr_code_scanner_rounded,
              color: Color(0xFFF59E0B), size: 24),
        ),
        const SizedBox(width: AlhaiSpacing.sm),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.barcodeSettings,
                style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface)),
            Text(l10n.barcodeSettingsSubtitle,
                style: TextStyle(
                    fontSize: 13,
                    color: Theme.of(context).colorScheme.onSurfaceVariant)),
          ],
        ),
      ],
    );
  }

  Widget _buildSettingsGroup(String title, IconData icon, Color color,
      bool isDark, List<Widget> children) {
    return Container(
      margin: const EdgeInsets.only(bottom: AlhaiSpacing.md),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).dividerColor,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(AlhaiSpacing.mdl,
                AlhaiSpacing.md, AlhaiSpacing.mdl, AlhaiSpacing.xs),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(AlhaiSpacing.xs),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: color, size: 20),
                ),
                const SizedBox(width: AlhaiSpacing.sm),
                Text(title,
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onSurface)),
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
    final l10n = AppLocalizations.of(context);
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
              groupValue: _barcodeFormat,
              onChanged: (v) {
                setState(() => _barcodeFormat = v!);
                _saveAllSettings();
                Navigator.pop(ctx);
              },
            ),
            RadioListTile<String>(
              title: const Text('EAN-8, EAN-13'),
              value: 'ean',
              groupValue: _barcodeFormat,
              onChanged: (v) {
                setState(() => _barcodeFormat = v!);
                _saveAllSettings();
                Navigator.pop(ctx);
              },
            ),
            RadioListTile<String>(
              title: const Text('UPC-A, UPC-E'),
              value: 'upc',
              groupValue: _barcodeFormat,
              onChanged: (v) {
                setState(() => _barcodeFormat = v!);
                _saveAllSettings();
                Navigator.pop(ctx);
              },
            ),
            RadioListTile<String>(
              title: Text(l10n.qrCodeOnly),
              value: 'qr',
              groupValue: _barcodeFormat,
              onChanged: (v) {
                setState(() => _barcodeFormat = v!);
                _saveAllSettings();
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
    final l10n = AppLocalizations.of(context);
    showModalBottomSheet(
      context: context,
      builder: (ctx) => Container(
        height: MediaQuery.of(context).size.height * 0.5,
        padding: const EdgeInsets.all(AlhaiSpacing.lg),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        ),
        child: Column(
          children: [
            Icon(Icons.qr_code_scanner,
                size: 64, color: isDark ? Colors.white70 : AppColors.primary),
            const SizedBox(height: AlhaiSpacing.md),
            Text(l10n.pointCameraAtBarcode,
                style: TextStyle(
                    fontSize: 18,
                    color: Theme.of(context).colorScheme.onSurface)),
            const SizedBox(height: AlhaiSpacing.lg),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(l10n.scanArea,
                      style: TextStyle(
                          color:
                              Theme.of(context).colorScheme.onSurfaceVariant)),
                ),
              ),
            ),
            const SizedBox(height: AlhaiSpacing.md),
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
