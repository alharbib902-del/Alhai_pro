# Monitoring Guide — Alhai Platform

---

## 1. Sentry Integration (Error Monitoring)

### Overview

Each app has its own Sentry project for isolated error tracking:

| App | Sentry Project Key | Environment Variable |
|-----|-------------------|---------------------|
| Customer App | `alhai-customer` | `SENTRY_DSN_CUSTOMER` |
| Driver App | `alhai-driver` | `SENTRY_DSN_DRIVER` |
| Distributor Portal | `alhai-distributor` | `SENTRY_DSN_DISTRIBUTOR` |

### Configuration (All Apps)

```dart
// Consistent across all 3 apps:
options.environment = kDebugMode ? 'development' : 'production';
options.tracesSampleRate = kDebugMode ? 1.0 : 0.3;  // 30% in production
options.attachScreenshot = true;                       // Crash screenshots
options.sendDefaultPii = false;                        // No PII sent
options.diagnosticLevel = SentryLevel.warning;
```

### Sentry Dashboard — What to Monitor

| Metric | Where | Alert Threshold |
|--------|-------|----------------|
| New errors | Issues → New | Any new P0 crash |
| Error frequency | Issues → Sort by events | > 100 events/hour |
| Crash-free users | Releases → Crash Free | < 99% |
| Performance (traces) | Performance → Overview | P95 > 3 seconds |
| Release health | Releases → Health | Adoption < 50% after 48h |

### Setting Up Alerts

1. Go to Sentry → Project → Alerts → Create Alert Rule
2. Recommended alerts:

   **Alert 1: New critical error**
   - Condition: A new issue is created
   - Filter: Level = `error` or `fatal`
   - Action: Email team + Slack notification

   **Alert 2: High error volume**
   - Condition: Number of events > 100 in 1 hour
   - Action: Email primary on-call

   **Alert 3: Crash rate spike**
   - Condition: Crash-free sessions < 98% for 1 hour
   - Action: Email engineering team

### Sentry Best Practices

- **Release tracking:** Tag releases with version numbers for regression detection
- **Source maps:** Upload source maps for web (distributor_portal) for readable stack traces
- **User context:** Set user ID (not PII) for tracking affected users
- **Breadcrumbs:** Sentry captures navigation breadcrumbs automatically in Flutter

---

## 2. Supabase Dashboard Monitoring

### Access
- **URL:** https://supabase.com/dashboard
- **What to check daily:**

### Database Health

| Metric | Location | Normal | Warning |
|--------|----------|--------|---------|
| Active connections | Database → Active connections | < 50 | > 100 |
| Database size | Database → Database size | < 4 GB | > 6 GB |
| Slow queries | Database → Query performance | All < 500ms | Any > 1s |
| Replication lag | Database → Replication | < 1s | > 5s |

### API Health

| Metric | Location | Normal | Warning |
|--------|----------|--------|---------|
| Request count | API → Overview | Consistent | Sudden drop = outage |
| Error rate | API → Overview | < 1% | > 5% |
| Response time (P95) | API → Overview | < 200ms | > 500ms |

### Auth Health

| Metric | Location | Normal | Warning |
|--------|----------|--------|---------|
| Signups/day | Auth → Users | Stable growth | Sudden spike = bot |
| Failed logins | Auth → Logs | < 5% of attempts | > 20% = brute force |
| Active users | Auth → Users | Growing | Sudden drop |

### Storage

| Metric | Location | Normal | Warning |
|--------|----------|--------|---------|
| Usage | Storage → Overview | < 50% of limit | > 80% |
| Large files | Storage → Files | < 10 MB each | > 50 MB |

---

## 3. Log Aggregation

### Current Setup

- **App errors:** Sentry (structured, searchable)
- **Database logs:** Supabase Dashboard → Logs
- **Auth events:** Supabase Dashboard → Auth → Logs
- **API requests:** Supabase Dashboard → API → Logs

### Recommended Future Setup

For production at scale, consider centralized logging:

```
App Errors     → Sentry (already set up)
Access Logs    → Supabase Logs Drain → (future: Better Stack / Datadog)
Auth Events    → Supabase Webhooks → (future: audit log service)
Infrastructure → Netlify / Vercel logs → (future: centralized)
```

### Log Retention

| Log Type | Current Retention | Recommended |
|---------|-------------------|-------------|
| Sentry errors | 90 days (free) | 90 days |
| Supabase API logs | 7 days | Enable log drain for longer |
| Supabase Auth logs | 7 days | Export critical events |
| Netlify deploy logs | 30 days | Sufficient |

---

## 4. Alerts Setup

### Critical Alerts (Immediate — P0)

| Alert | Source | Channel |
|-------|--------|---------|
| App crash rate > 5% | Sentry | Email + SMS |
| Supabase API down | UptimeRobot | Email + SMS |
| Database > 90% disk | Supabase | Email |
| SSL certificate expiring | Netlify | Email (auto-renewal should handle) |

### Warning Alerts (P1-P2)

| Alert | Source | Channel |
|-------|--------|---------|
| New error type | Sentry | Slack / Email |
| API error rate > 3% | Supabase / Sentry | Email |
| Auth failure rate > 10% | Supabase | Email |
| Deploy failed | Netlify | Email |

### Uptime Monitoring

Set up external uptime checks:

1. **UptimeRobot** (free tier: 50 monitors, 5-minute checks)
   - Monitor: `https://portal.alhai.store` (distributor portal)
   - Monitor: `https://your-project.supabase.co/rest/v1/` (API)
   - Alert: Email + Slack on downtime

2. **Better Stack** (alternative, includes status page)
   - Same monitors as above
   - Public status page: `status.alhai.store`

---

## 5. Performance Monitoring

### App Performance (Sentry Performance)

Sentry captures performance traces at 30% sample rate in production.

| Metric | Target | Location |
|--------|--------|----------|
| App startup time | < 3 seconds | Sentry → Performance → App Start |
| Screen load time | < 1 second | Sentry → Performance → Screens |
| API call duration | < 500ms | Sentry → Performance → HTTP |
| Frame rate (mobile) | > 55 FPS | Sentry → Performance → Frames |

### Web Performance (Distributor Portal)

| Metric | Target | Tool |
|--------|--------|------|
| First Contentful Paint | < 2s | Chrome Lighthouse |
| Largest Contentful Paint | < 3s | Chrome Lighthouse |
| Time to Interactive | < 4s | Chrome Lighthouse |
| Bundle size | < 5 MB | `flutter build web --release` output |

### Database Performance

```sql
-- Find slow queries (Supabase SQL Editor)
SELECT query, mean_exec_time, calls
FROM pg_stat_statements
ORDER BY mean_exec_time DESC
LIMIT 20;
```

---

## 6. Monthly Review Checklist

- [ ] Review Sentry error trends — any new recurring issues?
- [ ] Check Supabase database size and growth rate
- [ ] Review API response times — any degradation?
- [ ] Check backup restoration — do a test restore
- [ ] Review on-call incidents — any patterns?
- [ ] Check certificate expiry dates (SSL, Apple certs)
- [ ] Review user growth and capacity planning
- [ ] Check third-party service limits (Sentry events, Supabase limits)
- [ ] Update monitoring thresholds if needed
- [ ] Review and update this monitoring guide

---

*Last updated: April 16, 2026*
