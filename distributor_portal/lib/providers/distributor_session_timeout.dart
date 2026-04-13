/// Session timeout management (30 min idle).
library;

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:alhai_l10n/alhai_l10n.dart';

import '../core/services/sentry_service.dart';
import '../core/supabase/supabase_client.dart';
import 'distributor_auth_providers.dart';
import 'distributor_datasource_provider.dart';

// ─── Session Timeout (30 min idle) ─────────────────────────────

/// Duration before an idle session is automatically logged out.
const Duration sessionTimeoutDuration = Duration(minutes: 30);

/// Manages activity-based session timeout.
/// Call [recordActivity] on user interactions (taps, navigation, etc.).
/// When idle for [sessionTimeoutDuration], fires [onTimeout].
class SessionTimeoutManager {
  SessionTimeoutManager({required this.onTimeout});

  final VoidCallback onTimeout;
  Timer? _timer;

  /// Record user activity and reset the idle timer.
  void recordActivity() {
    _timer?.cancel();
    _timer = Timer(sessionTimeoutDuration, _handleTimeout);
  }

  void _handleTimeout() {
    onTimeout();
  }

  /// Start the idle timer. Call after login.
  void start() {
    recordActivity();
  }

  /// Stop and clean up the timer. Call on logout or dispose.
  void dispose() {
    _timer?.cancel();
    _timer = null;
  }
}

/// A widget that wraps the app to detect user activity and enforce session timeout.
class SessionTimeoutWrapper extends ConsumerStatefulWidget {
  final Widget child;

  const SessionTimeoutWrapper({super.key, required this.child});

  @override
  ConsumerState<SessionTimeoutWrapper> createState() =>
      _SessionTimeoutWrapperState();
}

class _SessionTimeoutWrapperState extends ConsumerState<SessionTimeoutWrapper> {
  late final SessionTimeoutManager _manager;
  bool _isTimerRunning = false;

  @override
  void initState() {
    super.initState();
    _manager = SessionTimeoutManager(onTimeout: _onSessionTimeout);
    // Start only if authenticated
    if (AppSupabase.isAuthenticated) {
      _manager.start();
      _isTimerRunning = true;
    }
  }

  @override
  void dispose() {
    _manager.dispose();
    _isTimerRunning = false;
    super.dispose();
  }

  void _onSessionTimeout() {
    if (!mounted) return;
    // Clear datasource cache
    try {
      ref.read(distributorDatasourceProvider).clearCache();
    } catch (e, stack) {
      reportError(e, stackTrace: stack, hint: 'session_timeout: clearCache');
    }
    // Sign out with error handling
    try {
      AppSupabase.client.auth.signOut();
      addBreadcrumb(
        message: 'Session timed out after inactivity',
        category: 'auth',
      );
    } catch (e, stack) {
      reportError(e, stackTrace: stack, hint: 'session_timeout: signOut');
    }
    // Navigate to login (use a post-frame callback to avoid issues)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final l10n = AppLocalizations.of(context);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.distributorSessionExpired)));
    });
  }

  @override
  Widget build(BuildContext context) {
    // Watch auth state to start/stop timer — guarded to avoid repeated side effects
    ref.listen<AsyncValue<AuthState>>(authStateProvider, (previous, next) {
      next.whenData((state) {
        if (state.event == AuthChangeEvent.signedIn && !_isTimerRunning) {
          _manager.start();
          _isTimerRunning = true;
        } else if (state.event == AuthChangeEvent.signedOut &&
            _isTimerRunning) {
          _manager.dispose();
          _isTimerRunning = false;
        }
      });
    });

    return Listener(
      onPointerDown: (_) => _manager.recordActivity(),
      onPointerMove: (_) => _manager.recordActivity(),
      behavior: HitTestBehavior.translucent,
      child: widget.child,
    );
  }
}
