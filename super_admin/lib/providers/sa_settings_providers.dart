import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/services/sentry_service.dart';
import '../data/models/sa_analytics_model.dart';

import 'sa_dashboard_providers.dart' show saSupabaseClientProvider;

// ============================================================================
// PLATFORM SETTINGS
// ============================================================================

/// Platform settings from the `platform_settings` Supabase table.
///
/// Errors propagate as [AsyncError] — consumers must handle the `error:`
/// branch of the returned [AsyncValue]. Fallback to hardcoded defaults is
/// intentionally avoided: if the read fails (network, RLS, auth expiry,
/// JSON shape drift), surfacing synthetic values would let operators edit
/// and then overwrite real platform settings on save.
final saPlatformSettingsProvider =
    FutureProvider.autoDispose<SAPlatformSettings>((ref) async {
      final client = ref.watch(saSupabaseClientProvider);
      try {
        final data = await client
            .from('platform_settings')
            .select('*')
            .single();
        return SAPlatformSettings.fromJson(data);
      } catch (e, st) {
        await reportError(
          e,
          stackTrace: st,
          hint: 'saPlatformSettingsProvider: failed to load platform_settings',
        );
        rethrow;
      }
    });
