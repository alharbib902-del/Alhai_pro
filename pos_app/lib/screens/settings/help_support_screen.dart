import 'package:pos_app/widgets/common/adaptive_icon.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../widgets/layout/app_header.dart';

/// شاشة المساعدة والدعم
class HelpSupportScreen extends ConsumerStatefulWidget {
  const HelpSupportScreen({super.key});

  @override
  ConsumerState<HelpSupportScreen> createState() => _HelpSupportScreenState();
}

class _HelpSupportScreenState extends ConsumerState<HelpSupportScreen> {
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isWideScreen = size.width >= 1200;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;
    final padding = size.width < 600 ? 12.0 : isWideScreen ? 24.0 : 16.0;

    return Column(
      children: [
        AppHeader(
          title: l10n.helpSupport,
          onMenuTap: isWideScreen ? null : () => Scaffold.of(context).openDrawer(),
          onNotificationsTap: () => context.push('/notifications'),
          notificationsCount: 3,
          userName: l10n.defaultUserName,
          userRole: l10n.branchManager,
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(padding),
            child: Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: isWideScreen ? 800 : double.infinity),
                child: _buildContent(isDark, l10n),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildContent(bool isDark, AppLocalizations l10n) {
    final faqs = [
      _FaqItem(q: l10n.faqQuestion1, a: l10n.faqAnswer1),
      _FaqItem(q: l10n.faqQuestion2, a: l10n.faqAnswer2),
      _FaqItem(q: l10n.faqQuestion3, a: l10n.faqAnswer3),
      _FaqItem(q: l10n.faqQuestion4, a: l10n.faqAnswer4),
      _FaqItem(q: l10n.faqQuestion5, a: l10n.faqAnswer5),
    ];

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      // Contact support
      _buildGroup(l10n.contactSupport, [
        _tile(Icons.headset_mic_rounded, l10n.liveChat, l10n.contactSupportDesc, isDark, onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('\u062C\u0627\u0631\u064A \u0641\u062A\u062D \u0627\u0644\u0645\u062D\u0627\u062F\u062B\u0629 \u0627\u0644\u0645\u0628\u0627\u0634\u0631\u0629...'),
              behavior: SnackBarBehavior.floating,
              duration: Duration(seconds: 2),
            ),
          );
        }),
        _tile(Icons.email_rounded, l10n.emailSupport, 'support@alhai.sa', isDark, onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('\u062C\u0627\u0631\u064A \u0641\u062A\u062D \u0627\u0644\u0628\u0631\u064A\u062F \u0627\u0644\u0625\u0644\u0643\u062A\u0631\u0648\u0646\u064A...'),
              behavior: SnackBarBehavior.floating,
              duration: Duration(seconds: 2),
            ),
          );
        }),
        _tile(Icons.phone_rounded, l10n.phoneSupport, '+966 12 345 6789', isDark, onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('\u062C\u0627\u0631\u064A \u0627\u0644\u0627\u062A\u0635\u0627\u0644...'),
              behavior: SnackBarBehavior.floating,
              duration: Duration(seconds: 2),
            ),
          );
        }),
        _tile(Icons.chat_rounded, l10n.whatsappSupport, '+966 55 123 4567', isDark, onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('\u062C\u0627\u0631\u064A \u0641\u062A\u062D \u0648\u0627\u062A\u0633\u0627\u0628...'),
              behavior: SnackBarBehavior.floating,
              duration: Duration(seconds: 2),
            ),
          );
        }),
      ], isDark),

      // FAQ
      _buildGroup(l10n.faq, faqs.map((faq) {
        return ExpansionTile(
          leading: Container(padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: AppColors.info.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
            child: const Icon(Icons.help_outline_rounded, color: AppColors.info, size: 20)),
          title: Text(faq.q, style: TextStyle(
              color: isDark ? Colors.white : AppColors.textPrimary, fontWeight: FontWeight.w500, fontSize: 14)),
          children: [
            Padding(padding: const EdgeInsetsDirectional.fromSTEB(72, 0, 16, 16),
              child: Text(faq.a, style: TextStyle(
                  color: isDark ? Colors.white.withValues(alpha: 0.7) : AppColors.textSecondary, fontSize: 13))),
          ],
        );
      }).toList(), isDark),

      // Documentation
      _buildGroup(l10n.documentation, [
        _tile(Icons.menu_book_rounded, l10n.userGuide, l10n.systemGuide, isDark, onTap: () {}),
        _tile(Icons.play_circle_rounded, l10n.videoTutorials, l10n.videoTutorials, isDark, onTap: () {}),
        _tile(Icons.update_rounded, l10n.changelog, l10n.changeLog, isDark, onTap: () {}),
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
      trailing: onTap != null ? AdaptiveIcon(Icons.chevron_left_rounded,
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
