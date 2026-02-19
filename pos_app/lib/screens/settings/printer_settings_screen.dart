import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../data/local/app_database.dart';
import '../../di/injection.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../providers/products_providers.dart';
import '../../providers/settings_db_providers.dart';
import '../../widgets/layout/app_header.dart';

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

  /// تحميل الإعدادات من قاعدة البيانات
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

  /// حفظ جميع إعدادات الطابعة في قاعدة البيانات مع المزامنة
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
        final l10n = AppLocalizations.of(context)!;
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
        final l10n = AppLocalizations.of(context)!;
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
    final l10n = AppLocalizations.of(context)!;

    if (_isLoading) {
      return Column(
        children: [
          AppHeader(
            title: l10n.printerSettings,
            onMenuTap: isWideScreen
                ? null
                : () => Scaffold.of(context).openDrawer(),
            onNotificationsTap: () => context.push('/notifications'),
            notificationsCount: 3,
            userName: l10n.defaultUserName,
            userRole: l10n.branchManager,
          ),
          const Expanded(
            child: Center(child: CircularProgressIndicator()),
          ),
        ],
      );
    }

    return Column(
              children: [
                AppHeader(
                  title: l10n.printerSettings,
                  onMenuTap: isWideScreen
                      ? null
                      : () => Scaffold.of(context).openDrawer(),
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

        // Printer type
        _buildSettingsGroup(l10n.printerType, Icons.print_rounded,
            const Color(0xFF8B5CF6), isDark, [
          RadioListTile<String>(
            title: Text('USB',
                style: TextStyle(
                    color: isDark ? Colors.white : AppColors.textPrimary)),
            subtitle: Text(l10n.thermalUsbPrinter),
            value: 'usb',
            // ignore: deprecated_member_use
            groupValue: _printerType,
            // ignore: deprecated_member_use
            onChanged: (v) => setState(() => _printerType = v!),
          ),
          RadioListTile<String>(
            title: Text('Bluetooth',
                style: TextStyle(
                    color: isDark ? Colors.white : AppColors.textPrimary)),
            subtitle: Text(l10n.bluetoothPortablePrinter),
            value: 'bluetooth',
            // ignore: deprecated_member_use
            groupValue: _printerType,
            // ignore: deprecated_member_use
            onChanged: (v) => setState(() => _printerType = v!),
          ),
          RadioListTile<String>(
            title: Text('PDF',
                style: TextStyle(
                    color: isDark ? Colors.white : AppColors.textPrimary)),
            subtitle: Text(l10n.saveAsPdf),
            value: 'pdf',
            // ignore: deprecated_member_use
            groupValue: _printerType,
            // ignore: deprecated_member_use
            onChanged: (v) => setState(() => _printerType = v!),
          ),
          const SizedBox(height: 8),
        ]),

        // Template
        _buildSettingsGroup(l10n.receiptTemplate, Icons.receipt_long_rounded,
            AppColors.info, isDark, [
          RadioListTile<String>(
            title: Text(l10n.compactTemplate,
                style: TextStyle(
                    color: isDark ? Colors.white : AppColors.textPrimary)),
            subtitle: Text(l10n.basicInfoOnly),
            value: 'compact',
            // ignore: deprecated_member_use
            groupValue: _template,
            // ignore: deprecated_member_use
            onChanged: (v) => setState(() => _template = v!),
          ),
          RadioListTile<String>(
            title: Text(l10n.detailedTemplate,
                style: TextStyle(
                    color: isDark ? Colors.white : AppColors.textPrimary)),
            subtitle: Text(l10n.allDetails),
            value: 'detailed',
            // ignore: deprecated_member_use
            groupValue: _template,
            // ignore: deprecated_member_use
            onChanged: (v) => setState(() => _template = v!),
          ),
          const SizedBox(height: 8),
        ]),

        // Auto print
        _buildSettingsGroup(l10n.printOptions, Icons.settings_rounded,
            AppColors.success, isDark, [
          SwitchListTile(
            title: Text(l10n.autoPrinting,
                style: TextStyle(
                    color: isDark ? Colors.white : AppColors.textPrimary)),
            subtitle: Text(l10n.autoPrintAfterSale),
            value: _autoPrint,
            onChanged: (v) => setState(() => _autoPrint = v),
          ),
          const SizedBox(height: 8),
        ]),

        const SizedBox(height: 16),

        // Test print button
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
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Save button
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
              padding: const EdgeInsets.symmetric(vertical: 16),
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
          icon: Icon(Icons.arrow_back_rounded,
              color: isDark ? Colors.white : AppColors.textPrimary),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: const Color(0xFF8B5CF6).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(Icons.print_rounded,
              color: Color(0xFF8B5CF6), size: 24),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.printerSettings,
                style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : AppColors.textPrimary)),
            Text(l10n.printerSettingsSubtitle,
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
}
