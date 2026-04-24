/// دوال مساعدة داخلية لـ widgets كشف الحساب
///
/// تحتوي على: أيقونات/ألوان/تسميات أنواع الحركات، تنسيق التاريخ،
/// وتحويل TransactionsTableData إلى خريطة العرض (debit/credit/balance بـ SAR).
library;

import 'package:flutter/material.dart';
import 'package:alhai_shared_ui/alhai_shared_ui.dart';
import 'package:alhai_l10n/alhai_l10n.dart';
import 'package:alhai_database/alhai_database.dart';

/// أيقونة الحركة حسب النوع
IconData ledgerTypeIcon(String type) {
  switch (type) {
    case 'opening':
      return Icons.account_balance_outlined;
    case 'invoice':
      return Icons.receipt_long_outlined;
    case 'payment':
      return Icons.payments_outlined;
    case 'adjustment':
      return Icons.tune_rounded;
    case 'return':
      return Icons.assignment_return_outlined;
    default:
      return Icons.swap_horiz_rounded;
  }
}

/// لون الحركة حسب النوع
Color ledgerTypeColor(String type, BuildContext context) {
  switch (type) {
    case 'opening':
      return AppColors.info;
    case 'invoice':
      return AppColors.secondary;
    case 'payment':
      return AppColors.success;
    case 'adjustment':
      return AppColors.warning;
    case 'return':
      return AppColors.purple;
    default:
      return Theme.of(context).colorScheme.outline;
  }
}

/// تسمية الحركة المحلَّاة حسب النوع
String ledgerTypeLabel(String type, AppLocalizations l10n) {
  switch (type) {
    case 'opening':
      return l10n.openingBalance;
    case 'invoice':
      return l10n.invoices;
    case 'payment':
      return l10n.payment;
    case 'adjustment':
      return l10n.adjustmentEntry;
    case 'return':
      return l10n.returnEntry;
    default:
      return type;
  }
}

/// تنسيق تاريخ YYYY-MM-DD
String formatLedgerDate(DateTime date) =>
    '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

/// تنسيق تاريخ + وقت HH:MM
String formatLedgerDateTime(DateTime date) =>
    '${formatLedgerDate(date)} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';

/// تحويل حركة DB إلى صورة عرض (cents → SAR doubles)
///
/// C-4 Session 4: transactions.amount, balance_after are int cents.
List<Map<String, dynamic>> ledgerTxnToMap(TransactionsTableData t) {
  final isDebit = t.amount > 0;
  final amountSar = t.amount.abs() / 100.0;
  final balanceSar = t.balanceAfter / 100.0;
  return [
    {
      'id': t.id,
      'type': t.type,
      'description': t.description ?? t.type,
      'reference': t.referenceId ?? '-',
      'debit': isDebit ? amountSar : 0.0,
      'credit': isDebit ? 0.0 : amountSar,
      'balance': balanceSar,
      'date': t.createdAt,
    },
  ];
}
