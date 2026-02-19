import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../widgets/layout/app_header.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../core/theme/app_colors.dart';
import '../../data/local/app_database.dart';
import '../../providers/suppliers_providers.dart';
import '../../widgets/common/app_empty_state.dart';

/// شاشة الموردين - CRUD
class SuppliersScreen extends ConsumerStatefulWidget {
  const SuppliersScreen({super.key});

  @override
  ConsumerState<SuppliersScreen> createState() => _SuppliersScreenState();
}

class _SuppliersScreenState extends ConsumerState<SuppliersScreen> {
  String _searchQuery = '';
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
                  title: l10n.suppliersTitle,
                  onMenuTap: isWideScreen
                      ? null
                      : () => Scaffold.of(context).openDrawer(),
                  onNotificationsTap: () => context.push('/notifications'),
                  notificationsCount: 3,
                  userName: '\u0623\u062D\u0645\u062F \u0645\u062D\u0645\u062F',
                  userRole: l10n.branchManager,
                ),
                Expanded(
                  child: ref.watch(suppliersListProvider).when(
                    loading: () => const Center(child: CircularProgressIndicator()),
                    error: (e, _) => AppErrorState.general(
                      message: e.toString(),
                      onRetry: () => ref.invalidate(suppliersListProvider),
                    ),
                    data: (suppliers) => SingleChildScrollView(
                      padding: EdgeInsets.all(isMediumScreen ? 24 : 16),
                      child: _buildContent(suppliers,
                          isWideScreen, isMediumScreen, isDark, l10n),
                    ),
                  ),
                ),
              ],
            );
  }
  Widget _buildContent(List<SuppliersTableData> suppliers,
      bool isWideScreen, bool isMediumScreen, bool isDark, AppLocalizations l10n) {
    final totalBalance = suppliers.fold(0.0, (sum, s) => sum + s.balance);
    final activeCount = suppliers.where((s) => s.isActive == true).length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Stats Cards
        if (isWideScreen)
          Row(
            children: [
              Expanded(
                child: _StatCard(
                  icon: Icons.store_rounded,
                  label: l10n.totalSuppliers,
                  value: '${suppliers.length}',
                  color: AppColors.primary,
                  isDark: isDark,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _StatCard(
                  icon: Icons.check_circle_rounded,
                  label: 'موردين نشطين',
                  value: '$activeCount',
                  color: AppColors.info,
                  isDark: isDark,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _StatCard(
                  icon: Icons.account_balance_wallet_rounded,
                  label: 'المستحقات',
                  value: '${totalBalance.toStringAsFixed(0)} ${l10n.sar}',
                  color: AppColors.error,
                  isDark: isDark,
                ),
              ),
            ],
          )
        else
          Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: _StatCard(
                      icon: Icons.store_rounded,
                      label: l10n.suppliersTitle,
                      value: '${suppliers.length}',
                      color: AppColors.primary,
                      isDark: isDark,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _StatCard(
                      icon: Icons.check_circle_rounded,
                      label: 'نشطين',
                      value: '$activeCount',
                      color: AppColors.info,
                      isDark: isDark,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _StatCard(
                icon: Icons.account_balance_wallet_rounded,
                label: 'المستحقات',
                value: '${totalBalance.toStringAsFixed(0)} ${l10n.sar}',
                color: AppColors.error,
                isDark: isDark,
              ),
            ],
          ),
        const SizedBox(height: 24),

        // Supplier Catalog - Coming Soon
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E293B) : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppColors.primary.withValues(alpha: 0.3),
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.menu_book_rounded,
                    color: AppColors.primary, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '\u0643\u062A\u0627\u0644\u0648\u062C \u0627\u0644\u0645\u0646\u062A\u062C\u0627\u062A',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        color: isDark ? Colors.white : AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '\u0642\u0631\u064A\u0628\u0627\u064B - \u062A\u0635\u0641\u062D \u0645\u0646\u062A\u062C\u0627\u062A \u0627\u0644\u0645\u0648\u0631\u062F\u064A\u0646',
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.5)
                            : AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.warning.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  '\u0642\u0631\u064A\u0628\u0627\u064B',
                  style: TextStyle(
                    color: AppColors.warning,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Search & Add row
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E293B) : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.1)
                  : AppColors.border,
            ),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      onChanged: (v) => setState(() => _searchQuery = v),
                      decoration: InputDecoration(
                        hintText: l10n.search,
                        prefixIcon: const Icon(Icons.search),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        contentPadding:
                            const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  FilledButton.icon(
                    onPressed: () => _showAddSupplierDialog(context),
                    icon: const Icon(Icons.add, size: 18),
                    label: Text(l10n.addSupplier),
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 14),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Divider(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.1)
                    : AppColors.border,
              ),
              const SizedBox(height: 8),

              // Suppliers List
              Builder(builder: (context) {
                final filtered = _searchQuery.isEmpty
                    ? suppliers
                    : suppliers.where((s) =>
                        s.name.contains(_searchQuery) ||
                        (s.phone ?? '').contains(_searchQuery) ||
                        (s.email ?? '').contains(_searchQuery)).toList();

                if (filtered.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.all(32),
                    child: Center(
                      child: Text(l10n.noSuppliers, style: TextStyle(color: isDark ? Colors.white.withValues(alpha: 0.5) : AppColors.textMuted)),
                    ),
                  );
                }

                return ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: filtered.length,
                  separatorBuilder: (_, __) => Divider(
                    height: 1,
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.05)
                        : AppColors.border,
                  ),
                  itemBuilder: (context, index) {
                    final supplier = filtered[index];
                    final initial = supplier.name.isNotEmpty ? supplier.name[0] : '?';
                    return ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 4, vertical: 8),
                      leading: CircleAvatar(
                        backgroundColor:
                            AppColors.primary.withValues(alpha: 0.1),
                        child: Text(
                          initial,
                          style: const TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      title: Text(
                        supplier.name,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: isDark ? Colors.white : AppColors.textPrimary,
                        ),
                      ),
                      subtitle: Text(
                        supplier.phone ?? '',
                        style: TextStyle(
                          color: isDark
                              ? Colors.white.withValues(alpha: 0.6)
                              : AppColors.textSecondary,
                        ),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color:
                                  AppColors.primary.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              '${supplier.balance.toStringAsFixed(0)} ${l10n.sar}',
                              style: const TextStyle(
                                color: AppColors.primary,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Icon(
                            Icons.chevron_left,
                            color: isDark
                                ? Colors.white.withValues(alpha: 0.3)
                                : AppColors.textTertiary,
                          ),
                        ],
                      ),
                      onTap: () => _showSupplierDetailFromData(context, supplier),
                    );
                  },
                );
              }),
            ],
          ),
        ),
      ],
    );
  }

  void _showSupplierDetailFromData(BuildContext context, SuppliersTableData supplier) {
    final l10n = AppLocalizations.of(context)!;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.4,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) => Padding(
          padding: const EdgeInsets.all(24),
          child: ListView(
            controller: scrollController,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              CircleAvatar(
                radius: 40,
                backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                child: const Icon(Icons.store,
                    size: 40, color: AppColors.primary),
              ),
              const SizedBox(height: 16),
              Text(
                supplier.name,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 24),
              _DetailRow(
                  icon: Icons.phone,
                  label: l10n.supplierPhone,
                  value: supplier.phone ?? '-'),
              _DetailRow(
                  icon: Icons.email,
                  label: l10n.supplierEmail,
                  value: supplier.email ?? '-'),
              _DetailRow(
                  icon: Icons.location_on,
                  label: l10n.supplierAddress,
                  value: supplier.address ?? '-'),
              _DetailRow(
                  icon: Icons.account_balance,
                  label: l10n.balance,
                  value: '${supplier.balance.toStringAsFixed(0)} ${l10n.sar}'),
              if (supplier.taxNumber != null)
                _DetailRow(
                    icon: Icons.numbers,
                    label: l10n.taxNumber,
                    value: supplier.taxNumber!),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.edit),
                      label: Text(l10n.edit),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.receipt_long),
                      label: Text(l10n.invoices),
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

  void _showAddSupplierDialog(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final nameCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();
    final emailCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.addSupplier),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameCtrl,
              decoration: InputDecoration(
                labelText: l10n.supplierName,
                prefixIcon: const Icon(Icons.store),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: phoneCtrl,
              decoration: InputDecoration(
                labelText: l10n.phone,
                prefixIcon: const Icon(Icons.phone),
              ),
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: emailCtrl,
              decoration: InputDecoration(
                labelText: l10n.supplierEmail,
                prefixIcon: const Icon(Icons.email),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () async {
              if (nameCtrl.text.isEmpty) return;
              Navigator.pop(dialogContext);
              await addSupplier(
                ref,
                name: nameCtrl.text,
                phone: phoneCtrl.text.isEmpty ? null : phoneCtrl.text,
                email: emailCtrl.text.isEmpty ? null : emailCtrl.text,
              );
              if (!context.mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('تم إضافة المورد')),
              );
            },
            child: Text(l10n.add),
          ),
        ],
      ),
    ).then((_) {
      nameCtrl.dispose();
      phoneCtrl.dispose();
      emailCtrl.dispose();
    });
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  final bool isDark;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.1)
              : AppColors.border,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.6)
                        : AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _DetailRow(
      {required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppColors.textSecondary),
          const SizedBox(width: 12),
          Text(label,
              style: const TextStyle(color: AppColors.textSecondary)),
          const Spacer(),
          Text(value,
              style: const TextStyle(fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}
