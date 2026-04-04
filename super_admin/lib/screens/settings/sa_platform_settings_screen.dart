import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:alhai_design_system/alhai_design_system.dart';
import 'package:alhai_l10n/alhai_l10n.dart';
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
  bool _zatcaEnabled = true;
  String _zatcaEnvironment = 'production';
  String _vatRate = '15';
  String _defaultLanguage = 'ar';
  int _trialPeriodDays = 14;
  bool _moyasarEnabled = true;
  bool _hyperpayEnabled = false;
  bool _tabbyEnabled = true;
  bool _tamaraEnabled = false;

  void _initFromData(Map<String, dynamic> data) {
    if (_initialized) return;
    _initialized = true;
    _zatcaEnabled = data['zatca_enabled'] as bool? ?? true;
    _zatcaEnvironment =
        data['zatca_environment'] as String? ?? 'production';
    final vat = data['vat_rate'];
    _vatRate = vat != null ? '$vat' : '15';
    _defaultLanguage =
        data['default_language'] as String? ?? 'ar';
    _trialPeriodDays =
        (data['trial_period_days'] as num?)?.toInt() ?? 14;
    _moyasarEnabled = data['moyasar_enabled'] as bool? ?? true;
    _hyperpayEnabled = data['hyperpay_enabled'] as bool? ?? false;
    _tabbyEnabled = data['tabby_enabled'] as bool? ?? true;
    _tamaraEnabled = data['tamara_enabled'] as bool? ?? false;
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
        error: (e, _) => Center(child: Text('Error: $e')),
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
                                title:
                                    const Text('ZATCA E-invoicing'),
                                subtitle: const Text(
                                  'Enable electronic invoicing compliance for all stores',
                                ),
                                value: _zatcaEnabled,
                                onChanged: (v) => setState(
                                    () => _zatcaEnabled = v),
                              ),
                              const Divider(),
                              ListTile(
                                title:
                                    const Text('API Environment'),
                                subtitle: Text(
                                    _zatcaEnvironment == 'production'
                                        ? 'Production'
                                        : 'Sandbox'),
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
                                      setState(() =>
                                          _zatcaEnvironment = v);
                                    }
                                  },
                                ),
                              ),
                              const Divider(),
                              ListTile(
                                title: const Text('Tax Rate (VAT)'),
                                subtitle: Text('$_vatRate%'),
                                trailing: SizedBox(
                                  width: 80,
                                  child: TextField(
                                    decoration: const InputDecoration(
                                      suffixText: '%',
                                      isDense: true,
                                    ),
                                    textAlign: TextAlign.center,
                                    controller:
                                        TextEditingController(
                                            text: _vatRate),
                                    onChanged: (v) =>
                                        _vatRate = v,
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
                                description:
                                    'Credit/debit card processing',
                                enabled: _moyasarEnabled,
                                onChanged: (v) => setState(
                                    () => _moyasarEnabled = v),
                              ),
                              const Divider(),
                              _GatewayTile(
                                name: 'HyperPay',
                                description:
                                    'Multi-method payment gateway',
                                enabled: _hyperpayEnabled,
                                onChanged: (v) => setState(
                                    () => _hyperpayEnabled = v),
                              ),
                              const Divider(),
                              _GatewayTile(
                                name: 'Tabby',
                                description: 'Buy now, pay later',
                                enabled: _tabbyEnabled,
                                onChanged: (v) => setState(
                                    () => _tabbyEnabled = v),
                              ),
                              const Divider(),
                              _GatewayTile(
                                name: 'Tamara',
                                description:
                                    'Installment payments',
                                enabled: _tamaraEnabled,
                                onChanged: (v) => setState(
                                    () => _tamaraEnabled = v),
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
                                title: const Text(
                                    'Default Language'),
                                trailing: DropdownButton<String>(
                                  value: _defaultLanguage,
                                  underline: const SizedBox(),
                                  items: const [
                                    DropdownMenuItem(
                                        value: 'ar',
                                        child: Text('Arabic')),
                                    DropdownMenuItem(
                                        value: 'en',
                                        child: Text('English')),
                                  ],
                                  onChanged: (v) {
                                    if (v != null) {
                                      setState(() =>
                                          _defaultLanguage = v);
                                    }
                                  },
                                ),
                              ),
                              const Divider(),
                              ListTile(
                                title: const Text(
                                    'Default Currency'),
                                subtitle: Text(
                                    'SAR - ${l10n.sar}'),
                                trailing: const Icon(
                                    Icons.chevron_right_rounded),
                              ),
                              const Divider(),
                              ListTile(
                                title: const Text(
                                    'Trial Period (Days)'),
                                trailing: SizedBox(
                                  width: 60,
                                  child: TextField(
                                    decoration:
                                        const InputDecoration(
                                      isDense: true,
                                    ),
                                    textAlign: TextAlign.center,
                                    controller:
                                        TextEditingController(
                                      text:
                                          '$_trialPeriodDays',
                                    ),
                                    onChanged: (v) {
                                      final parsed =
                                          int.tryParse(v);
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
