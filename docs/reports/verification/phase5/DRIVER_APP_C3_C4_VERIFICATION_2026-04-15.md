# Driver App C3+C4 Independent Verification

**Date:** 2026-04-15
**Verifier:** Claude (independent — did not participate in C3/C4 fixes)
**Branch:** fix/phase5-driver-app
**Scope:** C3 (Mock GPS Detection) + C4 (Order Acceptance Timeout) only
**Tests:** 104 passing | Analyzer: clean (1 pre-existing info lint, unrelated)

---

## Executive Summary

C4 (Timeout) is solid — correct timer lifecycle, auto-reject, cleanup, and real widget tests.
C3 (Mock GPS) core mechanism works, but a **ghost bug** exists: the delivery proof screen
bypasses the mock GPS guard entirely, making the `delivered` status check dead code in
the normal app flow. Conditional approval pending one fix.

---

## C3 Verification — Mock GPS Detection

### Status: :yellow_circle: CONDITIONAL

### What Works

| Check | Result | Evidence |
|-------|--------|----------|
| `getVerifiedPosition()` checks `isMocked` | :white_check_mark: | `location_service.dart:114` |
| `MockGpsDetectedException` with position data | :white_check_mark: | `location_service.dart:140-149` |
| Shift start blocked | :white_check_mark: | `shifts_providers.dart:31` calls `getVerifiedPosition()` before `startShift()` |
| Status transitions blocked | :white_check_mark: | `delivery_action_buttons.dart:38-43` guards `arrivedAtPickup`, `pickedUp`, `arrivedAtCustomer`, `delivered` |
| Audit log to Supabase | :white_check_mark: | `delivery_datasource.dart:417-435` inserts to `audit_log` table |
| User-facing Arabic error | :white_check_mark: | `location_service.dart:146` + `delivery_action_buttons.dart:69-74` SnackBar |
| iOS documented limitation | :white_check_mark: | `isMocked` always false on iOS — noted in code comments and commit message |
| Unit tests use real class | :white_check_mark: | `mock_gps_detection_test.dart` uses real `LocationService` with mocked `GeolocatorPlatform` |

### Ghost Bug Found: Delivery Proof Screen Bypass

**Severity: MEDIUM**
**File:** `delivery_proof_screen.dart:140`

**The bypass path:**

1. `order_details_screen.dart:143` — `onProofRequired` is **always set** to navigate to proof screen
2. User at `arrivedAtCustomer` presses "confirm delivery":
   - `delivery_action_buttons.dart:228` → calls `onProofRequired!()` **instead of** `_updateStatus`
   - Navigates to `DeliveryProofScreen`
3. `delivery_proof_screen.dart:140` → uses **`getCurrentPosition()`** (no mock GPS check!)
4. `delivery_proof_screen.dart:158-163` → calls `updateDeliveryStatusProvider` with `delivered`

**Result:** The mock GPS guard for `DeliveryStatus.delivered` in `_mockGpsGuardedStatuses` is
**dead code** in the normal flow. Every real delivery completion goes through the proof screen,
which bypasses the guard entirely.

**Fix required:** In `delivery_proof_screen.dart:140`, replace `getCurrentPosition()` with
`getVerifiedPosition()` and handle `MockGpsDetectedException` (show error, block submission).

### Additional Observations (LOW)

1. **`getPositionStream()` has no isMocked check** (`location_service.dart:73`) — background
   location tracking could use mocked positions. Severity LOW: tracking data, not status transitions.
2. **`catch (_)` allows transition on non-mock GPS errors** (`delivery_action_buttons.dart:78`) —
   documented design choice: if location fetch fails for non-mock reasons, allow the transition.
   Acceptable trade-off.

---

## C4 Verification — Order Acceptance Timeout

### Status: :white_check_mark: APPROVED

### What Works

| Check | Result | Evidence |
|-------|--------|----------|
| 30s configurable countdown | :white_check_mark: | `new_order_screen.dart:20` `timeoutSeconds = 30`, exposed for testing |
| `Timer.periodic` each second | :white_check_mark: | `new_order_screen.dart:51` |
| Auto-reject with `notes: 'timeout'` | :white_check_mark: | `new_order_screen.dart:72-78` sends `cancelled` + `'timeout'` |
| Timer cancelled on accept | :white_check_mark: | `new_order_screen.dart:95` `_countdownTimer?.cancel()` |
| Timer cancelled on reject | :white_check_mark: | `new_order_screen.dart:126` `_countdownTimer?.cancel()` |
| Timer cancelled on dispose | :white_check_mark: | `new_order_screen.dart:150` `_countdownTimer?.cancel()` |
| `mounted` checks in setState | :white_check_mark: | `new_order_screen.dart:83,106,108,137,139` |
| `canPop()` guard | :white_check_mark: | `new_order_screen.dart:83,137` |
| UI: LinearProgressIndicator | :white_check_mark: | `new_order_screen.dart:212-217` with `_remainingSeconds / widget.timeoutSeconds` |
| Color shift orange→red at 10s | :white_check_mark: | `new_order_screen.dart:201-202` |
| Arabic countdown text | :white_check_mark: | `new_order_screen.dart:221` `'$_remainingSeconds ثانية للقبول'` |
| Alert sound on open | :white_check_mark: | `new_order_screen.dart:42` `SystemSound.play(SystemSoundType.alert)` |
| Heavy haptic on open | :white_check_mark: | `new_order_screen.dart:43` `HapticFeedback.heavyImpact()` |
| Light haptic last 10s | :white_check_mark: | `new_order_screen.dart:58-59` |
| Debounce on buttons | :white_check_mark: | `new_order_screen.dart:88-92,119-124` 2-second interval |
| Manual reject reason | :white_check_mark: | `new_order_screen.dart:134` `'manual_rejection'` |
| Widget tests (real) | :white_check_mark: | 9 tests with `pumpWidget`, `_StatusUpdateTracker`, timer progression |
| Auto-reject tested | :white_check_mark: | `new_order_timeout_test.dart:151-179` |
| Dispose tested | :white_check_mark: | `new_order_timeout_test.dart:237-257` |

### Observations (LOW — do not block merge)

1. **Race condition (theoretical):** `_accept()` does not check `_isLoading`. If auto-reject sets
   `_isLoading = true` and a tap event is already queued in the event loop, both API calls could
   fire. Dart's single-threaded model makes the window extremely narrow (< 1 frame). Server-side
   state machine enforcement is the proper mitigation.

2. **Timer restart edge case:** `assigned.isEmpty` at line 167 cancels timer via
   `_countdownTimer?.cancel()` but does not nullify `_countdownTimer`. If a new delivery
   subsequently appears, `_ensureCountdownStarted` sees a non-null timer and returns early.
   This is an edge case (delivery disappears then reappears mid-countdown).

---

## General Checks

| Check | Result |
|-------|--------|
| All 104 tests pass | :white_check_mark: |
| Static analysis clean | :white_check_mark: (1 info lint in `injection.dart` — pre-existing, unrelated) |
| No TODO/FIXME/placeholder in diff | :white_check_mark: |
| No hardcoded secrets | :white_check_mark: |
| Silent catches (`catch (_)`) | 2 found — both documented with rationale |

### Silent Catches Detail

1. `new_order_screen.dart:79` — Auto-reject server failure: closes screen anyway (correct —
   don't leave order hanging in UI)
2. `delivery_action_buttons.dart:78` — Non-mock location failure: allows transition (documented
   design choice)

---

## New Findings

| ID | Severity | Component | Description | Fix |
|----|----------|-----------|-------------|-----|
| V1 | MEDIUM | C3 | `delivery_proof_screen.dart:140` uses `getCurrentPosition()` — the normal delivery completion path bypasses mock GPS guard entirely | Replace with `getVerifiedPosition()` + handle `MockGpsDetectedException` |
| V2 | LOW | C4 | `_accept()` doesn't guard on `_isLoading` — theoretical race with auto-reject | Add `if (_isLoading) return;` at top of `_accept()` |
| V3 | LOW | C4 | Timer not nullified on `assigned.isEmpty` — `_ensureCountdownStarted` won't restart for subsequent delivery | Set `_countdownTimer = null` after cancel at line 167 |
| V4 | LOW | C3 | `getPositionStream()` doesn't check `isMocked` — background tracking can use mock positions | Add isMocked filter to stream, or document as accepted risk |

---

## Final Recommendation

### :yellow_circle: CONDITIONAL — V1 must be fixed before merge

- **C3:** Core mechanism is correct but has a real bypass path (V1). The proof screen is the
  **primary** delivery completion flow and it skips mock GPS validation entirely. This undermines
  the purpose of C3 for the most critical transition (`delivered`). Fix is straightforward:
  ~5 lines of code in `delivery_proof_screen.dart`.

- **C4:** Approved as-is. Timer lifecycle is correct, auto-reject works, tests are real widget
  tests. The LOW observations (V2, V3) are edge cases that don't affect core functionality.

### Recommended fix for V1

```dart
// delivery_proof_screen.dart, inside _submit(), replace line 140:
// OLD:
final position = await LocationService.instance.getCurrentPosition();
// NEW:
Position? position;
try {
  position = await LocationService.instance.getVerifiedPosition();
} on MockGpsDetectedException catch (e) {
  if (mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(e.message),
        backgroundColor: Theme.of(context).colorScheme.error,
      ),
    );
    setState(() => _isLoading = false);
  }
  return;
}
```
