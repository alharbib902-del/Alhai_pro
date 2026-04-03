import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:alhai_design_system/alhai_design_system.dart';
import 'package:alhai_l10n/alhai_l10n.dart';
import '../../core/router/app_router.dart';

/// Stores list with search, filter by status/plan.
class SAStoresListScreen extends StatefulWidget {
  const SAStoresListScreen({super.key});

  @override
  State<SAStoresListScreen> createState() => _SAStoresListScreenState();
}

class _SAStoresListScreenState extends State<SAStoresListScreen> {
  String _statusFilter = 'all';
  String _planFilter = 'all';
  final _searchController = TextEditingController();

  // Mock data
  final List<_StoreRow> _stores = [
    _StoreRow('S-001', 'Grocery Plus', 'Ahmed Ali', 'active', 'professional', '2024-01-15', 4520),
    _StoreRow('S-002', 'Tech Zone', 'Sara Omar', 'active', 'advanced', '2024-02-20', 3180),
    _StoreRow('S-003', 'Fashion Hub', 'Khalid Nasser', 'trial', 'basic', '2024-11-01', 240),
    _StoreRow('S-004', 'Home Essentials', 'Fatima Youssef', 'active', 'basic', '2024-03-10', 1870),
    _StoreRow('S-005', 'Beauty Corner', 'Noura Saleh', 'suspended', 'advanced', '2024-04-05', 0),
    _StoreRow('S-006', 'Auto Parts KSA', 'Mohammed Ibrahim', 'active', 'professional', '2024-05-18', 6230),
    _StoreRow('S-007', 'Book Haven', 'Layla Adel', 'trial', 'basic', '2024-12-01', 85),
    _StoreRow('S-008', 'Fresh Market', 'Abdullah Rashid', 'active', 'advanced', '2024-06-22', 5640),
  ];

  List<_StoreRow> get _filteredStores {
    return _stores.where((s) {
      if (_statusFilter != 'all' && s.status != _statusFilter) return false;
      if (_planFilter != 'all' && s.plan != _planFilter) return false;
      if (_searchController.text.isNotEmpty) {
        final q = _searchController.text.toLowerCase();
        return s.name.toLowerCase().contains(q) ||
            s.owner.toLowerCase().contains(q) ||
            s.id.toLowerCase().contains(q);
      }
      return true;
    }).toList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);

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
                    onChanged: (_) => setState(() {}),
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
                  value: _statusFilter,
                  options: {
                    'all': l10n.allStatuses,
                    'active': l10n.active,
                    'suspended': l10n.suspended,
                    'trial': l10n.trial,
                  },
                  onChanged: (v) => setState(() => _statusFilter = v),
                ),
                _FilterChip(
                  label: l10n.filterByPlan,
                  value: _planFilter,
                  options: {
                    'all': l10n.allPlans,
                    'basic': l10n.basicPlan,
                    'advanced': l10n.advancedPlan,
                    'professional': l10n.professionalPlan,
                  },
                  onChanged: (v) => setState(() => _planFilter = v),
                ),
              ],
            ),
            const SizedBox(height: AlhaiSpacing.md),

            // Data table
            Expanded(
              child: _filteredStores.isEmpty
                  ? Center(
                      child: Text(
                        l10n.noStoresFound,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: theme.colorScheme.outline,
                        ),
                      ),
                    )
                  : Card(
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
                            DataColumn(label: Text(l10n.storeOwner)),
                            DataColumn(label: Text(l10n.storeStatus)),
                            DataColumn(label: Text(l10n.storePlan)),
                            DataColumn(label: Text(l10n.storeCreatedAt)),
                            DataColumn(
                              label: Text(l10n.storeTransactions),
                              numeric: true,
                            ),
                            const DataColumn(label: SizedBox()),
                          ],
                          rows: _filteredStores.map((store) {
                            return DataRow(cells: [
                              DataCell(Text(store.name)),
                              DataCell(Text(store.owner)),
                              DataCell(_StatusBadge(status: store.status)),
                              DataCell(_PlanBadge(plan: store.plan)),
                              DataCell(Text(store.createdAt)),
                              DataCell(Text(
                                store.transactions.toString(),
                              )),
                              DataCell(
                                IconButton(
                                  icon: const Icon(
                                    Icons.arrow_forward_rounded,
                                    size: 18,
                                  ),
                                  onPressed: () => context.go(
                                    '/stores/${store.id}',
                                  ),
                                  tooltip: l10n.viewDetails,
                                ),
                              ),
                            ]);
                          }).toList(),
                        ),
                      ),
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

class _StoreRow {
  final String id;
  final String name;
  final String owner;
  final String status;
  final String plan;
  final String createdAt;
  final int transactions;

  const _StoreRow(
    this.id,
    this.name,
    this.owner,
    this.status,
    this.plan,
    this.createdAt,
    this.transactions,
  );
}
