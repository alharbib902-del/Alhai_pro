/// Supabase Configuration
///
/// Contains Supabase project URL and anon key.
/// NEVER include service_role key in client code.
///
/// ⚠️ ملاحظة أمنية مهمة:
/// يجب تمرير القيم عبر --dart-define عند البناء:
///
/// للتطوير:
/// flutter run --dart-define=SUPABASE_URL=xxx --dart-define=SUPABASE_ANON_KEY=xxx
///
/// للإنتاج:
/// flutter build apk --dart-define=SUPABASE_URL=xxx --dart-define=SUPABASE_ANON_KEY=xxx
///
/// ⚠️ لا تضع القيم الفعلية في الكود أبداً!
library;

import 'package:flutter/foundation.dart';

class SupabaseConfig {
  SupabaseConfig._();

  /// Supabase project URL
  /// في وضع التطوير يستخدم القيمة الافتراضية تلقائياً
  /// في الإنتاج: --dart-define=SUPABASE_URL=https://your-project.supabase.co
  static const String url = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'https://jtgwboqushihwvvsdtud.supabase.co',
  );

  /// Supabase anon (public) key
  /// في وضع التطوير يستخدم القيمة الافتراضية تلقائياً
  /// في الإنتاج: --dart-define=SUPABASE_ANON_KEY=your_anon_key
  static const String anonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imp0Z3dib3F1c2hpaHd2dnNkdHVkIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzEzODIyODMsImV4cCI6MjA4Njk1ODI4M30.nqYYVlk2YeSgG7FNy7CIpXaw4vHWfU4oRMKDHWL-gzM',
  );

  /// Whether to enable Supabase debug logging
  static bool get enableDebugLogs => kDebugMode;

  /// هل الإعدادات مكتملة؟
  static bool get isConfigured => url.isNotEmpty && anonKey.isNotEmpty;

  /// رسالة خطأ إذا كانت الإعدادات غير مكتملة
  static String get configurationError {
    final missing = <String>[];
    if (url.isEmpty) missing.add('SUPABASE_URL');
    if (anonKey.isEmpty) missing.add('SUPABASE_ANON_KEY');

    if (missing.isEmpty) return '';
    return 'Missing required environment variables: ${missing.join(', ')}. '
        'Use --dart-define to provide them.';
  }
}
