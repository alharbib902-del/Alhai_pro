# 🔌 Admin Lite - API Contract

**Version:** 1.0.0  
**Date:** 2026-01-15  
**Base URL:** `https://api.alhai.sa/v1`  
**Status:** ✅ Final

---

## 📋 Overview

Admin Lite uses a **subset** of admin_pos APIs + **one new optimized endpoint** (`/lite/dashboard`)

### Key Differences from admin_pos:

```
1. Fewer endpoints (only essential ones)
2. Optimized responses (less data per request)
3. Mobile-optimized payloads
4. Aggressive caching headers
```

---

## 🔐 Authentication

### Same as admin_pos:

```
POST /auth/login
POST /auth/refresh
GET /auth/me
```

---

## 📊 New Endpoint: Lite Dashboard

### GET /lite/dashboard

**Optimized all-in-one dashboard for mobile**

Query Params:
- `date`: YYYY-MM-DD (default: today)

Response:
```json
{
  "success": true,
  "data": {
    "summary": {
      "today": {
        "revenue": 5500,
        "revenue_growth_percent": 10,
        "orders_count": 12,
        "alerts_count": 3,
        "target": 10000,
        "target_achievement_percent": 55
      },
      "yesterday": {
        "revenue": 5000
      },
      "trend_7days": [3500, 4000, 4500, 5000, 5200, 5500, 5500]
    },
    "stores": [
      {
        "id": "store-uuid-1",
        "name": "بقالة الحي",
        "revenue_today": 3300,
        "percent_of_total": 60,
        "status": "ACTIVE",
        "alerts_count": 2
      },
      {
        "id": "store-uuid-2",
        "name": "بقالة السوق",
        "revenue_today": 2200,
        "percent_of_total": 40,
        "status": "ACTIVE",
        "alerts_count": 1
      }
    ],
    "critical_alerts": [
      {
        "id": "alert-uuid-1",
        "type": "STOCK_LOW",
        "priority": "CRITICAL",
        "message": "حليب نادك نفذ في Store 1",
        "store_id": "store-uuid-1",
        "store_name": "بقالة الحي",
        "action_url": "/products/product-uuid-1/reorder",
        "created_at": "2026-01-15T10:00:00Z"
      }
    ],
    "pending_approvals_count": 3,
    "unread_notifications_count": 5
  }
}
```

---

## 🏪 Stores

### GET /stores/snapshot

**Lightweight store list for mobile**

Response:
```json
{
  "success": true,
  "data": {
    "stores": [
      {
        "id": "store-uuid-1",
        "name": "بقالة الحي",
        "status": "ACTIVE",
        "revenue_today": 3300,
        "orders_today": 8,
        "staff_on_duty": 3,
        "alerts_count": 2
      }
    ]
  }
}
```

### GET /stores/:id/details

**Read-only store details**

Response:
```json
{
  "success": true,
  "data": {
    "id": "store-uuid-1",
    "name": "بقالة الحي",
    "status": "ACTIVE",
    "phone": "+966112345678",
    "address": "حي النخيل، الرياض",
    "stats_today": {
      "revenue": 3300,
      "orders": 8,
      "customers": 25
    },
    "staff_on_duty": [
      {
        "id": "staff-uuid-1",
        "name": "علي الكاشير",
        "role": "CASHIER",
        "phone": "+966501111111"
      }
    ],
    "stock_alerts": [
      {
        "product_name": "حليب نادك",
        "quantity": 5,
        "min_stock": 20,
        "status": "LOW"
      }
    ]
  }
}
```

---

## ⚠️ Alerts

### GET /alerts

**Priority-sorted alerts**

Query Params:
- `priority`: CRITICAL|IMPORTANT|INFO (comma-separated)
- `limit`: 20 (default)

Response:
```json
{
  "success": true,
  "data": {
    "alerts": [
      {
        "id": "alert-uuid-1",
        "type": "STOCK_LOW",
        "priority": "CRITICAL",
        "message": "حليب نادك نفذ في Store 1",
        "store_id": "store-uuid-1",
        "store_name": "بقالة الحي",
        "action_url": "/products/product-uuid-1/reorder",
        "snoozed_until": null,
        "created_at": "2026-01-15T10:00:00Z"
      }
    ],
    "counts": {
      "CRITICAL": 3,
      "IMPORTANT": 5,
      "INFO": 2
    }
  }
}
```

### PUT /alerts/:id/snooze

**Snooze alert for later**

Request:
```json
{
  "snooze_until": "2026-01-15T18:00:00Z"
}
```

---

## ✅ Approvals

### GET /approvals/pending

**Pending approvalspending only**

Response:
```json
{
  "success": true,
  "data": {
    "approvals": [
      {
        "id": "approval-uuid-1",
        "type": "TRANSFER_INVENTORY",
        "title": "نقل مخزون: Store 1 → Store 2",
        "description": "50 حليب نادك",
        "requested_by": "سالم المدير",
        "created_at": "2026-01-15T09:00:00Z",
        "details_url": "/approvals/approval-uuid-1"
      }
    ],
    "total_count": 3
  }
}
```

### POST /approvals/:id/approve

**Quick approve**

Response:
```json
{
  "success": true,
  "message": "تمت الموافقة بنجاح"
}
```

### POST /approvals/:id/reject

**Quick reject**

Request:
```json
{
  "reason": "المخزون غير كافٍ"
}
```

---

## 🔔 Notifications (Mobile-Optimized)

### GET /notifications

**All notifications with mobile optimization**

Query Params:
- `type`: ORDER|RATING|TICKET|DEBT|SUGGESTION|SYSTEM (comma-separated)
- `priority`: CRITICAL|IMPORTANT|INFO
- `unread_only`: true|false
- `limit`: 20 (default)

Response (Mobile-Optimized):
```json
{
  "success": true,
  "data": {
    "notifications": [
      {
        "id": "notif-uuid-1",
        "type": "NEW_ORDER",
        "priority": "IMPORTANT",
        "title": "طلب جديد #12345",
        "message": "500 ر.س من فهد السعيد",
        "icon": "🛒",
        "data": {
          "order_id": "order-uuid-123",
          "customer_name": "فهد السعيد",
          "total_amount": 500
        },
        "actions": [
          {"label": "قبول", "action": "ACCEPT_ORDER", "style": "primary"},
          {"label": "رفض", "action": "REJECT_ORDER", "style": "danger"}
        ],
        "read": false,
        "created_at": "2026-01-15T10:00:00Z",
        "time_ago": "منذ ساعة"
      },
      {
        "id": "notif-uuid-2",
        "type": "STORE_RATING",
        "priority": "CRITICAL",
        "title": "⚠️ تقييم منخفض",
        "message": "بقالة السوق: ⭐⭐ (2/5)",
        "icon": "⭐",
        "data": {
          "store_name": "بقالة السوق",
          "rating": 2,
          "customer_name": "محمد أحمد"
        },
        "actions": [
          {"label": "حل المشكلة", "action": "RESOLVE_ISSUE", "style": "warning"}
        ],
        "read": false,
        "created_at": "2026-01-15T09:30:00Z",
        "time_ago": "منذ ساعتين"
      },
      {
        "id": "notif-uuid-3",
        "type": "DEBT_OVERDUE",
        "priority": "IMPORTANT",
        "title": "دين متأخر",
        "message": "محمد أحمد - 300 ر.س (30 يوم)",
        "icon": "💰",
        "data": {
          "customer_name": "محمد أحمد",
          "amount": 300,
          "days_overdue": 30
        },
        "actions": [
          {"label": "تذكير SMS", "action": "SEND_SMS", "style": "secondary"}
        ],
        "read": true,
        "created_at": "2026-01-15T08:00:00Z",
        "time_ago": "منذ 4 ساعات"
      }
    ],
    "unread_count": 15,
    "by_type": {
      "ORDER": 5,
      "RATING": 3,
      "TICKET": 2,
      "DEBT": 3,
      "SUGGESTION": 1,
      "SYSTEM": 1
    },
    "by_priority": {
      "CRITICAL": 2,
      "IMPORTANT": 8,
      "INFO": 5
    }
  }
}
```

---

### Notification Types (Mobile UI)

**All types same as admin_pos, but with mobile enhancements:**

#### Priority Indicators:
```
🔴 CRITICAL:
   - Red badge
   - Sound + Vibration
   - Heads-up notification
   - Auto-expand

🟠 IMPORTANT:
   - Orange badge
   - Sound only
   - Normal notification
   
🟡 INFO:
   - Blue badge
   - Silent
   - Collapsed by default
```

#### Quick Actions (Swipe):
```
← Swipe Left: Primary action
   - Accept Order
   - Approve Request
   - Send Reminder
   
→ Swipe Right: Secondary action
   - Reject
   - Snooze
   - Dismiss
   
↑ Swipe Up: View details
```

---

### Supported Types Summary:

**Orders (5 types):**
- NEW_ORDER (طلب جديد)
- ORDER_ACCEPTED (تم القبول)
- DRIVER_ASSIGNED (تم تعيين مندوب)
- DRIVER_CHANGED (تغيير مندوب)
- DELIVERY_STATUS (حالة التوصيل)

**Ratings (3 types):**
- STORE_RATING (تقييم بقالة)
- DRIVER_RATING (تقييم مندوب)
- LOW_RATING_ALERT (تنبيه تقييم منخفض)

**Tickets (3 types):**
- NEW_TICKET (تذكرة جديدة)
- TICKET_WAITING (تنتظر رد)
- TICKET_RESOLVED (محلولة)

**Debts (4 types):**
- NEW_DEBT (دين جديد)
- PAYMENT_RECEIVED (دفعة مستلمة)
- DEBT_OVERDUE (دين متأخر)
- DEBT_LIMIT_EXCEEDED (تجاوز الحد)

**Suggestions (3 types):**
- CUSTOMER_SUGGESTION (اقتراح عميل)
- POPULAR_SUGGESTION (اقتراح شائع)
- STAFF_NOTE (ملاحظة موظف)

**System (2 types):**
- STOCK_ALERT (تنبيه مخزون)
- SYSTEM_UPDATE (تحديث نظام)

> **Note**: For full type specifications, see `admin_pos/ADMIN_API_CONTRACT.md#notifications`

---

### POST /notifications/:id/action

**Execute quick action**

Request:
```json
{
  "action": "ACCEPT_ORDER"
}
```

Response:
```json
{
  "success": true,
  "message": "تم قبول الطلب",
  "haptic_feedback": "success"
}
```

---

### PUT /notifications/:id/read

**Mark as read**

Response:
```json
{
  "success": true,
  "read_at": "2026-01-15T11:00:00Z"
}
```

---

### PUT /notifications/mark-all-read

**Mark all as read**

```json
{
  "success": true,
  "count": 15
}
```

---

### GET /notifications/stats

**Notification statistics**

Response:
```json
{
  "success": true,
  "data": {
    "total_unread": 15,
    "by_type": {
      "ORDER": 5,
      "RATING": 3,
      "TICKET": 2,
      "DEBT": 3,
      "SUGGESTION": 1,
      "SYSTEM": 1
    },
    "by_priority": {
      "CRITICAL": 2,
      "IMPORTANT": 8,
      "INFO": 5
    },
    "today_summary": {
      "new_orders": 12,
      "avg_rating": 4.2,
      "pending_tickets": 2,
      "overdue_debts": 3
    }
  }
}
```

---

### Mobile Push Notifications

**FCM Configuration:**

```json
{
  "notification": {
    "title": "طلب جديد #12345",
    "body": "500 ر.س من فهد السعيد",
    "icon": "order_icon",
    "color": "#FF6B00",
    "sound": priority === "CRITICAL" ? "critical_alert" : "default",
    "priority": "high",
    "vibrate": [0, 500, 250, 500]
  },
  "data": {
    "type": "NEW_ORDER",
    "priority": "IMPORTANT",
    "order_id": "order-uuid-123",
    "action_screen": "/orders/order-uuid-123"
  }
}
```

**Notification Channels (Android):**
```
- Critical: Max priority + LED + Sound + Vibration
- Important: High priority + Sound
- Info: Low priority + Silent
```

---

## 📦 Order Tracking (Mobile-Optimized)

### GET /orders/:id/tracking

**Quick order tracking for mobile**

Response (Simplified for Mobile):
```json
{
  "success": true,
  "data": {
    "order_number": "#12345",
    "status": "OUT_FOR_DELIVERY",
    "status_ar": "في الطريق",
    "customer_name": "فهد السعيد",
    "driver": {
      "name": "خالد المندوب",
      "phone": "+966501111111",
      "location": {
        "lat": 24.7136,
        "lng": 46.6753
      }
    },
    "eta_minutes": 12,
    "distance_km": 3.5,
    "total_amount": 500,
    "items_count": 5,
    "timeline_summary": "طلب → قبول → تحضير → توصيل",
    "progress_percent": 75
  }
}
```

---

### POST /orders/:id/quick-action

**Quick action on order (mobile-optimized)**

Request:
```json
{
  "action": "ACCEPT",
  "auto_assign_driver": true
}
```

Actions: `ACCEPT`, `REJECT`, `ASSIGN_DRIVER`, `MARK_READY`

Response:
```json
{
  "success": true,
  "message": "تم قبول الطلب وتعيين المندوب",
  "new_status": "ASSIGNED",
  "haptic_feedback": "success"
}
```

---

## 📊 Revenue Quick Stats (Mobile)

### GET /analytics/revenue/quick

**Quick revenue overview (POS vs Delivery)**

Query Params:
- `period`: today|week|month (default: today)

Response (Mobile-Optimized):
```json
{
  "success": true,
  "data": {
    "period": "today",
    "total": 10000,
    "pos": {
      "amount": 6000,
      "percent": 60,
      "trend": "up",
      "growth": "+8%"
    },
    "delivery": {
      "amount": 4000,
      "percent": 40,
      "trend": "up",
      "growth": "+12%"
    },
    "chart_data": {
      "labels": ["POS", "Delivery"],
      "values": [6000, 4000],
      "colors": ["#4CAF50", "#FF9800"]
    },
    "summary": "Delivery نمو أسرع من POS",
    "recommendation": "استمر في تحسين التوصيل"
  }
}
```

---

### GET /analytics/stores/quick-compare

**Quick store comparison (top 3 metrics)**

Response (Mobile-Simplified):
```json
{
  "success": true,
  "data": {
    "stores": [
      {
        "id": "store-uuid-1",
        "name": "بقالة الحي",
        "revenue_today": 6000,
        "status": "🟢 Excellent",
        "delivery_time": "25 min ⚡",
        "rating": "4.8★"
      },
      {
        "id": "store-uuid-2",
        "name": "بقالة السوق",
        "revenue_today": 4000,
        "status": "🟡 Good",
        "delivery_time": "35 min ⚠️",
        "rating": "4.2★"
      }
    ],
    "quick_insight": "بقالة السوق يحتاج +1 مندوب",
    "action_button": {
      "label": "عرض التفاصيل",
      "screen": "/stores/compare"
    }
  }
}
```

---

### GET /reports/today

**Today's performance summary**

Response:
```json
{
  "success": true,
  "data": {
    "revenue": 5500,
    "revenue_target": 10000,
    "achievement_percent": 55,
    "orders_count": 12,
    "customers_count": 35,
    "avg_order_value": 458,
    "top_products": [
      {
        "name": "حليب نادك",
        "units_sold": 20,
        "revenue": 170
      }
    ],
    "by_store": [
      {
        "store_name": "بقالة الحي",
        "revenue": 3300,
        "percent": 60
      }
    ]
  }
}
```

---

## 💾 Caching Headers

All responses include aggressive caching:

```http
Cache-Control: private, max-age=120  # 2 minutes for dashboard
Cache-Control: private, max-age=30   # 30 seconds for alerts
Cache-Control: no-cache              # No cache for approvals
```

---

## ⚠️ Error Responses

Same as admin_pos:

```json
{
  "success": false,
  "error": {
    "code": "UNAUTHORIZED",
    "message": "Token expired"
  }
}
```

---

**📅 Last Updated**: 2026-01-15  
**✅ Status**: Final  
**🎯 Next**: ADMIN_LITE_UX_WIREFRAMES.md
