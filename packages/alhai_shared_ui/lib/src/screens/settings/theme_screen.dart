/// شاشة إعدادات الثيم - Theme Settings Screen
///
/// تتيح للمستخدم:
/// - اختيار وضع الثيم (فاتح/مظلم/نظام)
/// - معاينة فورية للتغيير
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:alhai_design_system/alhai_design_system.dart';
import 'package:alhai_l10n/alhai_l10n.dart';
import '../../providers/theme_provider.dart';
import '../../widgets/layout/app_header.dart';

/// شاشة إعدادات الثيم
class ThemeScreen extends ConsumerStatefulWidget {
  const ThemeScreen({super.key});

  @override
  ConsumerState<ThemeScreen> createState() => _ThemeScreenState();
}

class _ThemeScreenState extends ConsumerState<ThemeScreen> {
  @override
  Widget build(BuildContext context) {
    final isWideScreen = context.isDesktop;
    final isMediumScreen = !context.isMobile;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context);

    return Column(
      children: [
        AppHeader(
          title: l10n.theme,
          onMenuTap: isWideScreen
              ? null
              : () => Scaffold.of(context).openDrawer(),
          onNotificationsTap: () => context.push('/notifications'),
          notificationsCount: 3,
          userName: '\u0623\u062d\u0645\u062f \u0645\u062d\u0645\u062f',
          userRole: l10n.branchManager,
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(
              isMediumScreen ? AlhaiSpacing.lg : AlhaiSpacing.md,
            ),
            child: _buildContent(isWideScreen, isMediumScreen, isDark, l10n),
          ),
        ),
      ],
    );
  }

  Widget _buildContent(
    bool isWideScreen,
    bool isMediumScreen,
    bool isDark,
    AppLocalizations l10n,
  ) {
    final themeState = ref.watch(themeProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Theme preview
        _ThemePreview(isDark: isDark),

        SizedBox(height: AlhaiSpacing.lg),

        // Theme options
        _buildSettingsGroup(l10n.theme, [
          _buildThemeOptionTile(
            icon: Icons.light_mode_rounded,
            title: l10n.lightMode,
            subtitle:
                '\u0645\u0638\u0647\u0631 \u0641\u0627\u062a\u062d \u0645\u0631\u064a\u062d \u0644\u0644\u0639\u064a\u0646',
            isSelected: themeState.themeMode == ThemeMode.light,
            isDark: isDark,
            onTap: () {
              ref.read(themeProvider.notifier).enableLightMode();
              if (themeState.themeMode != ThemeMode.light) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      '\u062A\u0645 \u062A\u0641\u0639\u064A\u0644 ${l10n.lightMode}',
                    ),
                    backgroundColor: AppColors.success,
                    behavior: SnackBarBehavior.floating,
                    duration: const Duration(seconds: 2),
                  ),
                );
              }
            },
          ),
          _buildThemeOptionTile(
            icon: Icons.dark_mode_rounded,
            title: l10n.darkMode,
            subtitle:
                '\u0645\u0638\u0647\u0631 \u0645\u0638\u0644\u0645 \u064a\u062d\u0645\u064a \u0627\u0644\u0639\u064a\u0646',
            isSelected: themeState.themeMode == ThemeMode.dark,
            isDark: isDark,
            onTap: () {
              ref.read(themeProvider.notifier).enableDarkMode();
              if (themeState.themeMode != ThemeMode.dark) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      '\u062A\u0645 \u062A\u0641\u0639\u064A\u0644 ${l10n.darkMode}',
                    ),
                    backgroundColor: AppColors.success,
                    behavior: SnackBarBehavior.floating,
                    duration: const Duration(seconds: 2),
                  ),
                );
              }
            },
          ),
          _buildThemeOptionTile(
            icon: Icons.settings_suggest_rounded,
            title: l10n.systemMode,
            subtitle:
                '\u064a\u062a\u0628\u0639 \u0625\u0639\u062f\u0627\u062f\u0627\u062a \u062c\u0647\u0627\u0632\u0643 \u062a\u0644\u0642\u0627\u0626\u064a\u0627\u064b',
            isSelected: themeState.themeMode == ThemeMode.system,
            isDark: isDark,
            onTap: () {
              ref.read(themeProvider.notifier).enableSystemMode();
              if (themeState.themeMode != ThemeMode.system) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      '\u062A\u0645 \u062A\u0641\u0639\u064A\u0644 ${l10n.systemMode}',
                    ),
                    backgroundColor: AppColors.success,
                    behavior: SnackBarBehavior.floating,
                    duration: const Duration(seconds: 2),
                  ),
                );
              }
            },
          ),
        ], isDark),
      ],
    );
  }

  Widget _buildSettingsGroup(String title, List<Widget> children, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: AlhaiSpacing.md),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(20, 16, 20, 8),
            child: Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ),
          ...children,
        ],
      ),
    );
  }

  Widget _buildThemeOptionTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool isSelected,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(AlhaiSpacing.xs),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withValues(alpha: 0.1)
              : (Theme.of(context).colorScheme.surfaceContainerHighest),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          color: isSelected ? AppColors.primary : AppColors.textSecondary,
          size: 20,
        ),
      ),
      title: Text(
        title,
        style: TextStyle(
          color: isSelected
              ? AppColors.primary
              : (Theme.of(context).colorScheme.onSurface),
          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          color: Theme.of(context).colorScheme.onSurfaceVariant,
          fontSize: 12,
        ),
      ),
      trailing: isSelected
          ? Container(
              padding: const EdgeInsets.all(AlhaiSpacing.xxs),
              decoration: const BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check, color: Colors.white, size: 16),
            )
          : Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.3)
                      : AppColors.border,
                  width: 2,
                ),
              ),
            ),
      onTap: onTap,
    );
  }
}

/// معاينة الثيم
class _ThemePreview extends StatelessWidget {
  final bool isDark;

  const _ThemePreview({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AlhaiSpacing.mdl),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Theme.of(context).dividerColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Mini app bar
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.2)
                      : Colors.black.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
              ),
              SizedBox(width: AlhaiSpacing.xs),
              Expanded(
                child: Container(
                  height: 12,
                  decoration: BoxDecoration(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.15)
                        : Colors.black.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: AlhaiSpacing.md),
          // Mini cards
          Row(
            children: [
              Expanded(
                child: _MiniCard(isDark: isDark, color: AppColors.primary),
              ),
              SizedBox(width: AlhaiSpacing.xs),
              Expanded(
                child: _MiniCard(isDark: isDark, color: AppColors.secondary),
              ),
            ],
          ),
          SizedBox(height: AlhaiSpacing.xs),
          Row(
            children: [
              Expanded(
                child: _MiniCard(isDark: isDark, color: AppColors.success),
              ),
              SizedBox(width: AlhaiSpacing.xs),
              Expanded(
                child: _MiniCard(isDark: isDark, color: AppColors.warning),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// بطاقة مصغرة للمعاينة
class _MiniCard extends StatelessWidget {
  final bool isDark;
  final Color color;

  const _MiniCard({required this.isDark, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        color: color.withValues(alpha: isDark ? 0.3 : 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Center(
        child: Container(
          width: 30,
          height: 6,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
      ),
    );
  }
}
