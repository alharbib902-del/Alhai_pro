/// Customers Providers
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/local/app_database.dart';
import '../di/injection.dart';
import 'products_providers.dart';

/// Customer account detail
final customerDetailProvider = FutureProvider.autoDispose
    .family<AccountsTableData?, String>((ref, accountId) async {
  final db = getIt<AppDatabase>();
  return db.accountsDao.getAccountById(accountId);
});

/// Customer transactions
final customerTransactionsProvider = FutureProvider.autoDispose
    .family<List<TransactionsTableData>, String>((ref, accountId) async {
  final db = getIt<AppDatabase>();
  return db.transactionsDao.getAccountTransactions(accountId);
});

/// Receivable accounts (customer debts)
final receivableAccountsProvider =
    FutureProvider.autoDispose<List<AccountsTableData>>((ref) async {
  final storeId = ref.watch(currentStoreIdProvider);
  if (storeId == null) return [];
  final db = getIt<AppDatabase>();
  return db.accountsDao.getReceivableAccounts(storeId);
});

/// Total receivable
final totalReceivableProvider =
    FutureProvider.autoDispose<double>((ref) async {
  final storeId = ref.watch(currentStoreIdProvider);
  if (storeId == null) return 0.0;
  final db = getIt<AppDatabase>();
  return db.accountsDao.getTotalReceivable(storeId);
});
