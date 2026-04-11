/// شاشة إعدادات الضرائب - Tax Settings Screen
///
/// شاشة لإدارة إعدادات الضرائب وضريبة القيمة المضافة
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:alhai_shared_ui/alhai_shared_ui.dart';
import 'package:alhai_l10n/alhai_l10n.dart';
import 'package:alhai_database/alhai_database.dart';
import 'package:alhai_core/alhai_core.dart';
import '../../../providers/settings_db_providers.dart';
import 'package:alhai_design_system/alhai_design_system.dart';

// مفاتيح إعدادات الضرائب
const String _kTaxEnabled = 'tax_enabled';
const String _kTaxRate = 'tax_rate';
const String _kTaxNumber = 'tax_number';
const String _kTaxIncludeInPrice = 'tax_include_in_price';
const String _kTaxShowOnReceipt = 'tax_show_on_receipt';
const String _kZatcaEnabled = 'zatca_enabled';
const String _kZatcaPhase = 'zatca_phase';

/// شاشة إعدادات الضرائب
class TaxSettingsScreen extends ConsumerStatefulWidget {
  const TaxSettingsScreen({super.key});

  @override
  ConsumerState<TaxSettingsScreen> createState() => _TaxSettingsScreenState();
}

class _TaxSettingsScreenState extends ConsumerState<TaxSettingsScreen> {
  bool _enableVat = true;
  double _vatRate = 15.0;
  final _taxNumberController = TextEditingController(text: '310123456700003');
  bool _priceIncludesTax = true;
  bool _showTaxOnReceipt = true;
  bool _enableZatca = false;
  String _zatcaPhase = 'phase1';
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
      final settings = await getSettingsByPrefix(db, storeId, 'tax_');
      final zatcaSettings = await getSettingsByPrefix(db, storeId, 'zatca_');
      settings.addAll(zatcaSettings);

      if (mounted) {
        setState(() {
          _enableVat = settings[_kTaxEnabled] != 'false';
          _vatRate = double.tryParse(settings[_kTaxRate] ?? '') ?? 15.0;
          if (settings[_kTaxNumber] != null) {
            _taxNumberController.text = settings[_kTaxNumber]!;
          }
          _priceIncludesTax = settings[_kTaxIncludeInPrice] != 'false';
          _showTaxOnReceipt = settings[_kTaxShowOnReceipt] != 'false';
          _enableZatca = settings[_kZatcaEnabled] == 'true';
          _zatcaPhase = settings[_kZatcaPhase] ?? 'phase1';
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _saveSettings() async {
    setState(() => _isSaving = true);
    try {
      final storeId = ref.read(currentStoreIdProvider);
      if (storeId == null) return;

      final db = getIt<AppDatabase>();

      await saveSettingsBatch(
        db: db,
        storeId: storeId,
        settings: {
          _kTaxEnabled: _enableVat.toString(),
          _kTaxRate: _vatRate.toString(),
          _kTaxNumber: _taxNumberController.text,
          _kTaxIncludeInPrice: _priceIncludesTax.toString(),
          _kTaxShowOnReceipt: _showTaxOnReceipt.toString(),
          _kZatcaEnabled: _enableZatca.toString(),
          _kZatcaPhase: _zatcaPhase,
        },
        ref: ref,
      );

      if (mounted) {
        final l10n = AppLocalizations.of(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.taxSettingsSaved),
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
  void dispose() {
    _taxNumberController.dispose();
    super.dispose();
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
              title: l10n.taxSettings,
              onMenuTap: isWideScreen
                  ? null
                  : () => Scaffold.of(context).openDrawer(),
              onNotificationsTap: () => context.push('/notifications'),
              notificationsCount: 3,
              userName: l10n.defaultUserName,
              userRole: l10n.branchManager,
            ),
            const Expanded(child: Center(child: CircularProgressIndicator())),
          ],
        ),
      );
    }

    return SafeArea(
      child: Column(
        children: [
          AppHeader(
            title: l10n.taxSettings,
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
      ),
    );
  }

  Widget _buildContent(bool isDark, AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildPageHeader(isDark, l10n),
        const SizedBox(height: AlhaiSpacing.mdl),
        _buildSettingsGroup(
          l10n.vatSettings,
          Icons.percent_rounded,
          AppColors.success,
          isDark,
          [
            SwitchListTile(
              title: Text(
                l10n.enableVat,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              subtitle: Text(l10n.enableVatDesc),
              value: _enableVat,
              onChanged: (v) => setState(() => _enableVat = v),
            ),
            if (_enableVat) ...[
              const Divider(indent: 16, endIndent: 16),
              ListTile(
                title: Text(
                  l10n.taxRate,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                subtitle: Text('${_vatRate.toInt()}%'),
                trailing: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width > 600
                        ? 200
                        : 120,
                  ),
                  child: Slider(
                    value: _vatRate,
                    min: 5,
                    max: 20,
                    divisions: 3,
                    label: '${_vatRate.toInt()}%',
                    onChanged: (v) => setState(() => _vatRate = v),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(
                  AlhaiSpacing.mdl,
                  AlhaiSpacing.xs,
                  AlhaiSpacing.mdl,
                  AlhaiSpacing.xs,
                ),
                child: TextField(
                  controller: _taxNumberController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: l10n.taxNumber,
                    prefixIcon: const Icon(Icons.numbers),
                    helperText: l10n.taxNumberHint,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const Divider(indent: 16, endIndent: 16),
              SwitchListTile(
                title: Text(
                  l10n.pricesIncludeTax,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                subtitle: Text(l10n.pricesIncludeTaxDesc),
                value: _priceIncludesTax,
                onChanged: (v) => setState(() => _priceIncludesTax = v),
              ),
              SwitchListTile(
                title: Text(
                  l10n.showTaxOnReceipt,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                subtitle: Text(l10n.showTaxOnReceiptDesc),
                value: _showTaxOnReceipt,
                onChanged: (v) => setState(() => _showTaxOnReceipt = v),
              ),
            ],
            const SizedBox(height: AlhaiSpacing.xs),
          ],
        ),
        _buildSettingsGroup(
          l10n.zatcaEInvoicing,
          Icons.verified_rounded,
          AppColors.primary,
          isDark,
          [
            SwitchListTile(
              title: Text(
                l10n.enableZatca,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              subtitle: Text(l10n.enableZatcaDesc),
              value: _enableZatca,
              onChanged: (v) => setState(() => _enableZatca = v),
            ),
            if (_enableZatca) ...[
              const Divider(indent: 16, endIndent: 16),
              RadioGroup<String>(
                groupValue: _zatcaPhase,
                onChanged: (v) => setState(() => _zatcaPhase = v!),
                child: Column(
                  children: [
                    RadioListTile<String>(
                      title: Text(
                        l10n.phaseOne,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                      subtitle: Text(l10n.phaseOneDesc),
                      value: 'phase1',
                    ),
                    RadioListTile<String>(
                      title: Text(
                        l10n.phaseTwo,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                      subtitle: Text(l10n.phaseTwoDesc),
                      value: 'phase2',
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: AlhaiSpacing.xs),
          ],
        ),
        const SizedBox(height: AlhaiSpacing.md),
        SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            onPressed: _isSaving ? null : _saveSettings,
            icon: _isSaving
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Icon(Icons.save_rounded),
            label: Text(l10n.saveSettings),
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: AlhaiSpacing.md),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
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
            color: AppColors.success.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(
            Icons.percent_rounded,
            color: AppColors.success,
            size: 24,
          ),
        ),
        const SizedBox(width: AlhaiSpacing.sm),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.taxSettings,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            Text(
              l10n.taxSettingsSubtitle,
              style: TextStyle(
                fontSize: 13,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSettingsGroup(
    String title,
    IconData icon,
    Color color,
    bool isDark,
    List<Widget> children,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: AlhaiSpacing.md),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(
              AlhaiSpacing.mdl,
              AlhaiSpacing.md,
              AlhaiSpacing.mdl,
              AlhaiSpacing.xs,
            ),
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
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ),
          ...children,
        ],
      ),
    );
  }
}
