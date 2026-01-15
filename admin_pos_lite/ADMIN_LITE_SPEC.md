# 🔧 Admin Lite - Technical Specification

**Version:** 1.0.0  
**Date:** 2026-01-15  
**Status:** ✅ Final

---

## 📋 جدول المحتويات

1. [Architecture Overview](#architecture-overview)
2. [Technology Stack](#technology-stack)
3. [Data Access](#data-access)
4. [Key Features](#key-features)
5. [Performance](#performance)
6. [Security](#security)
7. [Offline Mode](#offline-mode)

---

## 🏗️ Architecture Overview

### Platform Strategy:

```
admin_app_lite = Mobile-Only Companion App

Relationship with admin_pos:
├── Shares same Supabase database
├── Shares same RLS policies
├── Shares same owner_id isolation
├── Uses subset of same APIs
└── Read-heavy (90% read, 10% write)
```

### Architecture Pattern:

```
Clean Architecture (Feature-First)

admin_app_lite/
├── lib/
│   ├── main.dart
│   ├── core/
│   │   ├── router/
│   │   ├── providers/
│   │   └── utils/
│   │
│   ├── features/
│   │   ├── auth/
│   │   │   ├── data/
│   │   │   ├── domain/
│   │   │   └── presentation/
│   │   │
│   │   ├── dashboard/
│   │   ├── alerts/
│   │   ├── approvals/
│   │   ├── notifications/
│   │   └── settings/
│   │
│   └── shared/
│       ├── widgets/
│       └── models/
```

---

## 💻 Technology Stack

### Frontend:

```yaml
Framework: Flutter 3.x
Platform: Mobile Only (iOS 13+, Android 6+)

Dependencies:
  # Shared packages
  alhai_core:
    path: ../alhai_core
  alhai_design_system:
    path: ../alhai_design_system
  
  # State management
  flutter_riverpod: ^2.4.0
  
  # Backend
  supabase_flutter: ^2.0.0
  
  # Local storage
  shared_preferences: ^2.2.0
  flutter_secure_storage: ^9.0.0
  
  # Auth
  local_auth: ^2.1.0  # Fingerprint/Face ID
  
  # Notifications
  firebase_messaging: ^14.7.0
  flutter_local_notifications: ^16.0.0
  
  # UI
  fl_chart: ^0.66.0  # Charts
  shimmer: ^3.0.0    # Loading placeholders
  
  # Utils
  intl: ^0.18.0
  timeago: ^3.5.0
```

---

## 🔌 Data Access

### API Strategy:

```
Uses same endpoints as admin_pos, but:
├── Fewer endpoints (only needed ones)
├── Optimized queries (less data per request)
├── Aggressive caching
└── Background refresh
```

### Primary Endpoints:

```
Authentication:
├── POST /auth/login
└── POST /auth/refresh

Dashboard:
├── GET /lite/dashboard  ← New optimized endpoint
├── GET /stores/snapshot
└── GET /kpi/summary

Alerts:
├── GET /alerts?priority=CRITICAL,IMPORTANT
└── PUT /alerts/:id/snooze

Approvals:
├── GET /approvals/pending
├── POST /approvals/:id/approve
└── POST /approvals/:id/reject

Notifications:
├── GET /notifications
└── PUT /notifications/:id/read

Reports:
└── GET /reports/today
```

### New Optimized Endpoint:

```json
GET /lite/dashboard

Response:
{
  "success": true,
  "data": {
    "today": {
      "revenue": 5500,
      "revenue_growth_percent": 10,
      "orders_count": 12,
      "alerts_count": 3
    },
    "yesterday": {
      "revenue": 5000
    },
    "trend_7days": [3500, 4000, 4500, 5000, 5200, 5500, 5500],
    "stores": [
      {
        "id": "store-1",
        "name": "بقالة الحي",
        "revenue_today": 3300,
        "percent_of_total": 60,
        "status": "ACTIVE"
      },
      {
        "id": "store-2",
        "name": "بقالة السوق",
        "revenue_today": 2200,
        "percent_of_total": 40,
        "status": "ACTIVE"
      }
    ],
    "critical_alerts": [
      {
        "id": "alert-1",
        "type": "STOCK_LOW",
        "priority": "CRITICAL",
        "message": "حليب نادك نفذ في Store 1",
        "action_url": "/products/product-1/reorder"
      }
    ]
  }
}
```

---

## ⚡ Key Features

### 1. Real-time Updates:

```dart
// Dashboard auto-refresh every 5 seconds
class DashboardViewModel extends ChangeNotifier {
  Timer? _refreshTimer;
  
  void startAutoRefresh() {
    _refreshTimer = Timer.periodic(
      Duration(seconds: 5),
      (_) => fetchDashboard(),
    );
  }
  
  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }
}
```

### 2. Push Notifications:

```dart
// FCM setup
FirebaseMessaging.onMessage.listen((message) {
  if (message.data['priority'] == 'CRITICAL') {
    // Show alert dialog
    showCriticalAlert(message);
  } else {
    // Show local notification
    showNotification(message);
  }
});

// Handle notification tap
FirebaseMessaging.onMessageOpenedApp.listen((message) {
  // Navigate to relevant screen
  navigateToScreen(message.data['screen']);
});
```

### 3. Biometric Auth:

```dart
// Fingerprint/Face ID
final localAuth = LocalAuthentication();

Future<bool> authenticateWithBiometrics() async {
  try {
    return await localAuth.authenticate(
      localizedReason: 'تسجيل الدخول السريع',
      options: AuthenticationOptions(
        biometricOnly: true,
        stickyAuth: true,
      ),
    );
  } catch (e) {
    return false;
  }
}
```

### 4. Quick Actions:

```dart
// One-tap approve
Future<void> quickApprove(String approvalId) async {
  // Optimistic update
  _updateLocalState(approvalId, ApprovalStatus.APPROVED);
  
  try {
    await _repository.approve(approvalId);
    _showSuccess('تمت الموافقة');
  } catch (e) {
    // Rollback
    _revertLocalState(approvalId);
    _showError('فشل الموافقة');
  }
}
```

---

## 🚀 Performance

### Target Metrics:

```
App Size: < 15 MB
Launch Time: < 1 second (cold start)
Dashboard Load: < 2 seconds
API Response: < 300ms
Frame Rate: 60 FPS
Memory Usage: < 150 MB
```

### Optimization Strategies:

```dart
// 1. Aggressive caching
class CacheManager {
  static const dashboardTTL = Duration(minutes: 2);
  static const alertsTTL = Duration(seconds: 30);
  
  Future<Dashboard?> getCachedDashboard() async {
    final cached = await _storage.read('dashboard');
    if (cached != null && !_isExpired(cached, dashboardTTL)) {
      return Dashboard.fromJson(cached);
    }
    return null;
  }
}

// 2. Image optimization
ProductImage(
  imageUrl: product.imageUrl,
  thumbnail: true,  // Load thumbnail only
  cacheWidth: 100,   // Resize on decode
)

// 3. Lazy loading
ListView.builder(
  itemCount: alerts.length,
  itemBuilder: (context, index) {
    // Only build visible items
    return AlertCard(alert: alerts[index]);
  },
)

// 4. Background data fetch
class BackgroundFetchService {
  static Future<void> initialize() async {
    BackgroundFetch.configure(
      BackgroundFetchConfig(
        minimumFetchInterval: 15, // minutes
      ),
      (_) async {
        // Fetch dashboard data in background
        await _fetchAndCacheDashboard();
      },
    );
  }
}
```

---

## 🔐 Security

### Authentication:

```
Same as admin_pos:
├── JWT tokens (1 hour access, 30 days refresh)
├── Secure storage for tokens
├── Auto-refresh before expiry
└── Biometric quick login
```

### Data Protection:

```dart
// 1. Secure storage
final secureStorage = FlutterSecureStorage();
await secureStorage.write(key: 'access_token', value: token);

// 2. RLS enforcement (Supabase)
Same RLS policies as admin_pos:
- owner_id = auth.uid()
- Automatic row filtering

// 3. No sensitive data caching
Don't cache:
- Payment info
- Staff salaries
- Customer phone numbers
```

### App Security:

```dart
// 1. Certificate pinning
HttpClient client = HttpClient(context: SecurityContext())
  ..badCertificateCallback = (cert, host, port) => false;

// 2. Jailbreak/Root detection
bool isDeviceSecure = await trustfall.isTrusted;
if (!isDeviceSecure) {
  showWarning('Device may be compromised');
}

// 3. Screenshot prevention (for sensitive screens)
WidgetsBinding.instance.addObserver(
  ScreenshotObserver(
    onScreenshot: () => showWarning('Screenshots disabled'),
  ),
);
```

---

## 📴 Offline Mode

### Basic Offline Support:

```
Limited offline functionality:
├── ✅ View cached dashboard (last 2 minutes)
├── ✅ View cached alerts (last 30 seconds)
├── ✅ View notifications history
└── ❌ No write operations offline
```

### Implementation:

```dart
class OfflineManager {
  // Check connectivity
  Future<bool> isOnline() async {
    final result = await Connectivity().checkConnectivity();
    return result != ConnectivityResult.none;
  }
  
  // Handle offline state
  Future<Dashboard> getDashboard() async {
    if (await isOnline()) {
      final dashboard = await _api.fetchDashboard();
      await _cache.saveDashboard(dashboard);
      return dashboard;
    } else {
      final cached = await _cache.getCachedDashboard();
      if (cached != null) {
        _showOfflineWarning();
        return cached;
      } else {
        throw OfflineException('No cached data available');
      }
    }
  }
}
```

---

## 🔔 Notifications

### Push Notification Types:

```
1. Critical Alerts (Red badge + Sound + Vibration):
   - Stock نفذ
   - System error
   - Security issue

2. Important (Orange badge + Sound):
   - Approval pending
   - Debt overdue
   - Target missed

3. Info (Blue badge, no sound):
   - New order
   - Daily summary
   - System update
```

### Local Notifications:

```dart
// Schedule daily summary
flutterLocalNotificationsPlugin.zonedSchedule(
  0,
  'Daily Summary',
  'Your stores earned 15,000 ر.س today',
  _nextInstanceOf8PM(),
  notificationDetails,
  androidAllowWhileIdle: true,
  uiLocalNotificationDateInterpretation:
      UILocalNotificationDateInterpretation.absoluteTime,
);
```

---

## 🎨 UI/UX Guidelines

### Mobile-First Design:

```
1. Large tap targets (min 44x44 dp)
2. Bottom navigation (thumb-friendly)
3. Swipe gestures:
   - Swipe right: Approve
   - Swipe left: Reject
   - Pull to refresh
4. One-hand operation optimized
5. Dark mode support
```

### Accessibility:

```dart
// 1. Screen reader support
Semantics(
  label: 'Revenue today: 5,500 riyals',
  child: Text('5,500 ر.س'),
)

// 2. High contrast mode
// 3. Large text support (follow system settings)
// 4. Voice commands (Phase 2)
```

---

## 🔗 Integration

### With admin_pos:

```
Shared:
├── Same Supabase project
├── Same database tables
├── Same RLS policies
├── Same owner_id

Different:
├── Separate Flutter project
├── Mobile-only platform
├── Lighter UI
└── Subset of features
```

### With alhai_core:

```dart
import 'package:alhai_core/alhai_core.dart';

// Use shared models
final product = Product.fromJson(json);

// Use shared repositories
final productRepo = ref.read(productRepositoryProvider);

// Use shared services
final imageService = ref.read(imageServiceProvider);
```

---

**📅 Last Updated**: 2026-01-15  
**✅ Status**: Final - Ready for Development  
**🎯 Next**: ADMIN_LITE_VISION.md
