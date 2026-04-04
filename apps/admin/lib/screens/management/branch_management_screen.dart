import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:alhai_shared_ui/alhai_shared_ui.dart';
import 'package:alhai_l10n/alhai_l10n.dart';
import 'package:alhai_database/alhai_database.dart';
import 'package:get_it/get_it.dart';
import 'package:alhai_design_system/alhai_design_system.dart';

/// Branch Management Screen - شاشة إدارة الفروع
class BranchManagementScreen extends ConsumerStatefulWidget {
  const BranchManagementScreen({super.key});

  @override
  ConsumerState<BranchManagementScreen> createState() => _BranchManagementScreenState();
}

class _BranchManagementScreenState extends ConsumerState<BranchManagementScreen> {
  List<StoresTableData> _stores = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final db = GetIt.I<AppDatabase>();
      final stores = await db.storesDao.getAllStores();
      if (mounted) {
        setState(() {
          _stores = stores;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _error = e.toString();
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isWideScreen = size.width > 900;
    final isMediumScreen = size.width > 600;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context);

    return Column(
      children: [
        AppHeader(
          title: l10n.branchesTitle,
          onMenuTap: isWideScreen ? null : () => Scaffold.of(context).openDrawer(),
          onNotificationsTap: () => context.push('/notifications'),
          notificationsCount: 3,
          userName: l10n.defaultUserName,
          userRole: l10n.branchManager,
          actions: [
            FilledButton.icon(onPressed: _addBranch, icon: const Icon(Icons.add, size: 18), label: Text(l10n.addBranchAction)),
          ],
        ),
        Expanded(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _error != null
                  ? AppErrorState.general(context, message: _error, onRetry: _loadData)
                  : SingleChildScrollView(
                      padding: EdgeInsets.all(isMediumScreen ? 24 : 16),
                      child: _buildContent(isWideScreen, isMediumScreen, isDark, l10n),
                    ),
        ),
      ],
    );
  }

  Widget _buildContent(bool isWideScreen, bool isMediumScreen, bool isDark, AppLocalizations l10n) {
    final activeCount = _stores.where((s) => s.isActive).length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(children: [
          Expanded(child: _buildStatCard(icon: Icons.store, label: l10n.branchesTitle, value: '${_stores.length}', color: AppColors.info, isDark: isDark)),
          const SizedBox(width: AlhaiSpacing.sm),
          Expanded(child: _buildStatCard(icon: Icons.check_circle, label: l10n.active, value: '$activeCount', color: AppColors.success, isDark: isDark)),
          const SizedBox(width: AlhaiSpacing.sm),
          Expanded(child: _buildStatCard(icon: Icons.attach_money, label: l10n.todaySales, value: '\u2014', color: AppColors.warning, isDark: isDark)),
        ]),
        const SizedBox(height: AlhaiSpacing.md),
        if (_stores.isEmpty)
          AppEmptyState(
            icon: Icons.store_mall_directory_outlined,
            title: l10n.branchesTitle,
            description: '\u0644\u0627 \u062A\u0648\u062C\u062F \u0641\u0631\u0648\u0639 \u0645\u0633\u062C\u0644\u0629',
            actionText: l10n.addBranchAction,
            onAction: _addBranch,
            actionIcon: Icons.add,
          )
        else
          ...List.generate(_stores.length, (index) {
            final store = _stores[index];
            return Container(
              margin: const EdgeInsets.only(bottom: AlhaiSpacing.sm),
              decoration: BoxDecoration(
                color: isDark
                    ? (store.isActive ? Theme.of(context).colorScheme.surfaceContainerHighest : Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.5))
                    : (store.isActive ? Theme.of(context).colorScheme.surface : Theme.of(context).colorScheme.surfaceContainerLowest),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Theme.of(context).dividerColor),
              ),
              child: InkWell(
                onTap: () => _showBranchDetails(store),
                borderRadius: BorderRadius.circular(12),
                child: Padding(
                  padding: const EdgeInsets.all(AlhaiSpacing.md),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(children: [
                        Container(
                          padding: const EdgeInsets.all(AlhaiSpacing.sm),
                          decoration: BoxDecoration(color: AppColors.info.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
                          child: const Icon(Icons.store, color: AppColors.info),
                        ),
                        const SizedBox(width: AlhaiSpacing.md),
                        Expanded(
                          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Row(children: [
                              Text(store.name, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Theme.of(context).colorScheme.onSurface)),
                              const SizedBox(width: AlhaiSpacing.xs),
                              if (!store.isActive)
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(color: AppColors.textSecondary, borderRadius: BorderRadius.circular(4)),
                                  child: Text(l10n.close, style: TextStyle(color: Theme.of(context).colorScheme.onInverseSurface, fontSize: 10)),
                                ),
                            ]),
                            Text(store.address ?? '', style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.onSurfaceVariant)),
                          ]),
                        ),
                        Switch(
                          value: store.isActive,
                          onChanged: (v) => _toggleStoreActive(store, v),
                          activeTrackColor: AppColors.primary.withValues(alpha: 0.5),
                        ),
                      ]),
                      Divider(height: 24, color: Theme.of(context).dividerColor),
                      Row(children: [
                        Icon(Icons.person, size: 16, color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.5)),
                        const SizedBox(width: AlhaiSpacing.xxs),
                        Text('\u2014', style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.onSurfaceVariant)),
                        const Spacer(),
                        Icon(Icons.phone, size: 16, color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.5)),
                        const SizedBox(width: AlhaiSpacing.xxs),
                        Text(store.phone ?? '\u2014', style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.onSurfaceVariant)),
                        const SizedBox(width: AlhaiSpacing.md),
                        Text(
                          '\u2014 \u0631.\u0633',
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: store.isActive ? AppColors.success : AppColors.textSecondary),
                        ),
                      ]),
                    ],
                  ),
                ),
              ),
            );
          }),
      ],
    );
  }

  Future<void> _toggleStoreActive(StoresTableData store, bool isActive) async {
    try {
      final db = GetIt.I<AppDatabase>();
      final updated = store.copyWith(isActive: isActive, updatedAt: Value(DateTime.now()));
      await db.storesDao.updateStore(updated);
      await _loadData();
    } catch (e) {
      // ignore
    }
  }

  Widget _buildStatCard({required IconData icon, required String label, required String value, required Color color, required bool isDark}) {
    return Container(
      padding: const EdgeInsets.all(AlhaiSpacing.md),
      decoration: BoxDecoration(
        color: isDark ? color.withValues(alpha: 0.1) : color.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: AlhaiSpacing.xs),
        Text(value, style: TextStyle(fontWeight: FontWeight.bold, color: color, fontSize: 20)),
        Text(label, style: TextStyle(fontSize: 12, color: color.withValues(alpha: 0.8))),
      ]),
    );
  }

  void _addBranch() {
    final l10n = AppLocalizations.of(context);
    final nameController = TextEditingController();
    final addressController = TextEditingController();
    final phoneController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.addBranchAction),
        content: SingleChildScrollView(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            TextField(controller: nameController, decoration: InputDecoration(labelText: l10n.branchName, prefixIcon: const Icon(Icons.store))),
            const SizedBox(height: AlhaiSpacing.sm),
            TextField(controller: addressController, decoration: InputDecoration(labelText: l10n.addressField, prefixIcon: const Icon(Icons.location_on))),
            const SizedBox(height: AlhaiSpacing.sm),
            TextField(controller: phoneController, keyboardType: TextInputType.phone, decoration: InputDecoration(labelText: l10n.phone, prefixIcon: const Icon(Icons.phone))),
          ]),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text(l10n.cancel)),
          FilledButton(
            onPressed: () async {
              if (nameController.text.isNotEmpty) {
                try {
                  final db = GetIt.I<AppDatabase>();
                  await db.storesDao.insertStore(StoresTableCompanion(
                    id: Value('store_${DateTime.now().millisecondsSinceEpoch}'),
                    name: Value(nameController.text),
                    address: Value(addressController.text.isEmpty ? null : addressController.text),
                    phone: Value(phoneController.text.isEmpty ? null : phoneController.text),
                    isActive: const Value(true),
                    createdAt: Value(DateTime.now()),
                  ));
                  await _loadData();
                } catch (e) {
                  // ignore
                }
              }
              if (ctx.mounted) Navigator.pop(ctx);
            },
            child: Text(l10n.add),
          ),
        ],
      ),
    ).then((_) {
      nameController.dispose();
      addressController.dispose();
      phoneController.dispose();
    });
  }

  void _showBranchDetails(StoresTableData store) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      // M124: constrain bottom sheet dimensions on desktop
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.7,
        maxWidth: 600,
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        expand: false,
        builder: (context, scrollController) => Container(
          color: Theme.of(context).colorScheme.surface,
          child: ListView(
            controller: scrollController,
            padding: const EdgeInsets.all(AlhaiSpacing.lg),
            children: [
              Center(child: Container(width: 40, height: 4, margin: const EdgeInsets.only(bottom: AlhaiSpacing.lg), decoration: BoxDecoration(color: Theme.of(context).colorScheme.outlineVariant, borderRadius: BorderRadius.circular(2)))),
              Row(children: [
                Container(padding: const EdgeInsets.all(AlhaiSpacing.md), decoration: BoxDecoration(color: AppColors.info.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)), child: const Icon(Icons.store, size: 32, color: AppColors.info)),
                const SizedBox(width: AlhaiSpacing.md),
                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(store.name, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface)),
                    Text(store.isActive ? l10n.active : l10n.close, style: TextStyle(color: store.isActive ? AppColors.success : AppColors.textSecondary)),
                  ]),
                ),
              ]),
              const SizedBox(height: AlhaiSpacing.lg),
              _DetailTile(icon: Icons.location_on, label: l10n.addressField, value: store.address ?? '\u2014', isDark: isDark),
              _DetailTile(icon: Icons.phone, label: l10n.phone, value: store.phone ?? '\u2014', isDark: isDark),
              _DetailTile(icon: Icons.email, label: '\u0627\u0644\u0628\u0631\u064A\u062F', value: store.email ?? '\u2014', isDark: isDark),
              _DetailTile(icon: Icons.location_city, label: '\u0627\u0644\u0645\u062F\u064A\u0646\u0629', value: store.city ?? '\u2014', isDark: isDark),
              _DetailTile(icon: Icons.receipt_long, label: l10n.taxNumber, value: store.taxNumber ?? '\u2014', isDark: isDark),
              Divider(height: 32, color: Theme.of(context).dividerColor),
              Container(
                padding: const EdgeInsets.all(AlhaiSpacing.md),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.success.withValues(alpha: 0.1) : AppColors.successSurface,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(children: [
                  const Icon(Icons.attach_money, color: AppColors.success),
                  const SizedBox(width: AlhaiSpacing.sm),
                  Text(l10n.todaySales, style: TextStyle(color: Theme.of(context).colorScheme.onSurface)),
                  const Spacer(),
                  const Text('\u2014 \u0631.\u0633', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.success)),
                ]),
              ),
              const SizedBox(height: AlhaiSpacing.lg),
              Row(children: [
                Expanded(child: OutlinedButton.icon(onPressed: () {}, icon: const Icon(Icons.edit), label: Text(l10n.edit))),
                const SizedBox(width: AlhaiSpacing.sm),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: () async {
                      Navigator.pop(context);
                      await _deleteStore(store);
                    },
                    style: FilledButton.styleFrom(backgroundColor: AppColors.error),
                    icon: const Icon(Icons.delete),
                    label: Text(l10n.delete),
                  ),
                ),
              ]),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _deleteStore(StoresTableData store) async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.deleteConfirmTitle),
        content: Text(l10n.deleteConfirmMessage),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(l10n.cancel)),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), style: FilledButton.styleFrom(backgroundColor: AppColors.error), child: Text(l10n.delete)),
        ],
      ),
    );
    if (confirmed == true) {
      try {
        final db = GetIt.I<AppDatabase>();
        await db.storesDao.deleteStore(store.id);
        await _loadData();
      } catch (e) {
        // ignore
      }
    }
  }
}

class _DetailTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool isDark;
  const _DetailTile({required this.icon, required this.label, required this.value, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AlhaiSpacing.xs),
      child: Row(children: [
        Icon(icon, size: 20, color: Theme.of(context).colorScheme.onSurfaceVariant),
        const SizedBox(width: AlhaiSpacing.sm),
        Text(label, style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant)),
        const Spacer(),
        Text(value, style: TextStyle(fontWeight: FontWeight.w500, color: Theme.of(context).colorScheme.onSurface)),
      ]),
    );
  }
}
