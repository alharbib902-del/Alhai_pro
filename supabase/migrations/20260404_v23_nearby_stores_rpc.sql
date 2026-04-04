-- ============================================================================
-- v23: دالة RPC للبحث عن المتاجر القريبة باستخدام Haversine
-- ============================================================================
-- بدلاً من جلب جميع المتاجر وتصفيتها في التطبيق، هذه الدالة تقوم بـ:
-- 1. حساب المسافة باستخدام صيغة Haversine على مستوى قاعدة البيانات
-- 2. إرجاع المتاجر النشطة فقط التي لديها إحداثيات
-- 3. ترتيب النتائج حسب المسافة
-- ============================================================================

CREATE OR REPLACE FUNCTION public.get_nearby_stores(
  p_lat DECIMAL,
  p_lng DECIMAL,
  p_radius_km DECIMAL DEFAULT 10
)
RETURNS TABLE (
  id UUID,
  name TEXT,
  name_en TEXT,
  address TEXT,
  phone TEXT,
  email TEXT,
  city TEXT,
  logo TEXT,
  lat DECIMAL,
  lng DECIMAL,
  description TEXT,
  image_url TEXT,
  delivery_radius DECIMAL,
  min_order_amount DECIMAL,
  delivery_fee DECIMAL,
  accepts_delivery BOOLEAN,
  accepts_pickup BOOLEAN,
  is_active BOOLEAN,
  created_at TIMESTAMPTZ,
  updated_at TIMESTAMPTZ,
  distance_km DOUBLE PRECISION
)
LANGUAGE sql
STABLE
SECURITY DEFINER
AS $$
  SELECT
    s.id,
    s.name,
    s.name_en,
    s.address,
    s.phone,
    s.email,
    s.city,
    s.logo,
    s.lat,
    s.lng,
    s.description,
    s.image_url,
    s.delivery_radius,
    s.min_order_amount,
    s.delivery_fee,
    s.accepts_delivery,
    s.accepts_pickup,
    s.is_active,
    s.created_at,
    s.updated_at,
    -- Haversine formula: distance in km
    (
      6371.0 * ACOS(
        LEAST(1.0, -- clamp to avoid NaN from floating point
          COS(RADIANS(p_lat)) * COS(RADIANS(s.lat)) *
          COS(RADIANS(s.lng) - RADIANS(p_lng)) +
          SIN(RADIANS(p_lat)) * SIN(RADIANS(s.lat))
        )
      )
    ) AS distance_km
  FROM public.stores s
  WHERE s.is_active = true
    AND s.lat IS NOT NULL
    AND s.lng IS NOT NULL
    AND (
      -- Haversine distance <= radius
      6371.0 * ACOS(
        LEAST(1.0,
          COS(RADIANS(p_lat)) * COS(RADIANS(s.lat)) *
          COS(RADIANS(s.lng) - RADIANS(p_lng)) +
          SIN(RADIANS(p_lat)) * SIN(RADIANS(s.lat))
        )
      )
    ) <= p_radius_km
  ORDER BY distance_km ASC;
$$;

COMMENT ON FUNCTION public.get_nearby_stores IS 'البحث عن المتاجر القريبة من موقع معين ضمن نطاق محدد بالكيلومتر';

-- Grant execute to authenticated users (customers need this)
GRANT EXECUTE ON FUNCTION public.get_nearby_stores TO authenticated;
GRANT EXECUTE ON FUNCTION public.get_nearby_stores TO anon;
