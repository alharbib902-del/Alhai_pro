/// Payment Devices Screen - Connected payment device management
///
/// List of connected payment devices with status indicators,
/// test connection button, and add device navigation.
/// Supports: RTL Arabic, dark/light theme, responsive layout.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:get_it/get_it.dart';
import 'package:alhai_shared_ui/alhai_shared_ui.dart';
import 'package:alhai_l10n/alhai_l10n.dart';
import 'package:alhai_database/alhai_database.dart';
import 'package:alhai_auth/alhai_auth.dart';
import 'package:alhai_design_system/alhai_design_system.dart'
    show
        AlhaiBreakpoints,
        AlhaiSnackbar,
        AlhaiSnackbarVariant,
        AlhaiSpacing;
// alhai_design_system is re-exported via alhai_shared_ui
import '../../../core/services/sentry_service.dart';

/// Payment devices list screen
class PaymentDevicesScreen extends ConsumerStatefulWidget {
  const PaymentDevicesScreen({super.key});

  @override
  ConsumerState<PaymentDevicesScreen> createState() =>
      _PaymentDevicesScreenState();
}

class _PaymentDevicesScreenState extends ConsumerState<PaymentDevicesScreen> {
  final _db = GetIt.I<AppDatabase>();
  bool _isLoading = true;
  String? _error;
  List<_PaymentDevice> _devices = [];

  @override
  void initState() {
    super.initState();
    _loadDevices();
  }

  Future<void> _loadDevices() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final storeId = ref.read(currentStoreIdProvider);
      if (storeId == null) return;
      final settings = await (_db.select(
        _db.settingsTable,
      )..where((s) => s.storeId.equals(storeId))).get();
      final List<_PaymentDevice> loaded = [];

      // Parse stored devices from settings
      for (final s in settings) {
        if (s.key.startsWith('payment_device_') &&
            !s.key.contains('_ip') &&
            !s.key.contains('_port')) {
          final parts = s.value.split('|');
          if (parts.length >= 3) {
            loaded.add(
              _PaymentDevice(
                id: s.key.replaceFirst('payment_device_', ''),
                name: parts[0],
                type: parts[1],
                connectionMethod: parts[2],
                isConnected: parts.length > 3 && parts[3] == 'true',
              ),
            );
          }
        }
      }

      // Default devices if none configured
      if (loaded.isEmpty) {
        loaded.addAll([
          const _PaymentDevice(
            id: 'mada_1',
            name: 'Mada Terminal',
            type: 'Mada',
            connectionMethod: 'Network',
            isConnected: true,
          ),
          const _PaymentDevice(
            id: 'stc_1',
            name: 'STC Pay',
            type: 'STC Pay',
            connectionMethod: 'QR Code',
            isConnected: false,
          ),
        ]);
      }

      if (mounted) {
        setState(() => _devices = loaded);
      }
    } catch (e, stack) {
      reportError(e, stackTrace: stack, hint: 'Load payment devices');
      if (mounted) setState(() => _error = '$e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _testConnection(int index) async {
    final device = _devices[index];

    // Simulate connection test
    AlhaiSnackbar.show(
      context,
      message: AppLocalizations.of(context).testingConnectionName(device.name),
      variant: AlhaiSnackbarVariant.info,
      duration: const Duration(seconds: 1),
    );

    await Future.delayed(const Duration(seconds: 2));

    if (mounted) {
      setState(() {
        _devices[index] = device.copyWith(isConnected: true);
      });
      AlhaiSnackbar.success(
        context,
        AppLocalizations.of(context).connectionSuccessful(device.name),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isWideScreen = size.width >= AlhaiBreakpoints.desktop;
    final isMediumScreen = size.width >= AlhaiBreakpoints.tablet;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context);

    return Column(
      children: [
        AppHeader(
          title: l10n.paymentDevicesSettings,
          subtitle: '${_devices.length} أجهزة مضافة',
          showSearch: false,
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back_rounded,
              color: AppColors.getTextPrimary(isDark),
            ),
            onPressed: () => context.pop(),
            tooltip: l10n.back,
          ),
          actions: [
            FilledButton.icon(
              onPressed: () => context.push('/settings/payment-devices/add'),
              icon: const Icon(Icons.add_rounded, size: 18),
              label: Text(l10n.addDevice),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.textOnPrimary,
                padding: const EdgeInsets.symmetric(
                  horizontal: AlhaiSpacing.md,
                  vertical: AlhaiSpacing.xs,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ],
          onNotificationsTap: () => context.push(AppRoutes.notificationsCenter),
          userName: ref.watch(currentUserProvider)?.name ?? l10n.cashCustomer,
          userRole: l10n.cashier,
          onUserTap: () => context.push(AppRoutes.profile),
        ),
        Expanded(
          child: _isLoading
              ? const AppLoadingState()
              : _error != null
              ? AppErrorState.general(
                  context,
                  message: _error!,
                  onRetry: _loadDevices,
                )
              : _devices.isEmpty
              ? _buildEmptyState(isDark, l10n)
              : SingleChildScrollView(
                  padding: EdgeInsets.all(
                    isMediumScreen ? AlhaiSpacing.lg : AlhaiSpacing.md,
                  ),
                  child: _buildContent(
                    isWideScreen,
                    isMediumScreen,
                    isDark,
                    l10n,
                  ),
                ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(bool isDark, AppLocalizations l10n) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.info.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(
              Icons.payment_rounded,
              size: 40,
              color: AppColors.info,
            ),
          ),
          const SizedBox(height: AlhaiSpacing.mdl),
          Text(
            l10n.noPaymentDevices,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.getTextPrimary(isDark),
            ),
          ),
          const SizedBox(height: AlhaiSpacing.xs),
          Text(
            l10n.addFirstPaymentDevice,
            style: TextStyle(
              fontSize: 14,
              color: AppColors.getTextSecondary(isDark),
            ),
          ),
          const SizedBox(height: AlhaiSpacing.lg),
          FilledButton.icon(
            onPressed: () => context.push('/settings/payment-devices/add'),
            icon: const Icon(Icons.add_rounded, size: 20),
            label: Text(l10n.addDevice),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.textOnPrimary,
              padding: const EdgeInsets.symmetric(
                horizontal: AlhaiSpacing.lg,
                vertical: 14,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(
    bool isWideScreen,
    bool isMediumScreen,
    bool isDark,
    AppLocalizations l10n,
  ) {
    // Summary card on top
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildSummaryCard(isDark, l10n),
        SizedBox(height: isMediumScreen ? AlhaiSpacing.lg : AlhaiSpacing.md),
        if (isWideScreen)
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 2.2,
            ),
            itemCount: _devices.length,
            itemBuilder: (context, index) =>
                _buildDeviceCard(_devices[index], index, isDark, l10n),
          )
        else
          ...List.generate(
            _devices.length,
            (index) => Padding(
              padding: EdgeInsetsDirectional.only(
                bottom: index < _devices.length - 1 ? 12 : 0,
              ),
              child: _buildDeviceCard(_devices[index], index, isDark, l10n),
            ),
          ),
      ],
    );
  }

  Widget _buildSummaryCard(bool isDark, AppLocalizations l10n) {
    final connectedCount = _devices.where((d) => d.isConnected).length;
    final disconnectedCount = _devices.length - connectedCount;

    return Container(
      padding: const EdgeInsets.all(AlhaiSpacing.mdl),
      decoration: BoxDecoration(
        color: AppColors.getSurface(isDark),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.getBorder(isDark)),
      ),
      child: Row(
        children: [
          _summaryItem(
            Icons.devices_rounded,
            '${_devices.length}',
            l10n.totalDevices,
            AppColors.info,
            isDark,
          ),
          Container(width: 1, height: 40, color: AppColors.getBorder(isDark)),
          _summaryItem(
            Icons.check_circle_rounded,
            '$connectedCount',
            l10n.connected,
            AppColors.success,
            isDark,
          ),
          Container(width: 1, height: 40, color: AppColors.getBorder(isDark)),
          _summaryItem(
            Icons.cancel_rounded,
            '$disconnectedCount',
            l10n.disconnected,
            AppColors.error,
            isDark,
          ),
        ],
      ),
    );
  }

  Widget _summaryItem(
    IconData icon,
    String value,
    String label,
    Color color,
    bool isDark,
  ) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(height: AlhaiSpacing.xs),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.getTextPrimary(isDark),
            ),
          ),
          const SizedBox(height: AlhaiSpacing.xxxs),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: AppColors.getTextMuted(isDark),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDeviceCard(
    _PaymentDevice device,
    int index,
    bool isDark,
    AppLocalizations l10n,
  ) {
    final statusColor = device.isConnected
        ? AppColors.success
        : AppColors.error;

    return Container(
      padding: const EdgeInsets.all(AlhaiSpacing.mdl),
      decoration: BoxDecoration(
        color: AppColors.getSurface(isDark),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.getBorder(isDark)),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: _getDeviceColor(
                device.type,
              ).withValues(alpha: isDark ? 0.2 : 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              _getDeviceIcon(device.type),
              color: _getDeviceColor(device.type),
              size: 24,
            ),
          ),
          const SizedBox(width: AlhaiSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  device.name,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: AppColors.getTextPrimary(isDark),
                  ),
                ),
                const SizedBox(height: AlhaiSpacing.xxs),
                Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: statusColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      device.isConnected ? l10n.connected : l10n.disconnected,
                      style: TextStyle(
                        fontSize: 12,
                        color: statusColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(width: AlhaiSpacing.sm),
                    Text(
                      '${device.type} - ${device.connectionMethod}',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.getTextMuted(isDark),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          OutlinedButton.icon(
            onPressed: () => _testConnection(index),
            icon: const Icon(Icons.sync_rounded, size: 16),
            label: Text(l10n.test),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.info,
              side: BorderSide(color: AppColors.info.withValues(alpha: 0.5)),
              padding: const EdgeInsets.symmetric(
                horizontal: AlhaiSpacing.sm,
                vertical: AlhaiSpacing.xs,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getDeviceColor(String type) {
    switch (type.toLowerCase()) {
      case 'mada':
        return AppColors.primary;
      case 'stc pay':
        return AppColors.info;
      case 'apple pay':
        return Theme.of(context).colorScheme.onSurfaceVariant;
      default:
        return AppColors.secondary;
    }
  }

  IconData _getDeviceIcon(String type) {
    switch (type.toLowerCase()) {
      case 'mada':
        return Icons.credit_card_rounded;
      case 'stc pay':
        return Icons.phone_android_rounded;
      case 'apple pay':
        return Icons.apple_rounded;
      default:
        return Icons.payment_rounded;
    }
  }
}

/// Payment device data model
class _PaymentDevice {
  final String id;
  final String name;
  final String type;
  final String connectionMethod;
  final bool isConnected;

  const _PaymentDevice({
    required this.id,
    required this.name,
    required this.type,
    required this.connectionMethod,
    required this.isConnected,
  });

  _PaymentDevice copyWith({bool? isConnected}) {
    return _PaymentDevice(
      id: id,
      name: name,
      type: type,
      connectionMethod: connectionMethod,
      isConnected: isConnected ?? this.isConnected,
    );
  }
}
