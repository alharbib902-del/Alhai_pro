# Supabase Production Configuration

## Overview

Alhai uses **Supabase** as the primary backend:
- **Database:** PostgreSQL (products, orders, invoices, users, distributors)
- **Authentication:** Email/password, OTP, MFA (TOTP for super_admin)
- **Row Level Security (RLS):** Per-table access control
- **Realtime:** WebSocket subscriptions for live updates
- **Storage:** File/image storage (future)

**Current:** Local development / Free tier
**Target:** Supabase Pro plan for production

---

## 1. Upgrade to Pro Plan

### Why Upgrade

| Feature | Free | Pro ($25/mo) |
|---------|------|-------------|
| Database size | 500 MB | 8 GB |
| Bandwidth | 2 GB/mo | 250 GB/mo |
| File storage | 1 GB | 100 GB |
| Auth users | Unlimited | Unlimited |
| Realtime connections | 200 concurrent | 500 concurrent |
| Daily backups | 7 days | 14 days |
| Custom domain | No | Yes |
| Support | Community | Email |

### Upgrade Steps

1. Go to https://supabase.com/dashboard
2. Select your project
3. Settings → Billing → Upgrade to Pro
4. Enter payment method
5. Confirm ($25/month)

---

## 2. Custom Domain

A custom domain (e.g., `api.alhai.store`) provides:
- Branding consistency
- Easier certificate pinning (stable domain)
- No exposure of Supabase project ID

### Setup

1. Supabase Dashboard → Settings → Custom Domains
2. Add domain: `api.alhai.store`
3. Add DNS records:

   | Type | Name | Value |
   |------|------|-------|
   | CNAME | api | `your-project-ref.supabase.co` |

4. Verify and activate
5. Update all `.env` files: `SUPABASE_URL=https://api.alhai.store`

---

## 3. Backup Strategy

### Automated Backups (Pro Plan)

- **Frequency:** Daily automatic backups
- **Retention:** 14 days (Pro plan)
- **Type:** Full PostgreSQL dump
- **Restore:** Dashboard → Database → Backups → Restore

### Manual Backups

```bash
# Using pg_dump (requires database connection string)
pg_dump "postgresql://postgres:[password]@db.[project-ref].supabase.co:5432/postgres" \
  -F c -b -v -f alhai_backup_$(date +%Y%m%d).dump

# Restore
pg_restore -d "postgresql://..." alhai_backup_20260416.dump
```

### Backup Checklist

- [ ] Pro plan activated (14-day retention)
- [ ] Weekly manual backup to external storage
- [ ] Backup restoration tested at least once
- [ ] Connection string stored securely (not in git)

---

## 4. RLS Audit Checklist

Row Level Security is critical — it prevents unauthorized data access.

### Audit Steps

1. **List all tables without RLS:**
   ```sql
   SELECT schemaname, tablename
   FROM pg_tables
   WHERE schemaname = 'public'
     AND tablename NOT IN (
       SELECT tablename FROM pg_tables
       WHERE rowsecurity = true
     );
   ```

2. **Verify policies per table:**
   ```sql
   SELECT tablename, policyname, cmd, qual
   FROM pg_policies
   WHERE schemaname = 'public'
   ORDER BY tablename;
   ```

3. **Key tables to verify:**

   | Table | Expected RLS | Policy |
   |-------|-------------|--------|
   | `users` | ✅ | Users can only read/update own row |
   | `orders` | ✅ | Customer sees own orders; driver sees assigned orders |
   | `products` | ✅ | Public read; distributor write own products |
   | `invoices` | ✅ | Distributor sees own invoices |
   | `distributors` | ✅ | Distributor sees own data; admin sees all |

4. **Test with anon key:**
   - Try to read other users' data → should fail
   - Try to insert into tables without proper role → should fail

---

## 5. Monitoring Setup

### Supabase Dashboard

The built-in dashboard provides:
- **Database:** Query performance, table sizes, active connections
- **Auth:** Sign-ups, active users, failed logins
- **API:** Request counts, response times, error rates
- **Realtime:** Active subscriptions, messages/sec

### Key Metrics to Watch

| Metric | Warning Threshold | Action |
|--------|-------------------|--------|
| Database size | > 6 GB (of 8 GB Pro) | Upgrade or archive old data |
| Active connections | > 400 (of 500) | Optimize connection pooling |
| API error rate | > 5% | Investigate failing endpoints |
| Auth failures | > 100/hour | Check for brute force; enable rate limiting |
| Realtime connections | > 400 | Review subscription patterns |

### Alerting

Supabase Pro includes basic email alerts. For advanced alerting:
1. Use Supabase Webhooks to forward events
2. Integrate with Sentry for error correlation
3. Consider a monitoring service (UptimeRobot, Better Stack) for uptime checks

---

## 6. Edge Functions (Future)

Supabase Edge Functions (Deno runtime) can be used for:
- Custom business logic
- ZATCA API proxy
- Webhook handlers
- Scheduled tasks (cron)

### Setup When Needed

```bash
# Install Supabase CLI
npm install -g supabase

# Create a function
supabase functions new my-function

# Deploy
supabase functions deploy my-function --project-ref your-project-ref
```

---

## 7. Storage Capacity Planning

### Current Usage Estimates

| Data Type | Estimated Size (Year 1) | Growth Rate |
|-----------|------------------------|-------------|
| User accounts | 10 MB | Slow |
| Product catalog | 100 MB | Moderate |
| Order history | 500 MB | Fast |
| Invoice records (ZATCA) | 200 MB | Fast |
| Audit logs | 100 MB | Moderate |
| **Total estimate** | **~1 GB** | |

### Recommendations

- **Year 1:** Pro plan (8 GB) is sufficient
- **Year 2+:** Monitor growth; consider archiving old orders
- **File storage:** Product images should use Supabase Storage or R2
- **Invoice PDFs:** Generate on-demand, don't store pre-rendered

---

## 8. Security Hardening

### Database

- [ ] All tables have RLS enabled
- [ ] No public schema functions with `SECURITY DEFINER` unless necessary
- [ ] `service_role` key only used server-side (never in client apps)
- [ ] Database extensions audited (remove unused)

### Authentication

- [ ] Email confirmation required for new signups
- [ ] Rate limiting on OTP requests
- [ ] MFA enforced for super_admin role
- [ ] Password policy configured (minimum length, complexity)
- [ ] Session duration set (e.g., 24 hours for mobile, 8 hours for web)

### API

- [ ] CORS restricted to known origins
- [ ] API rate limiting configured
- [ ] Unused API endpoints disabled
- [ ] Anon key has minimal permissions

### Network

- [ ] Custom domain with SSL (no exposed project ref)
- [ ] Certificate pinning configured in mobile apps
- [ ] Security headers set on all responses

---

## 9. Migration from Free to Pro

### Steps

1. **Before upgrade:**
   - Export current database: `pg_dump` (manual backup)
   - Document all custom settings (Auth, Storage, RLS)

2. **Upgrade:**
   - Dashboard → Settings → Billing → Upgrade
   - No downtime — same project, same URL

3. **After upgrade:**
   - Configure custom domain
   - Verify backup schedule
   - Test all API endpoints
   - Update monitoring thresholds

### Alternative: New Production Project

If you prefer a clean production setup:

1. Create new Supabase project (Pro plan)
2. Run all migrations from `supabase/migrations/`
3. Apply seed data if needed
4. Update all `.env` files with new URL/keys
5. Test thoroughly before switching DNS

---

*Last updated: April 16, 2026*
