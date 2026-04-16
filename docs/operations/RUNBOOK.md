# Operations Runbook — Alhai Platform

> هذا الدليل مخصّص لفريق العمليات والدعم الفني للتعامل مع الحوادث والمشاكل الشائعة.

---

## 1. Common Incidents & Fixes

### 1.1 Users Cannot Login

**Symptoms:** Users report "unable to login" or "OTP not received"

**Diagnosis:**
```bash
# Check Supabase Auth service
curl -s https://your-project.supabase.co/auth/v1/health

# Check Supabase status page
# https://status.supabase.com
```

**Fixes:**
| Cause | Fix |
|-------|-----|
| Supabase Auth down | Wait for Supabase recovery — check status page |
| OTP rate limited | User must wait (usually 60 seconds between OTP requests) |
| Phone number format wrong | Ensure +966 prefix for Saudi numbers |
| Account suspended | Check user status in Supabase Dashboard → Auth → Users |

### 1.2 Orders Not Processing

**Symptoms:** Orders stuck in "pending" status

**Diagnosis:**
1. Check Supabase Dashboard → Table Editor → `orders`
2. Filter by `status = 'pending'` and sort by `created_at DESC`
3. Check if Realtime subscriptions are active

**Fixes:**
| Cause | Fix |
|-------|-----|
| No available drivers | Notify operations — driver coverage issue |
| Distributor offline | Contact distributor to confirm availability |
| Database connection issue | Check Supabase Dashboard → Database → Active connections |

### 1.3 E-Invoice Submission Failing (ZATCA)

**Symptoms:** Invoices created but ZATCA submission fails

**Diagnosis:**
1. Check Sentry for ZATCA-related errors
2. Verify ZATCA API endpoint status:
   ```bash
   curl -s https://gw-fatoora.zatca.gov.sa/e-invoicing/core/health
   ```
3. Check CSID validity (CSIDs expire and need renewal)

**Fixes:**
| Cause | Fix |
|-------|-----|
| ZATCA API down | Retry later — ZATCA has maintenance windows |
| CSID expired | Renew CSID via production CSID renewal endpoint |
| Invalid invoice data | Check distributor's CR/VAT data in Supabase |
| Wrong environment | Ensure ZATCA env is `production` (not `sandbox`) |

### 1.4 App Crashing on Startup

**Symptoms:** Users report app closes immediately after opening

**Diagnosis:**
1. Check Sentry for crash reports (sort by latest)
2. Common causes: missing env vars, Supabase unreachable, cert pin mismatch

**Fixes:**
| Cause | Fix |
|-------|-----|
| Supabase URL changed | Update env vars and redeploy |
| Certificate rotated | Update `SUPABASE_CERT_FINGERPRINT` and release app update |
| Bad release build | Roll back to previous version |

### 1.5 Distributor Portal Not Loading (Web)

**Symptoms:** Blank page or loading spinner

**Diagnosis:**
1. Open browser DevTools → Console → check for errors
2. Check Netlify deploy status
3. Check if Supabase `connect-src` in CSP matches production URL

**Fixes:**
| Cause | Fix |
|-------|-----|
| Deploy failed | Check Netlify Dashboard → Deploys → rebuild |
| CSP blocking requests | Update CSP in `index.html` with correct Supabase URL |
| SSL certificate issue | Verify custom domain SSL in Netlify |

---

## 2. Supabase Health Checks

### Dashboard
- **URL:** https://supabase.com/dashboard
- **Check:** Database → Health, API → Request volume, Auth → Active users

### Manual Health Check

```bash
# API health
curl -s -o /dev/null -w "%{http_code}" \
  https://your-project.supabase.co/rest/v1/ \
  -H "apikey: your-anon-key"
# Expected: 200

# Auth health
curl -s https://your-project.supabase.co/auth/v1/health
# Expected: {"status":"ok"}

# Realtime
# Check WebSocket connections in Supabase Dashboard → Realtime
```

### Key Metrics

| Metric | Normal | Warning | Critical |
|--------|--------|---------|----------|
| API response time | < 200ms | 200-500ms | > 500ms |
| Database connections | < 50% capacity | 50-80% | > 80% |
| Auth success rate | > 99% | 95-99% | < 95% |
| Disk usage | < 50% | 50-80% | > 80% |

---

## 3. Deployment Rollback

### Distributor Portal (Netlify)

```bash
# Option 1: Netlify Dashboard
# Deploys → Click on previous successful deploy → "Publish deploy"

# Option 2: CLI
netlify rollback

# Option 3: Redeploy from specific commit
git checkout <previous-commit>
flutter build web --release --dart-define-from-file=.env
netlify deploy --dir=build/web --prod
```

### Mobile Apps (Android/iOS)

| Platform | Rollback Method | Time |
|---------|----------------|------|
| Android (Play Store) | Halt rollout → promote previous version | Minutes |
| Android (staged rollout) | Reduce rollout % to 0 | Minutes |
| iOS (App Store) | Remove current version → previous remains | Hours |
| iOS (TestFlight) | Expire current build → upload previous | 30 min |

> **Important:** Mobile app rollbacks are slower due to store review. Always maintain a staged rollout (10% → 25% → 50% → 100%).

### Database (Supabase)

```bash
# Restore from backup (Pro plan)
# Dashboard → Database → Backups → Select backup → Restore

# Point-in-time recovery (Pro plan)
# Available for last 7 days
```

> **WARNING:** Database rollback affects ALL users. Only use as last resort.

---

## 4. Investigating User Complaints

### Step-by-step Process

1. **Identify the user:**
   - Get user phone number or email
   - Find user ID in Supabase Dashboard → Auth → Users

2. **Check recent activity:**
   ```sql
   -- In Supabase SQL Editor
   SELECT * FROM orders
   WHERE user_id = 'uuid-here'
   ORDER BY created_at DESC
   LIMIT 10;
   ```

3. **Check error logs:**
   - Sentry → Search by user ID or email
   - Look for errors in the relevant time window

4. **Check device/app version:**
   - Sentry captures device info and app version
   - Ensure user is on latest version

5. **Respond to user:**
   - Acknowledge the issue
   - Provide estimated resolution time
   - Follow up when resolved

### Common User Complaints

| Complaint | Investigation | Resolution |
|-----------|--------------|------------|
| "My order is stuck" | Check order status in DB | Contact driver or reassign |
| "I was charged but no order" | Check payment records and order table | Verify with payment provider, issue refund if confirmed |
| "Wrong items delivered" | Check order items vs delivery | Offer replacement or refund |
| "Can't delete my account" | Verify the RPC function is deployed | Run `delete_user_account` manually if needed |
| "App keeps crashing" | Check Sentry for crash reports | Request user to update app or clear cache |

---

## 5. Support Escalation Path

```
Level 1 (L1): Customer Support
├── Basic account issues (login, password reset)
├── Order status inquiries
├── General app usage help
└── Escalate to L2 if: technical issue, repeated problem

Level 2 (L2): Technical Support
├── App crashes investigation (Sentry)
├── Database queries for specific users
├── Payment disputes
├── ZATCA invoice issues
└── Escalate to L3 if: infrastructure issue, data loss

Level 3 (L3): Engineering Team
├── Production incidents (Supabase down, critical bugs)
├── Security incidents
├── Data migration/recovery
├── Deployment issues
└── Escalate to: CTO/Founder if business-critical
```

### Response Time SLAs

| Severity | Description | Response Time | Resolution Time |
|----------|-------------|---------------|-----------------|
| **P0 — Critical** | Service completely down | 30 minutes | 4 hours |
| **P1 — High** | Major feature broken (ordering, payments) | 1 hour | 8 hours |
| **P2 — Medium** | Feature degraded but workaround exists | 4 hours | 24 hours |
| **P3 — Low** | Minor issue, cosmetic, enhancement | 24 hours | 1 week |

---

## 6. On-Call Rotation Template

### Weekly Rotation

| Week | Primary | Secondary | Notes |
|------|---------|-----------|-------|
| Week 1 | [Name A] | [Name B] | |
| Week 2 | [Name B] | [Name C] | |
| Week 3 | [Name C] | [Name A] | |
| Week 4 | [Name A] | [Name B] | |

### On-Call Responsibilities

- **Primary:** First responder for all P0/P1 incidents
- **Secondary:** Backup if primary is unavailable
- **Hours:** [Business hours / 24/7 — to be determined]
- **Notification:** [Slack channel / phone / PagerDuty — to be set up]

### Handoff Checklist

- [ ] Review active incidents from previous week
- [ ] Verify access to Supabase Dashboard, Sentry, Netlify
- [ ] Check scheduled maintenance or deployments
- [ ] Update on-call contact info if needed

---

*Last updated: April 16, 2026*
