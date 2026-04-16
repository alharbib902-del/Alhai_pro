# Distributor Portal — Web Deployment Guide

> This is the **highest priority** deployment — the distributor portal is a web app that can be deployed immediately.

## Overview

| Item | Value |
|------|-------|
| **Platform** | Flutter Web (PWA-capable) |
| **Version** | 1.0.0-beta.1 |
| **Build output** | `distributor_portal/build/web/` |
| **Recommended host** | Netlify (free tier) |
| **Custom domain** | e.g., `portal.alhai.store` |

---

## 1. Build for Production

```bash
cd distributor_portal

# Install dependencies
flutter pub get

# Build release
flutter build web --release --dart-define-from-file=.env

# Output directory: build/web/
# This contains index.html, main.dart.js, assets, etc.
```

### Verify Build Locally

```bash
# Install a local server (if needed)
npx serve build/web

# Open http://localhost:3000 and test:
# - Login / registration
# - Distributor dashboard
# - Invoice creation
# - MFA enrollment (super_admin)
```

---

## 2. Deploy to Netlify (Recommended)

### 2.1 Option A: Connect GitHub (CI/CD)

1. **Create Netlify account** at https://app.netlify.com
2. **New site** → Import from Git → Select your GitHub repo
3. **Build settings:**

   | Setting | Value |
   |---------|-------|
   | Base directory | `distributor_portal` |
   | Build command | `flutter build web --release --dart-define-from-file=.env` |
   | Publish directory | `distributor_portal/build/web` |
   | Node version | Not required |

4. **Environment variables** (Netlify Dashboard → Site → Environment variables):

   ```
   SUPABASE_URL=https://your-project.supabase.co
   SUPABASE_ANON_KEY=your-anon-key
   SENTRY_DSN_DISTRIBUTOR=https://your-sentry-dsn
   FLAVOR=prod
   ```

   > **Note:** Netlify's env vars are used to generate `.env` at build time. You may need a build plugin or `prebuild` script to write these to a `.env` file before `flutter build web` runs.

5. **Deploy trigger:** Auto-deploy on push to `main` branch.

### 2.2 Option B: Manual Deploy (CLI)

```bash
# Install Netlify CLI
npm install -g netlify-cli

# Login
netlify login

# Build locally
cd distributor_portal
flutter build web --release --dart-define-from-file=.env

# Deploy
netlify deploy --dir=build/web --prod

# First time: will prompt to create/link a site
```

### 2.3 Option C: Drag-and-Drop

1. Build locally: `flutter build web --release --dart-define-from-file=.env`
2. Go to https://app.netlify.com/drop
3. Drag the `distributor_portal/build/web` folder
4. Done — Netlify assigns a random `.netlify.app` URL

---

## 3. Custom Domain Setup

### 3.1 Netlify Domain Configuration

1. **Netlify Dashboard** → Site → Domain settings → Add custom domain
2. Enter: `portal.alhai.store` (or your preferred subdomain)
3. **DNS Configuration** — add these records at your DNS provider:

   | Type | Name | Value |
   |------|------|-------|
   | CNAME | portal | `your-site-name.netlify.app` |

   Or if using apex domain (`alhai.store`):

   | Type | Name | Value |
   |------|------|-------|
   | A | @ | `75.2.60.5` (Netlify load balancer) |

4. **Wait for DNS propagation** (up to 48 hours, usually minutes)

### 3.2 HTTPS / SSL

- Netlify provides **free SSL** via Let's Encrypt automatically.
- Force HTTPS: Netlify Dashboard → Domain settings → HTTPS → Force HTTPS ✓
- Certificate auto-renews every 90 days.

---

## 4. Security Headers

The `distributor_portal/web/index.html` already includes CSP and security meta tags:

```html
<!-- Content Security Policy -->
<meta http-equiv="Content-Security-Policy" content="
  default-src 'self';
  script-src 'self' 'unsafe-inline';
  style-src 'self' 'unsafe-inline';
  img-src 'self' data: blob:;
  font-src 'self' https://fonts.gstatic.com;
  connect-src 'self' https://*.supabase.co https://*.supabase.in wss://*.supabase.co;
  frame-ancestors 'none';
  base-uri 'self';
  form-action 'self';
">
```

### Additional Headers via Netlify

Create `distributor_portal/web/_headers` file for Netlify:

```
/*
  X-Frame-Options: DENY
  X-Content-Type-Options: nosniff
  Referrer-Policy: strict-origin-when-cross-origin
  Permissions-Policy: camera=(), microphone=(), geolocation=()
  X-XSS-Protection: 1; mode=block
```

### Redirects for SPA

Create `distributor_portal/web/_redirects` file:

```
/* /index.html 200
```

This ensures Flutter Web's client-side routing works on all paths.

---

## 5. Supabase Connection

The distributor portal connects to Supabase for:
- **Authentication** (email/password + MFA for super_admin)
- **Database** (products, orders, invoices, distributors)
- **Realtime** (WebSocket for live updates)

### CORS Configuration

In your Supabase Dashboard → Settings → API:
- Add `https://portal.alhai.store` to allowed origins
- Add `https://your-site.netlify.app` for staging

### Supabase URL in Production

Ensure your `.env` points to the production Supabase project:
```
SUPABASE_URL=https://your-prod-project.supabase.co
SUPABASE_ANON_KEY=eyJ...your-prod-anon-key
```

---

## 6. Alternative Hosting Options

### Vercel

```bash
# Install Vercel CLI
npm install -g vercel

# Build
cd distributor_portal
flutter build web --release --dart-define-from-file=.env

# Deploy
cd build/web
vercel --prod
```

**vercel.json** (place in `build/web/`):
```json
{
  "rewrites": [{ "source": "/(.*)", "destination": "/index.html" }]
}
```

### Cloudflare Pages

1. Connect GitHub repo at https://pages.cloudflare.com
2. Build settings:
   - Build command: `cd distributor_portal && flutter build web --release --dart-define-from-file=.env`
   - Build output: `distributor_portal/build/web`
3. Benefits: Global CDN, free SSL, DDoS protection included

### Firebase Hosting

```bash
# Install Firebase CLI
npm install -g firebase-tools

firebase init hosting
# Public directory: distributor_portal/build/web
# Single-page app: Yes

firebase deploy
```

---

## 7. Monitoring & Maintenance

### Sentry Integration
- Error reports sent automatically via `SENTRY_DSN_DISTRIBUTOR`
- Dashboard: https://sentry.io → Select distributor project
- Alerts: Configure email/Slack alerts for new error types

### Deployment Updates
```bash
# For manual deploys:
cd distributor_portal
flutter build web --release --dart-define-from-file=.env
netlify deploy --dir=build/web --prod

# For CI/CD: push to main triggers auto-deploy
```

### Rollback
```bash
# Netlify: Dashboard → Deploys → Click previous deploy → Publish deploy
# CLI:
netlify rollback
```

---

## 8. Pre-Launch Checklist

- [ ] Production Supabase URL configured
- [ ] Sentry DSN configured and receiving test errors
- [ ] MFA enrollment working for super_admin
- [ ] ZATCA environment set to `production` or `simulation`
- [ ] Custom domain configured with SSL
- [ ] SPA redirects working (all routes load correctly)
- [ ] CSP headers not blocking any required resources
- [ ] Tested on: Chrome, Safari, Firefox, Edge
- [ ] A4 invoice printing tested
- [ ] PWA install prompt working
- [ ] Privacy Policy and Terms of Service pages accessible

---

*Last updated: April 16, 2026*
