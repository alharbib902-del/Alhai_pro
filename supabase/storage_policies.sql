-- ============================================================
-- Alhai POS - Supabase Storage Bucket Policies
-- ============================================================
-- Run this SQL in Supabase Dashboard → SQL Editor
-- This creates storage buckets and RLS policies.
-- ============================================================

-- ============================
-- 1. Create Storage Buckets
-- ============================

-- Product images bucket
INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES (
    'product-images',
    'product-images',
    true,
    5242880, -- 5MB
    ARRAY['image/jpeg', 'image/png', 'image/webp']
)
ON CONFLICT (id) DO UPDATE SET
    file_size_limit = EXCLUDED.file_size_limit,
    allowed_mime_types = EXCLUDED.allowed_mime_types;

-- Store logos bucket
INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES (
    'store-logos',
    'store-logos',
    true,
    2097152, -- 2MB
    ARRAY['image/jpeg', 'image/png', 'image/svg+xml', 'image/webp']
)
ON CONFLICT (id) DO UPDATE SET
    file_size_limit = EXCLUDED.file_size_limit,
    allowed_mime_types = EXCLUDED.allowed_mime_types;

-- Receipts bucket (private)
INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES (
    'receipts',
    'receipts',
    false,
    1048576, -- 1MB
    ARRAY['application/pdf', 'image/png']
)
ON CONFLICT (id) DO UPDATE SET
    file_size_limit = EXCLUDED.file_size_limit,
    allowed_mime_types = EXCLUDED.allowed_mime_types;

-- Backups bucket (private)
INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES (
    'backups',
    'backups',
    false,
    52428800, -- 50MB
    ARRAY['application/json', 'application/octet-stream']
)
ON CONFLICT (id) DO UPDATE SET
    file_size_limit = EXCLUDED.file_size_limit,
    allowed_mime_types = EXCLUDED.allowed_mime_types;

-- Invoice attachments bucket (private)
INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES (
    'invoice-attachments',
    'invoice-attachments',
    false,
    10485760, -- 10MB
    ARRAY['image/jpeg', 'image/png', 'application/pdf', 'image/webp']
)
ON CONFLICT (id) DO UPDATE SET
    file_size_limit = EXCLUDED.file_size_limit,
    allowed_mime_types = EXCLUDED.allowed_mime_types;

-- ============================
-- 2. RLS Policies: product-images (public read, auth write)
-- ============================

-- Anyone can view product images
CREATE POLICY "Public read product images"
ON storage.objects FOR SELECT
USING (bucket_id = 'product-images');

-- Authenticated users can upload product images for their store
CREATE POLICY "Auth users upload product images"
ON storage.objects FOR INSERT
TO authenticated
WITH CHECK (
    bucket_id = 'product-images'
    AND EXISTS (
        SELECT 1 FROM public.user_stores us
        WHERE us.user_id = auth.uid()
        AND us.store_id = (storage.foldername(name))[1]::uuid
    )
);

-- Authenticated users can update their store's product images
CREATE POLICY "Auth users update product images"
ON storage.objects FOR UPDATE
TO authenticated
USING (
    bucket_id = 'product-images'
    AND EXISTS (
        SELECT 1 FROM public.user_stores us
        WHERE us.user_id = auth.uid()
        AND us.store_id = (storage.foldername(name))[1]::uuid
    )
);

-- Authenticated users can delete their store's product images
CREATE POLICY "Auth users delete product images"
ON storage.objects FOR DELETE
TO authenticated
USING (
    bucket_id = 'product-images'
    AND EXISTS (
        SELECT 1 FROM public.user_stores us
        WHERE us.user_id = auth.uid()
        AND us.store_id = (storage.foldername(name))[1]::uuid
    )
);

-- ============================
-- 3. RLS Policies: store-logos (public read, auth write)
-- ============================

CREATE POLICY "Public read store logos"
ON storage.objects FOR SELECT
USING (bucket_id = 'store-logos');

CREATE POLICY "Auth users upload store logos"
ON storage.objects FOR INSERT
TO authenticated
WITH CHECK (
    bucket_id = 'store-logos'
    AND EXISTS (
        SELECT 1 FROM public.user_stores us
        WHERE us.user_id = auth.uid()
        AND us.store_id = (storage.foldername(name))[1]::uuid
        AND us.role IN ('owner', 'admin')
    )
);

CREATE POLICY "Auth users update store logos"
ON storage.objects FOR UPDATE
TO authenticated
USING (
    bucket_id = 'store-logos'
    AND EXISTS (
        SELECT 1 FROM public.user_stores us
        WHERE us.user_id = auth.uid()
        AND us.store_id = (storage.foldername(name))[1]::uuid
        AND us.role IN ('owner', 'admin')
    )
);

CREATE POLICY "Auth users delete store logos"
ON storage.objects FOR DELETE
TO authenticated
USING (
    bucket_id = 'store-logos'
    AND EXISTS (
        SELECT 1 FROM public.user_stores us
        WHERE us.user_id = auth.uid()
        AND us.store_id = (storage.foldername(name))[1]::uuid
        AND us.role IN ('owner', 'admin')
    )
);

-- ============================
-- 4. RLS Policies: receipts (private per store)
-- ============================

CREATE POLICY "Auth users read own receipts"
ON storage.objects FOR SELECT
TO authenticated
USING (
    bucket_id = 'receipts'
    AND EXISTS (
        SELECT 1 FROM public.user_stores us
        WHERE us.user_id = auth.uid()
        AND us.store_id = (storage.foldername(name))[1]::uuid
    )
);

CREATE POLICY "Auth users upload receipts"
ON storage.objects FOR INSERT
TO authenticated
WITH CHECK (
    bucket_id = 'receipts'
    AND EXISTS (
        SELECT 1 FROM public.user_stores us
        WHERE us.user_id = auth.uid()
        AND us.store_id = (storage.foldername(name))[1]::uuid
    )
);

-- ============================
-- 5. RLS Policies: backups (owner/admin only)
-- ============================

CREATE POLICY "Owner/admin read backups"
ON storage.objects FOR SELECT
TO authenticated
USING (
    bucket_id = 'backups'
    AND EXISTS (
        SELECT 1 FROM public.user_stores us
        WHERE us.user_id = auth.uid()
        AND us.store_id = (storage.foldername(name))[1]::uuid
        AND us.role IN ('owner', 'admin')
    )
);

CREATE POLICY "Owner/admin upload backups"
ON storage.objects FOR INSERT
TO authenticated
WITH CHECK (
    bucket_id = 'backups'
    AND EXISTS (
        SELECT 1 FROM public.user_stores us
        WHERE us.user_id = auth.uid()
        AND us.store_id = (storage.foldername(name))[1]::uuid
        AND us.role IN ('owner', 'admin')
    )
);

CREATE POLICY "Owner/admin delete backups"
ON storage.objects FOR DELETE
TO authenticated
USING (
    bucket_id = 'backups'
    AND EXISTS (
        SELECT 1 FROM public.user_stores us
        WHERE us.user_id = auth.uid()
        AND us.store_id = (storage.foldername(name))[1]::uuid
        AND us.role IN ('owner', 'admin')
    )
);

-- ============================
-- 6. RLS Policies: invoice-attachments (per store)
-- ============================

CREATE POLICY "Auth users read invoice attachments"
ON storage.objects FOR SELECT
TO authenticated
USING (
    bucket_id = 'invoice-attachments'
    AND EXISTS (
        SELECT 1 FROM public.user_stores us
        WHERE us.user_id = auth.uid()
        AND us.store_id = (storage.foldername(name))[1]::uuid
    )
);

CREATE POLICY "Auth users upload invoice attachments"
ON storage.objects FOR INSERT
TO authenticated
WITH CHECK (
    bucket_id = 'invoice-attachments'
    AND EXISTS (
        SELECT 1 FROM public.user_stores us
        WHERE us.user_id = auth.uid()
        AND us.store_id = (storage.foldername(name))[1]::uuid
    )
);

CREATE POLICY "Auth users delete invoice attachments"
ON storage.objects FOR DELETE
TO authenticated
USING (
    bucket_id = 'invoice-attachments'
    AND EXISTS (
        SELECT 1 FROM public.user_stores us
        WHERE us.user_id = auth.uid()
        AND us.store_id = (storage.foldername(name))[1]::uuid
    )
);
