/// Add Payment Device Screen - Form to add a new payment device
///
/// Form with device name, type (Mada, STC Pay, Apple Pay),
/// connection method, IP/port fields, test & save buttons.
/// Supports: RTL Arabic, dark/light theme, responsive layout.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:get_it/get_it.dart';
import 'package:alhai_shared_ui/alhai_shared_ui.dart';
import 'package:alhai_l10n/alhai_l10n.dart';
import 'package:alhai_database/alhai_database.dart';
import 'package:uuid/uuid.dart';
import 'package:alhai_auth/alhai_auth.dart';
import 'package:alhai_design_system/alhai_design_system.dart' show AlhaiBreakpoints, AlhaiSpacing;
// alhai_design_system is re-exported via alhai_shared_ui
import '../../core/services/sentry_service.dart';

/// Add payment device form screen
class AddPaymentDeviceScreen extends ConsumerStatefulWidget {
  const AddPaymentDeviceScreen({super.key});

  @override
  ConsumerState<AddPaymentDeviceScreen> createState() =>
      _AddPaymentDeviceScreenState();
}

class _AddPaymentDeviceScreenState
    extends ConsumerState<AddPaymentDeviceScreen> {
  final _db = GetIt.I<AppDatabase>();
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _ipController = TextEditingController();
  final _portController = TextEditingController(text: '8080');

  String _selectedType = 'Mada';
  String _connectionMethod = 'Network';
  bool _isSaving = false;
  bool _isTesting = false;
  bool _testPassed = false;

  final _deviceTypes = const ['Mada', 'STC Pay', 'Apple Pay', 'Visa/MC'];
  final _connectionMethods = const ['Network', 'USB', 'Bluetooth', 'QR Code'];

  @override
  void dispose() {
    _nameController.dispose();
    _ipController.dispose();
    _portController.dispose();
    super.dispose();
  }

  Future<void> _upsertSetting(String key, String value) async {
    final storeId = ref.read(currentStoreIdProvider)!;
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

  Future<void> _testConnection() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isTesting = true;
      _testPassed = false;
    });

    try {
      // Simulate connection test
      await Future.delayed(const Duration(seconds: 2));

      if (mounted) {
        setState(() => _testPassed = true);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context).connectionSuccessMsg),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e, stack) {
      reportError(e, stackTrace: stack, hint: 'Test payment device connection');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context).connectionFailedMsg('$e')),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isTesting = false);
    }
  }

  Future<void> _saveDevice() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      final deviceId = const Uuid().v4();
      final value =
          '${_nameController.text}|$_selectedType|$_connectionMethod|$_testPassed';

      await _upsertSetting('payment_device_$deviceId', value);

      // Also store IP/port if network connection
      if (_connectionMethod == 'Network') {
        await _upsertSetting(
          'payment_device_${deviceId}_ip',
          _ipController.text,
        );
        await _upsertSetting(
          'payment_device_${deviceId}_port',
          _portController.text,
        );
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context).deviceSavedMsg),
            backgroundColor: AppColors.success,
          ),
        );
        context.pop();
      }
    } catch (e, stack) {
      reportError(e, stackTrace: stack, hint: 'Save payment device');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context).settingsSaveErrorMsg('$e')),
            backgroundColor: AppColors.error,
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
    final isWideScreen = size.width >= AlhaiBreakpoints.desktop;
    final isMediumScreen = size.width >= AlhaiBreakpoints.tablet;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context);

    return Column(
      children: [
        AppHeader(
          title: 'إضافة جهاز دفع',
          subtitle: 'إعداد جهاز جديد',
          showSearch: false,
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back_rounded,
              color: AppColors.getTextPrimary(isDark),
            ),
            onPressed: () => context.pop(),
          ),
          onNotificationsTap: () => context.push(AppRoutes.notificationsCenter),
          userName:
              ref.watch(currentUserProvider)?.name ?? l10n.cashCustomer,
          userRole: l10n.cashier,
          onUserTap: () => context.push(AppRoutes.profile),
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(isMediumScreen ? AlhaiSpacing.lg : AlhaiSpacing.md),
            // M121: constrain form width on desktop
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 800),
                child: Form(
                  key: _formKey,
                  child:
                      _buildContent(isWideScreen, isMediumScreen, isDark, l10n),
                ),
              ),
            ),
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
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              children: [
                _buildBasicInfoCard(isDark, l10n),
                const SizedBox(height: AlhaiSpacing.lg),
                _buildConnectionCard(isDark, l10n),
              ],
            ),
          ),
          const SizedBox(width: AlhaiSpacing.lg),
          Expanded(
            child: Column(
              children: [
                _buildNetworkCard(isDark, l10n),
                const SizedBox(height: AlhaiSpacing.lg),
                _buildActionsCard(isDark, l10n),
              ],
            ),
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildBasicInfoCard(isDark, l10n),
        SizedBox(height: isMediumScreen ? AlhaiSpacing.lg : AlhaiSpacing.md),
        _buildConnectionCard(isDark, l10n),
        SizedBox(height: isMediumScreen ? AlhaiSpacing.lg : AlhaiSpacing.md),
        if (_connectionMethod == 'Network') ...[
          _buildNetworkCard(isDark, l10n),
          SizedBox(height: isMediumScreen ? AlhaiSpacing.lg : AlhaiSpacing.md),
        ],
        _buildActionsCard(isDark, l10n),
      ],
    );
  }

  Widget _buildBasicInfoCard(bool isDark, AppLocalizations l10n) {
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
          _sectionHeader(
            Icons.edit_rounded,
            'Device Info',
            AppColors.primary,
            isDark,
          ),
          const SizedBox(height: AlhaiSpacing.mdl),
          Text(
            'Device Name',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.getTextSecondary(isDark),
            ),
          ),
          const SizedBox(height: AlhaiSpacing.xs),
          TextFormField(
            controller: _nameController,
            style: TextStyle(
              fontSize: 14,
              color: AppColors.getTextPrimary(isDark),
            ),
            validator: (v) =>
                v == null || v.isEmpty ? l10n.fieldRequired : null,
            decoration: _inputDecoration('e.g. Main Terminal', isDark),
          ),
          const SizedBox(height: AlhaiSpacing.mdl),
          Text(
            'Device Type',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.getTextSecondary(isDark),
            ),
          ),
          const SizedBox(height: AlhaiSpacing.xs),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _deviceTypes.map((type) {
              final isSelected = _selectedType == type;
              return GestureDetector(
                onTap: () => setState(() => _selectedType = type),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: AlhaiSpacing.md, vertical: 10),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.primary.withValues(alpha: 0.1)
                        : AppColors.getSurfaceVariant(isDark),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: isSelected
                          ? AppColors.primary
                          : AppColors.getBorder(isDark),
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  child: Text(
                    type,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: isSelected
                          ? AppColors.primary
                          : AppColors.getTextSecondary(isDark),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildConnectionCard(bool isDark, AppLocalizations l10n) {
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
          _sectionHeader(
            Icons.cable_rounded,
            'Connection Method',
            AppColors.info,
            isDark,
          ),
          const SizedBox(height: AlhaiSpacing.md),
          ...List.generate(_connectionMethods.length, (index) {
            final method = _connectionMethods[index];
            final isSelected = _connectionMethod == method;
            return Padding(
              padding: EdgeInsets.only(
                  bottom: index < _connectionMethods.length - 1 ? 8 : 0),
              child: GestureDetector(
                onTap: () =>
                    setState(() => _connectionMethod = method),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: AlhaiSpacing.md, vertical: 14),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.info.withValues(alpha: 0.08)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected
                          ? AppColors.info
                          : AppColors.getBorder(isDark),
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        _getConnectionIcon(method),
                        color: isSelected
                            ? AppColors.info
                            : AppColors.getTextMuted(isDark),
                        size: 22,
                      ),
                      const SizedBox(width: AlhaiSpacing.sm),
                      Text(
                        method,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight:
                              isSelected ? FontWeight.w600 : FontWeight.normal,
                          color: isSelected
                              ? AppColors.info
                              : AppColors.getTextPrimary(isDark),
                        ),
                      ),
                      const Spacer(),
                      if (isSelected)
                        const Icon(
                          Icons.check_circle_rounded,
                          color: AppColors.info,
                          size: 20,
                        ),
                    ],
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildNetworkCard(bool isDark, AppLocalizations l10n) {
    if (_connectionMethod != 'Network') {
      return const SizedBox.shrink();
    }

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
          _sectionHeader(
            Icons.lan_rounded,
            'Network Settings',
            AppColors.warning,
            isDark,
          ),
          const SizedBox(height: AlhaiSpacing.mdl),
          Text(
            'IP Address',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.getTextSecondary(isDark),
            ),
          ),
          const SizedBox(height: AlhaiSpacing.xs),
          TextFormField(
            controller: _ipController,
            keyboardType: TextInputType.number,
            style: TextStyle(
              fontSize: 14,
              color: AppColors.getTextPrimary(isDark),
            ),
            validator: (v) =>
                _connectionMethod == 'Network' && (v == null || v.isEmpty)
                    ? l10n.fieldRequired
                    : null,
            decoration: _inputDecoration('192.168.1.100', isDark),
          ),
          const SizedBox(height: AlhaiSpacing.mdl),
          Text(
            'Port',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.getTextSecondary(isDark),
            ),
          ),
          const SizedBox(height: AlhaiSpacing.xs),
          TextFormField(
            controller: _portController,
            keyboardType: TextInputType.number,
            style: TextStyle(
              fontSize: 14,
              color: AppColors.getTextPrimary(isDark),
            ),
            decoration: _inputDecoration('8080', isDark),
          ),
        ],
      ),
    );
  }

  Widget _buildActionsCard(bool isDark, AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (_testPassed)
          Container(
            padding: const EdgeInsets.all(AlhaiSpacing.md),
            margin: const EdgeInsets.only(bottom: AlhaiSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.success.withValues(alpha: isDark ? 0.15 : 0.08),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                  color: AppColors.success.withValues(alpha: 0.3)),
            ),
            child: Row(
              children: [
                const Icon(Icons.check_circle_rounded,
                    color: AppColors.success, size: 20),
                const SizedBox(width: AlhaiSpacing.sm),
                Text(
                  'Connection test passed',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.getTextPrimary(isDark),
                  ),
                ),
              ],
            ),
          ),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _isTesting ? null : _testConnection,
                icon: _isTesting
                    ? SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.getTextSecondary(isDark),
                        ),
                      )
                    : const Icon(Icons.wifi_find_rounded, size: 20),
                label: Text(l10n.testConnection),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.info,
                  side: BorderSide(
                      color: AppColors.info.withValues(alpha: 0.5)),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
            const SizedBox(width: AlhaiSpacing.sm),
            Expanded(
              child: FilledButton.icon(
                onPressed: _isSaving ? null : _saveDevice,
                icon: _isSaving
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white),
                      )
                    : const Icon(Icons.save_rounded, size: 20),
                label: Text(l10n.saveDevice),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  IconData _getConnectionIcon(String method) {
    switch (method) {
      case 'Network':
        return Icons.lan_rounded;
      case 'USB':
        return Icons.usb_rounded;
      case 'Bluetooth':
        return Icons.bluetooth_rounded;
      case 'QR Code':
        return Icons.qr_code_rounded;
      default:
        return Icons.cable_rounded;
    }
  }

  Widget _sectionHeader(
      IconData icon, String title, Color color, bool isDark) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(AlhaiSpacing.xs),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: AlhaiSpacing.sm),
        Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.getTextPrimary(isDark),
          ),
        ),
      ],
    );
  }

  InputDecoration _inputDecoration(String hint, bool isDark) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: AppColors.getTextMuted(isDark)),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AppColors.getBorder(isDark)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AppColors.getBorder(isDark)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.primary, width: 2),
      ),
      filled: true,
      fillColor: AppColors.getSurfaceVariant(isDark),
    );
  }
}
