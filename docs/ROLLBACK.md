# Rollback Runbook

## When to Rollback
- Critical bug affecting >5% of users
- Security vulnerability discovered post-release
- Data corruption detected
- Payment/ZATCA flow broken
- Cross-tenant data leak

## Application Rollback

### Web apps (cashier, admin, etc.)
1. Check current deployed commit: `git -C deploy log -1`
2. Identify last known good commit
3. Rollback:
   ```bash
   # If using GitHub Pages
   git revert <bad-commit> -m 1
   git push origin main
   # Or reset to last known good:
   git reset --hard <good-commit>
   git push --force-with-lease origin main
   ```
4. Verify via smoke test: navigate to production URL, check login + main flows
5. Notify users via in-app banner (if feature flag system allows)

### Mobile apps (Play Store)
1. Go to Google Play Console -> Release -> Production
2. Click on the problematic release
3. Use "Halt rollout" button to stop ongoing rollout
4. For users already on the bad version:
   - Use Firebase Remote Config / feature flags to disable the broken feature
   - Push a hotfix release (bumped version) ASAP
   - CANNOT undo an update -- users keep the new version
5. Start a new release with the previous working code + version bump

### Mobile apps (App Store)
- Apple does NOT support rollback
- Must submit new version (expedited review if critical)
- Until new version approved, use feature flags to disable bad feature

## Database Rollback

### Migration reverts
> **Warning:** Migrations are forward-only. There are NO `down.sql` files. To rollback:

1. **Option A -- Create counter-migration**
   - Write a new migration that undoes the changes
   - Example: if v32 added a RLS policy you want to remove, create v33 that drops it
   - This is the preferred approach

2. **Option B -- Point-in-Time Recovery (PITR)**
   - Supabase Pro plan only
   - Go to Supabase Dashboard -> Database -> Backups
   - Choose a timestamp BEFORE the bad migration ran
   - Click "Restore"
   - **Warning:** This reverts ALL data to that timestamp -- you WILL lose data written since

3. **Option C -- Contact Supabase support**
   - For catastrophic issues, open support ticket
   - Free tier: no backup, data may be lost

### Before running ANY migration in production:
```bash
# Manual backup step (until automated)
pg_dump -h <host> -U postgres -d postgres > backup-$(date +%Y%m%d-%H%M).sql
```

## Feature Flag Kill Switch

Use feature flags to disable broken features WITHOUT rolling back:

```sql
-- In Supabase SQL Editor
UPDATE feature_flags SET enabled = false WHERE key = 'broken_feature_name';
```

Apps using `FeatureFlags.isEnabled()` will pick up the change within 5 minutes (cache duration).

## Post-Rollback Checklist
- [ ] Confirm rollback successful (smoke test)
- [ ] Notify team via Slack / incident channel
- [ ] Post status update to status page
- [ ] Create incident report document
- [ ] Schedule post-mortem within 48 hours
- [ ] File bug ticket with root cause
