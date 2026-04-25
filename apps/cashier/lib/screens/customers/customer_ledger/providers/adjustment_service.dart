/// خدمة حفظ تسوية يدوية على حساب عميل
///
/// تُغلّف: DB transaction (insert transaction + update balance) + invalidate.
/// يُستدعى من الـ container عبر showAdjustmentDialog → onSave.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_it/get_it.dart';
import 'package:alhai_shared_ui/alhai_shared_ui.dart';
import 'package:alhai_l10n/alhai_l10n.dart';
import 'package:alhai_database/alhai_database.dart';
import 'package:alhai_auth/alhai_auth.dart' show currentUserProvider;
import 'package:alhai_sync/alhai_sync.dart' show SyncPriority;
import 'package:uuid/uuid.dart';
import 'package:alhai_design_system/alhai_design_system.dart' show AlhaiSnackbar;

import '../../../../core/services/sentry_service.dart';
import '../../../../core/services/audit_service.dart';
import 'customer_ledger_providers.dart';

/// تنفيذ حفظ تسوية يدوية لحساب عميل.
///
/// - يضبط [ledgerAdjustingProvider] = true أثناء العملية
/// - يُدرِج حركة + يحدّث رصيد الحساب داخل transaction واحدة
/// - يُبطل [accountLedgerDataProvider] لإجبار إعادة الجلب
/// - يعرض رسالة نجاح أو حوار خطأ
///
/// C-4 Session 4: accounts.balance, transactions.amount,
/// balance_after كلها int cents في DB.
Future<void> saveLedgerAdjustment({
  required BuildContext context,
  required WidgetRef ref,
  required String accountId,
  required String type,
  required double amount,
  required String reason,
  required DateTime date,
  required AppLocalizations l10n,
}) async {
  ref.read(ledgerAdjustingProvider.notifier).state = true;

  final db = GetIt.I<AppDatabase>();
  final isDebit = type == 'debit';
  final signedAmount = isDebit ? amount : -amount;
  final storeId = ref.read(currentStoreIdProvider);
  if (storeId == null) {
    ref.read(ledgerAdjustingProvider.notifier).state = false;
    return;
  }
  final user = ref.read(currentUserProvider);
  final syncService = ref.read(syncServiceProvider);
  final description = reason.isEmpty ? l10n.manualAdjustment : reason;

  try {
    final txnId = const Uuid().v4();
    // Re-fetch the account inside the transaction so the saved balance
    // reflects the most recent value, not whatever the UI cached. Without
    // this guard a concurrent write (e.g. a sale or another adjustment)
    // would be silently overwritten.
    // Wave 10 (P0-12): atomic SQL `balance = balance + ?` via
    // `addToBalance` instead of read-modify-write. Two devices sync
    // applying ±300 / ±200 to the same account used to lose one delta
    // when LWW picked one device's "absolute" balance over the other;
    // the SQL atomic add commutes so both deltas land. We still need
    // the freshly-read `newBalance` for the audit row's `balanceAfter`
    // — re-read it inside the same tx after the write so the value
    // matches what's on disk.
    late final double newBalance;
    await db.transaction(() async {
      await db.accountsDao.addToBalance(accountId, signedAmount);
      final fresh = await db.accountsDao.getAccountById(accountId);
      newBalance = (fresh?.balance ?? 0) / 100.0;
      await db.transactionsDao.insertTransaction(
        TransactionsTableCompanion.insert(
          id: txnId,
          storeId: storeId,
          accountId: accountId,
          type: 'adjustment',
          amount: (signedAmount * 100).round(),
          balanceAfter: (newBalance * 100).round(),
          description: Value(description),
          createdBy: Value(user?.name),
          createdAt: date,
        ),
      );
    });

    // Sync enqueue — outside the DB transaction. Without this, manual
    // adjustments stay local-only and the cloud ledger drifts (audit gap
    // + risk vector for unauthorized balance changes that never reach
    // server-side review).
    try {
      await syncService.enqueueCreate(
        tableName: 'transactions',
        recordId: txnId,
        data: {
          'id': txnId,
          'storeId': storeId,
          'accountId': accountId,
          'type': 'adjustment',
          'amount': (signedAmount * 100).round(),
          'balanceAfter': (newBalance * 100).round(),
          'description': description,
          'createdBy': user?.name,
          'createdAt': date.toIso8601String(),
        },
        priority: SyncPriority.high,
      );
      await syncService.enqueueUpdate(
        tableName: 'accounts',
        recordId: accountId,
        changes: {
          'id': accountId,
          'balance': (newBalance * 100).round(),
          'lastTransactionAt': date.toIso8601String(),
          'updatedAt': date.toIso8601String(),
        },
        priority: SyncPriority.high,
      );
    } catch (e, stack) {
      reportError(
        e,
        stackTrace: stack,
        hint: 'Adjustment sync enqueue (txn=$txnId)',
      );
    }

    ref.invalidate(accountLedgerDataProvider(accountId));

    // Audit log — manual balance changes must leave a trace for compliance
    // review. `logTransaction` records the full before/after context.
    // P1 #9: previously the adjustment bypassed the audit trail entirely.
    // Fetch account name for the description; fall back to the id.
    try {
      final fresh = await db.accountsDao.getAccountById(accountId);
      auditService.logTransaction(
        storeId: storeId,
        userId: user?.id ?? 'unknown',
        userName: user?.name ?? 'unknown',
        transactionId: txnId,
        accountName: fresh?.name ?? accountId,
        type: 'adjustment',
        amount: signedAmount,
        balanceAfter: newBalance,
      );
    } catch (e, stack) {
      // Audit failure is non-fatal for the local save — log and proceed.
      reportError(
        e,
        stackTrace: stack,
        hint: 'Adjustment audit log (txn=$txnId)',
      );
    }

    if (context.mounted) {
      AlhaiSnackbar.success(context, l10n.adjustmentSaved);
    }
  } catch (e, stack) {
    reportError(e, stackTrace: stack, hint: 'Save ledger adjustment');
    if (context.mounted) {
      await showDialog<void>(
        context: context,
        builder: (ctx) => AlertDialog(
          icon: const Icon(
            Icons.error_outline,
            color: AppColors.error,
            size: 48,
          ),
          title: Text(l10n.error),
          content: Text(l10n.errorWithDetails('$e')),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(l10n.close),
            ),
          ],
        ),
      );
    }
  } finally {
    if (context.mounted) {
      ref.read(ledgerAdjustingProvider.notifier).state = false;
    }
  }
}
