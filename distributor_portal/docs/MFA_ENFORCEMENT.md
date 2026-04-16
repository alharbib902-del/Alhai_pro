# MFA Enforcement Policy — distributor_portal

## Policy

| Role          | MFA Requirement | Behavior                                    |
|---------------|-----------------|---------------------------------------------|
| `super_admin` | **Mandatory**   | Forced enrollment on next login if not set   |
| Other roles   | Optional        | Can enroll/unenroll from Settings            |

## How it works

### Login flow for super_admin

1. User logs in with email + password.
2. System checks `user.userMetadata['role']`.
3. If `super_admin`:
   - **Has MFA factor** → redirected to `/mfa-verify` (TOTP challenge).
   - **No MFA factor** → redirected to `/mfa-enroll` with `forced: true`.
4. In forced enrollment mode:
   - Back button is hidden on the intro step.
   - A mandatory notice banner is displayed:
     *"كأدمن عام، المصادقة الثنائية إلزامية لحماية حسابك."*
   - On completion, user is sent to `/dashboard`.
   - User cannot reach the dashboard without completing enrollment.

### Login flow for other roles

1. User logs in with email + password.
2. If MFA is enrolled → redirected to `/mfa-verify`.
3. Otherwise → goes directly to `/dashboard`.

## Limitations

- **Cannot be disabled per-user**: All `super_admin` users must have MFA.
  To exempt a user, change their role from `super_admin`.
- **Role is stored in `user_metadata`**: Changing the role requires a Supabase
  admin API call or direct database update.
- **No server-side enforcement**: The policy is enforced client-side in the
  login flow. A determined attacker with valid credentials could bypass by
  calling the API directly. Server-side RLS policies should additionally
  check AAL level for sensitive operations.

## Recovery if locked out

1. **Backup codes**: Users receive 8 one-time backup codes during enrollment.
   Each can be used once to authenticate.
2. **Admin reset**: A super admin or database admin can unenroll the user's
   MFA factor via the Supabase dashboard (Authentication → Users → MFA).
3. **Re-enrollment**: After factor removal, the user will be prompted to
   enroll again on next login (since they are still `super_admin`).

## Files involved

- `lib/screens/auth/distributor_login_screen.dart` — Login flow with role check
- `lib/screens/auth/mfa_enrollment_screen.dart` — Enrollment wizard (supports `forced` flag)
- `lib/core/router/app_router.dart` — Route definitions and guards
- `lib/data/services/mfa_service.dart` — MFA service (enrollment, verify, backup codes)
