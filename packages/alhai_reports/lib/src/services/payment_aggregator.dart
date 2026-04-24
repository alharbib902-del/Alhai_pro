/// Payment Aggregator - تجميع المدفوعات
///
/// Sprint 1 / P0-16: single-source aggregation for payment breakdowns
/// across the three financial reports (payment_history, payment_reports,
/// custom_report). Before this, each report rolled its own loop and they
/// disagreed:
///
/// 1. **Mixed payments were misclassified.** Each loop bucketed by
///    `sales.payment_method` (a single string), so a 100 SAR sale split
///    50 cash / 50 card was attributed entirely to one method — usually
///    'mixed' or whichever single string the writer chose. The reports
///    showed "cash 100, card 0" instead of "cash 50, card 50". Pie charts
///    and totals shown to managers were wrong, leading to wrong debt-
///    collection and cash-handling decisions.
///
/// 2. **Voided / refunded sales were counted.** None of the loops filtered
///    by `status='completed'`, so a voided 500 SAR sale still appeared as
///    500 SAR in revenue. ZATCA totals shipped wrong; manager dashboards
///    inflated.
///
/// This aggregator solves both at the boundary:
/// * Reads `cashAmount` / `cardAmount` / `creditAmount` int-cents columns
///   directly when populated (the multi-tender path), so a mixed sale's
///   100 SAR breaks down into the actual 50+50 split that was charged.
/// * Falls back to the `paymentMethod` string only for legacy single-
///   tender rows (all three split columns null/zero), which matches what
///   the cashier actually entered for those sales.
/// * Filters `status != 'completed'` and reports the count of excluded
///   rows so callers can surface "12 voided/refunded excluded" UX.
///
/// All accumulation is in int cents — conversion to SAR happens at the
/// display boundary via [PaymentBreakdown.cashSar] etc., to avoid the
/// round-tripping bugs the v45 100× cleanup fixed.
library;

import 'package:alhai_database/alhai_database.dart';

/// Immutable result of aggregating a list of sales by payment method.
class PaymentBreakdown {
  /// Cents collected as cash (split column + single-tender 'cash' fallback).
  final int cashCents;

  /// Cents collected via card (split column + 'card'/'mada' single-tender).
  /// 'mada' (Saudi domestic debit) is grouped with 'card' for reporting,
  /// matching the convention used by payment_reports_screen pre-fix.
  final int cardCents;

  /// Cents recorded as credit / آجل (split column + 'credit' single-tender
  /// + every other unknown payment method, matching the legacy bucket).
  final int creditCents;

  /// Sum of `sales.total` for included rows.
  final int totalCents;

  /// Number of completed sales whose `cashAmount > 0`, OR (when no split
  /// columns are populated) whose `paymentMethod == 'cash'`. A mixed sale
  /// that includes any cash counts here AND in [cardCount]/[creditCount]
  /// — the counts are per-tender, not per-sale.
  final int cashCount;

  /// Number of completed sales contributing to [cardCents]. See [cashCount]
  /// for the per-tender semantics.
  final int cardCount;

  /// Number of completed sales contributing to [creditCents]. See
  /// [cashCount] for the per-tender semantics.
  final int creditCount;

  /// Number of sales actually counted (status='completed').
  final int includedCount;

  /// Number of sales skipped because status is voided / refunded / etc.
  /// Surface this in the UI so managers know the report excluded them.
  final int excludedCount;

  const PaymentBreakdown({
    required this.cashCents,
    required this.cardCents,
    required this.creditCents,
    required this.totalCents,
    required this.cashCount,
    required this.cardCount,
    required this.creditCount,
    required this.includedCount,
    required this.excludedCount,
  });

  /// Empty breakdown — useful as a starting accumulator or when the
  /// input list is empty.
  static const empty = PaymentBreakdown(
    cashCents: 0,
    cardCents: 0,
    creditCents: 0,
    totalCents: 0,
    cashCount: 0,
    cardCount: 0,
    creditCount: 0,
    includedCount: 0,
    excludedCount: 0,
  );

  // ─── SAR display accessors ──────────────────────────────────────
  // These exist for UI code that has historically worked in SAR doubles.
  // New code is encouraged to format from cents directly (CurrencyFormatter
  // can take cents) to avoid the double→cents drift that v45 cleaned up.
  double get cashSar => cashCents / 100.0;
  double get cardSar => cardCents / 100.0;
  double get creditSar => creditCents / 100.0;
  double get totalSar => totalCents / 100.0;

  @override
  String toString() =>
      'PaymentBreakdown(cash: $cashCents¢ × $cashCount, '
      'card: $cardCents¢ × $cardCount, '
      'credit: $creditCents¢ × $creditCount, '
      'total: $totalCents¢, '
      'included: $includedCount, excluded: $excludedCount)';
}

/// Status values that count as a real sale for revenue / payment reports.
/// Anything else (voided, refunded, draft, …) is excluded.
const _completedStatuses = {'completed', 'paid'};

/// Aggregator service — pure functions over [SalesTableData] lists.
class PaymentAggregator {
  const PaymentAggregator._();

  /// Bucket a list of sales into cash / card / credit breakdowns.
  ///
  /// Skips any row whose `status` isn't in [_completedStatuses] and reports
  /// the skip count via [PaymentBreakdown.excludedCount].
  static PaymentBreakdown aggregate(Iterable<SalesTableData> sales) {
    var cashCents = 0;
    var cardCents = 0;
    var creditCents = 0;
    var totalCents = 0;
    var cashCount = 0;
    var cardCount = 0;
    var creditCount = 0;
    var included = 0;
    var excluded = 0;

    for (final s in sales) {
      if (!_completedStatuses.contains(s.status)) {
        excluded++;
        continue;
      }
      included++;
      totalCents += s.total;

      final cash = s.cashAmount ?? 0;
      final card = s.cardAmount ?? 0;
      final credit = s.creditAmount ?? 0;

      if (cash > 0 || card > 0 || credit > 0) {
        // Multi-tender row — believe the split columns exactly. They
        // already carry int cents (post-v43 sales schema) and were
        // populated atomically with the sale by saleService.createSale.
        cashCents += cash;
        cardCents += card;
        creditCents += credit;
        if (cash > 0) cashCount++;
        if (card > 0) cardCount++;
        if (credit > 0) creditCount++;
      } else {
        // Legacy single-tender row (all three split columns null/zero).
        // Bucket by paymentMethod string — same semantics as the loops
        // we're replacing, but now consistent across all three reports.
        switch (s.paymentMethod) {
          case 'cash':
            cashCents += s.total;
            cashCount++;
          case 'card':
          case 'mada':
            cardCents += s.total;
            cardCount++;
          default:
            // 'credit', 'transfer', 'mixed' (with no splits — odd but
            // possible on legacy rows), unknown strings → credit bucket.
            // Matches payment_reports_screen pre-fix behaviour.
            creditCents += s.total;
            creditCount++;
        }
      }
    }

    return PaymentBreakdown(
      cashCents: cashCents,
      cardCents: cardCents,
      creditCents: creditCents,
      totalCents: totalCents,
      cashCount: cashCount,
      cardCount: cardCount,
      creditCount: creditCount,
      includedCount: included,
      excludedCount: excluded,
    );
  }
}
