import 'package:flutter/material.dart';
import 'package:alhai_l10n/alhai_l10n.dart';

import '../../core/services/sentry_service.dart';

/// Error display for Super Admin screens.
///
/// Shows a sanitized, localized message to the user and captures the
/// underlying exception to Sentry. The [error] parameter is NEVER
/// rendered — it exists only so operators can debug the root cause
/// while users see a clean message.
///
/// Stateful rather than stateless so the Sentry capture fires once
/// in [initState] instead of on every rebuild.
class SAErrorCard extends StatefulWidget {
  final Object error;
  final StackTrace? stackTrace;
  final bool flat;

  const SAErrorCard({
    super.key,
    required this.error,
    this.stackTrace,
    this.flat = false,
  });

  @override
  State<SAErrorCard> createState() => _SAErrorCardState();
}

class _SAErrorCardState extends State<SAErrorCard> {
  @override
  void initState() {
    super.initState();
    reportError(
      widget.error,
      stackTrace: widget.stackTrace,
      hint: 'SAErrorCard rendered',
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context);

    final content = Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.error_outline, size: 48, color: colorScheme.error),
          const SizedBox(height: 12),
          Text(
            l10n.saErrorLoading,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: colorScheme.onSurface,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );

    if (widget.flat) {
      return Center(child: content);
    }

    return Center(
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: colorScheme.outlineVariant),
        ),
        child: content,
      ),
    );
  }
}
