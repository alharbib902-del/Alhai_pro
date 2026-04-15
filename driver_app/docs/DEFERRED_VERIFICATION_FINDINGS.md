# Deferred Verification Findings — C3+C4 Phase 5

## V2 (LOW): _accept() race condition
**Source:** Phase 5 verification 2026-04-15
**Status:** DEFERRED

**Problem:** `_accept()` in `new_order_screen.dart` doesn't guard on `_isLoading`.
Theoretical race with auto-reject if tap event queued before timer fires.

**Risk:** Very low — Dart single-threaded, window < 1 frame.
Server-side state machine should be authoritative.

**Fix when revisited:**
- Add `if (_isLoading) return;` at top of `_accept()`
- Effort: 5 minutes

## V3 (LOW): Timer not nullified
**Source:** Phase 5 verification 2026-04-15
**Status:** DEFERRED

**Problem:** When `assigned.isEmpty`, `_countdownTimer` is cancelled but not
nullified. `_ensureCountdownStarted` sees non-null timer and returns early
if delivery reappears.

**Risk:** Edge case — delivery disappears then reappears mid-countdown.
Unlikely in production.

**Fix when revisited:**
- Set `_countdownTimer = null` after cancel
- Effort: 2 minutes

## V4 (LOW): Background location stream no isMocked check
**Source:** Phase 5 verification 2026-04-15
**Status:** DEFERRED

**Problem:** `getPositionStream()` doesn't check `isMocked`. Background
tracking can use mock positions.

**Risk:** LOW — affects tracking data shown to customer, not status
transitions. Status transitions remain protected.

**Fix when revisited:**
- Add isMocked filter to stream
- Or document as accepted risk
- Effort: 30 minutes
