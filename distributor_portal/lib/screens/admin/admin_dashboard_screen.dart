/// Admin dashboard — super_admin only.
///
/// Three tabs:
/// 1. Pending distributors for approval/rejection
/// 2. Documents pending review
/// 3. Admin notifications inbox
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../data/models/admin_notification.dart';
import '../../data/models/distributor_document.dart';
import '../../data/models/pending_distributor.dart';
import '../../providers/admin_providers.dart';

class AdminDashboardScreen extends ConsumerStatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  ConsumerState<AdminDashboardScreen> createState() =>
      _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends ConsumerState<AdminDashboardScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final unreadCount = ref.watch(unreadNotificationCountProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('لوحة الإدارة'),
        centerTitle: true,
        actions: [
          // Unread notification badge
          unreadCount.when(
            data: (count) => count > 0
                ? Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: Badge(
                      label: Text('$count'),
                      child: IconButton(
                        icon: const Icon(Icons.notifications_outlined),
                        tooltip: 'التنبيهات غير المقروءة',
                        onPressed: () {
                          _tabController.animateTo(2);
                        },
                      ),
                    ),
                  )
                : const SizedBox.shrink(),
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
          ),
          const SizedBox(width: 8),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'موزعون قيد المراجعة'),
            Tab(text: 'وثائق'),
            Tab(text: 'تنبيهات'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          _PendingDistributorsTab(),
          _PendingDocumentsTab(),
          _NotificationsTab(),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// Tab 1: Pending Distributors
// ═══════════════════════════════════════════════════════════════

class _PendingDistributorsTab extends ConsumerWidget {
  const _PendingDistributorsTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncDistributors = ref.watch(pendingDistributorsProvider);

    return asyncDistributors.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => _ErrorView(
        message: 'فشل تحميل الموزعين: $error',
        onRetry: () => ref.invalidate(pendingDistributorsProvider),
      ),
      data: (distributors) {
        if (distributors.isEmpty) {
          return const _EmptyView(
            icon: Icons.check_circle_outline,
            message: 'لا يوجد موزعون بانتظار المراجعة',
          );
        }
        return RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(pendingDistributorsProvider);
            // Wait for the provider to complete
            await ref.read(pendingDistributorsProvider.future);
          },
          child: ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: distributors.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              return _DistributorCard(distributor: distributors[index]);
            },
          ),
        );
      },
    );
  }
}

class _DistributorCard extends ConsumerWidget {
  final PendingDistributor distributor;

  const _DistributorCard({required this.distributor});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return Card(
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: name + status
            Row(
              children: [
                Expanded(
                  child: Text(
                    distributor.displayName,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.orange.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    distributor.status.arabicLabel,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: Colors.orange.shade800,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Info rows
            if (distributor.commercialReg != null)
              _InfoRow(
                icon: Icons.business,
                label: 'السجل التجاري',
                value: distributor.commercialReg!,
              ),
            if (distributor.taxNumber != null)
              _InfoRow(
                icon: Icons.receipt,
                label: 'الرقم الضريبي',
                value: distributor.taxNumber!,
              ),
            if (distributor.city != null)
              _InfoRow(
                icon: Icons.location_on_outlined,
                label: 'المدينة',
                value: distributor.city!,
              ),
            if (distributor.phone != null)
              _InfoRow(
                icon: Icons.phone_outlined,
                label: 'الهاتف',
                value: distributor.phone!,
              ),
            if (distributor.email != null)
              _InfoRow(
                icon: Icons.email_outlined,
                label: 'البريد',
                value: distributor.email!,
              ),

            const SizedBox(height: 4),
            Text(
              'سُجّل ${distributor.timeAgo}',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),

            const Divider(height: 24),

            // Action buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  onPressed: () {
                    context.go('/admin/distributor/${distributor.id}');
                  },
                  icon: const Icon(Icons.visibility_outlined, size: 18),
                  label: const Text('معاينة'),
                ),
                const SizedBox(width: 8),
                FilledButton.tonal(
                  onPressed: () => _showApproveDialog(context, ref),
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.green.withValues(alpha: 0.1),
                    foregroundColor: Colors.green.shade700,
                  ),
                  child: const Text('قبول'),
                ),
                const SizedBox(width: 8),
                FilledButton.tonal(
                  onPressed: () => _showRejectDialog(context, ref),
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.red.withValues(alpha: 0.1),
                    foregroundColor: Colors.red.shade700,
                  ),
                  child: const Text('رفض'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showApproveDialog(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('تأكيد الاعتماد'),
        content: Text(
          'هل تريد اعتماد "${distributor.displayName}"?\n\n'
          'سيتمكن الموزع من الوصول الكامل للمنصة.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('إلغاء'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: FilledButton.styleFrom(backgroundColor: Colors.green),
            child: const Text('نعم، اعتماد'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;
    if (!context.mounted) return;

    try {
      await ref.read(adminServiceProvider).approveDistributor(distributor.id);
      ref.invalidate(pendingDistributorsProvider);
      ref.invalidate(unreadNotificationCountProvider);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('تم اعتماد "${distributor.displayName}"'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('فشل الاعتماد: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _showRejectDialog(BuildContext context, WidgetRef ref) async {
    final reasonController = TextEditingController();
    String? selectedReason;
    final reasons = [
      'وثائق غير مكتملة',
      'معلومات غير صحيحة',
      'السجل التجاري منتهي',
    ];

    final result = await showDialog<String>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text('رفض الموزع'),
          content: SizedBox(
            width: 400,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('سبب رفض "${distributor.displayName}":'),
                const SizedBox(height: 16),
                // Predefined reasons
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: reasons.map((reason) {
                    final isSelected = selectedReason == reason;
                    return ChoiceChip(
                      label: Text(reason),
                      selected: isSelected,
                      onSelected: (selected) {
                        setDialogState(() {
                          selectedReason = selected ? reason : null;
                          if (selected) {
                            reasonController.text = reason;
                          } else {
                            reasonController.clear();
                          }
                        });
                      },
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: reasonController,
                  decoration: const InputDecoration(
                    labelText: 'أو اكتب السبب',
                    hintText: 'اكتب سبب الرفض (10 أحرف على الأقل)',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                  maxLength: 500,
                  onChanged: (value) {
                    setDialogState(() {
                      if (!reasons.contains(value)) {
                        selectedReason = null;
                      }
                    });
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('إلغاء'),
            ),
            FilledButton(
              onPressed: reasonController.text.trim().length >= 10
                  ? () => Navigator.of(ctx).pop(reasonController.text.trim())
                  : null,
              style: FilledButton.styleFrom(backgroundColor: Colors.red),
              child: const Text('رفض'),
            ),
          ],
        ),
      ),
    );

    reasonController.dispose();

    if (result == null || result.isEmpty) return;
    if (!context.mounted) return;

    try {
      await ref
          .read(adminServiceProvider)
          .rejectDistributor(distributor.id, result);
      ref.invalidate(pendingDistributorsProvider);
      ref.invalidate(unreadNotificationCountProvider);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('تم رفض "${distributor.displayName}"'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('فشل الرفض: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }
}

// ═══════════════════════════════════════════════════════════════
// Tab 2: Pending Documents
// ═══════════════════════════════════════════════════════════════

class _PendingDocumentsTab extends ConsumerWidget {
  const _PendingDocumentsTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncDocs = ref.watch(pendingDocumentsProvider);

    return asyncDocs.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => _ErrorView(
        message: 'فشل تحميل الوثائق: $error',
        onRetry: () => ref.invalidate(pendingDocumentsProvider),
      ),
      data: (docs) {
        if (docs.isEmpty) {
          return const _EmptyView(
            icon: Icons.description_outlined,
            message: 'لا توجد وثائق بانتظار المراجعة',
          );
        }
        return RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(pendingDocumentsProvider);
            await ref.read(pendingDocumentsProvider.future);
          },
          child: ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: docs.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              return _DocumentCard(document: docs[index]);
            },
          ),
        );
      },
    );
  }
}

class _DocumentCard extends ConsumerWidget {
  final DistributorDocument document;

  const _DocumentCard({required this.document});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return Card(
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.description_outlined,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        document.documentType.arabicName,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        document.fileName,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                Text(
                  document.fileSizeFormatted,
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'الموزع: ${document.orgId}',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  onPressed: () => _viewDocument(context, ref),
                  icon: const Icon(Icons.open_in_new, size: 18),
                  label: const Text('معاينة'),
                ),
                const SizedBox(width: 8),
                FilledButton.tonal(
                  onPressed: () => _approveDocument(context, ref),
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.green.withValues(alpha: 0.1),
                    foregroundColor: Colors.green.shade700,
                  ),
                  child: const Text('موافق'),
                ),
                const SizedBox(width: 8),
                FilledButton.tonal(
                  onPressed: () => _rejectDocument(context, ref),
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.red.withValues(alpha: 0.1),
                    foregroundColor: Colors.red.shade700,
                  ),
                  child: const Text('رفض'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _viewDocument(BuildContext context, WidgetRef ref) async {
    try {
      final url = await ref
          .read(adminServiceProvider)
          .getDocumentSignedUrl(document.fileUrl);
      if (!context.mounted) return;
      // Open URL — on web this opens a new tab
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('رابط المستند: $url')));
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('فشل تحميل المستند: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _approveDocument(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('تأكيد الموافقة'),
        content: Text(
          'هل تريد الموافقة على "${document.documentType.arabicName}"؟',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('إلغاء'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('موافق'),
          ),
        ],
      ),
    );

    if (confirmed != true || !context.mounted) return;

    try {
      await ref.read(adminServiceProvider).approveDocument(document.id);
      ref.invalidate(pendingDocumentsProvider);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تم الموافقة على المستند'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('فشل: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _rejectDocument(BuildContext context, WidgetRef ref) async {
    final reasonController = TextEditingController();
    final reasons = [
      'الصورة غير واضحة',
      'المستند منتهي الصلاحية',
      'نوع المستند غير صحيح',
    ];

    final result = await showDialog<String>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text('رفض المستند'),
          content: SizedBox(
            width: 400,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('سبب الرفض:'),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: reasons.map((reason) {
                    return ActionChip(
                      label: Text(reason),
                      onPressed: () {
                        setDialogState(() {
                          reasonController.text = reason;
                        });
                      },
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: reasonController,
                  decoration: const InputDecoration(
                    labelText: 'السبب',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 2,
                  maxLength: 500,
                  onChanged: (_) => setDialogState(() {}),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('إلغاء'),
            ),
            FilledButton(
              onPressed: reasonController.text.trim().length >= 5
                  ? () => Navigator.of(ctx).pop(reasonController.text.trim())
                  : null,
              style: FilledButton.styleFrom(backgroundColor: Colors.red),
              child: const Text('رفض'),
            ),
          ],
        ),
      ),
    );

    reasonController.dispose();

    if (result == null || result.isEmpty || !context.mounted) return;

    try {
      await ref.read(adminServiceProvider).rejectDocument(document.id, result);
      ref.invalidate(pendingDocumentsProvider);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تم رفض المستند'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('فشل: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }
}

// ═══════════════════════════════════════════════════════════════
// Tab 3: Notifications
// ═══════════════════════════════════════════════════════════════

class _NotificationsTab extends ConsumerStatefulWidget {
  const _NotificationsTab();

  @override
  ConsumerState<_NotificationsTab> createState() => _NotificationsTabState();
}

class _NotificationsTabState extends ConsumerState<_NotificationsTab> {
  bool _unreadOnly = false;

  @override
  Widget build(BuildContext context) {
    final asyncNotifications = ref.watch(
      adminNotificationsProvider(_unreadOnly),
    );

    return Column(
      children: [
        // Filter toggle
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
          child: Row(
            children: [
              const Text('عرض:'),
              const SizedBox(width: 8),
              ChoiceChip(
                label: const Text('الكل'),
                selected: !_unreadOnly,
                onSelected: (selected) {
                  if (selected) setState(() => _unreadOnly = false);
                },
              ),
              const SizedBox(width: 8),
              ChoiceChip(
                label: const Text('غير مقروءة'),
                selected: _unreadOnly,
                onSelected: (selected) {
                  if (selected) setState(() => _unreadOnly = true);
                },
              ),
            ],
          ),
        ),
        // List
        Expanded(
          child: asyncNotifications.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, _) => _ErrorView(
              message: 'فشل تحميل التنبيهات: $error',
              onRetry: () =>
                  ref.invalidate(adminNotificationsProvider(_unreadOnly)),
            ),
            data: (notifications) {
              if (notifications.isEmpty) {
                return const _EmptyView(
                  icon: Icons.notifications_none,
                  message: 'لا توجد تنبيهات',
                );
              }
              return RefreshIndicator(
                onRefresh: () async {
                  ref.invalidate(adminNotificationsProvider(_unreadOnly));
                  await ref.read(
                    adminNotificationsProvider(_unreadOnly).future,
                  );
                },
                child: ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: notifications.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    return _NotificationTile(
                      notification: notifications[index],
                    );
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _NotificationTile extends ConsumerWidget {
  final AdminNotification notification;

  const _NotificationTile({required this.notification});

  IconData _iconForType(AdminNotificationType type) {
    switch (type) {
      case AdminNotificationType.newDistributor:
        return Icons.person_add_outlined;
      case AdminNotificationType.documentUploaded:
        return Icons.upload_file_outlined;
      case AdminNotificationType.distributorApproved:
        return Icons.check_circle_outline;
      case AdminNotificationType.distributorRejected:
        return Icons.cancel_outlined;
      case AdminNotificationType.distributorSuspended:
        return Icons.block_outlined;
      case AdminNotificationType.general:
        return Icons.info_outline;
    }
  }

  Color _colorForType(AdminNotificationType type) {
    switch (type) {
      case AdminNotificationType.newDistributor:
        return Colors.blue;
      case AdminNotificationType.documentUploaded:
        return Colors.indigo;
      case AdminNotificationType.distributorApproved:
        return Colors.green;
      case AdminNotificationType.distributorRejected:
        return Colors.red;
      case AdminNotificationType.distributorSuspended:
        return Colors.orange;
      case AdminNotificationType.general:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final color = _colorForType(notification.type);

    return Card(
      elevation: notification.isRead ? 0 : 1,
      color: notification.isRead ? null : color.withValues(alpha: 0.05),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withValues(alpha: 0.1),
          child: Icon(_iconForType(notification.type), color: color, size: 20),
        ),
        title: Text(
          notification.title,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: notification.isRead
                ? FontWeight.normal
                : FontWeight.bold,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (notification.message != null)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  notification.message!,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                '${notification.type.arabicLabel} - ${notification.timeAgo}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ],
        ),
        trailing: notification.isRead
            ? null
            : IconButton(
                icon: const Icon(Icons.mark_email_read_outlined, size: 20),
                tooltip: 'تعيين كمقروء',
                onPressed: () async {
                  try {
                    await ref
                        .read(adminServiceProvider)
                        .markNotificationAsRead(notification.id);
                    ref.invalidate(adminNotificationsProvider(false));
                    ref.invalidate(adminNotificationsProvider(true));
                    ref.invalidate(unreadNotificationCountProvider);
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(
                        context,
                      ).showSnackBar(SnackBar(content: Text('فشل: $e')));
                    }
                  }
                },
              ),
        onTap: () {
          // Navigate to related distributor if applicable
          if (notification.relatedId != null &&
              notification.relatedType == 'organization') {
            context.go('/admin/distributor/${notification.relatedId}');
          }
        },
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// Shared widgets
// ═══════════════════════════════════════════════════════════════

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 8),
          Text(
            '$label: ',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodySmall,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyView extends StatelessWidget {
  final IconData icon;
  final String message;

  const _EmptyView({required this.icon, required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 64, color: Theme.of(context).colorScheme.outline),
          const SizedBox(height: 16),
          Text(
            message,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.error_outline, size: 48, color: Colors.red.shade300),
          const SizedBox(height: 16),
          Text(message, textAlign: TextAlign.center),
          const SizedBox(height: 16),
          FilledButton.tonal(
            onPressed: onRetry,
            child: const Text('إعادة المحاولة'),
          ),
        ],
      ),
    );
  }
}
