import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_it/get_it.dart';

import '../data/delivery_datasource.dart';

/// Tracks new delivery assignments from Realtime stream.
/// Filters for status == 'assigned' and provides the latest one.
final newAssignmentProvider =
    StreamProvider<Map<String, dynamic>?>((ref) async* {
  final ds = GetIt.instance<DeliveryDatasource>();

  await for (final deliveries in ds.streamNewAssignments()) {
    final assigned = deliveries
        .where((d) => d['status'] == 'assigned')
        .toList();

    if (assigned.isNotEmpty) {
      yield assigned.first;
    } else {
      yield null;
    }
  }
});

/// Whether there's a pending new assignment.
final hasNewAssignmentProvider = Provider<bool>((ref) {
  final assignment = ref.watch(newAssignmentProvider);
  return assignment.whenOrNull(data: (data) => data != null) ?? false;
});
