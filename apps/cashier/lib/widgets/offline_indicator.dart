import 'dart:async';
import 'package:flutter/material.dart';

import '../services/connectivity_service.dart';
import '../services/offline_queue_service.dart';

/// Compact indicator widget that shows offline status and pending sync count.
///
/// States:
///   - **Green** chip: online, all synced (hidden by default, see [alwaysShow]).
///   - **Amber** chip: online, pending operations waiting to sync.
///   - **Red** banner: offline, shows pending count.
///
/// All user-facing strings are in Arabic.
class OfflineIndicator extends StatefulWidget {
  /// When `true`, the widget is always visible (even when online and synced).
  /// When `false` (default), it hides when online and fully synced.
  final bool alwaysShow;

  const OfflineIndicator({super.key, this.alwaysShow = false});

  @override
  State<OfflineIndicator> createState() => _OfflineIndicatorState();
}

class _OfflineIndicatorState extends State<OfflineIndicator> {
  late final ConnectivityService _connectivity;
  late final OfflineQueueService _queue;

  StreamSubscription<bool>? _connectivitySub;
  Timer? _pollTimer;

  bool _isOnline = true;
  int _pendingCount = 0;

  @override
  void initState() {
    super.initState();
    _connectivity = ConnectivityService.instance;
    _queue = OfflineQueueService.instance;

    _isOnline = _connectivity.isOnline;
    _refreshPendingCount();

    // Listen for connectivity changes
    _connectivitySub = _connectivity.onConnectivityChanged.listen((online) {
      if (mounted) {
        setState(() => _isOnline = online);
        _refreshPendingCount();
      }
    });

    // Poll pending count every 5 seconds (items get flushed asynchronously)
    _pollTimer = Timer.periodic(
      const Duration(seconds: 5),
      (_) => _refreshPendingCount(),
    );
  }

  @override
  void dispose() {
    _connectivitySub?.cancel();
    _pollTimer?.cancel();
    super.dispose();
  }

  Future<void> _refreshPendingCount() async {
    final count = await _queue.pendingCount();
    if (mounted && count != _pendingCount) {
      setState(() => _pendingCount = count);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Hide when online, synced, and alwaysShow is false
    if (!widget.alwaysShow && _isOnline && _pendingCount == 0) {
      return const SizedBox.shrink();
    }

    // Determine state
    final Color backgroundColor;
    final Color foregroundColor;
    final IconData icon;
    final String label;

    if (!_isOnline) {
      // Offline -- red
      backgroundColor = isDark
          ? Colors.red.shade900.withValues(alpha: 0.8)
          : Colors.red.shade50;
      foregroundColor = isDark ? Colors.red.shade200 : Colors.red.shade800;
      icon = Icons.wifi_off_rounded;
      label = _pendingCount > 0
          ? 'غير متصل -- $_pendingCount عمليات في الانتظار'
          : 'غير متصل';
    } else if (_pendingCount > 0) {
      // Online but pending -- amber
      backgroundColor = isDark
          ? Colors.amber.shade900.withValues(alpha: 0.8)
          : Colors.amber.shade50;
      foregroundColor = isDark ? Colors.amber.shade200 : Colors.amber.shade900;
      icon = Icons.sync_rounded;
      label = '$_pendingCount عمليات في الانتظار';
    } else {
      // Online and synced -- green
      backgroundColor = isDark
          ? Colors.green.shade900.withValues(alpha: 0.8)
          : Colors.green.shade50;
      foregroundColor = isDark ? Colors.green.shade200 : Colors.green.shade800;
      icon = Icons.cloud_done_rounded;
      label = 'تمت المزامنة';
    }

    return AnimatedSize(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeInOut,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: foregroundColor),
            const SizedBox(width: 6),
            Text(
              label,
              style: theme.textTheme.labelSmall?.copyWith(
                color: foregroundColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
