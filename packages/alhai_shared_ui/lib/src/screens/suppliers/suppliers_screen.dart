import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../widgets/layout/app_header.dart';
import 'package:alhai_l10n/alhai_l10n.dart';
import 'package:alhai_design_system/alhai_design_system.dart';
import 'package:alhai_database/alhai_database.dart';
import '../../core/validators/input_sanitizer.dart';
import '../../providers/suppliers_providers.dart';
import '../../widgets/common/app_empty_state.dart';
import '../../widgets/common/shimmer_loading.dart';

/// شاشة الموردين - CRUD
class SuppliersScreen extends ConsumerStatefulWidget {
  const SuppliersScreen({super.key});

  @override
  ConsumerState<SuppliersScreen> createState() => _SuppliersScreenState();
}

class _SuppliersScreenState extends ConsumerState<SuppliersScreen> {
  String _searchQuery = '';
  Timer? _debounce;
  final _scrollController = ScrollController();
  bool _showScrollToTop = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      final show = _scrollController.offset > 300;
      if (show != _showScrollToTop) setState(() => _showScrollToTop = show);
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      setState(() => _searchQuery = query);
    });
  }

  @override
  Widget build(BuildContext context) {
    final isWideScreen = context.isDesktop;
    final isMediumScreen = !context.isMobile;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      floatingActionButton: _showScrollToTop
          ? FloatingActionButton.small(
              onPressed: () => _scrollController.animateTo(
                0,
                duration: AlhaiDurations.slow,
                curve: AlhaiMotion.standardDecelerate,
              ),
              child: const Icon(Icons.arrow_upward),
            )
          : null,
      body: Column(
        children: [
          AppHeader(
            title: l10n.suppliersTitle,
            onMenuTap:
                isWideScreen ? null : () => Scaffold.of(context).openDrawer(),
            onNotificationsTap: () => context.push('/notifications'),
            notificationsCount: 3,
            userName: '\u0623\u062D\u0645\u062F \u0645\u062D\u0645\u062F',
            userRole: l10n.branchManager,
          ),
          Expanded(
            child: ref.watch(suppliersListProvider).when(
                  loading: () => const Padding(
                    padding: EdgeInsets.all(AlhaiSpacing.md),
                    child: ShimmerList(itemCount: 6, itemHeight: 72),
                  ),
                  error: (e, _) => AppErrorState.general(
                    context,
                    message: e.toString(),
                    onRetry: () => ref.invalidate(suppliersListProvider),
                  ),
                  data: (suppliers) => RefreshIndicator(
                    onRefresh: () async =>
                        ref.invalidate(suppliersListProvider),
                    color: AppColors.primary,
                    child: SingleChildScrollView(
                      controller: _scrollController,
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: EdgeInsets.all(
                          isMediumScreen ? AlhaiSpacing.lg : AlhaiSpacing.md),
                      child: _buildContent(suppliers, isWideScreen,
                          isMediumScreen, isDark, l10n),
                    ),
                  ),
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(List<SuppliersTableData> suppliers, bool isWideScreen,
      bool isMediumScreen, bool isDark, AppLocalizations l10n) {
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
              SizedBox(width: AlhaiSpacing.md),
              Expanded(
                child: _StatCard(
                  icon: Icons.check_circle_rounded,
                  label: l10n.activeSuppliers,
                  value: '$activeCount',
                  color: AppColors.info,
                  isDark: isDark,
                ),
              ),
              SizedBox(width: AlhaiSpacing.md),
              Expanded(
                child: _StatCard(
                  icon: Icons.account_balance_wallet_rounded,
                  label: l10n.duePayments,
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
                  SizedBox(width: AlhaiSpacing.sm),
                  Expanded(
                    child: _StatCard(
                      icon: Icons.check_circle_rounded,
                      label: l10n.activeSuppliers,
                      value: '$activeCount',
                      color: AppColors.info,
                      isDark: isDark,
                    ),
                  ),
                ],
              ),
              SizedBox(height: AlhaiSpacing.sm),
              _StatCard(
                icon: Icons.account_balance_wallet_rounded,
                label: 'المستحقات',
                value: '${totalBalance.toStringAsFixed(0)} ${l10n.sar}',
                color: AppColors.error,
                isDark: isDark,
              ),
            ],
          ),
        SizedBox(height: AlhaiSpacing.lg),

        // Supplier Catalog - Coming Soon
        Container(
          padding: const EdgeInsets.all(AlhaiSpacing.md),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
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
              SizedBox(width: AlhaiSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.productCatalog,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    SizedBox(height: AlhaiSpacing.xxxs),
                    Text(
                      'تصفح كتالوج الموردين - هذه الميزة غير متاحة حالياً',
                      style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: AlhaiSpacing.xxs),
                decoration: BoxDecoration(
                  color: AppColors.warning.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'غير متاح',
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
        SizedBox(height: AlhaiSpacing.md),

        // Search & Add row
        Container(
          padding: const EdgeInsets.all(AlhaiSpacing.mdl),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Theme.of(context).dividerColor,
            ),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      onChanged: _onSearchChanged,
                      decoration: InputDecoration(
                        hintText: l10n.search,
                        prefixIcon: const Icon(Icons.search),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                            vertical: AlhaiSpacing.sm),
                      ),
                    ),
                  ),
                  SizedBox(width: AlhaiSpacing.md),
                  FilledButton.icon(
                    onPressed: () => _showAddSupplierDialog(context),
                    icon: const Icon(Icons.add, size: 18),
                    label: Text(l10n.addSupplier),
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: AlhaiSpacing.mdl, vertical: 14),
                    ),
                  ),
                ],
              ),
              SizedBox(height: AlhaiSpacing.md),
              Divider(
                color: Theme.of(context).dividerColor,
              ),
              SizedBox(height: AlhaiSpacing.xs),

              // Suppliers List
              Builder(builder: (context) {
                final filtered = _searchQuery.isEmpty
                    ? suppliers
                    : suppliers
                        .where((s) =>
                            s.name.contains(_searchQuery) ||
                            (s.phone ?? '').contains(_searchQuery) ||
                            (s.email ?? '').contains(_searchQuery))
                        .toList();

                if (filtered.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.all(AlhaiSpacing.xl),
                    child: Center(
                      child: Text(l10n.noSuppliers,
                          style: TextStyle(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurfaceVariant)),
                    ),
                  );
                }

                return ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: filtered.length,
                  separatorBuilder: (_, __) => Divider(
                    height: 1,
                    color: Theme.of(context).dividerColor,
                  ),
                  itemBuilder: (context, index) {
                    final supplier = filtered[index];
                    final initial =
                        supplier.name.isNotEmpty ? supplier.name[0] : '?';
                    return ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: AlhaiSpacing.xxs,
                          vertical: AlhaiSpacing.xs),
                      leading: Hero(
                        tag: 'supplier-avatar-${supplier.id}',
                        child: CircleAvatar(
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
                      ),
                      title: Text(
                        supplier.name,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                      subtitle: Text(
                        supplier.phone ?? '',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: AlhaiSpacing.xxs),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.1),
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
                          SizedBox(width: AlhaiSpacing.xs),
                          Icon(
                            Directionality.of(context) == TextDirection.rtl
                                ? Icons.chevron_right
                                : Icons.chevron_left,
                            color: isDark
                                ? Colors.white.withValues(alpha: 0.3)
                                : AppColors.textTertiary,
                          ),
                        ],
                      ),
                      onTap: () =>
                          _showSupplierDetailFromData(context, supplier),
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

  void _showSupplierDetailFromData(
      BuildContext context, SuppliersTableData supplier) {
    final l10n = AppLocalizations.of(context);
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
          padding: const EdgeInsets.all(AlhaiSpacing.lg),
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
              SizedBox(height: AlhaiSpacing.lg),
              CircleAvatar(
                radius: 40,
                backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                child:
                    const Icon(Icons.store, size: 40, color: AppColors.primary),
              ),
              SizedBox(height: AlhaiSpacing.md),
              Text(
                supplier.name,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              SizedBox(height: AlhaiSpacing.lg),
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
              SizedBox(height: AlhaiSpacing.lg),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.edit),
                      label: Text(l10n.edit),
                    ),
                  ),
                  SizedBox(width: AlhaiSpacing.md),
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
    final l10n = AppLocalizations.of(context);
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
            SizedBox(height: AlhaiSpacing.sm),
            TextField(
              controller: phoneCtrl,
              decoration: InputDecoration(
                labelText: l10n.phone,
                prefixIcon: const Icon(Icons.phone),
              ),
              keyboardType: TextInputType.phone,
            ),
            SizedBox(height: AlhaiSpacing.sm),
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

              // Security: Check for dangerous content
              final fieldsToCheck = [nameCtrl.text, emailCtrl.text];
              for (final value in fieldsToCheck) {
                if (value.trim().isNotEmpty &&
                    InputSanitizer.containsDangerousContent(value)) {
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(l10n.inputContainsDangerousContent),
                      backgroundColor: Theme.of(context).colorScheme.error,
                    ),
                  );
                  return;
                }
              }

              Navigator.pop(dialogContext);
              await addSupplier(
                ref,
                name: nameCtrl.text,
                phone: phoneCtrl.text.isEmpty ? null : phoneCtrl.text,
                email: emailCtrl.text.isEmpty ? null : emailCtrl.text,
              );
              if (!context.mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(l10n.supplierUpdatedMsg)),
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
      padding: const EdgeInsets.all(AlhaiSpacing.mdl),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).dividerColor,
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
          SizedBox(width: AlhaiSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
                SizedBox(height: AlhaiSpacing.xxs),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface,
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
      padding: const EdgeInsets.symmetric(vertical: AlhaiSpacing.xs),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppColors.textSecondary),
          SizedBox(width: AlhaiSpacing.sm),
          Text(label, style: const TextStyle(color: AppColors.textSecondary)),
          const Spacer(),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}
