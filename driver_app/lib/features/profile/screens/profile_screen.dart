import 'package:alhai_design_system/alhai_design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../../core/providers/app_providers.dart';
import '../../auth/providers/auth_providers.dart';
import '../../deliveries/providers/driving_mode_provider.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  String _versionText = 'Alhai Driver';

  @override
  void initState() {
    super.initState();
    PackageInfo.fromPlatform()
        .then((info) {
          if (mounted) {
            setState(() {
              _versionText =
                  'Alhai Driver v${info.version}+${info.buildNumber}';
            });
          }
        })
        .catchError((_) {});
  }

  @override
  Widget build(BuildContext context) {
    final driver = ref.watch(currentDriverProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('حسابي'), centerTitle: true),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 800),
            child: RefreshIndicator(
              onRefresh: () async {
                ref.invalidate(currentDriverProvider);
              },
              child: ListView(
                padding: const EdgeInsets.all(AlhaiSpacing.md),
                children: [
                  // Profile header
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(AlhaiSpacing.lg),
                      child: Column(
                        children: [
                          CircleAvatar(
                            radius: 40,
                            backgroundColor: theme.colorScheme.primaryContainer,
                            child: Text(
                              driver?.name.isNotEmpty == true
                                  ? driver!.name[0].toUpperCase()
                                  : '?',
                              style: theme.textTheme.headlineLarge?.copyWith(
                                color: theme.colorScheme.primary,
                              ),
                            ),
                          ),
                          const SizedBox(height: AlhaiSpacing.sm),
                          Text(
                            driver?.name ?? 'سائق',
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            driver?.phone ?? '',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.outline,
                            ),
                            textDirection: TextDirection.ltr,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: AlhaiSpacing.md),

                  // Driving mode toggle
                  Card(
                    child: SwitchListTile(
                      secondary: const Icon(Icons.directions_car),
                      title: const Text('وضع القيادة'),
                      subtitle: const Text('نصوص وأزرار أكبر + تنبيهات صوتية'),
                      value: ref.watch(drivingModeProvider),
                      onChanged: (_) =>
                          ref.read(drivingModeProvider.notifier).toggle(),
                    ),
                  ),
                  const SizedBox(height: AlhaiSpacing.md),

                  // Settings
                  Card(
                    child: Column(
                      children: [
                        ListTile(
                          leading: const Icon(Icons.person_outline),
                          title: const Text('تعديل الملف الشخصي'),
                          trailing: const Icon(
                            Icons.arrow_forward_ios,
                            size: 16,
                          ),
                          onTap: () => context.push('/profile-setup'),
                        ),
                        const Divider(height: 1),
                        ListTile(
                          leading: const Icon(Icons.history),
                          title: const Text('سجل الورديات'),
                          trailing: const Icon(
                            Icons.arrow_forward_ios,
                            size: 16,
                          ),
                          onTap: () {},
                        ),
                        const Divider(height: 1),
                        ListTile(
                          leading: const Icon(Icons.help_outline),
                          title: const Text('المساعدة'),
                          trailing: const Icon(
                            Icons.arrow_forward_ios,
                            size: 16,
                          ),
                          onTap: () {},
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AlhaiSpacing.md),

                  // Logout
                  Semantics(
                    label: 'زر تسجيل الخروج',
                    button: true,
                    child: Card(
                      child: ListTile(
                        leading: Icon(
                          Icons.logout,
                          color: theme.colorScheme.error,
                        ),
                        title: Text(
                          'تسجيل الخروج',
                          style: TextStyle(color: theme.colorScheme.error),
                        ),
                        onTap: () async {
                          final confirm = await showDialog<bool>(
                            context: context,
                            builder: (ctx) => AlertDialog(
                              title: const Text('تسجيل الخروج'),
                              content: const Text(
                                'هل تريد تسجيل الخروج من التطبيق؟',
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(ctx, false),
                                  child: const Text('إلغاء'),
                                ),
                                FilledButton(
                                  onPressed: () => Navigator.pop(ctx, true),
                                  style: FilledButton.styleFrom(
                                    backgroundColor: Theme.of(
                                      ctx,
                                    ).colorScheme.error,
                                  ),
                                  child: const Text('خروج'),
                                ),
                              ],
                            ),
                          );
                          if (confirm == true) {
                            await ref.read(logoutProvider.future);
                            if (context.mounted) context.go('/login');
                          }
                        },
                      ),
                    ),
                  ),

                  const SizedBox(height: AlhaiSpacing.lg),
                  Center(
                    child: Text(
                      _versionText,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.outline,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
