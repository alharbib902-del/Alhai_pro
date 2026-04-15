/// Pricing Tiers Management Screen
///
/// Two tabs:
/// 1. Tiers — CRUD for pricing tiers (name, discount%, default)
/// 2. Store Assignment — assign each store to a tier
///
/// Supports: RTL Arabic, dark/light theme, responsive layout.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:alhai_design_system/alhai_design_system.dart';
import 'package:intl/intl.dart' show DateFormat;

import '../../data/models.dart';
import '../../providers/distributor_providers.dart';
import '../../ui/skeleton_loading.dart';
import 'tier_form_dialog.dart';

class PricingTiersScreen extends ConsumerStatefulWidget {
  const PricingTiersScreen({super.key});

  @override
  ConsumerState<PricingTiersScreen> createState() => _PricingTiersScreenState();
}

class _PricingTiersScreenState extends ConsumerState<PricingTiersScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // ─── Tier CRUD ─────────────────────────────────────────────────

  Future<void> _createTier() async {
    final result = await showTierFormDialog(context);
    if (result == null || !mounted) return;

    setState(() => _isProcessing = true);
    try {
      final ds = ref.read(distributorDatasourceProvider);
      await ds.createPricingTier(
        name: result.name,
        nameAr: result.nameAr,
        discountPercent: result.discountPercent,
        isDefault: result.isDefault,
      );
      ref.invalidate(pricingTiersProvider);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تم إنشاء الفئة بنجاح'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('خطأ: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
    if (mounted) setState(() => _isProcessing = false);
  }

  Future<void> _editTier(PricingTier tier) async {
    final result = await showTierFormDialog(context, existing: tier);
    if (result == null || !mounted) return;

    setState(() => _isProcessing = true);
    try {
      final ds = ref.read(distributorDatasourceProvider);
      await ds.updatePricingTier(
        tierId: tier.id,
        name: result.name,
        nameAr: result.nameAr,
        discountPercent: result.discountPercent,
        isDefault: result.isDefault,
      );
      ref.invalidate(pricingTiersProvider);
      ref.invalidate(storeTierAssignmentsProvider);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تم تحديث الفئة'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('خطأ: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
    if (mounted) setState(() => _isProcessing = false);
  }

  Future<void> _deleteTier(PricingTier tier) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('حذف الفئة'),
        content: Text(
          'هل تريد حذف فئة "${tier.displayName}"؟\n'
          'سيتم إزالة التعيين من جميع المتاجر المرتبطة.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('إلغاء'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: AppColors.textOnPrimary,
            ),
            child: const Text('حذف'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    setState(() => _isProcessing = true);
    try {
      final ds = ref.read(distributorDatasourceProvider);
      await ds.deletePricingTier(tier.id);
      ref.invalidate(pricingTiersProvider);
      ref.invalidate(storeTierAssignmentsProvider);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تم حذف الفئة'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('خطأ: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
    if (mounted) setState(() => _isProcessing = false);
  }

  // ─── Store Assignment ──────────────────────────────────────────

  Future<void> _assignStore(String storeId, String? tierId) async {
    setState(() => _isProcessing = true);
    try {
      final ds = ref.read(distributorDatasourceProvider);
      if (tierId == null) {
        await ds.removeStoreFromTier(storeId);
      } else {
        await ds.assignStoreToTier(storeId: storeId, tierId: tierId);
      }
      ref.invalidate(storeTierAssignmentsProvider);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('خطأ: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
    if (mounted) setState(() => _isProcessing = false);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: AppColors.getBackground(isDark),
      appBar: AppBar(
        title: Text(
          'فئات الأسعار',
          style: TextStyle(fontWeight: FontWeight.bold, color: cs.onSurface),
        ),
        centerTitle: false,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'الفئات', icon: Icon(Icons.layers_outlined, size: 18)),
            Tab(
              text: 'تعيين المتاجر',
              icon: Icon(Icons.store_outlined, size: 18),
            ),
          ],
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.getTextSecondary(isDark),
          indicatorColor: AppColors.primary,
        ),
        actions: [
          if (_isProcessing)
            const Padding(
              padding: EdgeInsets.all(AlhaiSpacing.md),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _isProcessing ? null : _createTier,
        icon: const Icon(Icons.add),
        label: const Text('فئة جديدة'),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textOnPrimary,
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _TiersTab(
            onEdit: _editTier,
            onDelete: _deleteTier,
          ),
          _StoreAssignmentTab(onAssign: _assignStore),
        ],
      ),
    );
  }
}

// ─── Tiers Tab ───────────────────────────────────────────────────

class _TiersTab extends ConsumerWidget {
  final void Function(PricingTier) onEdit;
  final void Function(PricingTier) onDelete;

  const _TiersTab({required this.onEdit, required this.onDelete});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final tiersAsync = ref.watch(pricingTiersProvider);

    return tiersAsync.when(
      loading: () => const TableSkeleton(rows: 4, columns: 3),
      error: (e, _) => _ErrorState(
        message: _getErrorMessage(e),
        onRetry: () => ref.invalidate(pricingTiersProvider),
        isDark: isDark,
      ),
      data: (tiers) {
        if (tiers.isEmpty) {
          return _EmptyState(
            icon: Icons.layers_outlined,
            message: 'لا يوجد فئات بعد',
            subtitle: 'أنشئ فئة سعرية لبدء تخصيص الأسعار للمتاجر',
            isDark: isDark,
          );
        }

        return RefreshIndicator(
          onRefresh: () async => ref.invalidate(pricingTiersProvider),
          child: ListView.separated(
            padding: const EdgeInsets.all(AlhaiSpacing.mdl),
            itemCount: tiers.length,
            separatorBuilder: (_, __) =>
                const SizedBox(height: AlhaiSpacing.sm),
            itemBuilder: (_, index) {
              final tier = tiers[index];
              return _TierCard(
                tier: tier,
                onEdit: () => onEdit(tier),
                onDelete: () => onDelete(tier),
                isDark: isDark,
              );
            },
          ),
        );
      },
    );
  }

  String _getErrorMessage(Object error) {
    final msg = error.toString();
    if (msg.contains('42P01') || msg.contains('does not exist')) {
      return 'خاصية فئات الأسعار غير مفعّلة بعد.\n'
          'يرجى تنفيذ migration قاعدة البيانات أولاً.';
    }
    return 'حدث خطأ أثناء تحميل الفئات';
  }
}

class _TierCard extends StatelessWidget {
  final PricingTier tier;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final bool isDark;

  const _TierCard({
    required this.tier,
    required this.onEdit,
    required this.onDelete,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AlhaiSpacing.mdl),
      decoration: BoxDecoration(
        color: AppColors.getSurface(isDark),
        borderRadius: BorderRadius.circular(AlhaiRadius.md + 2),
        border: Border.all(
          color: tier.isDefault
              ? AppColors.primary.withValues(alpha: 0.4)
              : AppColors.getBorder(isDark),
        ),
      ),
      child: Row(
        children: [
          // Tier icon
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: isDark ? 0.15 : 0.08),
              borderRadius: BorderRadius.circular(AlhaiRadius.md),
            ),
            child: Icon(
              Icons.layers_rounded,
              color: AppColors.primary,
              size: 22,
            ),
          ),
          const SizedBox(width: AlhaiSpacing.md),
          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      tier.displayName,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.getTextPrimary(isDark),
                      ),
                    ),
                    if (tier.nameAr != null && tier.nameAr != tier.name) ...[
                      const SizedBox(width: AlhaiSpacing.xs),
                      Text(
                        '(${tier.name})',
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.getTextMuted(isDark),
                        ),
                      ),
                    ],
                    if (tier.isDefault) ...[
                      const SizedBox(width: AlhaiSpacing.sm),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          borderRadius:
                              BorderRadius.circular(AlhaiRadius.sm),
                        ),
                        child: const Text(
                          'افتراضي',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: AlhaiSpacing.xxs),
                Row(
                  children: [
                    Icon(
                      Icons.discount_outlined,
                      size: 14,
                      color: AppColors.getTextMuted(isDark),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'خصم ${tier.discountDisplay}',
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.getTextSecondary(isDark),
                      ),
                    ),
                    const SizedBox(width: AlhaiSpacing.md),
                    Icon(
                      Icons.calendar_today_outlined,
                      size: 12,
                      color: AppColors.getTextMuted(isDark),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      DateFormat('dd/MM/yyyy', 'ar')
                          .format(tier.createdAt),
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.getTextMuted(isDark),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Actions
          PopupMenuButton<String>(
            onSelected: (action) {
              if (action == 'edit') onEdit();
              if (action == 'delete') onDelete();
            },
            itemBuilder: (_) => [
              const PopupMenuItem(
                value: 'edit',
                child: Row(
                  children: [
                    Icon(Icons.edit_outlined, size: 18),
                    SizedBox(width: 8),
                    Text('تعديل'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(
                      Icons.delete_outline,
                      size: 18,
                      color: AppColors.error,
                    ),
                    SizedBox(width: 8),
                    Text(
                      'حذف',
                      style: TextStyle(color: AppColors.error),
                    ),
                  ],
                ),
              ),
            ],
            icon: Icon(
              Icons.more_vert,
              color: AppColors.getTextMuted(isDark),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Store Assignment Tab ────────────────────────────────────────

class _StoreAssignmentTab extends ConsumerWidget {
  final void Function(String storeId, String? tierId) onAssign;

  const _StoreAssignmentTab({required this.onAssign});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final storesAsync = ref.watch(orgStoresProvider);
    final tiersAsync = ref.watch(pricingTiersProvider);
    final assignmentsAsync = ref.watch(storeTierAssignmentsProvider);

    // Wait for all three providers
    if (storesAsync.isLoading ||
        tiersAsync.isLoading ||
        assignmentsAsync.isLoading) {
      return const TableSkeleton(rows: 5, columns: 3);
    }

    if (storesAsync.hasError) {
      return _ErrorState(
        message: 'خطأ في تحميل المتاجر',
        onRetry: () => ref.invalidate(orgStoresProvider),
        isDark: isDark,
      );
    }

    final stores = storesAsync.valueOrNull ?? [];
    final tiers = tiersAsync.valueOrNull ?? [];
    final assignments = assignmentsAsync.valueOrNull ?? [];

    if (stores.isEmpty) {
      return _EmptyState(
        icon: Icons.store_outlined,
        message: 'لا يوجد متاجر',
        subtitle: 'لم يتم العثور على متاجر مرتبطة بحسابك',
        isDark: isDark,
      );
    }

    if (tiers.isEmpty) {
      return _EmptyState(
        icon: Icons.layers_outlined,
        message: 'أنشئ فئة أولاً',
        subtitle: 'يجب إنشاء فئة سعرية قبل تعيينها للمتاجر',
        isDark: isDark,
      );
    }

    // Build a map: storeId → tierId
    final assignmentMap = <String, String>{};
    for (final a in assignments) {
      assignmentMap[a.storeId] = a.tierId;
    }

    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(orgStoresProvider);
        ref.invalidate(storeTierAssignmentsProvider);
      },
      child: ListView.separated(
        padding: const EdgeInsets.all(AlhaiSpacing.mdl),
        itemCount: stores.length,
        separatorBuilder: (_, __) => const SizedBox(height: AlhaiSpacing.sm),
        itemBuilder: (_, index) {
          final store = stores[index];
          final currentTierId = assignmentMap[store.id];

          return _StoreAssignmentCard(
            storeName: store.name,
            storeId: store.id,
            currentTierId: currentTierId,
            tiers: tiers,
            onChanged: (tierId) => onAssign(store.id, tierId),
            isDark: isDark,
          );
        },
      ),
    );
  }
}

class _StoreAssignmentCard extends StatelessWidget {
  final String storeName;
  final String storeId;
  final String? currentTierId;
  final List<PricingTier> tiers;
  final void Function(String?) onChanged;
  final bool isDark;

  const _StoreAssignmentCard({
    required this.storeName,
    required this.storeId,
    required this.currentTierId,
    required this.tiers,
    required this.onChanged,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final currentTier = currentTierId != null
        ? tiers.where((t) => t.id == currentTierId).firstOrNull
        : null;

    return Container(
      padding: const EdgeInsets.all(AlhaiSpacing.mdl),
      decoration: BoxDecoration(
        color: AppColors.getSurface(isDark),
        borderRadius: BorderRadius.circular(AlhaiRadius.md + 2),
        border: Border.all(color: AppColors.getBorder(isDark)),
      ),
      child: Row(
        children: [
          // Store icon
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.info.withValues(alpha: isDark ? 0.15 : 0.08),
              borderRadius: BorderRadius.circular(AlhaiRadius.md),
            ),
            child: Icon(Icons.store_rounded, color: AppColors.info, size: 20),
          ),
          const SizedBox(width: AlhaiSpacing.md),
          // Store name + current tier info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  storeName,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.getTextPrimary(isDark),
                  ),
                ),
                if (currentTier != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    'خصم ${currentTier.discountDisplay}',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.getTextMuted(isDark),
                    ),
                  ),
                ],
              ],
            ),
          ),
          // Tier dropdown
          SizedBox(
            width: 160,
            child: DropdownButtonFormField<String?>(
              initialValue: currentTierId,
              isExpanded: true,
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                filled: true,
                fillColor: AppColors.getSurfaceVariant(isDark),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AlhaiRadius.sm + 2),
                  borderSide: BorderSide(color: AppColors.getBorder(isDark)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AlhaiRadius.sm + 2),
                  borderSide: BorderSide(color: AppColors.getBorder(isDark)),
                ),
              ),
              hint: const Text('اختر فئة', style: TextStyle(fontSize: 13)),
              items: [
                const DropdownMenuItem<String?>(
                  value: null,
                  child: Text(
                    'بدون فئة',
                    style: TextStyle(fontSize: 13, fontStyle: FontStyle.italic),
                  ),
                ),
                ...tiers.map(
                  (t) => DropdownMenuItem<String?>(
                    value: t.id,
                    child: Text(
                      '${t.displayName} (${t.discountDisplay})',
                      style: const TextStyle(fontSize: 13),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              ],
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Shared States ───────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String message;
  final String subtitle;
  final bool isDark;

  const _EmptyState({
    required this.icon,
    required this.message,
    required this.subtitle,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AlhaiSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 64, color: AppColors.getTextMuted(isDark)),
            const SizedBox(height: AlhaiSpacing.md),
            Text(
              message,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.getTextSecondary(isDark),
              ),
            ),
            const SizedBox(height: AlhaiSpacing.xs),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 13,
                color: AppColors.getTextMuted(isDark),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  final bool isDark;

  const _ErrorState({
    required this.message,
    required this.onRetry,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AlhaiSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 48,
              color: AppColors.getTextMuted(isDark),
            ),
            const SizedBox(height: AlhaiSpacing.md),
            Text(
              message,
              style: TextStyle(
                fontSize: 14,
                color: AppColors.getTextSecondary(isDark),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AlhaiSpacing.md),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh, size: 18),
              label: const Text('إعادة المحاولة'),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.textOnPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
