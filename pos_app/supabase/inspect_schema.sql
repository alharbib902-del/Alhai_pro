-- ============================================================================
-- Alhai POS - فحص شامل للقاعدة (جداول + دوال + RLS)
-- ============================================================================

-- ============================================================================
-- 1. جميع الجداول مع عدد الأعمدة والسطور
-- ============================================================================
SELECT
    t.table_name AS "الجدول",
    (SELECT COUNT(*) FROM information_schema.columns c WHERE c.table_name = t.table_name AND c.table_schema = 'public') AS "عدد_الأعمدة",
    pg_stat_user_tables.n_live_tup AS "عدد_السطور",
    CASE WHEN rls.relrowsecurity THEN 'مفعّل' ELSE 'معطّل' END AS "RLS"
FROM information_schema.tables t
LEFT JOIN pg_stat_user_tables ON pg_stat_user_tables.relname = t.table_name
LEFT JOIN pg_class rls ON rls.relname = t.table_name AND rls.relnamespace = 'public'::regnamespace
WHERE t.table_schema = 'public'
AND t.table_type = 'BASE TABLE'
ORDER BY t.table_name;

-- ============================================================================
-- 2. جميع الأعمدة لكل جدول
-- ============================================================================
SELECT
    table_name AS "الجدول",
    column_name AS "العمود",
    data_type AS "النوع",
    is_nullable AS "قابل_للفراغ",
    column_default AS "القيمة_الافتراضية"
FROM information_schema.columns
WHERE table_schema = 'public'
ORDER BY table_name, ordinal_position;

-- ============================================================================
-- 3. جميع العلاقات (Foreign Keys)
-- ============================================================================
SELECT
    tc.table_name AS "الجدول",
    kcu.column_name AS "العمود",
    ccu.table_name AS "يشير_إلى_جدول",
    ccu.column_name AS "يشير_إلى_عمود",
    rc.delete_rule AS "عند_الحذف"
FROM information_schema.table_constraints tc
JOIN information_schema.key_column_usage kcu
    ON tc.constraint_name = kcu.constraint_name AND tc.table_schema = kcu.table_schema
JOIN information_schema.constraint_column_usage ccu
    ON ccu.constraint_name = tc.constraint_name AND ccu.table_schema = tc.table_schema
JOIN information_schema.referential_constraints rc
    ON rc.constraint_name = tc.constraint_name AND rc.constraint_schema = tc.table_schema
WHERE tc.constraint_type = 'FOREIGN KEY'
AND tc.table_schema = 'public'
ORDER BY tc.table_name, kcu.column_name;

-- ============================================================================
-- 4. جميع الفهارس (Indexes)
-- ============================================================================
SELECT
    tablename AS "الجدول",
    indexname AS "الفهرس",
    indexdef AS "التعريف"
FROM pg_indexes
WHERE schemaname = 'public'
ORDER BY tablename, indexname;

-- ============================================================================
-- 5. جميع سياسات RLS
-- ============================================================================
SELECT
    schemaname AS "المخطط",
    tablename AS "الجدول",
    policyname AS "السياسة",
    permissive AS "نوع",
    roles AS "الأدوار",
    cmd AS "العملية",
    qual AS "شرط_القراءة",
    with_check AS "شرط_الكتابة"
FROM pg_policies
WHERE schemaname = 'public'
ORDER BY tablename, policyname;

-- ============================================================================
-- 6. جميع الدوال (Functions)
-- ============================================================================
SELECT
    p.proname AS "الدالة",
    pg_get_function_arguments(p.oid) AS "المعاملات",
    pg_get_function_result(p.oid) AS "نوع_الإرجاع",
    CASE p.prosecdef WHEN TRUE THEN 'SECURITY DEFINER' ELSE 'INVOKER' END AS "الأمان",
    CASE p.provolatile WHEN 'i' THEN 'IMMUTABLE' WHEN 's' THEN 'STABLE' ELSE 'VOLATILE' END AS "الثبات",
    l.lanname AS "اللغة"
FROM pg_proc p
JOIN pg_namespace n ON n.oid = p.pronamespace
JOIN pg_language l ON l.oid = p.prolang
WHERE n.nspname = 'public'
ORDER BY p.proname;

-- ============================================================================
-- 7. جميع الـ Triggers
-- ============================================================================
SELECT
    event_object_table AS "الجدول",
    trigger_name AS "الـTrigger",
    event_manipulation AS "الحدث",
    action_timing AS "التوقيت",
    action_statement AS "الإجراء"
FROM information_schema.triggers
WHERE trigger_schema = 'public'
ORDER BY event_object_table, trigger_name;

-- ============================================================================
-- 8. Storage Buckets
-- ============================================================================
SELECT
    id AS "البكت",
    name AS "الاسم",
    public AS "عام",
    file_size_limit AS "حد_الحجم",
    allowed_mime_types AS "الأنواع_المسموحة",
    created_at AS "تاريخ_الإنشاء"
FROM storage.buckets
ORDER BY name;

-- ============================================================================
-- 9. سياسات RLS على Storage
-- ============================================================================
SELECT
    policyname AS "السياسة",
    permissive AS "نوع",
    roles AS "الأدوار",
    cmd AS "العملية",
    qual AS "شرط_القراءة",
    with_check AS "شرط_الكتابة"
FROM pg_policies
WHERE schemaname = 'storage' AND tablename = 'objects'
ORDER BY policyname;

-- ============================================================================
-- 10. Realtime Publications
-- ============================================================================
SELECT
    p.pubname AS "المنشور",
    pt.schemaname AS "المخطط",
    pt.tablename AS "الجدول"
FROM pg_publication p
JOIN pg_publication_tables pt ON p.pubname = pt.pubname
WHERE p.pubname = 'supabase_realtime'
ORDER BY pt.tablename;

-- ============================================================================
-- 11. ملخص إحصائي
-- ============================================================================
SELECT 'جداول' AS "العنصر",
    COUNT(*)::TEXT AS "العدد"
FROM information_schema.tables
WHERE table_schema = 'public' AND table_type = 'BASE TABLE'

UNION ALL

SELECT 'أعمدة',
    COUNT(*)::TEXT
FROM information_schema.columns
WHERE table_schema = 'public'

UNION ALL

SELECT 'علاقات (FK)',
    COUNT(*)::TEXT
FROM information_schema.table_constraints
WHERE table_schema = 'public' AND constraint_type = 'FOREIGN KEY'

UNION ALL

SELECT 'فهارس',
    COUNT(*)::TEXT
FROM pg_indexes
WHERE schemaname = 'public'

UNION ALL

SELECT 'سياسات RLS',
    COUNT(*)::TEXT
FROM pg_policies
WHERE schemaname = 'public'

UNION ALL

SELECT 'سياسات Storage',
    COUNT(*)::TEXT
FROM pg_policies
WHERE schemaname = 'storage' AND tablename = 'objects'

UNION ALL

SELECT 'دوال',
    COUNT(*)::TEXT
FROM pg_proc p
JOIN pg_namespace n ON n.oid = p.pronamespace
WHERE n.nspname = 'public'

UNION ALL

SELECT 'Triggers',
    COUNT(*)::TEXT
FROM information_schema.triggers
WHERE trigger_schema = 'public'

UNION ALL

SELECT 'Storage Buckets',
    COUNT(*)::TEXT
FROM storage.buckets

UNION ALL

SELECT 'Realtime Tables',
    COUNT(*)::TEXT
FROM pg_publication_tables
WHERE pubname = 'supabase_realtime'

ORDER BY "العنصر";
