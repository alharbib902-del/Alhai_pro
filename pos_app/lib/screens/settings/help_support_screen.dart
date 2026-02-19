import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/router/routes.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../widgets/layout/app_sidebar.dart';
import '../../widgets/layout/app_header.dart';

/// شاشة المساعدة والدعم
class HelpSupportScreen extends ConsumerStatefulWidget {
  const HelpSupportScreen({super.key});

  @override
  ConsumerState<HelpSupportScreen> createState() => _HelpSupportScreenState();
}

class _HelpSupportScreenState extends ConsumerState<HelpSupportScreen> {
  bool _sidebarCollapsed = false;
  String _selectedNavId = 'settings';

  final List<_FaqItem> _faqs = [
    _FaqItem(
      q: '\u0643\u064a\u0641 \u0623\u0636\u064a\u0641 \u0645\u0646\u062a\u062c \u062c\u062f\u064a\u062f\u061f',
      a: '\u0627\u0630\u0647\u0628 \u0625\u0644\u0649 \u0635\u0641\u062d\u0629 \u0627\u0644\u0645\u0646\u062a\u062c\u0627\u062a \u0648\u0627\u0636\u063a\u0637 \u0639\u0644\u0649 \u0632\u0631 "\u0625\u0636\u0627\u0641\u0629 \u0645\u0646\u062a\u062c" \u062b\u0645 \u0627\u0645\u0644\u0623 \u0627\u0644\u0628\u064a\u0627\u0646\u0627\u062a \u0627\u0644\u0645\u0637\u0644\u0648\u0628\u0629.',
    ),
    _FaqItem(
      q: '\u0643\u064a\u0641 \u0623\u0639\u0645\u0644 \u0641\u0627\u062a\u0648\u0631\u0629 \u0628\u064a\u0639\u061f',
      a: '\u0627\u0641\u062a\u062d \u0634\u0627\u0634\u0629 \u0646\u0642\u0637\u0629 \u0627\u0644\u0628\u064a\u0639 \u0648\u0623\u0636\u0641 \u0627\u0644\u0645\u0646\u062a\u062c\u0627\u062a \u0645\u0646 \u0627\u0644\u0642\u0627\u0626\u0645\u0629 \u0623\u0648 \u0628\u0645\u0633\u062d \u0627\u0644\u0628\u0627\u0631\u0643\u0648\u062f \u062b\u0645 \u0627\u062e\u062a\u0631 \u0637\u0631\u064a\u0642\u0629 \u0627\u0644\u062f\u0641\u0639.',
    ),
    _FaqItem(
      q: '\u0643\u064a\u0641 \u0623\u0639\u062f\u0644 \u0633\u0639\u0631 \u0645\u0646\u062a\u062c\u061f',
      a: '\u0627\u0630\u0647\u0628 \u0625\u0644\u0649 \u0635\u0641\u062d\u0629 \u0627\u0644\u0645\u0646\u062a\u062c\u0627\u062a \u0648\u0627\u0636\u063a\u0637 \u0639\u0644\u0649 \u0627\u0644\u0645\u0646\u062a\u062c \u0644\u062a\u0639\u062f\u064a\u0644\u0647.',
    ),
    _FaqItem(
      q: '\u0643\u064a\u0641 \u0623\u0633\u062a\u062e\u062f\u0645 \u0627\u0644\u0628\u0627\u0631\u0643\u0648\u062f\u061f',
      a: '\u064a\u0645\u0643\u0646\u0643 \u0627\u0633\u062a\u062e\u062f\u0627\u0645 \u0642\u0627\u0631\u0626 \u0628\u0627\u0631\u0643\u0648\u062f USB \u0645\u0628\u0627\u0634\u0631\u0629 \u0641\u064a \u0634\u0627\u0634\u0629 \u0646\u0642\u0637\u0629 \u0627\u0644\u0628\u064a\u0639.',
    ),
    _FaqItem(
      q: '\u0643\u064a\u0641 \u0623\u0639\u0645\u0644 \u0646\u0633\u062e\u0629 \u0627\u062d\u062a\u064a\u0627\u0637\u064a\u0629\u061f',
      a: '\u0627\u0630\u0647\u0628 \u0625\u0644\u0649 \u0627\u0644\u0625\u0639\u062f\u0627\u062f\u0627\u062a > \u0627\u0644\u0646\u0633\u062e \u0627\u0644\u0627\u062d\u062a\u064a\u0627\u0637\u064a \u0648\u0627\u0636\u063a\u0637 "\u0625\u0646\u0634\u0627\u0621 \u0646\u0633\u062e\u0629".',
    ),
  ];

  void _handleNavigation(AppSidebarItem item) {
    setState(() => _selectedNavId = item.id);
    switch (item.id) {
      case 'dashboard': context.go(AppRoutes.dashboard); break;
      case 'pos': context.go(AppRoutes.pos); break;
      case 'products': context.push(AppRoutes.products); break;
      case 'categories': context.push(AppRoutes.categories); break;
      case 'inventory': context.push(AppRoutes.inventory); break;
      case 'customers': context.push(AppRoutes.customers); break;
      case 'invoices': context.push(AppRoutes.invoices); break;
      case 'orders': context.push(AppRoutes.orders); break;
      case 'sales': context.push(AppRoutes.invoices); break;
      case 'returns': context.push(AppRoutes.returns); break;
      case 'reports': context.push(AppRoutes.reports); break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isWideScreen = size.width > 900;
    final isMediumScreen = size.width > 600;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F172A) : AppColors.backgroundSecondary,
      drawer: isWideScreen ? null : _buildDrawer(l10n),
      body: Row(children: [
        if (isWideScreen)
          AppSidebar(
            storeName: l10n.brandName, groups: DefaultSidebarItems.getGroups(context),
            selectedId: _selectedNavId, onItemTap: _handleNavigation,
            onSettingsTap: () => context.push(AppRoutes.settings),
            onSupportTap: () {}, onLogoutTap: () => context.go('/login'),
            collapsed: _sidebarCollapsed, userName: '\u0623\u062d\u0645\u062f \u0645\u062d\u0645\u062f',
            userRole: l10n.branchManager, onUserTap: () {},
          ),
        Expanded(child: Column(children: [
          AppHeader(
            title: l10n.helpSupport,
            onMenuTap: isWideScreen
                ? () => setState(() => _sidebarCollapsed = !_sidebarCollapsed)
                : () => Scaffold.of(context).openDrawer(),
            onNotificationsTap: () => context.push('/notifications'),
            notificationsCount: 3, userName: '\u0623\u062d\u0645\u062f \u0645\u062d\u0645\u062f', userRole: l10n.branchManager,
          ),
          Expanded(child: SingleChildScrollView(
            padding: EdgeInsets.all(isMediumScreen ? 24 : 16),
            child: _buildContent(isDark, l10n),
          )),
        ])),
      ]),
    );
  }

  Widget _buildDrawer(AppLocalizations l10n) {
    return Drawer(child: AppSidebar(
      storeName: l10n.brandName, groups: DefaultSidebarItems.getGroups(context),
      selectedId: _selectedNavId,
      onItemTap: (item) { Navigator.pop(context); _handleNavigation(item); },
      onSettingsTap: () { Navigator.pop(context); context.push(AppRoutes.settings); },
      onSupportTap: () => Navigator.pop(context),
      onLogoutTap: () { Navigator.pop(context); context.go('/login'); },
      userName: '\u0623\u062d\u0645\u062f \u0645\u062d\u0645\u062f', userRole: l10n.branchManager, onUserTap: () {},
    ));
  }

  Widget _buildContent(bool isDark, AppLocalizations l10n) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      // Contact support
      _buildGroup(l10n.contactSupport, [
        _tile(Icons.headset_mic_rounded, l10n.liveChat, '\u0645\u062a\u0627\u062d 24/7', isDark, onTap: () {}),
        _tile(Icons.email_rounded, l10n.emailSupport, 'support@alhai.sa', isDark, onTap: () {}),
        _tile(Icons.phone_rounded, l10n.phoneSupport, '+966 12 345 6789', isDark, onTap: () {}),
        _tile(Icons.chat_rounded, l10n.whatsappSupport, '+966 55 123 4567', isDark, onTap: () {}),
      ], isDark),

      // FAQ
      _buildGroup(l10n.faq, _faqs.map((faq) {
        return ExpansionTile(
          leading: Container(padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: AppColors.info.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
            child: const Icon(Icons.help_outline_rounded, color: AppColors.info, size: 20)),
          title: Text(faq.q, style: TextStyle(
              color: isDark ? Colors.white : AppColors.textPrimary, fontWeight: FontWeight.w500, fontSize: 14)),
          children: [
            Padding(padding: const EdgeInsets.fromLTRB(72, 0, 16, 16),
              child: Text(faq.a, style: TextStyle(
                  color: isDark ? Colors.white.withValues(alpha: 0.7) : AppColors.textSecondary, fontSize: 13))),
          ],
        );
      }).toList(), isDark),

      // Documentation
      _buildGroup(l10n.documentation, [
        _tile(Icons.menu_book_rounded, l10n.userGuide, '\u062f\u0644\u064a\u0644 \u0627\u0633\u062a\u062e\u062f\u0627\u0645 \u0627\u0644\u0646\u0638\u0627\u0645', isDark, onTap: () {}),
        _tile(Icons.play_circle_rounded, l10n.videoTutorials, '\u0641\u064a\u062f\u064a\u0648\u0647\u0627\u062a \u062a\u0639\u0644\u064a\u0645\u064a\u0629', isDark, onTap: () {}),
        _tile(Icons.update_rounded, l10n.changelog, '\u0633\u062c\u0644 \u0627\u0644\u062a\u062d\u062f\u064a\u062b\u0627\u062a', isDark, onTap: () {}),
      ], isDark),

      // App info
      _buildGroup(l10n.appInfo, [
        _tile(Icons.info_rounded, l10n.version, '2.0.0', isDark),
        _tile(Icons.code_rounded, l10n.buildNumber, '2024.12.15', isDark),
      ], isDark),
    ]);
  }

  Widget _buildGroup(String title, List<Widget> children, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? Colors.white.withValues(alpha: 0.1) : AppColors.border),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Padding(padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
          child: Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : AppColors.textPrimary))),
        ...children,
      ]),
    );
  }

  Widget _tile(IconData icon, String title, String? subtitle, bool isDark, {VoidCallback? onTap}) {
    return ListTile(
      leading: Container(padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
        child: Icon(icon, color: AppColors.primary, size: 20)),
      title: Text(title, style: TextStyle(color: isDark ? Colors.white : AppColors.textPrimary, fontWeight: FontWeight.w500)),
      subtitle: subtitle != null ? Text(subtitle, style: TextStyle(
          color: isDark ? Colors.white.withValues(alpha: 0.5) : AppColors.textSecondary, fontSize: 12)) : null,
      trailing: onTap != null ? Icon(Icons.chevron_left_rounded,
          color: isDark ? Colors.white.withValues(alpha: 0.3) : AppColors.textTertiary) : null,
      onTap: onTap,
    );
  }
}

class _FaqItem {
  final String q;
  final String a;
  _FaqItem({required this.q, required this.a});
}
