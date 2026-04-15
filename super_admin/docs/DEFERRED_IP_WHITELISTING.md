# IP Whitelisting — Deferred to Infrastructure Layer

## Status: DEFERRED

## Why Deferred

IP whitelisting for the Super Admin console requires infrastructure-level
enforcement (Supabase Edge Functions, CDN rules, or reverse proxy config)
that cannot be implemented purely in the Flutter client.

Client-side IP detection is unreliable and bypassable — it provides a
false sense of security without actual protection.

## Current Mitigation

Login IP context is now captured via the audit logging system:

- **auth.login** events include timestamp and email
- **auth.login_failed** events include timestamp and attempted email
- **auth.logout** events include timestamp
- **auth.mfa_verified** / **auth.mfa_failed** events include timestamp

For full IP logging, configure Supabase Database Webhooks or Edge
Functions to capture `request.headers['x-forwarded-for']` on the
`audit_log` INSERT trigger.

## Recommended Implementation

1. **Supabase Edge Function**: Create a middleware that checks the
   requesting IP against an allowlist stored in a `ip_allowlist` table.
   Reject requests from non-whitelisted IPs with HTTP 403.

2. **CDN/WAF Rules**: If using Cloudflare or similar, configure IP
   allowlist rules for the Super Admin domain/path.

3. **VPN Requirement**: Require BLTech staff to connect via VPN before
   accessing the Super Admin console. This is the strongest approach.

## Priority

P1 — Should be implemented before production deployment.
