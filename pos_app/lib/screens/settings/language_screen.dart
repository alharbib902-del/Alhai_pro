/// شاشة اختيار اللغة - Language Selection Screen
///
/// تتيح للمستخدم:
/// - اختيار لغة التطبيق من 7 لغات
/// - معاينة فورية للتغيير
/// - حفظ التفضيل
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/locale/locale_provider.dart';
import '../../core/theme/app_colors.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../widgets/layout/app_header.dart';

/// شاشة اختيار اللغة
class LanguageScreen extends ConsumerStatefulWidget {
  const LanguageScreen({super.key});

  @override
  ConsumerState<LanguageScreen> createState() => _LanguageScreenState();
}

class _LanguageScreenState extends ConsumerState<LanguageScreen> {
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isWideScreen = size.width > 900;
    final isMediumScreen = size.width > 600;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;

    return Column(
              children: [
                AppHeader(
                  title: l10n.language,
                  onMenuTap: isWideScreen
                      ? null
                      : () => Scaffold.of(context).openDrawer(),
                  onNotificationsTap: () => context.push('/notifications'),
                  notificationsCount: 3,
                  userName:
                      '\u0623\u062d\u0645\u062f \u0645\u062d\u0645\u062f',
                  userRole: l10n.branchManager,
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.all(isMediumScreen ? 24 : 16),
                    child: _buildContent(
                        isWideScreen, isMediumScreen, isDark, l10n),
                  ),
                ),
              ],
            );
  }

  Widget _buildContent(
      bool isWideScreen, bool isMediumScreen, bool isDark, AppLocalizations l10n) {
    final localeState = ref.watch(localeProvider);
    final currentLocale = localeState.locale;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Info note
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark
                ? AppColors.info.withValues(alpha: 0.15)
                : AppColors.info.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppColors.info.withValues(alpha: 0.3),
            ),
          ),
          child: Row(
            children: [
              const Icon(Icons.info_outline, color: AppColors.info, size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  l10n.languageChangeInfo,
                  style: TextStyle(
                    color: isDark
                        ? AppColors.info
                        : AppColors.info,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 24),

        // Language list
        _buildSettingsGroup(
          l10n.selectLanguage,
          SupportedLocales.all.map((locale) {
            final isSelected =
                locale.languageCode == currentLocale.languageCode;
            final nativeName = SupportedLocales.getNativeName(locale);
            final flag = SupportedLocales.getFlag(locale);
            final isRtl = SupportedLocales.isRtl(locale);

            return _buildLanguageTile(
              flag: flag,
              name: nativeName,
              code: locale.languageCode.toUpperCase(),
              isRtl: isRtl,
              isSelected: isSelected,
              isDark: isDark,
              onTap: () {
                ref.read(localeProvider.notifier).setLocale(locale);
              },
            );
          }).toList(),
          isDark,
        ),
      ],
    );
  }

  Widget _buildSettingsGroup(
      String title, List<Widget> children, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color:
              isDark ? Colors.white.withValues(alpha: 0.1) : AppColors.border,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
            child: Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : AppColors.textPrimary,
              ),
            ),
          ),
          ...children,
        ],
      ),
    );
  }

  Widget _buildLanguageTile({
    required String flag,
    required String name,
    required String code,
    required bool isRtl,
    required bool isSelected,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Text(flag, style: const TextStyle(fontSize: 28)),
      title: Text(
        name,
        style: TextStyle(
          color: isSelected
              ? AppColors.primary
              : (isDark ? Colors.white : AppColors.textPrimary),
          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
        ),
      ),
      subtitle: Row(
        children: [
          Text(
            code,
            style: TextStyle(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.5)
                  : AppColors.textSecondary,
              fontSize: 12,
            ),
          ),
          if (isRtl) ...[
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.info.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Text(
                'RTL',
                style: TextStyle(
                  color: AppColors.info,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ],
      ),
      trailing: isSelected
          ? Container(
              padding: const EdgeInsets.all(4),
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

/// Dialog لاختيار اللغة السريع
class LanguagePickerDialog extends ConsumerWidget {
  const LanguagePickerDialog({super.key});

  static Future<void> show(BuildContext context) {
    return showDialog(
      context: context,
      builder: (context) => const LanguagePickerDialog(),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final localeState = ref.watch(localeProvider);
    final currentLocale = localeState.locale;

    return AlertDialog(
      title: Text(AppLocalizations.of(context)!.selectLanguage),
      contentPadding: const EdgeInsets.symmetric(vertical: 16),
      content: SizedBox(
        width: double.maxFinite,
        child: ListView.builder(
          shrinkWrap: true,
          itemCount: SupportedLocales.all.length,
          itemBuilder: (context, index) {
            final locale = SupportedLocales.all[index];
            final isSelected =
                locale.languageCode == currentLocale.languageCode;
            final nativeName = SupportedLocales.getNativeName(locale);
            final flag = SupportedLocales.getFlag(locale);

            return ListTile(
              leading: Text(flag, style: const TextStyle(fontSize: 24)),
              title: Text(nativeName),
              trailing: isSelected
                  ? const Icon(Icons.check_circle, color: AppColors.primary)
                  : null,
              selected: isSelected,
              onTap: () {
                ref.read(localeProvider.notifier).setLocale(locale);
                Navigator.of(context).pop();
              },
            );
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(AppLocalizations.of(context)!.cancel),
        ),
      ],
    );
  }
}
