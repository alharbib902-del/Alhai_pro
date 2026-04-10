import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:alhai_shared_ui/alhai_shared_ui.dart';
import 'package:alhai_l10n/alhai_l10n.dart';
import 'package:alhai_database/alhai_database.dart';
import 'package:alhai_core/alhai_core.dart';
import '../../../providers/settings_db_providers.dart';
import 'package:alhai_design_system/alhai_design_system.dart';

// مفاتيح إعدادات الطابعة
const String _kPrinterType = 'printer_type';
const String _kPrinterAutoPrint = 'printer_auto_print';
const String _kPrinterTemplate = 'printer_template';

/// شاشة إعدادات الطابعة
class PrinterSettingsScreen extends ConsumerStatefulWidget {
  const PrinterSettingsScreen({super.key});

  @override
  ConsumerState<PrinterSettingsScreen> createState() =>
      _PrinterSettingsScreenState();
}

class _PrinterSettingsScreenState extends ConsumerState<PrinterSettingsScreen> {
  String _printerType = 'usb';
  bool _autoPrint = true;
  String _template = 'compact';
  bool _isLoading = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    try {
      final storeId = ref.read(currentStoreIdProvider);
      if (storeId == null) {
        if (mounted) setState(() => _isLoading = false);
        return;
      }

      final db = getIt<AppDatabase>();
      final settings = await getSettingsByPrefix(db, storeId, 'printer_');

      if (mounted) {
        setState(() {
          _printerType = settings[_kPrinterType] ?? 'usb';
          _autoPrint = settings[_kPrinterAutoPrint] != 'false';
          _template = settings[_kPrinterTemplate] ?? 'compact';
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _saveAllSettings() async {
    setState(() => _isSaving = true);
    try {
      final storeId = ref.read(currentStoreIdProvider);
      if (storeId == null) return;

      final db = getIt<AppDatabase>();

      await saveSettingsBatch(
        db: db,
        storeId: storeId,
        settings: {
          _kPrinterType: _printerType,
          _kPrinterAutoPrint: _autoPrint.toString(),
          _kPrinterTemplate: _template,
        },
        ref: ref,
      );

      if (mounted) {
        final l10n = AppLocalizations.of(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.printerSettingsSaved),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        final l10n = AppLocalizations.of(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${l10n.errorSaving}: $e'),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
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
            title: l10n.printerSettings,
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
          title: l10n.printerSettings,
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
        _buildSettingsGroup(l10n.printerType, Icons.print_rounded,
            const Color(0xFF8B5CF6), isDark, [
          RadioGroup<String>(
            groupValue: _printerType,
            onChanged: (v) => setState(() => _printerType = v!),
            child: Column(
              children: [
                RadioListTile<String>(
                  title: Text('USB',
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurface)),
                  subtitle: Text(l10n.thermalUsbPrinter),
                  value: 'usb',
                ),
                RadioListTile<String>(
                  title: Text('Bluetooth',
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurface)),
                  subtitle: Text(l10n.bluetoothPortablePrinter),
                  value: 'bluetooth',
                ),
                RadioListTile<String>(
                  title: Text('PDF',
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurface)),
                  subtitle: Text(l10n.saveAsPdf),
                  value: 'pdf',
                ),
              ],
            ),
          ),
          const SizedBox(height: AlhaiSpacing.xs),
        ]),
        _buildSettingsGroup(l10n.receiptTemplate, Icons.receipt_long_rounded,
            AppColors.info, isDark, [
          RadioGroup<String>(
            groupValue: _template,
            onChanged: (v) => setState(() => _template = v!),
            child: Column(
              children: [
                RadioListTile<String>(
                  title: Text(l10n.compactTemplate,
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurface)),
                  subtitle: Text(l10n.basicInfoOnly),
                  value: 'compact',
                ),
                RadioListTile<String>(
                  title: Text(l10n.detailedTemplate,
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurface)),
                  subtitle: Text(l10n.allDetails),
                  value: 'detailed',
                ),
              ],
            ),
          ),
          const SizedBox(height: AlhaiSpacing.xs),
        ]),
        _buildSettingsGroup(l10n.printOptions, Icons.settings_rounded,
            AppColors.success, isDark, [
          SwitchListTile(
            title: Text(l10n.autoPrinting,
                style:
                    TextStyle(color: Theme.of(context).colorScheme.onSurface)),
            subtitle: Text(l10n.autoPrintAfterSale),
            value: _autoPrint,
            onChanged: (v) => setState(() => _autoPrint = v),
          ),
          const SizedBox(height: AlhaiSpacing.xs),
        ]),
        const SizedBox(height: AlhaiSpacing.md),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(l10n.testPrintInProgress)),
              );
            },
            icon: const Icon(Icons.print),
            label: Text(l10n.testPrint),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: AlhaiSpacing.md),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ),
        const SizedBox(height: AlhaiSpacing.md),
        SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            onPressed: _isSaving ? null : _saveAllSettings,
            icon: _isSaving
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Icon(Icons.save_rounded),
            label: Text(_isSaving ? l10n.saving : l10n.saveSettings),
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: AlhaiSpacing.md),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ),
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
            color: const Color(0xFF8B5CF6).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(Icons.print_rounded,
              color: Color(0xFF8B5CF6), size: 24),
        ),
        const SizedBox(width: AlhaiSpacing.sm),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.printerSettings,
                style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface)),
            Text(l10n.printerSettingsSubtitle,
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
}
