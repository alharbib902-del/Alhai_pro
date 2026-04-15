# Pickup OTP Backend Requirements

## Problem

At pickup, no verification exists that:
- Driver actually arrived at store
- Store handed the correct order
- Driver didn't fake a pickup

## Solution

4-digit OTP generated on driver request, visible to cashier via Supabase Realtime.

## Schema

```sql
CREATE TABLE pickup_otps (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  order_id uuid NOT NULL REFERENCES orders(id),
  driver_id uuid NOT NULL REFERENCES profiles(id),
  store_id uuid NOT NULL REFERENCES stores(id),
  otp_code text NOT NULL,
  attempts int DEFAULT 0,
  verified_at timestamptz,
  expires_at timestamptz NOT NULL DEFAULT (now() + INTERVAL '15 minutes'),
  created_at timestamptz NOT NULL DEFAULT now()
);

-- RLS: driver reads OTPs for their own deliveries
ALTER TABLE pickup_otps ENABLE ROW LEVEL SECURITY;

CREATE POLICY pickup_otps_driver_select ON pickup_otps
  FOR SELECT TO authenticated
  USING (driver_id = auth.uid());

-- RLS: store cashiers read OTPs for their stores
CREATE POLICY pickup_otps_store_select ON pickup_otps
  FOR SELECT TO authenticated
  USING (
    store_id IN (
      SELECT store_id FROM store_users WHERE user_id = auth.uid()
    )
  );
```

## RPCs Required

### 1. `request_pickup_otp(order_id uuid)`

- Validates: `driver_id == auth.uid()`
- Validates: `order.status == 'arrived_at_pickup'`
- Generates random 4-digit OTP
- INSERTs into `pickup_otps`
- Returns: `{ otp_id, expires_at }`
- SECURITY DEFINER

### 2. `verify_pickup_otp(order_id uuid, otp_code text)`

- Validates: `driver_id == auth.uid()`
- Fetches latest OTP for this order
- If `verified_at != null`: error "already verified"
- If `expires_at < now()`: error "OTP expired"
- If `attempts >= 3`: error + audit log
- If `otp_code != stored`: increment attempts + error
- If correct:
  - Set `verified_at = now()`
  - Update `orders.status = 'picked_up'`
  - Return success

## Flow

1. Driver arrives at store → taps "Request OTP"
2. Server generates OTP → stores in `pickup_otps`
3. Cashier app subscribes to `pickup_otps` via Realtime → sees OTP
4. Cashier tells driver OTP verbally
5. Driver enters OTP in app
6. Server verifies → transitions order to `picked_up`

## Cashier App Integration (future)

The cashier app needs a Realtime subscription on `pickup_otps` filtered by
`store_id`. When a new row appears, display the OTP prominently for the
cashier to read aloud. No code changes needed on the cashier side until
this backend is deployed.
