import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:alhai_design_system/alhai_design_system.dart';
import 'package:alhai_l10n/alhai_l10n.dart';
import '../../providers/sa_providers.dart';
import '../../core/services/undo_service.dart';

/// Store settings: suspend, upgrade, downgrade plan -- real Supabase operations.
class SAStoreSettingsScreen extends ConsumerStatefulWidget {
  final String storeId;
  const SAStoreSettingsScreen({super.key, required this.storeId});

  @override
  ConsumerState<SAStoreSettingsScreen> createState() =>
      _SAStoreSettingsScreenState();
}

class _SAStoreSettingsScreenState
    extends ConsumerState<SAStoreSettingsScreen> {
  bool? _isActive;
  String? _currentPlan;
  bool _saving = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final width = MediaQuery.sizeOf(context).width;
    final isWide = width >= AlhaiBreakpoints.desktop;

    final storeAsync = ref.watch(saStoreDetailProvider(widget.storeId));

    return Scaffold(
      body: storeAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (store) {
          final isActive = _isActive ?? store.isActive;

          // Extract current plan
          String planSlug = 'basic';
          if (store.subscriptions.isNotEmpty) {
            planSlug = store.subscriptions.first.planSlug ?? 'basic';
          }
          final currentPlan = _currentPlan ?? planSlug;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(AlhaiSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_rounded),
                      onPressed: () =>
                          context.go('/stores/${widget.storeId}'),
                    ),
                    const SizedBox(width: AlhaiSpacing.xs),
                    Text(
                      '${l10n.storeSettings} - ${store.name.isNotEmpty ? store.name : widget.storeId}',
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
                                  isActive ? l10n.active : l10n.suspended,
                                ),
                                subtitle: Text(
                                  isActive
                                      ? l10n.confirmSuspend
                                      : l10n.confirmActivate,
                                  style: theme.textTheme.bodySmall,
                                ),
                                value: isActive,
                                onChanged: (v) async {
                                  setState(() => _isActive = v);
                                  final ds =
                                      ref.read(saStoresDatasourceProvider);
                                  await ds.updateStoreStatus(
                                      widget.storeId, v);
                                  ref.invalidate(saStoreDetailProvider(
                                      widget.storeId));
                                  ref.invalidate(saStoresListProvider);
                                },
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
                                groupValue: currentPlan,
                                onChanged: (v) => setState(
                                    () => _currentPlan = v),
                              ),
                              _PlanRadio(
                                title: l10n.advancedPlan,
                                subtitle:
                                    '249 ${l10n.sar}${l10n.perMonth}',
                                value: 'advanced',
                                groupValue: currentPlan,
                                onChanged: (v) => setState(
                                    () => _currentPlan = v),
                              ),
                              _PlanRadio(
                                title: l10n.professionalPlan,
                                subtitle:
                                    '499 ${l10n.sar}${l10n.perMonth}',
                                value: 'professional',
                                groupValue: currentPlan,
                                onChanged: (v) => setState(
                                    () => _currentPlan = v),
                              ),
                              const SizedBox(height: AlhaiSpacing.md),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  FilledButton(
                                    onPressed: _saving
                                        ? null
                                        : () async {
                                            setState(
                                                () => _saving = true);
                                            try {
                                              final ds = ref.read(
                                                  saStoresDatasourceProvider);
                                              await ds.updateStorePlan(
                                                  widget.storeId,
                                                  currentPlan);
                                              ref.invalidate(
                                                  saStoreDetailProvider(
                                                      widget.storeId));
                                              if (mounted) {
                                                ScaffoldMessenger.of(
                                                        context)
                                                    .showSnackBar(
                                                  const SnackBar(
                                                    content: Text(
                                                        'Plan updated'),
                                                  ),
                                                );
                                              }
                                            } catch (e) {
                                              if (mounted) {
                                                ScaffoldMessenger.of(
                                                        context)
                                                    .showSnackBar(
                                                  SnackBar(
                                                    content: Text(
                                                        'Error: $e'),
                                                    backgroundColor:
                                                        theme.colorScheme.error,
                                                  ),
                                                );
                                              }
                                            } finally {
                                              if (mounted) {
                                                setState(
                                                    () => _saving = false);
                                              }
                                            }
                                          },
                                    child: _saving
                                        ? const SizedBox(
                                            width: 20,
                                            height: 20,
                                            child:
                                                CircularProgressIndicator(
                                                    strokeWidth: 2),
                                          )
                                        : const Text('Save Changes'),
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
                          borderColor: theme.colorScheme.error.withValues(alpha: 0.3),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                l10n.suspendStore,
                                style:
                                    theme.textTheme.bodyMedium?.copyWith(
                                  color: theme.colorScheme.error,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: AlhaiSpacing.xs),
                              Text(
                                'Suspending a store will immediately disable access for all store users. '
                                'Data will be preserved and the store can be reactivated later.',
                                style:
                                    theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.outline,
                                ),
                              ),
                              const SizedBox(height: AlhaiSpacing.md),
                              OutlinedButton(
                                onPressed: isActive
                                    ? () async {
                                        final confirmed = await showDialog<bool>(
                                          context: context,
                                          builder: (ctx) => AlertDialog(
                                            title: const Text('تأكيد الإيقاف'),
                                            content: const Text(
                                              'هل أنت متأكد من إيقاف هذا المتجر؟ سيتم تعطيل الوصول لجميع المستخدمين فوراً.',
                                            ),
                                            actions: [
                                              TextButton(
                                                onPressed: () => Navigator.pop(ctx, false),
                                                child: Text(l10n.cancel),
                                              ),
                                              FilledButton(
                                                style: FilledButton.styleFrom(
                                                  backgroundColor: theme.colorScheme.error,
                                                ),
                                                onPressed: () => Navigator.pop(ctx, true),
                                                child: Text(l10n.suspendStore),
                                              ),
                                            ],
                                          ),
                                        );
                                        if (confirmed != true || !context.mounted) return;

                                        final ds = ref.read(saStoresDatasourceProvider);
                                        await UndoService.executeWithUndo(
                                          context: context,
                                          description: 'تم تعليق المتجر',
                                          action: () async {
                                            await ds.softDeleteStore(widget.storeId);
                                            setState(() => _isActive = false);
                                            ref.invalidate(saStoreDetailProvider(widget.storeId));
                                            ref.invalidate(saStoresListProvider);
                                          },
                                          undoAction: () async {
                                            await ds.restoreStore(widget.storeId);
                                            setState(() => _isActive = true);
                                            ref.invalidate(saStoreDetailProvider(widget.storeId));
                                            ref.invalidate(saStoresListProvider);
                                          },
                                        );
                                      }
                                    : null,
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: theme.colorScheme.error,
                                  side: BorderSide(
                                      color: theme.colorScheme.error),
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
          );
        },
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
