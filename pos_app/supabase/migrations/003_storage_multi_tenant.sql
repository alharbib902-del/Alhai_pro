-- ============================================================================
-- Alhai POS - Migration 003: Update Storage RLS for Multi-Tenant
-- ============================================================================
-- Updates storage bucket policies to support:
--   - Users accessing images for any of their assigned stores (via user_stores)
--   - Org admins accessing images for all stores in their organization
--   - Public read access remains unchanged
-- ============================================================================

-- ============================================================================
-- 1. DROP OLD STORAGE POLICIES
-- ============================================================================

-- Drop existing private upload/manage policies
DROP POLICY IF EXISTS "store_product_images" ON storage.objects;
DROP POLICY IF EXISTS "store_logos" ON storage.objects;
DROP POLICY IF EXISTS "store_category_images" ON storage.objects;
DROP POLICY IF EXISTS "store_avatars" ON storage.objects;
DROP POLICY IF EXISTS "store_receipt_images" ON storage.objects;
DROP POLICY IF EXISTS "store_whatsapp_media" ON storage.objects;

-- Keep public read policies (they don't need tenant isolation)
-- "public_product_images_read", "public_store_logos_read", etc. remain

-- ============================================================================
-- 2. NEW MULTI-TENANT STORAGE POLICIES
-- ============================================================================

-- Helper: Check if user can access a store's files
-- Files are stored as: {store_id}/...
-- User can access if:
--   a) store_id is in their user_stores, OR
--   b) they are an org admin for the store's organization

-- ── Product Images ──────────────────────────────────────────────────────────

-- INSERT (upload new images)
CREATE POLICY "mt_product_images_insert"
    ON storage.objects FOR INSERT
    WITH CHECK (
        bucket_id = 'product-images'
        AND auth.role() = 'authenticated'
        AND (
            -- User has access to the store folder
            (storage.foldername(name))[1] IN (SELECT get_user_store_ids())
            OR is_org_admin()
        )
    );

-- SELECT (read own store images - for authenticated, supplements public read)
CREATE POLICY "mt_product_images_select"
    ON storage.objects FOR SELECT
    USING (
        bucket_id = 'product-images'
        AND (
            auth.role() = 'anon'  -- public read
            OR (storage.foldername(name))[1] IN (SELECT get_user_store_ids())
            OR is_org_admin()
        )
    );

-- UPDATE (replace existing images)
CREATE POLICY "mt_product_images_update"
    ON storage.objects FOR UPDATE
    USING (
        bucket_id = 'product-images'
        AND auth.role() = 'authenticated'
        AND (
            (storage.foldername(name))[1] IN (SELECT get_user_store_ids())
            OR is_org_admin()
        )
    );

-- DELETE (remove images)
CREATE POLICY "mt_product_images_delete"
    ON storage.objects FOR DELETE
    USING (
        bucket_id = 'product-images'
        AND auth.role() = 'authenticated'
        AND (
            (storage.foldername(name))[1] IN (SELECT get_user_store_ids())
            OR is_org_admin()
        )
    );

-- ── Category Images ─────────────────────────────────────────────────────────

CREATE POLICY "mt_category_images_insert"
    ON storage.objects FOR INSERT
    WITH CHECK (
        bucket_id = 'category-images'
        AND auth.role() = 'authenticated'
        AND (
            (storage.foldername(name))[1] IN (SELECT get_user_store_ids())
            OR is_org_admin()
        )
    );

CREATE POLICY "mt_category_images_update"
    ON storage.objects FOR UPDATE
    USING (
        bucket_id = 'category-images'
        AND auth.role() = 'authenticated'
        AND (
            (storage.foldername(name))[1] IN (SELECT get_user_store_ids())
            OR is_org_admin()
        )
    );

CREATE POLICY "mt_category_images_delete"
    ON storage.objects FOR DELETE
    USING (
        bucket_id = 'category-images'
        AND auth.role() = 'authenticated'
        AND (
            (storage.foldername(name))[1] IN (SELECT get_user_store_ids())
            OR is_org_admin()
        )
    );

-- ── Store Logos ──────────────────────────────────────────────────────────────

CREATE POLICY "mt_store_logos_insert"
    ON storage.objects FOR INSERT
    WITH CHECK (
        bucket_id = 'store-logos'
        AND auth.role() = 'authenticated'
        AND (
            (storage.foldername(name))[1] IN (SELECT get_user_store_ids())
            OR is_org_admin()
        )
    );

CREATE POLICY "mt_store_logos_update"
    ON storage.objects FOR UPDATE
    USING (
        bucket_id = 'store-logos'
        AND auth.role() = 'authenticated'
        AND (
            (storage.foldername(name))[1] IN (SELECT get_user_store_ids())
            OR is_org_admin()
        )
    );

CREATE POLICY "mt_store_logos_delete"
    ON storage.objects FOR DELETE
    USING (
        bucket_id = 'store-logos'
        AND auth.role() = 'authenticated'
        AND (
            (storage.foldername(name))[1] IN (SELECT get_user_store_ids())
            OR is_org_admin()
        )
    );

-- ── Avatars ─────────────────────────────────────────────────────────────────

CREATE POLICY "mt_avatars_insert"
    ON storage.objects FOR INSERT
    WITH CHECK (
        bucket_id = 'avatars'
        AND auth.role() = 'authenticated'
        AND (
            (storage.foldername(name))[1] IN (SELECT get_user_store_ids())
            OR is_org_admin()
        )
    );

CREATE POLICY "mt_avatars_update"
    ON storage.objects FOR UPDATE
    USING (
        bucket_id = 'avatars'
        AND auth.role() = 'authenticated'
        AND (
            (storage.foldername(name))[1] IN (SELECT get_user_store_ids())
            OR is_org_admin()
        )
    );

CREATE POLICY "mt_avatars_delete"
    ON storage.objects FOR DELETE
    USING (
        bucket_id = 'avatars'
        AND auth.role() = 'authenticated'
        AND (
            (storage.foldername(name))[1] IN (SELECT get_user_store_ids())
            OR is_org_admin()
        )
    );

-- ── Receipt Images (PRIVATE bucket) ────────────────────────────────────────

CREATE POLICY "mt_receipt_images_insert"
    ON storage.objects FOR INSERT
    WITH CHECK (
        bucket_id = 'receipt-images'
        AND auth.role() = 'authenticated'
        AND (
            (storage.foldername(name))[1] IN (SELECT get_user_store_ids())
            OR is_org_admin()
        )
    );

CREATE POLICY "mt_receipt_images_select"
    ON storage.objects FOR SELECT
    USING (
        bucket_id = 'receipt-images'
        AND auth.role() = 'authenticated'
        AND (
            (storage.foldername(name))[1] IN (SELECT get_user_store_ids())
            OR is_org_admin()
        )
    );

CREATE POLICY "mt_receipt_images_update"
    ON storage.objects FOR UPDATE
    USING (
        bucket_id = 'receipt-images'
        AND auth.role() = 'authenticated'
        AND (
            (storage.foldername(name))[1] IN (SELECT get_user_store_ids())
            OR is_org_admin()
        )
    );

CREATE POLICY "mt_receipt_images_delete"
    ON storage.objects FOR DELETE
    USING (
        bucket_id = 'receipt-images'
        AND auth.role() = 'authenticated'
        AND (
            (storage.foldername(name))[1] IN (SELECT get_user_store_ids())
            OR is_org_admin()
        )
    );

-- ── WhatsApp Media (PRIVATE bucket) ────────────────────────────────────────

CREATE POLICY "mt_whatsapp_media_insert"
    ON storage.objects FOR INSERT
    WITH CHECK (
        bucket_id = 'whatsapp-media'
        AND auth.role() = 'authenticated'
        AND (
            (storage.foldername(name))[1] IN (SELECT get_user_store_ids())
            OR is_org_admin()
        )
    );

CREATE POLICY "mt_whatsapp_media_select"
    ON storage.objects FOR SELECT
    USING (
        bucket_id = 'whatsapp-media'
        AND auth.role() = 'authenticated'
        AND (
            (storage.foldername(name))[1] IN (SELECT get_user_store_ids())
            OR is_org_admin()
        )
    );

CREATE POLICY "mt_whatsapp_media_update"
    ON storage.objects FOR UPDATE
    USING (
        bucket_id = 'whatsapp-media'
        AND auth.role() = 'authenticated'
        AND (
            (storage.foldername(name))[1] IN (SELECT get_user_store_ids())
            OR is_org_admin()
        )
    );

CREATE POLICY "mt_whatsapp_media_delete"
    ON storage.objects FOR DELETE
    USING (
        bucket_id = 'whatsapp-media'
        AND auth.role() = 'authenticated'
        AND (
            (storage.foldername(name))[1] IN (SELECT get_user_store_ids())
            OR is_org_admin()
        )
    );

-- ============================================================================
-- DONE!
-- ============================================================================
-- Storage structure:
--
--   product-images/
--     └── {store_id}/
--         └── {product_id}/
--             ├── thumb_{hash}.jpg    (300px)
--             ├── medium_{hash}.jpg   (600px)
--             └── large_{hash}.jpg    (1200px)
--
--   category-images/
--     └── {store_id}/{category_id}.jpg
--
--   store-logos/
--     └── {store_id}/logo.png
--
--   avatars/
--     └── {store_id}/{user_id}.jpg
--
--   receipt-images/     (private)
--     └── {store_id}/{receipt_id}.pdf
--
--   whatsapp-media/     (private)
--     └── {store_id}/{message_id}.{ext}
-- ============================================================================
