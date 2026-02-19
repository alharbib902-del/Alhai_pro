import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../data/local/app_database.dart';
import '../../di/injection.dart';
import '../../widgets/layout/app_header.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../core/theme/app_colors.dart';
import '../../widgets/common/app_empty_state.dart';

/// شاشة إدارة الفروع
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
    setState(() { _isLoading = true; _error = null; });
    try {
      final db = getIt<AppDatabase>();
      final stores = await db.storesDao.getAllStores();
      if (mounted) setState(() { _stores = stores; _isLoading = false; });
    } catch (e) {
      if (mounted) setState(() { _isLoading = false; _error = e.toString(); });
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isWideScreen = size.width > 900;
    final isMediumScreen = size.width > 600;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;

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
            FilledButton.icon(
              onPressed: _addBranch,
              icon: const Icon(Icons.add, size: 18),
              label: Text(l10n.addBranchAction),
            ),
          ],
        ),
        Expanded(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _error != null
              ? AppErrorState.general(message: _error, onRetry: _loadData)
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
        // Stats row
        Row(
          children: [
            Expanded(child: _buildStatCard(icon: Icons.store, label: l10n.branchesTitle, value: '${_stores.length}', color: AppColors.info, isDark: isDark)),
            const SizedBox(width: 12),
            Expanded(child: _buildStatCard(icon: Icons.check_circle, label: l10n.active, value: '$activeCount', color: AppColors.success, isDark: isDark)),
            const SizedBox(width: 12),
            Expanded(child: _buildStatCard(icon: Icons.attach_money, label: l10n.todaySales, value: '—', color: AppColors.warning, isDark: isDark)),
          ],
        ),
        const SizedBox(height: 16),

        if (_stores.isEmpty)
          Center(
            child: Padding(
              padding: const EdgeInsets.all(48),
              child: Column(
                children: [
                  Icon(Icons.store_mall_directory_outlined, size: 64, color: isDark ? Colors.white24 : Colors.grey.shade400),
                  const SizedBox(height: 16),
                  Text(
                    'لا توجد فروع مسجلة', // TODO: localize
                    style: TextStyle(color: isDark ? Colors.white54 : Colors.grey.shade600, fontSize: 16),
                  ),
                ],
              ),
            ),
          )
        else
          // Branch list
          ...List.generate(_stores.length, (index) {
            final store = _stores[index];
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: isDark
                    ? (store.isActive ? const Color(0xFF1E293B) : const Color(0xFF1E293B).withValues(alpha: 0.5))
                    : (store.isActive ? Colors.white : Colors.grey.shade100),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: isDark ? Colors.white.withValues(alpha: 0.1) : AppColors.border),
              ),
              child: InkWell(
                onTap: () => _showBranchDetails(store),
                borderRadius: BorderRadius.circular(12),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppColors.info.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(Icons.store, color: AppColors.info),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      store.name,
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                        color: isDark ? Colors.white : AppColors.textPrimary,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    if (!store.isActive)
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: AppColors.textSecondary,
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                        child: Text(l10n.close, style: const TextStyle(color: Colors.white, fontSize: 10)),
                                      ),
                                  ],
                                ),
                                Text(
                                  store.address ?? '',
                                  style: TextStyle(fontSize: 12, color: isDark ? Colors.white54 : AppColors.textSecondary),
                                ),
                              ],
                            ),
                          ),
                          Switch(
                            value: store.isActive,
                            onChanged: (v) => _toggleStoreActive(store, v),
                            activeTrackColor: AppColors.primary.withValues(alpha: 0.5),
                          ),
                        ],
                      ),
                      Divider(height: 24, color: isDark ? Colors.white.withValues(alpha: 0.1) : AppColors.border),
                      Row(
                        children: [
                          Icon(Icons.person, size: 16, color: isDark ? Colors.white38 : AppColors.textTertiary),
                          const SizedBox(width: 4),
                          Text(
                            '—',
                            style: TextStyle(fontSize: 12, color: isDark ? Colors.white54 : AppColors.textSecondary),
                          ),
                          const Spacer(),
                          Icon(Icons.phone, size: 16, color: isDark ? Colors.white38 : AppColors.textTertiary),
                          const SizedBox(width: 4),
                          Text(
                            store.phone ?? '—',
                            style: TextStyle(fontSize: 12, color: isDark ? Colors.white54 : AppColors.textSecondary),
                          ),
                          const SizedBox(width: 16),
                          Text(
                            '— ر.س',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: store.isActive ? AppColors.success : AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
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
      final db = getIt<AppDatabase>();
      final updated = store.copyWith(isActive: isActive, updatedAt: Value(DateTime.now()));
      await db.storesDao.updateStore(updated);
      await _loadData();
    } catch (e) {
      // ignore
    }
  }

  Widget _buildStatCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? color.withValues(alpha: 0.1) : color.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(value, style: TextStyle(fontWeight: FontWeight.bold, color: color, fontSize: 20)),
          Text(label, style: TextStyle(fontSize: 12, color: color.withValues(alpha: 0.8))),
        ],
      ),
    );
  }

  void _addBranch() {
    final l10n = AppLocalizations.of(context)!;
    final nameController = TextEditingController();
    final addressController = TextEditingController();
    final phoneController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.addBranchAction),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: nameController, decoration: InputDecoration(labelText: l10n.branchName, prefixIcon: const Icon(Icons.store))),
              const SizedBox(height: 12),
              TextField(controller: addressController, decoration: InputDecoration(labelText: l10n.addressField, prefixIcon: const Icon(Icons.location_on))),
              const SizedBox(height: 12),
              TextField(controller: phoneController, keyboardType: TextInputType.phone, decoration: InputDecoration(labelText: l10n.phone, prefixIcon: const Icon(Icons.phone))),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text(l10n.cancel)),
          FilledButton(
            onPressed: () async {
              if (nameController.text.isNotEmpty) {
                try {
                  final db = getIt<AppDatabase>();
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
    final l10n = AppLocalizations.of(context)!;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        expand: false,
        builder: (context, scrollController) => Container(
          color: isDark ? const Color(0xFF1E293B) : Colors.white,
          child: ListView(
            controller: scrollController,
            padding: const EdgeInsets.all(24),
            children: [
              Center(child: Container(width: 40, height: 4, margin: const EdgeInsets.only(bottom: 24), decoration: BoxDecoration(color: isDark ? Colors.white24 : Colors.grey.shade300, borderRadius: BorderRadius.circular(2)))),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(color: AppColors.info.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
                    child: const Icon(Icons.store, size: 32, color: AppColors.info),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(store.name, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: isDark ? Colors.white : AppColors.textPrimary)),
                        Text(
                          store.isActive ? l10n.active : l10n.close,
                          style: TextStyle(color: store.isActive ? AppColors.success : AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              _DetailTile(icon: Icons.location_on, label: l10n.addressField, value: store.address ?? '—', isDark: isDark),
              _DetailTile(icon: Icons.phone, label: l10n.phone, value: store.phone ?? '—', isDark: isDark),
              _DetailTile(icon: Icons.email, label: 'البريد', value: store.email ?? '—', isDark: isDark), // TODO: localize - no ARB key
              _DetailTile(icon: Icons.location_city, label: 'المدينة', value: store.city ?? '—', isDark: isDark), // TODO: localize - no ARB key
              _DetailTile(icon: Icons.receipt_long, label: l10n.taxNumber, value: store.taxNumber ?? '—', isDark: isDark),
              Divider(height: 32, color: isDark ? Colors.white.withValues(alpha: 0.1) : AppColors.border),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.success.withValues(alpha: 0.1) : AppColors.successSurface,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.attach_money, color: AppColors.success),
                    const SizedBox(width: 12),
                    Text(l10n.todaySales, style: TextStyle(color: isDark ? Colors.white : AppColors.textPrimary)),
                    const Spacer(),
                    const Text(
                      '— ر.س',
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.success),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(child: OutlinedButton.icon(onPressed: () {}, icon: const Icon(Icons.edit), label: Text(l10n.edit))),
                  const SizedBox(width: 12),
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
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _deleteStore(StoresTableData store) async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.deleteConfirmTitle),
        content: Text(l10n.deleteConfirmMessage),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(l10n.cancel)),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(backgroundColor: AppColors.error),
            child: Text(l10n.delete),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      try {
        final db = getIt<AppDatabase>();
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
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: isDark ? Colors.white54 : AppColors.textSecondary),
          const SizedBox(width: 12),
          Text(label, style: TextStyle(color: isDark ? Colors.white54 : AppColors.textSecondary)),
          const Spacer(),
          Text(value, style: TextStyle(fontWeight: FontWeight.w500, color: isDark ? Colors.white : AppColors.textPrimary)),
        ],
      ),
    );
  }
}
