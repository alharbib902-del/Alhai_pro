-- ============================================================
-- Alhai POS - Supabase Complete Audit Script
-- Run this in Supabase SQL Editor to get full schema report
-- ============================================================

-- ============================================================
-- 1. ALL TABLES with row count
-- ============================================================
SELECT
  schemaname,
  tablename,
  (xpath('/row/cnt/text()', xml_count))[1]::text::bigint AS row_count
FROM (
  SELECT
    schemaname,
    tablename,
    query_to_xml(format('SELECT COUNT(*) AS cnt FROM %I.%I', schemaname, tablename), false, true, '') AS xml_count
  FROM pg_tables
  WHERE schemaname = 'public'
  ORDER BY tablename
) t;

-- ============================================================
-- 2. ALL COLUMNS per table with types, nullable, defaults
-- ============================================================
SELECT
  t.table_name,
  c.column_name,
  c.data_type,
  c.udt_name,
  c.is_nullable,
  c.column_default,
  c.character_maximum_length
FROM information_schema.tables t
JOIN information_schema.columns c
  ON t.table_name = c.table_name AND t.table_schema = c.table_schema
WHERE t.table_schema = 'public'
  AND t.table_type = 'BASE TABLE'
ORDER BY t.table_name, c.ordinal_position;

-- ============================================================
-- 3. ALL INDEXES
-- ============================================================
SELECT
  tablename,
  indexname,
  indexdef
FROM pg_indexes
WHERE schemaname = 'public'
ORDER BY tablename, indexname;

-- ============================================================
-- 4. ALL FOREIGN KEYS
-- ============================================================
SELECT
  tc.table_name,
  kcu.column_name,
  ccu.table_name AS foreign_table,
  ccu.column_name AS foreign_column,
  tc.constraint_name,
  rc.delete_rule,
  rc.update_rule
FROM information_schema.table_constraints tc
JOIN information_schema.key_column_usage kcu
  ON tc.constraint_name = kcu.constraint_name
JOIN information_schema.constraint_column_usage ccu
  ON ccu.constraint_name = tc.constraint_name
JOIN information_schema.referential_constraints rc
  ON rc.constraint_name = tc.constraint_name
WHERE tc.constraint_type = 'FOREIGN KEY'
  AND tc.table_schema = 'public'
ORDER BY tc.table_name, kcu.column_name;

-- ============================================================
-- 5. ALL UNIQUE CONSTRAINTS
-- ============================================================
SELECT
  tc.table_name,
  tc.constraint_name,
  string_agg(kcu.column_name, ', ' ORDER BY kcu.ordinal_position) AS columns
FROM information_schema.table_constraints tc
JOIN information_schema.key_column_usage kcu
  ON tc.constraint_name = kcu.constraint_name
WHERE tc.constraint_type IN ('UNIQUE', 'PRIMARY KEY')
  AND tc.table_schema = 'public'
GROUP BY tc.table_name, tc.constraint_name
ORDER BY tc.table_name, tc.constraint_name;

-- ============================================================
-- 6. RLS STATUS per table
-- ============================================================
SELECT
  relname AS table_name,
  relrowsecurity AS rls_enabled,
  relforcerowsecurity AS rls_forced
FROM pg_class
WHERE relnamespace = (SELECT oid FROM pg_namespace WHERE nspname = 'public')
  AND relkind = 'r'
ORDER BY relname;

-- ============================================================
-- 7. ALL RLS POLICIES with details
-- ============================================================
SELECT
  schemaname,
  tablename,
  policyname,
  permissive,
  roles,
  cmd,
  qual AS using_expression,
  with_check AS with_check_expression
FROM pg_policies
WHERE schemaname = 'public'
ORDER BY tablename, policyname;

-- ============================================================
-- 8. ALL FUNCTIONS (RPC)
-- ============================================================
SELECT
  p.proname AS function_name,
  pg_get_function_arguments(p.oid) AS arguments,
  pg_get_function_result(p.oid) AS return_type,
  CASE p.prosecdef WHEN true THEN 'SECURITY DEFINER' ELSE 'SECURITY INVOKER' END AS security,
  p.provolatile AS volatility,
  obj_description(p.oid) AS description
FROM pg_proc p
JOIN pg_namespace n ON p.pronamespace = n.oid
WHERE n.nspname = 'public'
  AND p.prokind = 'f'
ORDER BY p.proname;

-- ============================================================
-- 9. ALL TRIGGERS
-- ============================================================
SELECT
  event_object_table AS table_name,
  trigger_name,
  event_manipulation AS event,
  action_timing AS timing,
  action_statement
FROM information_schema.triggers
WHERE trigger_schema = 'public'
ORDER BY event_object_table, trigger_name;

-- ============================================================
-- 10. STORAGE BUCKETS
-- ============================================================
SELECT
  id,
  name,
  public,
  file_size_limit,
  allowed_mime_types,
  created_at
FROM storage.buckets
ORDER BY name;

-- ============================================================
-- 11. STORAGE POLICIES
-- ============================================================
SELECT
  tablename,
  policyname,
  permissive,
  roles,
  cmd,
  qual AS using_expression,
  with_check
FROM pg_policies
WHERE schemaname = 'storage'
ORDER BY tablename, policyname;

-- ============================================================
-- 12. REALTIME PUBLICATIONS
-- ============================================================
SELECT
  p.pubname AS publication_name,
  pt.schemaname,
  pt.tablename
FROM pg_publication p
JOIN pg_publication_tables pt ON p.pubname = pt.pubname
WHERE pt.schemaname = 'public'
ORDER BY pt.tablename;

-- ============================================================
-- 13. EDGE FUNCTIONS (list from vault if available)
-- ============================================================
-- Note: Edge functions are deployed separately.
-- Check supabase/functions/ directory for:
SELECT 'public-products' AS function_name, 'Rate-limited public product API' AS description
UNION ALL SELECT 'upload-product-images', 'Upload to Cloudflare R2'
UNION ALL SELECT 'notify-driver', 'FCM push to delivery drivers'
UNION ALL SELECT 'delivery-webhook', 'Delivery lifecycle events';

-- ============================================================
-- 14. AUTH CONFIGURATION
-- ============================================================
SELECT
  id,
  email,
  phone,
  role,
  created_at,
  last_sign_in_at,
  confirmed_at
FROM auth.users
ORDER BY created_at DESC
LIMIT 20;

-- ============================================================
-- 15. SCHEMA SUMMARY (counts)
-- ============================================================
SELECT 'Tables' AS metric, COUNT(*)::text AS value
FROM pg_tables WHERE schemaname = 'public'
UNION ALL
SELECT 'Columns', COUNT(*)::text
FROM information_schema.columns WHERE table_schema = 'public'
UNION ALL
SELECT 'Indexes', COUNT(*)::text
FROM pg_indexes WHERE schemaname = 'public'
UNION ALL
SELECT 'Foreign Keys', COUNT(*)::text
FROM information_schema.table_constraints WHERE constraint_type = 'FOREIGN KEY' AND table_schema = 'public'
UNION ALL
SELECT 'RLS Policies', COUNT(*)::text
FROM pg_policies WHERE schemaname = 'public'
UNION ALL
SELECT 'Functions (RPC)', COUNT(*)::text
FROM pg_proc p JOIN pg_namespace n ON p.pronamespace = n.oid WHERE n.nspname = 'public' AND p.prokind = 'f'
UNION ALL
SELECT 'Triggers', COUNT(*)::text
FROM information_schema.triggers WHERE trigger_schema = 'public'
UNION ALL
SELECT 'Storage Buckets', COUNT(*)::text
FROM storage.buckets
UNION ALL
SELECT 'Realtime Tables', COUNT(*)::text
FROM pg_publication_tables pt JOIN pg_publication p ON p.pubname = pt.pubname WHERE pt.schemaname = 'public';
