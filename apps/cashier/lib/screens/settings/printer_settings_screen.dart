/// Printer Settings Screen - Printer configuration and management
///
/// Real ESC/POS printer discovery (Bluetooth/Network/Sunmi), test print,
/// default printer toggle, auto-print setting, paper size selection.
/// Supports: RTL Arabic, dark/light theme, responsive.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:alhai_shared_ui/alhai_shared_ui.dart';
import 'package:alhai_l10n/alhai_l10n.dart';
import 'package:alhai_auth/alhai_auth.dart';
import '../../core/services/sentry_service.dart';
import '../../services/printing/print_service.dart';
import '../../services/printing/printing_providers.dart'
    hide autoPrintEnabledProvider;
import 'package:alhai_design_system/alhai_design_system.dart' show AlhaiBreakpoints, AlhaiSpacing;

/// Printer settings screen
class PrinterSettingsScreen extends ConsumerStatefulWidget {
  const PrinterSettingsScreen({super.key});

  @override
  ConsumerState<PrinterSettingsScreen> createState() =>
      _PrinterSettingsScreenState();
}

class _PrinterSettingsScreenState
    extends ConsumerState<PrinterSettingsScreen> {
  bool _isScanning = false;
  bool _isTesting = false;
  List<DiscoveredPrinter> _discoveredPrinters = [];
  String _selectedConnectionType = 'bluetooth'; // bluetooth, network, sunmi
  String? _networkIp;

  @override
  void initState() {
    super.initState();
    // Load auto-print preference
    PrintServiceNotifier.isAutoPrintEnabled().then((enabled) {
      if (mounted) {
        ref.read(autoPrintEnabledProvider.notifier).state = enabled;
      }
    });
  }

  Future<void> _scanPrinters() async {
    setState(() {
      _isScanning = true;
      _discoveredPrinters = [];
    });

    try {
      // Ensure service matches connection type
      await ref
          .read(printServiceProvider.notifier)
          .setServiceType(_selectedConnectionType);

      final service = ref.read(printServiceProvider);
      if (service == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(AppLocalizations.of(context).printerInitFailed),
              backgroundColor: AppColors.error,
            ),
          );
        }
        return;
      }

      final printers = await service.scanForPrinters(
        timeout: const Duration(seconds: 10),
      );

      if (mounted) {
        setState(() => _discoveredPrinters = printers);

        if (printers.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(AppLocalizations.of(context).noPrintersFound),
              backgroundColor: AppColors.warning,
            ),
          );
        }
      }
    } catch (e, stack) {
      reportError(e, stackTrace: stack, hint: 'Scan printers');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context).searchErrorMsg('$e')),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isScanning = false);
    }
  }

  Future<void> _connectPrinter(DiscoveredPrinter printer) async {
    try {
      final success = await ref
          .read(printServiceProvider.notifier)
          .connectAndSave(printer);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              success
                  ? AppLocalizations.of(context).connectedToPrinterName(printer.name)
                  : AppLocalizations.of(context).connectionFailedToPrinter(printer.name),
            ),
            backgroundColor: success ? AppColors.success : AppColors.error,
          ),
        );
        setState(() {}); // Refresh UI
      }
    } catch (e, stack) {
      reportError(e, stackTrace: stack, hint: 'Connect printer');
    }
  }

  Future<void> _connectNetworkPrinter() async {
    final ip = _networkIp?.trim();
    if (ip == null || ip.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context).enterPrinterIpAddress),
          backgroundColor: AppColors.warning,
        ),
      );
      return;
    }

    await ref
        .read(printServiceProvider.notifier)
        .setServiceType('network');

    final printer = DiscoveredPrinter(
      id: ip,
      name: 'Network Printer ($ip)',
      type: PrinterConnectionType.network,
      address: ip,
    );

    await _connectPrinter(printer);
  }

  Future<void> _testPrint() async {
    final l10n = AppLocalizations.of(context);
    final service = ref.read(printServiceProvider);
    if (service == null || service.status != PrinterStatus.connected) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.printerNotConnectedMsg),
          backgroundColor: AppColors.warning,
        ),
      );
      return;
    }

    setState(() => _isTesting = true);
    try {
      final result = await service.printTestPage();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              result.success
                  ? l10n.testPageSentSuccess
                  : l10n.testFailedMsg(result.error ?? ''),
            ),
            backgroundColor:
                result.success ? AppColors.success : AppColors.error,
          ),
        );
      }
    } catch (e, stack) {
      reportError(e, stackTrace: stack, hint: 'Test print');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.errorMsgGeneric('$e')),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isTesting = false);
    }
  }

  Future<void> _openCashDrawer() async {
    final l10n = AppLocalizations.of(context);
    final service = ref.read(printServiceProvider);
    if (service == null || service.status != PrinterStatus.connected) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.printerNotConnectedMsg),
          backgroundColor: AppColors.warning,
        ),
      );
      return;
    }

    final result = await service.openCashDrawer();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            result.success ? l10n.cashDrawerOpened : l10n.cashDrawerFailed(result.error ?? ''),
          ),
          backgroundColor:
              result.success ? AppColors.success : AppColors.error,
        ),
      );
    }
  }

  Future<void> _disconnect() async {
    await ref.read(printServiceProvider.notifier).disconnectAndClear();
    if (mounted) {
      setState(() {});
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context).disconnectedMsg),
          backgroundColor: AppColors.info,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isMediumScreen = size.width >= AlhaiBreakpoints.tablet;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context);

    final service = ref.watch(printServiceProvider);
    final isConnected = service?.status == PrinterStatus.connected;
    final autoPrint = ref.watch(autoPrintEnabledProvider);

    return Column(
      children: [
        AppHeader(
          title: l10n.printerSettings,
          subtitle: isConnected
              ? l10n.connectedPrinterStatus(service?.connectedPrinterName ?? '')
              : l10n.notConnectedStatus,
          showSearch: false,
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back_rounded,
              color: AppColors.getTextPrimary(isDark),
            ),
            onPressed: () => context.pop(),
            tooltip: l10n.back,
          ),
          onNotificationsTap: () =>
              context.push(AppRoutes.notificationsCenter),
          userName:
              ref.watch(currentUserProvider)?.name ?? l10n.cashCustomer,
          userRole: l10n.cashier,
          onUserTap: () => context.push(AppRoutes.profile),
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(isMediumScreen ? AlhaiSpacing.lg : AlhaiSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // ═══════════════════════════════
                // CONNECTION STATUS
                // ═══════════════════════════════
                _buildStatusCard(isDark, isConnected, service, l10n),
                const SizedBox(height: AlhaiSpacing.md),

                // ═══════════════════════════════
                // CONNECT NEW PRINTER
                // ═══════════════════════════════
                _buildConnectCard(isDark, l10n),
                const SizedBox(height: AlhaiSpacing.md),

                // ═══════════════════════════════
                // DISCOVERED PRINTERS
                // ═══════════════════════════════
                if (_discoveredPrinters.isNotEmpty)
                  _buildDiscoveredList(isDark, l10n),

                // ═══════════════════════════════
                // SETTINGS
                // ═══════════════════════════════
                const SizedBox(height: AlhaiSpacing.md),
                _buildSettingsCard(isDark, autoPrint, service, l10n),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ─── Status Card ───────────────────────────────────

  Widget _buildStatusCard(
    bool isDark,
    bool isConnected,
    ThermalPrintService? service,
    AppLocalizations l10n,
  ) {
    final statusColor = isConnected ? AppColors.success : AppColors.error;
    final statusIcon =
        isConnected ? Icons.check_circle_rounded : Icons.cancel_rounded;
    final statusText =
        isConnected ? 'متصل بالطابعة' : 'لا توجد طابعة متصلة';

    return Container(
      padding: const EdgeInsets.all(AlhaiSpacing.mdl),
      decoration: BoxDecoration(
        color: AppColors.getSurface(isDark),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: statusColor.withValues(alpha: 0.3),
          width: 2,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(statusIcon, color: statusColor, size: 28),
              ),
              const SizedBox(width: AlhaiSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      statusText,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.getTextPrimary(isDark),
                      ),
                    ),
                    if (isConnected) ...[
                      const SizedBox(height: AlhaiSpacing.xxs),
                      Text(
                        service?.connectedPrinterName ?? '',
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.getTextMuted(isDark),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          if (isConnected) ...[
            const SizedBox(height: AlhaiSpacing.md),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _isTesting ? null : _testPrint,
                    icon: _isTesting
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.print_rounded, size: 16),
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
                const SizedBox(width: AlhaiSpacing.xs),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _openCashDrawer,
                    icon: const Icon(Icons.point_of_sale_rounded, size: 16),
                    label: Text(AppLocalizations.of(context).openDrawer),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.warning,
                      side: BorderSide(
                          color: AppColors.warning.withValues(alpha: 0.5)),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                ),
                const SizedBox(width: AlhaiSpacing.xs),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _disconnect,
                    icon: const Icon(Icons.link_off_rounded, size: 16),
                    label: Text(AppLocalizations.of(context).cutPaperBtn),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.error,
                      side: BorderSide(
                          color: AppColors.error.withValues(alpha: 0.5)),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  // ─── Connect Card ──────────────────────────────────

  Widget _buildConnectCard(bool isDark, AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(AlhaiSpacing.mdl),
      decoration: BoxDecoration(
        color: AppColors.getSurface(isDark),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.getBorder(isDark)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'اتصال بطابعة',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.getTextPrimary(isDark),
            ),
          ),
          const SizedBox(height: AlhaiSpacing.md),

          // Connection type selector
          Text(
            'نوع الاتصال',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.getTextSecondary(isDark),
            ),
          ),
          const SizedBox(height: AlhaiSpacing.xs),
          Wrap(
            spacing: 8,
            children: [
              _connectionChip('bluetooth', 'بلوتوث', Icons.bluetooth, isDark),
              _connectionChip(
                  'network', 'شبكة', Icons.wifi_rounded, isDark),
              _connectionChip(
                  'sunmi', 'Sunmi', Icons.smartphone_rounded, isDark),
            ],
          ),
          const SizedBox(height: AlhaiSpacing.md),

          // Network IP input (only for network type)
          if (_selectedConnectionType == 'network') ...[
            Text(
              'عنوان IP للطابعة',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.getTextSecondary(isDark),
              ),
            ),
            const SizedBox(height: AlhaiSpacing.xs),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    textDirection: TextDirection.ltr,
                    keyboardType: TextInputType.number,
                    onChanged: (v) => _networkIp = v,
                    decoration: InputDecoration(
                      hintText: '192.168.1.100',
                      hintStyle:
                          TextStyle(color: AppColors.getTextMuted(isDark)),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: AlhaiSpacing.md, vertical: AlhaiSpacing.sm),
                      isDense: true,
                    ),
                  ),
                ),
                const SizedBox(width: AlhaiSpacing.xs),
                FilledButton(
                  onPressed: _connectNetworkPrinter,
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(
                        horizontal: AlhaiSpacing.mdl, vertical: AlhaiSpacing.sm),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                  child: Text(AppLocalizations.of(context).connectBtn),
                ),
              ],
            ),
            const SizedBox(height: AlhaiSpacing.md),
          ],

          // Scan button (for bluetooth and sunmi)
          if (_selectedConnectionType != 'network')
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: _isScanning ? null : _scanPrinters,
                icon: _isScanning
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.textOnPrimary,
                        ),
                      )
                    : const Icon(Icons.search_rounded, size: 18),
                label: Text(_isScanning ? 'جاري البحث...' : 'بحث عن طابعات'),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: AlhaiSpacing.sm),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _connectionChip(
      String value, String label, IconData icon, bool isDark) {
    final isSelected = _selectedConnectionType == value;
    return ChoiceChip(
      avatar: Icon(icon, size: 18),
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => setState(() => _selectedConnectionType = value),
      selectedColor: AppColors.primary.withValues(alpha: 0.15),
      labelStyle: TextStyle(
        color: isSelected
            ? AppColors.primary
            : AppColors.getTextPrimary(isDark),
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(
          color: isSelected ? AppColors.primary : AppColors.getBorder(isDark),
        ),
      ),
    );
  }

  // ─── Discovered Printers List ──────────────────────

  Widget _buildDiscoveredList(bool isDark, AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(AlhaiSpacing.mdl),
      decoration: BoxDecoration(
        color: AppColors.getSurface(isDark),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.getBorder(isDark)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'الطابعات المكتشفة (${_discoveredPrinters.length})',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.getTextPrimary(isDark),
            ),
          ),
          const SizedBox(height: AlhaiSpacing.sm),
          ..._discoveredPrinters.map((printer) {
            final connectedName =
                ref.read(printServiceProvider)?.connectedPrinterName;
            final isThisConnected = connectedName == printer.name;

            return Container(
              margin: const EdgeInsets.only(bottom: AlhaiSpacing.xs),
              padding:
                  const EdgeInsets.symmetric(horizontal: AlhaiSpacing.md, vertical: AlhaiSpacing.sm),
              decoration: BoxDecoration(
                color: isThisConnected
                    ? AppColors.success.withValues(alpha: 0.05)
                    : AppColors.getSurfaceVariant(isDark),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: isThisConnected
                      ? AppColors.success.withValues(alpha: 0.3)
                      : AppColors.getBorder(isDark),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    _iconForType(printer.type),
                    color: isThisConnected
                        ? AppColors.success
                        : AppColors.getTextMuted(isDark),
                    size: 20,
                  ),
                  const SizedBox(width: AlhaiSpacing.sm),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          printer.name,
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: AppColors.getTextPrimary(isDark),
                          ),
                        ),
                        if (printer.address != null)
                          Text(
                            printer.address!,
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.getTextMuted(isDark),
                            ),
                          ),
                      ],
                    ),
                  ),
                  if (isThisConnected)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: AlhaiSpacing.xxs),
                      decoration: BoxDecoration(
                        color: AppColors.success.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text(
                        'متصل',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: AppColors.success,
                        ),
                      ),
                    )
                  else
                    OutlinedButton(
                      onPressed: () => _connectPrinter(printer),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(
                            horizontal: AlhaiSpacing.md, vertical: 6),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                      ),
                      child: Text(AppLocalizations.of(context).connectBtn),
                    ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  IconData _iconForType(PrinterConnectionType type) {
    switch (type) {
      case PrinterConnectionType.bluetooth:
        return Icons.bluetooth;
      case PrinterConnectionType.network:
        return Icons.wifi_rounded;
      case PrinterConnectionType.sunmi:
        return Icons.smartphone_rounded;
      case PrinterConnectionType.usb:
        return Icons.usb_rounded;
    }
  }

  // ─── Settings Card ─────────────────────────────────

  Widget _buildSettingsCard(
    bool isDark,
    bool autoPrint,
    ThermalPrintService? service,
    AppLocalizations l10n,
  ) {
    return Container(
      padding: const EdgeInsets.all(AlhaiSpacing.mdl),
      decoration: BoxDecoration(
        color: AppColors.getSurface(isDark),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.getBorder(isDark)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'إعدادات الطباعة',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.getTextPrimary(isDark),
            ),
          ),
          const SizedBox(height: AlhaiSpacing.md),

          // Auto-print toggle
          _settingsRow(
            isDark,
            icon: Icons.auto_fix_high_rounded,
            title: 'طباعة تلقائية',
            subtitle: 'طباعة الفاتورة تلقائياً بعد كل عملية بيع',
            trailing: Switch(
              value: autoPrint,
              onChanged: (value) async {
                ref.read(autoPrintEnabledProvider.notifier).state = value;
                await PrintServiceNotifier.setAutoPrint(value);
              },
              activeTrackColor: AppColors.primary,
            ),
          ),
          Divider(color: AppColors.getBorder(isDark), height: 24),

          // Paper size selector
          _settingsRow(
            isDark,
            icon: Icons.straighten_rounded,
            title: 'حجم الورق',
            subtitle: 'عرض ورق الطباعة الحرارية',
            trailing: SegmentedButton<PaperSize>(
              segments: [
                ButtonSegment(
                  value: PaperSize.mm58,
                  label: Text(l10n.paperSize58mm),
                ),
                ButtonSegment(
                  value: PaperSize.mm80,
                  label: Text(l10n.paperSize80mm),
                ),
              ],
              selected: {service?.paperSize ?? PaperSize.mm80},
              onSelectionChanged: (sizes) async {
                await ref
                    .read(printServiceProvider.notifier)
                    .setPaperSize(sizes.first);
                setState(() {});
              },
              style: ButtonStyle(
                visualDensity: VisualDensity.compact,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _settingsRow(
    bool isDark, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Widget trailing,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AlhaiSpacing.xxs),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: AppColors.primary, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.getTextPrimary(isDark),
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.getTextMuted(isDark),
                  ),
                ),
              ],
            ),
          ),
          trailing,
        ],
      ),
    );
  }
}
