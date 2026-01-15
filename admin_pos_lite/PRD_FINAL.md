# 📱 Admin Lite - Product Requirements Document

**Version:** 1.0.0  
**Date:** 2026-01-15  
**Status:** ✅ Final  
**Platform:** Mobile Only (iOS + Android)

---

## 📋 جدول المحتويات

1. [Overview](#overview)
2. [Target Users](#target-users)
3. [Core Concept](#core-concept)
4. [User Stories](#user-stories)
5. [Screens Breakdown](#screens-breakdown)
6. [Route Dictionary](#route-dictionary)
7. [Priorities](#priorities)
8. [Development Checklist](#development-checklist)

---

## 🎯 Overview

**Admin Lite** = نسخة خفيفة وسريعة من Admin POS للمؤشرات والقرارات السريعة

### الفرق عن admin_pos:

| admin_pos Full | admin_lite |
|----------------|------------|
| 106 screens | **28 screens** (+6 B2B + 2 AI) |
| Screens | 94 | **28** |
| Platform | Web + Mobile + Desktop | **Mobile Only** |
| Use Case | Detailed management | **Quick decisions** |
| Session Time | 30-60 minutes | **2-5 minutes** |
| CRUD | ✅ Full | ⚡ Quick actions only |
| Target | Desktop/Office | **On-the-go** |

---

## 👤 Target Users

### Primary User: Store Owner (On-the-go)

**Scenarios:**
- صباحاً في السيارة: check مبيعات أمس + approve requests
- استراحة الغداء: check KPI + send reminders
- قبل النوم: view today's summary + tomorrow's alerts

**Pain Points:**
- ❌ admin_pos ثقيل للجوال
- ❌ يحتاج وقت طويل للوصول للمعلومة
- ❌ كثير شاشات ما يحتاجها on-the-go

**Solution:**
- ✅ تطبيق خفيف (< 15 MB)
- ✅ Dashboard واحد يعرض كل شيء
- ✅ Quick actions بدون تعقيد

---

## 💡 Core Concept

### The 3-Tap Rule:
```
أي معلومة أو action لازم ما تزيد عن 3 taps:

Tap 1: Open app (fingerprint/face ID)
Tap 2: Dashboard → Alert
Tap 3: Action (Approve/Reject/Send)
Done! ✅
```

### Real-time First:
```
كل شيء real-time:
- Dashboard updates كل 5 ثواني
- Notifications push فوري
- Status changes live
```

### Mobile-Optimized:
```
- One-hand operation ✅
- Large buttons
- Swipe gestures
- Voice commands (Phase 2)
```

---

## 📖 User Stories

### Epic 1: Quick Monitoring

**Story 1.1: Morning Check**
```
As an Owner
I want to see yesterday's performance in one screen
So I can start my day informed

Acceptance Criteria:
- Dashboard shows yesterday's revenue, orders, alerts
- Comparison with day before (+/- %)
- Critical alerts highlighted in red
- Load time < 2 seconds
```

**Story 1.2: Real-time KPIs**
```
As an Owner
I want to see live updates of today's sales
So I know if targets are being met

Acceptance Criteria:
- Revenue updates every 5 seconds
- Progress bar showing target achievement
- Store breakdown visible
- No manual refresh needed
```

---

### Epic 2: Quick Actions

**Story 2.1: Approve Requests**
```
As an Owner
I want to approve/reject pending requests quickly
So I don't block operations

Acceptance Criteria:
- List of pending approvals
- One-tap approve/reject
- Confirmation dialog
- Success feedback
```

**Story 2.2: Quick Reorder**
```
As an Owner
I want to reorder stock with one tap
So I can fix shortages immediately

Acceptance Criteria:
- Suggested reorder quantities (AI)
- One-tap to confirm
- SMS sent to supplier
- Inventory updated
```

---

### Epic 3: Alerts & Notifications

**Story 3.1: Priority Alerts**
```
As an Owner
I want to see critical issues first
So I can prioritize actions

Acceptance Criteria:
- Alerts sorted by priority (Critical/Important/Info)
- Badge count on icon
- Push notifications enabled
- Snooze option available
```

---

## 📱 Screens Breakdown

### Total Screens: 20

---

### Phase 1: Authentication (2 screens)

#### 1. Splash Screen
- Logo + loading
- Auto-login if saved

#### 2. Login Screen
- Phone + OTP
- Fingerprint/Face ID
- "Remember me"

---

### Phase 2: Dashboard (5 screens)

#### 3. Main Dashboard
```
┌─────────────────────────┐
│ [Owner Name]      [🔔3] │
├─────────────────────────┤
│                         │
│ Today's Revenue         │
│ 5,500 ر.س  [+10% ✅]   │
│                         │
│ ▁▃▅▇█▇▅▃ (7 days)      │
│                         │
│ ┌──────┐ ┌──────┐      │
│ │ 12   │ │  3   │      │
│ │Orders│ │Alerts│      │
│ └──────┘ └──────┘      │
│                         │
│ Quick Actions:          │
│ [Approve] [Reorder]     │
│ [Reminders] [Reports]   │
│                         │
│ Store Performance:      │
│ Store 1: 60% ████████  │
│ Store 2: 40% █████      │
│                         │
│ [View All Details →]    │
└─────────────────────────┘
```

#### 4. Stores Snapshot
- List of stores
- Revenue per store
- Status (Active/Issues)
- Tap to see details

#### 5. Store Details (Read-only)
- Store name + address
- Today's stats
- Staff on duty
- Stock alerts
- [Call Manager] button

#### 6. Financial Summary
- Today/Week/Month tabs
- Revenue breakdown
- Debts summary
- Profit margin
- [Export PDF] button

#### 7. Performance Comparison
- Store 1 vs Store 2
- Bar charts (simple)
- Key metrics only
- AI recommendation

---

### Phase 3: Alerts & Actions (5 screens)

#### 8. Alerts List
```
Priority sorting:
├── 🔴 Critical (3)
│   └── Stock نفذ - حليب نادك
├── 🟠 Important (5)
│   └── Debt overdue 60 days
└── 🟡 Info (2)
    └── New customer
```

#### 9. Alert Details
- Full description
- Suggested action
- [Take Action] button
- [Snooze] option

#### 10. Quick Approvals
- Pending requests list
- Type icons (Transfer/Staff/Price)
- [Approve] [Reject] buttons
- Swipe gestures

#### 11. Approval Details
- Full request info
- Who requested
- Why
- Impact analysis
- [Approve] [Reject]

#### 12. Quick Actions Menu
- Grid of actions
- Icons + labels
- One-tap execution
- Confirmation dialogs

---

### Phase 4: Notifications (2 screens)

#### 13. Notifications Center
- All notifications
- Read/Unread
- Filter by type
- Mark all as read

#### 14. Notification Details
- Full message
- Timestamp
- Related screen link
- [Dismiss] [Take Action]

---

### Phase 5: Reports (2 screens)

#### 15. Today's Performance
- Revenue progress
- Orders count
- Top products
- Staff efficiency
- Auto-refresh

#### 16. Quick Reports
- Preset report templates:
  - Yesterday summary
  - This week
  - This month
  - Compare stores
- [Email Me] button

---

### Phase 6: Settings (4 screens)

#### 17. Profile (Minimal)
- Owner name + photo
- Subscription plan
- App version
- [Logout]

#### 18. Notification Settings
- Enable/Disable push
- Alert priorities
- Quiet hours
- Sound/Vibration

#### 19. Quick Settings
- Language (AR/EN)
- Currency
- Date format
- [Reset Defaults]

#### 20. About & Help
- App version
- [Contact Support]
- [Terms]
- [Privacy Policy]

---

## 🗺️ Route Dictionary

```dart
// Authentication
'/splash'
'/login'

// Dashboard
'/dashboard'                    // Main
'/stores'                       // Stores snapshot
'/stores/:id/details'           // Store details
'/financial/summary'            // Financial summary
'/stores/compare'               // Performance comparison

// Alerts & Actions
'/alerts'                       // Alerts list
'/alerts/:id'                   // Alert details
'/approvals'                    // Quick approvals
'/approvals/:id'                // Approval details
'/quick-actions'                // Quick actions menu

// Notifications
'/notifications'                // Notifications center
'/notifications/:id'            // Notification details

// Reports
'/reports/today'                // Today's performance
'/reports/quick'                // Quick reports

// Settings
'/profile'                      // Profile
'/settings/notifications'       // Notification settings
'/settings'                     // Quick settings
'/about'                        // About & help
```

---

## 🎯 Priorities

### P0 - Must Have (Core - 12 screens):
1. ✅ Splash
2. ✅ Login
3. ✅ Main Dashboard
4. ✅ Stores Snapshot
5. ✅ Store Details
6. ✅ Alerts List
7. ✅ Alert Details
8. ✅ Quick Approvals
9. ✅ Approval Details
10. ✅ Notifications Center
11. ✅ Profile
12. ✅ Settings

### P1 - Should Have (Enhanced - 6 screens):
13. ✅ Financial Summary
14. ✅ Performance Comparison
15. ✅ Notification Details
16. ✅ Quick Actions Menu
17. ✅ Today's Performance
18. ✅ Notification Settings

### P2 - Nice to Have (Optional - 2 screens):
19. ✅ Quick Reports
20. ✅ About & Help

---

## 📊 Status Models

```dart
// Alert Priority
enum AlertPriority {
  CRITICAL,    // 🔴 Needs immediate action
  IMPORTANT,   // 🟠 Needs action today
  INFO         // 🟡 FYI only
}

// Alert Type
enum AlertType {
  STOCK_LOW,
  DEBT_OVERDUE,
  STAFF_ABSENT,
  SYSTEM_ERROR,
  TARGET_MISSED,
  NEW_ORDER
}

// Approval Status
enum ApprovalStatus {
  PENDING,
  APPROVED,
  REJECTED,
  EXPIRED
}

// Approval Type
enum ApprovalType {
  TRANSFER_INVENTORY,
  TRANSFER_STAFF,
  PRICE_CHANGE,
  DISCOUNT_REQUEST,
  LEAVE_REQUEST
}
```

---

## ✅ Development Checklist

### Phase 1: Core Setup
- [ ] Project structure (Flutter mobile-only)
- [ ] alhai_core integration
- [ ] alhai_design_system integration
- [ ] Supabase auth setup
- [ ] Fingerprint/Face ID
- [ ] Push notifications (FCM)

### Phase 2: Dashboard
- [ ] Main dashboard screen
- [ ] Real-time updates (5 sec interval)
- [ ] Store snapshot screen
- [ ] Store details (read-only)
- [ ] Charts (fl_chart package)

### Phase 3: Alerts
- [ ] Alerts list screen
- [ ] Alert details screen
- [ ] Priority sorting
- [ ] Badge count
- [ ] Push notifications

### Phase 4: Approvals
- [ ] Quick approvals list
- [ ] Approval details
- [ ] Approve/Reject actions
- [ ] Swipe gestures
- [ ] Confirmation dialogs

### Phase 5: Notifications
- [ ] Notifications center
- [ ] Notification details
- [ ] Mark as read/unread
- [ ] Filter by type

### Phase 6: Reports
- [ ] Today's performance
- [ ] Quick reports
- [ ] Email export
- [ ] PDF generation

### Phase 7: Settings
- [ ] Profile screen
- [ ] Notification settings
- [ ] App settings
- [ ] About & help

### Phase 8: Polish
- [ ] Loading states
- [ ] Error handling
- [ ] Offline mode (basic)
- [ ] Performance optimization
- [ ] Accessibility
- [ ] Localization (AR/EN)

### Phase 9: Testing
- [ ] Unit tests
- [ ] Widget tests
- [ ] Integration tests
- [ ] Manual QA
- [ ] Beta testing

### Phase 10: Deployment
- [ ] iOS build
- [ ] Android build
- [ ] App Store submission
- [ ] Play Store submission
- [ ] Analytics setup

---

**📅 Last Updated**: 2026-01-15  
**✅ Status**: Final - Ready for Development  
**🎯 Next**: ADMIN_LITE_SPEC.md
