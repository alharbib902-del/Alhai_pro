# Deferred HIGH Items — Super Admin Phase 4

## HIGH-04: Store Impersonation for Support

**Status:** DEFERRED — estimated effort > 2 days

**Why:** Requires multi-step implementation:
- Auth context switching (login as store owner with restricted permissions)
- Read-only session enforcement
- Multi-step confirmation dialogs
- Mandatory audit logging for every impersonation session
- Store owner notification system
- Session time limits (max 30 minutes)
- Separate impersonation tokens to prevent privilege escalation

**Mitigation:** Support staff can view store data via the store detail
screen (now audit-logged) without impersonation.

---

## HIGH-05: Support Ticket System

**Status:** DEFERRED — estimated effort > 3 days

**Why:** Full feature requiring:
- New `support_tickets` table with RLS policies
- Ticket creation form (for stores, accessible from store apps)
- Ticket list/detail screens in super_admin
- Status workflow (open → in_progress → resolved → closed)
- Priority levels and SLA tracking
- Notification system (email/push) for ticket updates
- File attachment support for screenshots

**Mitigation:** Support communication continues via existing channels
(WhatsApp, email) until the ticket system is built.

---

## HIGH-06: ZATCA Failure Alerts

**Status:** DEFERRED — estimated effort > 2 days

**Why:** Requires:
- Real-time monitoring infrastructure (Supabase Realtime or webhooks)
- Push notification service (FCM/APNs or email)
- Alert configuration UI (thresholds, recipients, channels)
- Dashboard notification bell with unread count
- Alert types: ZATCA submission failure, store offline, error spikes,
  suspicious login attempts

**Mitigation:** ZATCA failures are currently logged in Sentry. System
health screen shows database connectivity. Manual monitoring is required
until automated alerting is implemented.

---

## Priority for Implementation

1. HIGH-06 (ZATCA alerts) — most operationally impactful
2. HIGH-04 (impersonation) — improves support workflow
3. HIGH-05 (ticket system) — nice-to-have for tracking
