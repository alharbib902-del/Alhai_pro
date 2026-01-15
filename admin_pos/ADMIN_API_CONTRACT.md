p# 🔌 Admin POS - API Contract

**Version:** 1.0.0  
**Date:** 2026-01-15  
**Base URL:** `https://api.alhai.sa/v1`  
**Status:** ✅ Final

---

## 📋 جدول المحتويات

1. [Authentication](#authentication)
2. [Owners Management](#owners-management)
3. [Stores Management](#stores-management)
4. [Staff Management](#staff-management)
5. [Products & Inventory](#products--inventory)
6. [Customers](#customers)
7. [Orders & Deliveries](#orders--deliveries)
8. [Financial & Reports](#financial--reports)
9. [Subscriptions](#subscriptions)
10. [Referrals](#referrals)

---

## � Financial Terminology Standards

### Unified Naming Convention:

This API uses consistent financial terminology across all endpoints:

```
Revenue = Total sales amount (before deducting costs)
Cost = Cost of goods sold (COGS)
Profit = Revenue - Cost (Gross Profit)
Margin = (Profit / Revenue) × 100

✅ Always use: revenue, cost, profit, margin_percent
❌ Never use: sales (in financial totals), gross_profit, net_profit
```

### Standard Response Format:

```json
{
  "total_revenue": 50000,        // إجمالي المبيعات
  "total_cost": 37000,            // إجمالي التكلفة
  "total_profit": 13000,          // إجمالي الربح (Gross)
  "profit_margin_percent": 26,    // نسبة الربح
  
  "breakdown": [{
    "revenue": 15000,
    "cost": 11000,
    "profit": 4000,
    "margin_percent": 26.7
  }]
}
```

---

## �🔐 Authentication

### POST /auth/signup
**Owner Registration**

Request:
```json
{
  "name": "محمد أحمد",
  "phone": "+966501234567",
  "email": "m.ahmed@example.com",
  "trade_license": "1234567890",
  "id_image_url": "https://r2.alhai.sa/id_images/abc123.jpg",
  "referral_code": "MSAWQ123"
}
```

Response:
```json
{
  "success": true,
  "data": {
    "owner_id": "owner-uuid-123",
    "status": "PENDING_APPROVAL",
    "message": "تم استلام طلبك. سيتم مراجعته خلال 24 ساعة"
  }
}
```

---

### POST /auth/login
**Owner Login**

Request:
```json
{
  "phone": "+966501234567",
  "password": "hashed_password"
}
```

Response:
```json
{
  "success": true,
  "data": {
    "access_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
    "refresh_token": "refresh_token_here",
    "owner": {
      "id": "owner-uuid-123",
      "name": "محمد أحمد",
      "email": "m.ahmed@example.com",
      "status": "APPROVED",
      "subscription_plan": "basic"
    }
  }
}
```

---

### POST /auth/send-otp
**Send OTP for Login**

Request:
```json
{
  "phone": "+966501234567"
}
```

Response:
```json
{
  "success": true,
  "message": "تم إرسال رمز التحقق"
}
```

---

### POST /auth/verify-otp
**Verify OTP**

Request:
```json
{
  "phone": "+966501234567",
  "otp": "123456"
}
```

Response:
```json
{
  "success": true,
  "data": {
    "access_token": "...",
    "owner": {...}
  }
}
```

---

## 👤 Owners Management

### GET /owners/me
**Get Current Owner Profile**

Headers:
```
Authorization: Bearer {access_token}
```

Response:
```json
{
  "success": true,
  "data": {
    "id": "owner-uuid-123",
    "name": "محمد أحمد",
    "phone": "+966501234567",
    "email": "m.ahmed@example.com",
    "status": "APPROVED",
    "subscription": {
      "plan": "basic",
      "status": "ACTIVE",
      "expires_at": "2026-02-15T00:00:00Z",
      "limits": {
        "max_stores": 1,
        "max_staff": 3,
        "max_products": 1000
      }
    },
    "referral_code": "OWNER123",
    "referred_by": "MSAWQ123",
    "created_at": "2026-01-01T00:00:00Z"
  }
}
```

---

### PUT /owners/me
**Update Owner Profile**

Request:
```json
{
  "name": "محمد أحمد السعيد",
  "email": "new.email@example.com"
}
```

Response:
```json
{
  "success": true,
  "data": {
    "id": "owner-uuid-123",
    "name": "محمد أحمد السعيد",
    "email": "new.email@example.com"
  }
}
```

---

## 🏪 Stores Management

### GET /stores
**Get All Stores (Owner's)**

Query Params:
- `page`: 1
- `limit`: 20
- `status`: ACTIVE|INACTIVE

Response:
```json
{
  "success": true,
  "data": {
    "stores": [
      {
        "id": "store-uuid-1",
        "name": "بقالة الحي",
        "name_en": "Alhai Grocery",
        "address": "حي النخيل، الرياض",
        "lat": 24.7136,
        "lng": 46.6753,
        "phone": "+966112345678",
        "status": "ACTIVE",
        "logo_url": "https://r2.alhai.sa/stores/logo1.jpg",
        "working_hours": {
          "saturday": {"open": "08:00", "close": "23:00"},
          "sunday": {"open": "08:00", "close": "23:00"}
        },
        "delivery_radius_km": 5,
        "created_at": "2026-01-05T00:00:00Z"
      }
    ],
    "pagination": {
      "page": 1,
      "limit": 20,
      "total": 1
    }
  }
}
```

---

### POST /stores
**Create New Store**

Request:
```json
{
  "name": "بقالة السوق",
  "name_en": "Souq Grocery",
  "address": "حي الملك فهد، الرياض",
  "lat": 24.7250,
  "lng": 46.6800,
  "phone": "+966112345679",
  "logo": "base64_image_data",
  "working_hours": {
    "saturday": {"open": "08:00", "close": "23:00"}
  },
  "delivery_radius_km": 5,
  "min_order_value": 20,
  "delivery_fee": 5,
  "vat_percentage": 15
}
```

Response:
```json
{
  "success": true,
  "data": {
    "id": "store-uuid-2",
    "name": "بقالة السوق",
    "status": "ACTIVE",
    "warehouse": {
      "id": "warehouse-uuid-1",
      "name": "المستودع الرئيسي",
      "location": "نفس موقع البقالة"
    }
  }
}
```

Error (Subscription Limit):
```json
{
  "success": false,
  "error": {
    "code": "SUBSCRIPTION_LIMIT_EXCEEDED",
    "message": "خطتك Basic تسمح ببقالة واحدة فقط. ترقية للـ Pro؟",
    "upgrade_url": "/subscription/upgrade"
  }
}
```

---

### GET /stores/:id
**Get Store Details**

Response:
```json
{
  "success": true,
  "data": {
    "id": "store-uuid-1",
    "name": "بقالة الحي",
    "address": "حي النخيل، الرياض",
    "lat": 24.7136,
    "lng": 46.6753,
    "stats": {
      "total_orders_today": 12,
      "revenue_today": 1500,
      "active_customers": 45,
      "pending_debts": 5000
    },
    "warehouses": [
      {
        "id": "warehouse-uuid-1",
        "name": "المستودع الرئيسي"
      }
    ]
  }
}
```

---

### PUT /stores/:id
**Update Store**

Request:
```json
{
  "name": "بقالة الحي الجديدة",
  "phone": "+966112345670",
  "delivery_fee": 10
}
```

---

### DELETE /stores/:id
**Delete Store (Soft)**

Response:
```json
{
  "success": true,
  "message": "تم حذف البقالة بنجاح"
}
```

---

## 👥 Staff Management

### GET /staff
**Get All Staff**

Query Params:
- `store_id`: filter by store
- `role`: MANAGER|CASHIER|DRIVER

Response:
```json
{
  "success": true,
  "data": {
    "staff": [
      {
        "id": "staff-uuid-1",
        "name": "علي الكاشير",
        "phone": "+966501111111",
        "role": "CASHIER",
        "store": {
          "id": "store-uuid-1",
          "name": "بقالة الحي"
        },
        "pin": "1234",
        "permissions": ["SELL", "RETURNS"],
        "status": "ACTIVE",
        "hire_date": "2025-06-01"
      }
    ]
  }
}
```

---

### POST /staff
**Add New Staff Member**

Request:
```json
{
  "name": "سالم المدير",
  "phone": "+966503333333",
  "role": "MANAGER",
  "store_id": "store-uuid-1",
  "pin": "5678",
  "permissions": ["SELL", "RETURNS", "EDIT_PRICES", "MANAGE_INVENTORY"],
  "salary": 5000
}
```

Response:
```json
{
  "success": true,
  "data": {
    "id": "staff-uuid-2",
    "name": "سالم المدير",
    "invitation_sent": true,
    "sms_sent": true,
    "email_sent": true
  }
}
```

---

### POST /staff/:id/transfer
**Transfer Staff to Another Store**

Request:
```json
{
  "from_store_id": "store-uuid-1",
  "to_store_id": "store-uuid-2",
  "transfer_type": "PERMANENT",
  "effective_date": "2026-02-01",
  "new_salary": 4500,
  "reason": "Store 2 يحتاج كاشير"
}
```

Response:
```json
{
  "success": true,
  "data": {
    "transfer_id": "transfer-uuid-1",
    "status": "PENDING_APPROVAL",
    "approvals_required": [
      {
        "approver": "Store 1 Manager",
        "status": "PENDING"
      }
    ]
  }
}
```

---

## 📦 Products & Inventory

### GET /products
**Get All Products**

Query Params:
- `store_id`: optional (all stores by default)
- `category_id`: filter by category
- `search`: search by name/barcode
- `page`: 1
- `limit`: 50

Response:
```json
{
  "success": true,
  "data": {
    "products": [
      {
        "id": "product-uuid-1",
        "name": "حليب نادك كامل الدسم 1 لتر",
        "name_en": "Nadec Full Cream Milk 1L",
        "barcode": "6281000001234",
        "category": {
          "id": "cat-uuid-1",
          "name": "ألبان ومشتقاتها"
        },
        "sell_price": 8.50,
        "purchase_price": 6.00,
        "image_thumbnail": "https://r2.alhai.sa/products/thumb/p1.jpg",
        "inventory": [
          {
            "store_id": "store-uuid-1",
            "warehouse_id": "warehouse-uuid-1",
            "quantity": 120,
            "reserved_qty": 10
          }
        ],
        "created_at": "2026-01-01T00:00:00Z"
      }
    ],
    "pagination": {...}
  }
}
```

---

### POST /products
**Create Product**

Request:
```json
{
  "name": "خبز طازج",
  "name_en": "Fresh Bread",
  "barcode": "6281000005678",
  "category_id": "cat-uuid-2",
  "sell_price": 2.00,
  "purchase_price": 1.20,
  "min_stock": 50,
  "image": "base64_image_data"
}
```

Response:
```json
{
  "success": true,
  "data": {
    "id": "product-uuid-2",
    "name": "خبز طازج",
    "image_urls": {
      "thumbnail": "https://r2.alhai.sa/products/thumb/p2.jpg",
      "medium": "https://r2.alhai.sa/products/medium/p2.jpg",
      "large": "https://r2.alhai.sa/products/large/p2.jpg"
    }
  }
}
```

---

### POST /warehouses/transfer
**Transfer Inventory Between Warehouses**

Request:
```json
{
  "from_warehouse_id": "warehouse-uuid-1",
  "to_warehouse_id": "warehouse-uuid-2",
  "driver_id": "staff-uuid-3",
  "transfer_date": "2026-01-15",
  "expected_delivery": "2026-01-15T18:00:00Z",
  "items": [
    {
      "product_id": "product-uuid-1",
      "quantity": 50
    },
    {
      "product_id": "product-uuid-2",
      "quantity": 100
    }
  ],
  "notes": "نقل عاجل"
}
```

Response:
```json
{
  "success": true,
  "data": {
    "transfer_id": "transfer-uuid-1",
    "status": "PENDING",
    "total_value": 5000,
    "items_count": 2
  }
}
```

---

### GET /warehouses/transfers
**Get Transfer History**

Response:
```json
{
  "success": true,
  "data": {
    "transfers": [
      {
        "id": "transfer-uuid-1",
        "from_store": "بقالة الحي",
        "to_store": "بقالة السوق",
        "status": "IN_TRANSIT",
        "driver": "خالد المندوب",
        "items_count": 2,
        "total_value": 5000,
        "created_at": "2026-01-15T10:00:00Z",
        "expected_delivery": "2026-01-15T18:00:00Z"
      }
    ]
  }
}
```

---

## 👥 Customers

### GET /customers
**Get All Customers**

Query Params:
- `store_id`: filter by store
- `search`: search by name/phone
- `segment`: VIP|AT_RISK|NEW|DORMANT

Response:
```json
{
  "success": true,
  "data": {
    "customers": [
      {
        "id": "customer-uuid-1",
        "name": "فهد السعيد",
        "phone": "+966509876543",
        "address": "حي النخيل",
        "lat": 24.7140,
        "lng": 46.6760,
        "accounts": [
          {
            "store_id": "store-uuid-1",
            "store_name": "بقالة الحي",
            "balance": -150,
            "credit_limit": 500,
            "total_orders": 15,
            "last_order": "2026-01-13T12:00:00Z"
          },
          {
            "store_id": "store-uuid-2",
            "store_name": "بقالة السوق",
            "balance": -50,
            "credit_limit": 300,
            "total_orders": 8,
            "last_order": "2026-01-12T15:00:00Z"
          }
        ],
        "total_lifetime_value": 5000,
        "segment": "VIP"
      }
    ]
  }
}
```

---

### GET /customers/:id
**Get Customer Details**

Response:
```json
{
  "success": true,
  "data": {
    "id": "customer-uuid-1",
    "name": "فهد السعيد",
    "phone": "+966509876543",
    "address": "حي النخيل، الرياض",
    "accounts": [
      {
        "store_id": "store-uuid-1",
        "balance": -150,
        "credit_limit": 500,
        "overdue_amount": 0,
        "last_payment": "2026-01-10T10:00:00Z"
      }
    ],
    "order_history": [
      {
        "id": "order-uuid-1",
        "store_name": "بقالة الحي",
        "total": 120,
        "status": "DELIVERED",
        "date": "2026-01-13T12:00:00Z"
      }
    ],
    "debt_history": [
      {
        "type": "INVOICE",
        "amount": 150,
        "date": "2026-01-13T12:00:00Z"
      },
      {
        "type": "PAYMENT",
        "amount": -50,
        "date": "2026-01-14T09:00:00Z"
      }
    ]
  }
}
```

---

## 📋 Orders & Deliveries

### GET /orders
**Get All Orders**

Query Params:
- `store_id`: filter by store
- `status`: PENDING|ACCEPTED|IN_DELIVERY|DELIVERED|CANCELLED
- `date_from`: 2026-01-01
- `date_to`: 2026-01-15

Response:
```json
{
  "success": true,
  "data": {
    "orders": [
      {
        "id": "order-uuid-1",
        "receipt_no": "INV-2026-001",
        "store": {
          "id": "store-uuid-1",
          "name": "بقالة الحي"
        },
        "customer": {
          "id": "customer-uuid-1",
          "name": "فهد السعيد",
          "phone": "+966509876543"
        },
        "status": "PENDING",
        "channel": "APP",
        "items_count": 5,
        "subtotal": 100,
        "delivery_fee": 5,
        "vat": 15,
        "total": 120,
        "payment_method": "CASH",
        "created_at": "2026-01-15T10:00:00Z"
      }
    ],
    "pagination": {...}
  }
}
```

---

### GET /orders/:id
**Get Order Details**

Response:
```json
{
  "success": true,
  "data": {
    "id": "order-uuid-1",
    "receipt_no": "INV-2026-001",
    "status": "IN_DELIVERY",
    "customer": {...},
    "delivery_address": "حي النخيل، الرياض",
    "items": [
      {
        "product": {
          "id": "product-uuid-1",
          "name": "حليب نادك",
          "image": "..."
        },
        "quantity": 2,
        "unit_price": 8.50,
        "total": 17.00
      }
    ],
    "driver": {
      "id": "staff-uuid-3",
      "name": "خالد المندوب",
      "phone": "+966505555555",
      "current_location": {
        "lat": 24.7145,
        "lng": 46.6765
      }
    },
    "timeline": [
      {
        "status": "PENDING",
        "timestamp": "2026-01-15T10:00:00Z"
      },
      {
        "status": "ACCEPTED",
        "timestamp": "2026-01-15T10:05:00Z"
      },
      {
        "status": "IN_DELIVERY",
        "timestamp": "2026-01-15T10:30:00Z"
      }
    ]
  }
}
```

---

### POST /orders/:id/assign-driver
**Assign Driver to Order**

Request:
```json
{
  "driver_id": "staff-uuid-3"
}
```

Response:
```json
{
  "success": true,
  "data": {
    "order_id": "order-uuid-1",
    "driver": {
      "id": "staff-uuid-3",
      "name": "خالد المندوب"
    },
    "status": "IN_DELIVERY",
    "notification_sent": true
  }
}
```

```

---

## 📦 Order Tracking & Delivery (Enhanced)

### GET /orders/:id/tracking

**Real-time order tracking with GPS**

Response:
```json
{
  "success": true,
  "data": {
    "order_id": "order-uuid-123",
    "order_number": "#12345",
    "status": "OUT_FOR_DELIVERY",
    "customer": {
      "name": "فهد السعيد",
      "phone": "+966501234567",
      "address": {
        "street": "شارع الملك فهد",
        "district": "حي النخيل",
        "city": "الرياض",
        "lat": 24.7500,
        "lng": 46.6800
      }
    },
    "driver": {
      "id": "staff-uuid-3",
      "name": "خالد المندوب",
      "phone": "+966501111111",
      "current_location": {
        "lat": 24.7136,
        "lng": 46.6753,
        "updated_at": "2026-01-15T12:35:00Z"
      },
      "heading": 180,
      "speed_kmh": 45
    },
    "timeline": [
      {
        "status": "CREATED",
        "timestamp": "2026-01-15T10:00:00Z",
        "note": "Order placed"
      },
      {
        "status": "CONFIRMED",
        "timestamp": "2026-01-15T10:02:00Z",
        "note": "Accepted by store"
      },
      {
        "status": "ASSIGNED",
        "timestamp": "2026-01-15T10:05:00Z",
        "note": "Driver assigned: خالد"
      },
      {
        "status": "PICKED_UP",
        "timestamp": "2026-01-15T10:15:00Z",
        "note": "Driver picked up order"
      },
      {
        "status": "OUT_FOR_DELIVERY",
        "timestamp": "2026-01-15T10:20:00Z",
        "note": "On the way to customer"
      }
    ],
    "eta": {
      "minutes": 12,
      "arrival_time": "2026-01-15T10:47:00Z"
    },
    "distance": {
      "remaining_km": 3.5,
      "total_km": 8.2
    },
    "items_count": 5,
    "total_amount": 500
  }
}
```

---

### POST /orders/:id/update-status

**Update order status with notes**

Request:
```json
{
  "status": "CONFIRMED",
  "notes": "تم التأكيد - سيتم التحضير الآن"
}
```

Response:
```json
{
  "success": true,
  "data": {
    "order_id": "order-uuid-123",
    "old_status": "CREATED",
    "new_status": "CONFIRMED",
    "updated_at": "2026-01-15T10:02:00Z"
  }
}
```

---

### GET /orders/timeline

**Orders timeline for today/date range**

Query Params:
- `date`: YYYY-MM-DD (default: today)
- `store_id`: optional

Response:
```json
{
  "success": true,
  "data": {
    "date": "2026-01-15",
    "total_orders": 45,
    "by_status": {
      "CREATED": 3,
      "CONFIRMED": 5,
      "PREPARING": 4,
      "OUT_FOR_DELIVERY": 8,
      "DELIVERED": 25
    },
    "by_channel": {
      "POS": 25,
      "DELIVERY": 20
    },
    "timeline_today": [
      {
        "hour": "10:00",
        "orders_count": 3,
        "revenue": 800
      },
      {
        "hour": "11:00",
        "orders_count": 5,
        "revenue": 1200
      },
      {
        "hour": "12:00",
        "orders_count": 8,
        "revenue": 2100
      }
    ]
  }
}
```

---

## 📊 Revenue Analytics (POS vs Delivery)

### GET /analytics/revenue/channels

**Revenue breakdown by channel (POS vs Delivery)**

Query Params:
- `date_from`: YYYY-MM-DD
- `date_to`: YYYY-MM-DD
- `store_id`: optional (all stores by default)

Response:
```json
{
  "success": true,
  "data": {
    "period": {
      "from": "2026-01-08",
      "to": "2026-01-15"
    },
    "total_revenue": 70000,
    "pos_revenue": 42000,
    "pos_percent": 60,
    "delivery_revenue": 28000,
    "delivery_percent": 40,
    "by_payment_method": {
      "CASH": {
        "amount": 35000,
        "percent": 50
      },
      "CARD": {
        "amount": 21000,
        "percent": 30
      },
      "CREDIT": {
        "amount": 14000,
        "percent": 20
      }
    },
    "delivery_stats": {
      "orders_count": 105,
      "avg_order_value": 266.67,
      "delivery_fees_total": 1050,
      "net_revenue": 26950,
      "avg_delivery_time_min": 28,
      "on_time_rate_percent": 85
    },
    "pos_stats": {
      "transactions_count": 230,
      "avg_transaction_value": 182.61,
      "peak_hour": "18:00-19:00",
      "busiest_day": "Thursday"
    },
    "trend_7days": {
      "dates": ["2026-01-09", "2026-01-10", "2026-01-11", "2026-01-12", "2026-01-13", "2026-01-14", "2026-01-15"],
      "pos": [6000, 6500, 7000, 6800, 7200, 6900, 7100],
      "delivery": [4000, 4200, 4500, 4800, 5000, 4700, 4900]
    },
    "growth": {
      "pos_growth_percent": 8.5,
      "delivery_growth_percent": 12.3,
      "overall_growth_percent": 10.2
    }
  }
}
```

---

### GET /analytics/revenue/comparison

**Compare stores by revenue channels**

Query Params:
- `store_ids`: comma-separated UUIDs
- `date_from`: YYYY-MM-DD
- `date_to`: YYYY-MM-DD

Response:
```json
{
  "success": true,
  "data": {
    "period": {
      "from": "2026-01-08",
      "to": "2026-01-15"
    },
    "stores": [
      {
        "store_id": "store-uuid-1",
        "store_name": "بقالة الحي",
        "total_revenue": 42000,
        "pos_revenue": 27720,
        "pos_percent": 66,
        "delivery_revenue": 14280,
        "delivery_percent": 34,
        "orders": {
          "total": 150,
          "pos": 95,
          "delivery": 55
        },
        "delivery_performance": {
          "avg_delivery_time_min": 25,
          "on_time_percent": 90,
          "driver_count": 3,
          "rating_avg": 4.8,
          "complaints_count": 1
        },
        "staff": {
          "total_on_duty": 8,
          "cashiers": 3,
          "drivers": 3,
          "managers": 2
        },
        "status": "EXCELLENT",
        "alerts_count": 0
      },
      {
        "store_id": "store-uuid-2",
        "store_name": "بقالة السوق",
        "total_revenue": 28000,
        "pos_revenue": 14000,
        "pos_percent": 50,
        "delivery_revenue": 14000,
        "delivery_percent": 50,
        "orders": {
          "total": 120,
          "pos": 55,
          "delivery": 65
        },
        "delivery_performance": {
          "avg_delivery_time_min": 35,
          "on_time_percent": 70,
          "driver_count": 2,
          "rating_avg": 4.2,
          "complaints_count": 5
        },
        "staff": {
          "total_on_duty": 5,
          "cashiers": 2,
          "drivers": 2,
          "managers": 1
        },
        "status": "NEEDS_IMPROVEMENT",
        "alerts_count": 3,
        "issues": [
          "Slow delivery time",
          "Low driver count",
          "High complaint rate"
        ]
      }
    ],
    "insights": {
      "best_performer": {
        "store_id": "store-uuid-1",
        "store_name": "بقالة الحي",
        "reason": "Excellent delivery performance + balanced revenue mix"
      },
      "recommendations": [
        {
          "store_id": "store-uuid-2",
          "issue": "Slow delivery (35 min avg vs 25 min)",
          "solution": "Hire +1 driver",
          "expected_improvement": "15% faster delivery, +10% revenue",
          "investment": "3000 ر.س/month",
          "roi": "Expected +2800 ر.س/month"
        },
        {
          "store_id": "store-uuid-2",
          "issue": "Low POS sales (50% vs 66%)",
          "solution": "Improve in-store experience",
          "expected_improvement": "+8% POS revenue"
        }
      ]
    }
  }
}
```

---

### GET /analytics/delivery/heatmap

**Delivery zones heatmap data**

Query Params:
- `store_id`: required
- `days`: 7 (default)

Response:
```json
{
  "success": true,
  "data": {
    "store_id": "store-uuid-1",
    "store_name": "بقالة الحي",
    "store_location": {
      "lat": 24.7136,
      "lng": 46.6753
    },
    "zones": [
      {
        "zone_name": "حي النخيل",
        "center_lat": 24.7500,
        "center_lng": 46.6800,
        "deliveries_count": 45,
        "avg_delivery_time_min": 22,
        "total_revenue": 12000,
        "heat_intensity": 0.9
      },
      {
        "zone_name": "حي الروضة",
        "center_lat": 24.7200,
        "center_lng": 46.7000,
        "deliveries_count": 30,
        "avg_delivery_time_min": 28,
        "total_revenue": 8000,
        "heat_intensity": 0.6
      },
      {
        "zone_name": "حي العليا",
        "center_lat": 24.7000,
        "center_lng": 46.6900,
        "deliveries_count": 15,
        "avg_delivery_time_min": 35,
        "total_revenue": 4000,
        "heat_intensity": 0.3
      }
    ],
    "summary": {
      "total_zones_covered": 12,
      "busiest_zone": "حي النخيل",
      "slowest_zone": "حي العليا",
      "recommended_expansion": "حي السليمانية (high demand, not covered)"
    }
  }
}
```

---

## 🏪 Store Comparison (Enhanced)

### GET /stores/compare

**Detailed store comparison with AI insights**

Query Params:
- `store_ids`: comma-separated UUIDs (required)
- `metric`: revenue|orders|delivery|staff|all (default: all)
- `date`: YYYY-MM-DD (default: today)

Response:
```json
{
  "success": true,
  "data": {
    "comparison_date": "2026-01-15",
    "stores": [
      {
        "store_id": "store-uuid-1",
        "store_name": "بقالة الحي",
        "revenue": {
          "today": 6000,
          "pos": 4000,
          "pos_percent": 66.7,
          "delivery": 2000,
          "delivery_percent": 33.3,
          "target": 5000,
          "achievement_percent": 120
        },
        "orders": {
          "total": 20,
          "pos": 12,
          "delivery": 8,
          "avg_order_value": 300,
          "completed": 18,
          "pending": 2,
          "cancelled": 0
        },
        "delivery_performance": {
          "active_deliveries": 2,
          "avg_time_min": 25,
          "on_time_rate": 90,
          "driver_count": 3,
          "drivers_available": 2,
          "rating": 4.8,
          "eta_accuracy": 95
        },
        "staff": {
          "total_count": 8,
          "on_duty": 8,
          "cashiers": 3,
          "drivers": 3,
          "managers": 2,
          "efficiency_score": 92
        },
        "inventory": {
          "low_stock_items": 3,
          "out_of_stock_items": 0,
          "stock_value": 150000
        },
        "customers": {
          "new_today": 3,
          "returning_today": 15,
          "loyalty_members": 120
        },
        "alerts": {
          "critical": 0,
          "important": 2,
          "info": 1
        },
        "overall_status": "EXCELLENT",
        "health_score": 95
      },
      {
        "store_id": "store-uuid-2",
        "store_name": "بقالة السوق",
        "revenue": {
          "today": 4000,
          "pos": 2000,
          "pos_percent": 50,
          "delivery": 2000,
          "delivery_percent": 50,
          "target": 5000,
          "achievement_percent": 80
        },
        "orders": {
          "total": 15,
          "pos": 7,
          "delivery": 8,
          "avg_order_value": 266,
          "completed": 12,
          "pending": 2,
          "cancelled": 1
        },
        "delivery_performance": {
          "active_deliveries": 3,
          "avg_time_min": 35,
          "on_time_rate": 70,
          "driver_count": 2,
          "drivers_available": 0,
          "rating": 4.2,
          "eta_accuracy": 75
        },
        "staff": {
          "total_count": 5,
          "on_duty": 5,
          "cashiers": 2,
          "drivers": 2,
          "managers": 1,
          "efficiency_score": 75
        },
        "inventory": {
          "low_stock_items": 8,
          "out_of_stock_items": 2,
          "stock_value": 95000
        },
        "customers": {
          "new_today": 2,
          "returning_today": 10,
          "loyalty_members": 85
        },
        "alerts": {
          "critical": 2,
          "important": 5,
          "info": 3
        },
        "overall_status": "NEEDS_IMPROVEMENT",
        "health_score": 72
      }
    ],
    "comparison_matrix": {
      "winner_by_metric": {
        "revenue": "store-uuid-1",
        "orders_count": "store-uuid-1",
        "delivery_speed": "store-uuid-1",
        "customer_rating": "store-uuid-1",
        "staff_efficiency": "store-uuid-1"
      },
      "gaps": [
        {
          "metric": "delivery_time",
          "store_1": 25,
          "store_2": 35,
          "gap": 10,
          "gap_percent": 40
        },
        {
          "metric": "revenue",
          "store_1": 6000,
          "store_2": 4000,
          "gap": 2000,
          "gap_percent": 33
        }
      ]
    },
    "ai_insights": {
      "best_practices_from_top_performer": [
        "بقالة الحي maintains 3 drivers for optimal coverage",
        "66% POS revenue indicates strong in-store experience",
        "25 min avg delivery time drives high customer satisfaction"
      ],
      "recommendations": [
        {
          "priority": "HIGH",
          "store_id": "store-uuid-2",
          "action": "Hire +1 driver immediately",
          "rationale": "All drivers busy, causing delays (35min avg)",
          "expected_result": "Reduce delivery time to ~28min, increase rating to 4.5★",
          "cost": "3000 ر.س/month",
          "roi": "Expected +15% delivery revenue (+2100 ر.س)"
        },
        {
          "priority": "MEDIUM",
          "store_id": "store-uuid-2",
          "action": "Stock 8 low-stock items",
          "rationale": "Missing sales opportunities",
          "expected_result": "+5% revenue"
        },
        {
          "priority": "LOW",
          "store_id": "store-uuid-1",
          "action": "Increase delivery focus",
          "rationale": "Only 33% delivery revenue (untapped potential)",
          "expected_result": "Could reach 40% delivery mix like Store 2"
        }
      ]
    }
  }
}
```

---

### GET /financial/dashboard
**Financial Dashboard (Consolidated)**

Query Params:
- `date_from`: 2026-01-01
- `date_to`: 2026-01-15
- `store_id`: optional (all stores by default)

Response:
```json
{
  "success": true,
  "data": {
    "total_revenue": 50000,
    "total_debts": 15000,
    "overdue_debts": 5000,
    "collections_this_month": 12000,
    "breakdown_by_store": [
      {
        "store_id": "store-uuid-1",
        "store_name": "بقالة الحي",
        "revenue": 30000,
        "debts": 10000,
        "profit": 8000
      },
      {
        "store_id": "store-uuid-2",
        "store_name": "بقالة السوق",
        "revenue": 20000,
        "debts": 5000,
        "profit": 5000
      }
    ],
    "by_payment_method": {
      "CASH": 25000,
      "CARD": 15000,
      "CREDIT": 10000
    },
    "by_channel": {
      "POS": 35000,
      "APP": 15000
    }
  }
}
```

---

### GET /reports/debts
**Debts Report (Detailed)**

Response:
```json
{
  "success": true,
  "data": {
    "total_debt": 15000,
    "by_age": {
      "current": 10000,
      "overdue_30": 3000,
      "overdue_60": 1500,
      "overdue_90": 500
    },
    "customers": [
      {
        "customer_id": "customer-uuid-1",
        "name": "فهد السعيد",
        "total_debt": 200,
        "overdue": 0,
        "accounts": [
          {
            "store_name": "بقالة الحي",
            "balance": -150,
            "overdue_days": 0
          },
          {
            "store_name": "بقالة السوق",
            "balance": -50,
            "overdue_days": 0
          }
        ]
      }
    ]
  }
}
```

---

### GET /reports/sales
**Sales Report**

Query Params:
- `period`: today|week|month|custom
- `store_id`: optional

Response:
```json
{
  "success": true,
  "data": {
    "total_revenue": 50000,
    "total_cost": 37000,
    "total_profit": 13000,
    "profit_margin_percent": 26,
    "total_orders": 500,
    "avg_order_value": 100,
    "by_category": [
      {
        "category": "ألبان ومشتقاتها",
        "revenue": 15000,
        "cost": 11000,
        "profit": 4000,
        "percentage": 30
      }
    ],
    "top_products": [
      {
        "product": "حليب نادك",
        "units_sold": 200,
        "revenue": 1700,
        "cost": 1200,
        "profit": 500
      }
    ],
    "trends": [
      {
        "date": "2026-01-10",
        "revenue": 3500,
        "profit": 900
      },
      {
        "date": "2026-01-11",
        "revenue": 4000,
        "profit": 1050
      }
    ]
  }
}
```

---

### GET /kpi
**KPI Dashboard**

Response:
```json
{
  "success": true,
  "data": {
    "revenue_growth": 15,
    "customer_retention": 85,
    "inventory_turnover": 6,
    "debt_collection_rate": 92,
    "avg_delivery_time": 28,
    "cashier_efficiency": {
      "transactions_per_hour": 12,
      "avg_transaction_value": 100
    },
    "ai_insights": [
      {
        "type": "INVENTORY",
        "message": "حليب نادك ينفد كل 3 أيام. اطلب 200 بدلاً من 100",
        "impact": "high",
        "action_url": "/products/product-uuid-1/reorder"
      },
      {
        "type": "SALES",
        "message": "الطلبات تزيد 30% يوم الخميس. جهّز مخزون إضافي",
        "impact": "medium"
      }
    ]
  }
}
```

---

## 💳 Subscriptions

### GET /subscription
**Get Current Subscription**

Response (Active):
```json
{
  "success": true,
  "data": {
    "plan": "basic",
    "status": "ACTIVE",
    "billing_cycle": "monthly",
    "price": 99,
    "currency": "SAR",
    "started_at": "2026-01-15T00:00:00Z",
    "expires_at": "2026-02-15T00:00:00Z",
    "days_remaining": 31,
    "limits": {
      "max_stores": 1,
      "max_staff": 3,
      "max_products": 1000,
      "features": {
        "ai_insights": false,
        "transfers": false,
        "advanced_reports": false
      }
    },
    "usage": {
      "stores_count": 1,
      "staff_count": 2,
      "products_count": 450
    }
  }
}
```

Response (Expired - Read-Only Mode):
```json
{
  "success": true,
  "data": {
    "plan": "basic",
    "status": "EXPIRED",
    "billing_cycle": "monthly",
    "expired_at": "2026-01-10T00:00:00Z",
    "grace_period_ends": "2026-01-13T00:00:00Z",
    "days_overdue": 5,
    "read_only_mode": true,
    "allowed_operations": [
      "GET /stores",
      "GET /products",
      "GET /orders",
      "GET /customers",
      "GET /reports/*",
      "GET /financial/*",
      "POST /subscription/reactivate"
    ],
    "blocked_operations": [
      "POST /stores",
      "PUT /stores/:id",
      "DELETE /stores/:id",
      "POST /products",
      "PUT /products/:id",
      "POST /staff",
      "POST /warehouses/transfer",
      "All write operations blocked"
    ],
    "message": "اشتراكك منتهٍ. أنت في وضع القراءة فقط. قم بالتجديد لاستعادة الوصول الكامل.",
    "upgrade_url": "/subscription/reactivate"
  }
}
```

Response (Cancelled):
```json
{
  "success": true,
  "data": {
    "plan": "basic",
    "status": "CANCELLED",
    "cancelled_at": "2026-01-05T00:00:00Z",
    "data_retention_until": "2026-02-04T00:00:00Z",
    "days_until_deletion": 30,
    "read_only_mode": true,
    "allowed_operations": [
      "GET /owners/me",
      "GET /subscription",
      "POST /subscription/reactivate",
      "POST /export-data"
    ],
    "message": "حسابك ملغى. بياناتك ستحذف بعد 30 يوم. يمكنك إعادة التفعيل أو تصدير بياناتك.",
    "reactivate_url": "/subscription/reactivate",
    "export_url": "/export-data"
  }
}
```

---

### POST /subscription/upgrade
**Upgrade Subscription**

Request:
```json
{
  "new_plan": "pro",
  "payment_method_id": "pm_stripe_123456"
}
```

Response:
```json
{
  "success": true,
  "data": {
    "subscription_id": "sub-uuid-1",
    "plan": "pro",
    "status": "ACTIVE",
    "prorated_amount": 150,
    "charged_amount": 150,
    "next_billing_date": "2026-02-15T00:00:00Z",
    "unlocked_features": [
      "ai_insights",
      "transfers",
      "max_stores_increased_to_3"
    ],
    "invoice_url": "https://api.alhai.sa/invoices/inv-123.pdf"
  }
}
```

---

### GET /subscription/invoices
**Get Billing History**

Response:
```json
{
  "success": true,
  "data": {
    "invoices": [
      {
        "id": "inv-uuid-1",
        "date": "2026-01-15T00:00:00Z",
        "amount": 99,
        "status": "PAID",
        "plan": "basic",
        "pdf_url": "https://api.alhai.sa/invoices/inv-uuid-1.pdf"
      }
    ]
  }
}
```

---

## 🤝 Referrals

### GET /referrals
**Get My Referrals (Marketer)**

Response:
```json
{
  "success": true,
  "data": {
    "referral_code": "MSAWQ123",
    "total_referrals": 25,
    "active_referrals": 20,
    "pending_referrals": 3,
    "churned_referrals": 2,
    "earnings": {
      "this_month": 1200,
      "last_month": 980,
      "lifetime": 15000
    },
    "tier": "TIER_2",
    "commission_rate": 0.12,
    "referrals": [
      {
        "owner_id": "owner-uuid-1",
        "owner_name": "محمد أحمد",
        "signup_date": "2026-01-01T00:00:00Z",
        "status": "ACTIVE",
        "subscription_plan": "basic",
        "monthly_revenue": 99,
        "your_commission": 11.88
      }
    ]
  }
}
```

---

### GET /referrals/stats
**Referral Statistics**

Response:
```json
{
  "success": true,
  "data": {
    "conversion_rate": 40,
    "avg_owner_ltv": 2400,
    "leaderboard_position": 3,
    "badges": ["STARTER", "PRO"],
    "next_milestone": {
      "target": "50_REFERRALS",
      "progress": 25,
      "reward": "Upgrade to TIER_3 (15% commission)"
    }
  }
}
```

---

## 🔔 Notifications (نظام الإشعارات الشامل)

### GET /notifications

**Get All Notifications**

Query Params:
- `type`: ORDER|RATING|TICKET|DEBT|SUGGESTION|SYSTEM (comma-separated)
- `priority`: CRITICAL|IMPORTANT|INFO
- `unread_only`: true|false
- `limit`: 20 (default)
- `offset`: 0

Response:
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
        "data": {
          "order_id": "order-uuid-123",
          "customer_name": "فهد السعيد",
          "total_amount": 500,
          "payment_method": "CREDIT"
        },
        "actions": [
          {"label": "قبول", "action": "ACCEPT_ORDER"},
          {"label": "رفض", "action": "REJECT_ORDER"}
        ],
        "read": false,
        "created_at": "2026-01-15T10:00:00Z"
      },
      {
        "id": "notif-uuid-2",
        "type": "STORE_RATING",
        "priority": "CRITICAL",
        "title": "⚠️ تقييم منخفض: ⭐⭐",
        "message": "بقالة السوق حصلت على تقييم 2/5",
        "data": {
          "store_id": "store-uuid-2",
          "store_name": "بقالة السوق",
          "customer_name": "محمد أحمد",
          "rating": 2,
          "review": "تأخير في التوصيل"
        },
        "actions": [
          {"label": "حل المشكلة", "action": "RESOLVE_ISSUE"},
          {"label": "رد على العميل", "action": "REPLY_CUSTOMER"}
        ],
        "read": false,
        "created_at": "2026-01-15T09:30:00Z"
      },
      {
        "id": "notif-uuid-3",
        "type": "DEBT_OVERDUE",
        "priority": "IMPORTANT",
        "title": "دين متأخر (30 يوم)",
        "message": "محمد أحمد - 300 ر.س متأخر",
        "data": {
          "customer_id": "customer-uuid-1",
          "customer_name": "محمد أحمد",
          "amount": 300,
          "days_overdue": 30
        },
        "actions": [
          {"label": "إرسال تذكير", "action": "SEND_REMINDER"},
          {"label": "اتصال", "action": "CALL_CUSTOMER"}
        ],
        "read": true,
        "read_at": "2026-01-15T11:00:00Z",
        "created_at": "2026-01-15T08:00:00Z"
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

### Notification Types (أنواع الإشعارات)

#### 1. Orders & Delivery (الطلبات والتوصيل):

**NEW_ORDER** - طلب جديد
```json
{
  "type": "NEW_ORDER",
  "priority": "IMPORTANT",
  "title": "طلب جديد #12345",
  "message": "500 ر.س من فهد السعيد",
  "data": {
    "order_id": "order-uuid-123",
    "customer_name": "فهد السعيد",
    "items_count": 5,
    "total_amount": 500,
    "payment_method": "CREDIT"
  },
  "actions": [
    {"label": "قبول", "action": "ACCEPT_ORDER"},
    {"label": "رفض", "action": "REJECT_ORDER"}
  ]
}
```

**ORDER_ACCEPTED** - تم قبول الطلب
```json
{
  "type": "ORDER_ACCEPTED",
  "priority": "INFO",
  "title": "تم قبول طلب #12345",
  "message": "Awaiting driver assignment",
  "actions": [
    {"label": "تعيين مندوب", "action": "ASSIGN_DRIVER"}
  ]
}
```

**DRIVER_ASSIGNED** - تم تعيين مندوب
```json
{
  "type": "DRIVER_ASSIGNED",
  "priority": "INFO",
  "title": "مندوب معيّن للطلب #12345",
  "message": "خالد المندوب - ETA 30 دقيقة",
  "data": {
    "driver_name": "خالد المندوب",
    "driver_phone": "+966501111111",
    "eta_minutes": 30
  }
}
```

**DRIVER_CHANGED** - تغيير المندوب
```json
{
  "type": "DRIVER_CHANGED",
  "priority": "IMPORTANT",
  "title": "تغيير مندوب للطلب #12345",
  "message": "من خالد → أحمد (خالد مشغول)",
  "data": {
    "old_driver": "خالد المندوب",
    "new_driver": "أحمد المندوب",
    "reason": "خالد مشغول",
    "new_eta": 25
  }
}
```

**DELIVERY_STATUS** - حالة التوصيل
```json
{
  "type": "DELIVERY_STATUS",
  "priority": "INFO",
  "title": "طلب #12345 تم التوصيل ✅",
  "message": "Customer: فهد السعيد",
  "data": {
    "status": "DELIVERED",
    "delivered_at": "2026-01-15T12:30:00Z",
    "driver": "خالد المندوب"
  }
}
```

---

#### 2. Ratings & Reviews (التقييمات):

**STORE_RATING** - تقييم البقالة
```json
{
  "type": "STORE_RATING",
  "priority": rating < 3 ? "CRITICAL" : "INFO",
  "title": "تقييم جديد: ⭐⭐⭐⭐⭐",
  "message": "فهد السعيد قيّم بقالة الحي",
  "data": {
    "store_id": "store-uuid-1",
    "store_name": "بقالة الحي",
    "customer_name": "فهد السعيد",
    "rating": 5,
    "review": "خدمة ممتازة ومنتجات طازجة"
  },
  "actions": [
    {"label": "شكر العميل", "action": "THANK_CUSTOMER"},
    {"label": "عرض", "action": "VIEW_REVIEW"}
  ]
}
```

**DRIVER_RATING** - تقييم المندوب
```json
{
  "type": "DRIVER_RATING",
  "priority": "INFO",
  "title": "تقييم مندوب: ⭐⭐⭐⭐⭐",
  "message": "خالد حصل على 5 نجوم",
  "data": {
    "driver_id": "driver-uuid-1",
    "driver_name": "خالد المندوب",
    "rating": 5,
    "comment": "سريع ومحترم",
    "order_id": "order-uuid-123"
  }
}
```

**LOW_RATING_ALERT** - تنبيه تقييم منخفض
```json
{
  "type": "LOW_RATING_ALERT",
  "priority": "CRITICAL",
  "title": "🔴 3 تقييمات منخفضة اليوم",
  "message": "بقالة السوق متوسط التقييم 2.3/5",
  "data": {
    "store_id": "store-uuid-2",
    "avg_rating": 2.3,
    "low_ratings_count": 3,
    "common_issues": ["تأخير في التوصيل", "منتجات ناقصة"]
  },
  "actions": [
    {"label": "مراجعة", "action": "REVIEW_ISSUES"},
    {"label": "خطة تحسين", "action": "CREATE_IMPROVEMENT_PLAN"}
  ]
}
```

---

#### 3. Support Tickets (تذاكر الدعم):

**NEW_TICKET** - تذكرة جديدة
```json
{
  "type": "NEW_TICKET",
  "priority": "IMPORTANT",
  "title": "تذكرة جديدة #789",
  "message": "محمد أحمد - شكوى: المنتج تالف",
  "data": {
    "ticket_id": "ticket-uuid-789",
    "customer_name": "محمد أحمد",
    "category": "COMPLAINT",
    "subject": "المنتج تالف",
    "description": "استلمت حليب تالف، تاريخ الصلاحية منتهي"
  },
  "actions": [
    {"label": "رد", "action": "REPLY_TICKET"},
    {"label": "استرجاع", "action": "PROCESS_REFUND"}
  ]
}
```

**TICKET_WAITING** - تذكرة تنتظر رد
```json
{
  "type": "TICKET_WAITING",
  "priority": "IMPORTANT",
  "title": "تذكرة #789 تنتظر رد (2 ساعات)",
  "message": "محمد أحمد ينتظر الرد",
  "data": {
    "ticket_id": "ticket-uuid-789",
    "waiting_time_hours": 2,
    "sla_breach_soon": true
  },
  "actions": [
    {"label": "رد الآن", "action": "REPLY_NOW"}
  ]
}
```

**TICKET_RESOLVED** - تذكرة محلولة
```json
{
  "type": "TICKET_RESOLVED",
  "priority": "INFO",
  "title": "تذكرة #789 محلولة ✅",
  "message": "Customer rated resolution: 5/5",
  "data": {
    "ticket_id": "ticket-uuid-789",
    "resolution_time_hours": 3,
    "customer_satisfaction": 5
  }
}
```

---

#### 4. Debts & Payments (الديون والدفعات):

**NEW_DEBT** - دين جديد
```json
{
  "type": "NEW_DEBT",
  "priority": "INFO",
  "title": "دين جديد: 500 ر.س",
  "message": "فهد السعيد - مستحق في 2026-01-20",
  "data": {
    "customer_id": "customer-uuid-1",
    "customer_name": "فهد السعيد",
    "amount": 500,
    "due_date": "2026-01-20"
  },
  "actions": [
    {"label": "تعيين تذكير", "action": "SET_REMINDER"}
  ]
}
```

**PAYMENT_RECEIVED** - دفعة مستلمة
```json
{
  "type": "PAYMENT_RECEIVED",
  "priority": "INFO",
  "title": "دفعة مستلمة: 200 ر.س",
  "message": "فهد السعيد - متبقي 300 ر.س",
  "data": {
    "customer_name": "فهد السعيد",
    "amount_paid": 200,
    "remaining_debt": 300
  }
}
```

**DEBT_OVERDUE** - دين متأخر
```json
{
  "type": "DEBT_OVERDUE",
  "priority": days > 60 ? "CRITICAL" : "IMPORTANT",
  "title": "دين متأخر (30 يوم)",
  "message": "محمد أحمد - 300 ر.س",
  "data": {
    "customer_name": "محمد أحمد",
    "amount": 300,
    "days_overdue": 30,
    "total_debt": 800
  },
  "actions": [
    {"label": "إرسال تذكير SMS", "action": "SEND_SMS_REMINDER"},
    {"label": "اتصال", "action": "CALL_CUSTOMER"},
    {"label": "WhatsApp", "action": "SEND_WHATSAPP"}
  ]
}
```

**DEBT_LIMIT_EXCEEDED** - تجاوز حد الدين
```json
{
  "type": "DEBT_LIMIT_EXCEEDED",
  "priority": "CRITICAL",
  "title": "🔴 تجاوز حد الدين",
  "message": "عبدالله - 2,500 ر.س (limit: 2,000)",
  "data": {
    "customer_name": "عبدالله",
    "current_debt": 2500,
    "credit_limit": 2000,
    "exceeded_by": 500
  },
  "actions": [
    {"label": "حظر مؤقت", "action": "BLOCK_CUSTOMER"},
    {"label": "زيادة الحد", "action": "INCREASE_LIMIT"}
  ]
}
```

---

#### 5. Suggestions & Feedback (اقتراحات وملاحظات):

**CUSTOMER_SUGGESTION** - اقتراح عميل
```json
{
  "type": "CUSTOMER_SUGGESTION",
  "priority": "INFO",
  "title": "اقتراح جديد من عميل",
  "message": "فهد السعيد: إضافة زيت زيتون",
  "data": {
    "customer_name": "فهد السعيد",
    "suggestion": "إضافة زيت زيتون للمنتجات",
    "category": "PRODUCT_REQUEST"
  },
  "actions": [
    {"label": "نظر", "action": "REVIEW_SUGGESTION"},
    {"label": "تنفيذ", "action": "IMPLEMENT"},
    {"label": "رفض", "action": "DECLINE"}
  ]
}
```

**POPULAR_SUGGESTION** - اقتراح شائع
```json
{
  "type": "POPULAR_SUGGESTION",
  "priority": "IMPORTANT",
  "title": "اقتراح شائع (5 عملاء)",
  "message": "توصيل مجاني فوق 100 ر.س",
  "data": {
    "suggestion": "توصيل مجاني فوق 100 ر.س",
    "customers_count": 5,
    "customer_names": ["فهد", "محمد", "أحمد", "خالد", "سالم"]
  },
  "actions": [
    {"label": "تنفيذ كحملة", "action": "CREATE_CAMPAIGN"}
  ]
}
```

**STAFF_NOTE** - ملاحظة موظف
```json
{
  "type": "STAFF_NOTE",
  "priority": "IMPORTANT",
  "title": "ملاحظة من علي الكاشير",
  "message": "السعر خطأ للمنتج #123",
  "data": {
    "staff_name": "علي الكاشير",
    "staff_role": "CASHIER",
    "note": "السعر 8.5 ر.س بس في POS يطلع 9 ر.س",
    "product_id": "product-uuid-123"
  },
  "actions": [
    {"label": "تصحيح السعر", "action": "FIX_PRICE"}
  ]
}
```

---

### POST /notifications/:id/action

**Execute action on notification**

Request:
```json
{
  "action": "ACCEPT_ORDER",
  "params": {
    "assigned_driver": "driver-uuid-1"
  }
}
```

Response:
```json
{
  "success": true,
  "message": "تم قبول الطلب وتعيين المندوب",
  "notification_updated": true
}
```

---

### PUT /notifications/:id/read

**Mark notification as read**

Response:
```json
{
  "success": true,
  "read_at": "2026-01-15T11:00:00Z"
}
```

---

### PUT /notifications/mark-all-read

**Mark all notifications as read**

Response:
```json
{
  "success": true,
  "count": 15
}
```

---

### DELETE /notifications/:id

**Delete notification**

Response:
```json
{
  "success": true
}
```

---

### GET /notifications/stats

**Get notification statistics**

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
    "recent_trends": {
      "orders_today": 12,
      "ratings_avg_today": 4.2,
      "tickets_pending": 2,
      "debts_overdue_count": 3
    }
  }
}
```

---

## ⚠️ Error Responses

### Standard Error Format:

```json
{
  "success": false,
  "error": {
    "code": "ERROR_CODE",
    "message": "رسالة الخطأ بالعربية",
    "details": {}
  }
}
```

### Common Error Codes:

| Code | Description |
|------|-------------|
| `UNAUTHORIZED` | Token غير صالح |
| `FORBIDDEN` | ليس لديك صلاحية |
| `NOT_FOUND` | المورد غير موجود |
| `VALIDATION_ERROR` | بيانات غير صحيحة |
| `SUBSCRIPTION_LIMIT_EXCEEDED` | تجاوزت حد الاشتراك |
| `SUBSCRIPTION_EXPIRED` | اشتراكك منتهٍ - وضع القراءة فقط |
| `INSUFFICIENT_INVENTORY` | مخزون غير كافٍ |
| `TRANSFER_NOT_ALLOWED` | النقل غير مسموح |
| `DUPLICATE_ENTRY` | موجود مسبقاً |
| `INTERNAL_SERVER_ERROR` | خطأ في السيرفر |

### SUBSCRIPTION_EXPIRED Error Example:

```json
{
  "success": false,
  "error": {
    "code": "SUBSCRIPTION_EXPIRED",
    "message": "اشتراكك منتهٍ. أنت في وضع القراءة فقط. العمليات الكتابية محظورة.",
    "details": {
      "expired_at": "2026-01-10T00:00:00Z",
      "days_overdue": 5,
      "grace_period_ends": "2026-01-13T00:00:00Z",
      "read_only_mode": true,
      "reactivate_url": "/subscription/reactivate",
      "allowed_operations": ["GET"],
      "blocked_operation_attempted": "POST /products"
    }
  }
}
```

This error is returned when:
- Owner tries POST/PUT/DELETE while subscription is EXPIRED
- Owner is in grace period (3 days after expiry)
- After grace period, only GET /subscription and POST /subscription/reactivate are allowed


---

## 🔄 Pagination

All list endpoints support pagination:

Query Params:
- `page`: رقم الصفحة (default: 1)
- `limit`: عدد العناصر (default: 20, max: 100)

Response Format:
```json
{
  "data": [...],
  "pagination": {
    "page": 1,
    "limit": 20,
    "total": 150,
    "total_pages": 8,
    "has_next": true,
    "has_prev": false
  }
}
```

---

## 📡 Real-time Updates

### Supabase Realtime Channels:

```javascript
// Subscribe to orders for a store
const channel = supabase
  .channel(`orders:store_id=eq.${storeId}`)
  .on('INSERT', payload => {
    // New order received
  })
  .on('UPDATE', payload => {
    // Order status updated
  })
  .subscribe();

// Subscribe to inventory for a warehouse
const inventoryChannel = supabase
  .channel(`inventory:warehouse_id=eq.${warehouseId}`)
  .on('UPDATE', payload => {
    // Stock level changed
  })
  .subscribe();
```

---

## 💾 Cache Policy

### Client-Side Caching Strategy:

#### 1. Heavy Dashboards (with TTL):

```
Dashboard العام (/financial/dashboard):
├── Cache: Memory + Local Storage
├── TTL: 2 minutes
├── Invalidation: On Realtime event (new order/payment)
└── Key: `dashboard:${ownerId}:${dateRange}`

KPI Dashboard (/kpi):
├── Cache: Memory
├── TTL: 5 minutes
├── Invalidation: Manual refresh button
└── Key: `kpi:${ownerId}:${timestamp}`

Store Comparison (/stores/compare):
├── Cache: Memory
├── TTL: 10 minutes
├── Invalidation: On store settings change
└── Key: `comparison:${store1Id}:${store2Id}`
```

#### 2. Static/Semi-Static Data (Long TTL):

```
Owner Profile (/owners/me):
├── Cache: Secure Storage
├── TTL: 24 hours
├── Invalidation: On profile update
└── Key: `owner:${ownerId}`

Stores List (/stores):
├── Cache: Local Storage
├── TTL: 1 hour
├── Invalidation: On store create/update/delete
└── Key: `stores:${ownerId}`

Subscription (/subscription):
├── Cache: Shared Preferences
├── TTL: 6 hours
├── Invalidation: On upgrade/downgrade
└── Key: `subscription:${ownerId}`
```

#### 3. Frequently Changing Data (Short TTL):

```
Orders List (/orders):
├── Cache: Memory only
├── TTL: 30 seconds
├── Invalidation: On Realtime INSERT/UPDATE
└── No persistent cache

Products List (/products):
├── Cache: Memory
├── TTL: 5 minutes
├── Invalidation: On product create/update/delete
└── Pagination cached per page

Customers List (/customers):
├── Cache: Memory
├── TTL: 2 minutes
├── Invalidation: On customer update
└── Pagination cached
```

#### 4. Never Cache:

```
❌ POST/PUT/DELETE requests
❌ Real-time tracking (/deliveries/track/:orderId)
❌ Payment endpoints
❌ Transfer operations
❌ AI Insights (always fresh)
```

### Invalidation Rules:

```
Event: New Order (Realtime)
├── Invalidate: dashboard cache
├── Invalidate: orders list cache
├── Invalidate: KPI cache
└── Refetch automatically

Event: Product Updated
├── Invalidate: products list
├── Invalidate: related inventory
└── User must manually refresh

Event: Subscription Upgraded
├── Invalidate: owner profile
├── Invalidate: subscription cache
├── Invalidate: stores list (new limits)
└── Force app reload

Event: Logout
├── Clear ALL caches
├── Clear Secure Storage
└── Reset to fresh state
```

### Implementation Example (Flutter):

```dart
// Cache manager
class CacheManager {
  final _memoryCache = <String, CachedData>{};
  
  Future<T?> get<T>(String key, Duration ttl) async {
    final cached = _memoryCache[key];
    if (cached != null && !cached.isExpired(ttl)) {
      return cached.data as T;
    }
    return null;
  }
  
  void set(String key, dynamic data) {
    _memoryCache[key] = CachedData(data, DateTime.now());
  }
  
  void invalidate(String keyPattern) {
    _memoryCache.removeWhere((key, value) => key.contains(keyPattern));
  }
}
```

---

**📅 Last Updated**: 2026-01-15  
**✅ Status**: Ready for Development  
**🎯 Next**: ADMIN_UX_WIREFRAMES.md
