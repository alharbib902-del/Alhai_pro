/// Datasource singleton provider.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/distributor_datasource.dart';

// ─── Datasource singleton ───────────────────────────────────────

final distributorDatasourceProvider = Provider<DistributorDatasource>((ref) {
  return DistributorDatasource();
});
