-- Migration v22: Server-side OTP rate limiting and permission verification
-- Date: 2026-04-03
-- Description:
--   SEC-002: OTP rate limiting via otp_attempts table + check_otp_rate_limit() RPC
--   SEC-007: Server-side permission checks via verify_operation_permission() RPC
--   SEC-008: security_events table for persisting SecurityLogger entries
--
-- These functions enforce security server-side so that client-side checks
-- cannot be bypassed by reinstalling the app or clearing local storage.

-- ============================================================================
-- SEC-002: OTP Rate Limiting
-- ============================================================================

-- Table to track OTP send/verify attempts per phone number
CREATE TABLE IF NOT EXISTS public.otp_attempts (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  phone TEXT NOT NULL,
  attempt_type TEXT NOT NULL CHECK (attempt_type IN ('send', 'verify')),
  ip_address TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- Index for fast lookup by phone + time window
CREATE INDEX IF NOT EXISTS idx_otp_attempts_phone_created
  ON public.otp_attempts (phone, created_at DESC);

-- Auto-cleanup: drop rows older than 24 hours (run via pg_cron or app-level)
-- For now the RPC function only looks at the last 15 minutes.

-- RPC: Check whether a phone number is within OTP rate limits.
-- Returns TRUE if the phone is allowed to request/verify OTP, FALSE if blocked.
-- Rules: max 5 attempts of each type per 15-minute sliding window.
CREATE OR REPLACE FUNCTION public.check_otp_rate_limit(
  p_phone TEXT,
  p_attempt_type TEXT DEFAULT 'send'
) RETURNS BOOLEAN AS $$
DECLARE
  attempt_count INT;
BEGIN
  SELECT COUNT(*) INTO attempt_count
  FROM public.otp_attempts
  WHERE phone = p_phone
    AND attempt_type = p_attempt_type
    AND created_at > NOW() - INTERVAL '15 minutes';

  RETURN attempt_count < 5;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- RPC: Record an OTP attempt (called by the app after sending or verifying).
CREATE OR REPLACE FUNCTION public.record_otp_attempt(
  p_phone TEXT,
  p_attempt_type TEXT DEFAULT 'send',
  p_ip_address TEXT DEFAULT NULL
) RETURNS VOID AS $$
BEGIN
  INSERT INTO public.otp_attempts (phone, attempt_type, ip_address)
  VALUES (p_phone, p_attempt_type, p_ip_address);

  -- Housekeeping: delete attempts older than 24 hours for this phone
  DELETE FROM public.otp_attempts
  WHERE phone = p_phone
    AND created_at < NOW() - INTERVAL '24 hours';
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ============================================================================
-- SEC-007: Server-side Permission Verification
-- ============================================================================

-- RPC: Verify that a user has the required permission for a sensitive operation.
-- Operations: 'void', 'refund', 'price_change', 'stock_adjust', 'shift_close',
--             'settings_change', 'user_manage', 'report_export'
--
-- Permission matrix (store_role):
--   owner   -> all operations
--   manager -> all except 'user_manage', 'settings_change'
--   cashier -> only 'refund' (with limits), basic operations
--
-- Returns TRUE if allowed, FALSE if denied.
CREATE OR REPLACE FUNCTION public.verify_operation_permission(
  p_user_id UUID,
  p_store_id TEXT,
  p_operation TEXT
) RETURNS BOOLEAN AS $$
DECLARE
  v_role store_role;
  v_is_active BOOLEAN;
BEGIN
  -- Look up user's role in this store
  SELECT role_in_store, is_active
    INTO v_role, v_is_active
    FROM public.store_members
   WHERE user_id = p_user_id
     AND store_id = p_store_id
   LIMIT 1;

  -- User not found in store or inactive
  IF NOT FOUND OR v_is_active IS NOT TRUE THEN
    RETURN FALSE;
  END IF;

  -- Owner can do everything
  IF v_role = 'owner' THEN
    RETURN TRUE;
  END IF;

  -- Manager can do most things except user management and settings
  IF v_role = 'manager' THEN
    RETURN p_operation NOT IN ('user_manage', 'settings_change');
  END IF;

  -- Cashier: limited operations
  IF v_role = 'cashier' THEN
    RETURN p_operation IN ('refund', 'shift_close');
  END IF;

  RETURN FALSE;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ============================================================================
-- SEC-008: Security Events Table (for SecurityLogger persistence)
-- ============================================================================

CREATE TABLE IF NOT EXISTS public.security_events (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  store_id TEXT,
  user_id TEXT,
  phone TEXT,
  event_type TEXT NOT NULL,
  details TEXT,
  metadata JSONB,
  ip_address TEXT,
  device_info TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- Indexes for common queries
CREATE INDEX IF NOT EXISTS idx_security_events_store
  ON public.security_events (store_id, created_at DESC);
CREATE INDEX IF NOT EXISTS idx_security_events_user
  ON public.security_events (user_id, created_at DESC);
CREATE INDEX IF NOT EXISTS idx_security_events_type
  ON public.security_events (event_type, created_at DESC);

-- RPC: Batch-insert security events (called by SecurityLogger flush).
-- Accepts a JSONB array of event objects.
CREATE OR REPLACE FUNCTION public.insert_security_events(
  p_events JSONB
) RETURNS INTEGER AS $$
DECLARE
  evt JSONB;
  v_count INTEGER := 0;
BEGIN
  FOR evt IN SELECT * FROM jsonb_array_elements(p_events)
  LOOP
    INSERT INTO public.security_events (
      store_id, user_id, phone, event_type,
      details, metadata, ip_address, device_info, created_at
    ) VALUES (
      evt->>'store_id',
      evt->>'user_id',
      evt->>'phone',
      evt->>'event_type',
      evt->>'details',
      CASE WHEN evt->'metadata' IS NOT NULL AND evt->>'metadata' != 'null'
           THEN (evt->'metadata')
           ELSE NULL END,
      evt->>'ip_address',
      evt->>'device_info',
      COALESCE((evt->>'created_at')::TIMESTAMPTZ, NOW())
    );
    v_count := v_count + 1;
  END LOOP;

  RETURN v_count;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ============================================================================
-- RLS Policies
-- ============================================================================

-- otp_attempts: only service_role should write; authenticated can call RPCs
ALTER TABLE public.otp_attempts ENABLE ROW LEVEL SECURITY;

-- security_events: members can read their store's events
ALTER TABLE public.security_events ENABLE ROW LEVEL SECURITY;

CREATE POLICY "security_events_read_own_store"
  ON public.security_events FOR SELECT
  USING (
    public.is_store_member(store_id)
    OR public.is_super_admin()
  );

-- ============================================================================
-- Grant execute permissions to authenticated users
-- ============================================================================

GRANT EXECUTE ON FUNCTION public.check_otp_rate_limit(TEXT, TEXT) TO authenticated;
GRANT EXECUTE ON FUNCTION public.record_otp_attempt(TEXT, TEXT, TEXT) TO authenticated;
GRANT EXECUTE ON FUNCTION public.verify_operation_permission(UUID, TEXT, TEXT) TO authenticated;
GRANT EXECUTE ON FUNCTION public.insert_security_events(JSONB) TO authenticated;
