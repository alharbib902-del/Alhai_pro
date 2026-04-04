import 'package:supabase_flutter/supabase_flutter.dart';

/// Datasource for driver shift management.
class ShiftsDatasource {
  final SupabaseClient _client;

  ShiftsDatasource(this._client);

  String get _driverId {
    final user = _client.auth.currentUser;
    if (user == null) throw StateError('المستخدم غير مسجّل الدخول');
    return user.id;
  }

  /// Get active shift for current driver.
  Future<Map<String, dynamic>?> getActiveShift() async {
    return await _client
        .from('driver_shifts')
        .select()
        .eq('driver_id', _driverId)
        .eq('status', 'active')
        .maybeSingle();
  }

  /// Start a new shift.
  Future<Map<String, dynamic>> startShift() async {
    return await _client
        .from('driver_shifts')
        .insert({
          'driver_id': _driverId,
          'status': 'active',
          'started_at': DateTime.now().toIso8601String(),
        })
        .select()
        .single();
  }

  /// End the active shift.
  Future<void> endShift(String shiftId) async {
    await _client.from('driver_shifts').update({
      'status': 'ended',
      'ended_at': DateTime.now().toIso8601String(),
    }).eq('id', shiftId);

    // Set driver offline
    await _client.from('driver_locations').upsert({
      'driver_id': _driverId,
      'is_online': false,
      'updated_at': DateTime.now().toIso8601String(),
    });
  }

  /// Get shift history.
  Future<List<Map<String, dynamic>>> getShiftHistory({int limit = 30}) async {
    return await _client
        .from('driver_shifts')
        .select()
        .eq('driver_id', _driverId)
        .order('started_at', ascending: false)
        .limit(limit);
  }
}
