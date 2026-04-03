import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:alhai_design_system/alhai_design_system.dart';
import 'package:alhai_l10n/alhai_l10n.dart';

/// Store settings: suspend, upgrade, downgrade plan.
class SAStoreSettingsScreen extends StatefulWidget {
  final String storeId;
  const SAStoreSettingsScreen({super.key, required this.storeId});

  @override
  State<SAStoreSettingsScreen> createState() => _SAStoreSettingsScreenState();
}

class _SAStoreSettingsScreenState extends State<SAStoreSettingsScreen> {
  bool _isActive = true;
  String _currentPlan = 'professional';

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
            // Back + title
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back_rounded),
                  onPressed: () =>
                      context.go('/stores/${widget.storeId}'),
                ),
                const SizedBox(width: AlhaiSpacing.xs),
                Text(
                  '${l10n.storeSettings} - ${widget.storeId}',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AlhaiSpacing.lg),

            Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: isWide ? 700 : double.infinity,
                ),
                child: Column(
                  children: [
                    // Status card
                    _SettingsCard(
                      title: l10n.storeStatus,
                      icon: Icons.power_settings_new_rounded,
                      child: Column(
                        children: [
                          SwitchListTile(
                            title: Text(
                              _isActive
                                  ? l10n.active
                                  : l10n.suspended,
                            ),
                            subtitle: Text(
                              _isActive
                                  ? l10n.confirmSuspend
                                  : l10n.confirmActivate,
                              style: theme.textTheme.bodySmall,
                            ),
                            value: _isActive,
                            onChanged: (v) =>
                                setState(() => _isActive = v),
                          ),
                          if (!_isActive)
                            Padding(
                              padding: const EdgeInsets.only(
                                top: AlhaiSpacing.sm,
                              ),
                              child: FilledButton.tonal(
                                onPressed: () =>
                                    setState(() => _isActive = true),
                                child: Text(l10n.activateStore),
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AlhaiSpacing.md),

                    // Plan management card
                    _SettingsCard(
                      title: l10n.storePlan,
                      icon: Icons.card_membership_rounded,
                      child: Column(
                        children: [
                          _PlanRadio(
                            title: l10n.basicPlan,
                            subtitle:
                                '99 ${l10n.sar}${l10n.perMonth}',
                            value: 'basic',
                            groupValue: _currentPlan,
                            onChanged: (v) =>
                                setState(() => _currentPlan = v!),
                          ),
                          _PlanRadio(
                            title: l10n.advancedPlan,
                            subtitle:
                                '249 ${l10n.sar}${l10n.perMonth}',
                            value: 'advanced',
                            groupValue: _currentPlan,
                            onChanged: (v) =>
                                setState(() => _currentPlan = v!),
                          ),
                          _PlanRadio(
                            title: l10n.professionalPlan,
                            subtitle:
                                '499 ${l10n.sar}${l10n.perMonth}',
                            value: 'professional',
                            groupValue: _currentPlan,
                            onChanged: (v) =>
                                setState(() => _currentPlan = v!),
                          ),
                          const SizedBox(height: AlhaiSpacing.md),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              FilledButton(
                                onPressed: () {
                                  ScaffoldMessenger.of(context)
                                      .showSnackBar(
                                    const SnackBar(
                                      content: Text('Plan updated'),
                                    ),
                                  );
                                },
                                child: const Text('Save Changes'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AlhaiSpacing.md),

                    // Danger zone
                    _SettingsCard(
                      title: 'Danger Zone',
                      icon: Icons.warning_rounded,
                      borderColor: Colors.red.withValues(alpha: 0.3),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.suspendStore,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: Colors.red,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: AlhaiSpacing.xs),
                          Text(
                            'Suspending a store will immediately disable access for all store users. '
                            'Data will be preserved and the store can be reactivated later.',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.outline,
                            ),
                          ),
                          const SizedBox(height: AlhaiSpacing.md),
                          OutlinedButton(
                            onPressed: _isActive
                                ? () =>
                                    setState(() => _isActive = false)
                                : null,
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.red,
                              side: const BorderSide(color: Colors.red),
                            ),
                            child: Text(l10n.suspendStore),
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

class _SettingsCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Widget child;
  final Color? borderColor;

  const _SettingsCard({
    required this.title,
    required this.icon,
    required this.child,
    this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AlhaiRadius.card),
        side: BorderSide(
          color: borderColor ?? theme.colorScheme.outlineVariant,
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
                Icon(icon, size: 20),
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

class _PlanRadio extends StatelessWidget {
  final String title;
  final String subtitle;
  final String value;
  final String groupValue;
  final ValueChanged<String?> onChanged;

  const _PlanRadio({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.groupValue,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return RadioListTile<String>(
      title: Text(title),
      subtitle: Text(subtitle),
      value: value,
      groupValue: groupValue,
      onChanged: onChanged,
    );
  }
}
