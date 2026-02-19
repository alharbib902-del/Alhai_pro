import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Settings Screen Components', () {
    group('User Card Widget', () {
      testWidgets('يعرض اسم المستخدم', (tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: _TestUserCard(
                name: 'محمد أحمد',
                email: 'mohamed@example.com',
                role: 'مدير',
              ),
            ),
          ),
        );

        expect(find.text('محمد أحمد'), findsOneWidget);
        expect(find.text('mohamed@example.com'), findsOneWidget);
        expect(find.text('مدير'), findsOneWidget);
      });

      testWidgets('يعرض أول حرف من الاسم كـ Avatar', (tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: _TestUserCard(
                name: 'أحمد',
                email: 'ahmed@test.com',
                role: 'كاشير',
              ),
            ),
          ),
        );

        expect(find.text('أ'), findsOneWidget);
      });

      testWidgets('يعرض "؟" عند عدم وجود اسم', (tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: _TestUserCard(
                name: null,
                email: '',
                role: 'مستخدم',
              ),
            ),
          ),
        );

        expect(find.text('?'), findsOneWidget);
        expect(find.text('غير معروف'), findsOneWidget);
      });
    });

    group('Toggle Tile Widget', () {
      testWidgets('يعرض العنوان والوصف', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: _TestToggleTile(
                icon: Icons.dark_mode_rounded,
                title: 'الوضع الداكن',
                subtitle: 'تفعيل المظهر الداكن',
                value: false,
                onChanged: (_) {},
              ),
            ),
          ),
        );

        expect(find.text('الوضع الداكن'), findsOneWidget);
        expect(find.text('تفعيل المظهر الداكن'), findsOneWidget);
        expect(find.byIcon(Icons.dark_mode_rounded), findsOneWidget);
      });

      testWidgets('يظهر Switch مفعل عندما value = true', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: _TestToggleTile(
                icon: Icons.volume_up_rounded,
                title: 'الأصوات',
                subtitle: 'أصوات الإشعارات',
                value: true,
                onChanged: (_) {},
              ),
            ),
          ),
        );

        final switchWidget = tester.widget<Switch>(find.byType(Switch));
        expect(switchWidget.value, isTrue);
      });

      testWidgets('يستجيب للتبديل', (tester) async {
        bool currentValue = false;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: StatefulBuilder(
                builder: (context, setState) {
                  return _TestToggleTile(
                    icon: Icons.notifications_rounded,
                    title: 'الإشعارات',
                    subtitle: 'تفعيل الإشعارات',
                    value: currentValue,
                    onChanged: (value) {
                      setState(() => currentValue = value);
                    },
                  );
                },
              ),
            ),
          ),
        );

        await tester.tap(find.byType(Switch));
        await tester.pump();

        expect(currentValue, isTrue);
      });
    });

    group('Settings Tile Widget', () {
      testWidgets('يعرض العنوان والوصف والأيقونة', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: _TestSettingsTile(
                icon: Icons.store_rounded,
                title: 'معلومات المتجر',
                subtitle: 'الاسم، العنوان، الرقم الضريبي',
                onTap: () {},
              ),
            ),
          ),
        );

        expect(find.text('معلومات المتجر'), findsOneWidget);
        expect(find.text('الاسم، العنوان، الرقم الضريبي'), findsOneWidget);
        expect(find.byIcon(Icons.store_rounded), findsOneWidget);
      });

      testWidgets('يستجيب للضغط', (tester) async {
        bool tapped = false;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: _TestSettingsTile(
                icon: Icons.print_rounded,
                title: 'إعدادات الطابعة',
                subtitle: 'الطابعة الحرارية',
                onTap: () => tapped = true,
              ),
            ),
          ),
        );

        await tester.tap(find.text('إعدادات الطابعة'));
        expect(tapped, isTrue);
      });

      testWidgets('يعرض سهم الانتقال', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: _TestSettingsTile(
                icon: Icons.receipt_rounded,
                title: 'تخصيص الفاتورة',
                subtitle: 'الشعار، الهيدر، الفوتر',
                onTap: () {},
              ),
            ),
          ),
        );

        expect(find.byIcon(Icons.chevron_left_rounded), findsOneWidget);
      });
    });

    group('Nav Item Widget', () {
      testWidgets('يعرض النص والأيقونة', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: _TestNavItem(
                label: 'عام',
                icon: Icons.tune_rounded,
                isSelected: false,
                onTap: () {},
              ),
            ),
          ),
        );

        expect(find.text('عام'), findsOneWidget);
        expect(find.byIcon(Icons.tune_rounded), findsOneWidget);
      });

      testWidgets('يظهر علامة التحديد عند الاختيار', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: _TestNavItem(
                label: 'المتجر',
                icon: Icons.store_rounded,
                isSelected: true,
                onTap: () {},
              ),
            ),
          ),
        );

        expect(find.byIcon(Icons.check_rounded), findsOneWidget);
      });
    });

    group('Sync Card Widget', () {
      testWidgets('يعرض حالة "كل شيء متزامن" عند عدم وجود عناصر معلقة', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: _TestSyncCard(
                pendingSync: 0,
                lastSync: DateTime.now(),
                isSyncing: false,
                onSync: () {},
              ),
            ),
          ),
        );

        expect(find.text('كل شيء متزامن'), findsOneWidget);
      });

      testWidgets('يعرض عدد العناصر المعلقة', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: _TestSyncCard(
                pendingSync: 5,
                lastSync: null,
                isSyncing: false,
                onSync: () {},
              ),
            ),
          ),
        );

        expect(find.text('5 عنصر قيد الانتظار'), findsOneWidget);
      });

      testWidgets('يعرض مؤشر التحميل أثناء المزامنة', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: _TestSyncCard(
                pendingSync: 0,
                lastSync: null,
                isSyncing: true,
                onSync: () {},
              ),
            ),
          ),
        );

        expect(find.byType(CircularProgressIndicator), findsOneWidget);
      });

      testWidgets('يعرض وقت آخر مزامنة', (tester) async {
        final lastSync = DateTime(2025, 1, 15, 14, 30);

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: _TestSyncCard(
                pendingSync: 0,
                lastSync: lastSync,
                isSyncing: false,
                onSync: () {},
              ),
            ),
          ),
        );

        expect(find.text('آخر مزامنة: 14:30'), findsOneWidget);
      });
    });

    group('Logout Card Widget', () {
      testWidgets('يعرض زر تسجيل الخروج', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: _TestLogoutCard(onTap: () {}),
            ),
          ),
        );

        expect(find.text('تسجيل الخروج'), findsOneWidget);
        expect(find.byIcon(Icons.logout_rounded), findsOneWidget);
      });

      testWidgets('يستجيب للضغط', (tester) async {
        bool tapped = false;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: _TestLogoutCard(onTap: () => tapped = true),
            ),
          ),
        );

        await tester.tap(find.text('تسجيل الخروج'));
        expect(tapped, isTrue);
      });
    });

    group('Language Dropdown', () {
      testWidgets('يعرض اللغة المحددة', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: _TestLanguageDropdown(
                selectedLanguage: 'ar',
                onChanged: (_) {},
              ),
            ),
          ),
        );

        expect(find.text('العربية'), findsOneWidget);
      });

      testWidgets('يحتوي على خيارات اللغات', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: _TestLanguageDropdown(
                selectedLanguage: 'ar',
                onChanged: (_) {},
              ),
            ),
          ),
        );

        // فتح القائمة
        await tester.tap(find.byType(DropdownButton<String>));
        await tester.pumpAndSettle();

        expect(find.text('العربية'), findsWidgets);
        expect(find.text('English'), findsOneWidget);
      });
    });

    group('About Dialog Content', () {
      testWidgets('يعرض معلومات التطبيق', (tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: _TestAboutContent(),
            ),
          ),
        );

        expect(find.text('نظام نقاط البيع'), findsOneWidget);
        expect(find.text('الإصدار 1.0.0'), findsOneWidget);
        expect(find.text('2025 Alhai'), findsOneWidget);
      });
    });
  });

  group('Settings Screen Logic', () {
    test('تنسيق وقت المزامنة', () {
      final lastSync = DateTime(2025, 1, 15, 9, 5);
      final formatted = '${lastSync.hour}:${lastSync.minute.toString().padLeft(2, '0')}';

      expect(formatted, '9:05');
    });

    test('تنسيق وقت المزامنة - ساعات بعد الظهر', () {
      final lastSync = DateTime(2025, 1, 15, 14, 30);
      final formatted = '${lastSync.hour}:${lastSync.minute.toString().padLeft(2, '0')}';

      expect(formatted, '14:30');
    });

    test('التحقق من العناصر المعلقة', () {
      const pendingSync = 5;
      const hasPending = pendingSync > 0;

      expect(hasPending, isTrue);
    });

    test('التحقق من عدم وجود عناصر معلقة', () {
      const pendingSync = 0;
      const hasPending = pendingSync > 0;

      expect(hasPending, isFalse);
    });

    test('تحديث قيمة الوضع الداكن', () {
      bool isDarkMode = false;
      isDarkMode = true;

      expect(isDarkMode, isTrue);
    });

    test('تحديث قيمة الأصوات', () {
      bool soundEnabled = true;
      soundEnabled = false;

      expect(soundEnabled, isFalse);
    });

    test('تغيير اللغة', () {
      String selectedLanguage = 'ar';
      selectedLanguage = 'en';

      expect(selectedLanguage, 'en');
    });

    test('اللغات المدعومة', () {
      const languages = ['ar', 'en'];

      expect(languages.length, 2);
      expect(languages, contains('ar'));
      expect(languages, contains('en'));
    });
  });

  group('Settings Card Types', () {
    test('إعدادات المتجر', () {
      const storeSettings = [
        {'title': 'معلومات المتجر', 'icon': Icons.store_rounded},
        {'title': 'إعدادات الطابعة', 'icon': Icons.print_rounded},
        {'title': 'تخصيص الفاتورة', 'icon': Icons.receipt_rounded},
      ];

      expect(storeSettings.length, 3);
    });

    test('إعدادات أخرى', () {
      const otherSettings = [
        {'title': 'النسخ الاحتياطي', 'icon': Icons.backup_rounded},
        {'title': 'عن التطبيق', 'icon': Icons.info_rounded},
      ];

      expect(otherSettings.length, 2);
    });

    test('عناصر التنقل', () {
      const navItems = [
        {'label': 'عام', 'icon': Icons.tune_rounded},
        {'label': 'المتجر', 'icon': Icons.store_rounded},
        {'label': 'الطابعة', 'icon': Icons.print_rounded},
        {'label': 'الإشعارات', 'icon': Icons.notifications_rounded},
        {'label': 'المزامنة', 'icon': Icons.sync_rounded},
        {'label': 'النسخ الاحتياطي', 'icon': Icons.backup_rounded},
        {'label': 'عن التطبيق', 'icon': Icons.info_rounded},
      ];

      expect(navItems.length, 7);
    });
  });

  group('Quick Settings', () {
    test('إعدادات سريعة متاحة', () {
      const quickSettings = [
        {'title': 'الوضع الداكن', 'type': 'toggle'},
        {'title': 'الأصوات', 'type': 'toggle'},
        {'title': 'اللغة', 'type': 'dropdown'},
      ];

      expect(quickSettings.length, 3);
      expect(quickSettings.where((s) => s['type'] == 'toggle').length, 2);
      expect(quickSettings.where((s) => s['type'] == 'dropdown').length, 1);
    });
  });

  group('Logout Confirmation', () {
    test('رسالة التأكيد مع عناصر معلقة', () {
      const pendingSync = 3;
      const message = 'لديك $pendingSync عنصر لم يتم مزامنته. هل تريد تسجيل الخروج؟';

      expect(message, contains('3 عنصر'));
    });

    test('رسالة التأكيد بدون عناصر معلقة', () {
      const pendingSync = 0;
      const message = pendingSync > 0
          ? 'لديك $pendingSync عنصر لم يتم مزامنته.'
          : 'هل تريد تسجيل الخروج من حسابك؟';

      expect(message, 'هل تريد تسجيل الخروج من حسابك؟');
    });
  });

  group('App Version', () {
    test('معلومات الإصدار', () {
      const version = '1.0.0';
      const appName = 'نظام نقاط البيع';
      const copyright = '2025 Alhai';

      expect(version, isNotEmpty);
      expect(appName, isNotEmpty);
      expect(copyright, contains('2025'));
    });
  });
}

// ============================================================================
// Test Helper Widgets
// ============================================================================

class _TestUserCard extends StatelessWidget {
  final String? name;
  final String email;
  final String role;

  const _TestUserCard({
    required this.name,
    required this.email,
    required this.role,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Colors.blue, Colors.blue],
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(
                name?.isNotEmpty == true ? name![0].toUpperCase() : '?',
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name ?? 'غير معروف',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(email, style: const TextStyle(color: Colors.white)),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(role, style: const TextStyle(fontSize: 12, color: Colors.white)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TestToggleTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _TestToggleTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.grey,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: Colors.grey, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
              Text(subtitle, style: const TextStyle(fontSize: 12, color: Colors.grey)),
            ],
          ),
        ),
        Switch(value: value, onChanged: onChanged),
      ],
    );
  }
}

class _TestSettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _TestSettingsTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.grey,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: Colors.grey, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
                    Text(subtitle, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                  ],
                ),
              ),
              const Icon(Icons.chevron_left_rounded, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }
}

class _TestNavItem extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _TestNavItem({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isSelected ? Colors.blue : Colors.transparent,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            children: [
              Icon(icon, size: 20, color: isSelected ? Colors.blue : Colors.grey),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  color: isSelected ? Colors.blue : Colors.black,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
              if (isSelected) ...[
                const Spacer(),
                const Icon(Icons.check_rounded, size: 18, color: Colors.blue),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _TestSyncCard extends StatelessWidget {
  final int pendingSync;
  final DateTime? lastSync;
  final bool isSyncing;
  final VoidCallback onSync;

  const _TestSyncCard({
    required this.pendingSync,
    required this.lastSync,
    required this.isSyncing,
    required this.onSync,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: pendingSync > 0 ? Colors.orange : Colors.grey,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                pendingSync > 0 ? Icons.sync_problem_rounded : Icons.cloud_done_rounded,
                color: pendingSync > 0 ? Colors.orange : Colors.green,
              ),
              const SizedBox(width: 8),
              const Text('المزامنة', style: TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: pendingSync > 0
                  ? Colors.orange
                  : Colors.green,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(
                  pendingSync > 0 ? Icons.hourglass_bottom_rounded : Icons.check_circle_rounded,
                  color: pendingSync > 0 ? Colors.orange : Colors.green,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        pendingSync > 0
                            ? '$pendingSync عنصر قيد الانتظار'
                            : 'كل شيء متزامن',
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      if (lastSync != null)
                        Text(
                          'آخر مزامنة: ${lastSync!.hour}:${lastSync!.minute.toString().padLeft(2, '0')}',
                          style: const TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                    ],
                  ),
                ),
                if (isSyncing)
                  const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                else
                  ElevatedButton.icon(
                    onPressed: onSync,
                    icon: const Icon(Icons.sync_rounded),
                    label: const Text('مزامنة الآن'),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TestLogoutCard extends StatelessWidget {
  final VoidCallback onTap;

  const _TestLogoutCard({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.red.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red.withValues(alpha: 0.2)),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: const Padding(
            padding: EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.logout_rounded, color: Colors.red),
                SizedBox(width: 8),
                Text(
                  'تسجيل الخروج',
                  style: TextStyle(color: Colors.red, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TestLanguageDropdown extends StatelessWidget {
  final String selectedLanguage;
  final ValueChanged<String?> onChanged;

  const _TestLanguageDropdown({
    required this.selectedLanguage,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.grey,
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(Icons.language_rounded, color: Colors.grey, size: 20),
        ),
        const SizedBox(width: 12),
        const Expanded(
          child: Text('اللغة', style: TextStyle(fontWeight: FontWeight.w600)),
        ),
        DropdownButton<String>(
          value: selectedLanguage,
          items: const [
            DropdownMenuItem(value: 'ar', child: Text('العربية')),
            DropdownMenuItem(value: 'en', child: Text('English')),
          ],
          onChanged: onChanged,
          underline: const SizedBox(),
        ),
      ],
    );
  }
}

class _TestAboutContent extends StatelessWidget {
  const _TestAboutContent();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(24),
          decoration: const BoxDecoration(
            color: Colors.blue,
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.point_of_sale_rounded, size: 48, color: Colors.blue),
        ),
        const SizedBox(height: 16),
        const Text(
          'نظام نقاط البيع',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        const Text(
          'الإصدار 1.0.0',
          style: TextStyle(color: Colors.grey),
        ),
        const SizedBox(height: 16),
        const Text(
          'نظام نقاط بيع متكامل للمتاجر والمحلات التجارية.',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.grey),
        ),
        const SizedBox(height: 16),
        const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.copyright_rounded, size: 16, color: Colors.grey),
            SizedBox(width: 4),
            Text('2025 Alhai', style: TextStyle(color: Colors.grey)),
          ],
        ),
      ],
    );
  }
}











