# Account Deletion — Backend RPC Required

## Status: REQUIRED before production (PDPL + App Store compliance)

The customer app calls `delete_user_account()` RPC. Deploy this function in Supabase:

```sql
CREATE OR REPLACE FUNCTION delete_user_account()
RETURNS void AS $$
BEGIN
  -- Remove personal addresses
  DELETE FROM addresses WHERE user_id = auth.uid()::text;
  -- Anonymize order history (preserve for accounting)
  UPDATE orders SET customer_name = 'محذوف', customer_phone = '***'
    WHERE customer_id = auth.uid()::text;
  -- Remove favorites
  DELETE FROM favorites WHERE user_id = auth.uid()::text;
  -- Delete auth user (cascades profile)
  DELETE FROM auth.users WHERE id = auth.uid();
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
```

## Client behavior

- On success: clears SharedPreferences + FlutterSecureStorage, signs out, navigates to login
- On RPC missing (42883): shows "يرجى التواصل مع الدعم لحذف حسابك"
- On other errors: shows generic retry message
