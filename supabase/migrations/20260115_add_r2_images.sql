-- Migration: Add R2 Image Storage Columns
-- Created: 2026-01-15
-- Description: Adds support for multiple image sizes stored on Cloudflare R2

-- Add new image columns
ALTER TABLE products 
ADD COLUMN IF NOT EXISTS image_thumbnail TEXT,
ADD COLUMN IF NOT EXISTS image_medium TEXT,
ADD COLUMN IF NOT EXISTS image_large TEXT,
ADD COLUMN IF NOT EXISTS image_hash TEXT,
ADD COLUMN IF NOT EXISTS image_updated_at TIMESTAMPTZ;

-- Migrate existing imageUrl to image_thumbnail
UPDATE products 
SET image_thumbnail = image_url
WHERE image_url IS NOT NULL AND image_thumbnail IS NULL;

-- Add comments for documentation
COMMENT ON COLUMN products.image_url IS 'Deprecated - use image_thumbnail/medium/large instead';
COMMENT ON COLUMN products.image_thumbnail IS 'R2 CDN URL - 300x300px thumbnail';
COMMENT ON COLUMN products.image_medium IS 'R2 CDN URL - 600x600px medium';
COMMENT ON COLUMN products.image_large IS 'R2 CDN URL - 1200x1200px large';
COMMENT ON COLUMN products.image_hash IS 'SHA-256 hash (8 chars) for versioning';

-- Create index on image_hash for faster lookups
CREATE INDEX IF NOT EXISTS idx_products_image_hash ON products(image_hash);
