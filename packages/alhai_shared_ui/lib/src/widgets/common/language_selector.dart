/// Language Selector Widget - محدد اللغة
///
/// NOTE: This file is intentionally duplicated in alhai_auth.
/// It cannot be consolidated because alhai_shared_ui depends on alhai_auth,
/// so alhai_auth cannot import from alhai_shared_ui (circular dependency).
/// Keep both copies in sync manually.
///
/// مكون لاختيار لغة التطبيق من بين 6 لغات
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:alhai_l10n/alhai_l10n.dart';
import 'package:alhai_design_system/alhai_design_system.dart';

/// زر اختيار اللغة المصغر
class LanguageSelectorButton extends ConsumerWidget {
  final bool showLabel;
  final bool compact;

  const LanguageSelectorButton({
    super.key,
    this.showLabel = true,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final localeState = ref.watch(localeProvider);
    final currentLocale = localeState.locale;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    // ألوان متوافقة مع الوضع الداكن
    final backgroundColor = isDarkMode 
        ? const Color(0xFF374151) // Gray-700
        : AppColors.backgroundSecondary;
    final textColor = isDarkMode 
        ? Colors.white 
        : AppColors.textSecondary;
    final iconColor = isDarkMode 
        ? Colors.white70 
        : AppColors.textTertiary;

    return InkWell(
      onTap: () => _showLanguageDialog(context, ref),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: compact ? 8 : 12,
          vertical: compact ? 6 : 8,
        ),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(8),
          border: isDarkMode 
              ? Border.all(color: Colors.white12) 
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              SupportedLocales.getFlag(currentLocale),
              style: TextStyle(fontSize: compact ? 16 : 20),
            ),
            if (showLabel) ...[
              const SizedBox(width: 6),
              Text(
                SupportedLocales.getNativeName(currentLocale),
                style: TextStyle(
                  color: textColor,
                  fontSize: compact ? 12 : 13,
                ),
              ),
            ],
            const SizedBox(width: 4),
            Icon(
              Icons.keyboard_arrow_down_rounded,
              size: compact ? 16 : 18,
              color: iconColor,
            ),
          ],
        ),
      ),
    );
  }

  void _showLanguageDialog(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => LanguagePickerSheet(
        onSelect: (locale) {
          ref.read(localeProvider.notifier).setLocale(locale);
          Navigator.pop(context);
        },
      ),
    );
  }
}

/// شاشة اختيار اللغة
class LanguagePickerSheet extends ConsumerWidget {
  final ValueChanged<Locale> onSelect;

  const LanguagePickerSheet({
    super.key,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final localeState = ref.watch(localeProvider);
    final currentLocale = localeState.locale;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    // ألوان متوافقة مع الوضع الفاتح والداكن
    final backgroundColor = isDarkMode 
        ? const Color(0xFF1E293B) // Slate-800
        : Colors.white;
    final handleColor = isDarkMode 
        ? Colors.white24 
        : AppColors.border;

    return Container(
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // المقبض
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: handleColor,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // العنوان
          Padding(
            padding: const EdgeInsets.all(20),
            child: Text(
              AppLocalizations.of(context)?.selectLanguage ?? 'Select Language',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          // قائمة اللغات
          Flexible(
            child: ListView.builder(
              shrinkWrap: true,
              padding: EdgeInsets.zero,
              itemCount: SupportedLocales.all.length,
              itemBuilder: (context, index) {
                final locale = SupportedLocales.all[index];
                final isSelected = locale.languageCode == currentLocale.languageCode;
                return _LanguageOption(
                  locale: locale,
                  isSelected: isSelected,
                  onTap: () => onSelect(locale),
                  isDarkMode: isDarkMode,
                );
              },
            ),
          ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

/// عنصر لغة في القائمة
class _LanguageOption extends StatelessWidget {
  final Locale locale;
  final bool isSelected;
  final VoidCallback onTap;
  final bool isDarkMode;

  const _LanguageOption({
    required this.locale,
    required this.isSelected,
    required this.onTap,
    this.isDarkMode = false,
  });

  @override
  Widget build(BuildContext context) {
    final textColor = Theme.of(context).colorScheme.onSurface;
    final subtitleColor = Theme.of(context).colorScheme.onSurfaceVariant;
    
    return ListTile(
      onTap: onTap,
      leading: Text(
        SupportedLocales.getFlag(locale),
        style: const TextStyle(fontSize: 32),
      ),
      title: Text(
        SupportedLocales.getNativeName(locale),
        style: TextStyle(
          color: textColor,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      subtitle: Text(
        _getLanguageDescription(locale),
        style: TextStyle(
          color: subtitleColor,
          fontSize: 12,
        ),
      ),
      trailing: isSelected
          ? const Icon(
              Icons.check_circle_rounded,
              color: AppColors.primary,
            )
          : null,
    );
  }

  // L104: Use native language names so each user can identify their language
  String _getLanguageDescription(Locale locale) {
    switch (locale.languageCode) {
      case 'ar':
        return 'العربية - السعودية';
      case 'en':
        return 'English - United States';
      case 'ur':
        return 'اردو - پاکستان';
      case 'hi':
        return 'हिन्दी - भारत';
      case 'fil':
        return 'Filipino - Pilipinas';
      case 'bn':
        return 'বাংলা - বাংলাদেশ';
      case 'id':
        return 'Bahasa Indonesia';
      default:
        return '';
    }
  }
}

/// شاشة إعدادات اللغة الكاملة
class LanguageSettingsScreen extends ConsumerWidget {
  const LanguageSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final localeState = ref.watch(localeProvider);
    final currentLocale = localeState.locale;
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n?.language ?? 'Language'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // معلومات
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.info.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.info_outline_rounded,
                  color: AppColors.info,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    l10n?.languageChangeInfo ?? 'Choose your preferred display language. Changes will be applied immediately.',
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // قائمة اللغات
          ...SupportedLocales.all.map((locale) {
            final isSelected = locale.languageCode == currentLocale.languageCode;
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _LanguageCard(
                locale: locale,
                isSelected: isSelected,
                onTap: () {
                  ref.read(localeProvider.notifier).setLocale(locale);
                },
              ),
            );
          }),
        ],
      ),
    );
  }
}

/// كارت اللغة
class _LanguageCard extends StatelessWidget {
  final Locale locale;
  final bool isSelected;
  final VoidCallback onTap;

  const _LanguageCard({
    required this.locale,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.primary.withValues(alpha: 0.05)
                : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? AppColors.primary : AppColors.border,
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Row(
            children: [
              // العلم
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.backgroundSecondary,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    SupportedLocales.getFlag(locale),
                    style: const TextStyle(fontSize: 28),
                  ),
                ),
              ),

              const SizedBox(width: 16),

              // المعلومات
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      SupportedLocales.getNativeName(locale),
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 16,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        if (SupportedLocales.isRtl(locale)) ...[
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text(
                              'RTL',
                              style: TextStyle(
                                color: AppColors.primary,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                        ],
                        Text(
                          locale.countryCode ?? '',
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // علامة الاختيار
              if (isSelected)
                const Icon(
                  Icons.check_circle_rounded,
                  color: AppColors.primary,
                  size: 24,
                )
              else
                const Icon(
                  Icons.radio_button_unchecked_rounded,
                  color: AppColors.textTertiary,
                  size: 24,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
