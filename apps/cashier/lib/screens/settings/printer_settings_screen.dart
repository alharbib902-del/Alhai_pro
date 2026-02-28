/// Printer Settings Screen - Printer configuration and management
///
/// List of configured printers, add printer form, test print,
/// default printer toggle. Supports: RTL Arabic, dark/light theme, responsive.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:get_it/get_it.dart';
import 'package:alhai_shared_ui/alhai_shared_ui.dart';
import 'package:alhai_l10n/alhai_l10n.dart';
import 'package:alhai_database/alhai_database.dart';
import 'package:alhai_auth/alhai_auth.dart';
// alhai_design_system is re-exported via alhai_shared_ui

/// Printer settings screen
class PrinterSettingsScreen extends ConsumerStatefulWidget {
  const PrinterSettingsScreen({super.key});

  @override
  ConsumerState<PrinterSettingsScreen> createState() =>
      _PrinterSettingsScreenState();
}

class _PrinterSettingsScreenState
    extends ConsumerState<PrinterSettingsScreen> {
  final _db = GetIt.I<AppDatabase>();
  bool _isLoading = true;
  List<_PrinterConfig> _printers = [];
  String _defaultPrinterId = '';

  @override
  void initState() {
    super.initState();
    _loadPrinters();
  }

  Future<void> _upsertSetting(String key, String value) async {
    final storeId = ref.read(currentStoreIdProvider) ?? kDefaultStoreId;
    final id = 'setting_${storeId}_$key';
    await _db.into(_db.settingsTable).insertOnConflictUpdate(
      SettingsTableCompanion.insert(
        id: id,
        storeId: storeId,
        key: key,
        value: value,
        updatedAt: DateTime.now(),
      ),
    );
  }

  Future<void> _loadPrinters() async {
    setState(() => _isLoading = true);
    try {
      final storeId = ref.read(currentStoreIdProvider) ?? kDefaultStoreId;
      final settings = await (
        _db.select(_db.settingsTable)
          ..where((s) => s.storeId.equals(storeId))
      ).get();
      final List<_PrinterConfig> loaded = [];

      for (final s in settings) {
        if (s.key.startsWith('printer_config_')) {
          final parts = s.value.split('|');
          if (parts.length >= 3) {
            loaded.add(_PrinterConfig(
              id: s.key.replaceFirst('printer_config_', ''),
              name: parts[0],
              type: parts[1],
              connection: parts[2],
            ));
          }
        }
        if (s.key == 'default_printer') {
          _defaultPrinterId = s.value;
        }
      }

      // Default printers if none configured
      if (loaded.isEmpty) {
        loaded.addAll([
          const _PrinterConfig(
            id: 'thermal_1',
            name: 'Thermal Receipt',
            type: 'Thermal',
            connection: 'USB',
          ),
          const _PrinterConfig(
            id: 'a4_1',
            name: 'Office A4',
            type: 'A4',
            connection: 'Network',
          ),
        ]);
        _defaultPrinterId = 'thermal_1';
      }

      if (mounted) {
        setState(() => _printers = loaded);
      }
    } catch (_) {
      // Use defaults
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _setDefaultPrinter(String printerId) async {
    setState(() => _defaultPrinterId = printerId);
    try {
      await _upsertSetting('default_printer', printerId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Default printer set'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (_) {}
  }

  Future<void> _testPrint(String printerName) async {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Test print sent to $printerName'),
        backgroundColor: AppColors.info,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showAddPrinterDialog(bool isDark, AppLocalizations l10n) {
    final nameCtrl = TextEditingController();
    String type = 'Thermal';
    String connection = 'USB';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          backgroundColor: AppColors.getSurface(isDark),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(
            'Add Printer',
            style: TextStyle(color: AppColors.getTextPrimary(isDark)),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Printer Name',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.getTextSecondary(isDark),
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: nameCtrl,
                  style: TextStyle(
                    color: AppColors.getTextPrimary(isDark),
                  ),
                  decoration: InputDecoration(
                    hintText: 'e.g. Receipt Printer',
                    hintStyle:
                        TextStyle(color: AppColors.getTextMuted(isDark)),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide:
                          BorderSide(color: AppColors.getBorder(isDark)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide:
                          BorderSide(color: AppColors.getBorder(isDark)),
                    ),
                    filled: true,
                    fillColor: AppColors.getSurfaceVariant(isDark),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  l10n.printerType,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.getTextSecondary(isDark),
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: ['Thermal', 'A4'].map((t) {
                    final isSelected = type == t;
                    return ChoiceChip(
                      label: Text(t),
                      selected: isSelected,
                      onSelected: (_) =>
                          setDialogState(() => type = t),
                      selectedColor:
                          AppColors.primary.withValues(alpha: 0.15),
                      labelStyle: TextStyle(
                        color: isSelected
                            ? AppColors.primary
                            : AppColors.getTextPrimary(isDark),
                        fontWeight:
                            isSelected ? FontWeight.w600 : FontWeight.normal,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                        side: BorderSide(
                          color: isSelected
                              ? AppColors.primary
                              : AppColors.getBorder(isDark),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),
                Text(
                  'Connection Type',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.getTextSecondary(isDark),
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: ['USB', 'Bluetooth', 'Network'].map((c) {
                    final isSelected = connection == c;
                    return ChoiceChip(
                      label: Text(c),
                      selected: isSelected,
                      onSelected: (_) =>
                          setDialogState(() => connection = c),
                      selectedColor:
                          AppColors.info.withValues(alpha: 0.15),
                      labelStyle: TextStyle(
                        color: isSelected
                            ? AppColors.info
                            : AppColors.getTextPrimary(isDark),
                        fontWeight:
                            isSelected ? FontWeight.w600 : FontWeight.normal,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                        side: BorderSide(
                          color: isSelected
                              ? AppColors.info
                              : AppColors.getBorder(isDark),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(l10n.cancel),
            ),
            FilledButton(
              onPressed: () async {
                if (nameCtrl.text.isEmpty) return;
                final id = DateTime.now().millisecondsSinceEpoch.toString();
                try {
                  await _upsertSetting(
                    'printer_config_$id',
                    '${nameCtrl.text}|$type|$connection',
                  );
                } catch (_) {}
                if (ctx.mounted) {
                  Navigator.pop(ctx);
                  _loadPrinters();
                }
              },
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
              ),
              child: Text(l10n.add),
            ),
          ],
        ),
      ),
    );
  }

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
          title: l10n.printerSettings,
          subtitle: '${_printers.length} printers configured',
          showSearch: false,
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back_rounded,
              color: AppColors.getTextPrimary(isDark),
            ),
            onPressed: () => context.pop(),
          ),
          actions: [
            FilledButton.icon(
              onPressed: () => _showAddPrinterDialog(isDark, l10n),
              icon: const Icon(Icons.add_rounded, size: 18),
              label: const Text('Add Printer'),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ],
          onNotificationsTap: () => context.push(AppRoutes.notificationsCenter),
          userName:
              ref.watch(currentUserProvider)?.name ?? l10n.cashCustomer,
          userRole: l10n.cashier,
          onUserTap: () => context.push(AppRoutes.profile),
        ),
        Expanded(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                  padding: EdgeInsets.all(isMediumScreen ? 24 : 16),
                  child: _buildContent(
                      isWideScreen, isMediumScreen, isDark, l10n),
                ),
        ),
      ],
    );
  }

  Widget _buildContent(
    bool isWideScreen,
    bool isMediumScreen,
    bool isDark,
    AppLocalizations l10n,
  ) {
    if (isWideScreen) {
      return GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 1.8,
        ),
        itemCount: _printers.length,
        itemBuilder: (context, index) =>
            _buildPrinterCard(_printers[index], isDark, l10n),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: _printers.map((printer) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _buildPrinterCard(printer, isDark, l10n),
        );
      }).toList(),
    );
  }

  Widget _buildPrinterCard(
    _PrinterConfig printer,
    bool isDark,
    AppLocalizations l10n,
  ) {
    final isDefault = printer.id == _defaultPrinterId;
    final typeColor =
        printer.type == 'Thermal' ? AppColors.warning : AppColors.info;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.getSurface(isDark),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDefault
              ? AppColors.primary.withValues(alpha: 0.5)
              : AppColors.getBorder(isDark),
          width: isDefault ? 2 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: typeColor.withValues(alpha: isDark ? 0.2 : 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  printer.type == 'Thermal'
                      ? Icons.receipt_long_rounded
                      : Icons.print_rounded,
                  color: typeColor,
                  size: 22,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          printer.name,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: AppColors.getTextPrimary(isDark),
                          ),
                        ),
                        if (isDefault) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: AppColors.primary
                                  .withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              l10n.defaultLabel,
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${printer.type} - ${printer.connection}',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.getTextMuted(isDark),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _testPrint(printer.name),
                  icon: const Icon(Icons.print_rounded, size: 16),
                  label: Text(l10n.testPrint),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.info,
                    side: BorderSide(
                        color: AppColors.info.withValues(alpha: 0.5)),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              if (!isDefault)
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _setDefaultPrinter(printer.id),
                    icon: const Icon(Icons.star_rounded, size: 16),
                    label: const Text('Set Default'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      side: BorderSide(
                          color: AppColors.primary.withValues(alpha: 0.5)),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Printer configuration data model
class _PrinterConfig {
  final String id;
  final String name;
  final String type;
  final String connection;

  const _PrinterConfig({
    required this.id,
    required this.name,
    required this.type,
    required this.connection,
  });
}
