import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'
import { corsHeaders } from '../_shared/cors.ts'

const RATE_LIMIT_REQUESTS = 100;  // per minute per IP
const RATE_LIMIT_WINDOW = 60000;  // 1 minute in ms

// Simple in-memory rate limiter (use Redis in production for distributed)
const rateLimitMap = new Map<string, { count: number; resetAt: number }>();

Deno.serve(async (req) => {
    // Handle CORS preflight
    if (req.method === 'OPTIONS') {
        return new Response('ok', { headers: corsHeaders });
    }

    const url = new URL(req.url);
    const storeId = url.searchParams.get('store_id');
    const page = parseInt(url.searchParams.get('page') || '1');
    const limit = Math.min(parseInt(url.searchParams.get('limit') || '20'), 50);
    const categoryId = url.searchParams.get('category_id');
    const search = url.searchParams.get('search');

    // 1. Validate store_id is REQUIRED
    if (!storeId) {
        return new Response(
            JSON.stringify({
                code: 'VALIDATION_ERROR',
                message: 'store_id is required'
            }),
            {
                status: 400,
                headers: { ...corsHeaders, 'Content-Type': 'application/json' }
            }
        );
    }

    // 2. Rate limiting per IP + store
    const clientIp = req.headers.get('x-forwarded-for')?.split(',')[0] || 'unknown';
    const rateLimitKey = `${clientIp}:${storeId}`;
    const now = Date.now();
    const rateLimit = rateLimitMap.get(rateLimitKey);

    if (rateLimit) {
        if (now < rateLimit.resetAt) {
            if (rateLimit.count >= RATE_LIMIT_REQUESTS) {
                return new Response(
                    JSON.stringify({
                        code: 'RATE_LIMITED',
                        message: 'Too many requests. Please try again later.'
                    }),
                    {
                        status: 429,
                        headers: {
                            ...corsHeaders,
                            'Content-Type': 'application/json',
                            'Retry-After': Math.ceil((rateLimit.resetAt - now) / 1000).toString()
                        }
                    }
                );
            }
            rateLimit.count++;
        } else {
            rateLimitMap.set(rateLimitKey, { count: 1, resetAt: now + RATE_LIMIT_WINDOW });
        }
    } else {
        rateLimitMap.set(rateLimitKey, { count: 1, resetAt: now + RATE_LIMIT_WINDOW });
    }

    // 3. Create Supabase client with service role (bypasses RLS)
    const supabaseUrl = Deno.env.get('SUPABASE_URL');
    const supabaseKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY');

    if (!supabaseUrl || !supabaseKey) {
        return new Response(
            JSON.stringify({ code: 'SERVER_ERROR', message: 'Server configuration error' }),
            { status: 500, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
        );
    }

    const supabase = createClient(supabaseUrl, supabaseKey);

    // 4. Verify store exists and is active
    const { data: store, error: storeError } = await supabase
        .from('stores')
        .select('id, name, is_active')
        .eq('id', storeId)
        .single();

    if (storeError || !store) {
        return new Response(
            JSON.stringify({ code: 'NOT_FOUND', message: 'Store not found' }),
            { status: 404, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
        );
    }

    if (!store.is_active) {
        return new Response(
            JSON.stringify({ code: 'FORBIDDEN', message: 'Store is not active' }),
            { status: 403, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
        );
    }

    // 5. Query products with ENFORCED store_id filter
    let query = supabase
        .from('products')
        .select('id, name, name_ar, barcode, sku, category_id, price, image_thumbnail, image_medium, stock_qty, min_stock_level, is_active, created_at', { count: 'exact' })
        .eq('store_id', storeId)
        .eq('is_active', true)
        .order('name')
        .range((page - 1) * limit, page * limit - 1);

    if (categoryId) {
        query = query.eq('category_id', categoryId);
    }
    if (search) {
        query = query.or(`name.ilike.%${search}%,name_ar.ilike.%${search}%,barcode.eq.${search}`);
    }

    const { data: products, error, count } = await query;

    if (error) {
        console.error('Products query error:', error);
        return new Response(
            JSON.stringify({ code: 'SERVER_ERROR', message: 'Failed to fetch products' }),
            { status: 500, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
        );
    }

    // 6. Return with standardized envelope
    return new Response(
        JSON.stringify({
            data: products || [],
            meta: {
                page,
                limit,
                total: count || 0,
                hasMore: count ? page * limit < count : false,
                storeId,
                storeName: store.name,
                timestamp: new Date().toISOString()
            }
        }),
        {
            status: 200,
            headers: { ...corsHeaders, 'Content-Type': 'application/json' }
        }
    );
});
