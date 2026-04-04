/// Lite Pending Approvals Screen
///
/// Shows all items requiring manager approval: refunds and
/// purchase orders. Queried from returnsDao and purchasesDao.
/// Supports RTL, dark mode, and responsive layouts.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:alhai_l10n/alhai_l10n.dart';
import 'package:alhai_design_system/alhai_design_system.dart';
import 'package:alhai_database/alhai_database.dart';
import 'package:alhai_auth/alhai_auth.dart';
import 'package:get_it/get_it.dart';

import '../../providers/lite_screen_providers.dart';

/// Pending approvals screen for Admin Lite
class LitePendingApprovalsScreen extends ConsumerWidget {
  const LitePendingApprovalsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final size = MediaQuery.of(context).size;
    final isMobile = size.width < 600;
    final l10n = AppLocalizations.of(context)!;
    final dataAsync = ref.watch(litePendingApprovalsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.pendingItems),
        centerTitle: true,
        actions: [
          dataAsync.when(
            data: (items) => Container(
              margin: const EdgeInsetsDirectional.only(end: AlhaiSpacing.md),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: AlhaiSpacing.xxs),
              decoration: BoxDecoration(color: AlhaiColors.warning, borderRadius: BorderRadius.circular(12)),
              child: Text('${items.length}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
            ),
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
          ),
        ],
      ),
      body: dataAsync.when(
        data: (items) {
          if (items.isEmpty) return _buildEmptyState(context, isDark, l10n);
          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(litePendingApprovalsProvider),
            child: ListView.builder(
              padding: EdgeInsets.all(isMobile ? AlhaiSpacing.md : AlhaiSpacing.lg),
              itemCount: items.length,
              itemBuilder: (context, index) {
                return _buildApprovalCard(context, items[index], isDark, l10n, ref);
              },
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(l10n.errorOccurred),
              TextButton.icon(onPressed: () => ref.invalidate(litePendingApprovalsProvider), icon: const Icon(Icons.refresh_rounded), label: Text(l10n.tryAgain)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, bool isDark, AppLocalizations l10n) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.check_circle_outline, size: 64, color: isDark ? Colors.white24 : AlhaiColors.success.withValues(alpha: 0.5)),
          const SizedBox(height: AlhaiSpacing.md),
          Text(l10n.noResults, style: TextStyle(fontSize: 16, color: isDark ? Colors.white54 : Theme.of(context).colorScheme.onSurfaceVariant)),
        ],
      ),
    );
  }

  IconData _typeIcon(String type) => type == 'refund' ? Icons.undo : Icons.shopping_cart;
  Color _typeColor(String type) => type == 'refund' ? AlhaiColors.warning : AlhaiColors.info;

  String _timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 60) return '${diff.inMinutes} min ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }

  Widget _buildApprovalCard(BuildContext context, PendingApprovalItem item, bool isDark, AppLocalizations l10n, WidgetRef ref) {
    final color = _typeColor(item.type);
    final icon = _typeIcon(item.type);

    return Container(
      margin: const EdgeInsets.only(bottom: AlhaiSpacing.sm),
      padding: const EdgeInsets.all(AlhaiSpacing.md),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.06) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? Colors.white12 : Theme.of(context).colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40, height: 40,
                decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(10)),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: AlhaiSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item.type == 'refund' ? 'Refund Request' : 'Purchase Order', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: isDark ? Colors.white : Colors.black87)),
                    Text(item.reference, style: TextStyle(fontSize: 12, color: isDark ? Colors.white38 : Theme.of(context).colorScheme.onSurfaceVariant)),
                  ],
                ),
              ),
              Text('${item.amount.toStringAsFixed(0)} SAR', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: isDark ? Colors.white : Colors.black87)),
            ],
          ),
          const SizedBox(height: AlhaiSpacing.sm),
          Text(item.description, style: TextStyle(fontSize: 13, color: isDark ? Colors.white54 : Theme.of(context).colorScheme.onSurfaceVariant)),
          const SizedBox(height: AlhaiSpacing.xs),
          Row(
            children: [
              Icon(Icons.person, size: 14, color: isDark ? Colors.white24 : Colors.black38),
              const SizedBox(width: AlhaiSpacing.xxs),
              Text(item.requestedBy, style: TextStyle(fontSize: 12, color: isDark ? Colors.white38 : Colors.black45)),
              const SizedBox(width: AlhaiSpacing.md),
              Icon(Icons.access_time, size: 14, color: isDark ? Colors.white24 : Colors.black38),
              const SizedBox(width: AlhaiSpacing.xxs),
              Text(_timeAgo(item.createdAt), style: TextStyle(fontSize: 12, color: isDark ? Colors.white38 : Colors.black45)),
            ],
          ),
          const SizedBox(height: AlhaiSpacing.md),
          const Divider(height: 1),
          const SizedBox(height: AlhaiSpacing.sm),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () async {
                    if (item.type == 'refund') {
                      final db = GetIt.I<AppDatabase>();
                      await db.customStatement("UPDATE returns SET status = 'rejected' WHERE id = ?", [item.id]);
                    } else {
                      final db = GetIt.I<AppDatabase>();
                      await db.purchasesDao.updateStatus(item.id, 'rejected');
                    }
                    ref.invalidate(litePendingApprovalsProvider);
                  },
                  icon: const Icon(Icons.close, size: 16),
                  label: Text(l10n.reject),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AlhaiColors.error,
                    side: const BorderSide(color: AlhaiColors.error),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                ),
              ),
              const SizedBox(width: AlhaiSpacing.sm),
              Expanded(
                child: FilledButton.icon(
                  onPressed: () async {
                    if (item.type == 'refund') {
                      final db = GetIt.I<AppDatabase>();
                      await db.customStatement("UPDATE returns SET status = 'approved' WHERE id = ?", [item.id]);
                    } else {
                      final db = GetIt.I<AppDatabase>();
                      await db.purchasesDao.updateStatus(item.id, 'approved');
                    }
                    ref.invalidate(litePendingApprovalsProvider);
                  },
                  icon: const Icon(Icons.check, size: 16),
                  label: Text(l10n.approve),
                  style: FilledButton.styleFrom(
                    backgroundColor: AlhaiColors.success,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
