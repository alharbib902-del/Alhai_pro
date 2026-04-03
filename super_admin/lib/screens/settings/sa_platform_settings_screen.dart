import 'package:flutter/material.dart';
import 'package:alhai_design_system/alhai_design_system.dart';
import 'package:alhai_l10n/alhai_l10n.dart';

/// Platform settings: ZATCA config, payment gateways.
class SAPlatformSettingsScreen extends StatefulWidget {
  const SAPlatformSettingsScreen({super.key});

  @override
  State<SAPlatformSettingsScreen> createState() =>
      _SAPlatformSettingsScreenState();
}

class _SAPlatformSettingsScreenState
    extends State<SAPlatformSettingsScreen> {
  bool _zatcaEnabled = true;
  bool _moyasarEnabled = true;
  bool _hyperpayEnabled = false;
  bool _tabbyEnabled = true;
  bool _tamaraEnabled = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final width = MediaQuery.sizeOf(context).width;
    final isWide = width >= AlhaiBreakpoints.desktop;

    return Scaffold(
      body: SingleChildScrollView(
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
                            title: const Text('ZATCA E-invoicing'),
                            subtitle: const Text(
                              'Enable electronic invoicing compliance for all stores',
                            ),
                            value: _zatcaEnabled,
                            onChanged: (v) =>
                                setState(() => _zatcaEnabled = v),
                          ),
                          const Divider(),
                          ListTile(
                            title: const Text('API Environment'),
                            subtitle: const Text('Production'),
                            trailing: DropdownButton<String>(
                              value: 'production',
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
                              onChanged: (_) {},
                            ),
                          ),
                          const Divider(),
                          ListTile(
                            title: const Text('Tax Rate (VAT)'),
                            subtitle: const Text('15%'),
                            trailing: SizedBox(
                              width: 80,
                              child: TextField(
                                decoration: const InputDecoration(
                                  suffixText: '%',
                                  isDense: true,
                                ),
                                textAlign: TextAlign.center,
                                controller:
                                    TextEditingController(text: '15'),
                              ),
                            ),
                          ),
                          const Divider(),
                          ListTile(
                            title: const Text(
                                'Certificate Expiry'),
                            subtitle: const Text('2025-12-31'),
                            trailing: FilledButton.tonal(
                              onPressed: () {},
                              child: const Text('Renew'),
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
                            onChanged: (v) =>
                                setState(() => _tabbyEnabled = v),
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
                            title: const Text('Default Language'),
                            trailing: DropdownButton<String>(
                              value: 'ar',
                              underline: const SizedBox(),
                              items: const [
                                DropdownMenuItem(
                                    value: 'ar',
                                    child: Text('Arabic')),
                                DropdownMenuItem(
                                    value: 'en',
                                    child: Text('English')),
                              ],
                              onChanged: (_) {},
                            ),
                          ),
                          const Divider(),
                          ListTile(
                            title: const Text('Default Currency'),
                            subtitle: Text(
                                'SAR - ${l10n.sar}'),
                            trailing: const Icon(
                                Icons.chevron_right_rounded),
                          ),
                          const Divider(),
                          ListTile(
                            title: const Text('Trial Period (Days)'),
                            trailing: SizedBox(
                              width: 60,
                              child: TextField(
                                decoration: const InputDecoration(
                                  isDense: true,
                                ),
                                textAlign: TextAlign.center,
                                controller:
                                    TextEditingController(text: '14'),
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
