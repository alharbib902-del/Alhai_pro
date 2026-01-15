import { serve } from 'https://deno.land/std@0.168.0/http/server.ts'
import { S3Client, PutObjectCommand } from 'npm:@aws-sdk/client-s3@3'
import { createClient } from 'npm:@supabase/supabase-js@2'

serve(async (req) => {
    try {
        const { product_id, hash, images } = await req.json()

        // 1. Verify authentication
        const authHeader = req.headers.get('Authorization')
        if (!authHeader) {
            return new Response(JSON.stringify({ error: 'Missing auth header' }), {
                status: 401,
                headers: { 'Content-Type': 'application/json' },
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
                headers: { 'Content-Type': 'application/json' },
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

        // 3. Upload each size to R2
        for (const [size, base64Data] of Object.entries(images)) {
            const key = `products/${product_id}_${size}_${hash}.webp`

            // Decode base64
            const binaryString = atob(base64Data as string)
            const bytes = new Uint8Array(binaryString.length)
            for (let i = 0; i < binaryString.length; i++) {
                bytes[i] = binaryString.charCodeAt(i)
            }

            await s3.send(new PutObjectCommand({
                Bucket: 'alhai-public',
                Key: key,
                Body: bytes,
                ContentType: 'image/webp',
                CacheControl: 'public, max-age=31536000, immutable',
            }))

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
                JSON.stringify({ error: 'Failed to update database', details: updateError.message }),
                { status: 500, headers: { 'Content-Type': 'application/json' } }
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
            { headers: { 'Content-Type': 'application/json' } }
        )

    } catch (error) {
        console.error('Upload error:', error)
        return new Response(
            JSON.stringify({ error: 'Upload failed', details: error.message }),
            { status: 500, headers: { 'Content-Type': 'application/json' } }
        )
    }
})
