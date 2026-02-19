-- =====================================================
-- دوال المزامنة لنظام Alhai POS
-- =====================================================
-- apply_stock_deltas: تطبيق تغييرات المخزون (Delta Sync)
-- get_changes_since: جلب التغييرات منذ وقت معين
-- =====================================================

-- ─── جدول تتبع دلتا المخزون على السيرفر ───
CREATE TABLE IF NOT EXISTS stock_deltas (
    id TEXT PRIMARY KEY,
    product_id TEXT NOT NULL REFERENCES products(id),
    store_id TEXT NOT NULL,
    org_id TEXT,
    quantity_change INTEGER NOT NULL,
    device_id TEXT NOT NULL,
    operation_type TEXT NOT NULL, -- sale, return, adjustment, purchase
    reference_id TEXT,
    sync_status TEXT DEFAULT 'synced',
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    synced_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_stock_deltas_product ON stock_deltas(product_id);
CREATE INDEX IF NOT EXISTS idx_stock_deltas_store ON stock_deltas(store_id);
CREATE INDEX IF NOT EXISTS idx_stock_deltas_org ON stock_deltas(org_id);

-- ─── دالة تطبيق تغييرات المخزون ───
-- تستقبل مصفوفة من التغييرات (الدلتا) وتطبقها على المخزون
-- تُرجع المخزون النهائي لكل منتج + علامة oversold
CREATE OR REPLACE FUNCTION apply_stock_deltas(
    p_org_id TEXT,
    p_store_id TEXT,
    p_deltas JSONB
)
RETURNS TABLE (
    product_id TEXT,
    new_stock INTEGER,
    is_oversold BOOLEAN
)
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    delta JSONB;
    v_product_id TEXT;
    v_quantity_change INTEGER;
    v_current_stock INTEGER;
    v_new_stock INTEGER;
BEGIN
    -- إنشاء جدول مؤقت للنتائج
    CREATE TEMP TABLE IF NOT EXISTS _delta_results (
        product_id TEXT PRIMARY KEY,
        new_stock INTEGER,
        is_oversold BOOLEAN DEFAULT FALSE
    ) ON COMMIT DROP;

    -- تطبيق كل دلتا
    FOR delta IN SELECT jsonb_array_elements(p_deltas)
    LOOP
        v_product_id := delta->>'product_id';
        v_quantity_change := (delta->>'quantity_change')::INTEGER;

        -- تسجيل الدلتا في جدول stock_deltas
        INSERT INTO stock_deltas (
            id, product_id, store_id, org_id,
            quantity_change, device_id, operation_type,
            reference_id, created_at
        ) VALUES (
            delta->>'id',
            v_product_id,
            p_store_id,
            p_org_id,
            v_quantity_change,
            delta->>'device_id',
            delta->>'operation_type',
            delta->>'reference_id',
            (delta->>'created_at')::TIMESTAMPTZ
        ) ON CONFLICT (id) DO NOTHING; -- تجاهل التكرار (idempotent)

        -- تحديث المخزون في جدول المنتجات (عملية ذرية)
        UPDATE products
        SET stock_qty = stock_qty + v_quantity_change,
            updated_at = NOW()
        WHERE id = v_product_id
          AND store_id = p_store_id
        RETURNING stock_qty INTO v_new_stock;

        -- إذا لم يُحدث أي سجل، نتخطى
        IF v_new_stock IS NULL THEN
            CONTINUE;
        END IF;

        -- تسجيل النتيجة
        INSERT INTO _delta_results (product_id, new_stock, is_oversold)
        VALUES (v_product_id, v_new_stock, v_new_stock < 0)
        ON CONFLICT (product_id) DO UPDATE
        SET new_stock = EXCLUDED.new_stock,
            is_oversold = EXCLUDED.is_oversold;
    END LOOP;

    -- إرجاع النتائج
    RETURN QUERY SELECT r.product_id, r.new_stock, r.is_oversold
    FROM _delta_results r;
END;
$$;

-- ─── دالة جلب التغييرات منذ وقت معين ───
-- تُستخدم للمزامنة التزايدية (incremental sync)
-- إزالة النسخة القديمة (4 معاملات) من migration 001 لتجنب التعارض
DROP FUNCTION IF EXISTS get_changes_since(TEXT, TEXT, TIMESTAMPTZ, INTEGER);
DROP FUNCTION IF EXISTS get_changes_since(TEXT, TEXT, TIMESTAMPTZ);

CREATE OR REPLACE FUNCTION get_changes_since(
    p_table TEXT,
    p_org_id TEXT,
    p_since TIMESTAMPTZ
)
RETURNS SETOF JSONB
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
    RETURN QUERY EXECUTE format(
        'SELECT to_jsonb(t.*) FROM %I t WHERE t.org_id = $1 AND t.updated_at > $2 ORDER BY t.updated_at ASC',
        p_table
    ) USING p_org_id, p_since;
END;
$$;

-- ─── سياسات RLS للأمان ───
ALTER TABLE stock_deltas ENABLE ROW LEVEL SECURITY;

-- السماح للمستخدمين المصادقين بقراءة وكتابة دلتا المخزون لمؤسستهم فقط
-- ملاحظة: auth.uid() يرجع UUID لذا نحوله لـ TEXT للمقارنة مع user_id
CREATE POLICY "Users can read own org stock deltas"
    ON stock_deltas FOR SELECT
    USING (org_id IN (
        SELECT om.org_id FROM org_members om
        WHERE om.user_id = auth.uid()::TEXT
    ));

CREATE POLICY "Users can insert own org stock deltas"
    ON stock_deltas FOR INSERT
    WITH CHECK (org_id IN (
        SELECT om.org_id FROM org_members om
        WHERE om.user_id = auth.uid()::TEXT
    ));

-- ─── منح الصلاحيات ───
GRANT EXECUTE ON FUNCTION apply_stock_deltas(TEXT, TEXT, JSONB) TO authenticated;
GRANT EXECUTE ON FUNCTION get_changes_since(TEXT, TEXT, TIMESTAMPTZ) TO authenticated;

-- ─── تفعيل Realtime على الجداول المهمة ───
-- products قد تكون مضافة مسبقاً، نتجاهل الخطأ
DO $$
BEGIN
    ALTER PUBLICATION supabase_realtime ADD TABLE products;
EXCEPTION WHEN duplicate_object THEN NULL;
END $$;

DO $$
BEGIN
    ALTER PUBLICATION supabase_realtime ADD TABLE categories;
EXCEPTION WHEN duplicate_object THEN NULL;
END $$;
