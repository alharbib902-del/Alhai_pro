/// Session timeout manager — auto-locks app after inactivity.
///
/// Tracks user interaction (taps, keyboard, mouse) and triggers
/// a session timeout redirect after [kSessionTimeoutMinutes] of inactivity.
library;

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:alhai_auth/alhai_auth.dart' show authStateProvider, AuthStatus;

/// Inactivity timeout duration
const kSessionTimeoutMinutes = 15;

/// Provider for the session manager
final sessionManagerProvider = Provider<SessionManager>((ref) {
  return SessionManager(ref);
});

/// Manages inactivity timeout. Wrap the app body with [SessionTimeoutWrapper]
/// to automatically reset on user interaction.
class SessionManager {
  SessionManager(this._ref);

  final Ref _ref;
  Timer? _timer;
  bool _isLocked = false;

  bool get isLocked => _isLocked;

  /// Start or restart the inactivity timer
  void resetTimer() {
    _timer?.cancel();

    // Only run when authenticated
    final authState = _ref.read(authStateProvider);
    if (authState.status != AuthStatus.authenticated) return;

    _timer = Timer(
      const Duration(minutes: kSessionTimeoutMinutes),
      _onTimeout,
    );
  }

  /// Called when the timer expires
  void _onTimeout() {
    _isLocked = true;
    // Trigger auth state change to unauthenticated / session expired
    // The router guard will redirect to login automatically
    // Use logout which clears tokens and sets state to unauthenticated.
    // The router guard will redirect to login automatically.
    _ref.read(authStateProvider.notifier).logout();
  }

  /// Unlock after re-authentication
  void unlock() {
    _isLocked = false;
    resetTimer();
  }

  /// Stop tracking (e.g. on logout)
  void dispose() {
    _timer?.cancel();
    _timer = null;
    _isLocked = false;
  }
}

/// Wraps child widget to detect user interaction and reset the session timer.
class SessionTimeoutWrapper extends ConsumerStatefulWidget {
  final Widget child;

  const SessionTimeoutWrapper({super.key, required this.child});

  @override
  ConsumerState<SessionTimeoutWrapper> createState() =>
      _SessionTimeoutWrapperState();
}

class _SessionTimeoutWrapperState extends ConsumerState<SessionTimeoutWrapper>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // Start the timer on first load
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(sessionManagerProvider).resetTimer();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final sm = ref.read(sessionManagerProvider);
    if (state == AppLifecycleState.resumed) {
      // When app comes back to foreground, check if timer already expired
      sm.resetTimer();
    }
  }

  void _onUserInteraction() {
    ref.read(sessionManagerProvider).resetTimer();
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: (_) => _onUserInteraction(),
      onPointerMove: (_) => _onUserInteraction(),
      behavior: HitTestBehavior.translucent,
      child: widget.child,
    );
  }
}
