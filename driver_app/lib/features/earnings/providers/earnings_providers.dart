import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_it/get_it.dart';

import '../data/earnings_datasource.dart';

/// Selected earnings period.
enum EarningsPeriod { daily, weekly, monthly }

final earningsPeriodProvider = StateProvider<EarningsPeriod>(
  (ref) => EarningsPeriod.daily,
);

/// Earnings summary based on selected period.
final earningsSummaryProvider = FutureProvider<Map<String, dynamic>>((
  ref,
) async {
  final period = ref.watch(earningsPeriodProvider);
  final ds = GetIt.instance<EarningsDatasource>();

  final now = DateTime.now();
  late DateTime from;

  switch (period) {
    case EarningsPeriod.daily:
      from = DateTime(now.year, now.month, now.day);
    case EarningsPeriod.weekly:
      from = now.subtract(Duration(days: now.weekday - 1));
      from = DateTime(from.year, from.month, from.day);
    case EarningsPeriod.monthly:
      from = DateTime(now.year, now.month, 1);
  }

  return ds.getEarningsSummary(from: from, to: now);
});
