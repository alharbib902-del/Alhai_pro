# Admin POS Lite - Step 002: Dashboard + Real-time

> **المرحلة:** Phase 2 | **المدة:** أسبوعين | **الأولوية:** P0

---

## 🎯 الهدف

إنشاء Dashboard يتحدث لحظياً:
- Main Dashboard (كل 5 ثواني)
- Stores Snapshot
- Store Details (read-only)

---

## 📋 المهام

### DASH-001: Main Dashboard (14h)

**Route:** `/dashboard`

**محتويات الشاشة:**
```
┌─────────────────────────┐
│ [Owner Name]      [🔔3] │
├─────────────────────────┤
│ Today's Revenue         │
│ 5,500 ر.س  [+10% ✅]   │
│ ▁▃▅▇█▇▅▃ (7 days)      │
│                         │
│ ┌──────┐ ┌──────┐      │
│ │ 12   │ │  3   │      │
│ │Orders│ │Alerts│      │
│ └──────┘ └──────┘      │
│                         │
│ Quick Actions:          │
│ [Approve] [Reorder]     │
└─────────────────────────┘
```

### REAL-001: Auto-refresh (4h)

```dart
class DashboardViewModel extends ChangeNotifier {
  Timer? _refreshTimer;
  
  void startAutoRefresh() {
    _refreshTimer = Timer.periodic(
      Duration(seconds: 5),
      (_) => fetchDashboard(),
    );
  }
}
```

### DASH-002: Stores Snapshot (8h)

**Route:** `/stores`

- قائمة البقالات
- Revenue per store
- Status (Active/Issues)
- Tap → Store Details

---

## ✅ معايير الإنجاز

- [ ] Dashboard يتحدث كل 5 ثواني
- [ ] Stores list يعرض KPI
- [ ] Charts تعمل (fl_chart)
- [ ] Real-time updates

---

## 📚 المراجع

- [PROD.json](../PROD.json) - DASH-*, REAL-*
- [PRD_FINAL.md](../PRD_FINAL.md) - Dashboard wireframe
