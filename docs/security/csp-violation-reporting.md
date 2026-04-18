# CSP Violation Reporting (Sentry)

## Why this matters
Content-Security-Policy is enforced across `super_admin` and `distributor_portal`
via `web/_headers` (Cloudflare), `nginx.conf` (Docker), and `vercel.json`.
Without reporting, a directive that accidentally blocks a legitimate third-party
asset (or catches a real XSS probe) is invisible — only user complaints reveal
it. CSP reports surface breakage, misconfiguration, and active attacks within
minutes.

## How Sentry ingests CSP reports
Sentry exposes a per-project endpoint that accepts the browser's native
`application/csp-report` JSON body (`{ "csp-report": { ... } }`). Reports show
up under the project's **Security** tab, grouped by violated directive + URI.
The endpoint URL is in the form:

```
https://<org>.ingest.sentry.io/api/<PROJECT_ID>/security/?sentry_key=<KEY>
```

Everything after `https://` is what we store in the `SENTRY_CSP_REPORT_URI`
secret (the scheme is added by the template).

## What ships in the repo
Each of the 6 CSP locations contains the placeholder token
`__SENTRY_CSP_REPORT_URI__`. The deploy workflow replaces it with the real
URI before upload. If the secret is unset, the placeholder is left in place
(reports go nowhere, CSP still enforces normally — graceful degradation).

| File | Directive added |
|------|-----------------|
| `super_admin/web/_headers` | `report-uri`, `report-to`, `Report-To:` header |
| `super_admin/web/index.html` | `report-uri` (meta-tag limitation: no `Report-To`) |
| `distributor_portal/web/_headers` | `report-uri`, `report-to`, `Report-To:` header |
| `distributor_portal/web/index.html` | `report-uri` only |
| `distributor_portal/nginx.conf` | `report-uri`, `report-to`, `add_header Report-To` |
| `distributor_portal/vercel.json` | `report-uri`, `report-to`, `Report-To` header entry |

## Ops setup (one-time)

1. In Sentry, open the target project → **Settings → Security Headers → CSP**.
2. Copy the full ingest URL (the `https://...sentry.io/api/.../security/?sentry_key=...`).
3. Strip the leading `https://` — store only the host+path+query in GitHub
   Actions secret `SENTRY_CSP_REPORT_URI`.
4. Next deploy, the workflow's **Inject CSP report-uri** step runs `sed` across
   the 6 files and substitutes the placeholder. Violations begin posting within
   minutes of deploy.

## Testing
Drop this into any page of a non-production build to trigger a violation:

```html
<script src="https://evil.example/x.js"></script>
```

The browser console logs `Refused to load the script ... Content Security Policy`
and a POST lands at the Sentry endpoint. Verify it appears under **Security →
CSP Reports**.

## Known limitations

- `<meta http-equiv="Content-Security-Policy">` cannot set the `Report-To`
  HTTP response header — that is header-only per the Reporting API spec.
  We still emit the legacy `report-uri` directive via the meta tag so
  deployments without `_headers`/nginx/vercel support can at least report.
- Browsers are migrating from `report-uri` (deprecated) to the `Report-To`
  header + `report-to` directive. We ship both for compatibility. Sentry
  accepts reports from either pathway.
- Reports contain user IP and the violating URL — nothing PII-sensitive.
