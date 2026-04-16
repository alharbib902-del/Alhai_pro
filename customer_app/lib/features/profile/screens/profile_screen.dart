import 'package:alhai_design_system/alhai_design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/providers/app_providers.dart';
import '../../../core/services/sentry_service.dart';
import '../../auth/providers/auth_providers.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final user = ref.watch(currentUserProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('حسابي')),
      body: SafeArea(
        top: false,
        child: ListView(
          padding: const EdgeInsets.all(AlhaiSpacing.md),
          children: [
            // User info card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(AlhaiSpacing.md),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 32,
                      backgroundColor: theme.colorScheme.primaryContainer,
                      child: Text(
                        user?.initials ?? '?',
                        style: theme.textTheme.headlineSmall?.copyWith(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: AlhaiSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user?.name ?? 'مستخدم',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: AlhaiSpacing.xxs),
                          Text(
                            user?.phone ?? '',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.outline,
                            ),
                            textDirection: TextDirection.ltr,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AlhaiSpacing.md),

            // Menu items
            _MenuItem(
              icon: Icons.location_on_outlined,
              title: 'عناويني',
              onTap: () => context.push('/profile/addresses'),
            ),
            _MenuItem(
              icon: Icons.receipt_long_outlined,
              title: 'طلباتي',
              onTap: () => context.push('/orders'),
            ),
            _MenuItem(
              icon: Icons.settings_outlined,
              title: 'الإعدادات',
              onTap: () => context.push('/profile/settings'),
            ),
            _MenuItem(
              icon: Icons.help_outline,
              title: 'المساعدة',
              onTap: () {},
            ),
            const SizedBox(height: AlhaiSpacing.lg),
            OutlinedButton.icon(
              onPressed: () async {
                final confirmed = await showDialog<bool>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('تسجيل الخروج'),
                    content: const Text('هل تريد تسجيل الخروج؟'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(ctx, false),
                        child: const Text('إلغاء'),
                      ),
                      FilledButton(
                        onPressed: () => Navigator.pop(ctx, true),
                        child: const Text('تسجيل الخروج'),
                      ),
                    ],
                  ),
                );

                if (confirmed == true) {
                  await ref.read(logoutProvider.future);
                  if (context.mounted) context.go('/auth/login');
                }
              },
              icon: Icon(Icons.logout, color: theme.colorScheme.error),
              label: Text(
                'تسجيل الخروج',
                style: TextStyle(color: theme.colorScheme.error),
              ),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(48),
                side: BorderSide(color: theme.colorScheme.error),
              ),
            ),
            const SizedBox(height: AlhaiSpacing.md),
            TextButton(
              onPressed: () => _showDeleteAccountDialog(context, ref),
              child: Text(
                'حذف الحساب',
                style: TextStyle(
                  color: theme.colorScheme.error,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Future<void> _showDeleteAccountDialog(BuildContext context, WidgetRef ref) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('حذف الحساب'),
      content: const Text(
        'هل أنت متأكد من حذف حسابك؟\n'
        'سيتم حذف جميع بياناتك الشخصية نهائياً.\n'
        'هذا الإجراء لا يمكن التراجع عنه.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx, false),
          child: const Text('إلغاء'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(ctx, true),
          style: FilledButton.styleFrom(
            backgroundColor: Theme.of(ctx).colorScheme.error,
          ),
          child: const Text('حذف نهائياً'),
        ),
      ],
    ),
  );

  if (confirmed != true) return;
  if (!context.mounted) return;

  try {
    final client = Supabase.instance.client;

    // Try RPC-based deletion (server handles cascade)
    try {
      await client.rpc('delete_user_account');
    } on PostgrestException catch (e) {
      if (e.code == '42883' || e.message.contains('function')) {
        // RPC not deployed — inform user
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('يرجى التواصل مع الدعم لحذف حسابك'),
            ),
          );
        }
        return;
      }
      rethrow;
    }

    // Clear local data
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    const storage = FlutterSecureStorage();
    await storage.deleteAll();

    // Sign out
    await client.auth.signOut();
    ref.read(currentUserProvider.notifier).state = null;

    if (context.mounted) context.go('/auth/login');
  } catch (e, stack) {
    reportError(e, stackTrace: stack, hint: 'deleteAccount');
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('فشل حذف الحساب. حاول مرة أخرى')),
      );
    }
  }
}

class _MenuItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const _MenuItem({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: AlhaiSpacing.xxs),
      child: ListTile(
        leading: Icon(icon),
        title: Text(title),
        trailing: const Icon(Icons.chevron_left),
        onTap: onTap,
      ),
    );
  }
}
