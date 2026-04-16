# Distributor Onboarding — Backend Requirements

**Date:** 2026-04-16
**Feature:** Self-service distributor signup → email verification → pending review → admin approval
**Client:** `distributor_portal/` (Flutter Web)

---

## 1. Distributors Table — Status Column Update

The `distributors` table needs a status CHECK constraint supporting the onboarding workflow:

```sql
-- Update distributors status enum
ALTER TABLE distributors
  DROP CONSTRAINT IF EXISTS distributors_status_check;

ALTER TABLE distributors
  ADD CONSTRAINT distributors_status_check
  CHECK (status IN (
    'pending_email_verification',
    'pending_review',
    'active',
    'rejected',
    'suspended'
  ));

-- New fields for terms tracking
ALTER TABLE distributors
  ADD COLUMN IF NOT EXISTS terms_accepted_at timestamptz,
  ADD COLUMN IF NOT EXISTS terms_version text;
```

## 2. RLS Policy — Distributor Self-Insert

Allow authenticated users to create their own distributor record during signup:

```sql
CREATE POLICY distributors_signup_insert ON distributors
  FOR INSERT TO authenticated
  WITH CHECK (user_id = auth.uid());
```

## 3. Admin Notifications Table

```sql
CREATE TABLE IF NOT EXISTS admin_notifications (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  type text NOT NULL,        -- 'new_distributor', 'document_uploaded', etc
  title text NOT NULL,
  message text,
  related_id uuid,           -- distributor_id, document_id, etc
  related_type text,         -- 'distributor', 'document'
  is_read boolean DEFAULT false,
  created_at timestamptz NOT NULL DEFAULT now(),
  read_at timestamptz,
  read_by uuid REFERENCES profiles(id)
);

ALTER TABLE admin_notifications ENABLE ROW LEVEL SECURITY;

CREATE POLICY admin_notifications_admin_all ON admin_notifications
  FOR ALL TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM profiles
      WHERE id = auth.uid() AND role IN ('super_admin', 'admin')
    )
  );
```

## 4. Trigger — Notify Admin on New Distributor

```sql
CREATE OR REPLACE FUNCTION notify_admin_new_distributor()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO admin_notifications (
    type, title, message, related_id, related_type
  ) VALUES (
    'new_distributor',
    'موزّع جديد بانتظار المراجعة',
    'الشركة: ' || NEW.company_name,
    NEW.id,
    'distributor'
  );
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_notify_admin_new_distributor
AFTER INSERT ON distributors
FOR EACH ROW
WHEN (NEW.status = 'pending_review')
EXECUTE FUNCTION notify_admin_new_distributor();
```

## 5. Supabase Auth Configuration

Ensure in **Supabase Dashboard > Authentication > Email**:

- [x] Email confirmations enabled
- [x] Redirect URL configured for distributor portal domain
- [x] Rate limiting on email sends (default 60s)

## 6. Status Transitions

```
signup → pending_email_verification
email confirmed → pending_review
admin approves → active
admin rejects → rejected
admin suspends → suspended
```

Only the following transitions are valid:
- `pending_email_verification` → `pending_review` (automatic on email confirm)
- `pending_review` → `active` (admin action)
- `pending_review` → `rejected` (admin action)
- `active` → `suspended` (admin action)
- `suspended` → `active` (admin action)

## 7. Future: Admin Review Screen

Not implemented in this session. Requires:
- Query `distributors WHERE status = 'pending_review'`
- Approve/reject with optional reason
- Status update + notification to distributor
