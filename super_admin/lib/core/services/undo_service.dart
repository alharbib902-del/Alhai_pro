import 'dart:async';
import 'package:flutter/material.dart';

/// Represents an undoable action
class UndoableAction {
  final String description;
  final Future<void> Function() undoCallback;
  final DateTime createdAt;
  Timer? _expiryTimer;

  UndoableAction({required this.description, required this.undoCallback})
    : createdAt = DateTime.now();

  void startExpiry(Duration duration, VoidCallback onExpired) {
    _expiryTimer = Timer(duration, onExpired);
  }

  void cancel() {
    _expiryTimer?.cancel();
  }
}

/// Service to manage undo operations with SnackBar integration
class UndoService {
  static const _undoDuration = Duration(seconds: 8);

  /// Execute a destructive action with undo capability
  static Future<void> executeWithUndo({
    required BuildContext context,
    required String description,
    required Future<void> Function() action,
    required Future<void> Function() undoAction,
    IconData icon = Icons.delete_rounded,
  }) async {
    // Execute the action
    await action();

    if (!context.mounted) return;

    // Show SnackBar with undo button
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Expanded(child: Text(description)),
          ],
        ),
        duration: _undoDuration,
        action: SnackBarAction(
          label: '\u062a\u0631\u0627\u062c\u0639',
          textColor: Colors.amber,
          onPressed: () async {
            try {
              await undoAction();
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      '\u062a\u0645 \u0627\u0644\u062a\u0631\u0627\u062c\u0639 \u0639\u0646: $description',
                    ),
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    duration: const Duration(seconds: 2),
                  ),
                );
              }
            } catch (e) {
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      '\u0641\u0634\u0644 \u0627\u0644\u062a\u0631\u0627\u062c\u0639: $e',
                    ),
                    backgroundColor: Theme.of(context).colorScheme.error,
                  ),
                );
              }
            }
          },
        ),
      ),
    );
  }
}
