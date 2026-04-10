// Production origins - always allowed
const PROD_ORIGINS = [
    'https://app.alhai.sa',
    'https://admin.alhai.sa',
    'https://cashier.alhai.sa',
    'https://portal.alhai.sa',
];

// Dev-only origins (localhost). Merged into ALLOWED_ORIGINS only when
// ENVIRONMENT === "development" so production deployments never accept them.
const DEV_ORIGINS = [
    'http://localhost:3000',
    'http://localhost:5173',
];

const ALLOWED_ORIGINS = Deno.env.get('ENVIRONMENT') === 'development'
    ? [...PROD_ORIGINS, ...DEV_ORIGINS]
    : PROD_ORIGINS;

export function getCorsHeaders(req?: Request): Record<string, string> {
    const origin = req?.headers.get('Origin') || '';
    const allowedOrigin = ALLOWED_ORIGINS.includes(origin) ? origin : ALLOWED_ORIGINS[0];

    return {
        'Access-Control-Allow-Origin': allowedOrigin,
        'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type, x-correlation-id',
        'Access-Control-Allow-Methods': 'GET, POST, PUT, PATCH, DELETE, OPTIONS',
        'Vary': 'Origin',
    };
}

// Backwards-compatible export for existing code
export const corsHeaders = {
    'Access-Control-Allow-Origin': ALLOWED_ORIGINS[0],
    'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type, x-correlation-id',
    'Access-Control-Allow-Methods': 'GET, POST, PUT, PATCH, DELETE, OPTIONS',
};
