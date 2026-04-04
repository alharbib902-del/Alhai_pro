import 'dart:async';

import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:alhai_design_system/alhai_design_system.dart';
import 'package:alhai_l10n/alhai_l10n.dart';
import '../../core/router/app_router.dart';
import '../../providers/sa_providers.dart';
import '../../data/models/sa_store_model.dart';
import '../../ui/widgets/sa_skeleton.dart';
import '../../ui/widgets/sa_empty_state.dart';

/// Stores list with search, filter by status/plan -- real Supabase data.
class SAStoresListScreen extends ConsumerStatefulWidget {
  const SAStoresListScreen({super.key});

  @override
  ConsumerState<SAStoresListScreen> createState() => _SAStoresListScreenState();
}

class _SAStoresListScreenState extends ConsumerState<SAStoresListScreen> {
  final _searchController = TextEditingController();
  Timer? _debounceTimer;
  int _rowsPerPage = 10;

  @override
  void dispose() {
    _debounceTimer?.cancel();
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
    final isDark = theme.brightness == Brightness.dark;
    final colorScheme = theme.colorScheme;
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
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 300),
                  child: TextField(
                    controller: _searchController,
                    onChanged: (query) {
                      _debounceTimer?.cancel();
                      _debounceTimer =
                          Timer(const Duration(milliseconds: 300), () {
                        _applySearch(query);
                      });
                    },
                    decoration: InputDecoration(
                      hintText: l10n.searchStores,
                      prefixIcon: const Icon(Icons.search_rounded),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AlhaiRadius.input),
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
                loading: () => const SATableSkeleton(),
                error: (e, _) => Center(child: Text('Error: $e')),
                data: (stores) {
                  return Card(
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AlhaiRadius.card),
                      side: BorderSide(
                        color: colorScheme.outlineVariant,
                        width: AlhaiSpacing.strokeXs,
                      ),
                    ),
                    child: PaginatedDataTable2(
                      columnSpacing: 12,
                      horizontalMargin: 12,
                      minWidth: 800,
                      rowsPerPage: _rowsPerPage,
                      availableRowsPerPage: const [10, 25, 50],
                      onRowsPerPageChanged: (value) {
                        if (value != null) setState(() => _rowsPerPage = value);
                      },
                      headingRowHeight: 48,
                      dataRowHeight: 52,
                      empty: SAEmptyState.stores(
                        onAdd: () => context.go(SuperAdminRoutes.createStore),
                      ),
                      columns: [
                        DataColumn2(
                            label: Text(l10n.storeName), size: ColumnSize.L),
                        DataColumn2(
                            label: Text(l10n.storeStatus), fixedWidth: 120),
                        DataColumn2(
                            label: Text(l10n.storePlan), fixedWidth: 140),
                        DataColumn2(
                            label: Text(l10n.storeCreatedAt), fixedWidth: 130),
                        const DataColumn2(label: SizedBox(), fixedWidth: 56),
                      ],
                      source: _StoresDataSource(
                        stores: stores,
                        context: context,
                        isDark: isDark,
                        l10n: l10n,
                        onViewStore: (storeId) =>
                            context.go('/stores/$storeId'),
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

class _StoresDataSource extends DataTableSource {
  final List<SAStore> stores;
  final BuildContext context;
  final bool isDark;
  final AppLocalizations l10n;
  final void Function(String storeId) onViewStore;

  _StoresDataSource({
    required this.stores,
    required this.context,
    required this.isDark,
    required this.l10n,
    required this.onViewStore,
  });

  @override
  DataRow? getRow(int index) {
    if (index >= stores.length) return null;
    final store = stores[index];

    final name = store.name.isEmpty ? 'Unnamed' : store.name;
    final createdAt = store.createdAt ?? '';
    final dateStr =
        createdAt.length >= 10 ? createdAt.substring(0, 10) : createdAt;

    // Extract plan from typed subscription
    final planName = store.planName;
    String status = store.isActive ? 'active' : 'suspended';
    if (store.subscriptionStatus == 'trial') status = 'trial';

    return DataRow2(
      cells: [
        DataCell(Text(name)),
        DataCell(_StatusBadge(status: status)),
        DataCell(_PlanBadge(plan: planName.toLowerCase())),
        DataCell(Text(dateStr)),
        DataCell(
          IconButton(
            icon: const Icon(Icons.arrow_forward_rounded, size: 18),
            onPressed: () => onViewStore(store.id),
            tooltip: l10n.viewDetails,
          ),
        ),
      ],
    );
  }

  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => stores.length;

  @override
  int get selectedRowCount => 0;
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
          .map((e) => DropdownMenuItem(value: e.key, child: Text(e.value)))
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final (color, bgColor) = switch (status) {
      'active' => (
          isDark ? const Color(0xFF4ADE80) : const Color(0xFF15803D),
          isDark ? const Color(0xFF1B3A2A) : const Color(0xFFDCFCE7),
        ),
      'suspended' => (
          isDark ? const Color(0xFFF87171) : const Color(0xFFB91C1C),
          isDark ? const Color(0xFF3A1B1B) : const Color(0xFFFEE2E2),
        ),
      'trial' => (
          isDark ? const Color(0xFFFBBF24) : const Color(0xFFB45309),
          isDark ? const Color(0xFF3A2F1B) : const Color(0xFFFEF3C7),
        ),
      _ => (
          isDark ? const Color(0xFF9CA3AF) : const Color(0xFF4B5563),
          isDark ? const Color(0xFF2A2A2A) : const Color(0xFFF3F4F6),
        ),
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
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: color,
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colorScheme = Theme.of(context).colorScheme;
    final color = switch (plan) {
      'professional' => isDark ? const Color(0xFF2DD4BF) : Colors.teal,
      'advanced' => isDark ? const Color(0xFFA78BFA) : Colors.deepPurple,
      'basic' => isDark ? const Color(0xFF60A5FA) : Colors.blue,
      _ => colorScheme.outline,
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
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
      ),
    );
  }
}
