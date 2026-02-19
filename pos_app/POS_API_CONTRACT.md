# 🔌 POS App - API Contract v3.0.0
## عقد الـ API بين التطبيق والسيرفر (معتمد)

> **Version:** 3.0.0 | **Date:** 2026-02-02 | **Base URL:** `https://api.alhai.app/v1`

---

# 📋 جدول المحتويات

1. [Headers & Standards](#headers-standards)
2. [Authentication](#1-authentication)
3. [Products](#2-products)
4. [Inventory](#3-inventory)
5. [Sales](#4-sales)
6. [Orders](#5-orders)
7. [Accounts](#6-accounts)
8. [Transactions](#7-transactions)
9. [Payments](#8-payments)
10. [Purchases](#9-purchases)
11. [Reports](#10-reports)
12. [Sync](#11-sync)
13. [Drivers](#12-drivers) ★
14. [VAT Report](#13-vat-report) ★
15. [Promotions](#14-promotions) ★
16. [Loyalty](#15-loyalty) ★
17. [WhatsApp](#16-whatsapp) ★
18. [Smart Orders](#17-smart-orders) ★
19. [ZATCA](#18-zatca) ★
20. [General Settings](#19-general-settings) ★
21. [Store Settings](#20-store-settings) ★
22. [Payment Devices](#21-payment-devices) ★
23. [Hold Invoices](#22-hold-invoices) ★
24. [Returns](#23-returns) ★
25. [Cash Drawer](#24-cash-drawer) ★
26. [Expiry Tracking](#25-expiry-tracking) ★
27. [Split Payment](#26-split-payment) ⭐ NEW v3.0
28. [Debt Reminders](#27-debt-reminders) ⭐ NEW v3.0
29. [Multi-Branch](#28-multi-branch) ⭐ NEW v3.0
30. [Stock Transfers](#29-stock-transfers) ⭐ NEW v3.0
31. [AI Transfer Suggestions](#30-ai-transfer-suggestions) ⭐ NEW v3.0
32. [Loyalty Extended](#31-loyalty-extended) ⭐ NEW v3.0
33. [Error Codes](#error-codes)

---

# 🔑 Headers & Standards

## Required Headers
```
Authorization: Bearer <accessToken>
Content-Type: application/json
Accept-Language: ar
X-Store-Id: <storeId>
X-Device-Id: <deviceId>
X-Request-Id: <uuid>              ← لتتبع الأخطاء
X-App-Channel: POS|APP            ← مصدر الطلب
```

## Idempotency (للعمليات الكتابية)
```
X-Idempotency-Key: <uuid>
```

**يُستخدم في:**
- `POST /sales`
- `POST /accounts/:id/payment`
- `POST /purchases`
- `POST /orders/:id/deliver`
- `POST /sync/push`

**السلوك:**
- إذا نفس الـ Key مرسل مرتين خلال 24 ساعة → يرجع النتيجة السابقة بدون تنفيذ جديد

---

## Timestamps
- جميع الأوقات **UTC** بصيغة ISO 8601
- `clientCreatedAt` للأحداث المحلية
- `serverCreatedAt` يضاف من السيرفر
- الـ Timezone الافتراضي للتقارير: `Asia/Riyadh`

---

# 🔐 1. Authentication

## POST `/auth/login`
تسجيل دخول المستخدم

**Request:**
```json
{
  "phone": "+966500000000",
  "pin": "1234"
}
```

**Response 200:**
```json
{
  "user": {
    "id": "uuid",
    "name": "أحمد",
    "phone": "+966500000000",
    "role": "MANAGER",
    "permissions": ["VOID_SALE", "ADJUST_INVENTORY", "CLOSE_MONTH"]
  },
  "store": {
    "id": "uuid",
    "name": "بقالة السعادة",
    "currency": "SAR",
    "taxRate": 15.0,
    "timezone": "Asia/Riyadh"
  },
  "settings": {
    "printerType": "THERMAL",
    "printerTemplate": "COMPACT",
    "autoPrint": true,
    "interestEnabled": true,
    "defaultInterestRate": 5.0
  },
  "accessToken": "eyJ...",
  "refreshToken": "eyJ...",
  "expiresIn": 3600
}
```

---

## GET `/auth/me`
المستخدم الحالي وإعداداته

**Response 200:** نفس response `/auth/login` بدون tokens

---

## POST `/auth/refresh`
تجديد التوكن

**Request:**
```json
{
  "refreshToken": "eyJ..."
}
```

**Response 200:**
```json
{
  "accessToken": "eyJ...",
  "expiresIn": 3600
}
```

---

## POST `/auth/logout`
تسجيل خروج (إبطال refresh token)

**Request:**
```json
{
  "refreshToken": "eyJ..."
}
```

**Response 204:** No Content

---

## POST `/auth/validate-pin` ★ v2.1.0
التحقق من PIN المشرف (TOTP للـ Offline)

**Request:**
```json
{
  "userId": "uuid",
  "pin": "1234",
  "action": "REFUND|DISCOUNT|VOID|CASH_OUT"
}
```

**Response 200:**
```json
{
  "valid": true,
  "userId": "uuid",
  "role": "SUPERVISOR",
  "permissions": ["REFUND", "DISCOUNT_20"],
  "totpSecret": "BASE32_SECRET",
  "emergencyCode": "123456",
  "emergencyCodeExpiresAt": "2026-01-21T00:00:00Z"
}
```

**Errors:**
- `401 INVALID_PIN` - PIN غير صحيح
- `429 TOO_MANY_ATTEMPTS` - محاولات كثيرة

---

## POST `/auth/send-otp` ★ v2.1.0
إرسال رمز التحقق

**Request:**
```json
{
  "phone": "+966500000000"
}
```

**Response 200:**
```json
{
  "success": true,
  "expiresIn": 60,
  "message": "تم إرسال رمز التحقق"
}
```

---

# 👥 1.5 Customers ★ v2.1.0

## GET `/customers/search`
بحث سريع عن العملاء

**Query Params:**
| Param | Type | Required | Description |
|-------|------|----------|-------------|
| q | string | Yes | رقم الجوال أو الاسم (min 4 chars) |
| limit | int | No | Default: 10 |

**Response 200:**
```json
{
  "items": [
    {
      "id": "uuid",
      "name": "أحمد محمد",
      "phone": "+966500001234",
      "phoneMasked": "05XX XXX 1234",
      "totalPurchases": 15,
      "totalSpent": 1250.00,
      "loyaltyPoints": 125,
      "hasDebt": true,
      "lastVisit": "2026-01-15T10:00:00Z"
    }
  ],
  "total": 1
}
```

---

## POST `/customers`
إنشاء عميل جديد

**Request:**
```json
{
  "name": "أحمد محمد",
  "phone": "+966500001234",
  "email": "ahmed@example.com",
  "birthday": "1990-01-15",
  "consentGiven": true
}
```

---

# 📦 1.6 Stock Check ★ v2.1.0

## GET `/stock/check`
فحص المخزون الحقيقي

**Query Params:**
| Param | Type | Required | Description |
|-------|------|----------|-------------|
| productIds | string | Yes | قائمة IDs مفصولة بفاصلة |

**Response 200:**
```json
{
  "items": [
    {
      "productId": "uuid",
      "availableQty": 15,
      "reservedQty": 3,
      "totalQty": 18,
      "status": "IN_STOCK|LOW_STOCK|OUT_OF_STOCK",
      "threshold": 5
    }
  ],
  "serverTime": "2026-01-20T10:00:00Z"
}
```

---

# 📱 1.7 WhatsApp Receipts ★ v2.1.0

## POST `/receipts/whatsapp`
إرسال إيصال عبر WhatsApp

**Request:**
```json
{
  "orderId": "uuid",
  "phone": "+966500001234",
  "customerName": "أحمد"
}
```

**Response 200:**
```json
{
  "messageId": "wamid.xxx",
  "status": "QUEUED|SENT|DELIVERED|FAILED",
  "receiptUrl": "https://receipts.alhai.sa/abc123"
}
```

**Errors:**
- `400 INVALID_PHONE` - رقم غير صحيح
- `429 RATE_LIMITED` - تجاوز الحد اليومي

---

# 🔄 1.8 Sync Conflicts ★ v2.1.0

## GET `/sync/conflicts`
قائمة التعارضات المعلقة

**Response 200:**
```json
{
  "items": [
    {
      "id": "uuid",
      "type": "STOCK|PRICE|ORDER",
      "entityId": "uuid",
      "localValue": {...},
      "serverValue": {...},
      "detectedAt": "2026-01-20T10:00:00Z",
      "status": "PENDING|RESOLVED"
    }
  ],
  "total": 3
}
```

## POST `/sync/conflicts/:id/resolve`
حل التعارض

**Request:**
```json
{
  "resolution": "ACCEPT_LOCAL|ACCEPT_SERVER|CREATE_ADJUSTMENT",
  "notes": "ملاحظات اختيارية"
}
```

---

# 📦 2. Products

## GET `/products`
قائمة المنتجات

**Query Params:**
| Param | Type | Required | Description |
|-------|------|----------|-------------|
| page | int | No | Default: 1 |
| limit | int | No | Default: 50 |
| categoryId | uuid | No | فلترة بالفئة |
| search | string | No | بحث بالاسم/الباركود |
| lowStock | bool | No | المخزون المنخفض فقط |
| updatedSince | timestamp | No | للمزامنة |
| includeInactive | bool | No | يشمل المحذوفة |

**Response 200:**
```json
{
  "items": [
    {
      "id": "uuid",
      "name": "حليب طازج",
      "nameEn": "Fresh Milk",
      "barcode": "6281000000001",
      "categoryId": "uuid",
      "categoryName": "ألبان",
      "sellPrice": 8.50,
      "purchasePrice": 6.00,
      "minStock": 10,
      "imageUrl": "https://...",
      "inventory": {
        "quantity": 25,
        "reservedQty": 3,
        "availableQty": 22
      },
      "isActive": true,
      "createdAt": "2026-01-01T00:00:00Z",
      "updatedAt": "2026-01-10T00:00:00Z"
    }
  ],
  "total": 150,
  "page": 1,
  "limit": 50
}
```

---

## GET `/products/:id`
تفاصيل منتج

---

## GET `/products/barcode/:barcode`
البحث بالباركود

**Errors:** `404 Not Found`

---

## POST `/products`
إضافة منتج جديد (Manager only)

**Request:**
```json
{
  "name": "منتج جديد",
  "nameEn": "New Product",
  "barcode": "6281000000002",
  "categoryId": "uuid",
  "sellPrice": 15.00,
  "purchasePrice": 10.00,
  "minStock": 5,
  "imageUrl": "https://..."
}
```

**Response 201:**
```json
{
  "id": "uuid",
  ...
  "createdAt": "...",
  "updatedAt": "..."
}
```

---

## PUT `/products/:id`
تعديل منتج (Manager only)

---

## DELETE `/products/:id`
حذف منتج (Soft Delete → isActive=false)

---

## POST `/products/upload-image` ★ جديد - R2 Integration
رفع صورة منتج (Multi-part Upload → Cloudflare R2)

**Request**: `multipart/form-data`
| Field | Type | Required | Description |
|-------|------|----------|-------------|
| image | file | Yes | الصورة (JPEG/PNG/WebP) |
| product_id | uuid | Yes | معرّف المنتج |

**Response 200**:
```json
{
  "imageThumbnail": "https://cdn.alhai.sa/products/123_thumb_abc.webp",
  "imageMedium": "https://cdn.alhai.sa/products/123_medium_abc.webp",
  "imageLarge": "https://cdn.alhai.sa/products/123_large_abc.webp",
  "imageHash": "abc123"
}
```

**Process**:
1. الصورة تُرفع للـ Edge Function
2. يتم resize لـ 3 أحجام (300x300, 600x600, 1200x1200)
3. تحويل لـ WebP (جودة 75%, 80%, 85%)
4. رفع لـ Cloudflare R2 مع hash في الاسم
5. تحديث حقول الصورة في الـ database

**Errors**:
- `400 INVALID_IMAGE_FORMAT` - صيغة غير مدعومة
- `413 FILE_TOO_LARGE` - الحجم أكبر من 10MB

**Response 200:**
```json
{
  "id": "uuid",
  "isActive": false,
  "deletedAt": "2026-01-13T10:00:00Z"
}
```

---

# 📊 3. Inventory

## GET `/inventory`
قائمة المخزون

---

## POST `/inventory/adjust`
تعديل المخزون (Manager only)

**Request:**
```json
{
  "productId": "uuid",
  "newQuantity": 30,
  "reason": "جرد فعلي",
  "allowNegative": false
}
```

**Response 200:**
```json
{
  "productId": "uuid",
  "oldQuantity": 25,
  "newQuantity": 30,
  "movement": {
    "id": "uuid",
    "type": "ADJUSTMENT",
    "quantity": 5,
    "createdAt": "2026-01-13T10:00:00Z"
  }
}
```

**Errors:**
- `400 NEGATIVE_QUANTITY_NOT_ALLOWED` - الكمية سالبة وغير مسموح

---

## GET `/inventory/movements`
سجل حركات المخزون

---

# 💵 4. Sales

## POST `/sales`
إنشاء فاتورة بيع (POS)

**Headers:**
```
X-Idempotency-Key: <uuid>
```

**Request:**
```json
{
  "items": [
    {
      "productId": "uuid",
      "quantity": 2,
      "unitPrice": 8.50
    }
  ],
  "paymentMethod": "CASH",
  "customerId": "uuid",
  "discount": 0,
  "notes": "",
  "clientCreatedAt": "2026-01-13T10:00:00Z"
}
```

> ⚠️ **ملاحظة:** `unitCost` يُحسب من السيرفر (آخر purchasePrice) - لا يُرسل من العميل

**Response 201:**
```json
{
  "id": "uuid",
  "receiptNo": "POS-2026-00001",
  "channel": "POS",
  "items": [
    {
      "productId": "uuid",
      "productName": "حليب",
      "quantity": 2,
      "unitPrice": 8.50,
      "unitCost": 6.00,
      "total": 17.00
    }
  ],
  "subtotal": 17.00,
  "discount": 0,
  "tax": 2.55,
  "total": 19.55,
  "paymentMethod": "CASH",
  "customerId": null,
  "cashierId": "uuid",
  "status": "COMPLETED",
  "clientCreatedAt": "2026-01-13T10:00:00Z",
  "serverCreatedAt": "2026-01-13T10:00:05Z"
}
```

---

## GET `/sales`
قائمة المبيعات

---

## POST `/sales/:id/void`
إلغاء فاتورة (Manager only)

**Request:**
```json
{
  "reason": "خطأ في الفاتورة"
}
```

**Response 200:**
```json
{
  "id": "uuid",
  "status": "VOIDED",
  "voidedAt": "2026-01-13T10:30:00Z",
  "voidedBy": "uuid",
  "voidReason": "خطأ في الفاتورة",
  "reverseMovements": [
    {"id": "uuid", "productId": "uuid", "type": "VOID_RETURN", "quantity": 2}
  ],
  "reversedTransactionId": "uuid"
}
```

---

# 📱 5. Orders (من التطبيق)

## GET `/orders`
قائمة الطلبات

**Query Params:**
| Param | Type | Description |
|-------|------|-------------|
| status | string | PENDING, ACCEPTED, PREPARED, READY, DELIVERED, CANCELLED |

---

## GET `/orders/:id`
تفاصيل طلب

**Response 200:**
```json
{
  "id": "uuid",
  "orderNo": "APP-2026-00123",
  "customer": {...},
  "items": [
    {
      "productId": "uuid",
      "productName": "حليب",
      "quantity": 2,
      "unitPrice": 8.50,
      "total": 17.00,
      "availableQty": 22
    }
  ],
  "subtotal": 85.00,
  "discount": 0,
  "total": 85.00,
  "paymentMethod": "CASH",
  "paymentStatus": "PENDING",
  "status": "PENDING",
  "address": "الرياض، حي النزهة...",
  "notes": "",
  "createdAt": "2026-01-13T10:00:00Z",
  "acceptedAt": null,
  "preparedAt": null,
  "deliveredAt": null,
  "cancelledAt": null,
  "cancelReasonCode": null,
  "cancelReasonText": null
}
```

---

## PUT `/orders/:id/status`
تغيير حالة الطلب

**Request:**
```json
{
  "status": "ACCEPTED"
}
```

**Valid Transitions:**
| From | To |
|------|-----|
| PENDING | ACCEPTED, CANCELLED |
| ACCEPTED | PREPARED, CANCELLED |
| PREPARED | READY, CANCELLED |
| READY | DELIVERED, CANCELLED |

**Response 200 (Accept):**
```json
{
  "id": "uuid",
  "status": "ACCEPTED",
  "acceptedAt": "2026-01-13T10:05:00Z",
  "reservations": [
    {"productId": "uuid", "reservedQty": 2}
  ]
}
```

**Errors:**
- `400 INSUFFICIENT_STOCK` - كمية غير متوفرة
- `409 INVALID_STATUS_TRANSITION` - تحويل غير مسموح

---

## POST `/orders/:id/cancel`
إلغاء طلب

**Request:**
```json
{
  "reasonCode": "CUSTOMER_REQUEST",
  "reasonText": "العميل ألغى الطلب"
}
```

**Reason Codes:**
- `CUSTOMER_REQUEST` - طلب العميل
- `OUT_OF_STOCK` - نفاد المخزون
- `STORE_CLOSED` - المتجر مغلق
- `OTHER` - أخرى

**Response 200:**
```json
{
  "id": "uuid",
  "status": "CANCELLED",
  "cancelledAt": "...",
  "cancelReasonCode": "CUSTOMER_REQUEST",
  "cancelReasonText": "...",
  "unreservedMovements": [...]
}
```

---

## POST `/orders/:id/deliver` ★ جديد
تسليم الطلب (Atomic Operation)

**Headers:**
```
X-Idempotency-Key: <uuid>
```

**Request:**
```json
{
  "deliveryNotes": "تم التسليم للعميل مباشرة"
}
```

يُنفّذ في معاملة واحدة:
1. خصم المخزون من الحجز (DEDUCT_FROM_RESERVATION)
2. إنشاء Sale {channel=APP, sourceOrderId}
3. إنشاء Transaction إذا آجل
4. تغيير حالة الطلب إلى DELIVERED

**Response 200:**
```json
{
  "orderId": "uuid",
  "status": "DELIVERED",
  "deliveredAt": "2026-01-13T12:00:00Z",
  "sale": {
    "id": "uuid",
    "receiptNo": "APP-2026-00045",
    "total": 85.00
  },
  "inventoryMovements": [...],
  "accountTransaction": {
    "id": "uuid",
    "amount": 85.00
  }
}
```

---

# 👥 6. Accounts (Customers/Suppliers)

## GET `/accounts`
قائمة الحسابات

---

## POST `/accounts`
إنشاء حساب جديد

---

## GET `/accounts/:id`
تفاصيل الحساب

---

## PUT `/accounts/:id`
تعديل الحساب

---

# 💳 7. Transactions

## GET `/accounts/:id/transactions`
حركات الحساب

---

## POST `/accounts/:id/payment`
تسجيل دفعة

**Headers:**
```
X-Idempotency-Key: <uuid>
```

**Request:**
```json
{
  "amount": 100.00,
  "paymentMethod": "CASH",
  "notes": "دفعة جزئية",
  "clientCreatedAt": "..."
}
```

**Response 201:**
```json
{
  "id": "uuid",
  "type": "PAYMENT",
  "amount": -100.00,
  "balanceAfter": 50.00,
  "paymentMethod": "CASH",
  "createdBy": "POS",
  "serverCreatedAt": "..."
}
```

---

## POST `/interest/close-month`
إقفال الشهر وحساب الفوائد (Manager only)

**Request:**
```json
{
  "periodKey": "2026-01"
}
```

**Errors:**
- `409 PERIOD_ALREADY_CLOSED` - الشهر مُقفل مسبقاً

---

# 💳 8. Payments (Online) ★ جديد

## POST `/payments/init`
بدء عملية دفع أونلاين (من التطبيق)

**Request:**
```json
{
  "accountId": "uuid",
  "amount": 100.00,
  "returnUrl": "alhai://payment-complete"
}
```

**Response 200:**
```json
{
  "paymentId": "uuid",
  "transactionRef": "PAY-2026-00123",
  "paymentUrl": "https://payment-gateway.com/pay/...",
  "qrCode": "data:image/png;base64,...",
  "expiresAt": "2026-01-13T11:00:00Z",
  "status": "PENDING"
}
```

---

## GET `/payments/:id`
حالة الدفع

**Response 200:**
```json
{
  "paymentId": "uuid",
  "transactionRef": "PAY-2026-00123",
  "amount": 100.00,
  "status": "SUCCEEDED",
  "paidAt": "2026-01-13T10:05:00Z",
  "accountTransactionId": "uuid"
}
```

**Statuses:** `PENDING`, `SUCCEEDED`, `FAILED`, `EXPIRED`

---

## POST `/payments/webhook` (Internal)
Webhook من بوابة الدفع

**Request (from payment gateway):**
```json
{
  "transactionRef": "PAY-2026-00123",
  "status": "SUCCEEDED",
  "gatewayRef": "GW-XYZ",
  "paidAt": "2026-01-13T10:05:00Z",
  "signature": "hmac-sha256..."
}
```

**Actions on Success:**
- إنشاء Transaction PAYMENT(-) على الحساب
- `createdBy` = "APP"

---

# 🛒 9. Purchases

## POST `/purchases`
فاتورة مشتريات يدوية

**Headers:**
```
X-Idempotency-Key: <uuid>
```

---

## POST `/purchases/import-invoice`
استيراد فاتورة بالـ AI

**Request:** `multipart/form-data`
| Field | Type | Description |
|-------|------|-------------|
| image | file | صورة الفاتورة |
| supplierId | uuid | المورد (اختياري) |

**Response 200:**
```json
{
  "importId": "uuid",
  "imageUrl": "https://...",
  "rawText": "...",
  "supplierDetected": "شركة الغذاء",
  "dateDetected": "2026-01-10",
  "items": [
    {
      "lineNumber": 1,
      "rawName": "حليب المراعي 1 لتر",
      "quantity": 24,
      "unitCost": 5.50,
      "total": 132.00,
      "confidence": 0.92,
      "needsReview": false,
      "matchedProduct": {
        "id": "uuid",
        "name": "حليب المراعي",
        "matchScore": 0.85
      },
      "suggestions": [
        {"id": "uuid", "name": "حليب طازج", "matchScore": 0.70}
      ]
    }
  ],
  "totalDetected": 456.00,
  "expiresAt": "2026-01-13T11:00:00Z"
}
```

> ⚠️ `needsReview: true` إذا `confidence < 0.70`

---

## POST `/purchases/confirm-import`
تأكيد الاستيراد بعد المراجعة

**Headers:**
```
X-Idempotency-Key: <uuid>
```

**Request:**
```json
{
  "importId": "uuid",
  "supplierId": "uuid",
  "invoiceDate": "2026-01-10",
  "isPaid": false,
  "items": [
    {
      "lineNumber": 1,
      "productId": "uuid",
      "quantity": 24,
      "unitCost": 5.50,
      "isConfirmed": true
    },
    {
      "lineNumber": 2,
      "productId": null,
      "quantity": 10,
      "unitCost": 8.00,
      "isConfirmed": true,
      "createProduct": {
        "name": "منتج جديد",
        "barcode": "123456",
        "sellPrice": 12.00,
        "categoryId": "uuid"
      }
    }
  ]
}
```

**Response 201:**
```json
{
  "purchaseId": "uuid",
  "total": 456.00,
  "productsCreated": 1,
  "inventoryMovements": [...],
  "supplierTransaction": {...}
}
```

**Errors:**
- `404 IMPORT_SESSION_EXPIRED` - انتهت صلاحية جلسة الاستيراد
- `400 UNCONFIRMED_LOW_CONFIDENCE` - سطور منخفضة الثقة غير مؤكدة

---

# 📈 10. Reports

## GET `/reports/sales-summary`
ملخص المبيعات

**Query Params:**
| Param | Type | Description |
|-------|------|-------------|
| from | date | من تاريخ |
| to | date | إلى تاريخ |
| channel | string | POS / APP / ALL |
| groupBy | string | day / week / month |
| timezone | string | Default: Asia/Riyadh |

**Response 200:**
```json
{
  "summary": {
    "totalSales": 15420.00,
    "totalCost": 10500.00,
    "grossProfit": 4920.00,
    "netProfit": 4920.00,
    "profitMargin": 31.9,
    "ordersCount": 145,
    "averageOrderValue": 106.34
  },
  "byChannel": {
    "POS": {"sales": 10200.00, "count": 95, "profit": 3060.00},
    "APP": {"sales": 5220.00, "count": 50, "profit": 1860.00}
  },
  "byPayment": {
    "CASH": {"sales": 8500.00, "count": 80},
    "CARD": {"sales": 4920.00, "count": 45},
    "CREDIT": {"sales": 2000.00, "count": 20}
  },
  "trend": [
    {"date": "2026-01-01", "sales": 520.00, "count": 5, "profit": 156.00}
  ],
  "timezone": "Asia/Riyadh"
}
```

---

## GET `/reports/top-products`
المنتجات الأكثر مبيعاً

---

## GET `/reports/debts-summary`
ملخص الديون

---

# 🔄 11. Sync

## POST `/sync/push`
رفع التغييرات المحلية

**Headers:**
```
X-Idempotency-Key: <uuid>
```

**Request:**
```json
{
  "deviceId": "uuid",
  "deviceSeq": 145,
  "events": [
    {
      "localId": "local-uuid",
      "entityType": "SALE",
      "entityId": "uuid",
      "action": "CREATE",
      "payload": {...},
      "clientCreatedAt": "2026-01-13T10:00:00Z"
    }
  ]
}
```

**Response 200:**
```json
{
  "serverAckSeq": 145,
  "processed": [
    {"localId": "local-uuid", "serverId": "server-uuid", "status": "OK"}
  ],
  "conflicts": [
    {
      "localId": "local-uuid",
      "reason": "ALREADY_EXISTS",
      "resolution": "SERVER_WINS",
      "serverVersion": {...}
    }
  ],
  "serverTime": "2026-01-13T10:00:05Z"
}
```

---

## GET `/sync/pull`
جلب التغييرات من السيرفر

**Query Params:**
| Param | Type | Description |
|-------|------|-------------|
| cursor | string | مؤشر المزامنة (من الطلب السابق) |
| limit | int | Default: 100 |
| entities | string | PRODUCTS,ORDERS,ACCOUNTS (comma-separated) |

**Response 200:**
```json
{
  "changes": [
    {
      "entityType": "PRODUCT",
      "entityId": "uuid",
      "action": "UPDATE",
      "data": {...},
      "changedAt": "2026-01-13T09:00:00Z"
    },
    {
      "entityType": "ORDER",
      "entityId": "uuid",
      "action": "CREATE",
      "data": {...},
      "changedAt": "2026-01-13T09:30:00Z"
    }
  ],
  "nextCursor": "eyJ0cyI6IjIwMjYtMDEtMTNUMTA6MDA6MDBaIn0=",
  "hasMore": true,
  "serverTime": "2026-01-13T10:00:00Z"
}
```

---

# 🚗 12. Drivers ★ Phase 7

## GET `/drivers`
قائمة المناديب

**Query Params:**
| Param | Type | Description |
|-------|------|-------------|
| type | string | `INTERNAL`, `EXTERNAL`, or empty for all |
| isActive | bool | Default: true |

**Response 200:**
```json
{
  "drivers": [
    {
      "id": "uuid",
      "name": "أحمد محمد",
      "phone": "+966500000005",
      "type": "INTERNAL",
      "avgRating": 4.8,
      "totalDeliveries": 45,
      "isActive": true,
      "createdAt": "2026-01-01T00:00:00Z"
    }
  ]
}
```

## POST `/drivers`
إضافة مندوب جديد

**Request:**
```json
{
  "name": "أحمد محمد",
  "phone": "+966500000005",
  "type": "INTERNAL"
}
```

## PATCH `/drivers/:id`
تعديل بيانات المندوب

## DELETE `/drivers/:id`
Soft delete (isActive=false)

## POST `/drivers/:id/ratings`
تقييم المندوب بعد التسليم

**Request:**
```json
{
  "orderId": "uuid",
  "rating": 5,
  "comment": "توصيل سريع"
}
```

## GET `/drivers/:id/stats`
إحصائيات المندوب

**Response 200:**
```json
{
  "totalDeliveries": 45,
  "thisMonthDeliveries": 12,
  "avgRating": 4.8,
  "recentRatings": [
    {"orderId": "uuid", "rating": 5, "comment": "ممتاز", "createdAt": "..."}
  ]
}
```

---

# 📊 13. VAT Report ★ Phase 7

## GET `/reports/vat`
تقرير ضريبة القيمة المضافة

**Query Params:**
| Param | Type | Description |
|-------|------|-------------|
| period | string | `MONTHLY`, `QUARTERLY`, `YEARLY` |
| year | int | السنة (مثال: 2026) |
| quarter | int | الربع (1-4) - إذا period=QUARTERLY |
| month | int | الشهر (1-12) - إذا period=MONTHLY |

**Response 200:**
```json
{
  "period": {
    "type": "QUARTERLY",
    "year": 2026,
    "quarter": 1,
    "startDate": "2026-01-01",
    "endDate": "2026-03-31"
  },
  "sales": {
    "total": 45000.00,
    "taxCollected": 6750.00
  },
  "purchases": {
    "total": 15000.00,
    "taxPaid": 2250.00
  },
  "netTax": 4500.00,
  "taxRate": 15.0,
  "generatedAt": "2026-01-13T10:00:00Z"
}
```

---

# 🎁 14. Promotions ★ Phase 7

## GET `/promotions`
قائمة العروض

**Query Params:**
| Param | Type | Description |
|-------|------|-------------|
| status | string | `ACTIVE`, `EXPIRED`, `DRAFT` |
| isAiGenerated | bool | العروض المقترحة من AI |

**Response 200:**
```json
{
  "promotions": [
    {
      "id": "uuid",
      "type": "DISCOUNT",
      "name": "خصم عيد الفطر",
      "description": "خصم 15% على جميع المنتجات",
      "discountPercent": 15.0,
      "productIds": null,
      "minPurchaseAmount": 0,
      "startDate": "2026-04-01",
      "endDate": "2026-04-07",
      "geoFenceEnabled": true,
      "isActive": true,
      "isAiGenerated": false,
      "createdAt": "..."
    }
  ],
  "aiSuggestions": [
    {
      "id": "suggested-uuid",
      "type": "DISCOUNT",
      "name": "خصم على المنتجات الراكدة",
      "discountPercent": 20.0,
      "productIds": ["uuid1", "uuid2"],
      "reason": "SLOW_MOVING",
      "products": [{"name": "معجون أسنان", "daysSinceLastSale": 45}]
    }
  ]
}
```

## POST `/promotions`
إنشاء عرض جديد

**Request:**
```json
{
  "type": "DISCOUNT",
  "name": "خصم عيد الفطر",
  "discountPercent": 15.0,
  "startDate": "2026-04-01",
  "endDate": "2026-04-07",
  "geoFenceEnabled": true
}
```

## POST `/promotions/ai-suggestions/:id/activate`
تفعيل اقتراح AI كعرض

## DELETE `/promotions/ai-suggestions/:id`
رفض اقتراح AI

## POST `/promotions/:id/notify`
إرسال إشعارات العرض

**Request:**
```json
{
  "channel": "PUSH|WHATSAPP",
  "geoFenceRadius": 3.0
}
```

---

# ⭐ 15. Loyalty ★ Phase 7

## GET `/loyalty/settings`
إعدادات نقاط الولاء

**Response 200:**
```json
{
  "enabled": true,
  "pointsPerRiyal": 1,
  "pointsToRiyal": 100,
  "minRedemption": 100
}
```

## PATCH `/loyalty/settings`
تحديث إعدادات الولاء

## GET `/loyalty/stats`
إحصائيات نقاط الولاء

**Response 200:**
```json
{
  "totalPointsEarned": 45000,
  "totalPointsRedeemed": 12000,
  "activeCustomers": 85,
  "topCustomers": [
    {"accountId": "uuid", "name": "محمد أحمد", "points": 2500}
  ]
}
```

## GET `/accounts/:id/loyalty`
نقاط العميل

**Response 200:**
```json
{
  "accountId": "uuid",
  "currentPoints": 2500,
  "lifetimeEarned": 3000,
  "lifetimeRedeemed": 500,
  "equivalentValue": 25.00,
  "transactions": [
    {"type": "EARN", "points": 50, "referenceId": "sale-uuid", "createdAt": "..."}
  ]
}
```

## POST `/accounts/:id/loyalty/redeem`
استبدال النقاط

**Request:**
```json
{
  "points": 100,
  "saleId": "uuid"
}
```

---

# 📱 16. WhatsApp ★ Phase 7

## GET `/whatsapp/settings`
إعدادات WhatsApp

**Response 200:**
```json
{
  "enabled": true,
  "phoneNumber": "+966500000000",
  "apiKeyConfigured": true,
  "autoDebtReminder": {
    "enabled": true,
    "minAmount": 500.0,
    "minDays": 30
  },
  "templates": [
    {"id": "debt_reminder", "name": "تذكير دين", "template": "مرحباً {name}..."}
  ]
}
```

## PATCH `/whatsapp/settings`
تحديث إعدادات WhatsApp

## POST `/whatsapp/send`
إرسال رسالة WhatsApp

**Request:**
```json
{
  "phones": ["+966500000001", "+966500000002"],
  "templateId": "debt_reminder",
  "variables": {
    "name": "محمد",
    "amount": "500"
  }
}
```

## POST `/whatsapp/send-bulk`
إرسال رسائل جماعية

**Request:**
```json
{
  "filter": {
    "minBalance": 500,
    "minDaysSinceLastPayment": 30
  },
  "templateId": "debt_reminder"
}
```

---

# 🛒 17. Smart Orders ★ Phase 7

## POST `/smart-orders/suggest`
اقتراح توزيع الميزانية على المنتجات

**Request:**
```json
{
  "supplierId": "uuid",
  "budget": 5000.00,
  "criteria": {
    "prioritizeTurnover": true,
    "prioritizeLowStock": true,
    "prioritizeSeasonality": false
  }
}
```

**Response 200:**
```json
{
  "suggestions": [
    {
      "productId": "uuid",
      "productName": "حليب طازج",
      "currentStock": 5,
      "minStock": 20,
      "avgDailySales": 10,
      "suggestedQty": 100,
      "unitPrice": 5.00,
      "totalPrice": 500.00,
      "reason": "HIGH_TURNOVER"
    }
  ],
  "totalAmount": 4825.00,
  "remainingBudget": 175.00
}
```

## POST `/smart-orders`
إنشاء طلب ذكي

**Request:**
```json
{
  "supplierId": "uuid",
  "paymentMethod": "CASH",
  "items": [
    {"productId": "uuid", "quantity": 100, "unitPrice": 5.00}
  ],
  "sendVia": "WHATSAPP"
}
```

**Response 201:**
```json
{
  "id": "uuid",
  "status": "DRAFT",
  "supplierId": "uuid",
  "totalAmount": 4825.00,
  "paymentMethod": "CASH",
  "createdAt": "..."
}
```

## POST `/smart-orders/:id/send`
إرسال الطلب للمورد

**Request:**
```json
{
  "channel": "WHATSAPP",
  "supplierPhone": "+966500000010"
}
```

## PATCH `/smart-orders/:id/status`
تحديث حالة الطلب

**Request:**
```json
{
  "status": "CONFIRMED",
  "expectedDeliveryDate": "2026-01-15"
}
```

---

# 🧾 18. ZATCA ★ Phase 7

## GET `/zatca/settings`
إعدادات الفوترة الإلكترونية

**Response 200:**
```json
{
  "enabled": true,
  "taxNumber": "300012345600003",
  "commercialRegistration": "1010012345",
  "businessName": "بقالة السعادة",
  "businessNameEn": "Al Saada Grocery",
  "address": {
    "street": "شارع الملك فهد",
    "district": "النزهة",
    "city": "الرياض",
    "postalCode": "12345",
    "country": "SA"
  },
  "qrCodeEnabled": true,
  "saveXml": true
}
```

## PATCH `/zatca/settings`
تحديث إعدادات ZATCA

## POST `/sales/:id/zatca`
إنشاء فاتورة ZATCA

**Response 200:**
```json
{
  "invoiceUuid": "uuid",
  "invoiceHash": "base64-hash",
  "qrCode": "base64-qr-image",
  "xmlDocument": "base64-xml",
  "status": "VALID",
  "issuedAt": "2026-01-13T10:00:00Z"
}
```

## GET `/zatca/invoices`
سجل الفواتير الإلكترونية

**Query Params:**
| Param | Type | Description |
|-------|------|-------------|
| from | date | من تاريخ |
| to | date | إلى تاريخ |
| status | string | `VALID`, `PENDING`, `REJECTED` |

---

# ⚙️ 19. General Settings ★ Phase 7B

## GET `/settings/general`
إعدادات التطبيق العامة

**Response 200:**
```json
{
  "theme": "DARK",
  "language": "ar",
  "soundEnabled": true,
  "notificationsEnabled": true
}
```

## PATCH `/settings/general`
تحديث الإعدادات العامة

---

# 🏪 20. Store Settings ★ Phase 7B

## GET `/settings/store`
بيانات المتجر

**Response 200:**
```json
{
  "name": "بقالة السعادة",
  "nameEn": "Al Saada Grocery",
  "logoUrl": "https://...",
  "address": "الرياض، حي النزهة",
  "phone": "+966500000000",
  "email": "info@example.com",
  "workingHours": {
    "saturday": {"open": "08:00", "close": "23:00"},
    "friday": {"open": "15:00", "close": "23:00"}
  }
}
```

## PATCH `/settings/store`
تحديث بيانات المتجر

## POST `/settings/store/logo`
رفع لوغو المتجر (multipart/form-data)

---

# 💳 21. Payment Devices ★ Phase 7B

## GET `/payment-devices`
قائمة أجهزة الدفع المربوطة

**Response 200:**
```json
{
  "devices": [
    {
      "id": "uuid",
      "type": "MADA",
      "name": "جهاز mada الرئيسي",
      "terminalId": "12345678",
      "status": "CONNECTED",
      "isActive": true
    }
  ]
}
```

## POST `/payment-devices`
إضافة جهاز دفع جديد

**Request:**
```json
{
  "type": "MADA|STC_PAY|APPLE_PAY|TABBY",
  "name": "جهاز mada الرئيسي",
  "terminalId": "12345678",
  "merchantId": "..."
}
```

## POST `/payment-devices/:id/test`
اختبار الاتصال بالجهاز

## PATCH `/payment-devices/:id`
تعديل/تفعيل/تعطيل الجهاز

---

# ⏸️ 22. Hold Invoices ★ Phase 7B

## GET `/pos/hold`
قائمة الفواتير المعلقة

**Response 200:**
```json
{
  "holdInvoices": [
    {
      "id": "uuid",
      "label": "عميل يرجع",
      "itemsCount": 5,
      "total": 125.50,
      "createdBy": "أحمد",
      "createdAt": "2026-01-13T10:00:00Z"
    }
  ]
}
```

## POST `/pos/hold`
تعليق فاتورة

**Request:**
```json
{
  "label": "عميل يرجع",
  "items": [
    {"productId": "uuid", "quantity": 2, "unitPrice": 15.00}
  ],
  "customerId": null
}
```

## GET `/pos/hold/:id`
استرجاع فاتورة معلقة

## DELETE `/pos/hold/:id`
حذف فاتورة معلقة

---

# ↩️ 23. Returns ★ Phase 7B

## POST `/returns`
إنشاء مرتجع

**Request:**
```json
{
  "originalSaleId": "uuid",
  "items": [
    {"productId": "uuid", "quantity": 1, "reason": "DEFECTIVE"}
  ],
  "refundMethod": "CASH|CARD|CREDIT",
  "refundAmount": 50.00
}
```

**Response 201:**
```json
{
  "id": "uuid",
  "returnNumber": "RET-0001",
  "originalSaleId": "uuid",
  "items": [...],
  "refundAmount": 50.00,
  "refundMethod": "CASH",
  "createdBy": "uuid",
  "createdAt": "..."
}
```

## GET `/returns`
قائمة المرتجعات

## GET `/returns/:id`
تفاصيل المرتجع

---

# 💰 24. Cash Drawer ★ Phase 7B

## POST `/cash-drawer/open`
فتح وردية جديدة

**Request:**
```json
{
  "openingAmount": 500.00
}
```

## GET `/cash-drawer/current`
الوردية الحالية

**Response 200:**
```json
{
  "id": "uuid",
  "cashierId": "uuid",
  "cashierName": "أحمد",
  "openingAmount": 500.00,
  "currentAmount": 1250.00,
  "salesCount": 15,
  "salesTotal": 750.00,
  "returnsTotal": 0,
  "openedAt": "2026-01-13T08:00:00Z",
  "status": "OPEN"
}
```

## POST `/cash-drawer/close`
إغلاق الوردية

**Request:**
```json
{
  "actualAmount": 1240.00,
  "notes": "فرق 10 ريال"
}
```

**Response 200:**
```json
{
  "id": "uuid",
  "expectedAmount": 1250.00,
  "actualAmount": 1240.00,
  "difference": -10.00,
  "status": "CLOSED",
  "closedAt": "..."
}
```

## GET `/cash-drawer/history`
سجل الورديات

---

# 📅 25. Expiry Tracking ★ Phase 7B

## GET `/inventory/expiry`
قائمة المنتجات حسب الصلاحية

**Query Params:**
| Param | Type | Description |
|-------|------|-------------|
| daysToExpiry | int | المنتجات التي ستنتهي خلال X يوم |
| categoryId | string | فلتر بالفئة |
| status | string | `EXPIRED`, `EXPIRING_SOON`, `VALID` |

**Response 200:**
```json
{
  "products": [
    {
      "productId": "uuid",
      "productName": "حليب طازج",
      "batchNumber": "B001",
      "expiryDate": "2026-01-20",
      "daysRemaining": 7,
      "quantity": 50,
      "status": "EXPIRING_SOON"
    }
  ],
  "summary": {
    "expired": 3,
    "expiringSoon": 12,
    "valid": 450
  }
}
```

## POST `/products/:id/expiry`
إضافة/تحديث تاريخ صلاحية

**Request:**
```json
{
  "batchNumber": "B001",
  "expiryDate": "2026-03-15",
  "quantity": 50
}
```

---

# 👥 26. User Management ★ Phase 8

## GET `/users`
قائمة المستخدمين

**Response 200:**
```json
{
  "users": [
    {
      "id": "uuid",
      "name": "أحمد محمد",
      "phone": "+966500000000",
      "role": "CASHIER",
      "isActive": true,
      "lastLogin": "2026-01-13T08:00:00Z"
    }
  ]
}
```

## POST `/users`
إضافة مستخدم جديد

**Request:**
```json
{
  "name": "محمد علي",
  "phone": "+966500000001",
  "pin": "1234",
  "role": "CASHIER",
  "permissions": ["VOID_SALE"]
}
```

## PATCH `/users/:id`
تعديل مستخدم

## DELETE `/users/:id`
تعطيل مستخدم (Soft delete)

## GET `/roles`
قائمة الأدوار والصلاحيات

---

# 💾 27. Backup ★ Phase 8

## POST `/backup/create`
إنشاء نسخة احتياطية

**Response 200:**
```json
{
  "backupId": "uuid",
  "filename": "backup_2026-01-13.zip",
  "size": 15000000,
  "createdAt": "2026-01-13T10:00:00Z"
}
```

## GET `/backup/list`
قائمة النسخ الاحتياطية

## POST `/backup/:id/restore`
استعادة نسخة احتياطية

## DELETE `/backup/:id`
حذف نسخة احتياطية

---

# 💸 28. Expenses ★ Phase 8

## GET `/expenses`
قائمة المصروفات

**Query Params:**
| Param | Type | Description |
|-------|------|-------------|
| from | date | من تاريخ |
| to | date | إلى تاريخ |
| category | string | فئة المصروف |

**Response 200:**
```json
{
  "expenses": [
    {
      "id": "uuid",
      "amount": 500.00,
      "category": "UTILITIES",
      "description": "فاتورة كهرباء",
      "date": "2026-01-13",
      "createdBy": "uuid"
    }
  ],
  "total": 1500.00
}
```

## POST `/expenses`
إضافة مصروف جديد

**Request:**
```json
{
  "amount": 500.00,
  "category": "UTILITIES|RENT|SALARIES|MAINTENANCE|OTHER",
  "description": "فاتورة كهرباء",
  "date": "2026-01-13"
}
```

---

# 📦 29. Inventory Count ★ Phase 8

## POST `/inventory/count/start`
بدء جلسة جرد جديدة

**Response 200:**
```json
{
  "sessionId": "uuid",
  "startedAt": "2026-01-13T10:00:00Z",
  "status": "IN_PROGRESS"
}
```

## POST `/inventory/count/:sessionId/item`
تسجيل كمية منتج

**Request:**
```json
{
  "productId": "uuid",
  "countedQuantity": 50
}
```

## GET `/inventory/count/:sessionId`
تفاصيل جلسة الجرد

**Response 200:**
```json
{
  "sessionId": "uuid",
  "items": [
    {
      "productId": "uuid",
      "productName": "حليب طازج",
      "systemQuantity": 45,
      "countedQuantity": 50,
      "difference": 5
    }
  ],
  "totalItems": 100,
  "countedItems": 45,
  "discrepancies": 3
}
```

## POST `/inventory/count/:sessionId/complete`
إنهاء الجرد وتطبيق التعديلات

---

# 👨‍💼 30. Cashier Report ★ Phase 8

## GET `/reports/cashier`
تقرير أداء الكاشير

**Query Params:**
| Param | Type | Description |
|-------|------|-------------|
| from | date | من تاريخ |
| to | date | إلى تاريخ |
| userId | string | مستخدم معين (اختياري) |

**Response 200:**
```json
{
  "cashiers": [
    {
      "userId": "uuid",
      "name": "أحمد محمد",
      "salesCount": 145,
      "salesTotal": 15000.00,
      "returnsCount": 3,
      "returnsTotal": 250.00,
      "avgTransactionValue": 103.45,
      "shiftsCount": 12,
      "shortages": -50.00
    }
  ],
  "period": {
    "from": "2026-01-01",
    "to": "2026-01-13"
  }
}
```

---

# 🧾 31. Receipt Design ★ Phase 9

## GET `/settings/receipt`
إعدادات تصميم الإيصال

**Response 200:**
```json
{
  "showLogo": true,
  "logoUrl": "https://...",
  "headerText": "بقالة السعادة",
  "footerText": "شكراً لزيارتكم",
  "showQrCode": true,
  "showTaxDetails": true,
  "paperWidth": 80
}
```

## PATCH `/settings/receipt`
تحديث تصميم الإيصال

---

# 📈 32. Price History ★ Phase 9

## GET `/products/:id/price-history`
سجل تغييرات الأسعار

**Response 200:**
```json
{
  "history": [
    {
      "id": "uuid",
      "oldPrice": 10.00,
      "newPrice": 12.00,
      "changedBy": "أحمد محمد",
      "changedAt": "2026-01-13T10:00:00Z",
      "reason": "تحديث سنوي"
    }
  ]
}
```

---

# 🔔 33. Notifications ★ Phase 9

## GET `/notifications`
قائمة التنبيهات

**Query Params:**
| Param | Type | Description |
|-------|------|-------------|
| type | string | `LOW_STOCK`, `EXPIRY`, `ORDER`, `SYSTEM` |
| read | boolean | مقروءة/غير مقروءة |

**Response 200:**
```json
{
  "notifications": [
    {
      "id": "uuid",
      "type": "LOW_STOCK",
      "title": "مخزون منخفض",
      "message": "حليب طازج - 5 وحدات متبقية",
      "isRead": false,
      "createdAt": "2026-01-13T10:00:00Z"
    }
  ],
  "unreadCount": 12
}
```

## PATCH `/notifications/:id/read`
تحديد كمقروء

## POST `/notifications/read-all`
تحديد الكل كمقروء

---

# 🔄 34. Switch User ★ Phase 9

## POST `/pos/switch-user`
تبديل الكاشير

**Request:**
```json
{
  "pin": "1234"
}
```

**Response 200:**
```json
{
  "userId": "uuid",
  "name": "سارة علي",
  "role": "CASHIER",
  "token": "jwt-token"
}
```

---

# 🏆 35. Top Products Report ★ Phase 9

## GET `/reports/top-products`
تقرير الأصناف الأكثر مبيعاً

**Query Params:**
| Param | Type | Description |
|-------|------|-------------|
| from | date | من تاريخ |
| to | date | إلى تاريخ |
| limit | int | 10, 50, 100 |
| sortBy | string | `quantity`, `revenue` |

**Response 200:**
```json
{
  "products": [
    {
      "rank": 1,
      "productId": "uuid",
      "productName": "حليب طازج",
      "quantitySold": 500,
      "revenue": 7500.00
    }
  ]
}
```

---

# ⏰ 36. Peak Hours Report ★ Phase 9

## GET `/reports/peak-hours`
تقرير ساعات الذروة

**Response 200:**
```json
{
  "heatmap": [
    {"day": "السبت", "hour": 10, "salesCount": 45},
    {"day": "السبت", "hour": 11, "salesCount": 62},
    {"day": "السبت", "hour": 20, "salesCount": 78}
  ],
  "peakHours": ["20:00", "21:00", "10:00"]
}
```

---

# 💹 37. Profit Margin Report ★ Phase 9

## GET `/reports/profit-margin`
تقرير هامش الربح

**Response 200:**
```json
{
  "products": [
    {
      "productId": "uuid",
      "productName": "حليب طازج",
      "costPrice": 10.00,
      "salePrice": 15.00,
      "margin": 5.00,
      "marginPercent": 33.33,
      "quantitySold": 100,
      "totalProfit": 500.00
    }
  ],
  "summary": {
    "totalCost": 10000.00,
    "totalRevenue": 15000.00,
    "totalProfit": 5000.00,
    "avgMarginPercent": 33.33
  }
}
```

---

# 📊 38. Period Comparison ★ Phase 9

## GET `/reports/comparison`
مقارنة الفترات

**Query Params:**
| Param | Type | Description |
|-------|------|-------------|
| period1From | date | بداية الفترة الأولى |
| period1To | date | نهاية الفترة الأولى |
| period2From | date | بداية الفترة الثانية |
| period2To | date | نهاية الفترة الثانية |

**Response 200:**
```json
{
  "period1": {
    "sales": 50000.00,
    "transactions": 500,
    "avgTicket": 100.00
  },
  "period2": {
    "sales": 45000.00,
    "transactions": 450,
    "avgTicket": 100.00
  },
  "change": {
    "salesPercent": 11.11,
    "transactionsPercent": 11.11
  }
}
```

---

# 📋 39. Audit Log ★ Phase 9

## GET `/settings/audit-log`
سجل النشاطات

**Query Params:**
| Param | Type | Description |
|-------|------|-------------|
| action | string | `VOID_SALE`, `PRICE_CHANGE`, `DELETE`, `LOGIN` |
| userId | string | فلتر بالمستخدم |
| from | date | من تاريخ |
| to | date | إلى تاريخ |

**Response 200:**
```json
{
  "logs": [
    {
      "id": "uuid",
      "action": "PRICE_CHANGE",
      "userId": "uuid",
      "userName": "أحمد محمد",
      "details": {
        "productId": "uuid",
        "oldValue": 10.00,
        "newValue": 12.00
      },
      "ipAddress": "192.168.1.1",
      "timestamp": "2026-01-13T10:00:00Z"
    }
  ]
}
```

---

# 👔 40. Roles Management ★ Phase 9

## GET `/settings/roles`
قائمة الأدوار

**Response 200:**
```json
{
  "roles": [
    {
      "id": "MANAGER",
      "name": "مدير",
      "permissions": ["VOID_SALE", "ADJUST_INVENTORY", "VIEW_REPORTS", "CLOSE_MONTH"]
    },
    {
      "id": "CASHIER",
      "name": "كاشير",
      "permissions": ["VOID_SALE"]
    }
  ]
}
```

## PUT `/settings/roles/:id`
تعديل صلاحيات دور

---

# ⚖️ 41. Scale Settings ★ Phase 9

## GET `/settings/scale`
إعدادات الميزان الإلكتروني

## PATCH `/settings/scale`
تحديث إعدادات الميزان

**Request:**
```json
{
  "enabled": true,
  "port": "COM3",
  "baudRate": 9600,
  "protocol": "TOLEDO"
}
```

---

# 🗃️ 42. Cash Drawer Device ★ Phase 9

## GET `/settings/cash-drawer-device`
إعدادات درج النقود

## PATCH `/settings/cash-drawer-device`
تحديث إعدادات درج النقود

**Request:**
```json
{
  "enabled": true,
  "openOnCashPayment": true,
  "printerPort": "COM1"
}
```

---

# 🏷️ 43. Barcode Settings ★ Phase 9

## GET `/settings/barcode`
إعدادات الباركود

## PATCH `/settings/barcode`
تحديث إعدادات الباركود

## POST `/products/:id/print-barcode`
طباعة باركود منتج

**Request:**
```json
{
  "copies": 10,
  "includePrice": true
}
```

---

# ⌨️ 44. Keyboard Shortcuts ★ Phase 9

## GET `/settings/shortcuts`
اختصارات لوحة المفاتيح

**Response 200:**
```json
{
  "shortcuts": [
    {"key": "F1", "action": "OPEN_SEARCH", "label": "بحث"},
    {"key": "F2", "action": "NEW_SALE", "label": "بيع جديد"},
    {"key": "F3", "action": "HOLD_INVOICE", "label": "تعليق"},
    {"key": "F12", "action": "CHECKOUT", "label": "دفع"}
  ]
}
```

## PUT `/settings/shortcuts`
تخصيص الاختصارات

---

# ⭐ 45. Favorites ★ Phase 9

## GET `/pos/favorites`
المنتجات المفضلة

**Response 200:**
```json
{
  "favorites": [
    {"productId": "uuid", "productName": "حليب طازج", "price": 15.00, "order": 1}
  ]
}
```

## POST `/pos/favorites`
إضافة منتج للمفضلة

## DELETE `/pos/favorites/:productId`
إزالة من المفضلة

## PUT `/pos/favorites/reorder`
إعادة ترتيب المفضلة

---

# 📱 46. Digital Receipt ★ Phase 10

## GET `/settings/digital-receipt`
إعدادات الفاتورة الرقمية

**Response 200:**
```json
{
  "enabled": true,
  "sendViaWhatsApp": true,
  "includeAppDownloadLink": true,
  "storeCode": "STORE123",
  "appDownloadUrl": "https://alhai.app/s/STORE123",
  "messageTemplate": "🧾 فاتورتك من {storeName}\n\nالمجموع: {total} ر.س\n📄 {receiptUrl}\n\n📲 حمّل تطبيقنا:\n{appUrl}",
  "welcomePoints": 50,
  "firstOrderDiscount": 5
}
```

## PATCH `/settings/digital-receipt`
تحديث إعدادات الفاتورة الرقمية

## POST `/receipts/:id/send-whatsapp`
إرسال الفاتورة عبر واتساب

**Request:**
```json
{
  "phone": "+966500000001",
  "includeAppLink": true
}
```

**Response 200:**
```json
{
  "status": "SENT",
  "messageId": "uuid",
  "receiptUrl": "https://alhai.app/r/ABC123"
}
```

---

# 📊 47. App Downloads Report ★ Phase 10

## GET `/reports/app-downloads`
تقرير تحميلات التطبيق

**Query Params:**
| Param | Type | Description |
|-------|------|-------------|
| from | date | من تاريخ |
| to | date | إلى تاريخ |
| source | string | `POS`, `RECEIPT`, `REFERRAL`, `ORGANIC` |

**Response 200:**
```json
{
  "summary": {
    "totalDownloads": 245,
    "fromPos": 120,
    "fromReceipt": 80,
    "fromReferral": 35,
    "organic": 10
  },
  "daily": [
    {"date": "2026-01-13", "downloads": 15, "orders": 8},
    {"date": "2026-01-12", "downloads": 12, "orders": 5}
  ],
  "conversionRate": 48.9
}
```

---

# 🔗 48. Referral Program ★ Phase 10

## GET `/settings/referral`
إعدادات برنامج الإحالة

**Response 200:**
```json
{
  "enabled": true,
  "storeCode": "STORE123",
  "storeQrCodeUrl": "https://alhai.app/qr/STORE123",
  "referrerPoints": 100,
  "refereePoints": 50,
  "refereeDiscount": 5,
  "referralUrl": "https://alhai.app/ref/{customerId}"
}
```

## PATCH `/settings/referral`
تحديث إعدادات الإحالة

## GET `/reports/referrals`
تقرير الإحالات

**Response 200:**
```json
{
  "totalReferrals": 45,
  "successfulInstalls": 38,
  "ordersFromReferrals": 25,
  "revenueFromReferrals": 3500.00,
  "topReferrers": [
    {"customerId": "uuid", "name": "محمد أحمد", "referrals": 12, "revenue": 1200.00}
  ]
}
```

---

# 💳 26. Split Payment ⭐ NEW v3.0

## POST `/sales` (Updated)
إنشاء فاتورة بيع مع دفع مقسم

**Request (Split Payment):**
```json
{
  "items": [
    {
      "productId": "uuid",
      "quantity": 2,
      "unitPrice": 8.50
    }
  ],
  "payments": [
    {
      "method": "CASH",
      "amount": 200.00
    },
    {
      "method": "CARD",
      "amount": 150.00,
      "deviceId": "uuid",
      "transactionRef": "TXN123456"
    },
    {
      "method": "CREDIT",
      "amount": 150.00
    }
  ],
  "customerId": "uuid",
  "discount": 0,
  "notes": "",
  "clientCreatedAt": "2026-01-13T10:00:00Z"
}
```

**Response 201:**
```json
{
  "id": "uuid",
  "receiptNo": "POS-2026-00001",
  "items": [...],
  "subtotal": 500.00,
  "discount": 0,
  "tax": 75.00,
  "total": 500.00,
  "payments": [
    {
      "id": "uuid",
      "method": "CASH",
      "amount": 200.00,
      "processedAt": "2026-01-13T10:00:00Z"
    },
    {
      "id": "uuid",
      "method": "CARD",
      "amount": 150.00,
      "deviceId": "uuid",
      "transactionRef": "TXN123456",
      "processedAt": "2026-01-13T10:00:01Z"
    },
    {
      "id": "uuid",
      "method": "CREDIT",
      "amount": 150.00,
      "processedAt": "2026-01-13T10:00:02Z"
    }
  ],
  "paymentSummary": {
    "cashPaid": 200.00,
    "cardPaid": 150.00,
    "creditAmount": 150.00,
    "totalPaid": 500.00
  },
  "customerId": "uuid",
  "status": "COMPLETED"
}
```

**Validation Rules:**
- مجموع `payments.amount` يجب أن يساوي `total`
- إذا كان هناك `CREDIT` payment، يجب تحديد `customerId`
- `CARD` payment يتطلب `deviceId` و `transactionRef`

**Errors:**
- `400 PAYMENT_AMOUNT_MISMATCH` - مجموع الدفعات لا يساوي الإجمالي
- `400 CREDIT_REQUIRES_CUSTOMER` - الدفع الآجل يتطلب تحديد العميل
- `400 CARD_REQUIRES_DEVICE` - دفع البطاقة يتطلب جهاز

---

## GET `/sales/:id/payments`
قائمة دفعات الفاتورة

**Response 200:**
```json
{
  "saleId": "uuid",
  "payments": [
    {
      "id": "uuid",
      "method": "CASH",
      "amount": 200.00,
      "processedAt": "2026-01-13T10:00:00Z"
    }
  ],
  "total": 500.00,
  "totalPaid": 500.00,
  "remainingBalance": 0.00
}
```

---

# 📧 27. Debt Reminders ⭐ NEW v3.0

## GET `/debt-reminders/settings`
إعدادات تذكير الديون

**Response 200:**
```json
{
  "enabled": true,
  "channels": ["WHATSAPP", "SMS"],
  "schedule": [
    {"daysAfterDue": 7, "enabled": true, "templateId": "reminder_7_days"},
    {"daysAfterDue": 15, "enabled": true, "templateId": "reminder_15_days"},
    {"daysAfterDue": 30, "enabled": true, "templateId": "reminder_30_days"}
  ],
  "minAmount": 100.00,
  "autoSend": false,
  "defaultChannel": "WHATSAPP",
  "excludeWeekends": true,
  "sendTime": "10:00"
}
```

## PATCH `/debt-reminders/settings`
تحديث إعدادات التذكير

**Request:**
```json
{
  "enabled": true,
  "channels": ["WHATSAPP"],
  "schedule": [
    {"daysAfterDue": 7, "enabled": true},
    {"daysAfterDue": 15, "enabled": true}
  ],
  "minAmount": 200.00,
  "autoSend": true
}
```

---

## GET `/debt-reminders/templates`
قوالب رسائل التذكير

**Response 200:**
```json
{
  "templates": [
    {
      "id": "reminder_7_days",
      "name": "تذكير بعد 7 أيام",
      "channel": "WHATSAPP",
      "content": "مرحباً {customer_name}،\n\nنذكرك بمبلغ {amount} ر.س المستحق منذ {days} يوم.\n\nللدفع: {payment_link}\n\nشكراً لك،\n{store_name}",
      "variables": ["customer_name", "amount", "days", "payment_link", "store_name"],
      "isDefault": true
    }
  ]
}
```

## POST `/debt-reminders/templates`
إنشاء قالب جديد

## PUT `/debt-reminders/templates/:id`
تعديل قالب

## DELETE `/debt-reminders/templates/:id`
حذف قالب (فقط القوالب المخصصة)

---

## GET `/debt-reminders/scheduled`
التذكيرات المجدولة

**Query Params:**
| Param | Type | Description |
|-------|------|-------------|
| from | date | من تاريخ |
| to | date | إلى تاريخ |
| status | string | `PENDING`, `SENT`, `FAILED` |

**Response 200:**
```json
{
  "reminders": [
    {
      "id": "uuid",
      "customerId": "uuid",
      "customerName": "أحمد محمد",
      "customerPhone": "+966500001234",
      "debtAmount": 1500.00,
      "daysOverdue": 7,
      "scheduledAt": "2026-02-08T10:00:00Z",
      "channel": "WHATSAPP",
      "templateId": "reminder_7_days",
      "status": "PENDING"
    }
  ],
  "summary": {
    "pending": 15,
    "sentToday": 8,
    "failedToday": 1
  }
}
```

---

## POST `/debt-reminders/send`
إرسال تذكير يدوي

**Request:**
```json
{
  "customerId": "uuid",
  "channel": "WHATSAPP",
  "templateId": "reminder_7_days"
}
```

**Response 200:**
```json
{
  "reminderId": "uuid",
  "status": "SENT",
  "messageId": "wamid.xxx",
  "sentAt": "2026-02-02T10:30:00Z"
}
```

---

## POST `/debt-reminders/send-bulk`
إرسال تذكيرات جماعية

**Request:**
```json
{
  "filter": {
    "minAmount": 500,
    "minDaysOverdue": 7,
    "maxDaysOverdue": 30
  },
  "channel": "WHATSAPP",
  "templateId": "reminder_7_days",
  "dryRun": true
}
```

**Response 200 (dryRun=true):**
```json
{
  "wouldSendTo": 23,
  "customers": [
    {"id": "uuid", "name": "أحمد محمد", "amount": 1500.00, "daysOverdue": 10}
  ],
  "estimatedCost": 11.50
}
```

---

## GET `/debt-reminders/log`
سجل التذكيرات المرسلة

**Query Params:**
| Param | Type | Description |
|-------|------|-------------|
| customerId | uuid | فلتر بالعميل |
| channel | string | `WHATSAPP`, `SMS` |
| status | string | `SENT`, `DELIVERED`, `READ`, `FAILED` |
| from | date | من تاريخ |
| to | date | إلى تاريخ |

**Response 200:**
```json
{
  "logs": [
    {
      "id": "uuid",
      "customerId": "uuid",
      "customerName": "أحمد محمد",
      "channel": "WHATSAPP",
      "status": "READ",
      "debtAmount": 1500.00,
      "sentAt": "2026-02-01T10:30:00Z",
      "deliveredAt": "2026-02-01T10:30:05Z",
      "readAt": "2026-02-01T10:35:00Z",
      "messagePreview": "مرحباً أحمد، نذكرك بمبلغ..."
    }
  ],
  "total": 45
}
```

---

# 🏪 28. Multi-Branch ⭐ NEW v3.0

## GET `/branches`
قائمة الفروع

**Response 200:**
```json
{
  "branches": [
    {
      "id": "uuid",
      "name": "فرع الرياض - العليا",
      "address": "شارع العليا، حي الورود",
      "phone": "+966500000001",
      "isMain": true,
      "status": "ACTIVE",
      "productsCount": 1234,
      "lowStockCount": 23,
      "settings": {
        "workingHours": {...},
        "autoSync": true
      },
      "createdAt": "2026-01-01T00:00:00Z"
    }
  ],
  "total": 3
}
```

## POST `/branches`
إنشاء فرع جديد

**Request:**
```json
{
  "name": "فرع جدة - الكورنيش",
  "address": "طريق الكورنيش، حي الشاطئ",
  "phone": "+966500000002",
  "settings": {
    "copyProductsFrom": "uuid",
    "copyPricesFrom": "uuid"
  }
}
```

**Response 201:**
```json
{
  "id": "uuid",
  "name": "فرع جدة - الكورنيش",
  "isMain": false,
  "status": "ACTIVE",
  "inventorySetup": "PENDING",
  "createdAt": "2026-02-02T10:00:00Z"
}
```

## GET `/branches/:id`
تفاصيل الفرع

## PATCH `/branches/:id`
تعديل بيانات الفرع

## DELETE `/branches/:id`
تعطيل الفرع (Soft delete)

---

## GET `/branches/:id/inventory`
مخزون الفرع

**Query Params:**
| Param | Type | Description |
|-------|------|-------------|
| lowStock | bool | المنخفض فقط |
| categoryId | uuid | فلتر بالفئة |
| search | string | بحث |

**Response 200:**
```json
{
  "branchId": "uuid",
  "branchName": "فرع الرياض",
  "inventory": [
    {
      "productId": "uuid",
      "productName": "حليب طازج",
      "barcode": "6281000000001",
      "quantity": 50,
      "reservedQty": 5,
      "availableQty": 45,
      "minStock": 20,
      "status": "IN_STOCK",
      "lastUpdated": "2026-02-01T10:00:00Z"
    }
  ],
  "summary": {
    "totalProducts": 1234,
    "inStock": 1100,
    "lowStock": 100,
    "outOfStock": 34
  }
}
```

## POST `/branches/:id/inventory/adjust`
تعديل مخزون الفرع

**Request:**
```json
{
  "productId": "uuid",
  "newQuantity": 100,
  "reason": "جرد فعلي"
}
```

---

## GET `/branches/comparison`
مقارنة الفروع

**Query Params:**
| Param | Type | Description |
|-------|------|-------------|
| metric | string | `sales`, `stock`, `customers` |
| from | date | من تاريخ |
| to | date | إلى تاريخ |

**Response 200:**
```json
{
  "metric": "sales",
  "period": {"from": "2026-01-01", "to": "2026-01-31"},
  "branches": [
    {
      "branchId": "uuid",
      "branchName": "فرع الرياض",
      "value": 150000.00,
      "change": 12.5,
      "rank": 1
    },
    {
      "branchId": "uuid",
      "branchName": "فرع جدة",
      "value": 120000.00,
      "change": 8.3,
      "rank": 2
    }
  ]
}
```

---

# 🔄 29. Stock Transfers ⭐ NEW v3.0

## GET `/stock-transfers`
قائمة عمليات النقل

**Query Params:**
| Param | Type | Description |
|-------|------|-------------|
| fromBranchId | uuid | من فرع |
| toBranchId | uuid | إلى فرع |
| status | string | `DRAFT`, `PENDING`, `IN_TRANSIT`, `RECEIVED`, `CANCELLED` |
| from | date | من تاريخ |
| to | date | إلى تاريخ |

**Response 200:**
```json
{
  "transfers": [
    {
      "id": "uuid",
      "transferNumber": "TR-2026-00001",
      "fromBranch": {"id": "uuid", "name": "فرع الرياض"},
      "toBranch": {"id": "uuid", "name": "فرع جدة"},
      "itemsCount": 15,
      "totalValue": 5000.00,
      "status": "IN_TRANSIT",
      "isAiSuggested": true,
      "aiReason": "نقص متوقع في فرع جدة",
      "createdBy": {"id": "uuid", "name": "أحمد"},
      "createdAt": "2026-02-01T10:00:00Z",
      "sentAt": "2026-02-01T11:00:00Z",
      "receivedAt": null
    }
  ],
  "summary": {
    "pending": 3,
    "inTransit": 2,
    "receivedThisMonth": 15
  }
}
```

## POST `/stock-transfers`
إنشاء عملية نقل جديدة

**Request:**
```json
{
  "fromBranchId": "uuid",
  "toBranchId": "uuid",
  "items": [
    {
      "productId": "uuid",
      "quantity": 50
    }
  ],
  "notes": "نقل طارئ بسبب نقص المخزون",
  "isAiSuggested": false
}
```

**Response 201:**
```json
{
  "id": "uuid",
  "transferNumber": "TR-2026-00002",
  "status": "DRAFT",
  "items": [
    {
      "id": "uuid",
      "productId": "uuid",
      "productName": "حليب طازج",
      "quantity": 50,
      "unitCost": 10.00,
      "totalValue": 500.00
    }
  ],
  "totalItems": 1,
  "totalValue": 500.00,
  "createdAt": "2026-02-02T10:00:00Z"
}
```

## GET `/stock-transfers/:id`
تفاصيل عملية النقل

## PATCH `/stock-transfers/:id`
تعديل عملية النقل (فقط DRAFT)

## DELETE `/stock-transfers/:id`
إلغاء عملية النقل

---

## POST `/stock-transfers/:id/send`
إرسال عملية النقل

**Request:**
```json
{
  "notes": "تم تسليم للسائق أحمد"
}
```

**Response 200:**
```json
{
  "id": "uuid",
  "status": "IN_TRANSIT",
  "sentAt": "2026-02-02T11:00:00Z",
  "sentBy": {"id": "uuid", "name": "محمد"}
}
```

---

## POST `/stock-transfers/:id/receive`
استلام عملية النقل

**Request:**
```json
{
  "items": [
    {
      "productId": "uuid",
      "quantityReceived": 48,
      "condition": "GOOD",
      "notes": "2 علب تالفة"
    }
  ],
  "notes": "تم الاستلام كاملاً ما عدا التالف"
}
```

**Response 200:**
```json
{
  "id": "uuid",
  "status": "RECEIVED",
  "receivedAt": "2026-02-02T14:00:00Z",
  "receivedBy": {"id": "uuid", "name": "سارة"},
  "discrepancies": [
    {
      "productId": "uuid",
      "productName": "حليب طازج",
      "expected": 50,
      "received": 48,
      "difference": -2,
      "condition": "DAMAGED"
    }
  ],
  "inventoryMovements": [
    {"branchId": "uuid", "productId": "uuid", "type": "TRANSFER_IN", "quantity": 48}
  ]
}
```

---

# 🤖 30. AI Transfer Suggestions ⭐ NEW v3.0

## GET `/ai-transfers/suggestions`
اقتراحات النقل الذكي

**Query Params:**
| Param | Type | Description |
|-------|------|-------------|
| priority | string | `URGENT`, `NORMAL`, `LOW` |
| status | string | `PENDING`, `APPLIED`, `IGNORED` |

**Response 200:**
```json
{
  "suggestions": [
    {
      "id": "uuid",
      "fromBranch": {"id": "uuid", "name": "فرع الرياض"},
      "toBranch": {"id": "uuid", "name": "فرع جدة"},
      "product": {
        "id": "uuid",
        "name": "حليب طازج",
        "barcode": "6281000000001"
      },
      "suggestedQty": 50,
      "fromStock": 200,
      "toStock": 10,
      "fromSalesRate": 5.0,
      "toSalesRate": 15.0,
      "daysUntilStockout": 0.67,
      "priority": "URGENT",
      "reason": "سينفد المخزون في فرع جدة خلال يوم واحد",
      "confidence": 0.95,
      "status": "PENDING",
      "createdAt": "2026-02-02T08:00:00Z"
    }
  ],
  "summary": {
    "urgent": 5,
    "normal": 12,
    "low": 8,
    "potentialSavings": 15000.00
  }
}
```

## POST `/ai-transfers/suggestions/:id/apply`
تطبيق اقتراح AI

**Request:**
```json
{
  "adjustedQty": 45,
  "notes": "تعديل الكمية حسب الموجود"
}
```

**Response 200:**
```json
{
  "suggestionId": "uuid",
  "status": "APPLIED",
  "transfer": {
    "id": "uuid",
    "transferNumber": "TR-2026-00003",
    "status": "DRAFT"
  }
}
```

## POST `/ai-transfers/suggestions/:id/ignore`
تجاهل اقتراح AI

**Request:**
```json
{
  "reason": "المنتج سيصل غداً من المورد"
}
```

---

## POST `/ai-transfers/generate`
إعادة توليد الاقتراحات

**Request:**
```json
{
  "branchIds": ["uuid1", "uuid2"],
  "lookbackDays": 7,
  "forecastDays": 14
}
```

**Response 200:**
```json
{
  "generatedAt": "2026-02-02T10:00:00Z",
  "newSuggestions": 15,
  "updatedSuggestions": 3,
  "removedSuggestions": 2
}
```

---

## GET `/ai-transfers/analytics`
تحليلات النقل الذكي

**Response 200:**
```json
{
  "period": {"from": "2026-01-01", "to": "2026-02-02"},
  "suggestionsGenerated": 150,
  "suggestionsApplied": 85,
  "suggestionsIgnored": 45,
  "applicationRate": 56.7,
  "stockoutsPreventedEstimate": 23,
  "savingsEstimate": 45000.00,
  "accuracyScore": 0.87
}
```

---

# ⭐ 31. Loyalty Extended ⭐ NEW v3.0

## GET `/loyalty/settings` (Extended)
إعدادات الولاء الموسعة

**Response 200:**
```json
{
  "enabled": true,
  "pointsPerRiyal": 1,
  "pointsToRiyal": 100,
  "minRedemption": 100,
  "pointsExpiryMonths": 12,
  "tiers": {
    "enabled": true,
    "levels": [
      {
        "id": "BRONZE",
        "name": "برونزي",
        "nameEn": "Bronze",
        "minPoints": 0,
        "multiplier": 1.0,
        "benefits": ["نقطة لكل ريال"]
      },
      {
        "id": "SILVER",
        "name": "فضي",
        "nameEn": "Silver",
        "minPoints": 1000,
        "multiplier": 1.25,
        "benefits": ["1.25 نقطة لكل ريال", "عروض حصرية"]
      },
      {
        "id": "GOLD",
        "name": "ذهبي",
        "nameEn": "Gold",
        "minPoints": 5000,
        "multiplier": 1.5,
        "benefits": ["1.5 نقطة لكل ريال", "توصيل مجاني", "أولوية الطلبات"]
      },
      {
        "id": "DIAMOND",
        "name": "ماسي",
        "nameEn": "Diamond",
        "minPoints": 15000,
        "multiplier": 2.0,
        "benefits": ["نقطتان لكل ريال", "خصم 5% دائم", "هدايا موسمية"]
      }
    ]
  }
}
```

---

## GET `/accounts/:id/loyalty` (Extended)
نقاط وولاء العميل

**Response 200:**
```json
{
  "accountId": "uuid",
  "tier": {
    "current": "SILVER",
    "name": "فضي",
    "multiplier": 1.25,
    "nextTier": "GOLD",
    "pointsToNextTier": 2500
  },
  "points": {
    "current": 2500,
    "pending": 150,
    "lifetimeEarned": 3500,
    "lifetimeRedeemed": 500,
    "equivalentValue": 25.00
  },
  "expiring": {
    "amount": 300,
    "expiryDate": "2026-03-01",
    "daysUntilExpiry": 27
  },
  "recentTransactions": [
    {
      "id": "uuid",
      "type": "EARN",
      "points": 50,
      "multiplier": 1.25,
      "basePoints": 40,
      "bonusPoints": 10,
      "referenceId": "sale-uuid",
      "createdAt": "2026-02-01T10:00:00Z"
    }
  ]
}
```

---

## GET `/loyalty/expiring-points`
النقاط التي ستنتهي قريباً

**Query Params:**
| Param | Type | Description |
|-------|------|-------------|
| withinDays | int | خلال X يوم (Default: 30) |

**Response 200:**
```json
{
  "customers": [
    {
      "accountId": "uuid",
      "name": "أحمد محمد",
      "phone": "+966500001234",
      "expiringPoints": 500,
      "expiryDate": "2026-03-01",
      "daysUntilExpiry": 27,
      "totalPoints": 2500
    }
  ],
  "summary": {
    "totalExpiringPoints": 15000,
    "affectedCustomers": 45
  }
}
```

---

## POST `/loyalty/notify-expiring`
إرسال تنبيه بالنقاط المنتهية

**Request:**
```json
{
  "withinDays": 30,
  "channel": "WHATSAPP",
  "dryRun": false
}
```

---

## POST `/accounts/:id/loyalty/redeem` (Extended)
استبدال النقاط (موسع)

**Request:**
```json
{
  "points": 1000,
  "saleId": "uuid",
  "redeemType": "DISCOUNT"
}
```

**Response 200:**
```json
{
  "redemptionId": "uuid",
  "pointsRedeemed": 1000,
  "discountApplied": 10.00,
  "remainingPoints": 1500,
  "tier": {
    "current": "SILVER",
    "affected": false
  }
}
```

**Errors:**
- `400 INSUFFICIENT_POINTS` - نقاط غير كافية
- `400 BELOW_MIN_REDEMPTION` - أقل من الحد الأدنى
- `400 POINTS_WOULD_DOWNGRADE_TIER` - سيؤدي لخفض المستوى (تحذير)

---

# ⚠️ Error Codes

## Error Format
```json
{
  "error": {
    "code": "INSUFFICIENT_STOCK",
    "message": "الكمية المطلوبة غير متوفرة",
    "requestId": "uuid",
    "details": {
      "productId": "uuid",
      "requested": 10,
      "available": 5
    }
  }
}
```

## Common Errors
| Code | HTTP | Description |
|------|------|-------------|
| `UNAUTHORIZED` | 401 | غير مصرح |
| `FORBIDDEN` | 403 | لا صلاحية |
| `NOT_FOUND` | 404 | غير موجود |
| `VALIDATION_ERROR` | 400 | بيانات غير صحيحة |
| `INSUFFICIENT_STOCK` | 400 | مخزون غير كافي |
| `NEGATIVE_QUANTITY_NOT_ALLOWED` | 400 | كمية سالبة غير مسموحة |
| `ALREADY_EXISTS` | 409 | موجود مسبقاً |
| `PERIOD_ALREADY_CLOSED` | 409 | الفترة مُقفلة |
| `INVALID_STATUS_TRANSITION` | 409 | تحويل حالة غير مسموح |
| `IMPORT_SESSION_EXPIRED` | 404 | جلسة الاستيراد منتهية |
| `UNCONFIRMED_LOW_CONFIDENCE` | 400 | سطور غير مؤكدة |
| `IDEMPOTENCY_CONFLICT` | 409 | مفتاح مكرر بـ payload مختلف |
| `PAYMENT_AMOUNT_MISMATCH` | 400 | مجموع الدفعات لا يساوي الإجمالي |
| `CREDIT_REQUIRES_CUSTOMER` | 400 | الدفع الآجل يتطلب تحديد العميل |
| `CARD_REQUIRES_DEVICE` | 400 | دفع البطاقة يتطلب جهاز |
| `BRANCH_NOT_FOUND` | 404 | الفرع غير موجود |
| `TRANSFER_NOT_FOUND` | 404 | عملية النقل غير موجودة |
| `INVALID_TRANSFER_STATUS` | 409 | حالة النقل لا تسمح بهذا الإجراء |
| `INSUFFICIENT_BRANCH_STOCK` | 400 | مخزون الفرع غير كافي |
| `INSUFFICIENT_POINTS` | 400 | نقاط غير كافية للاستبدال |
| `BELOW_MIN_REDEMPTION` | 400 | أقل من الحد الأدنى للاستبدال |
| `POINTS_EXPIRED` | 400 | النقاط منتهية الصلاحية |
| `SUGGESTION_ALREADY_APPLIED` | 409 | الاقتراح مطبق مسبقاً |
| `REMINDER_ALREADY_SENT` | 409 | التذكير مرسل مسبقاً |
| `TEMPLATE_NOT_FOUND` | 404 | قالب الرسالة غير موجود |

---

> **Approved by:** _________ | **Date:** 2026-02-02
