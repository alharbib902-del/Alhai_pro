/// P0-13: Credit Limit Enforcement.
///
/// Pre-flight check before any code path that increases a receivable
/// account's balance — three call sites today:
///   - `payment_screen.dart` (POS credit / mixed-tender sale)
///   - `create_invoice_screen.dart` (B2B credit invoice)
///   - `new_transaction_screen.dart` (manual debt entry)
///
/// **Why a dedicated service:** the check is identical across the three
/// flows (read account → compare projected new balance vs. limit → emit
/// one of {ok, warning, exceeded}), but the data conversions are subtle
/// (cents vs. SAR, signed delta vs. absolute amount) and easy to get
/// wrong if each screen rolls its own. Centralising avoids three near-
/// identical bugs.
library;

import 'package:alhai_database/alhai_database.dart';

/// Result of a credit-limit check. The screens act on the kind:
///   - `ok` / `noLimitSet` — proceed silently.
///   - `warning` — proceed but show a non-blocking warning toast (the
///     account is past 90% of its limit but still under it).
///   - `exceeded` — block by default. The screen may offer a manager-
///     PIN override; if granted, audit-log the override and proceed.
sealed class CreditCheckResult {
  const CreditCheckResult();

  /// Account has no configured limit (or limit == 0). Per Wave 3b-2b
  /// follow-up D1, "no limit set" means the cashier is unrestricted —
  /// keep historical behaviour rather than silently blocking every
  /// credit sale on accounts that were never configured.
  const factory CreditCheckResult.noLimitSet() = NoLimitSet;

  /// New balance comfortably under the limit. Proceed without UI.
  const factory CreditCheckResult.ok({
    required int currentBalanceCents,
    required int limitCents,
    required int newBalanceCents,
  }) = CreditCheckOk;

  /// New balance ≥ 90% of limit but still under it. Proceed but the
  /// caller SHOULD show a toast ("Customer is at X% of their limit").
  const factory CreditCheckResult.warning({
    required int currentBalanceCents,
    required int limitCents,
    required int newBalanceCents,
    required double utilisation,
  }) = CreditCheckWarning;

  /// New balance > limit. Caller MUST block by default; manager
  /// override may unblock with audit log.
  const factory CreditCheckResult.exceeded({
    required int currentBalanceCents,
    required int limitCents,
    required int newBalanceCents,
    required int overByCents,
  }) = CreditCheckExceeded;

  /// True for [CreditCheckExceeded] only — convenience for callers.
  bool get isBlocked => this is CreditCheckExceeded;

  /// True for [CreditCheckWarning] only.
  bool get isWarning => this is CreditCheckWarning;
}

/// `CreditCheckResult.noLimitSet()`
final class NoLimitSet extends CreditCheckResult {
  const NoLimitSet();
}

/// New balance well under the limit.
final class CreditCheckOk extends CreditCheckResult {
  final int currentBalanceCents;
  final int limitCents;
  final int newBalanceCents;
  const CreditCheckOk({
    required this.currentBalanceCents,
    required this.limitCents,
    required this.newBalanceCents,
  });
}

/// New balance has crossed the warning threshold (default 90%).
final class CreditCheckWarning extends CreditCheckResult {
  final int currentBalanceCents;
  final int limitCents;
  final int newBalanceCents;
  final double utilisation;
  const CreditCheckWarning({
    required this.currentBalanceCents,
    required this.limitCents,
    required this.newBalanceCents,
    required this.utilisation,
  });
}

/// New balance would exceed the limit. Manager PIN override required.
final class CreditCheckExceeded extends CreditCheckResult {
  final int currentBalanceCents;
  final int limitCents;
  final int newBalanceCents;
  final int overByCents;
  const CreditCheckExceeded({
    required this.currentBalanceCents,
    required this.limitCents,
    required this.newBalanceCents,
    required this.overByCents,
  });
}

/// Pre-flight credit-limit check service.
///
/// Pure: never writes, never throws on a "not found" lookup (returns
/// [CreditCheckResult.noLimitSet] so a missing account doesn't crash
/// the cashier flow — the downstream insert will fail loudly anyway).
class CreditLimitEnforcer {
  final AppDatabase _db;

  /// Warning threshold expressed as a fraction of the limit. Default
  /// 0.9 (warn when projected balance ≥ 90% of limit). Wave-time
  /// owner decision (D3); kept configurable for store-specific tuning
  /// in a future wave without changing this API.
  final double warningThreshold;

  CreditLimitEnforcer({
    required AppDatabase db,
    this.warningThreshold = 0.9,
  }) : _db = db;

  /// Check a proposed change to a customer's receivable balance.
  ///
  /// [accountId] is the receivable account ID (from `accounts` table).
  /// [proposedDeltaCents] is the signed amount that will be added to
  /// `balance` — positive for new debt (sale, invoice, manual entry),
  /// negative for payments. The check only blocks positive deltas; a
  /// payment can never push a balance over its limit, so it returns
  /// [CreditCheckResult.ok] regardless.
  Future<CreditCheckResult> check({
    required String accountId,
    required int proposedDeltaCents,
  }) async {
    final account = await _db.accountsDao.getAccountById(accountId);
    // Missing account = unrestricted. The downstream write will fail
    // with a foreign-key error and surface there.
    if (account == null) return const CreditCheckResult.noLimitSet();

    return _evaluate(
      currentBalance: account.balance,
      limit: account.creditLimit,
      proposedDelta: proposedDeltaCents,
    );
  }

  /// Variant for the create-invoice + payment-screen flows where the
  /// caller has the customer ID but no pre-fetched account row.
  /// Resolves the receivable account for `(customerId, storeId)`.
  Future<CreditCheckResult> checkByCustomer({
    required String customerId,
    required String storeId,
    required int proposedDeltaCents,
  }) async {
    final account = await _db.accountsDao.getCustomerAccount(
      customerId,
      storeId,
    );
    if (account == null) return const CreditCheckResult.noLimitSet();
    return _evaluate(
      currentBalance: account.balance,
      limit: account.creditLimit,
      proposedDelta: proposedDeltaCents,
    );
  }

  /// Pure decision function — extracted so unit tests can exercise the
  /// branches without hitting Drift.
  CreditCheckResult _evaluate({
    required int currentBalance,
    required int limit,
    required int proposedDelta,
  }) {
    // Limit of zero (or unset) = unrestricted, per D1 default.
    if (limit <= 0) return const CreditCheckResult.noLimitSet();

    // Payments / refunds reduce balance — they can't breach a positive
    // limit. Skip the projection math.
    if (proposedDelta <= 0) {
      return CreditCheckResult.ok(
        currentBalanceCents: currentBalance,
        limitCents: limit,
        newBalanceCents: currentBalance + proposedDelta,
      );
    }

    final newBalance = currentBalance + proposedDelta;

    if (newBalance > limit) {
      return CreditCheckResult.exceeded(
        currentBalanceCents: currentBalance,
        limitCents: limit,
        newBalanceCents: newBalance,
        overByCents: newBalance - limit,
      );
    }

    final utilisation = newBalance / limit;
    if (utilisation >= warningThreshold) {
      return CreditCheckResult.warning(
        currentBalanceCents: currentBalance,
        limitCents: limit,
        newBalanceCents: newBalance,
        utilisation: utilisation,
      );
    }

    return CreditCheckResult.ok(
      currentBalanceCents: currentBalance,
      limitCents: limit,
      newBalanceCents: newBalance,
    );
  }
}
