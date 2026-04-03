-- ============================================================================
-- Alhai Platform - Delivery System Migration
-- Version: 19
-- Date: 2026-04-01
-- Description: Complete delivery system tables, enums, RPC functions, and RLS
-- ============================================================================

-- ============================================================================
-- 1. EXTEND delivery_status ENUM (add 4 intermediate states)
-- ============================================================================

ALTER TYPE delivery_status ADD VALUE IF NOT EXISTS 'heading_to_pickup' AFTER 'accepted';
ALTER TYPE delivery_status ADD VALUE IF NOT EXISTS 'arrived_at_pickup' AFTER 'heading_to_pickup';
ALTER TYPE delivery_status ADD VALUE IF NOT EXISTS 'heading_to_customer' AFTER 'picked_up';
ALTER TYPE delivery_status ADD VALUE IF NOT EXISTS 'arrived_at_customer' AFTER 'heading_to_customer';

-- ============================================================================
-- 2. ADD COLUMNS to deliveries table
-- ============================================================================

ALTER TABLE public.deliveries
  ADD COLUMN IF NOT EXISTS driver_lat DECIMAL(10,8),
  ADD COLUMN IF NOT EXISTS driver_lng DECIMAL(11,8),
  ADD COLUMN IF NOT EXISTS delivery_fee DECIMAL(10,2) DEFAULT 0,
  ADD COLUMN IF NOT EXISTS proof_photo_url TEXT,
  ADD COLUMN IF NOT EXISTS proof_signature_url TEXT,
  ADD COLUMN IF NOT EXISTS accepted_at TIMESTAMPTZ,
  ADD COLUMN IF NOT EXISTS store_id TEXT;

-- ============================================================================
-- 3. NEW TABLES
-- ============================================================================

-- driver_locations: real-time GPS position (upsert pattern - one row per driver)
CREATE TABLE IF NOT EXISTS public.driver_locations (
  driver_id UUID PRIMARY KEY REFERENCES public.users(id) ON DELETE CASCADE,
  lat DECIMAL(10,8) NOT NULL,
  lng DECIMAL(11,8) NOT NULL,
  heading DECIMAL(5,2),
  speed DECIMAL(6,2),
  accuracy DECIMAL(6,2),
  is_online BOOLEAN DEFAULT true,
  updated_at TIMESTAMPTZ DEFAULT now()
);

-- driver_shifts: driver work sessions (separate from POS shifts)
CREATE TABLE IF NOT EXISTS public.driver_shifts (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  driver_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
  store_id TEXT,
  started_at TIMESTAMPTZ DEFAULT now(),
  ended_at TIMESTAMPTZ,
  status TEXT NOT NULL DEFAULT 'active' CHECK (status IN ('active', 'ended')),
  total_deliveries INT DEFAULT 0,
  total_earnings DECIMAL(10,2) DEFAULT 0,
  total_distance_km DECIMAL(10,2) DEFAULT 0,
  created_at TIMESTAMPTZ DEFAULT now()
);

-- chat_messages: per-order messaging between driver/customer/store
CREATE TABLE IF NOT EXISTS public.chat_messages (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  order_id UUID NOT NULL REFERENCES public.orders(id) ON DELETE CASCADE,
  delivery_id UUID REFERENCES public.deliveries(id) ON DELETE SET NULL,
  sender_type TEXT NOT NULL CHECK (sender_type IN ('driver', 'customer', 'store', 'system')),
  sender_id UUID REFERENCES public.users(id) ON DELETE SET NULL,
  text TEXT NOT NULL,
  text_translated TEXT,
  image_url TEXT,
  language TEXT DEFAULT 'ar',
  is_read BOOLEAN DEFAULT false,
  is_system BOOLEAN DEFAULT false,
  created_at TIMESTAMPTZ DEFAULT now()
);

-- delivery_proofs: photo + signature evidence of delivery
CREATE TABLE IF NOT EXISTS public.delivery_proofs (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  delivery_id UUID NOT NULL REFERENCES public.deliveries(id) ON DELETE CASCADE,
  photo_url TEXT,
  signature_data TEXT,
  recipient_name TEXT,
  notes TEXT,
  lat DECIMAL(10,8),
  lng DECIMAL(11,8),
  created_at TIMESTAMPTZ DEFAULT now()
);

-- ============================================================================
-- 4. INDEXES
-- ============================================================================

CREATE INDEX IF NOT EXISTS idx_driver_locations_online
  ON public.driver_locations (is_online, updated_at DESC);

CREATE INDEX IF NOT EXISTS idx_driver_shifts_driver_status
  ON public.driver_shifts (driver_id, status, started_at DESC);

CREATE INDEX IF NOT EXISTS idx_chat_messages_order
  ON public.chat_messages (order_id, created_at ASC);
CREATE INDEX IF NOT EXISTS idx_chat_messages_unread
  ON public.chat_messages (order_id, sender_type, is_read)
  WHERE is_read = false;

CREATE INDEX IF NOT EXISTS idx_delivery_proofs_delivery
  ON public.delivery_proofs (delivery_id);

CREATE INDEX IF NOT EXISTS idx_deliveries_store_status
  ON public.deliveries (store_id, status, created_at DESC);

-- ============================================================================
-- 5. UNIQUE CONSTRAINTS
-- ============================================================================

DO $$ BEGIN
  ALTER TABLE public.delivery_proofs
    ADD CONSTRAINT delivery_proofs_delivery_unique UNIQUE(delivery_id);
EXCEPTION WHEN duplicate_object THEN null;
END $$;

DO $$ BEGIN
  ALTER TABLE public.driver_shifts
    ADD CONSTRAINT driver_shifts_one_active
    EXCLUDE USING gist (driver_id WITH =) WHERE (status = 'active');
EXCEPTION WHEN duplicate_object THEN null;
END $$;

-- ============================================================================
-- 6. RPC FUNCTIONS
-- ============================================================================

-- update_delivery_status: validates state transitions before updating
CREATE OR REPLACE FUNCTION public.update_delivery_status(
  p_delivery_id UUID,
  p_new_status TEXT,
  p_notes TEXT DEFAULT NULL
)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_current_status TEXT;
  v_driver_id UUID;
  v_order_id UUID;
  v_valid_transitions JSONB;
BEGIN
  -- Get current delivery state
  SELECT status::TEXT, driver_id, order_id
  INTO v_current_status, v_driver_id, v_order_id
  FROM public.deliveries
  WHERE id = p_delivery_id;

  IF v_current_status IS NULL THEN
    RETURN jsonb_build_object('success', false, 'error', 'DELIVERY_NOT_FOUND');
  END IF;

  -- Verify caller is the assigned driver
  IF v_driver_id != auth.uid() THEN
    RETURN jsonb_build_object('success', false, 'error', 'NOT_ASSIGNED_DRIVER');
  END IF;

  -- Define valid state transitions
  v_valid_transitions := '{
    "assigned": ["accepted", "cancelled"],
    "accepted": ["heading_to_pickup", "cancelled"],
    "heading_to_pickup": ["arrived_at_pickup", "cancelled"],
    "arrived_at_pickup": ["picked_up", "cancelled"],
    "picked_up": ["heading_to_customer"],
    "heading_to_customer": ["arrived_at_customer"],
    "arrived_at_customer": ["delivered", "failed"],
    "delivered": [],
    "failed": [],
    "cancelled": []
  }'::JSONB;

  -- Validate transition
  IF NOT (v_valid_transitions->v_current_status) ? p_new_status THEN
    RETURN jsonb_build_object(
      'success', false,
      'error', 'INVALID_TRANSITION',
      'current', v_current_status,
      'requested', p_new_status
    );
  END IF;

  -- Update delivery status
  UPDATE public.deliveries
  SET
    status = p_new_status::delivery_status,
    notes = COALESCE(p_notes, notes),
    accepted_at = CASE WHEN p_new_status = 'accepted' THEN now() ELSE accepted_at END,
    picked_up_at = CASE WHEN p_new_status = 'picked_up' THEN now() ELSE picked_up_at END,
    delivered_at = CASE WHEN p_new_status = 'delivered' THEN now() ELSE delivered_at END,
    updated_at = now()
  WHERE id = p_delivery_id;

  -- Update order status to match delivery progress
  IF p_new_status = 'picked_up' THEN
    UPDATE public.orders SET status = 'out_for_delivery'::order_status, updated_at = now()
    WHERE id = v_order_id;
  ELSIF p_new_status = 'delivered' THEN
    UPDATE public.orders SET status = 'delivered'::order_status, delivered_at = now(), updated_at = now()
    WHERE id = v_order_id;
  ELSIF p_new_status = 'cancelled' OR p_new_status = 'failed' THEN
    UPDATE public.orders SET status = 'cancelled'::order_status, cancelled_at = now(),
      cancellation_reason = COALESCE(p_notes, 'Delivery ' || p_new_status), updated_at = now()
    WHERE id = v_order_id AND status NOT IN ('delivered', 'completed');
  END IF;

  -- Insert status history
  INSERT INTO public.order_status_history (order_id, old_status, new_status, changed_by, notes)
  VALUES (v_order_id, v_current_status, p_new_status, auth.uid(), p_notes);

  RETURN jsonb_build_object(
    'success', true,
    'delivery_id', p_delivery_id,
    'old_status', v_current_status,
    'new_status', p_new_status
  );
END;
$$;

-- get_driver_dashboard_stats: today's stats for the driver
CREATE OR REPLACE FUNCTION public.get_driver_dashboard_stats(p_driver_id UUID)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
STABLE
SET search_path = public
AS $$
DECLARE
  v_today_start TIMESTAMPTZ;
  v_result JSONB;
BEGIN
  v_today_start := date_trunc('day', now());

  SELECT jsonb_build_object(
    'today_deliveries', COALESCE(
      (SELECT COUNT(*) FROM deliveries
       WHERE driver_id = p_driver_id AND status = 'delivered'
       AND delivered_at >= v_today_start), 0),
    'today_earnings', COALESCE(
      (SELECT SUM(delivery_fee) FROM deliveries
       WHERE driver_id = p_driver_id AND status = 'delivered'
       AND delivered_at >= v_today_start), 0),
    'active_delivery_id',
      (SELECT id FROM deliveries
       WHERE driver_id = p_driver_id
       AND status NOT IN ('delivered', 'failed', 'cancelled')
       ORDER BY created_at DESC LIMIT 1),
    'active_delivery_status',
      (SELECT status::TEXT FROM deliveries
       WHERE driver_id = p_driver_id
       AND status NOT IN ('delivered', 'failed', 'cancelled')
       ORDER BY created_at DESC LIMIT 1),
    'pending_count',
      (SELECT COUNT(*) FROM deliveries
       WHERE driver_id = p_driver_id AND status = 'assigned'),
    'is_on_shift',
      (SELECT EXISTS(SELECT 1 FROM driver_shifts
       WHERE driver_id = p_driver_id AND status = 'active')),
    'current_shift_id',
      (SELECT id FROM driver_shifts
       WHERE driver_id = p_driver_id AND status = 'active'
       LIMIT 1)
  ) INTO v_result;

  RETURN v_result;
END;
$$;

-- assign_delivery_to_driver: called by admin/store to assign
CREATE OR REPLACE FUNCTION public.assign_delivery_to_driver(
  p_order_id UUID,
  p_driver_id UUID,
  p_store_id TEXT DEFAULT NULL
)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_delivery_id UUID;
  v_order_record RECORD;
BEGIN
  -- Get order info
  SELECT id, store_id, delivery_address, delivery_lat, delivery_lng, delivery_fee
  INTO v_order_record
  FROM public.orders
  WHERE id = p_order_id;

  IF v_order_record IS NULL THEN
    RETURN jsonb_build_object('success', false, 'error', 'ORDER_NOT_FOUND');
  END IF;

  -- Check driver exists and is delivery role
  IF NOT EXISTS (SELECT 1 FROM public.users WHERE id = p_driver_id AND role = 'delivery' AND is_active = true) THEN
    RETURN jsonb_build_object('success', false, 'error', 'INVALID_DRIVER');
  END IF;

  -- Check if delivery already exists for this order
  SELECT id INTO v_delivery_id FROM public.deliveries WHERE order_id = p_order_id;

  IF v_delivery_id IS NOT NULL THEN
    -- Update existing delivery with new driver
    UPDATE public.deliveries
    SET driver_id = p_driver_id, status = 'assigned', updated_at = now()
    WHERE id = v_delivery_id;
  ELSE
    -- Create new delivery
    INSERT INTO public.deliveries (
      order_id, driver_id, store_id, status,
      delivery_address, delivery_lat, delivery_lng, delivery_fee
    ) VALUES (
      p_order_id, p_driver_id,
      COALESCE(p_store_id, v_order_record.store_id),
      'assigned',
      v_order_record.delivery_address,
      v_order_record.delivery_lat,
      v_order_record.delivery_lng,
      COALESCE(v_order_record.delivery_fee, 0)
    )
    RETURNING id INTO v_delivery_id;
  END IF;

  -- Update order with driver assignment
  UPDATE public.orders
  SET driver_id = p_driver_id::TEXT, status = 'confirmed'::order_status, updated_at = now()
  WHERE id = p_order_id AND status IN ('created', 'confirmed');

  RETURN jsonb_build_object(
    'success', true,
    'delivery_id', v_delivery_id,
    'driver_id', p_driver_id,
    'order_id', p_order_id
  );
END;
$$;

-- ============================================================================
-- 7. ROW LEVEL SECURITY
-- ============================================================================

-- driver_locations
ALTER TABLE public.driver_locations ENABLE ROW LEVEL SECURITY;

CREATE POLICY "drivers_own_location_select" ON public.driver_locations
  FOR SELECT USING (
    driver_id = auth.uid()
    OR EXISTS (SELECT 1 FROM public.users WHERE id = auth.uid() AND role IN ('super_admin', 'store_owner'))
    OR EXISTS ( -- Customer can see driver location for their active delivery
      SELECT 1 FROM public.deliveries d
      JOIN public.orders o ON o.id = d.order_id
      WHERE d.driver_id = driver_locations.driver_id
        AND o.customer_id = auth.uid()
        AND d.status NOT IN ('delivered', 'failed', 'cancelled')
    )
  );

CREATE POLICY "drivers_own_location_upsert" ON public.driver_locations
  FOR INSERT WITH CHECK (driver_id = auth.uid());

CREATE POLICY "drivers_own_location_update" ON public.driver_locations
  FOR UPDATE USING (driver_id = auth.uid());

-- driver_shifts
ALTER TABLE public.driver_shifts ENABLE ROW LEVEL SECURITY;

CREATE POLICY "drivers_own_shifts" ON public.driver_shifts
  FOR ALL USING (
    driver_id = auth.uid()
    OR EXISTS (SELECT 1 FROM public.users WHERE id = auth.uid() AND role IN ('super_admin', 'store_owner'))
  );

-- chat_messages
ALTER TABLE public.chat_messages ENABLE ROW LEVEL SECURITY;

CREATE POLICY "chat_participants_select" ON public.chat_messages
  FOR SELECT USING (
    sender_id = auth.uid()
    OR EXISTS ( -- Driver assigned to this order's delivery
      SELECT 1 FROM public.deliveries d
      WHERE d.order_id = chat_messages.order_id AND d.driver_id = auth.uid()
    )
    OR EXISTS ( -- Customer who placed the order
      SELECT 1 FROM public.orders o
      WHERE o.id = chat_messages.order_id AND o.customer_id = auth.uid()
    )
    OR EXISTS (SELECT 1 FROM public.users WHERE id = auth.uid() AND role IN ('super_admin', 'store_owner'))
  );

CREATE POLICY "chat_participants_insert" ON public.chat_messages
  FOR INSERT WITH CHECK (
    sender_id = auth.uid()
    AND (
      EXISTS (SELECT 1 FROM public.deliveries d WHERE d.order_id = chat_messages.order_id AND d.driver_id = auth.uid())
      OR EXISTS (SELECT 1 FROM public.orders o WHERE o.id = chat_messages.order_id AND o.customer_id = auth.uid())
      OR EXISTS (SELECT 1 FROM public.users WHERE id = auth.uid() AND role IN ('super_admin', 'store_owner'))
    )
  );

CREATE POLICY "chat_mark_read" ON public.chat_messages
  FOR UPDATE USING (
    EXISTS (SELECT 1 FROM public.deliveries d WHERE d.order_id = chat_messages.order_id AND d.driver_id = auth.uid())
    OR EXISTS (SELECT 1 FROM public.orders o WHERE o.id = chat_messages.order_id AND o.customer_id = auth.uid())
  )
  WITH CHECK (is_read = true); -- Can only update is_read to true

-- delivery_proofs
ALTER TABLE public.delivery_proofs ENABLE ROW LEVEL SECURITY;

CREATE POLICY "proof_driver_insert" ON public.delivery_proofs
  FOR INSERT WITH CHECK (
    EXISTS (
      SELECT 1 FROM public.deliveries d
      WHERE d.id = delivery_proofs.delivery_id AND d.driver_id = auth.uid()
    )
  );

CREATE POLICY "proof_read" ON public.delivery_proofs
  FOR SELECT USING (
    EXISTS (
      SELECT 1 FROM public.deliveries d
      WHERE d.id = delivery_proofs.delivery_id
      AND (
        d.driver_id = auth.uid()
        OR EXISTS (SELECT 1 FROM public.orders o WHERE o.id = d.order_id AND o.customer_id = auth.uid())
        OR EXISTS (SELECT 1 FROM public.users WHERE id = auth.uid() AND role IN ('super_admin', 'store_owner'))
      )
    )
  );

-- Enable Realtime for delivery tracking tables
ALTER PUBLICATION supabase_realtime ADD TABLE public.driver_locations;
ALTER PUBLICATION supabase_realtime ADD TABLE public.deliveries;
ALTER PUBLICATION supabase_realtime ADD TABLE public.chat_messages;

-- ============================================================================
-- 8. STORAGE BUCKET for delivery proofs
-- ============================================================================

INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES (
  'delivery-proofs',
  'delivery-proofs',
  false,
  5242880, -- 5MB
  ARRAY['image/jpeg', 'image/png', 'image/webp']
)
ON CONFLICT (id) DO NOTHING;

-- Storage policies
CREATE POLICY "driver_upload_proof" ON storage.objects
  FOR INSERT WITH CHECK (
    bucket_id = 'delivery-proofs'
    AND auth.uid() IS NOT NULL
    AND EXISTS (SELECT 1 FROM public.users WHERE id = auth.uid() AND role = 'delivery')
  );

CREATE POLICY "proof_read_access" ON storage.objects
  FOR SELECT USING (
    bucket_id = 'delivery-proofs'
    AND auth.uid() IS NOT NULL
  );
