/// Shared localization (7 languages) and locale management for Alhai apps.
///
/// Supports: Arabic (primary), English, Urdu, Hindi, Filipino, Bengali, Indonesian.
/// RTL support for Arabic and Urdu.
library alhai_l10n;

// Locale provider (SupportedLocales, LocaleNotifier, Riverpod providers)
export 'src/locale_provider.dart';

// Generated localizations (AppLocalizations class)
export 'l10n/generated/app_localizations.dart';
