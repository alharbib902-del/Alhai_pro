# 💰 Driver App - التفاصيل المالية والعمليات

> **⚠️ تنبيه**: هذا ملف تفاصيل داعمة (Supporting Details).  
> - المرجع النهائي: [`DRIVER_SPEC.md`](../DRIVER_SPEC.md) | [`DRIVER_API_CONTRACT.md`](../DRIVER_API_CONTRACT.md)

**التاريخ**: 2026-01-15  
**إضافة**: Payment Systems, Earnings Tracking, Mobile Performance

---

## 1️⃣ نظام الأرباح - Payment Models

### A. Salary-Based (راتب ثابت):

```dart
class SalaryBasedEarnings {
  final double baseSalary = 3000; // ر.س/month
  final double bonusPerDelivery = 5; // ر.س
  
  double calculateMonthly(int deliveries) {
    return baseSalary + (deliveries * bonusPerDelivery);
  }
}

Example:
100 deliveries/month
= 3000 + (100 × 5)
= 3500 ر.س
```

### B. Commission-Based (عمولة فقط):

```dart
class CommissionBasedEarnings {
  final double baseCommission = 15; // ر.س per delivery
  
  // Bonuses
  final double sameDayBonus = 5;
  final double onTimeBonus = 5;
  final double fiveStarBonus = 10;
  
  double calculateDelivery(bool sameDay, bool onTime, bool fiveStar) {
    double total = baseCommission;
    if (sameDay) total += sameDayBonus;
    if (onTime) total += onTimeBonus;
    if (fiveStar) total += fiveStarBonus;
    return total;
  }
}

Example (all bonuses):
= 15 + 5 + 5 + 10
= 35 ر.س per delivery

100 deliveries × 35 = 3500 ر.س/month
```

### C. Hybrid (الأمثل) ⭐:

```dart
class HybridEarnings {
  final double baseSalary = 2000; // ر.س/month
  final double commission = 10; // ر.س per delivery
  final double onTimeBonus = 5;
  final double fiveStarBonus = 10;
  
  double calculateMonthly({
    required int totalDeliveries,
    required int onTimeDeliveries,
    required int fiveStarDeliveries,
  }) {
    double total = baseSalary;
    total += totalDeliveries * commission;
    total += onTimeDeliveries * onTimeBonus;
    total += fiveStarDeliveries * fiveStarBonus;
    return total;
  }
}

Example (140 deliveries, 90% performance):
Base:     2000 ر.س
Commission: 140 × 10 = 1400 ر.س
On-time:  126 × 5  = 630 ر.س
5-star:   126 × 10 = 1260 ر.س
─────────────────
Total:    5290 ر.س ✅
```

---

## 2️⃣ تتبع الأرباح (Earnings Tracking)

### Real-time Dashboard:

```dart
class EarningsDashboard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Today's Earnings
        Card(
          child: Column(
            children: [
              Text('اليوم', style: heading),
              Text('270 ر.س', style: largeNumber),
              Row(
                children: [
                  EarningsBreakdown(
                    label: 'Base',
                    amount: 140,
                  ),
                  EarningsBreakdown(
                    label: 'On-time',
                    amount: 70,
                  ),
                  EarningsBreakdown(
                    label: '5-star',
                    amount: 60,
                  ),
                ],
              ),
            ],
          ),
        ),
        
        // Week Summary
        WeeklySummary(
          deliveries: 84,
          earnings: 1450,
        ),
        
        // Month Summary
        MonthlySummary(
          deliveries: 320,
          earnings: 5290,
          target: 5000,
          achievement: 105.8,
        ),
      ],
    );
  }
}
```

---

## 3️⃣ نظام المناوبات (Shift Management)

### Clock In/Out:

```dart
class ShiftManager {
  Future<void> clockIn({
    required String driverId,
    required LatLng location,
  }) async {
    final shift = Shift(
      id: uuid.v4(),
      driverId: driverId,
      status: ShiftStatus.active,
      clockInTime: DateTime.now(),
      clockInLocation: location,
    );
    
    await supabase.from('shifts').insert(shift.toJson());
    
    // Start GPS tracking
    startLocationTracking();
    
    // Enable order notifications
    enableOrderNotifications();
  }
  
  Future<ShiftSummary> clockOut({
    required String shiftId,
    required LatLng location,
  }) async {
    await supabase.from('shifts').update({
      'status': 'completed',
      'clock_out_time': DateTime.now().toIso8601String(),
      'clock_out_location': location.toJson(),
    }).eq('id', shiftId);
    
    // Stop GPS tracking
    stopLocationTracking();
    
    // Generate summary
    return await generateShiftSummary(shiftId);
  }
}

// Shift Model
class Shift {
  final String id;
  final String driverId;
  final ShiftStatus status;
  final DateTime clockInTime;
  final LatLng clockInLocation;
  final DateTime? clockOutTime;
  final LatLng? clockOutLocation;
  final List<String> deliveryIds;
  
  Duration get duration => 
    (clockOutTime ?? DateTime.now()).difference(clockInTime);
}
```

---

## 4️⃣ Mobile Performance Optimization

### GPS Battery Optimization:

```dart
class LocationService {
  StreamSubscription? _locationSubscription;
  Timer? _throttleTimer;
  
  void startTracking() {
    // During active delivery: high accuracy, 5 sec updates
    if (hasActiveDelivery) {
      _locationSubscription = Geolocator.getPositionStream(
        locationSettings: LocationSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: 10, // meters
        ),
      ).listen(_updateLocation);
    } else {
      // Idle: low accuracy, 30 sec updates
      _locationSubscription = Geolocator.getPositionStream(
        locationSettings: LocationSettings(
          accuracy: LocationAccuracy.medium,
          distanceFilter: 50,
        ),
      ).listen(_updateLocation);
    }
  }
  
  void _updateLocation(Position position) {
    // Throttle updates to server (max 1 per 5 sec)
    if (_throttleTimer == null || !_throttleTimer!.isActive) {
      supabase.from('driver_locations').upsert({
        'driver_id': driverId,
        'lat': position.latitude,
        'lng': position.longitude,
        'updated_at': DateTime.now().toIso8601String(),
      });
      
      _throttleTimer = Timer(Duration(seconds: 5), () {});
    }
  }
}
```

---

## 5️⃣ Offline Mode Strategy

### Cache Critical Data:

```dart
class OfflineManager {
  final Hive = Hive.box('driver_cache');
  
  // Cache shift schedule
  Future<void> cacheShifts(List<Shift> shifts) async {
    await hive.put('shifts', shifts.map((s) => s.toJson()).toList());
  }
  
  // Cache today's orders (for navigation)
  Future<void> cacheOrders(List<Order> orders) async {
    await hive.put('orders', orders.map((o) => o.toJson()).toList());
  }
  
  // Queue actions when offline
  Future<void> queueDeliveryProof(DeliveryProof proof) async {
    final queue = hive.get('offline_queue', defaultValue: []);
    queue.add({
      'action': 'delivery_proof',
      'data': proof.toJson(),
      'timestamp': DateTime.now().toIso8601String(),
    });
    await hive.put('offline_queue', queue);
  }
  
  // Sync when back online
  Future<void> syncOfflineQueue() async {
    final queue = hive.get('offline_queue', defaultValue: []);
    
    for (final item in queue) {
      try {
        await _processQueueItem(item);
      } catch (e) {
        // Keep in queue for next sync
        continue;
      }
    }
    
    await hive.put('offline_queue', []);
  }
}
```

---

## 6️⃣ Translation Implementation

### Multi-language Support:

```dart
class TranslationService {
  final translator = GoogleTranslator();
  
  Future<String> translateMessage({
    required String text,
    required String targetLang,
  }) async {
    try {
      final translation = await translator.translate(
        text,
        to: targetLang,
      );
      return translation.text;
    } catch (e) {
      return text; // Return original on error
    }
  }
  
  // Voice to text with translation
  Future<String> transcribeAndTranslate({
    required String audioPath,
    required String sourceLang,
    required String targetLang,
  }) async {
    // 1. Voice to text (source language)
    final transcript = await speechToText(
      audioPath: audioPath,
      language: sourceLang,
    );
    
    // 2. Translate
    final translated = await translateMessage(
      text: transcript,
      targetLang: targetLang,
    );
    
    return translated;
  }
}

// Supported languages
enum AppLanguage {
  arabic('ar'),
  english('en'),
  urdu('ur'),
  hindi('hi'),
  indonesian('id'),
  bengali('bn');
  
  final String code;
  const AppLanguage(this.code);
}
```

---

## 7️⃣ Gamification System

### Achievements:

```dart
class AchievementSystem {
  final achievements = [
    Achievement(
      id: 'fast_50',
      title: 'السريع',
      description: '50 deliveries on-time',
      icon: '🏆',
      reward: 50, // ر.س bonus
    ),
    Achievement(
      id: 'pro',
      title: 'المحترف',
      description: 'Average 4.5+ rating',
      icon: '⭐',
      reward: 100,
    ),
    Achievement(
      id: 'active_100',
      title: 'النشيط',
      description: '100 deliveries in month',
      icon: '💰',
      reward: 150,
    ),
    Achievement(
      id: 'hero',
      title: 'البطل',
      description: 'Top driver of the month',
      icon: '🚀',
      reward: 500,
    ),
  ];
  
  Future<void> checkAchievements(String driverId) async {
    final stats = await getDriverStats(driverId);
    
    for (final achievement in achievements) {
      if (await _meetsRequirement(achievement, stats)) {
        await _unlockAchievement(driverId, achievement);
      }
    }
  }
}
```

---

## 8️⃣ Safety Features

### Emergency SOS:

```dart
class SafetyManager {
  Future<void> triggerSOS({
    required String driverId,
    required LatLng location,
  }) async {
    // 1. Send alert to owner
    await supabase.from('sos_alerts').insert({
      'driver_id': driverId,
      'location': location.toJson(),
      'timestamp': DateTime.now().toIso8601String(),
      'status': 'active',
    });
    
    // 2. Notify owner via push notification
    await sendPushNotification(
      to: ownerDeviceToken,
      title: 'SOS Alert!',
      body: 'Driver خالد needs help at ${location.toString()}',
      priority: 'high',
    );
    
    // 3. Call emergency contact (optional)
    if (autoCallEnabled) {
      await makePhoneCall(emergencyNumber);
    }
    
    // 4. Share location continuously
    startEmergencyTracking();
  }
}
```

---

## 9️⃣ Smart Incentives

### Dynamic Bonuses:

```dart
class IncentiveEngine {
  double calculateBonus({
    required DateTime orderTime,
    required String weather,
    required int consecutiveDeliveries,
  }) {
    double bonus = 0;
    
    // Peak hours bonus
    final hour = orderTime.hour;
    if ((hour >= 12 && hour < 14) || (hour >= 18 && hour < 20)) {
      bonus += 5; // Lunch/Dinner rush
    }
    if (hour >= 21) {
      bonus += 10; // Late night
    }
    
    // Weather bonus
    if (weather == 'rain') {
      bonus += 10;
    }
    if (weather == 'extreme_heat') {
      bonus += 5;
    }
    if (weather == 'sandstorm') {
      bonus += 20;
    }
    
    // Streak bonus
    if (consecutiveDeliveries >= 5) {
      bonus += 25;
    }
    if (consecutiveDeliveries >= 10) {
      bonus += 50;
    }
    
    return bonus;
  }
}
```

---

## 🔟 Route Optimization

### AI-Powered Routing:

```dart
class RouteOptimizer {
  Future<List<Order>> optimizeRoute(List<Order> orders) async {
    // 1. Group by store
    final groupedByStore = _groupByStore(orders);
    
    // 2. Order by proximity
    final optimized = <Order>[];
    
    for (final storeOrders in groupedByStore.values) {
      // Pickup all from same store first
      optimized.addAll(storeOrders);
    }
    
    // 3. Sort deliveries by proximity (TSP algorithm)
    final deliveryRoute = await _solveTSP(
      start: currentLocation,
      points: optimized.map((o) => o.deliveryAddress).toList(),
    );
    
    return deliveryRoute;
  }
  
  Future<RouteOptimizationResult> _solveTSP({
    required LatLng start,
    required List<Address> points,
  }) async {
    // Use Google Directions API with waypoints optimization
    final response = await http.get(
      'https://maps.googleapis.com/maps/api/directions/json',
      params: {
        'origin': '${start.lat},${start.lng}',
        'destination': '${points.last.lat},${points.last.lng}',
        'waypoints': 'optimize:true|${_waypointsString(points)}',
        'key': googleMapsApiKey,
      },
    );
    
    return RouteOptimizationResult.fromJson(response.data);
  }
}
```

---

## 📊 Database Schema (New Models)

### Shifts Table:

```sql
CREATE TABLE shifts (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  driver_id UUID REFERENCES users(id) NOT NULL,
  store_id UUID REFERENCES stores(id),
  status TEXT NOT NULL CHECK (status IN ('scheduled', 'active', 'completed', 'cancelled')),
  scheduled_start TIMESTAMPTZ NOT NULL,
  scheduled_end TIMESTAMPTZ NOT NULL,
  clock_in_time TIMESTAMPTZ,
  clock_out_time TIMESTAMPTZ,
  clock_in_location JSONB,
  clock_out_location JSONB,
  total_deliveries INT DEFAULT 0,
  total_distance_km DECIMAL(10,2),
  total_earnings DECIMAL(10,2),
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_shifts_driver_id ON shifts(driver_id);
CREATE INDEX idx_shifts_status ON shifts(status);
```

### Driver Earnings Table:

```sql
CREATE TABLE driver_earnings (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  driver_id UUID REFERENCES users(id) NOT NULL,
  shift_id UUID REFERENCES shifts(id),
  delivery_id UUID REFERENCES deliveries(id),
  type TEXT NOT NULL CHECK (type IN ('base_salary', 'commission', 'bonus')),
  category TEXT, -- 'on_time', 'five_star', 'peak_hour', etc.
  amount DECIMAL(10,2) NOT NULL,
  date DATE NOT NULL,
  status TEXT DEFAULT 'pending' CHECK (status IN ('pending', 'approved', 'paid')),
  paid_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_earnings_driver_id ON driver_earnings(driver_id);
CREATE INDEX idx_earnings_date ON driver_earnings(date);
CREATE INDEX idx_earnings_status ON driver_earnings(status);
```

### Delivery Proof Table:

```sql
CREATE TABLE delivery_proofs (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  delivery_id UUID REFERENCES deliveries(id) NOT NULL,
  code VARCHAR(6),
  code_verified_at TIMESTAMPTZ,
  photo_url TEXT,
  signature_url TEXT,
  gps_location JSONB NOT NULL,
  gps_verified BOOLEAN DEFAULT FALSE,
  verification_method TEXT[], -- ['code', 'photo', 'signature', 'gps']
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_proof_delivery_id ON delivery_proofs(delivery_id);
```

---

**📅 التاريخ**: 2026-01-15  
**🔄 آخر تحديث**: 2026-01-15  
**✅ الحالة**: Financial & Operations Details Complete
