import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_it/get_it.dart';

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
final toggleShiftProvider = FutureProvider<void>((ref) async {
  final ds = GetIt.instance<ShiftsDatasource>();
  final currentShift = await ds.getActiveShift();

  if (currentShift != null) {
    await ds.endShift(currentShift['id'] as String);
  } else {
    await ds.startShift();
  }

  ref.invalidate(activeShiftProvider);
});

/// Shift history.
final shiftHistoryProvider =
    FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final ds = GetIt.instance<ShiftsDatasource>();
  return ds.getShiftHistory();
});
