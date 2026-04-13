/// Receipt Settings Screen - Receipt template configuration
///
/// Header/footer text, logo toggle, show/hide fields,
/// receipt width selection, and preview section.
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
    show AlhaiBreakpoints, AlhaiSpacing;
// alhai_design_system is re-exported via alhai_shared_ui
import '../../../core/services/sentry_service.dart';

/// Receipt settings screen
class ReceiptSettingsScreen extends ConsumerStatefulWidget {
  const ReceiptSettingsScreen({super.key});

  @override
  ConsumerState<ReceiptSettingsScreen> createState() =>
      _ReceiptSettingsScreenState();
}

class _ReceiptSettingsScreenState extends ConsumerState<ReceiptSettingsScreen> {
  final _db = GetIt.I<AppDatabase>();
  final _headerController = TextEditingController();
  final _footerController = TextEditingController();

  bool _isLoading = true;
  bool _isSaving = false;
  String? _error;
  bool _showLogo = true;
  bool _showCustomerName = true;
  bool _showCashierName = true;
  bool _showStoreAddress = true;
  String _receiptWidth = '80mm';

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  @override
  void dispose() {
    _headerController.dispose();
    _footerController.dispose();
    super.dispose();
  }

  Future<void> _loadSettings() async {
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
      for (final s in settings) {
        switch (s.key) {
          case 'receipt_header':
            _headerController.text = s.value;
          case 'receipt_footer':
            _footerController.text = s.value;
          case 'receipt_show_logo':
            _showLogo = s.value != 'false';
          case 'receipt_show_customer_name':
            _showCustomerName = s.value != 'false';
          case 'receipt_show_cashier_name':
            _showCashierName = s.value != 'false';
          case 'receipt_show_store_address':
            _showStoreAddress = s.value != 'false';
          case 'receipt_width':
            _receiptWidth = s.value;
        }
      }
    } catch (e, stack) {
      reportError(e, stackTrace: stack, hint: 'Load receipt settings');
      if (mounted) setState(() => _error = '$e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _upsertSetting(String key, String value) async {
    final storeId = ref.read(currentStoreIdProvider);
    if (storeId == null) return;
    final id = 'setting_${storeId}_$key';
    await _db
        .into(_db.settingsTable)
        .insertOnConflictUpdate(
          SettingsTableCompanion.insert(
            id: id,
            storeId: storeId,
            key: key,
            value: value,
            updatedAt: DateTime.now(),
          ),
        );
  }

  Future<void> _saveSettings() async {
    setState(() => _isSaving = true);
    try {
      final entries = {
        'receipt_header': _headerController.text,
        'receipt_footer': _footerController.text,
        'receipt_show_logo': _showLogo.toString(),
        'receipt_show_customer_name': _showCustomerName.toString(),
        'receipt_show_cashier_name': _showCashierName.toString(),
        'receipt_show_store_address': _showStoreAddress.toString(),
        'receipt_width': _receiptWidth,
      };
      for (final entry in entries.entries) {
        await _upsertSetting(entry.key, entry.value);
      }
      if (mounted) {
        final l10n = AppLocalizations.of(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.settingsSaved),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e, stack) {
      reportError(e, stackTrace: stack, hint: 'Save receipt settings');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(context).errorSavingSettings('$e'),
            ),
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
          title: l10n.receiptSettings,
          subtitle: 'تخصيص الإيصال',
          showSearch: false,
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back_rounded,
              color: AppColors.getTextPrimary(isDark),
            ),
            onPressed: () => context.pop(),
            tooltip: l10n.back,
          ),
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
                  onRetry: _loadSettings,
                )
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
            flex: 3,
            child: Column(
              children: [
                _buildTextFieldsCard(isDark, l10n),
                const SizedBox(height: AlhaiSpacing.lg),
                _buildTogglesCard(isDark, l10n),
                const SizedBox(height: AlhaiSpacing.lg),
                _buildWidthCard(isDark, l10n),
                const SizedBox(height: AlhaiSpacing.lg),
                _buildSaveButton(isDark, l10n),
              ],
            ),
          ),
          const SizedBox(width: AlhaiSpacing.lg),
          Expanded(flex: 2, child: _buildPreviewCard(isDark, l10n)),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildTextFieldsCard(isDark, l10n),
        SizedBox(height: isMediumScreen ? AlhaiSpacing.lg : AlhaiSpacing.md),
        _buildTogglesCard(isDark, l10n),
        SizedBox(height: isMediumScreen ? AlhaiSpacing.lg : AlhaiSpacing.md),
        _buildWidthCard(isDark, l10n),
        SizedBox(height: isMediumScreen ? AlhaiSpacing.lg : AlhaiSpacing.md),
        _buildPreviewCard(isDark, l10n),
        const SizedBox(height: AlhaiSpacing.lg),
        _buildSaveButton(isDark, l10n),
      ],
    );
  }

  Widget _buildTextFieldsCard(bool isDark, AppLocalizations l10n) {
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
            Icons.text_fields_rounded,
            'Receipt Text',
            AppColors.secondary,
            isDark,
          ),
          const SizedBox(height: AlhaiSpacing.mdl),
          Text(
            'Header Text',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.getTextSecondary(isDark),
            ),
          ),
          const SizedBox(height: AlhaiSpacing.xs),
          TextField(
            controller: _headerController,
            maxLines: 3,
            style: TextStyle(
              fontSize: 14,
              color: AppColors.getTextPrimary(isDark),
            ),
            decoration: _inputDecoration('Receipt header hint', isDark),
          ),
          const SizedBox(height: AlhaiSpacing.mdl),
          Text(
            l10n.footerText,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.getTextSecondary(isDark),
            ),
          ),
          const SizedBox(height: AlhaiSpacing.xs),
          TextField(
            controller: _footerController,
            maxLines: 3,
            style: TextStyle(
              fontSize: 14,
              color: AppColors.getTextPrimary(isDark),
            ),
            decoration: _inputDecoration('Receipt footer hint', isDark),
          ),
        ],
      ),
    );
  }

  Widget _buildTogglesCard(bool isDark, AppLocalizations l10n) {
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
            Icons.visibility_rounded,
            'Display Options',
            AppColors.info,
            isDark,
          ),
          const SizedBox(height: AlhaiSpacing.md),
          _toggleItem(
            'Show Logo',
            'Display store logo on receipt',
            _showLogo,
            (v) => setState(() => _showLogo = v),
            isDark,
          ),
          Divider(color: AppColors.getBorder(isDark), height: 1),
          _toggleItem(
            'Show Customer Name',
            'Print customer name on receipt',
            _showCustomerName,
            (v) => setState(() => _showCustomerName = v),
            isDark,
          ),
          Divider(color: AppColors.getBorder(isDark), height: 1),
          _toggleItem(
            'Show Cashier Name',
            'Print cashier name on receipt',
            _showCashierName,
            (v) => setState(() => _showCashierName = v),
            isDark,
          ),
          Divider(color: AppColors.getBorder(isDark), height: 1),
          _toggleItem(
            'Show Store Address',
            'Print store address on receipt',
            _showStoreAddress,
            (v) => setState(() => _showStoreAddress = v),
            isDark,
          ),
        ],
      ),
    );
  }

  Widget _buildWidthCard(bool isDark, AppLocalizations l10n) {
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
            Icons.straighten_rounded,
            'Receipt Width',
            AppColors.warning,
            isDark,
          ),
          const SizedBox(height: AlhaiSpacing.md),
          Row(
            children: ['58mm', '80mm'].map((width) {
              final isSelected = _receiptWidth == width;
              return Expanded(
                child: Padding(
                  padding: EdgeInsetsDirectional.only(
                    end: width == '58mm' ? 8 : 0,
                    start: width == '80mm' ? 8 : 0,
                  ),
                  child: GestureDetector(
                    onTap: () => setState(() => _receiptWidth = width),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        vertical: AlhaiSpacing.md,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.primary.withValues(alpha: 0.1)
                            : AppColors.getSurfaceVariant(isDark),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected
                              ? AppColors.primary
                              : AppColors.getBorder(isDark),
                          width: isSelected ? 2 : 1,
                        ),
                      ),
                      child: Column(
                        children: [
                          Icon(
                            Icons.receipt_rounded,
                            color: isSelected
                                ? AppColors.primary
                                : AppColors.getTextMuted(isDark),
                            size: 28,
                          ),
                          const SizedBox(height: AlhaiSpacing.xs),
                          Text(
                            width,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: isSelected
                                  ? AppColors.primary
                                  : AppColors.getTextPrimary(isDark),
                            ),
                          ),
                          const SizedBox(height: AlhaiSpacing.xxs),
                          Text(
                            width == '58mm'
                                ? l10n.smallSize
                                : l10n.standardSize,
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.getTextMuted(isDark),
                            ),
                          ),
                        ],
                      ),
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

  Widget _buildPreviewCard(bool isDark, AppLocalizations l10n) {
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
            Icons.preview_rounded,
            'Preview',
            AppColors.primary,
            isDark,
          ),
          const SizedBox(height: AlhaiSpacing.md),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AlhaiSpacing.md),
            decoration: BoxDecoration(
              color: isDark ? AppColors.backgroundDark : AppColors.surface,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: AppColors.getBorder(isDark),
                style: BorderStyle.solid,
              ),
            ),
            child: Column(
              children: [
                if (_showLogo) ...[
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.store_rounded,
                      color: AppColors.primary,
                      size: 24,
                    ),
                  ),
                  const SizedBox(height: AlhaiSpacing.xs),
                ],
                if (_headerController.text.isNotEmpty) ...[
                  Text(
                    _headerController.text,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: AppColors.getTextPrimary(isDark),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AlhaiSpacing.xs),
                ],
                if (_showStoreAddress)
                  Text(
                    'Sample Address',
                    style: TextStyle(
                      fontSize: 10,
                      color: AppColors.getTextMuted(isDark),
                    ),
                    textAlign: TextAlign.center,
                  ),
                Divider(color: AppColors.getBorder(isDark), height: 16),
                if (_showCashierName)
                  _previewRow(l10n.cashier, 'Sample Cashier Name', isDark),
                if (_showCustomerName)
                  _previewRow(l10n.customer, l10n.cashCustomer, isDark),
                Divider(color: AppColors.getBorder(isDark), height: 16),
                _previewRow('Sample Product', '25.00', isDark),
                _previewRow('Sample Product 2', '15.50', isDark),
                Divider(color: AppColors.getBorder(isDark), height: 16),
                _previewRow(
                  l10n.total,
                  '40.50 ${l10n.sar}',
                  isDark,
                  bold: true,
                ),
                if (_footerController.text.isNotEmpty) ...[
                  Divider(color: AppColors.getBorder(isDark), height: 16),
                  Text(
                    _footerController.text,
                    style: TextStyle(
                      fontSize: 10,
                      color: AppColors.getTextMuted(isDark),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _previewRow(
    String label,
    String value,
    bool isDark, {
    bool bold = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AlhaiSpacing.xxxs),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: bold ? FontWeight.bold : FontWeight.normal,
              color: AppColors.getTextPrimary(isDark),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 11,
              fontWeight: bold ? FontWeight.bold : FontWeight.normal,
              color: AppColors.getTextPrimary(isDark),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSaveButton(bool isDark, AppLocalizations l10n) {
    return SizedBox(
      width: double.infinity,
      child: FilledButton.icon(
        onPressed: _isSaving ? null : _saveSettings,
        icon: _isSaving
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColors.textOnPrimary,
                ),
              )
            : const Icon(Icons.save_rounded, size: 20),
        label: Text(
          l10n.saveSettings,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.textOnPrimary,
          padding: const EdgeInsets.symmetric(vertical: AlhaiSpacing.md),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  Widget _sectionHeader(IconData icon, String title, Color color, bool isDark) {
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

  Widget _toggleItem(
    String title,
    String subtitle,
    bool value,
    ValueChanged<bool> onChanged,
    bool isDark,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AlhaiSpacing.sm),
      child: Row(
        children: [
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
                const SizedBox(height: AlhaiSpacing.xxxs),
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
          Switch(
            value: value,
            onChanged: onChanged,
            activeTrackColor: AppColors.primary.withValues(alpha: 0.5),
            activeThumbColor: AppColors.primary,
          ),
        ],
      ),
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
