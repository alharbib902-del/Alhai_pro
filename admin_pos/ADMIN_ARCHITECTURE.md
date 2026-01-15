# 🏗️ Admin POS - Platform Architecture

**Version:** 1.0.0  
**Date:** 2026-01-15  
**Status:** ✅ Final

---

## 📋 جدول المحتويات

1. [Platform Overview](#platform-overview)
2. [Multi-Tenant Isolation](#multi-tenant-isolation)
3. [Technology Stack](#technology-stack)
4. [System Architecture](#system-architecture)
5. [Scaling Strategy](#scaling-strategy)
6. [Deployment](#deployment)
7. [Performance](#performance)
8. [Security Architecture](#security-architecture)

---

## 🌐 Platform Overview

### Architecture Type:
**SaaS Multi-Tenant Platform**

```
┌─────────────────────────────────────────────────┐
│         Admin POS Platform (SaaS)               │
├─────────────────────────────────────────────────┤
│                                                 │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐     │
│  │ Owner A  │  │ Owner B  │  │ Owner C  │     │
│  │ (2 stores│  │ (1 store)│  │ (3 stores│     │
│  └──────────┘  └──────────┘  └──────────┘     │
│                                                 │
│  ┌───────────────────────────────────────┐     │
│  │    Shared Infrastructure              │     │
│  │    ├── Supabase (PostgreSQL)          │     │
│  │    ├── Cloudflare R2 (Storage)        │     │
│  │    ├── Edge Functions                 │     │
│  │    └── Realtime Subscriptions         │     │
│  └───────────────────────────────────────┘     │
│                                                 │
└─────────────────────────────────────────────────┘
```

### Key Characteristics:

1. **Multi-Tenancy**: كل Owner معزول، بيانات منفصلة
2. **Shared Infrastructure**: نفس الـ codebase والـ database
3. **Scalable**: يدعم 1 → 10,000+ owners
4. **Cross-Platform**: Mobile + Web + Desktop

---

## 🔒 Multi-Tenant Isolation

### Isolation Strategy:

```
Level 1: Application Level (Flutter)
├── Owner ID في كل request
├── Route guards (permission checks)
└── State isolation per Owner

Level 2: API Level (Supabase)
├── RLS policies (Row Level Security)
├── Owner ID في كل query
└── JWT token validation

Level 3: Data Level (PostgreSQL)
├── owner_id column في كل table
├── Indexes على owner_id
└── Partitioning (future optimization)
```

### Data Isolation Example:

```
Scenario: Owner A requests stores list

Frontend (admin_pos):
├── User logged in → JWT contains owner_id
├── Request: GET /stores
└── Header: Authorization: Bearer {jwt}

Backend (Supabase):
├── Extract owner_id from JWT
├── RLS Policy: "owner can only see their stores"
│   └── WHERE stores.owner_id = auth.uid()
└── Return: Only Owner A's stores

Result:
✅ Owner A sees stores 1, 2
❌ Owner B's stores invisible
```

---

## 💻 Technology Stack

### Frontend:

```
Framework: Flutter 3.x
├── Cross-platform (Mobile, Web, Desktop)
├── Hot reload للتطوير السريع
└── Native performance

State Management:
├── Riverpod (Dependency Injection)
└── ChangeNotifier (ViewModels)

Routing:
└── GoRouter (declarative routing)

Local Storage:
├── SharedPreferences (settings)
└── SecureStorage (tokens)

UI:
└── alhai_design_system (shared components)
```

---

### Backend:

```
Platform: Supabase
├── PostgreSQL (database)
├── PostgREST (auto API)
├── GoTrue (authentication)
├── Realtime (subscriptions)
└── Edge Functions (serverless)

Storage:
└── Cloudflare R2
    ├── Images (products, stores, staff)
    ├── Documents (invoices, reports)
    └── CDN globally distributed

Image Processing:
└── alhai_core ImageService
    ├── Resize (thumbnail, medium, large)
    ├── Compress (optimize quality)
    └── Upload to R2
```

---

### Infrastructure:

```
Hosting:
├── Flutter Web: Cloudflare Pages
├── Flutter Mobile: App Store / Play Store
├── Flutter Desktop: Direct download + auto-update

Database:
└── Supabase (managed PostgreSQL)
    ├── Automatic backups (daily)
    ├── Point-in-time recovery
    └── Read replicas (for scaling)

CDN:
└── Cloudflare
    ├── R2 for images
    ├── Pages for web app
    └── Global edge network
```

---

## 🏗️ System Architecture

### High-Level Architecture:

```
┌─────────────────────────────────────────────────┐
│                                                 │
│         Client Apps (Flutter)                   │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐     │
│  │ iOS/     │  │  Web     │  │ Desktop  │     │
│  │ Android  │  │ Browser  │  │ Win/Mac  │     │
│  └────┬─────┘  └────┬─────┘  └────┬─────┘     │
│       │             │             │            │
│       └─────────────┼─────────────┘            │
│                     │                          │
└─────────────────────┼──────────────────────────┘
                      │
                      │ HTTPS / WSS
                      │
┌─────────────────────▼──────────────────────────┐
│             API Gateway                        │
│          (Supabase PostgREST)                  │
└─────────────────────┬──────────────────────────┘
                      │
        ┌─────────────┼─────────────┐
        │             │             │
┌───────▼──────┐ ┌────▼─────┐ ┌────▼─────┐
│ PostgreSQL   │ │ Realtime │ │  Edge    │
│   Database   │ │ Server   │ │ Functions│
└───────┬──────┘ └──────────┘ └──────────┘
        │
        │ RLS Policies
        │
┌───────▼──────────────────────────────────────┐
│  Data (Tables with owner_id isolation)      │
│  ├── owners                                 │
│  ├── stores                                 │
│  ├── staff                                  │
│  ├── products                               │
│  ├── orders                                 │
│  └── ...                                    │
└─────────────────────────────────────────────┘

External Services:
├── Cloudflare R2 (Images)
├── Stripe/Tap (Payments)
├── Twilio (SMS)
└── SendGrid (Email)
```

---

### Feature Architecture (Clean Architecture):

```
admin_pos/
├── lib/
│   ├── main.dart
│   ├── di/              ← Dependency Injection
│   ├── core/            ← Shared utilities
│   │   ├── router/
│   │   ├── constants/
│   │   └── services/
│   │
│   ├── features/        ← Feature modules
│   │   ├── auth/
│   │   │   ├── data/
│   │   │   │   └── auth_repository.dart
│   │   │   ├── domain/
│   │   │   │   └── auth_service.dart
│   │   │   └── presentation/
│   │   │       ├── screens/
│   │   │       ├── widgets/
│   │   │       └── view_models/
│   │   │
│   │   ├── stores/
│   │   ├── staff/
│   │   ├── products/
│   │   ├── financial/
│   │   └── ...
│   │
│   └── shared/          ← Shared widgets
│
└── test/
```

---

## 📈 Scaling Strategy

### Vertical Scaling (Supabase):

```
Tier 1: Free (Development)
├── 500 MB database
├── 1 GB storage
└── Good for testing

Tier 2: Pro ($25/month)
├── 8 GB database
├── 100 GB storage
├── Daily backups
└── 100-500 owners

Tier 3: Team ($599/month)
├── Unlimited database
├── Unlimited storage
├── Point-in-time recovery
└── 500-2000 owners

Tier 4: Enterprise (Custom)
├── Dedicated instance
├── SLA guarantees
├── Custom scaling
└── 2000+ owners
```

---

### Horizontal Scaling:

```
Database:
├── Read replicas (Supabase)
│   └── Distribute read queries
├── Connection pooling
│   └── PgBouncer (built-in)
└── Query optimization
    └── Proper indexes

API:
├── Edge Functions
│   └── Auto-scaling (Supabase)
├── Rate limiting
│   └── Per Owner (prevent abuse)
└── Caching
    └── API responses (Redis - future)

CDN:
├── Cloudflare R2
│   └── Globally distributed
├── Image caching
│   └── Browser + CDN
└── Static assets
    └── Cloudflare Pages
```

---

### Optimization Strategies:

```
1. Database:
   ✅ Indexes على owner_id
   ✅ Composite indexes (owner_id + date)
   ✅ Partitioning tables (future - by month)
   ✅ Archive old data (>2 years)

2. API:
   ✅ Pagination (limit 20-50)
   ✅ Field selection (GraphQL-like)
   ✅ Batch operations
   ✅ Debounce requests (frontend)

3. Images:
   ✅ Progressive loading
   ✅ Lazy loading
   ✅ WebP format
   ✅ Multiple sizes (thumb/medium/large)

4. Real-time:
   ✅ Selective subscriptions
   ✅ Unsubscribe on unmount
   ✅ Throttle updates (1-2 sec)
```

---

## 🚀 Deployment

### Environments:

```
1. Development
   ├── Supabase: dev project
   ├── R2: dev bucket
   └── Local testing

2. Staging
   ├── Supabase: staging project
   ├── R2: staging bucket
   ├── Testing with seed data
   └── QA validation

3. Production
   ├── Supabase: prod project
   ├── R2: prod bucket
   ├── Real users
   └── Monitoring enabled
```

---

### Deployment Process:

```
Flutter Web:
├── Build: flutter build web --release
├── Deploy: Cloudflare Pages (auto from Git)
└── Rollback: Previous deployment (1-click)

Flutter Mobile:
├── Build iOS: flutter build ios --release
├── Build Android: flutter build apk --release
├── TestFlight / Internal Testing
└── App Store / Play Store publish

Flutter Desktop:
├── Build Windows: flutter build windows --release
├── Build macOS: flutter build macos --release
├── Code signing (certificates)
└── Direct download + auto-update (future)
```

---

### CI/CD Pipeline:

```
GitHub Actions:
├── On Push (main branch):
│   ├── Run tests (flutter test)
│   ├── Run analysis (flutter analyze)
│   ├── Build web (flutter build web)
│   └── Deploy to Cloudflare Pages
│
└── On Tag (v*):
    ├── Build mobile (iOS + Android)
    ├── Upload to TestFlight / Internal Testing
    └── Create GitHub Release
```

---

## ⚡ Performance

### Target Metrics:

```
Load Time:
├── Web (First Paint): < 2 sec
├── Mobile (App Launch): < 1 sec
└── Desktop (App Launch): < 0.5 sec

API Response:
├── List queries: < 200ms
├── Detail queries: < 100ms
└── Mutations: < 300ms

Real-time:
├── Update latency: < 500ms
└── Connection: < 1 sec

Image Loading:
├── Thumbnail: < 100ms
├── Medium: < 300ms
└── Large: < 500ms
```

---

### Performance Optimizations:

```
1. Code Splitting (Web):
   ✅ Lazy load routes
   ✅ Split large features
   └── Reduce initial bundle

2. Tree Shaking:
   ✅ Remove unused code
   ✅ Optimize imports
   └── Smaller bundle size

3. Caching:
   ✅ API responses (memory cache)
   ✅ Images (disk cache)
   ✅ Static assets (browser cache)
   └── User preferences (SharedPreferences)

4. Background Sync:
   ✅ Non-blocking operations
   ✅ Queue failed requests
   └── Retry with exponential backoff

5. Pagination:
   ✅ Load 20-50 items at a time
   ✅ Infinite scroll (mobile)
   └── Load more button (web/desktop)
```

---

## 🔐 Security Architecture

### Authentication Flow:

```
1. Owner Login:
   ├── Phone + OTP (Supabase Auth)
   ├── Or Email + Password
   ├── JWT token issued
   └── Token stored (SecureStorage)

2. Token Lifecycle:
   ├── Access Token: 1 hour
   ├── Refresh Token: 30 days
   ├── Auto-refresh (when expires)
   └── Logout: invalidate tokens

3. Session Management:
   ├── Single device: logout others
   ├── Or: multiple sessions allowed
   └── Security logs (audit trail)
```

---

### Authorization (RLS):

```
Supabase RLS Policies:

Policy: "Owners see only their data"
├── Table: stores
├── Operation: SELECT
└── Using: owner_id = auth.uid()

Policy: "Owners manage their staff"
├── Table: staff
├── Operation: INSERT, UPDATE, DELETE
└── Using: owner_id = auth.uid()

Policy: "Managers see their store only"
├── Table: orders
├── Operation: SELECT
└── Using: 
    store_id IN (
      SELECT id FROM stores 
      WHERE manager_id = auth.uid()
    )
```

---

### Data Security:

```
1. Encryption:
   ✅ At rest (PostgreSQL encrypted)
   ✅ In transit (HTTPS/TLS)
   ✅ Tokens (JWT signed)
   └── Sensitive fields (hashed passwords)

2. Access Control:
   ✅ RLS enforced على كل table
   ✅ API rate limiting (per owner)
   ✅ Permission checks (frontend + backend)
   └── Audit logs (who did what)

3. Data Privacy:
   ✅ GDPR compliant (data export/delete)
   ✅ Tenant isolation (no cross-owner access)
   ✅ Minimal data collection
   └── Anonymization (analytics)

4. Vulnerability Protection:
   ✅ SQL injection (PostgREST prevents)
   ✅ XSS (Flutter sanitizes)
   ✅ CSRF (JWT token-based auth)
   └── DDoS (Cloudflare protection)
```

---

### Compliance:

```
Standards:
├── GDPR (EU data protection)
├── Saudi Data Protection Law
├── PCI DSS (payment handling via Stripe/Tap)
└── ISO 27001 (future certification)

Data Handling:
├── Data residency (Saudi cloud region)
├── Backup retention (90 days)
├── Right to deletion (GDPR Article 17)
└── Data portability (export to JSON/CSV)
```

---

## 📊 Monitoring & Observability

### Metrics:

```
Application:
├── Sentry (error tracking)
│   ├── Crash reports
│   ├── Error rates
│   └── Performance issues
│
├── Firebase Analytics (user behavior)
│   ├── Screen views
│   ├── Events
│   └── User retention
│
└── Custom Dashboards
    ├── Active owners
    ├── Revenue (MRR)
    ├── Churn rate
    └── Feature usage

Infrastructure:
├── Supabase Dashboard
│   ├── Database performance
│   ├── API requests/sec
│   └── Storage usage
│
└── Cloudflare Analytics
    ├── CDN bandwidth
    ├── Cache hit rate
    └── Global latency
```

---

### Alerting:

```
Critical Alerts (PagerDuty/SMS):
├── Database down
├── API error rate > 5%
├── Payment failures
└── Security breach

Warning Alerts (Email/Slack):
├── High latency (>1 sec)
├── Storage >80% full
├── Subscription churns
└── Low API rate limits
```

---

## 🔄 Disaster Recovery

### Backup Strategy:

```
Database:
├── Automatic daily backups (Supabase)
├── Point-in-time recovery (7 days)
├── Manual snapshots (before major updates)
└── Offsite backups (weekly to S3)

Images (R2):
├── Versioning enabled
├── Lifecycle policies (delete >2 years)
└── Cross-region replication (future)

Code:
├── Git repository (GitHub)
├── Tagged releases (semver)
└── Docker images (registry)
```

---

### Recovery Plan:

```
Scenario 1: Database corruption
├── Restore from backup (< 1 hour RTO)
├── Replay WAL logs
└── Verify data integrity

Scenario 2: Service outage
├── Fallback to read-only mode
├── Queue writes for later
└── Notify users (status page)

Scenario 3: Security breach
├── Isolate affected tenants
├── Reset tokens
├── Audit logs review
└── Notify affected owners
```

---

## 🌍 Geographic Distribution

### Current:

```
Primary Region: Saudi Arabia (Middle East)
├── Supabase: Middle East region
├── Cloudflare R2: Global (auto)
└── Web app: Cloudflare Pages (global CDN)
```

---

### Future Expansion:

```
Phase 1 (2026): GCC
├── Saudi Arabia ✅
├── UAE
├── Kuwait
├── Bahrain
└── Qatar

Phase 2 (2027): broader MENA
├── Egypt
├── Jordan
└── Lebanon

Multi-region setup:
├── Database replicas per region
├── R2 buckets per region
└── Edge Functions per region
```

---

## 🎯 Performance Benchmarks

### Target SLAs:

```
Availability:
├── Uptime: 99.9% (43 min downtime/month)
├── Planned maintenance: < 2 hours/month
└── Incident response: < 15 min

Performance:
├── API p95: < 500ms
├── API p99: < 1 sec
├── Page load (Web): < 3 sec
└── Realtime latency: < 1 sec

Scalability:
├── Support 10,000 concurrent users
├── Handle 1M API requests/day
└── Store 100TB+ data
```

---

**📅 Last Updated**: 2026-01-15  
**✅ Status**: Ready for Development  
**🎯 Next**: README.md (Index + Quick Navigation)
