# Incident Runbook — Alhai POS

**Audience:** the single on-call engineer (you or whoever you hand the phone to).
**Goal:** every minute an incident continues is a minute a customer can't sell.
This document exists so you never lose time remembering what to try.

---

## Severity levels

| Level | Definition | Target response | Notify |
|-------|------------|-----------------|--------|
| **SEV1** | POS cashier cannot complete a sale. Data loss suspected. ZATCA rejects production invoice. | Acknowledge < 5 min. Resolve < 1 hr. | All customers + you |
| **SEV2** | Admin / reports broken. One payment method fails. One app crashes on start. | Ack < 30 min. Resolve < 4 hr. | Affected customer + you |
| **SEV3** | Cosmetic bug. Slow query. Non-critical feature degraded. | Ack < 1 business day. | Logged only |

---

## Golden signals — where to look first

| Signal | Dashboard | What "bad" looks like |
|--------|-----------|------------------------|
| Crash rate | Sentry (per app) | > 1% of sessions in last hour |
| Supabase health | supabase.com → Project → Home | Red status banner |
| Supabase writes | Supabase → Database → Query performance | Timeouts or high locks |
| Railway AI Server | railway.com → Project → api.alhai.store | Red "Deploy failed" or "Crashed" |
| ZATCA acceptance | fatoora.zatca.gov.sa → Submission history | Rejected / 4xx rate > 0 |
| Cert pinning | Sentry search: `message:REJECTED certificate` | Any event = pin mismatch |
| Customer reports | WhatsApp Business | Multiple customers reporting same issue |

---

## Decision tree

```
Customer reports a problem
  ↓
Is cashier unable to complete a sale?
  ├── YES → SEV1 → skip to "SEV1 — POS down"
  └── NO  ↓
Is it ZATCA-related?
  ├── YES → "ZATCA rejections"
  └── NO  ↓
Is it sync-related (app shows stale data)?
  ├── YES → "Sync stuck"
  └── NO  ↓
Is it crash-on-start?
  ├── YES → "App crashes immediately"
  └── NO  ↓
Single customer? → SEV2/3, take your time. Log it.
All customers? → Escalate to SEV1 anyway.
```

---

## Playbook — SEV1: POS is down

**Symptoms:** Cashier screen frozen, "Cannot connect" error, or sale submit never completes.

1. **Check Supabase status first** — supabase.com → project. If red banner: wait it out; the offline queue in cashier will hold sales. Tell the customer "Sales will auto-sync when we're back." Supabase outages typically resolve in <30 min.

2. **If Supabase is green:** check Sentry for new errors in the last 15 min:
   - Many sessions all hitting the same error → deploy regression. **Roll back** (see "Rollback").
   - A single session looping errors → probably the customer's device. Ask them to force-quit + relaunch.

3. **If cashier can't even open:** check if a forced-upgrade banner is blocking:
   - `cashier/lib/main.dart` checks `minSupportedVersion` at startup.
   - Likely cause: recent release bumped the minimum and the customer's build is stale.
   - Fix: push a hotfix release with the minimum lowered, OR have the customer reinstall from Play Store.

4. **If a specific feature is broken** (e.g., can't close shift): gather a reproduction, log the customer's `user_id` + `store_id`, escalate to engineering.

**Recovery verification:**
- Have the customer complete one full sale end-to-end.
- Check `daily_summaries` row for their store has incremented.
- Verify ZATCA invoice was accepted.

---

## Playbook — ZATCA rejections

**Symptoms:** Invoices queue up, "pending" status never moves to "issued".

1. **Open fatoora.zatca.gov.sa → Submission history.** Filter by "Rejected". Read the first rejected row's error message exactly.

2. **Common causes + fixes:**

   | Error message (fragment) | Likely cause | Fix |
   |---------------------------|--------------|-----|
   | "Invalid signature" | Cert expired or wrong CSID | Renew CSID via ZATCA portal + redeploy backend |
   | "Previous hash mismatch" | Invoice chain broken | Check `invoices.previous_invoice_hash` consistency; may require manual chain repair |
   | "UUID already submitted" | Duplicate push | Safe to ignore if the invoice shows "accepted" on a prior submission |
   | "Timestamp outside window" | Server clock drift > 5 min | Check Railway container time; restart if needed |
   | "Invalid tax calculation" | Pricing / VAT bug in cashier | Don't push retry — fix the calc locally first |

3. **If the cause is a cashier-side calculation bug** (wrong VAT, wrong total), do NOT keep retrying. Each retry adds a bad row to `invoices`. Pause pushes (disable the sync for the invoice table by commenting out 'invoices' in `packages/alhai_sync/lib/src/strategies/push_strategy.dart:96`), ship a fix, then re-enable.

4. **If the customer continues to sell during an outage**, their invoices queue locally. Once ZATCA is back + fix is shipped, they'll sync automatically. No data loss — the POS is offline-first by design.

---

## Playbook — Sync stuck

**Symptoms:** Customer says data in admin doesn't match cashier. Or push sync queue backs up.

1. **On the cashier device:** open DevTools → Console. Look for `[SyncEngine]` log lines. Patterns:
   - `Failed to push sales: 42P01 relation does not exist` → a migration is missing on Supabase. Run `./scripts/post_deploy_check.py` to diagnose.
   - `Failed to push: version conflict` → optimistic concurrency (v42) rejected a stale write. Safe — the client will re-fetch and retry.
   - `No network` → offline. Queue will drain when back online.

2. **On Supabase:** open the SQL editor and run:
   ```sql
   SELECT table_name, COUNT(*) FROM (
     SELECT 'sync_queue_local' AS table_name FROM <your-local-debug-table>
   ) t GROUP BY table_name;
   ```
   (This assumes you've exported the local queue to a debug table; otherwise pull from the device.)

3. **Force a full resync on the device:**
   - Settings → Advanced → "Clear sync queue and re-pull".
   - WARNING: does not fix bad data, just retries.

4. **Worst case — bad row blocking the queue:**
   - Identify the blocking row in `sync_queue` (highest retry_count).
   - Manually inspect it. If it's malformed: delete from local queue; engineering will reconstruct server-side.
   - Never delete from `sales` or `invoices` on the server to "make it work" — that's data loss.

---

## Playbook — App crashes immediately on launch

1. **Ask the customer:** fresh install or update? What Android/iOS version?

2. **Most common cause (post-release):** missing `--dart-define` at build. Check the exact build ID's CI log:
   - Was `SUPABASE_URL` empty? That explains hard fail.
   - Was `SUPABASE_CERT_FINGERPRINT` missing? That explains fail-closed pinning in release mode.

3. **Immediate mitigation:** publish the previous working version in Play Console as an emergency rollback (Releases → Dashboard → Rollout halt → Promote previous AAB).

4. **After mitigation:** fix the CI workflow, verify all required secrets present, re-release.

---

## Rollback procedure (Supabase)

**Never roll BACK a Supabase migration** — Postgres doesn't support this cleanly for anything with data changes. Roll FORWARD with a new migration that reverses the change.

**If you absolutely must restore a database:**
1. Supabase → Project → Database → Backups → pick the most recent pre-incident snapshot.
2. PITR (Point-in-Time Recovery) requires Pro plan with PITR enabled (extra $) — buy the addon if you need it.
3. Restoration is to a NEW database. You then repoint the app at the new connection string. Expect 15-60 min downtime depending on data size.

**Practice this before you need it.** Do a test restore on staging during Week 2 so you know the steps work.

---

## Rollback procedure (App — Android)

1. Google Play Console → select app → Releases → Production → "Create new release".
2. "Add from library" → pick a previous AAB that was known good.
3. Fill in release notes: "Rollback due to bug X. Fix inbound." Submit.
4. Google reviews within 1-4 hours. During review, the current (broken) release is still the active one — so this is NOT a zero-downtime rollback.
5. For emergency: use "Halt rollout" on the broken release. New users get the previous version; existing users keep the broken one until they uninstall.

---

## Rollback procedure (AI Server — Railway)

1. railway.com → project → `api.alhai.store` service → Deployments tab.
2. Find the last green deployment. Click → Redeploy.
3. Railway promotes it within ~2 min. No database migration involved, so no data risk.

---

## Communication templates

**SEV1 Acknowledge (WhatsApp):**
> نعتذر عن التعطّل الحالي. فريقنا يعمل على حلّه الآن وسنبلّغك فور عودة الخدمة. مبيعاتك المحلية مسجّلة وستُزامَن تلقائياً.

**SEV1 Resolved:**
> تمت استعادة الخدمة. نشكر صبركم. إن لاحظت أي فاتورة ناقصة، تواصل معنا مباشرةً.

**Maintenance window (advance notice):**
> تحديث مجدول للنظام في [التاريخ/الساعة]. مدة متوقّعة: 15 دقيقة. خلال هذه الفترة، POS يعمل offline وستُزامَن المبيعات تلقائياً بعد التحديث.

---

## Post-incident checklist (for every SEV1)

- [ ] Root cause identified in writing (not "fixed it — unknown why").
- [ ] Specific commit or config change that caused it.
- [ ] Test that would have caught it BEFORE release (write it if it doesn't exist).
- [ ] Monitoring/alert that would have detected it sooner (add it if missing).
- [ ] Decision: does this warrant paging the customer post-mortem, or is internal-only sufficient?
- [ ] Filed in `docs/postmortems/` with date + one-line summary.

---

## Contacts

| Role | Contact |
|------|---------|
| You (engineer) | +966 ... |
| Supabase support | support@supabase.com (Pro plan: email SLA 24h) |
| ZATCA support | 19993 or zatca.gov.sa/contact |
| Railway support | team@railway.app |
| Sentry support | Web-only chat inside dashboard |

**Emergency escalation path:** if you're alone and incapacitated, the pilot customer has your number — they must know they can WhatsApp any issue. That's the fallback until the team grows.
