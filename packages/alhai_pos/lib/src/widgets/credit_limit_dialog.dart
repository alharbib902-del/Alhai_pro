/// P0-13: Credit-limit dialog helpers used by the 3 screens that
/// create receivable obligations (POS payment, credit invoice, manual
/// debt entry).
///
/// Two flows:
///   - `showCreditLimitWarning(...)` — non-blocking toast, returns void.
///   - `showCreditLimitExceededDialog(...)` — blocking modal with two
///     buttons: cancel (returns false) or "override with manager
///     approval" (chains into the standard PIN dialog and returns
///     true on success). The caller is responsible for writing the
///     audit-log row when this returns true.
library;

import 'package:flutter/material.dart';
import 'package:alhai_auth/alhai_auth.dart' show ManagerApprovalScreen;
import 'package:alhai_design_system/alhai_design_system.dart'
    show AlhaiSnackbar;
import 'package:alhai_l10n/alhai_l10n.dart';

import '../services/credit_limit_enforcer.dart';

/// Show the warning snackbar for an account at or past the warning
/// threshold (default 90% of limit). Non-blocking.
void showCreditLimitWarning(BuildContext context, CreditCheckWarning result) {
  final l10n = AppLocalizations.of(context);
  final percent = (result.utilisation * 100).round();
  AlhaiSnackbar.warning(
    context,
    l10n.creditLimitWarningSnackbar(percent),
  );
}

/// Show the blocking "limit exceeded" dialog. Returns:
///   - `false` if the cashier dismisses, picks Cancel, or fails the
///     manager-PIN check.
///   - `true` if a manager PIN is verified — the caller MUST then
///     audit-log the override (see `auditService.logCreditLimitOverride`
///     in the cashier app, or the equivalent in alhai_pos integrations).
Future<bool> showCreditLimitExceededDialog(
  BuildContext context,
  CreditCheckExceeded result,
) async {
  final l10n = AppLocalizations.of(context);

  final newBalanceSar = (result.newBalanceCents / 100).toStringAsFixed(2);
  final limitSar = (result.limitCents / 100).toStringAsFixed(2);
  final overBySar = (result.overByCents / 100).toStringAsFixed(2);

  final action = await showDialog<_CreditLimitChoice>(
    context: context,
    barrierDismissible: false,
    builder: (ctx) => AlertDialog(
      icon: const Icon(Icons.warning_amber_rounded, size: 48),
      title: Text(l10n.creditLimitExceededTitle),
      content: Text(
        l10n.creditLimitExceededBody(newBalanceSar, limitSar, overBySar),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(_CreditLimitChoice.cancel),
          child: Text(l10n.creditLimitBlockButton),
        ),
        FilledButton(
          onPressed: () => Navigator.of(ctx).pop(_CreditLimitChoice.override),
          child: Text(l10n.creditLimitOverrideButton),
        ),
      ],
    ),
  );

  if (action != _CreditLimitChoice.override) return false;
  if (!context.mounted) return false;

  // Hand off to the standard PIN-backed approval flow — same dialog
  // used for void_sale, refund, and the other protected actions, so
  // store managers don't have to learn a new UI.
  return ManagerApprovalScreen.showApprovalDialog(
    context,
    action: l10n.creditLimitOverrideAction,
  );
}

enum _CreditLimitChoice { cancel, override }
