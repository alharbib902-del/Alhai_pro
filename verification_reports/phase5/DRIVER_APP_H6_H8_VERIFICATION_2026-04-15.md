# Driver App H6+H8 Verification

**Date:** 2026-04-15
**Verifier:** Claude Opus 4.6 (independent — did not author any fix)
**Branch:** fix/phase5-driver-app-high
**Commits:** bff98a1 (H6), 861b8f6 (H8)
**Scope:** H6 (WakeLock) + H8 (Mandatory Proof) only

---

## Executive Summary

H6 (WakeLock) is correctly implemented with proper filtering, idempotency, and cleanup. Minor gap: no explicit disable on logout (relies on stream state change). H8 (Mandatory Proof) successfully blocks the direct UI bypass, but a **ghost bug** exists: the proof screen itself requires no actual proof — a driver can open it and submit immediately with zero attachments, defeating the "mandatory proof" intent.

---

## H6 Verification — WakeLock Lifecycle

**Status: ✅ PASS (minor advisory notes)**

### Evidence

| Check | Result |
|-------|--------|
| `WakelockService` wraps `WakelockPlus` correctly | ✅ enable/disable with try-catch, idempotency guards |
| `activeDeliveriesStreamProvider` filters correctly | ✅ Uses `!_isTerminal(d)` — terminal = {delivered, failed, cancelled} |
| `ref.listen` in `main.dart:175-185` toggles correctly | ✅ `hasActive = next.valueOrNull?.isNotEmpty ?? false` |
| `dispose()` calls `WakelockService.instance.disable()` | ✅ `main.dart:125` |
| Tests pass (5/5) | ✅ enable, disable, idempotency×2, cycling |
| Tests use real `WakelockService` + fake platform | ✅ `FakeWakelockPlatform` overrides `wakelockPlusPlatformInstance` |

### Active Deliveries Filter Check

`delivery_providers.dart:82-92`:
```dart
final activeDeliveriesStreamProvider =
    Provider<AsyncValue<List<Map<String, dynamic>>>>((ref) {
      return ref.watch(
        myDeliveriesStreamProvider.select(
          (async) => async.whenData(
            (list) => list.where((d) => !_isTerminal(d)).toList(),
          ),
        ),
      );
    });
```

`_isTerminal` checks against `DeliveryStatus.terminal = {delivered, failed, cancelled}` (driver_constants.dart:42). All non-terminal statuses (assigned, accepted, heading_to_pickup, arrived_at_pickup, picked_up, heading_to_customer, arrived_at_customer) correctly keep wakelock on.

**VERDICT: Filtering is correct. No false positives/negatives.**

### Logout / Lifecycle Handling

| Scenario | Behavior | Risk |
|----------|----------|------|
| Normal logout | `logoutProvider` → `signOut()` → Supabase stream errors → `valueOrNull` = null → disable | 🟡 Indirect — works but depends on stream emitting after signOut |
| App backgrounded | WakeLock stays enabled | ✅ Harmless — OS manages screen for backgrounded apps |
| App killed | `dispose()` may not run | ✅ OS releases wakelock on process death |
| Network error during active delivery | `valueOrNull` = null → **wakelock disabled** | 🟡 Screen could dim during driving — acceptable tradeoff |

### Advisory Notes (not blocking)

1. **No explicit WakeLock.disable() on logout** — The logout flow (`auth_providers.dart:51-55`) doesn't call `WakelockService.instance.disable()`. It relies on the Supabase stream transitioning to error state. This works but is fragile — if the stream teardown races with the navigation, there's a brief window where wakelock remains enabled. Recommend adding `WakelockService.instance.disable()` to `logoutProvider` for defense-in-depth.

2. **No integration test for provider → service binding** — Tests only cover the `WakelockService` unit. The `ref.listen` glue in `main.dart:175-185` is untested. This is acceptable for the current scope.

---

## H8 Verification — Mandatory Delivery Proof

**Status: 🟡 CONDITIONAL — ghost bug found**

### Evidence

| Check | Result |
|-------|--------|
| `onProofRequired == null` → SnackBar + NO status update | ✅ `delivery_action_buttons.dart:228-239` — return path, no `_updateStatus` call |
| `onProofRequired != null` → callback invoked | ✅ `delivery_action_buttons.dart:228-229` |
| Only 1 usage site in codebase | ✅ `order_details_screen.dart:140-144` — always provides callback |
| No other path calls `updateStatus(delivered)` | ✅ Only `delivery_proof_screen.dart:188` |
| OfflineQueue not a bypass | ✅ Queue replays already-validated operations only |
| Tests pass (3/3) | ✅ null→SnackBar, provided→callback, both buttons render |
| Tests use real widget testing (pumpWidget) | ✅ Not test theater |

### Bypass Paths Checked

| Path | Bypass? | Evidence |
|------|---------|----------|
| `DeliveryActionButtons` with `onProofRequired=null` | ❌ Blocked by H8 fix | Shows SnackBar, no status update |
| Direct `updateDeliveryStatusProvider(delivered)` | ❌ Only called from proof screen | `delivery_proof_screen.dart:186-190` |
| `OfflineQueueService.enqueue(delivered)` | ❌ Not a bypass | Queued from `DeliveryDatasource.updateStatus` after proof |
| Realtime listener / notification handler | ❌ None found | No background status mutation in codebase |
| **Proof screen with zero attachments** | **⚠️ YES** | See ghost bug below |

### Ghost Bug: Proof Screen Allows Empty Submission

**Severity: HIGH — defeats H8's stated intent**

The proof screen (`delivery_proof_screen.dart:127-209`) calls `submitProof()` with all optional fields:
- `photoBytes: _photoBytes` — can be `null` (no photo taken)
- `signatureData: signatureDataUri` — can be `null` (empty signature)
- `recipientName` — can be `null`
- `notes` — can be `null`

`ProofDatasource.submitProof()` validates format **if** data is provided (size limits, magic bytes) but does NOT require that **at least one** proof item exists.

**Effective bypass:** Driver taps "تأكيد التسليم" → proof screen opens → immediately taps submit button → `submitProof(null, null, null, null, lat, lng)` succeeds → `updateDeliveryStatusProvider(delivered)` fires → delivery marked complete with no actual proof.

The only "proof" captured would be GPS coordinates, which are always included via `LocationService.instance.getVerifiedPosition()`.

### Server-Side Documentation

**Not created.** The commit message mentions server-side enforcement is needed, but no `SERVER_SIDE_VALIDATION.md` or equivalent was produced. Backend team has no guidance on what to validate.

---

## New Findings

| ID | Severity | Component | Description |
|----|----------|-----------|-------------|
| GH-1 | **HIGH** | H8 / proof_screen | Proof screen allows submission with zero proof (no photo, no signature). Driver bypasses "mandatory proof" by opening proof screen and immediately submitting. Recommend: add client-side gate requiring at least photo OR signature before enabling submit button. |
| GH-2 | **LOW** | H8 / documentation | No `SERVER_SIDE_VALIDATION.md` created. Backend team needs to know: (1) `delivered` transition should require a proof record with `photo_url IS NOT NULL OR signature_data IS NOT NULL`, (2) RPC `update_delivery_status` should reject `delivered` without a matching proof row. |
| GH-3 | **LOW** | H6 / logout | No explicit `WakelockService.disable()` in logout flow. Indirect via stream state change — works but fragile. |

---

## Test Results

```
00:02 +8: All tests passed!
  - wakelock_service_test.dart: 5/5 ✅
  - delivery_action_buttons_test.dart: 3/3 ✅
```

No concerning patterns (TODO/FIXME/placeholder/silent catch) found in diff.

---

## Final Recommendation

### 🟡 CONDITIONAL — one fix required before merge

**H6: ✅ APPROVED** — WakeLock implementation is correct and safe to merge.

**H8: 🟡 CONDITIONAL** — The UI-level block works correctly, but GH-1 creates a trivial bypass through the proof screen itself. Before merge:

1. **Required:** Add client-side validation in `delivery_proof_screen.dart` requiring at least `_photoBytes != null` OR `_signatureController.isNotEmpty` before enabling the submit button. This is a 5-line fix.
2. **Recommended:** Add `WakelockService.instance.disable()` to `logoutProvider` (GH-3).
3. **Recommended:** Create `SERVER_SIDE_VALIDATION.md` documenting required backend enforcement (GH-2).
