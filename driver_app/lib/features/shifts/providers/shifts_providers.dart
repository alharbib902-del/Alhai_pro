import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_it/get_it.dart';

import '../../../core/services/location_service.dart';
import '../data/shifts_datasource.dart';

/// Current active shift.
final activeShiftProvider = FutureProvider<Map<String, dynamic>?>((ref) async {
  final ds = GetIt.instance<ShiftsDatasource>();
  return ds.getActiveShift();
});

/// Whether driver is currently on shift.
final isOnShiftProvider = Provider<bool>((ref) {
  final shift = ref.watch(activeShiftProvider);
  return shift.whenOrNull(data: (data) => data != null) ?? false;
});

/// Toggle shift on/off.
///
/// When going online (starting a shift), validates that the driver is not
/// using a mock GPS provider. Throws [MockGpsDetectedException] if detected.
final toggleShiftProvider = FutureProvider<void>((ref) async {
  final ds = GetIt.instance<ShiftsDatasource>();
  final currentShift = await ds.getActiveShift();

  if (currentShift != null) {
    await ds.endShift(currentShift['id'] as String);
  } else {
    // Block going online with mock GPS.
    await LocationService.instance.getVerifiedPosition();
    await ds.startShift();
  }

  ref.invalidate(activeShiftProvider);
});

/// Shift history.
final shiftHistoryProvider = FutureProvider<List<Map<String, dynamic>>>((
  ref,
) async {
  final ds = GetIt.instance<ShiftsDatasource>();
  return ds.getShiftHistory();
});
