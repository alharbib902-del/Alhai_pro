import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/providers/app_providers.dart';

/// Dashboard stats for the driver (today's deliveries, earnings, etc.).
final dashboardStatsProvider =
    FutureProvider<Map<String, dynamic>>((ref) async {
  final client = ref.read(supabaseClientProvider);
  final driverId = client.auth.currentUser?.id;
  if (driverId == null) return {};

  final result = await client.rpc(
    'get_driver_dashboard_stats',
    params: {'p_driver_id': driverId},
  );

  return result as Map<String, dynamic>;
});
