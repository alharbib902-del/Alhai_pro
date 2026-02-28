/**
 * Alhai Cashier - PWA Service Worker
 * Cache strategy:
 *   - NetworkFirst  : Supabase API calls (/rest/, /auth/, /functions/, /realtime/)
 *   - CacheFirst    : Static assets (fonts, icons, images, .js, .css, .wasm)
 *   - StaleWhileRevalidate : HTML navigation requests
 *
 * This worker coexists with Flutter's own flutter_service_worker.js.
 * It does NOT intercept flutter_service_worker.js itself, so Flutter's
 * built-in caching is unaffected.
 */

'use strict';

// ─── Cache names ─────────────────────────────────────────────────────────────
const APP_ID        = 'alhai-cashier';
const CACHE_VERSION = 'v1';
const CACHE_NAME    = `${APP_ID}-${CACHE_VERSION}`;

// Separate buckets keep eviction logic clean and prevent cross-contamination.
const CACHE_STATIC  = `${CACHE_NAME}-static`;
const CACHE_PAGES   = `${CACHE_NAME}-pages`;

// ─── Cache limits ─────────────────────────────────────────────────────────────
const MAX_STATIC_ENTRIES = 100;
const MAX_PAGE_ENTRIES   = 20;

// ─── App-shell files to precache on install ───────────────────────────────────
// These are relative to the service worker scope.
const PRECACHE_ASSETS = [
  '/',
  '/index.html',
  '/manifest.json',
  '/favicon.png',
  '/icons/Icon-192.png',
  '/icons/Icon-512.png',
  '/icons/Icon-maskable-192.png',
  '/icons/Icon-maskable-512.png',
  // Flutter bootstrap loader – present after `flutter build web`
  '/flutter_bootstrap.js',
  // Drift / SQLite WASM worker (cashier-specific)
  '/drift_worker.dart.js',
  '/sqlite3.wasm',
];

// ─── URL pattern matchers ────────────────────────────────────────────────────

/**
 * Supabase / API calls – never cache auth tokens or response bodies.
 * Matches:  /rest/v1/…  /auth/v1/…  /functions/v1/…  /realtime/v1/…
 * Also matches the full Supabase project URL pattern.
 */
function isApiRequest(url) {
  return (
    url.pathname.startsWith('/rest/')      ||
    url.pathname.startsWith('/auth/')      ||
    url.pathname.startsWith('/functions/') ||
    url.pathname.startsWith('/realtime/')  ||
    url.hostname.includes('.supabase.co')  ||
    url.hostname.includes('api.anthropic.com')
  );
}

/**
 * Static assets that are safe to serve from cache first.
 * Fonts, icons, compiled JS bundles, CSS, WASM, images.
 */
function isStaticAsset(url) {
  const pathname = url.pathname;
  return (
    /\.(js|css|woff2?|ttf|otf|eot|png|jpg|jpeg|svg|ico|wasm|map)(\?.*)?$/.test(pathname) ||
    pathname.startsWith('/icons/')  ||
    pathname.startsWith('/assets/') ||
    url.hostname === 'fonts.gstatic.com' ||
    url.hostname === 'fonts.googleapis.com'
  );
}

/**
 * Flutter's own service worker and its hash manifest – leave it alone so
 * Flutter's update mechanism continues to work correctly.
 */
function isFlutterServiceWorker(url) {
  return (
    url.pathname.includes('flutter_service_worker') ||
    url.pathname.includes('flutter.js')
  );
}

/**
 * HTML navigation requests (browser navigating to a page).
 */
function isNavigationRequest(request) {
  return (
    request.mode === 'navigate' ||
    request.headers.get('Accept').includes('text/html')
  );
}

// ─── Cache helpers ────────────────────────────────────────────────────────────

/** Trim a cache bucket to at most `maxEntries` items (FIFO). */
async function trimCache(cacheName, maxEntries) {
  const cache = await caches.open(cacheName);
  const keys  = await cache.keys();
  if (keys.length > maxEntries) {
    const toDelete = keys.slice(0, keys.length - maxEntries);
    await Promise.all(toDelete.map((key) => cache.delete(key)));
  }
}

/** Clone + store a response in the given cache bucket, respecting the limit. */
async function storeInCache(cacheName, request, response, maxEntries) {
  // Only cache successful, non-opaque responses to avoid poisoning the cache.
  if (!response || response.status !== 200 || response.type === 'error') return;

  const cache = await caches.open(cacheName);
  await cache.put(request, response.clone());
  await trimCache(cacheName, maxEntries);
}

// ─── Install event ────────────────────────────────────────────────────────────
self.addEventListener('install', (event) => {
  event.waitUntil(
    (async () => {
      const cache = await caches.open(CACHE_STATIC);
      // Precache with individual error handling so one missing file doesn't
      // break the entire install.
      await Promise.allSettled(
        PRECACHE_ASSETS.map((url) =>
          cache.add(url).catch((err) =>
            console.warn(`[SW:cashier] Precache failed for ${url}:`, err)
          )
        )
      );
      console.log('[SW:cashier] Installed – precache complete.');
      // Take control immediately without waiting for old SW to be discarded.
      await self.skipWaiting();
    })()
  );
});

// ─── Activate event ───────────────────────────────────────────────────────────
self.addEventListener('activate', (event) => {
  event.waitUntil(
    (async () => {
      // Delete any cache bucket that doesn't belong to the current version.
      const allCacheKeys = await caches.keys();
      const staleCaches  = allCacheKeys.filter(
        (key) =>
          key.startsWith(APP_ID) &&
          key !== CACHE_STATIC   &&
          key !== CACHE_PAGES
      );
      await Promise.all(staleCaches.map((key) => caches.delete(key)));
      console.log('[SW:cashier] Activated – stale caches removed:', staleCaches);
      // Claim all open clients so the new SW takes effect without a reload.
      await self.clients.claim();
    })()
  );
});

// ─── Fetch event ─────────────────────────────────────────────────────────────
self.addEventListener('fetch', (event) => {
  const request = event.request;
  const url     = new URL(request.url);

  // Only handle GET requests – let POST/PUT/DELETE pass through untouched.
  if (request.method !== 'GET') return;

  // Never intercept chrome-extension, data, or blob URLs.
  if (!['http:', 'https:'].includes(url.protocol)) return;

  // Leave Flutter's own service worker registration alone.
  if (isFlutterServiceWorker(url)) return;

  // ── Strategy 1: NetworkFirst for API / Supabase ──────────────────────────
  if (isApiRequest(url)) {
    event.respondWith(networkFirst(request));
    return;
  }

  // ── Strategy 2: CacheFirst for static assets ────────────────────────────
  if (isStaticAsset(url)) {
    event.respondWith(cacheFirst(request));
    return;
  }

  // ── Strategy 3: StaleWhileRevalidate for HTML navigation ─────────────────
  if (isNavigationRequest(request)) {
    event.respondWith(staleWhileRevalidate(request));
    return;
  }

  // Everything else: plain network pass-through.
});

// ─── Fetch strategies ─────────────────────────────────────────────────────────

/**
 * NetworkFirst – try network, fall back to cache on failure.
 * Used for API calls so we always get fresh data when online.
 * We deliberately do NOT cache Supabase auth/API responses to avoid
 * serving stale tokens or sensitive data.
 */
async function networkFirst(request) {
  try {
    const networkResponse = await fetch(request);
    return networkResponse;
  } catch (_err) {
    // Offline: return a minimal JSON error so the app can handle it gracefully.
    return new Response(
      JSON.stringify({ error: 'offline', message: 'No network connection.' }),
      {
        status: 503,
        headers: {
          'Content-Type': 'application/json',
          'X-SW-Fallback': 'true',
        },
      }
    );
  }
}

/**
 * CacheFirst – serve from cache, fetch and update cache on miss.
 * Used for static assets that rarely change between deployments.
 */
async function cacheFirst(request) {
  const cached = await caches.match(request);
  if (cached) return cached;

  try {
    const networkResponse = await fetch(request);
    await storeInCache(CACHE_STATIC, request, networkResponse, MAX_STATIC_ENTRIES);
    return networkResponse;
  } catch (_err) {
    // Asset not in cache and network is down – nothing we can serve.
    return new Response('Asset unavailable offline.', { status: 503 });
  }
}

/**
 * StaleWhileRevalidate – serve cached version immediately (if any),
 * revalidate in the background, cache the updated version for next time.
 * Offline fallback: return cached index.html so Flutter can bootstrap.
 */
async function staleWhileRevalidate(request) {
  const cache        = await caches.open(CACHE_PAGES);
  const cachedMatch  = await cache.match(request);

  const fetchPromise = fetch(request)
    .then(async (networkResponse) => {
      await storeInCache(CACHE_PAGES, request, networkResponse, MAX_PAGE_ENTRIES);
      return networkResponse;
    })
    .catch(async (_err) => {
      // Network failed – return cached fallback if we have it, else index.html.
      if (cachedMatch) return cachedMatch.clone();
      const fallback = await caches.match('/index.html');
      return (
        fallback ||
        new Response('<h1>Offline</h1>', {
          status: 200,
          headers: { 'Content-Type': 'text/html' },
        })
      );
    });

  // If we have a cached version, return it immediately and revalidate quietly.
  return cachedMatch || fetchPromise;
}
