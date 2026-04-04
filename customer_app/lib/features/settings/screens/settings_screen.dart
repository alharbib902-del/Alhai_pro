import 'package:alhai_design_system/alhai_design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _notificationsEnabledKey = 'notifications_enabled';

final _notificationsEnabledProvider = StateProvider<bool>((ref) => true);

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  @override
  void initState() {
    super.initState();
    _loadNotificationPref();
  }

  Future<void> _loadNotificationPref() async {
    final prefs = await SharedPreferences.getInstance();
    final enabled = prefs.getBool(_notificationsEnabledKey) ?? true;
    if (mounted) {
      ref.read(_notificationsEnabledProvider.notifier).state = enabled;
    }
  }

  Future<void> _toggleNotifications(bool value) async {
    ref.read(_notificationsEnabledProvider.notifier).state = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_notificationsEnabledKey, value);
  }

  void _showLanguagePicker() {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.check),
              title: const Text('العربية'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              title: const Text('English'),
              enabled: false,
              subtitle: const Text('قريباً'),
              onTap: null,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final notificationsEnabled = ref.watch(_notificationsEnabledProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('الإعدادات'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        top: false,
        child: ListView(
        padding: const EdgeInsets.all(AlhaiSpacing.md),
        children: [
          // Language
          Card(
            child: ListTile(
              leading: const Icon(Icons.language),
              title: const Text('اللغة', maxLines: 1, overflow: TextOverflow.ellipsis),
              subtitle: const Text('العربية'),
              trailing: const Icon(Icons.chevron_left),
              onTap: _showLanguagePicker,
            ),
          ),
          // Notifications
          Card(
            child: SwitchListTile(
              secondary: const Icon(Icons.notifications_outlined),
              title: const Text('الإشعارات', maxLines: 1, overflow: TextOverflow.ellipsis),
              subtitle: const Text('تلقي إشعارات الطلبات'),
              value: notificationsEnabled,
              onChanged: _toggleNotifications,
            ),
          ),
          // About
          Card(
            child: ListTile(
              leading: const Icon(Icons.info_outline),
              title: const Text('عن التطبيق', maxLines: 1, overflow: TextOverflow.ellipsis),
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
      ),
    );
  }
}
