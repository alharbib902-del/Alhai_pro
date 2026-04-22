/// Shared confirmation dialog for destructive delete actions.
///
/// Use this instead of calling a delete method directly from a button.
/// Returns `true` when the user confirms, `false` otherwise (cancel /
/// dismissed). Never returns null.
library;

import 'package:flutter/material.dart';
import 'package:alhai_design_system/alhai_design_system.dart';
import 'package:alhai_l10n/alhai_l10n.dart';

/// Shows the standard "Delete <name>?" confirmation dialog.
///
/// ```dart
/// if (!await confirmDelete(context, itemName: coupon.code)) return;
/// await deleteCoupon(ref, coupon.id);
/// ```
Future<bool> confirmDelete(
  BuildContext context, {
  required String itemName,
}) async {
  final l10n = AppLocalizations.of(context);
  final result = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(l10n.deleteConfirmTitle),
      content: Text(l10n.confirmDeleteItemMessage(itemName)),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx, false),
          child: Text(l10n.cancel),
        ),
        TextButton(
          onPressed: () => Navigator.pop(ctx, true),
          style: TextButton.styleFrom(foregroundColor: AppColors.error),
          child: Text(l10n.delete),
        ),
      ],
    ),
  );
  return result ?? false;
}
