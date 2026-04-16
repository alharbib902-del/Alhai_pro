# OTP Server-Side Rate Limiting

## Status: REQUIRED before production

Client-side OTP rate limiting is implemented with persistent state (SharedPreferences),
but this only protects the UI path. An attacker can call the Supabase `verifyOTP` API
directly, bypassing the client entirely.

## Required: Supabase Auth Rate Limiting

Configure in Supabase Dashboard → Authentication → Rate Limits:

- **OTP verification attempts**: Max 5 per phone per 15 minutes
- **OTP send requests**: Max 3 per phone per 15 minutes
- **Global rate limit**: Apply IP-based throttling at edge/API gateway

## Current Client-Side Protection

- 5 failed attempts → 15-minute lockout
- State persisted in SharedPreferences (survives app restart)
- Keys: `otp_failed_attempts_{phone}`, `otp_lockout_until_{phone}`
