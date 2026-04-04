/// Report-related providers.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/models.dart';
import 'distributor_datasource_provider.dart';

// ─── Reports ────────────────────────────────────────────────────

/// Report data — period is one of: day, week, month, year
final reportDataProvider =
    FutureProvider.family<ReportData, String>((ref, period) async {
  final ds = ref.watch(distributorDatasourceProvider);
  return ds.getReportData(period: period);
});
