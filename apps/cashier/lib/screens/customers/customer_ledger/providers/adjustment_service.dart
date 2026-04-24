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
import 'package:uuid/uuid.dart';
import 'package:alhai_design_system/alhai_design_system.dart' show AlhaiSnackbar;

import '../../../../core/services/sentry_service.dart';
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
  final account =
      ref.read(accountLedgerDataProvider(accountId)).valueOrNull?.account;
  final isDebit = type == 'debit';
  final currentBal = (account?.balance ?? 0) / 100.0;
  final signedAmount = isDebit ? amount : -amount;
  final newBalance = currentBal + signedAmount;
  final storeId = ref.read(currentStoreIdProvider);
  if (storeId == null) {
    ref.read(ledgerAdjustingProvider.notifier).state = false;
    return;
  }

  try {
    final txnId = const Uuid().v4();
    await db.transaction(() async {
      await db.transactionsDao.insertTransaction(
        TransactionsTableCompanion.insert(
          id: txnId,
          storeId: storeId,
          accountId: accountId,
          type: 'adjustment',
          amount: (signedAmount * 100).round(),
          balanceAfter: (newBalance * 100).round(),
          description: Value(reason.isEmpty ? l10n.manualAdjustment : reason),
          createdAt: date,
        ),
      );
      await db.accountsDao.updateBalance(accountId, newBalance);
    });
    ref.invalidate(accountLedgerDataProvider(accountId));

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
