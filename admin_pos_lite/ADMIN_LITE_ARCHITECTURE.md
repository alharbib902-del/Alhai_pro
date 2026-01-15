# 🏗️ Admin Lite - Platform Architecture

**Version:** 1.0.0  
**Date:** 2026-01-15  
**Status:** ✅ Final

---

## 🌐 Platform Overview

### Architecture Type:
**Mobile-Only Companion App** to admin_pos

```
┌─────────────────────────────────┐
│      Admin Lite (Mobile)        │
│    iOS + Android                │
├─────────────────────────────────┤
│                                 │
│  ┌───────────────────────┐     │
│  │  Same Supabase DB     │     │
│  │  Same RLS Policies    │     │
│  │  Same owner_id        │     │
│  └───────────────────────┘     │
│                                 │
│  Optimized for:                 │
│  - Speed (< 2 sec load)         │
│  - Mobile screens               │
│  - Quick actions                │
│  - Real-time updates            │
│                                 │
└─────────────────────────────────┘
```

---

## 💻 Technology Stack

### Mobile Framework:

```
Flutter 3.x
├── Target: Mobile Only (iOS 13+, Android 6+)
├── Architecture: Clean Architecture
├── State: Riverpod + ChangeNotifier
└── Routing: GoRouter
```

### Dependencies:

```yaml
# Shared
alhai_core: ^latest
alhai_design_system: ^latest

# Backend
supabase_flutter: ^2.0.0

# Auth
local_auth: ^2.1.0  # Biometrics

# Notifications
firebase_messaging: ^14.7.0
flutter_local_notifications: ^16.0.0

# UI
fl_chart: ^0.66.0
shimmer: ^3.0.0

# Performance
cached_network_image: ^3.3.0
```

---

## 🔗 Data Flow

### Request Flow:

```
User Tap
    ↓
ViewModel (Riverpod)
    ↓
Repository (alhai_core)
    ↓
Supabase Client
    ↓
API Gateway (Supabase)
    ↓
PostgreSQL + RLS
    ↓
Response
    ↓
Cache + UI Update
```

### Real-time Flow:

```
Supabase Realtime
    ↓
Listen to changes (orders, alerts)
    ↓
Auto-update ViewModel
    ↓
UI reflects changes (no manual refresh)
```

---

## ⚡ Performance Architecture

### Caching Strategy:

```
Level 1: Memory Cache
├── Dashboard data (2 min TTL)
├── Alerts (30 sec TTL)
└── Stores snapshot (5 min TTL)

Level 2: Secure Storage
├── Auth tokens
└── User preferences

Level 3: Disk Cache
└── Images (via cached_network_image)
```

### Background Refresh:

```dart
// Refresh dashboard in background every 15 min
BackgroundFetch.configure(
  BackgroundFetchConfig(
    minimumFetchInterval: 15,
  ),
  (_) async {
    await _dashboardRepo.fetch AndCache();
  },
);
```

---

## 🔒 Security Architecture

### Authentication Layers:

```
Layer 1: Biometric (Face ID/Fingerprint)
├── Quick login (< 1 sec)
└── Falls back to PIN if fails

Layer 2: JWT Tokens
├── Access token (1 hour)
├── Refresh token (30 days)
└── Auto-refresh on expiry

Layer 3: RLS (Supabase)
├── owner_id = auth.uid()
└── Automatic row filtering
```

### Data Protection:

```
Encrypted Storage:
├── FlutterSecureStorage for tokens
├── No sensitive data in cache
└── Auto-wipe on logout

Network Security:
├── HTTPS only
├── Certificate pinning
└── No plaintext transmission
```

---

## 📡 Notification Architecture

### Push Notifications:

```
Firebase Cloud Messaging (FCM)
    ↓
Priority-based delivery:
├── Critical: Immediate + Sound + Vibration
├── Important: Immediate + Sound
└── Info: Silent notification

Local Notifications:
├── Daily summary (8 PM)
├── Morning briefing (8 AM)
└── Custom reminders
```

---

## 📊 Analytics Architecture

### Events Tracked:

```
User Engagement:
├── App opens (daily/total)
├── Screen views (per screen)
├── Session duration
└── Feature usage

Performance:
├── API response times
├── App crash rate
├── Screen load times
└── Memory usage

Business:
├── Approvals per day
├── Alerts actioned
├── Quick orders placed
└── Reports generated
```

---

## 🌍 Deployment Architecture

### Environments:

```
Development:
├── Supabase: dev project
├── FCM: dev config
└── Local testing

Staging:
├── Supabase: staging project
├── FCM: staging config
├── TestFlight / Internal Testing
└── QA validation

Production:
├── Supabase: prod project
├── FCM: prod config
├── App Store / Play Store
└── Real users
```

### CI/CD Pipeline:

```
GitHub Actions:

On Push (main):
├── flutter analyze
├── flutter test
└── Build dev APK

On Tag (v*):
├── flutter build ios --release
├── flutter build apk --release
├── Upload to TestFlight
├── Upload to Play Console (Internal)
└── Create GitHub Release
```

---

## 📱 Platform-Specific Features

### iOS:

```
- Face ID / Touch ID
- iOS Widgets (Phase 2)
- Apple Watch companion (Phase 2)
- Siri shortcuts (Phase 2)
- CarPlay integration (Phase 3)
```

### Android:

```
- Fingerprint / Face unlock
- Android Widgets (Phase 2)
- Wear OS companion (Phase 2)
- Google Assistant shortcuts (Phase 2)
- Android Auto integration (Phase 3)
```

---

## 🔄 Offline Mode

### Basic Offline Support:

```
Read Operations (Cached):
├── ✅ View dashboard (last 2 min)
├── ✅ View alerts (last 30 sec)
├── ✅ View notifications history
└── ❌ No write operations

Connectivity Detection:
├── Show offline banner
├── Disable action buttons
└── Queue writes for when online
```

---

## 📊 Scalability

### User Scale:

```
Target Load:
├── 50,000 concurrent users
├── 100 requests/sec per user
└── 5M requests/sec total

Supabase Limits:
├── Pro plan: 100K concurrent connections
├── Database: Auto-scaling
└── CDN: Unlimited bandwidth
```

### Data Scale:

```
Per Owner:
├── ~1000 products
├── ~100 orders/day
├── ~50 alerts/day
└── ~10 MB data/month

50K Owners:
├── 50M products
├── 5M orders/day
├── 2.5M alerts/day
└── 500 GB data/month
```

---

## 🎯 Performance Targets

### Response Times:

```
App Launch: < 1 sec (cold start)
Dashboard Load: < 2 sec
Alert List: < 1 sec
Approval Action: < 500ms
Push Notification: < 1 sec delivery
```

### Resource Usage:

```
App Size: < 15 MB
RAM Usage: < 150 MB
Battery: < 2% per hour (background)
Network: < 10 MB per day
```

---

## 🔧 Monitoring & Debugging

### Tools:

```
Crash Reporting:
└── Sentry (real-time crash tracking)

Performance:
├── Firebase Performance Monitoring
└── Custom metrics (API latency)

Analytics:
├── Firebase Analytics (user behavior)
└── Supabase Analytics (API usage)

Debugging:
├── Flutter DevTools
└── Remote debugging (Flipper)
```

---

## 🚀 Future Enhancements

### Phase 2 (Q3 2026):

```
- Voice commands ("Show today's revenue")
- iOS/Android widgets (home screen)
- Improved AI insights
```

### Phase 3 (Q4 2026):

```
- Apple Watch / Wear OS apps
- Offline write queueing
- Advanced caching
```

### Phase 4 (2027):

```
- AR dashboard (view revenue in 3D)
- Car Play / Android Auto integration
- Multi-language support (10+ languages)
```

---

**📅 Last Updated**: 2026-01-15  
**✅ Status**: Final  
**🎯 Next**: README.md
