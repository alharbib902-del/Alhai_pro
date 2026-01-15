# 🔌 Customer App - API Contract (Complete)

**الإصدار**: 1.0  
**التاريخ**: 2026-01-15  
**المرجع**: PRD_FINAL.md (80 Screens)

---

## 📋 Base Configuration

```
Base URL: https://api.alhai.sa/v1
Environment: Production
Protocol: HTTPS only
```

### Authentication Headers
```
Authorization: Bearer {access_token}
X-Customer-Id: {customerId}
X-Store-Id: {storeId} (when applicable)
Content-Type: application/json
Accept-Language: ar-SA, en-US
```

---

## 🔐 Authentication APIs

### POST `/auth/send-otp`
إرسال OTP للتسجيل أو الدخول

**Request**:
```json
{
  "phone": "966501234567",
  "type": "signup" | "login"
}
```

**Response** (200):
```json
{
  "success": true,
  "message": "OTP sent",
  "expiresIn": 300
}
```

### POST `/auth/verify-otp`
التحقق من OTP

**Request**:
```json
{
  "phone": "966501234567",
  "otp": "123456",
  "name": "محمد أحمد" // Required for signup only
}
```

**Response** (200):
```json
{
  "accessToken": "eyJhbGc...",
  "refreshToken": "eyJhbGc...",
  "customerId": "uuid",
  "isNewUser": true
}
```

### POST `/auth/refresh`
تحديث Access Token

**Request**:
```json
{
  "refreshToken": "eyJhbGc..."
}
```

### POST `/auth/logout`
تسجيل الخروج

---

## 🏪 Stores APIs

### GET `/stores/nearby`
البقالات القريبة

**Query Parameters**:
- `lat`: Latitude (required)
- `lng`: Longitude (required)
- `radius`: Radius in km (default: 5)

**Response** (200):
```json
{
  "stores": [
    {
      "id": "uuid",
      "name": "بقالة الحي",
      "distance": 0.5,
      "location": {"lat": 24.7136, "lng": 46.6753},
      "status": "open" | "busy" | "closed",
      "openingHours": "6:00 AM - 12:00 AM",
      "customerDebt": 150.00,
      "lastOrderDate": "2026-01-12T10:30:00Z"
    }
  ]
}
```

### GET `/stores/:storeId`
تفاصيل البقالة

**Response** (200):
```json
{
  "id": "uuid",
  "name": "بقالة الحي",
  "phone": "966501234567",
  "address": "الرياض، حي النهضة",
  "location": {"lat": 24.7136, "lng": 46.6753},
  "status": "open",
  "openingHours": "6:00 AM - 12:00 AM",
  "deliveryFee": 5.00,
  "minOrder": 20.00,
  "customerAccount": {
    "balance": -150.00,
    "creditLimit": 500.00,
    "availableCredit": 350.00,
    "lastOrderDate": "2026-01-12T10:30:00Z",
    "totalOrders": 25
  }
}
```

### GET `/stores/:storeId/products`
منتجات البقالة

**Query Parameters**:
- `category`: Category filter (optional)
- `search`: Search query (optional)
- `sort`: `price_asc` | `price_desc` | `popular` | `newest`
- `page`: Page number (default: 1)
- `limit`: Items per page (default: 20)

**Response** (200):
```json
{
  "products": [
    {
      "id": "uuid",
      "name": "حليب نادك كامل الدسم",
      "nameEn": "Nadec Full Cream Milk",
      "category": "dairy",
      "price": 18.00,
      "images": {
        "thumbnail": "https://cdn.alhai.sa/.../thumb.webp",
        "medium": "https://cdn.alhai.sa/.../medium.webp",
        "large": "https://cdn.alhai.sa/.../large.webp"
      },
      "inStock": true,
      "unit": "1L"
    }
  ],
  "pagination": {
    "page": 1,
    "limit": 20,
    "total": 150,
    "totalPages": 8
  }
}
```

### GET `/products/:productId`
تفاصيل المنتج

**Response** (200):
```json
{
  "id": "uuid",
  "name": "حليب نادك كامل الدسم",
  "description": "حليب طازج كامل الدسم",
  "price": 18.00,
  "images": {...},
  "inStock": true,
  "unit": "1L",
  "brand": "نادك",
  "category": "dairy",
  "relatedProducts": ["uuid1", "uuid2"]
}
```

---

## 🛒 Cart APIs

### GET `/cart`
عرض السلة

**Response** (200):
```json
{
  "items": [
    {
      "productId": "uuid",
      "name": "حليب نادك",
      "price": 18.00,
      "quantity": 2,
      "subtotal": 36.00,
      "images": {...}
    }
  ],
  "subtotal": 65.00,
  "deliveryFee": 5.00,
  "total": 70.00,
  "storeId": "uuid"
}
```

### POST `/cart/items`
إضافة للسلة

**Request**:
```json
{
  "productId": "uuid",
  "quantity": 2,
  "storeId": "uuid"
}
```

### PATCH `/cart/items/:productId`
تحديث الكمية

**Request**:
```json
{
  "quantity": 3
}
```

### DELETE `/cart/items/:productId`
حذف من السلة

---

## 📦 Orders APIs

### POST `/orders`
إنشاء طلب جديد

**Request**:
```json
{
  "storeId": "uuid",
  "items": [
    {"productId": "uuid", "quantity": 2}
  ],
  "paymentMethod": "credit" | "cash" | "online",
  "deliveryAddress": {
    "id": "uuid",  // or full address object
    "notes": "الدور الثاني"
  },
  "scheduledFor": "2026-01-15T18:00:00Z",  // optional
  "promoCode": "SAVE10"  // optional
}
```

**Response** (201):
```json
{
  "orderId": "uuid",
  "orderNumber": "12345",
  "total": 70.00,
  "status": "created",
  "paymentStatus": "pending",
  "estimatedDelivery": "2026-01-15T18:30:00Z"
}
```

### GET `/orders`
قائمة الطلبات

**Query Parameters**:
- `status`: Filter by status
- `storeId`: Filter by store
- `page`, `limit`

**Response** (200):
```json
{
  "orders": [
    {
      "id": "uuid",
      "orderNumber": "12345",
      "storeId": "uuid",
      "storeName": "بقالة الحي",
      "total": 70.00,
      "status": "delivered",
      "paymentMethod": "credit",
      "createdAt": "2026-01-15T16:00:00Z",
      "deliveredAt": "2026-01-15T18:30:00Z"
    }
  ],
  "pagination": {...}
}
```

### GET `/orders/:orderId`
تفاصيل الطلب

**Response** (200):
```json
{
  "id": "uuid",
  "orderNumber": "12345",
  "store": {...},
  "items": [
    {
      "productId": "uuid",
      "name": "حليب نادك",
      "quantity": 2,
      "price": 18.00,
      "subtotal": 36.00,
      "substitution": {
        "original": "حليب نادك 1L",
        "replacement": "حليب المراعي 1L",
        "priceDiff": 2.00
      }
    }
  ],
  "subtotal": 65.00,
  "deliveryFee": 5.00,
  "discount": 0.00,
  "total": 70.00,
  "status": "delivered",
  "paymentMethod": "credit",
  "paymentStatus": "captured",
  "deliveryAddress": {...},
  "scheduledFor": "2026-01-15T18:00:00Z",
  "deliveredAt": "2026-01-15T18:25:00Z",
  "driver": {
    "id": "uuid",
    "name": "أحمد",
    "phone": "966501234567",
    "location": {"lat": 24.7136, "lng": 46.6753}
  },
  "tracking": {
    "status": "delivered",
    "estimatedArrival": "2026-01-15T18:30:00Z",
    "history": [...]
  }
}
```

### PATCH `/orders/:orderId`
تعديل الطلب (قبل القبول فقط)

**Request**:
```json
{
  "items": [...],  // Updated items
  "scheduledFor": "2026-01-15T19:00:00Z"
}
```

### POST `/orders/:orderId/cancel`
إلغاء الطلب

**Request**:
```json
{
  "reason": "غيرت رأيي" | "طلبت بالخطأ" | "تأخير التوصيل"
}
```

### GET `/orders/:orderId/track`
تتبع الطلب Real-time

**Response** (200):
```json
{
  "status": "out_for_delivery",
  "driver": {
    "name": "أحمد",
    "phone": "966501234567",
    "location": {"lat": 24.7136, "lng": 46.6753},
    "isOnline": true
  },
  "estimatedArrival": "2026-01-15T18:30:00Z",
  "distance": 1.2  // km
}
```

### POST `/orders/:orderId/reorder`
إعادة الطلب

**Response** (200):
```json
{
  "cartUpdated": true,
  "itemsAdded": 3,
  "unavailableItems": []
}
```

---

## 💳 Payments APIs

### POST `/payments`
إنشاء دفعة

**Request**:
```json
{
  "orderId": "uuid",  // optional, for order payment
  "storeId": "uuid",  // optional, for debt payment
  "amount": 150.00,
  "method": "card" | "apple_pay" | "stc_pay" | "mada"
}
```

**Response** (201):
```json
{
  "paymentId": "uuid",
  "status": "initiated",
  "amount": 150.00,
  "checkoutUrl": "https://payment.alhai.sa/checkout/...",
  "expiresAt": "2026-01-15T17:15:00Z"
}
```

### GET `/payments/:paymentId/status`
حالة الدفع

**Response** (200):
```json
{
  "paymentId": "uuid",
  "status": "captured" | "pending_3ds" | "failed",
  "amount": 150.00,
  "method": "card",
  "processedAt": "2026-01-15T17:05:00Z",
  "failureReason": null
}
```

### POST `/payments/:paymentId/refund`
استرداد المبلغ

**Request**:
```json
{
  "amount": 70.00,  // optional, defaults to full refund
  "reason": "طلب ملغى"
}
```

**Response** (200):
```json
{
  "refundId": "uuid",
  "amount": 70.00,
  "status": "processing",
  "estimatedCompletion": "2026-01-18T00:00:00Z"
}
```

---

## 💰 Accounts & Debts APIs

### GET `/accounts`
جميع حساباتي

**Response** (200):
```json
{
  "accounts": [
    {
      "storeId": "uuid",
      "storeName": "بقالة الحي",
      "balance": -150.00,
      "creditLimit": 500.00,
      "availableCredit": 350.00,
      "totalOrders": 25,
      "lastOrderDate": "2026-01-15T10:00:00Z"
    }
  ],
  "totalDebt": 200.00
}
```

### GET `/accounts/:storeId`
تفاصيل حساب البقالة

**Response** (200):
```json
{
  "storeId": "uuid",
  "storeName": "بقالة الحي",
  "balance": -150.00,
  "creditLimit": 500.00,
  "availableCredit": 350.00,
  "transactions": [
    {
      "id": "uuid",
      "type": "order" | "payment",
      "amount": -70.00,
      "balance": -150.00,
      "description": "طلب #12345",
      "date": "2026-01-15T16:00:00Z"
    }
  ]
}
```

### GET `/transactions`
تاريخ المعاملات

**Query**: `?storeId=uuid&type=order|payment&fromDate=...&toDate=...`

---

## ⭐ Loyalty APIs

### GET `/loyalty/points`
نقاط الولاء

**Response** (200):
```json
{
  "balance": 1250,
  "tier": "silver",
  "nextTier": "gold",
  "pointsToNextTier": 750,
  "earnedThisMonth": 200,
  "expiringPoints": {
    "amount": 100,
    "expiryDate": "2026-02-01T00:00:00Z"
  }
}
```

### GET `/loyalty/challenges`
التحديات

**Response** (200):
```json
{
  "challenges": [
    {
      "id": "uuid",
      "title": "3 طلبات هذا الأسبوع",
      "description": "+200 نقطة مكافأة",
      "progress": 2,
      "target": 3,
      "reward": 200,
      "expiresAt": "2026-01-20T23:59:59Z"
    }
  ],
  "streak": {
    "current": 5,
    "longestStreak": 12,
    "nextReward": "+50 نقطة عند 7 أيام"
  }
}
```

### POST `/loyalty/redeem`
استبدال النقاط

**Request**:
```json
{
  "points": 100,
  "type": "discount" | "delivery_credit"
}
```

**Response** (200):
```json
{
  "success": true,
  "reward": "خصم 5 ريال",
  "code": "LOYALTY5",
  "expiresAt": "2026-01-22T23:59:59Z"
}
```

---

## 💬 Chat APIs

### GET `/chat/conversations`
قائمة المحادثات

**Response** (200):
```json
{
  "conversations": [
    {
      "orderId": "uuid",
      "orderNumber": "12345",
      "driver": {
        "id": "uuid",
        "name": "أحمد"
      },
      "lastMessage": {
        "text": "في الطريق",
        "timestamp": "2026-01-15T17:50:00Z",
        "isRead": false
      },
      "unreadCount": 2
    }
  ]
}
```

### GET `/chat/:orderId/messages`
رسائل المحادثة

**Response** (200):
```json
{
  "messages": [
    {
      "id": "uuid",
      "sender": "customer" | "driver",
      "text": "متى تصل؟",
      "textTranslated": "When will you arrive?",  // if translation enabled
      "timestamp": "2026-01-15T17:45:00Z"
    }
  ]
}
```

### POST `/chat/:orderId/messages`
إرسال رسالة

**Request**:
```json
{
  "text": "متى تصل؟",
  "language": "ar"
}
```

### POST `/chat/:orderId/translate`
تشغيل/إيقاف الترجمة

**Request**:
```json
{
  "enabled": true,
  "targetLanguage": "ur"  // urdu
}
```

---

## ⭐ Ratings APIs

### POST `/ratings/driver`
تقييم المندوب

**Request**:
```json
{
  "orderId": "uuid",
  "rating": 5,
  "tags": ["سريع", "مؤدب", "منتجات سليمة"],
  "comment": "خدمة ممتازة"
}
```

**Response** (200):
```json
{
  "success": true,
  "pointsEarned": 10
}
```

### POST `/stores/:storeId/rate`
تقييم البقالة

**Request**:
```json
{
  "rating": 5,
  "productQuality": 5,
  "service": 5,
  "speed": 4,
  "comment": "بقالة ممتازة"
}
```

---

## 🆘 Support APIs

### POST `/support/tickets`
إنشاء تذكرة دعم

**Request**:
```json
{
  "orderId": "uuid",  // optional
  "subject": "تأخير في التوصيل",
  "category": "delivery" | "payment" | "product" | "other",
  "description": "الطلب تأخر أكثر من ساعة",
  "attachments": ["url1", "url2"]
}
```

**Response** (201):
```json
{
  "ticketId": "uuid",
  "ticketNumber": "SUP-12345",
  "status": "open",
  "estimatedResponse": "خلال 24 ساعة"
}
```

### GET `/support/tickets/:ticketId`
تفاصيل التذكرة

**Response** (200):
```json
{
  "id": "uuid",
  "ticketNumber": "SUP-12345",
  "status": "open" | "in_progress" | "resolved" | "closed",
  "subject": "تأخير في التوصيل",
  "messages": [...]
}
```

### POST `/support/tickets/:ticketId/messages`
إضافة رد

**Request**:
```json
{
  "message": "هل تم حل المشكلة؟",
  "attachments": []
}
```

---

## 🔍 Search APIs

### GET `/search`
بحث شامل

**Query**: `?q=حليب&storeId=uuid&limit=20`

**Response** (200):
```json
{
  "results": [
    {
      "type": "product",
      "id": "uuid",
      "name": "حليب نادك",
      "price": 18.00,
      "images": {...}
    }
  ],
  "suggestions": ["حليب كامل الدسم", "حليب قليل الدسم"]
}
```

---

## ⚙️ Settings APIs

### GET `/settings/profile`
الملف الشخصي

### PATCH `/settings/profile`
تحديث الملف الشخصي

### GET `/settings/addresses`
العناوين

### POST `/settings/addresses`
إضافة عنوان

### GET `/settings/substitutions`
تفضيلات الاستبدال

**Response** (200):
```json
{
  "allowSubstitutions": "always" | "ask_me" | "never",
  "maxPriceDifference": 5.00,
  "preferredBrands": ["نادك", "المراعي"],
  "bannedProducts": ["productId1"]
}
```

### DELETE `/settings/account`
حذف الحساب

**Request**:
```json
{
  "confirmation": "DELETE_MY_ACCOUNT",
  "password": "123456"
}
```

---

## 📊 Reports APIs

### GET `/reports/purchases`
تقرير المشتريات

**Query**: `?from=2026-01-01&to=2026-01-31`

### GET `/reports/debts`
تقرير الديون

### GET `/reports/points`
تقرير النقاط

---

## 🚨 Error Responses

### Standard Error Format
```json
{
  "error": {
    "code": "CREDIT_LIMIT_EXCEEDED",
    "message": "تجاوزت الحد الأقصى للآجل",
    "details": {
      "currentDebt": 150.00,
      "creditLimit": 500.00,
      "orderAmount": 400.00
    }
  }
}
```

### Common Error Codes
- `INVALID_OTP`
- `STORE_CLOSED`
- `OUT_OF_DELIVERY_AREA`
- `MIN_ORDER_NOT_MET`
- `CREDIT_LIMIT_EXCEEDED`
- `CREDIT_UNAVAILABLE`
- `PRICE_CHANGED`
- `ITEM_OUT_OF_STOCK`
- `PAYMENT_FAILED`
- `ORDER_CANNOT_BE_EDITED`

---

**📌 النسخة**: 1.0  
**📅 آخر تحديث**: 2026-01-15  
**✅ الحالة**: Complete & Ready
