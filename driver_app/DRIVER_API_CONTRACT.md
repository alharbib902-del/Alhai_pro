# 🔌 Driver App - API Contract

**Version:** 1.0.0  
**Date:** 2026-01-15  
**Base URL:** `https://api.alhai.sa/v1`

---

## 📋 Overview

Driver App APIs for delivery management, earnings tracking, and communication.

**Shared with:**
- admin_pos (driver management)
- customer_app (order delivery)
- alhai_core (models)

---

## 🔐 Authentication

```
POST /auth/driver/login
POST /auth/driver/verify-otp
POST /auth/driver/refresh-token
```

---

## 📦 Orders & Deliveries

### GET /driver/orders/available
**Get available orders for driver**

Response:
```json
{
  "orders": [
    {
      "order_id": "order-uuid-123",
      "order_number": "#12345",
      "store_name": "بقالة الحي",
      "customer_name": "فهد السعيد",
      "total_amount": 500,
      "delivery_fee": 15,
      "pickup_distance_km": 2.5,
      "delivery_distance_km": 5.0,
      "estimated_time_min": 23,
      "status": "PENDING_DRIVER"
    }
  ]
}
```

### POST /driver/orders/:id/accept
**Accept order**

Request:
```json
{
  "estimated_arrival_min": 25
}
```

### POST /driver/orders/:id/reject
**Reject order with reason**

Request:
```json
{
  "reason": "Too far",
  "voice_note_url": "https://r2.../reason.mp3" // optional
}
```

### GET /driver/orders/:id/details
**Get order details**

### POST /driver/deliveries/:id/update-location
**Update driver location**

Request:
```json
{
  "lat": 24.7136,
  "lng": 46.6753,
  "heading": 180,
  "speed_kmh": 45
}
```

### POST /driver/deliveries/:id/proof
**Submit delivery proof**

Request:
```json
{
  "code": "5279",
  "photo_url": "https://r2.../proof.jpg",
  "signature_url": "https://r2.../signature.png",
  "gps_location": {"lat": 24.7500, "lng": 46.6800}
}
```

---

## 💰 Earnings

### GET /driver/earnings/summary
**Get earnings summary**

Query: `period=today|week|month`

Response:
```json
{
  "period": "today",
  "total": 270,
  "breakdown": {
    "base": 140,
    "commission": 140,
    "bonuses": {
      "on_time": 70,
      "five_star": 60
    }
  },
  "deliveries_count": 14,
  "avg_per_delivery": 19.3
}
```

---

## 📅 Shifts

### POST /driver/shifts/clock-in
**Clock in for shift**

Request:
```json
{
  "location": {"lat": 24.7136, "lng": 46.6753}
}
```

### POST /driver/shifts/clock-out
**Clock out from shift**

Response:
```json
{
  "shift_summary": {
    "duration_hours": 6,
    "deliveries": 14,
    "distance_km": 45,
    "earnings": 270
  }
}
```

---

## 💬 Chat

### GET /driver/chat/:orderId/messages
**Get chat messages**

### POST /driver/chat/:orderId/send
**Send message**

Request:
```json
{
  "type": "text|voice|photo",
  "content": "أنا في الطريق",
  "media_url": "https://..." // if voice/photo
}
```

---

## 🌐 Translation

### POST /driver/translate
**Translate text**

Request:
```json
{
  "text": "أين أنت؟",
  "target_lang": "ur" // ur, hi, id, bn
}
```

Response:
```json
{
  "translated": "آپ کہاں ہیں؟",
  "source_lang": "ar"
}
```

---

**For complete API documentation, see full contract.**

**📅 Last Updated**: 2026-01-15
