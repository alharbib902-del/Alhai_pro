/// مزوّدات بيانات كشف حساب العميل (Riverpod)
///
/// يستبدل متغيّرات حالة الشاشة (_account, _transactions, _isLoading, _error,
/// _isAdjusting) بـ Riverpod providers لتقليل setState إلى الأدنى.
///
/// P1 #12: تم تحويل `accountLedgerDataProvider` من `FutureProvider` إلى
/// `StreamProvider` يستخدم `watchAccountById` + `watchAccountTransactions`
/// حتى تتحدّث الشاشة تلقائياً بعد أي كتابة (تسوية، سداد، بيع بالدين)
/// بدون الحاجة لـ `ref.invalidate` يدوي. يحافظ `rxdart.combineLatest2`
/// على نفس واجهة `CustomerLedgerData` حتى لا تتكسّر الواجهة والاختبارات.
library;

import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_it/get_it.dart';
import 'package:alhai_auth/alhai_auth.dart' show currentStoreIdProvider;
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

/// Provider يجلب بيانات كشف الحساب من DB (حساب + حركات) لحساب محدّد.
///
/// StreamProvider حتى تتحدّث الشاشة تلقائياً بعد كل كتابة (انظر P1 #12).
/// family: معرّف الحساب.
/// autoDispose: يتم إلغاؤه عند الخروج من الشاشة.
///
/// نلتزم بحدود `StreamController` يدوية بدلاً من `rxdart` لتجنّب إضافة
/// dependency لهذا الإصلاح فقط. كل stream يُحتفظ بآخر قيمة له ويُبنى
/// `CustomerLedgerData` جديد عند كل تحديث من أيّ منهما.
final accountLedgerDataProvider = StreamProvider.autoDispose
    .family<CustomerLedgerData, String>((ref, accountId) {
      final db = GetIt.I<AppDatabase>();
      final controller = StreamController<CustomerLedgerData>();
      // P2 #5: scope the ledger to the currently-active store. Without this
      // guard the screen would render an account from a previously-selected
      // store if the id lingered in a deep-link or stale navigator state —
      // a multi-tenant data-leak risk.
      final currentStoreId = ref.watch(currentStoreIdProvider);

      AccountsTableData? lastAccount;
      List<TransactionsTableData>? lastTransactions;
      var accountReceived = false;
      var transactionsReceived = false;

      void emit() {
        if (!accountReceived || !transactionsReceived) return;
        if (controller.isClosed) return;
        // Reject the account when it belongs to a different store. We still
        // emit so the UI can render its empty/error state rather than hang.
        final acc =
            (lastAccount != null && lastAccount!.storeId != currentStoreId)
            ? null
            : lastAccount;
        controller.add(
          CustomerLedgerData(
            account: acc,
            transactions: acc == null ? const [] : (lastTransactions ?? const []),
          ),
        );
      }

      final accountSub = db.accountsDao.watchAccountById(accountId).listen(
        (account) {
          lastAccount = account;
          accountReceived = true;
          emit();
        },
        onError: controller.addError,
      );
      final txnSub = db.transactionsDao
          .watchAccountTransactions(accountId)
          .listen(
            (transactions) {
              lastTransactions = transactions;
              transactionsReceived = true;
              emit();
            },
            onError: controller.addError,
          );

      ref.onDispose(() {
        accountSub.cancel();
        txnSub.cancel();
        controller.close();
      });

      return controller.stream;
    });

/// حالة عملية "حفظ تسوية يدوية" جارية الآن
///
/// يستبدل `_isAdjusting` setState في الشاشة القديمة.
final ledgerAdjustingProvider = StateProvider.autoDispose<bool>((_) => false);
