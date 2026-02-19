import 'package:flutter/material.dart';
import 'dart:async';

/// ويدجت مؤشر حالة الاتصال (Offline Indicator)
class OfflineIndicator extends StatefulWidget {
  final Widget child;
  const OfflineIndicator({super.key, required this.child});

  @override
  State<OfflineIndicator> createState() => _OfflineIndicatorState();
}

class _OfflineIndicatorState extends State<OfflineIndicator> {
  final bool _isOnline = true;
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
                    child: const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.cloud_off, color: Colors.white, size: 16),
                          SizedBox(width: 8),
                          Text('غير متصل - يتم حفظ العمليات محلياً', style: TextStyle(color: Colors.white, fontSize: 13)),
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
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.cloud_off, color: Colors.red.shade600),
            const SizedBox(width: 12),
            const Text('الوضع غير المتصل'),
          ],
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('يمكنك الاستمرار في استخدام التطبيق:'),
            SizedBox(height: 12),
            Text('✓ إجراء عمليات البيع', style: TextStyle(color: Colors.green)),
            Text('✓ إضافة منتجات للسلة', style: TextStyle(color: Colors.green)),
            Text('✓ طباعة الإيصالات', style: TextStyle(color: Colors.green)),
            SizedBox(height: 12),
            Text('سيتم مزامنة البيانات تلقائياً عند عودة الاتصال.'),
          ],
        ),
        actions: [
          FilledButton(onPressed: () => Navigator.pop(context), child: const Text('فهمت')),
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
              isOnline ? '$pendingCount معلق' : 'غير متصل',
              style: const TextStyle(color: Colors.white, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}
