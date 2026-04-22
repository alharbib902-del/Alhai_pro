/// ZATCA submission-queue report for admin (Tier B M7).
///
/// Shows an operator how many invoices have been sent, are still pending
/// retry in the offline queue, or have been moved to the dead-letter
/// table after exhausting all retries. Pure read-only view.
library;

import 'package:alhai_auth/alhai_auth.dart' show currentStoreIdProvider;
import 'package:alhai_database/alhai_database.dart';
import 'package:alhai_design_system/alhai_design_system.dart';
import 'package:alhai_l10n/alhai_l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_it/get_it.dart';

/// Aggregated counts for the three queue states.
class _ZatcaQueueSummary {
  final int pending;
  final int rejected;
  final int sent;

  const _ZatcaQueueSummary({
    required this.pending,
    required this.rejected,
    required this.sent,
  });
}

/// Summary counts provider: pending + dead-letter + sent.
/// `sent` is computed as `invoices.zatcaHash IS NOT NULL` — the queue
/// does not keep successfully-sent rows, so we count the invoices table
/// directly.
final _zatcaQueueSummaryProvider =
    FutureProvider.autoDispose<_ZatcaQueueSummary>((ref) async {
  final storeId = ref.watch(currentStoreIdProvider);
  final db = GetIt.I<AppDatabase>();
  final pending = await db.zatcaOfflineQueueDao.getPendingCount(
    storeId: storeId,
  );
  final rejected = await db.zatcaOfflineQueueDao.getDeadLetterCount(
    storeId: storeId,
  );
  final sent = await db.invoicesDao.getZatcaSentCount(storeId: storeId);
  return _ZatcaQueueSummary(
    pending: pending,
    rejected: rejected,
    sent: sent,
  );
});

final _pendingItemsProvider =
    FutureProvider.autoDispose<List<ZatcaOfflineQueueTableData>>((ref) {
  final storeId = ref.watch(currentStoreIdProvider);
  final db = GetIt.I<AppDatabase>();
  return db.zatcaOfflineQueueDao.getPending(storeId: storeId);
});

final _rejectedItemsProvider =
    FutureProvider.autoDispose<List<ZatcaDeadLetterTableData>>((ref) {
  final storeId = ref.watch(currentStoreIdProvider);
  final db = GetIt.I<AppDatabase>();
  return db.zatcaOfflineQueueDao.getDeadLetter(storeId: storeId);
});

/// Admin-facing ZATCA submission-queue status report.
class ZatcaQueueReportScreen extends ConsumerWidget {
  const ZatcaQueueReportScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final summary = ref.watch(_zatcaQueueSummaryProvider);
    final pendingAsync = ref.watch(_pendingItemsProvider);
    final rejectedAsync = ref.watch(_rejectedItemsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.zatcaQueueReportTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: l10n.retry,
            onPressed: () {
              ref.invalidate(_zatcaQueueSummaryProvider);
              ref.invalidate(_pendingItemsProvider);
              ref.invalidate(_rejectedItemsProvider);
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(_zatcaQueueSummaryProvider);
          ref.invalidate(_pendingItemsProvider);
          ref.invalidate(_rejectedItemsProvider);
          // Wait a frame so the refresh spinner has a chance to render.
          await Future<void>.delayed(const Duration(milliseconds: 100));
        },
        child: ListView(
          padding: const EdgeInsets.all(AlhaiSpacing.md),
          children: [
            summary.when(
              data: (s) => _SummaryRow(summary: s),
              loading: () => const Padding(
                padding: EdgeInsets.all(AlhaiSpacing.md),
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (err, _) => _ErrorTile(message: '$err'),
            ),
            const SizedBox(height: AlhaiSpacing.lg),
            _SectionHeader(
              icon: Icons.error_outline_rounded,
              color: AppColors.error,
              label: l10n.zatcaRejectedSection,
            ),
            rejectedAsync.when(
              data: (items) => items.isEmpty
                  ? _EmptyTile(message: l10n.zatcaNoRejectedInvoices)
                  : Column(
                      children: items
                          .map((it) => _RejectedItemTile(item: it))
                          .toList(growable: false),
                    ),
              loading: () => const Padding(
                padding: EdgeInsets.all(AlhaiSpacing.md),
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (err, _) => _ErrorTile(message: '$err'),
            ),
            const SizedBox(height: AlhaiSpacing.lg),
            _SectionHeader(
              icon: Icons.hourglass_empty_rounded,
              color: AppColors.warning,
              label: l10n.zatcaPendingSection,
            ),
            pendingAsync.when(
              data: (items) => items.isEmpty
                  ? _EmptyTile(message: l10n.zatcaNoPendingInvoices)
                  : Column(
                      children: items
                          .map((it) => _PendingItemTile(item: it))
                          .toList(growable: false),
                    ),
              loading: () => const Padding(
                padding: EdgeInsets.all(AlhaiSpacing.md),
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (err, _) => _ErrorTile(message: '$err'),
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final _ZatcaQueueSummary summary;

  const _SummaryRow({required this.summary});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Row(
      children: [
        Expanded(
          child: _SummaryCard(
            icon: Icons.check_circle_outline_rounded,
            color: AppColors.success,
            label: l10n.zatcaSent,
            value: summary.sent,
          ),
        ),
        const SizedBox(width: AlhaiSpacing.sm),
        Expanded(
          child: _SummaryCard(
            icon: Icons.hourglass_empty_rounded,
            color: AppColors.warning,
            label: l10n.zatcaPendingLabel,
            value: summary.pending,
          ),
        ),
        const SizedBox(width: AlhaiSpacing.sm),
        Expanded(
          child: _SummaryCard(
            icon: Icons.error_outline_rounded,
            color: AppColors.error,
            label: l10n.zatcaRejected,
            value: summary.rejected,
          ),
        ),
      ],
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;
  final int value;

  const _SummaryCard({
    required this.icon,
    required this.color,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Semantics(
      label: '$label: $value',
      child: Container(
        padding: const EdgeInsets.all(AlhaiSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.getSurface(isDark),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.getBorder(isDark)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ExcludeSemantics(
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(height: AlhaiSpacing.sm),
            Text(
              '$value',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AppColors.getTextPrimary(isDark),
              ),
            ),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: AppColors.getTextMuted(isDark),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;

  const _SectionHeader({
    required this.icon,
    required this.color,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AlhaiSpacing.sm),
      child: Row(
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(width: AlhaiSpacing.xs),
          Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 15,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}

class _PendingItemTile extends StatelessWidget {
  final ZatcaOfflineQueueTableData item;

  const _PendingItemTile({required this.item});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Card(
      margin: const EdgeInsets.symmetric(vertical: AlhaiSpacing.xxs),
      child: ListTile(
        leading: const Icon(
          Icons.receipt_long_rounded,
          color: AppColors.warning,
        ),
        title: Text(item.invoiceNumber),
        subtitle: Text(
          '${l10n.zatcaRetriesLabel(item.retryCount)} · '
          '${_formatDate(item.queuedAt)}',
        ),
        trailing: item.lastError != null
            ? Tooltip(
                message: item.lastError!,
                child: const Icon(Icons.info_outline_rounded, size: 18),
              )
            : null,
      ),
    );
  }
}

class _RejectedItemTile extends StatelessWidget {
  final ZatcaDeadLetterTableData item;

  const _RejectedItemTile({required this.item});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Card(
      margin: const EdgeInsets.symmetric(vertical: AlhaiSpacing.xxs),
      child: ExpansionTile(
        leading: const Icon(Icons.block_rounded, color: AppColors.error),
        title: Text(item.invoiceNumber),
        subtitle: Text(
          '${l10n.zatcaRetriesLabel(item.retryCount)} · '
          '${_formatDate(item.deadLetteredAt)}',
        ),
        childrenPadding: const EdgeInsets.fromLTRB(
          AlhaiSpacing.md,
          0,
          AlhaiSpacing.md,
          AlhaiSpacing.md,
        ),
        children: [
          if (item.lastError != null && item.lastError!.isNotEmpty)
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: SelectableText(
                item.lastError!,
                style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _EmptyTile extends StatelessWidget {
  final String message;

  const _EmptyTile({required this.message});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: AlhaiSpacing.xxs),
      child: Padding(
        padding: const EdgeInsets.all(AlhaiSpacing.md),
        child: Row(
          children: [
            Icon(
              Icons.check_circle_outline_rounded,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            const SizedBox(width: AlhaiSpacing.sm),
            Expanded(
              child: Text(
                message,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorTile extends StatelessWidget {
  final String message;

  const _ErrorTile({required this.message});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppColors.error.withValues(alpha: 0.08),
      margin: const EdgeInsets.symmetric(vertical: AlhaiSpacing.xxs),
      child: Padding(
        padding: const EdgeInsets.all(AlhaiSpacing.md),
        child: Row(
          children: [
            const Icon(Icons.error_outline_rounded, color: AppColors.error),
            const SizedBox(width: AlhaiSpacing.sm),
            Expanded(
              child: SelectableText(
                message,
                style: const TextStyle(color: AppColors.error, fontSize: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

String _formatDate(DateTime d) {
  String two(int n) => n.toString().padLeft(2, '0');
  return '${d.year}-${two(d.month)}-${two(d.day)} '
      '${two(d.hour)}:${two(d.minute)}';
}
