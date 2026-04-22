import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:alhai_design_system/alhai_design_system.dart';
import 'package:alhai_l10n/alhai_l10n.dart';

import '../../core/services/sentry_service.dart';
import '../../data/models/sa_analytics_model.dart';
import '../../providers/sa_providers.dart';

/// Platform settings: ZATCA config, payment gateways -- real Supabase data.
class SAPlatformSettingsScreen extends ConsumerStatefulWidget {
  const SAPlatformSettingsScreen({super.key});

  @override
  ConsumerState<SAPlatformSettingsScreen> createState() =>
      _SAPlatformSettingsScreenState();
}

class _SAPlatformSettingsScreenState
    extends ConsumerState<SAPlatformSettingsScreen> {
  // Local state mirrors -- initialized from provider data
  bool _initialized = false;
  bool _saving = false;
  SAPlatformSettings? _original;

  bool _zatcaEnabled = true;
  String _zatcaEnvironment = 'production';
  String _vatRate = '15';
  String _defaultLanguage = 'ar';
  int _trialPeriodDays = 14;
  bool _moyasarEnabled = true;
  bool _hyperpayEnabled = false;
  bool _tabbyEnabled = true;
  bool _tamaraEnabled = false;

  void _initFromData(SAPlatformSettings data) {
    if (_initialized) return;
    _initialized = true;
    _original = data;
    _zatcaEnabled = data.zatcaEnabled;
    _zatcaEnvironment = data.zatcaEnvironment;
    _vatRate = '${data.vatRate}';
    _defaultLanguage = data.defaultLanguage;
    _trialPeriodDays = data.trialPeriodDays;
    _moyasarEnabled = data.moyasarEnabled;
    _hyperpayEnabled = data.hyperpayEnabled;
    _tabbyEnabled = data.tabbyEnabled;
    _tamaraEnabled = data.tamaraEnabled;
  }

  /// True when any local field differs from the last loaded snapshot.
  bool get _isDirty {
    final o = _original;
    if (o == null) return false;
    final parsedVat = double.tryParse(_vatRate) ?? o.vatRate;
    return _zatcaEnabled != o.zatcaEnabled ||
        _zatcaEnvironment != o.zatcaEnvironment ||
        parsedVat != o.vatRate ||
        _defaultLanguage != o.defaultLanguage ||
        _trialPeriodDays != o.trialPeriodDays ||
        _moyasarEnabled != o.moyasarEnabled ||
        _hyperpayEnabled != o.hyperpayEnabled ||
        _tabbyEnabled != o.tabbyEnabled ||
        _tamaraEnabled != o.tamaraEnabled;
  }

  void _resetFromOriginal() {
    final o = _original;
    if (o == null) return;
    setState(() {
      _zatcaEnabled = o.zatcaEnabled;
      _zatcaEnvironment = o.zatcaEnvironment;
      _vatRate = '${o.vatRate}';
      _defaultLanguage = o.defaultLanguage;
      _trialPeriodDays = o.trialPeriodDays;
      _moyasarEnabled = o.moyasarEnabled;
      _hyperpayEnabled = o.hyperpayEnabled;
      _tabbyEnabled = o.tabbyEnabled;
      _tamaraEnabled = o.tamaraEnabled;
    });
  }

  Future<void> _save(SAPlatformSettings original) async {
    final l10n = AppLocalizations.of(context);

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.saSaveChanges),
        content: Text(l10n.saPlatformSettingsConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(l10n.saDiscardChanges),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(l10n.saConfirmSave),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    if (!mounted) return;

    setState(() => _saving = true);
    try {
      final vatRate = double.tryParse(_vatRate) ?? original.vatRate;
      final client = ref.read(saSupabaseClientProvider);
      await client.rpc(
        'update_platform_settings',
        params: {
          'p_zatca_enabled': _zatcaEnabled,
          'p_zatca_environment': _zatcaEnvironment,
          'p_vat_rate': vatRate,
          'p_default_language': _defaultLanguage,
          'p_default_currency': original.defaultCurrency,
          'p_trial_period_days': _trialPeriodDays,
          'p_moyasar_enabled': _moyasarEnabled,
          'p_hyperpay_enabled': _hyperpayEnabled,
          'p_tabby_enabled': _tabbyEnabled,
          'p_tamara_enabled': _tamaraEnabled,
        },
      );
      if (!mounted) return;

      // Force a re-read so the displayed values match what Supabase now has,
      // and reset the dirty-tracking snapshot on the next rebuild.
      _initialized = false;
      ref.invalidate(saPlatformSettingsProvider);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.saPlatformSettingsSaved)),
      );
    } catch (e, st) {
      await reportError(e, stackTrace: st, hint: 'platform_settings.save');
      if (!mounted) return;
      // Preserve the user's unsaved local edits -- do NOT invalidate here.
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.of(context).saPlatformSettingsSaveFailed,
          ),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final width = MediaQuery.sizeOf(context).width;
    final isWide = width >= AlhaiBreakpoints.desktop;
    final settingsAsync = ref.watch(saPlatformSettingsProvider);

    return Scaffold(
      body: settingsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text(l10n.saErrorLoadingSettings)),
        data: (data) {
          _initFromData(data);

          return SingleChildScrollView(
            padding: const EdgeInsets.all(AlhaiSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.platformSettings,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: AlhaiSpacing.lg),
                Center(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: isWide ? 800 : double.infinity,
                    ),
                    child: Column(
                      children: [
                        // ZATCA Configuration
                        _SettingsSection(
                          title: l10n.zatcaConfig,
                          icon: Icons.receipt_long_rounded,
                          child: Column(
                            children: [
                              SwitchListTile(
                                title: Text(l10n.saZatcaEInvoicing),
                                subtitle: Text(l10n.saEnableEInvoicing),
                                value: _zatcaEnabled,
                                onChanged: (v) =>
                                    setState(() => _zatcaEnabled = v),
                              ),
                              const Divider(),
                              ListTile(
                                title: Text(l10n.saApiEnvironment),
                                subtitle: Text(
                                  _zatcaEnvironment == 'production'
                                      ? 'Production'
                                      : 'Sandbox',
                                ),
                                trailing: DropdownButton<String>(
                                  value: _zatcaEnvironment,
                                  underline: const SizedBox(),
                                  items: const [
                                    DropdownMenuItem(
                                      value: 'sandbox',
                                      child: Text('Sandbox'),
                                    ),
                                    DropdownMenuItem(
                                      value: 'production',
                                      child: Text('Production'),
                                    ),
                                  ],
                                  onChanged: (v) {
                                    if (v != null) {
                                      setState(() => _zatcaEnvironment = v);
                                    }
                                  },
                                ),
                              ),
                              const Divider(),
                              ListTile(
                                title: Text(l10n.saTaxRateVat),
                                subtitle: Text('$_vatRate%'),
                                trailing: SizedBox(
                                  width: 80,
                                  child: TextField(
                                    decoration: const InputDecoration(
                                      suffixText: '%',
                                      isDense: true,
                                    ),
                                    textAlign: TextAlign.center,
                                    controller: TextEditingController(
                                      text: _vatRate,
                                    ),
                                    onChanged: (v) => _vatRate = v,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: AlhaiSpacing.md),

                        // Payment Gateways
                        _SettingsSection(
                          title: l10n.paymentGateways,
                          icon: Icons.payment_rounded,
                          child: Column(
                            children: [
                              _GatewayTile(
                                name: 'Moyasar',
                                description: 'Credit/debit card processing',
                                enabled: _moyasarEnabled,
                                onChanged: (v) =>
                                    setState(() => _moyasarEnabled = v),
                              ),
                              const Divider(),
                              _GatewayTile(
                                name: 'HyperPay',
                                description: 'Multi-method payment gateway',
                                enabled: _hyperpayEnabled,
                                onChanged: (v) =>
                                    setState(() => _hyperpayEnabled = v),
                              ),
                              const Divider(),
                              _GatewayTile(
                                name: 'Tabby',
                                description: 'Buy now, pay later',
                                enabled: _tabbyEnabled,
                                onChanged: (v) =>
                                    setState(() => _tabbyEnabled = v),
                              ),
                              const Divider(),
                              _GatewayTile(
                                name: 'Tamara',
                                description: 'Installment payments',
                                enabled: _tamaraEnabled,
                                onChanged: (v) =>
                                    setState(() => _tamaraEnabled = v),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: AlhaiSpacing.md),

                        // General platform settings
                        _SettingsSection(
                          title: 'General',
                          icon: Icons.tune_rounded,
                          child: Column(
                            children: [
                              ListTile(
                                title: Text(l10n.saDefaultLanguage),
                                trailing: DropdownButton<String>(
                                  value: _defaultLanguage,
                                  underline: const SizedBox(),
                                  items: const [
                                    DropdownMenuItem(
                                      value: 'ar',
                                      child: Text('Arabic'),
                                    ),
                                    DropdownMenuItem(
                                      value: 'en',
                                      child: Text('English'),
                                    ),
                                  ],
                                  onChanged: (v) {
                                    if (v != null) {
                                      setState(() => _defaultLanguage = v);
                                    }
                                  },
                                ),
                              ),
                              const Divider(),
                              ListTile(
                                title: Text(l10n.saDefaultCurrency),
                                subtitle: Text('SAR - ${l10n.sar}'),
                                trailing: const Icon(
                                  Icons.chevron_right_rounded,
                                ),
                              ),
                              const Divider(),
                              ListTile(
                                title: Text(l10n.saTrialPeriodDays),
                                trailing: SizedBox(
                                  width: 60,
                                  child: TextField(
                                    decoration: const InputDecoration(
                                      isDense: true,
                                    ),
                                    textAlign: TextAlign.center,
                                    controller: TextEditingController(
                                      text: '$_trialPeriodDays',
                                    ),
                                    onChanged: (v) {
                                      final parsed = int.tryParse(v);
                                      if (parsed != null) {
                                        _trialPeriodDays = parsed;
                                      }
                                    },
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: AlhaiSpacing.lg),

                        // Save / Discard action row.
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton(
                              onPressed: (_isDirty && !_saving)
                                  ? _resetFromOriginal
                                  : null,
                              child: Text(l10n.saDiscardChanges),
                            ),
                            const SizedBox(width: AlhaiSpacing.md),
                            FilledButton(
                              onPressed: (_isDirty && !_saving)
                                  ? () => _save(data)
                                  : null,
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  if (_saving)
                                    const SizedBox(
                                      width: 16,
                                      height: 16,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    )
                                  else
                                    const Icon(Icons.save_rounded, size: 18),
                                  const SizedBox(width: 8),
                                  Text(
                                    _saving
                                        ? l10n.saSaving
                                        : l10n.saSaveChanges,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _SettingsSection extends StatelessWidget {
  final String title;
  final IconData icon;
  final Widget child;

  const _SettingsSection({
    required this.title,
    required this.icon,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AlhaiRadius.card),
        side: BorderSide(
          color: theme.colorScheme.outlineVariant,
          width: AlhaiSpacing.strokeXs,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AlhaiSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 20, color: theme.colorScheme.primary),
                const SizedBox(width: AlhaiSpacing.xs),
                Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const Divider(height: AlhaiSpacing.xl),
            child,
          ],
        ),
      ),
    );
  }
}

class _GatewayTile extends StatelessWidget {
  final String name;
  final String description;
  final bool enabled;
  final ValueChanged<bool> onChanged;

  const _GatewayTile({
    required this.name,
    required this.description,
    required this.enabled,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      title: Text(name),
      subtitle: Text(description),
      value: enabled,
      onChanged: onChanged,
    );
  }
}
