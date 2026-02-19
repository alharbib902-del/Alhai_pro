import 'package:flutter/material.dart';
import 'dart:async';
import '../l10n/generated/app_localizations.dart';

/// ويدجت مؤشر حالة الاتصال (Offline Indicator)
class OfflineIndicator extends StatefulWidget {
  final Widget child;
  const OfflineIndicator({super.key, required this.child});

  @override
  State<OfflineIndicator> createState() => _OfflineIndicatorState();
}

class _OfflineIndicatorState extends State<OfflineIndicator> {
  bool _isOnline = true;
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    // Check connectivity periodically
    _timer = Timer.periodic(const Duration(seconds: 5), (_) => _checkConnectivity());
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  Future<void> _checkConnectivity() async {
    // TODO: Implement real connectivity check
    // For now, simulate online status
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      children: [
        // Offline banner
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          height: _isOnline ? 0 : 36,
          color: Colors.red.shade600,
          child: _isOnline
              ? null
              : Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () => _showOfflineDialog(context),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.cloud_off, color: Colors.white, size: 16),
                          const SizedBox(width: 8),
                          Text(l10n.offlineSavingLocally, style: const TextStyle(color: Colors.white, fontSize: 13)),
                        ],
                      ),
                    ),
                  ),
                ),
        ),
        // Main content
        Expanded(child: widget.child),
      ],
    );
  }

  void _showOfflineDialog(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.cloud_off, color: Colors.red.shade600),
            const SizedBox(width: 12),
            Text(l10n.offlineModeTitle),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.offlineModeDescription),
            const SizedBox(height: 12),
            Text('✓ ${l10n.offlineCanSell}', style: const TextStyle(color: Colors.green)),
            Text('✓ ${l10n.offlineCanAddToCart}', style: const TextStyle(color: Colors.green)),
            Text('✓ ${l10n.offlineCanPrint}', style: const TextStyle(color: Colors.green)),
            const SizedBox(height: 12),
            Text(l10n.offlineAutoSync),
          ],
        ),
        actions: [
          FilledButton(onPressed: () => Navigator.pop(context), child: Text(l10n.gotIt)),
        ],
      ),
    );
  }
}

/// شريط حالة Sync صغير للشاشات
class SyncStatusBar extends StatelessWidget {
  final int pendingCount;
  final bool isOnline;
  final VoidCallback? onTap;

  const SyncStatusBar({
    super.key,
    this.pendingCount = 0,
    this.isOnline = true,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    if (isOnline && pendingCount == 0) return const SizedBox.shrink();

    final l10n = AppLocalizations.of(context)!;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isOnline ? Colors.amber : Colors.red,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isOnline ? Icons.sync : Icons.cloud_off,
              color: Colors.white,
              size: 14,
            ),
            const SizedBox(width: 6),
            Text(
              isOnline ? '$pendingCount ${l10n.pending}' : l10n.offline,
              style: const TextStyle(color: Colors.white, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}
