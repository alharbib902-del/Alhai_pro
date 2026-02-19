/// مزودات المبيعات - Sale Providers
///
/// توفر خدمة المبيعات للتطبيق
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/sale_service.dart';
import 'sync_providers.dart';

/// مزود خدمة المبيعات
final saleServiceProvider = Provider<SaleService>((ref) {
  final db = ref.watch(appDatabaseProvider);
  final syncService = ref.watch(syncServiceProvider);
  
  return SaleService(
    db: db,
    syncService: syncService,
  );
});

/// مزود إجمالي مبيعات اليوم
final todaySalesTotalProvider = FutureProvider.family<double, (String, String)>((ref, params) async {
  final saleService = ref.watch(saleServiceProvider);
  final (storeId, cashierId) = params;
  return saleService.getTodayTotal(storeId, cashierId);
});

/// مزود عدد مبيعات اليوم
final todaySalesCountProvider = FutureProvider.family<int, (String, String)>((ref, params) async {
  final saleService = ref.watch(saleServiceProvider);
  final (storeId, cashierId) = params;
  return saleService.getTodayCount(storeId, cashierId);
});
