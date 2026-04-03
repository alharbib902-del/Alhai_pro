import 'package:alhai_design_system/alhai_design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('الإعدادات'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(AlhaiSpacing.md),
        children: [
          // Language
          Card(
            child: ListTile(
              leading: const Icon(Icons.language),
              title: const Text('اللغة'),
              subtitle: const Text('العربية'),
              trailing: const Icon(Icons.chevron_left),
              onTap: () {
                // TODO: Language picker
              },
            ),
          ),
          // Notifications
          Card(
            child: SwitchListTile(
              secondary: const Icon(Icons.notifications_outlined),
              title: const Text('الإشعارات'),
              subtitle: const Text('تلقي إشعارات الطلبات'),
              value: true,
              onChanged: (value) {
                // TODO: Toggle notifications
              },
            ),
          ),
          // About
          Card(
            child: ListTile(
              leading: const Icon(Icons.info_outline),
              title: const Text('عن التطبيق'),
              subtitle: const Text('بقالة الحي - الإصدار 1.0.0'),
              trailing: const Icon(Icons.chevron_left),
              onTap: () {
                showAboutDialog(
                  context: context,
                  applicationName: 'بقالة الحي',
                  applicationVersion: '1.0.0',
                  applicationLegalese: 'جميع الحقوق محفوظة 2026',
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
