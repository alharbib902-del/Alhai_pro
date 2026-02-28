import { serve } from 'https://deno.land/std@0.168.0/http/server.ts'
import { S3Client, PutObjectCommand } from 'npm:@aws-sdk/client-s3@3'
import { createClient } from 'npm:@supabase/supabase-js@2'
import { getCorsHeaders } from '../_shared/cors.ts'

/**
 * Detect the image format from magic bytes in the binary data.
 * Returns { mime, ext } for JPEG, PNG, WebP, or defaults to JPEG.
 */
function detectImageFormat(bytes: Uint8Array): { mime: string; ext: string } {
    // JPEG: starts with FF D8 FF
    if (bytes.length >= 3 && bytes[0] === 0xFF && bytes[1] === 0xD8 && bytes[2] === 0xFF) {
        return { mime: 'image/jpeg', ext: 'jpg' }
    }
    // PNG: starts with 89 50 4E 47
    if (bytes.length >= 4 && bytes[0] === 0x89 && bytes[1] === 0x50 && bytes[2] === 0x4E && bytes[3] === 0x47) {
        return { mime: 'image/png', ext: 'png' }
    }
    // WebP: starts with RIFF....WEBP (bytes 0-3 = RIFF, bytes 8-11 = WEBP)
    if (bytes.length >= 12 && bytes[0] === 0x52 && bytes[1] === 0x49 && bytes[2] === 0x46 && bytes[3] === 0x46
        && bytes[8] === 0x57 && bytes[9] === 0x45 && bytes[10] === 0x42 && bytes[11] === 0x50) {
        return { mime: 'image/webp', ext: 'webp' }
    }
    // Default to JPEG (the Dart client encodes as JPEG)
    return { mime: 'image/jpeg', ext: 'jpg' }
}

serve(async (req) => {
    const cors = getCorsHeaders(req)

    // Handle CORS preflight (M154 fix)
    if (req.method === 'OPTIONS') {
        return new Response('ok', { headers: cors })
    }

    try {
        const { product_id, hash, images } = await req.json()

        // 1. Verify authentication
        const authHeader = req.headers.get('Authorization')
        if (!authHeader) {
            return new Response(JSON.stringify({ error: 'Missing auth header' }), {
                status: 401,
                headers: { 'Content-Type': 'application/json', ...cors },
            })
        }

        const supabase = createClient(
            Deno.env.get('SUPABASE_URL')!,
            Deno.env.get('SUPABASE_ANON_KEY')!,
            { global: { headers: { Authorization: authHeader } } }
        )

        const { data: { user }, error: authError } = await supabase.auth.getUser()
        if (authError || !user) {
            return new Response(JSON.stringify({ error: 'Unauthorized' }), {
                status: 401,
                headers: { 'Content-Type': 'application/json', ...cors },
            })
        }

        // 1b. Validate required fields
        if (!product_id || typeof product_id !== 'string') {
            return new Response(JSON.stringify({ error: 'product_id is required' }), {
                status: 400, headers: { 'Content-Type': 'application/json', ...cors },
            })
        }
        if (!images || typeof images !== 'object' || Object.keys(images).length === 0) {
            return new Response(JSON.stringify({ error: 'images object is required' }), {
                status: 400, headers: { 'Content-Type': 'application/json', ...cors },
            })
        }

        // 1c. Validate image sizes (max 5MB per image after base64 decode)
        const MAX_IMAGE_SIZE = 5 * 1024 * 1024; // 5MB
        const ALLOWED_SIZES = ['thumb', 'medium', 'large'];
        for (const [size, base64Data] of Object.entries(images)) {
            if (!ALLOWED_SIZES.includes(size)) {
                return new Response(JSON.stringify({ error: `Invalid image size key: ${size}` }), {
                    status: 400, headers: { 'Content-Type': 'application/json', ...cors },
                })
            }
            if (typeof base64Data !== 'string') {
                return new Response(JSON.stringify({ error: `Image data for ${size} must be a base64 string` }), {
                    status: 400, headers: { 'Content-Type': 'application/json', ...cors },
                })
            }
            // base64 string length * 3/4 ≈ decoded byte size
            const estimatedBytes = (base64Data as string).length * 3 / 4;
            if (estimatedBytes > MAX_IMAGE_SIZE) {
                return new Response(JSON.stringify({ error: `Image ${size} exceeds 5MB limit` }), {
                    status: 400, headers: { 'Content-Type': 'application/json', ...cors },
                })
            }
        }

        // 1d. Verify user owns/manages this product's store
        const serviceClient = createClient(
            Deno.env.get('SUPABASE_URL')!,
            Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!,
        )
        const { data: product } = await serviceClient
            .from('products')
            .select('store_id')
            .eq('id', product_id)
            .single()

        if (!product) {
            return new Response(JSON.stringify({ error: 'Product not found' }), {
                status: 404, headers: { 'Content-Type': 'application/json', ...cors },
            })
        }

        const { data: membership } = await serviceClient
            .from('user_stores')
            .select('role')
            .eq('user_id', user.id)
            .eq('store_id', product.store_id)
            .single()

        if (!membership) {
            return new Response(JSON.stringify({ error: 'You do not have access to this store' }), {
                status: 403, headers: { 'Content-Type': 'application/json', ...cors },
            })
        }

        // 2. Initialize R2 client
        const s3 = new S3Client({
            region: 'auto',
            endpoint: Deno.env.get('R2_ENDPOINT'),
            credentials: {
                accessKeyId: Deno.env.get('R2_ACCESS_KEY_ID')!,
                secretAccessKey: Deno.env.get('R2_SECRET_ACCESS_KEY')!,
            },
        })

        const urls: Record<string, string> = {}

        // 3. Upload each size to R2 (auto-detect image format from magic bytes)
        for (const [size, base64Data] of Object.entries(images)) {
            // Decode base64
            const binaryString = atob(base64Data as string)
            const bytes = new Uint8Array(binaryString.length)
            for (let i = 0; i < binaryString.length; i++) {
                bytes[i] = binaryString.charCodeAt(i)
            }

            // Detect actual image format from binary content
            const format = detectImageFormat(bytes)
            const key = `products/${product_id}_${size}_${hash}.${format.ext}`

            await s3.send(new PutObjectCommand({
                Bucket: 'alhai-public',
                Key: key,
                Body: bytes,
                ContentType: format.mime,
                CacheControl: 'public, max-age=31536000, immutable',
            }))

            // CDN domain: cdn.alhai.sa is a CNAME pointing to the R2 public bucket
            // (alhai-public.r2.dev). DNS is managed in Cloudflare. Update the CNAME
            // record there if the R2 bucket or account changes.
            urls[size] = `https://cdn.alhai.sa/${key}`
        }

        // 4. Update database
        const { error: updateError } = await supabase
            .from('products')
            .update({
                image_thumbnail: urls['thumb'],
                image_medium: urls['medium'],
                image_large: urls['large'],
                image_hash: hash,
                image_updated_at: new Date().toISOString(),
            })
            .eq('id', product_id)

        if (updateError) {
            console.error('Database update error:', updateError)
            return new Response(
                JSON.stringify({ error: 'Failed to update database' }),
                { status: 500, headers: { 'Content-Type': 'application/json', ...cors } }
            )
        }

        return new Response(
            JSON.stringify({
                success: true,
                urls: {
                    imageThumbnail: urls['thumb'],
                    imageMedium: urls['medium'],
                    imageLarge: urls['large'],
                    imageHash: hash,
                }
            }),
            { headers: { 'Content-Type': 'application/json', ...cors } }
        )

    } catch (error) {
        console.error('Upload error:', error)
        return new Response(
            JSON.stringify({ error: 'Upload failed' }),
            { status: 500, headers: { 'Content-Type': 'application/json', ...cors } }
        )
    }
})
