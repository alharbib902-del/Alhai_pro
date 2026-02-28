/// Customers Providers
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:alhai_auth/alhai_auth.dart';
import 'package:alhai_database/alhai_database.dart';
import 'package:get_it/get_it.dart';

/// Customer account detail
final customerDetailProvider = FutureProvider.autoDispose
    .family<AccountsTableData?, String>((ref, accountId) async {
  final db = GetIt.I<AppDatabase>();
  return db.accountsDao.getAccountById(accountId);
});

/// Customer transactions
final customerTransactionsProvider = FutureProvider.autoDispose
    .family<List<TransactionsTableData>, String>((ref, accountId) async {
  final db = GetIt.I<AppDatabase>();
  return db.transactionsDao.getAccountTransactions(accountId);
});

/// Receivable accounts (customer debts)
final receivableAccountsProvider =
    FutureProvider.autoDispose<List<AccountsTableData>>((ref) async {
  final storeId = ref.watch(currentStoreIdProvider);
  if (storeId == null) return [];
  final db = GetIt.I<AppDatabase>();
  return db.accountsDao.getReceivableAccounts(storeId);
});

/// Total receivable
final totalReceivableProvider =
    FutureProvider.autoDispose<double>((ref) async {
  final storeId = ref.watch(currentStoreIdProvider);
  if (storeId == null) return 0.0;
  final db = GetIt.I<AppDatabase>();
  return db.accountsDao.getTotalReceivable(storeId);
});
