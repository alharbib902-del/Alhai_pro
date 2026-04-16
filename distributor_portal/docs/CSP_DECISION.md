# CSP unsafe-inline Decision

## Current Policy

```
script-src 'self' 'unsafe-inline';
style-src 'self' 'unsafe-inline';
```

## Why unsafe-inline Is Required

Flutter Web injects inline `<script>` tags at runtime for:
- `flutter_bootstrap.js` loader
- Service worker registration
- Deferred library loading
- Hot reload (debug mode)

Removing `unsafe-inline` from `script-src` breaks Flutter Web completely.
The Flutter framework does not currently support CSP nonce-based script
injection (tracked: https://github.com/flutter/flutter/issues/126977).

## Existing Mitigations

The following headers are already in place to limit attack surface:

| Header | Value | Purpose |
|--------|-------|---------|
| `frame-ancestors` | `'none'` | Prevents clickjacking |
| `X-Frame-Options` | `DENY` | IE/legacy clickjacking prevention |
| `X-Content-Type-Options` | `nosniff` | Prevents MIME sniffing |
| `Referrer-Policy` | `strict-origin-when-cross-origin` | Limits referrer leaks |
| `base-uri` | `'self'` | Prevents base tag hijacking |
| `form-action` | `'self'` | Prevents form submission to external origins |
| `connect-src` | Explicit allowlist | Only Supabase endpoints |

## Additional Mitigations

- All user inputs are validated server-side (Supabase RLS + RPC validation).
- Sentry monitoring is active for runtime errors (including unexpected script execution).
- No user-generated HTML is rendered (all UI is Flutter widget-based).

## Future Action

When Flutter Web supports CSP nonces (via `flutter build web --csp-nonce`
or equivalent), migrate from `unsafe-inline` to nonce-based policy.
Monitor the Flutter issue tracker for progress.
