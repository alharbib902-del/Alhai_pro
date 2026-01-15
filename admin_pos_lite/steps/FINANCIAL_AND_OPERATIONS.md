# 💡 Admin Lite - Mobile UX & Performance Features

> **⚠️ تنبيه**: هذا ملف تفاصيل داعمة (Supporting Details).  
> - المرجع النهائي: [`ADMIN_LITE_SPEC.md`](../ADMIN_LITE_SPEC.md) | [`ADMIN_LITE_API_CONTRACT.md`](../ADMIN_LITE_API_CONTRACT.md)

**التاريخ**: 2026-01-15  
**إضافة**: Mobile UX Patterns + Performance Optimizations

---

## 1️⃣ Mobile UX Patterns

### One-Hand Operation

```
Thumb Zone Optimization:

┌─────────────────────────┐
│      Hard to reach      │  ← Header (info only)
├─────────────────────────┤
│                         │
│    Natural reach        │  ← Content area
│    (comfortable)        │
│                         │
├─────────────────────────┤
│   Easy thumb zone       │  ← Primary actions
│   [Button] [Button]     │
└─────────────────────────┘
     Bottom Navigation      ← Most important
```

### Swipe Gestures

```
Approval Card:

⬅️  Swipe Left to Reject
┌───────────────────────┐
│ 📦 نقل مخزون          │
│ 50 حليب نادك          │
│ Store 1 → Store 2     │
└───────────────────────┘
➡️  Swipe Right to Approve

Implementation:
- Swipe threshold: 50% of card width
- Haptic feedback on action
- Undo option (3 sec)
```

### Pull to Refresh

```
Dashboard Screen:

↓ Pull Down
┌───────────────────────┐
│   ↓ Refreshing...     │  ← Loading indicator
├───────────────────────┤
│ Dashboard Content     │
│ ...                   │
└───────────────────────┘

Auto-refresh: Every 5 seconds (while visible)
Manual refresh: Pull down gesture
```

---

## 2️⃣ Performance Optimizations

### App Launch Optimization

```dart
// Splash screen (< 1 sec)
class SplashScreen extends StatefulWidget {
  @override
  void initState() {
    super.initState();
    
    // Parallel initialization
    Future.wait([
      _checkAuth(),        // Check saved token
      _preloadCache(),     // Load cached data
      _initNotifications() // Setup FCM
    ]).then((_) {
      // Navigate to appropriate screen
      if (isAuthenticated) {
        navigateToDashboard();
      } else {
        navigateToLogin();
      }
    });
  }
}
```

### Dashboard Load Optimization

```dart
// Load dashboard in stages
class DashboardViewModel extends ChangeNotifier {
  Future<void> loadDashboard() async {
    // Stage 1: Show cached data immediately (< 100ms)
    final cached = await _cache.getDashboard();
    if (cached!= null) {
      _dashboard = cached;
      notifyListeners(); // UI updates instantly
    }
    
    // Stage 2: Fetch fresh data in background
    try {
      final fresh = await _api.fetchDashboard();
      _dashboard = fresh;
      await _cache.saveDashboard(fresh);
      notifyListeners(); // UI updates with fresh data
    } catch (e) {
      // Keep showing cached data
    }
  }
}
```

### Image Loading Optimization

```dart
// Progressive image loading
CachedNetworkImage(
  imageUrl: product.imageUrl,
  placeholder: (context, url) => Shimmer(...), // Skeleton
  errorWidget: (context, url, error) => Icon(Icons.error),
  
  // Optimization
  memCacheWidth: 100,   // Resize on decode
  memCacheHeight: 100,
  maxHeightDiskCache: 200,
  maxWidthDiskCache: 200,
  
  // Caching
  cacheManager: DefaultCacheManager()
    ..getFileFromCache(url, ignoreMemCache: false),
)
```

### List Performance

```dart
// Efficient list rendering
ListView.builder(
  itemCount: alerts.length,
  itemExtent: 80.0, // Fixed height for better performance
  cacheExtent: 200, // Pre-cache off-screen items
  
  itemBuilder: (context, index) {
    // Only build visible items
    return AlertCard(
      alert: alerts[index],
      onTap: () => _viewDetails(alerts[index]),
    );
  },
)
```

---

## 3️⃣ Battery Optimization

### Background Fetch Strategy

```dart
// Smart background refresh
class BackgroundService {
  static Future<void> initialize() async {
    // Only fetch when necessary
    BackgroundFetch.configure(
      BackgroundFetchConfig(
        minimumFetchInterval: 15, // 15 minutes
        stopOnTerminate: false,
        enableHeadless: true,
        requiresBatteryNotLow: true,  // ← Battery-aware
        requiresCharging: false,
        requiresDeviceIdle: false,
        requiresStorageNotLow: false,
      ),
      (taskId) async {
        // Quick fetch (< 30 seconds)
        await _fetchCriticalData();
        BackgroundFetch.finish(taskId);
      },
    );
  }
  
  static Future<void> _fetchCriticalData() async {
    // Only fetch critical alerts
    final alerts = await _api.fetchAlerts(
      priority: ['CRITICAL', 'IMPORTANT'],
      limit: 10,
    );
    
    // Cache for instant display
    await _cache.saveAlerts(alerts);
    
    // Show notification if new critical alert
    if (alerts.any((a) => a.priority == 'CRITICAL')) {
      await _showNotification(alerts.first);
    }
  }
}
```

### Network Optimization

```dart
// Batch API calls
class ApiOptimizer {
  // Instead of 3 separate calls:
  // ❌ GET /stores
  // ❌ GET /alerts
  // ❌ GET /approvals
  
  // Use single optimized endpoint:
  // ✅ GET /lite/dashboard
  //    Returns: stores + alerts + approvals in one call
  
  Future<Dashboard> fetchDashboard() async {
    final response = await _client.get('/lite/dashboard');
    
    // Single network call, all data
    return Dashboard.fromJson(response.data);
  }
}
```

---

## 4️⃣ Notification Strategies

### Smart Grouping

```dart
// Group notifications to avoid spam
class NotificationManager {
  static Future<void> handleAlerts(List<Alert> alerts) async {
    if (alerts.length == 1) {
      // Single alert: show individual notification
      await _showNotification(alerts.first);
    } else if (alerts.length <= 3) {
      // 2-3 alerts: show summary with inbox style
      await _showGroupedNotification(
        title: '${alerts.length} تنبيهات جديدة',
        alerts: alerts,
        style: InboxStyle(),
      );
    } else {
      // >3 alerts: show count only
      await _showGroupedNotification(
        title: '${alerts.length} تنبيهات جديدة',
        body: 'اضغط لعرض التفاصيل',
        style: BigTextStyle(),
      );
    }
  }
}
```

### Priority-Based Delivery

```dart
// Critical alerts: Immediate + Sound + Vibration
if (alert.priority == AlertPriority.CRITICAL) {
  await _showNotification(
    title: alert.message,
    body: alert.details,
    priority: Priority.high,
    importance: Importance.max,
    sound: RawResourceAndroidNotificationSound('alert_critical'),
    playSound: true,
    enableVibration: true,
    vibrationPattern: Int64List.fromList([0, 500, 250, 500]),
  );
}

// Important alerts: Immediate + Sound only
else if (alert.priority == AlertPriority.IMPORTANT) {
  await _showNotification(
    priority: Priority.high,
    playSound: true,
    enableVibration: false,
  );
}

// Info alerts: Silent notification
else {
  await _showNotification(
    priority: Priority.low,
    playSound: false,
    enableVibration: false,
  );
}
```

### Quiet Hours

```dart
// Respect user's quiet hours
class QuietHoursManager {
  static bool isQuietHour() {
    final now = DateTime.now();
    final quietStart = TimeOfDay(hour: 22, minute: 0);  // 10 PM
    final quietEnd = TimeOfDay(hour: 8, minute: 0);     // 8 AM
    
    final nowTime = TimeOfDay.fromDateTime(now);
    
    // Check if current time is in quiet hours
    return _isInRange(nowTime, quietStart, quietEnd);
  }
  
  static Future<void> handleAlert(Alert alert) async {
    if (isQuietHour() && alert.priority != AlertPriority.CRITICAL) {
      // Save for morning briefing
      await _queueForMorning(alert);
    } else {
      // Show immediately
      await _showNotification(alert);
    }
  }
}
```

---

## 5️⃣ Offline Mode

### Cache Management

```dart
// Smart caching with TTL
class CacheManager {
  // Dashboard: 2 minutes
  static const dashboardTTL = Duration(minutes: 2);
  
  // Alerts: 30 seconds (more critical)
  static const alertsTTL = Duration(seconds: 30);
  
  // Stores: 5 minutes (less frequently changed)
  static const storesTTL = Duration(minutes: 5);
  
  Future<T?> get<T>(
    String key,
    Duration ttl,
    T Function(Map<String, dynamic>) fromJson,
  ) async {
    final cached = await _storage.read(key);
    
    if (cached != null) {
      final timestamp = DateTime.parse(cached['timestamp']);
      final age = DateTime.now().difference(timestamp);
      
      if (age < ttl) {
        return fromJson(cached['data']);
      }
    }
    
    return null;
  }
}
```

### Offline UI

```dart
// Show offline banner
class OfflineBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<bool>(
      stream: _connectivityService.isOnlineStream,
      builder: (context, snapshot) {
        final isOnline = snapshot.data ?? true;
        
        if (!isOnline) {
          return Container(
            color: Colors.orange,
            padding: EdgeInsets.all(8),
            child: Row(
              children: [
                Icon(Icons.cloud_off, color: Colors.white),
                SizedBox(width: 8),
                Text(
                  'Offline - عرض البيانات المحفوظة',
                  style: TextStyle(color: Colors.white),
                ),
              ],
            ),
          );
        }
        
        return SizedBox.shrink();
      },
    );
  }
}
```

---

## 6️⃣ Accessibility

### Screen Reader Support

```dart
// Semantic labels for screen readers
Semantics(
  label: 'الإيرادات اليوم: خمسة آلاف وخمسمائة ريال',
  hint: 'زيادة عشرة بالمئة عن الأمس',
  child: Column(
    children: [
      Text('5,500 ر.س', style: headlineStyle),
      Text('+10%', style: successStyle),
    ],
  ),
)
```

### High Contrast Mode

```dart
// Support system high contrast
class AlhaiTheme {
  static ThemeData getTheme(BuildContext context) {
    final highContrast = MediaQuery.of(context).highContrast;
    
    if (highContrast) {
      return ThemeData(
        // Higher contrast colors
        primaryColor: Colors.black,
        accentColor: Colors.yellow[700],
        backgroundColor: Colors.white,
      );
    }
    
    return ThemeData(...normal theme...);
  }
}
```

### Large Text Support

```dart
// Respect system text scaling
Text(
  'Dashboard',
  style: Theme.of(context).textTheme.headline6,
  // ← Automatically scales with system settings
)
```

---

## 🎯 Performance Targets

```
Cold Start: < 1 sec
Dashboard Load: < 2 sec (cached) / < 3 sec (fresh)
Alert List Load: < 1 sec
Approval Action: < 500ms
Frame Rate: 60 FPS stable
Memory Usage: < 150 MB
Battery Drain: < 2% per hour (background)
App Size: < 15 MB
```

---

**📅 Last Updated**: 2026-01-15  
**✅ Status**: Mobile UX & Performance Guidelines Complete
