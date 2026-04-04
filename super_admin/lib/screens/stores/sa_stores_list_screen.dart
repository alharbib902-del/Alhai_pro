import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:alhai_design_system/alhai_design_system.dart';
import 'package:alhai_l10n/alhai_l10n.dart';
import '../../core/router/app_router.dart';
import '../../providers/sa_providers.dart';

/// Stores list with search, filter by status/plan -- real Supabase data.
class SAStoresListScreen extends ConsumerStatefulWidget {
  const SAStoresListScreen({super.key});

  @override
  ConsumerState<SAStoresListScreen> createState() => _SAStoresListScreenState();
}

class _SAStoresListScreenState extends ConsumerState<SAStoresListScreen> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _applySearch(String query) {
    ref.read(saStoresFilterProvider.notifier).update(
          (state) => state.copyWith(search: query),
        );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final filter = ref.watch(saStoresFilterProvider);
    final storesAsync = ref.watch(saStoresListProvider);

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(AlhaiSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row
            Row(
              children: [
                Expanded(
                  child: Text(
                    l10n.storeManagement,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                FilledButton.icon(
                  onPressed: () => context.go(SuperAdminRoutes.createStore),
                  icon: const Icon(Icons.add_rounded),
                  label: Text(l10n.createStore),
                ),
              ],
            ),
            const SizedBox(height: AlhaiSpacing.lg),

            // Search + Filters
            Wrap(
              spacing: AlhaiSpacing.md,
              runSpacing: AlhaiSpacing.sm,
              children: [
                SizedBox(
                  width: 300,
                  child: TextField(
                    controller: _searchController,
                    onChanged: _applySearch,
                    decoration: InputDecoration(
                      hintText: l10n.searchStores,
                      prefixIcon: const Icon(Icons.search_rounded),
                      border: OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(AlhaiRadius.input),
                      ),
                      isDense: true,
                    ),
                  ),
                ),
                _FilterChip(
                  label: l10n.filterByStatus,
                  value: filter.status,
                  options: {
                    'all': l10n.allStatuses,
                    'active': l10n.active,
                    'suspended': l10n.suspended,
                    'trial': l10n.trial,
                  },
                  onChanged: (v) => ref
                      .read(saStoresFilterProvider.notifier)
                      .update((state) => state.copyWith(status: v)),
                ),
                _FilterChip(
                  label: l10n.filterByPlan,
                  value: filter.plan,
                  options: {
                    'all': l10n.allPlans,
                    'basic': l10n.basicPlan,
                    'advanced': l10n.advancedPlan,
                    'professional': l10n.professionalPlan,
                  },
                  onChanged: (v) => ref
                      .read(saStoresFilterProvider.notifier)
                      .update((state) => state.copyWith(plan: v)),
                ),
              ],
            ),
            const SizedBox(height: AlhaiSpacing.md),

            // Data table
            Expanded(
              child: storesAsync.when(
                loading: () =>
                    const Center(child: CircularProgressIndicator()),
                error: (e, _) => Center(child: Text('Error: $e')),
                data: (stores) {
                  if (stores.isEmpty) {
                    return Center(
                      child: Text(
                        l10n.noStoresFound,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: theme.colorScheme.outline,
                        ),
                      ),
                    );
                  }

                  return Card(
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(AlhaiRadius.card),
                      side: BorderSide(
                        color: theme.colorScheme.outlineVariant,
                        width: AlhaiSpacing.strokeXs,
                      ),
                    ),
                    child: SingleChildScrollView(
                      child: DataTable(
                        columnSpacing: AlhaiSpacing.lg,
                        headingRowHeight: 48,
                        dataRowMinHeight: 52,
                        dataRowMaxHeight: 52,
                        columns: [
                          DataColumn(label: Text(l10n.storeName)),
                          DataColumn(label: Text(l10n.storeStatus)),
                          DataColumn(label: Text(l10n.storePlan)),
                          DataColumn(label: Text(l10n.storeCreatedAt)),
                          const DataColumn(label: SizedBox()),
                        ],
                        rows: stores.map((store) {
                          final name =
                              store['name'] as String? ?? 'Unnamed';
                          final isActive =
                              store['is_active'] as bool? ?? false;
                          final createdAt =
                              store['created_at'] as String? ?? '';
                          final dateStr = createdAt.length >= 10
                              ? createdAt.substring(0, 10)
                              : createdAt;

                          // Extract plan from nested subscription
                          final subs =
                              store['subscriptions'] as List<dynamic>?;
                          String planName = '-';
                          String status = isActive ? 'active' : 'suspended';
                          if (subs != null && subs.isNotEmpty) {
                            final sub =
                                subs.first as Map<String, dynamic>;
                            final plan =
                                sub['plans'] as Map<String, dynamic>?;
                            planName =
                                plan?['name'] as String? ?? '-';
                            final subStatus =
                                sub['status'] as String? ?? '';
                            if (subStatus == 'trial') status = 'trial';
                          }

                          return DataRow(cells: [
                            DataCell(Text(name)),
                            DataCell(_StatusBadge(status: status)),
                            DataCell(_PlanBadge(
                                plan: planName.toLowerCase())),
                            DataCell(Text(dateStr)),
                            DataCell(
                              IconButton(
                                icon: const Icon(
                                  Icons.arrow_forward_rounded,
                                  size: 18,
                                ),
                                onPressed: () => context.go(
                                  '/stores/${store['id']}',
                                ),
                                tooltip: l10n.viewDetails,
                              ),
                            ),
                          ]);
                        }).toList(),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final String value;
  final Map<String, String> options;
  final ValueChanged<String> onChanged;

  const _FilterChip({
    required this.label,
    required this.value,
    required this.options,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButton<String>(
      value: value,
      underline: const SizedBox(),
      borderRadius: BorderRadius.circular(AlhaiRadius.sm),
      items: options.entries
          .map((e) =>
              DropdownMenuItem(value: e.key, child: Text(e.value)))
          .toList(),
      onChanged: (v) {
        if (v != null) onChanged(v);
      },
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String status;
  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final (color, bgColor) = switch (status) {
      'active' => (Colors.green.shade700, Colors.green.shade50),
      'suspended' => (Colors.red.shade700, Colors.red.shade50),
      'trial' => (Colors.amber.shade700, Colors.amber.shade50),
      _ => (Colors.grey.shade700, Colors.grey.shade50),
    };

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AlhaiSpacing.xs,
        vertical: AlhaiSpacing.xxxs,
      ),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(AlhaiRadius.chip),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _PlanBadge extends StatelessWidget {
  final String plan;
  const _PlanBadge({required this.plan});

  @override
  Widget build(BuildContext context) {
    final color = switch (plan) {
      'professional' => Colors.teal,
      'advanced' => Colors.deepPurple,
      'basic' => Colors.blue,
      _ => Colors.grey,
    };

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AlhaiSpacing.xs,
        vertical: AlhaiSpacing.xxxs,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AlhaiRadius.chip),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        plan,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
