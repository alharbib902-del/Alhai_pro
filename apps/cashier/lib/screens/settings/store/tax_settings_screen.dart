/// Tax Settings Screen - VAT and tax configuration
///
/// Display current tax rate (15% VAT default), tax number,
/// toggle tax inclusive/exclusive, save to local settings.
/// Supports: RTL Arabic, dark/light theme, responsive layout.
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:get_it/get_it.dart';
import 'package:alhai_shared_ui/alhai_shared_ui.dart';
import 'package:alhai_l10n/alhai_l10n.dart';
import 'package:alhai_database/alhai_database.dart';
import 'package:alhai_auth/alhai_auth.dart';
import 'package:alhai_design_system/alhai_design_system.dart'
    show AlhaiBreakpoints, AlhaiSnackbar, AlhaiSpacing;
// alhai_design_system is re-exported via alhai_shared_ui
import '../../../core/services/sentry_service.dart';

/// Tax settings screen
class TaxSettingsScreen extends ConsumerStatefulWidget {
  const TaxSettingsScreen({super.key});

  @override
  ConsumerState<TaxSettingsScreen> createState() => _TaxSettingsScreenState();
}

class _TaxSettingsScreenState extends ConsumerState<TaxSettingsScreen> {
  final _db = GetIt.I<AppDatabase>();
  final _taxRateController = TextEditingController(text: '15');
  final _taxNumberController = TextEditingController();

  bool _isLoading = true;
  bool _isSaving = false;
  String? _error;
  bool _taxInclusive = true;
  bool _taxEnabled = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  @override
  void dispose() {
    _taxRateController.dispose();
    _taxNumberController.dispose();
    super.dispose();
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

  Future<void> _loadSettings() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      // Null + empty guard: Drift `.equals('')` is a valid query but
      // would match rows where storeId is literally empty — refuse to
      // run in that state instead of silently mis-scoping the read.
      final storeId = ref.read(currentStoreIdProvider);
      if (storeId == null || storeId.isEmpty) return;

      final store = await _db.storesDao.getStoreById(storeId);
      if (store != null && mounted) {
        _taxNumberController.text = store.taxNumber ?? '';
      }
      // Load from settings table
      final settings = await (_db.select(
        _db.settingsTable,
      )..where((s) => s.storeId.equals(storeId))).get();
      for (final s in settings) {
        if (s.key == 'tax_rate') {
          // Read path tolerates both legacy (decimal string like '15'
          // or '15.0') and the new canonical basis-points integer
          // ('1500' → 15.00%). Integer values with no dot get divided
          // by 100 to recover the percentage; anything that looks like
          // a float is trusted as the legacy percent string.
          _taxRateController.text = _decodeStoredTaxRate(s.value);
        } else if (s.key == 'tax_inclusive') {
          _taxInclusive = s.value == 'true';
        } else if (s.key == 'tax_enabled') {
          _taxEnabled = s.value != 'false';
        }
      }
    } catch (e, stack) {
      reportError(e, stackTrace: stack, hint: 'Load tax settings');
      if (mounted) setState(() => _error = '$e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  /// Parse + validate the tax-rate field. Returns null when the input is
  /// not a finite number in [0, 100]. ZATCA invoices reject negative or
  /// >100 rates, and unparseable values would crash the receipt builder
  /// later in the flow.
  double? _parseTaxRate(String raw) {
    final text = raw.trim();
    if (text.isEmpty) return null;
    final value = double.tryParse(text);
    if (value == null || !value.isFinite) return null;
    if (value < 0 || value > 100) return null;
    return value;
  }

  /// Decode a stored tax rate back to a user-facing percent string.
  ///
  /// Backwards-compatible with legacy rows written as '15', '15.0', or
  /// '15.00'. New rows use basis-points ('1500' = 15.00%), stored as an
  /// integer so the double round-trip can't drift.
  String _decodeStoredTaxRate(String stored) {
    final trimmed = stored.trim();
    if (trimmed.isEmpty) return '15';

    // Integer-only → basis-points. 1500 → '15', 1525 → '15.25'.
    if (!trimmed.contains('.')) {
      final bps = int.tryParse(trimmed);
      if (bps != null) {
        final percent = bps / 100.0;
        // Drop trailing zeros: 15.00 → '15', 15.50 → '15.5'.
        final asStr = percent.toStringAsFixed(2);
        return asStr
            .replaceFirst(RegExp(r'\.?0+$'), '')
            .ifEmpty('0');
      }
    }

    // Legacy decimal string — trust it, but keep bounds behaviour so
    // garbage rows don't crash the TextField.
    final asDouble = double.tryParse(trimmed);
    if (asDouble == null || !asDouble.isFinite) return '15';
    return trimmed;
  }

  /// Encode a percent (e.g. 15.0) to the canonical basis-points string.
  /// 15 → '1500', 15.5 → '1550', 15.25 → '1525'.
  String _encodeTaxRateAsBasisPoints(double percent) {
    return (percent * 100).round().toString();
  }

  Future<void> _saveSettings() async {
    final l10n = AppLocalizations.of(context);

    // Validator: a bad tax rate poisons every subsequent ZATCA invoice.
    // Refuse the save here rather than letting `double.parse` blow up
    // somewhere downstream.
    final rate = _parseTaxRate(_taxRateController.text);
    if (rate == null) {
      AlhaiSnackbar.error(
        context,
        'نسبة ضريبة غير صالحة — أدخل رقماً بين 0 و 100',
      );
      return;
    }

    setState(() => _isSaving = true);
    try {
      // Canonical form: basis-points integer string. 15% → '1500',
      // 15.25% → '1525'. Avoids double-precision drift that would
      // otherwise bite downstream tax math (a 15.0 that reads back as
      // 14.999999… compounds across dozens of invoices per day).
      await _upsertSetting('tax_rate', _encodeTaxRateAsBasisPoints(rate));
      await _upsertSetting('tax_inclusive', _taxInclusive.toString());
      await _upsertSetting('tax_enabled', _taxEnabled.toString());

      if (mounted) {
        AlhaiSnackbar.success(context, l10n.settingsSaved);
      }
    } catch (e, stack) {
      reportError(e, stackTrace: stack, hint: 'Save tax settings');
      if (mounted) {
        AlhaiSnackbar.error(
          context,
          AppLocalizations.of(context).errorSavingSettings('$e'),
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
          title: l10n.taxSettings,
          subtitle: l10n.taxSettingsSubtitle,
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
            child: Column(
              children: [
                _buildTaxRateCard(isDark, l10n),
                const SizedBox(height: AlhaiSpacing.lg),
                _buildTaxNumberCard(isDark, l10n),
              ],
            ),
          ),
          const SizedBox(width: AlhaiSpacing.lg),
          Expanded(
            child: Column(
              children: [
                _buildOptionsCard(isDark, l10n),
                const SizedBox(height: AlhaiSpacing.lg),
                _buildSaveButton(isDark, l10n),
              ],
            ),
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildTaxRateCard(isDark, l10n),
        SizedBox(height: isMediumScreen ? AlhaiSpacing.lg : AlhaiSpacing.md),
        _buildTaxNumberCard(isDark, l10n),
        SizedBox(height: isMediumScreen ? AlhaiSpacing.lg : AlhaiSpacing.md),
        _buildOptionsCard(isDark, l10n),
        const SizedBox(height: AlhaiSpacing.lg),
        _buildSaveButton(isDark, l10n),
      ],
    );
  }

  Widget _buildTaxRateCard(bool isDark, AppLocalizations l10n) {
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
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AlhaiSpacing.xs),
                decoration: BoxDecoration(
                  color: AppColors.info.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.percent_rounded,
                  color: AppColors.info,
                  size: 20,
                ),
              ),
              const SizedBox(width: AlhaiSpacing.sm),
              Text(
                l10n.taxRate,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.getTextPrimary(isDark),
                ),
              ),
            ],
          ),
          const SizedBox(height: AlhaiSpacing.mdl),
          TextField(
            controller: _taxRateController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            // Defence-in-depth alongside _parseTaxRate: keeps a clean
            // numeric string in the controller so save-time validation
            // only has to range-check.
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'^\d{0,3}(\.\d{0,2})?')),
            ],
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: AppColors.getTextPrimary(isDark),
            ),
            decoration: InputDecoration(
              hintText: '15',
              hintStyle: TextStyle(
                color: AppColors.getTextMuted(isDark),
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
              suffixText: '%',
              suffixStyle: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.getTextSecondary(isDark),
              ),
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
                borderSide: const BorderSide(
                  color: AppColors.primary,
                  width: 2,
                ),
              ),
              filled: true,
              fillColor: AppColors.getSurfaceVariant(isDark),
            ),
          ),
          const SizedBox(height: AlhaiSpacing.sm),
          Text(
            'ضريبة القيمة المضافة السعودية 15٪',
            style: TextStyle(
              fontSize: 12,
              color: AppColors.getTextMuted(isDark),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTaxNumberCard(bool isDark, AppLocalizations l10n) {
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
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AlhaiSpacing.xs),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.numbers_rounded,
                  color: AppColors.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: AlhaiSpacing.sm),
              Text(
                l10n.taxNumber,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.getTextPrimary(isDark),
                ),
              ),
            ],
          ),
          const SizedBox(height: AlhaiSpacing.mdl),
          TextField(
            controller: _taxNumberController,
            readOnly: true,
            style: TextStyle(
              fontSize: 16,
              color: AppColors.getTextPrimary(isDark),
            ),
            decoration: InputDecoration(
              hintText: l10n.taxNumberHint,
              hintStyle: TextStyle(color: AppColors.getTextMuted(isDark)),
              prefixIcon: Icon(
                Icons.verified_rounded,
                color: AppColors.getTextMuted(isDark),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: AppColors.getBorder(isDark)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: AppColors.getBorder(isDark)),
              ),
              filled: true,
              fillColor: AppColors.getSurfaceVariant(isDark),
            ),
          ),
          const SizedBox(height: AlhaiSpacing.xs),
          Text(
            'الرقم الضريبي (للقراءة فقط)',
            style: TextStyle(
              fontSize: 12,
              color: AppColors.getTextMuted(isDark),
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOptionsCard(bool isDark, AppLocalizations l10n) {
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
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AlhaiSpacing.xs),
                decoration: BoxDecoration(
                  color: AppColors.warning.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.settings_rounded,
                  color: AppColors.warning,
                  size: 20,
                ),
              ),
              const SizedBox(width: AlhaiSpacing.sm),
              Text(
                'خيارات الضريبة',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.getTextPrimary(isDark),
                ),
              ),
            ],
          ),
          const SizedBox(height: AlhaiSpacing.mdl),
          _ToggleRow(
            icon: Icons.toggle_on_rounded,
            title: 'تفعيل الضريبة',
            subtitle: 'تطبيق الضريبة على جميع المبيعات',
            value: _taxEnabled,
            isDark: isDark,
            onChanged: (v) => setState(() => _taxEnabled = v),
          ),
          Divider(color: AppColors.getBorder(isDark), height: 1),
          _ToggleRow(
            icon: Icons.price_check_rounded,
            title: 'السعر شامل الضريبة',
            subtitle: l10n.pricesIncludeTax,
            value: _taxInclusive,
            isDark: isDark,
            onChanged: _taxEnabled
                ? (v) => setState(() => _taxInclusive = v)
                : null,
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
}

/// Private String helper used by the basis-point decoder so stripping
/// trailing zeros can never leave an empty string.
extension _StringIfEmpty on String {
  String ifEmpty(String fallback) => isEmpty ? fallback : this;
}

/// Toggle row widget for settings
class _ToggleRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final bool isDark;
  final ValueChanged<bool>? onChanged;

  const _ToggleRow({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.isDark,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isDisabled = onChanged == null;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Row(
        children: [
          Icon(
            icon,
            size: 20,
            color: isDisabled
                ? AppColors.getTextMuted(isDark)
                : AppColors.getTextSecondary(isDark),
          ),
          const SizedBox(width: AlhaiSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isDisabled
                        ? AppColors.getTextMuted(isDark)
                        : AppColors.getTextPrimary(isDark),
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
}
