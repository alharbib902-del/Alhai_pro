# Incident Response Plan

## Severity Levels

| Level | Description | Response Time | Example |
|-------|-------------|---------------|---------|
| SEV1 | Production down, data loss risk | < 15 min | Login broken for all users, DB corruption |
| SEV2 | Major feature broken | < 1 hour | POS checkout fails, ZATCA invoices rejected |
| SEV3 | Minor feature broken | < 4 hours | Report export fails, UI glitch |
| SEV4 | Cosmetic / non-blocking | Next business day | Typo, minor UI issue |

## Roles
- **Incident Commander**: First responder, coordinates response
- **Technical Lead**: Investigates root cause
- **Communications**: Updates stakeholders and status page

## Response Steps

### 1. Detection
- Source: Sentry alerts, user reports, monitoring
- Acknowledge within response time SLA

### 2. Triage
- Determine severity level
- Identify affected users (count, regions)
- Open incident channel: `#incident-YYYYMMDD-description`

### 3. Mitigate
- **First priority: stop the bleeding**
- Options (in order):
  1. Feature flag kill switch
  2. Rollback deployment (see ROLLBACK.md)
  3. Hotfix deploy
  4. Manual database intervention (last resort, with backup)

### 4. Communicate
- Internal: Slack incident channel, every 30 min
- External (if SEV1/SEV2): Status page update within 1 hour
- User-facing: In-app banner or email notification

### 5. Resolve
- Confirm issue resolved
- Monitor for regressions for 24 hours
- Close incident officially

### 6. Post-Mortem
- Within 48 hours of resolution
- Blameless culture -- focus on systems, not people
- Document:
  - Timeline
  - Root cause
  - What went well
  - What didn't
  - Action items with owners

## Contacts (TODO: fill in)

- On-call rotation: [define]
- Supabase support: support@supabase.io
- ZATCA support: (for e-invoice issues)
- Google Play support: (for release issues)
- Apple Developer support: (for release issues)

## Communication Templates

### Initial user notification
> We're currently investigating an issue affecting [feature]. Our team is working on it and will provide updates. Thank you for your patience.

### Resolution notification
> The issue affecting [feature] has been resolved. If you continue to experience problems, please [contact method].
