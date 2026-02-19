/// Smart Offline Banner - شريط ذكي لحالة الاتصال
///
/// يعرض:
/// - حالة الاتصال الحالية
/// - عدد العمليات المعلقة
/// - مؤشر المزامنة
/// - إمكانية المزامنة اليدوية
library smart_offline_banner;

import 'dart:async';
import 'package:flutter/material.dart';
import '../../services/offline/offline_manager.dart';

/// شريط حالة الاتصال الذكي
class SmartOfflineBanner extends StatefulWidget {
  /// الـ widget الابن
  final Widget child;

  /// إظهار عدد العمليات المعلقة
  final bool showPendingCount;

  /// callback للمزامنة اليدوية
  final VoidCallback? onSyncPressed;

  /// مدة إظهار الشريط عند الاتصال
  final Duration onlineBannerDuration;

  const SmartOfflineBanner({
    super.key,
    required this.child,
    this.showPendingCount = true,
    this.onSyncPressed,
    this.onlineBannerDuration = const Duration(seconds: 3),
  });

  @override
  State<SmartOfflineBanner> createState() => _SmartOfflineBannerState();
}

class _SmartOfflineBannerState extends State<SmartOfflineBanner>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _slideAnimation;
  StreamSubscription<NetworkConnectionState>? _subscription;

  NetworkConnectionState _connectionState = OfflineManager.instance.state;
  bool _showOnlineBanner = false;
  Timer? _onlineBannerTimer;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _slideAnimation = Tween<double>(begin: -1, end: 0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOut,
      ),
    );

    _subscription = OfflineManager.instance.stateStream.listen(_onStateChanged);

    // إظهار الشريط إذا كنا offline
    if (_connectionState.isOffline) {
      _animationController.forward();
    }
  }

  @override
  void dispose() {
    _subscription?.cancel();
    _animationController.dispose();
    _onlineBannerTimer?.cancel();
    super.dispose();
  }

  void _onStateChanged(NetworkConnectionState state) {
    final wasOffline = _connectionState.isOffline;

    setState(() {
      _connectionState = state;
    });

    if (state.isOffline) {
      // أظهر شريط offline
      _showOnlineBanner = false;
      _onlineBannerTimer?.cancel();
      _animationController.forward();
    } else if (wasOffline && state.isOnline) {
      // عاد الاتصال - أظهر شريط online مؤقتاً
      setState(() {
        _showOnlineBanner = true;
      });

      _onlineBannerTimer?.cancel();
      _onlineBannerTimer = Timer(widget.onlineBannerDuration, () {
        if (mounted) {
          _animationController.reverse().then((_) {
            if (mounted) {
              setState(() {
                _showOnlineBanner = false;
              });
            }
          });
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // الشريط
        AnimatedBuilder(
          animation: _slideAnimation,
          builder: (context, child) {
            if (!_connectionState.isOffline && !_showOnlineBanner) {
              return const SizedBox.shrink();
            }

            return ClipRect(
              child: Align(
                alignment: Alignment.topCenter,
                heightFactor: _slideAnimation.value + 1,
                child: child,
              ),
            );
          },
          child: _buildBanner(),
        ),

        // المحتوى
        Expanded(child: widget.child),
      ],
    );
  }

  Widget _buildBanner() {
    if (_showOnlineBanner) {
      return _OnlineBanner();
    }

    return _OfflineBanner(
      pendingCount: widget.showPendingCount ? _connectionState.pendingSyncCount : 0,
      connectionType: _connectionState.type,
      onSyncPressed: widget.onSyncPressed,
    );
  }
}

/// شريط عدم الاتصال
class _OfflineBanner extends StatelessWidget {
  final int pendingCount;
  final NetworkConnectionType connectionType;
  final VoidCallback? onSyncPressed;

  const _OfflineBanner({
    required this.pendingCount,
    required this.connectionType,
    this.onSyncPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.orange[800],
      child: SafeArea(
        bottom: false,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              const Icon(
                Icons.wifi_off,
                color: Colors.white,
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'لا يوجد اتصال بالإنترنت',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                    if (pendingCount > 0)
                      Text(
                        '$pendingCount عملية في انتظار المزامنة',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.9),
                          fontSize: 11,
                        ),
                      ),
                  ],
                ),
              ),
              if (onSyncPressed != null && pendingCount > 0)
                TextButton.icon(
                  onPressed: onSyncPressed,
                  icon: const Icon(Icons.sync, size: 16),
                  label: const Text('مزامنة'),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// شريط عودة الاتصال
class _OnlineBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.green[700],
      child: SafeArea(
        bottom: false,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.wifi,
                color: Colors.white,
                size: 20,
              ),
              SizedBox(width: 8),
              Text(
                'تم استعادة الاتصال',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Widget صغير لعرض حالة الاتصال (للـ AppBar مثلاً)
class ConnectionStatusIndicator extends StatefulWidget {
  final double size;
  final bool showLabel;

  const ConnectionStatusIndicator({
    super.key,
    this.size = 12,
    this.showLabel = false,
  });

  @override
  State<ConnectionStatusIndicator> createState() => _ConnectionStatusIndicatorState();
}

class _ConnectionStatusIndicatorState extends State<ConnectionStatusIndicator> {
  StreamSubscription<NetworkConnectionState>? _subscription;
  NetworkConnectionState _state = OfflineManager.instance.state;

  @override
  void initState() {
    super.initState();
    _subscription = OfflineManager.instance.stateStream.listen((state) {
      if (mounted) {
        setState(() => _state = state);
      }
    });
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isOnline = _state.isOnline;
    final color = isOnline ? Colors.green : Colors.orange;

    if (widget.showLabel) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: widget.size,
            height: widget.size,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            isOnline ? 'متصل' : 'غير متصل',
            style: TextStyle(
              fontSize: 12,
              color: color,
            ),
          ),
          if (!isOnline && _state.pendingSyncCount > 0) ...[
            const SizedBox(width: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.orange[100],
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '${_state.pendingSyncCount}',
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.orange[800],
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ],
      );
    }

    return Container(
      width: widget.size,
      height: widget.size,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.5),
            blurRadius: 4,
            spreadRadius: 1,
          ),
        ],
      ),
    );
  }
}
