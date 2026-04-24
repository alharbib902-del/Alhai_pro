/// مزوّدات بيانات كشف حساب العميل (Riverpod)
///
/// يستبدل متغيّرات حالة الشاشة (_account, _transactions, _isLoading, _error,
/// _isAdjusting) بـ Riverpod providers لتقليل setState إلى الأدنى.
///
/// ملاحظة تصميم:
/// - `accountLedgerDataProvider` يجمع الحساب + قائمة الحركات في FutureProvider
///   واحد للحفاظ على توافق test stubs الحالية (`getAccountById` +
///   `getAccountTransactions`).
/// - التحديث التفاعلي (realtime) يتم عبر `ref.invalidate(...)` بعد الحفظ،
///   وليس عبر StreamProvider — حفاظاً على عقد الاختبار الحالي.
///   يمكن لاحقاً ترحيله إلى `watchAccountTransactions` دون تغيير الـ UI.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_it/get_it.dart';
import 'package:alhai_database/alhai_database.dart';

/// الحالة المُجمَّعة لصفحة كشف الحساب (حساب + حركاته)
class CustomerLedgerData {
  final AccountsTableData? account;
  final List<TransactionsTableData> transactions;

  const CustomerLedgerData({
    required this.account,
    required this.transactions,
  });
}

/// Provider يجلب بيانات كشف الحساب من DB (حساب + حركات) لحساب محدّد
///
/// family: معرّف الحساب
/// autoDispose: يتم إلغاؤه عند الخروج من الشاشة
final accountLedgerDataProvider = FutureProvider.autoDispose
    .family<CustomerLedgerData, String>((ref, accountId) async {
      final db = GetIt.I<AppDatabase>();
      final account = await db.accountsDao.getAccountById(accountId);
      final transactions = await db.transactionsDao.getAccountTransactions(
        accountId,
      );
      return CustomerLedgerData(
        account: account,
        transactions: transactions,
      );
    });

/// حالة عملية "حفظ تسوية يدوية" جارية الآن
///
/// يستبدل `_isAdjusting` setState في الشاشة القديمة.
final ledgerAdjustingProvider = StateProvider.autoDispose<bool>((_) => false);
