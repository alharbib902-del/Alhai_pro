import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:alhai_shared_ui/alhai_shared_ui.dart';
import 'package:alhai_l10n/alhai_l10n.dart';
import 'package:alhai_design_system/alhai_design_system.dart';

/// Print Queue Screen - Admin version
/// Displays pending print jobs with status indicators and reprint/cancel actions
class PrintQueueScreen extends ConsumerStatefulWidget {
  const PrintQueueScreen({super.key});

  @override
  ConsumerState<PrintQueueScreen> createState() => _PrintQueueScreenState();
}

class _PrintQueueScreenState extends ConsumerState<PrintQueueScreen> {
  bool _isPrinting = false;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isWideScreen = size.width > 900;
    final isMediumScreen = size.width > 600;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context);
    final jobs = ref.watch(printQueueProvider);

    return Column(
      children: [
        AppHeader(
          title: l10n.printQueueTitle,
          onMenuTap: isWideScreen
              ? null
              : () => Scaffold.of(context).openDrawer(),
          onNotificationsTap: () => context.push('/notifications'),
          notificationsCount: 3,
          userName: l10n.defaultUserName,
          userRole: l10n.branchManager,
          actions: [
            IconButton(
              icon: Icon(Icons.settings,
                  color: Theme.of(context).colorScheme.onSurfaceVariant),
              tooltip: l10n.printerSettings,
              onPressed: () => context.push(AppRoutes.settingsPrinter),
            ),
          ],
        ),
        Expanded(
          child: jobs.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.print_disabled,
                          size: 64,
                          color: isDark
                              ? Colors.white24
                              : AppColors.textTertiary),
                      const SizedBox(height: AlhaiSpacing.md),
                      Text(
                        l10n.noPrintJobsPending,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                )
              : SingleChildScrollView(
                  padding: EdgeInsets.all(isMediumScreen ? 24 : 16),
                  child: _buildContent(
                      jobs, isWideScreen, isMediumScreen, isDark, l10n),
                ),
        ),
      ],
    );
  }

  Widget _buildContent(List<PrintJob> jobs, bool isWideScreen,
      bool isMediumScreen, bool isDark, AppLocalizations l10n) {
    final pendingCount = jobs.where((j) => j.status == 'pending').length;
    final failedCount = jobs.where((j) => j.status == 'failed').length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Printer status
        Container(
          padding: const EdgeInsets.all(AlhaiSpacing.md),
          decoration: BoxDecoration(
            color: isDark
                ? AppColors.success.withValues(alpha: 0.1)
                : AppColors.successSurface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppColors.success.withValues(alpha: 0.3),
            ),
          ),
          child: Row(
            children: [
              const Icon(Icons.check_circle,
                  color: AppColors.success, size: 20),
              const SizedBox(width: AlhaiSpacing.sm),
              Expanded(
                child: Text(
                  l10n.printerConnected,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Text(
                'XP-80C',
                style: TextStyle(
                    color:
                        Theme.of(context).colorScheme.onSurfaceVariant),
              ),
            ],
          ),
        ),
        const SizedBox(height: AlhaiSpacing.md),

        // Stats row
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                icon: Icons.print,
                label: l10n.total,
                value: '${jobs.length}',
                color: AppColors.info,
                isDark: isDark,
              ),
            ),
            const SizedBox(width: AlhaiSpacing.sm),
            Expanded(
              child: _buildStatCard(
                icon: Icons.hourglass_empty,
                label: l10n.pending,
                value: '$pendingCount',
                color: AppColors.warning,
                isDark: isDark,
              ),
            ),
            const SizedBox(width: AlhaiSpacing.sm),
            Expanded(
              child: _buildStatCard(
                icon: Icons.error_outline,
                label: l10n.failedPrintLabel,
                value: '$failedCount',
                color: AppColors.error,
                isDark: isDark,
              ),
            ),
          ],
        ),
        const SizedBox(height: AlhaiSpacing.md),

        // Header row
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '${jobs.length} ${l10n.pending}',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            Row(
              children: [
                TextButton(
                  onPressed: _clearAll,
                  child: Text(l10n.clearAll,
                      style: const TextStyle(color: AppColors.error)),
                ),
                const SizedBox(width: AlhaiSpacing.xs),
                FilledButton.icon(
                  onPressed: _isPrinting ? null : _printAll,
                  icon: _isPrinting
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white))
                      : const Icon(Icons.print, size: 18),
                  label: Text(
                      _isPrinting ? l10n.printingInProgress : l10n.printAll),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: AlhaiSpacing.sm),

        // Jobs list
        ...List.generate(jobs.length, (index) {
          final job = jobs[index];
          return Container(
            margin: const EdgeInsets.only(bottom: AlhaiSpacing.xs),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: job.status == 'failed'
                    ? AppColors.error.withValues(alpha: 0.3)
                    : (Theme.of(context).dividerColor),
              ),
            ),
            child: ListTile(
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: AlhaiSpacing.md, vertical: AlhaiSpacing.xxs),
              leading: CircleAvatar(
                backgroundColor: job.status == 'failed'
                    ? AppColors.error.withValues(alpha: 0.1)
                    : AppColors.info.withValues(alpha: 0.1),
                child: Icon(
                  job.type == 'receipt'
                      ? Icons.receipt
                      : Icons.description,
                  color: job.status == 'failed'
                      ? AppColors.error
                      : AppColors.info,
                ),
              ),
              title: Text(
                job.receiptNo.isNotEmpty ? job.receiptNo : job.saleId,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              subtitle: Row(
                children: [
                  Icon(
                    job.status == 'failed'
                        ? Icons.error
                        : Icons.schedule,
                    size: 14,
                    color: job.status == 'failed'
                        ? AppColors.error
                        : AppColors.textTertiary,
                  ),
                  const SizedBox(width: AlhaiSpacing.xxs),
                  Expanded(
                    child: Text(
                      job.status == 'failed'
                          ? l10n.failedPrintLabel
                          : job.status == 'printing'
                              ? l10n.printingInProgress
                              : l10n.waitingStatus,
                      style: TextStyle(
                        color: job.status == 'failed'
                            ? AppColors.error
                            : (Theme.of(context).colorScheme.onSurfaceVariant),
                      ),
                    ),
                  ),
                ],
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.print, color: AppColors.info),
                    onPressed: () => _printJob(job),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline,
                        color: AppColors.error),
                    onPressed: () => _removeJob(job),
                  ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.all(AlhaiSpacing.md),
      decoration: BoxDecoration(
        color: isDark
            ? color.withValues(alpha: 0.1)
            : color.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: AlhaiSpacing.xs),
          Text(
            value,
            style: TextStyle(
                fontWeight: FontWeight.bold, color: color, fontSize: 20),
          ),
          Text(
            label,
            style:
                TextStyle(fontSize: 12, color: color.withValues(alpha: 0.8)),
          ),
        ],
      ),
    );
  }

  Future<void> _printJob(PrintJob job) async {
    final l10n = AppLocalizations.of(context);
    final notifier = ref.read(printQueueProvider.notifier);
    notifier.markPrinting(job.id);

    try {
      // Simulate print delay for admin
      await Future<void>.delayed(const Duration(seconds: 1));
      notifier.markCompleted(job.id);
      // Remove completed job after a short delay
      Future.delayed(const Duration(seconds: 1), () {
        if (mounted) {
          notifier.removeJob(job.id);
        }
      });
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              '${l10n.printAll}: ${job.receiptNo.isNotEmpty ? job.receiptNo : job.saleId}'),
          backgroundColor: AppColors.success,
        ),
      );
    } catch (e) {
      notifier.markFailed(job.id, e.toString());
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${l10n.failedPrintLabel}: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  void _removeJob(PrintJob job) {
    ref.read(printQueueProvider.notifier).removeJob(job.id);
  }

  Future<void> _printAll() async {
    setState(() => _isPrinting = true);
    final notifier = ref.read(printQueueProvider.notifier);
    final jobs = ref.read(printQueueProvider);
    final pendingJobs =
        jobs.where((j) => j.status == 'pending' || j.status == 'failed');

    for (final job in pendingJobs) {
      notifier.markPrinting(job.id);
      try {
        // Simulate print delay for admin
        await Future<void>.delayed(const Duration(milliseconds: 500));
        notifier.markCompleted(job.id);
      } catch (e) {
        notifier.markFailed(job.id, e.toString());
      }
    }

    // Remove completed jobs
    notifier.clearCompleted();

    if (!mounted) return;
    setState(() => _isPrinting = false);

    final l10n = AppLocalizations.of(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(l10n.allJobsPrinted),
        backgroundColor: AppColors.success,
      ),
    );
  }

  void _clearAll() {
    final l10n = AppLocalizations.of(context);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.clearPrintQueueTitle),
        content: Text(l10n.clearPrintQueueConfirm),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(l10n.cancel)),
          FilledButton(
            onPressed: () {
              Navigator.pop(ctx);
              ref.read(printQueueProvider.notifier).clearAll();
            },
            style: FilledButton.styleFrom(backgroundColor: AppColors.error),
            child: Text(l10n.delete),
          ),
        ],
      ),
    );
  }
}
