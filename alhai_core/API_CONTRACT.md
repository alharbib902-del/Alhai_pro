# Alhai API Contract
**Version:** 1.2.0  
**Base URL:** `https://api.alhai.sa/v1`  
**Edge Functions:** `https://<project>.supabase.co/functions/v1`

---

## Conventions

### Authentication
```
Authorization: Bearer <access_token>
```

### Response Envelope (موحد لجميع الاستجابات)

**Single Object:**
```json
{
  "data": { ... },
  "meta": { "timestamp": "ISO8601" }
}
```

**List/Paginated:**
```json
{
  "data": [ ... ],
  "meta": {
    "page": 1,
    "limit": 20,
    "total": 150,
    "hasMore": true,
    "timestamp": "ISO8601"
  }
}
```

**DELETE Response:**
```json
{
  "data": { "deleted": true, "id": "uuid" }
}
```

### Pagination
```
?page=1&limit=20
```

### Filtering & Sorting
```
?status=active&sort=created_at&order=desc
```

### Idempotency (للعمليات الحساسة)

للعمليات التي قد تتكرر عند إعادة المحاولة:
```
Idempotency-Key: <UUID>
```

**العمليات التي تتطلب Idempotency-Key:**
- `POST /orders`
- `POST /purchase-orders/:id/receive`
- `POST /purchase-orders/:id/payment`
- `POST /debts/:id/payments`
- `POST /inventory/adjust`

### Currency & Precision

| الخاصية | القيمة |
|---------|--------|
| العملة | SAR (ريال سعودي) |
| الدقة | 2 decimals |
| Tax | مضاف إلى subtotal (total = subtotal - discount + tax) |

### Error Response
```json
{
  "code": "VALIDATION_ERROR",
  "message": "Human readable message",
  "details": { "field": "error description" }
}
```

### Error Codes
| Code | HTTP | Description |
|------|------|-------------|
| `UNAUTHORIZED` | 401 | Invalid/expired token |
| `FORBIDDEN` | 403 | RLS policy violation |
| `NOT_FOUND` | 404 | Resource not found |
| `VALIDATION_ERROR` | 400 | Invalid input |
| `CONFLICT` | 409 | Duplicate/conflict |
| `IDEMPOTENCY_CONFLICT` | 409 | Duplicate idempotency key with different payload |
| `SERVER_ERROR` | 500 | Internal error |

---

## Enums

### OrderStatus
| Value | Description |
|-------|-------------|
| `pending` | تم إنشاء الطلب، في انتظار التأكيد |
| `confirmed` | تم تأكيد الطلب |
| `preparing` | جاري تحضير الطلب |
| `ready` | جاهز للاستلام/التوصيل |
| `delivering` | جاري التوصيل |
| `delivered` | تم التوصيل بنجاح |
| `cancelled` | تم إلغاء الطلب |

**Transitions:** pending → confirmed → preparing → ready → delivering → delivered  
**Cancel allowed from:** pending, confirmed, preparing

### PaymentStatus
| Value | Description |
|-------|-------------|
| `pending` | في انتظار الدفع |
| `paid` | تم الدفع بالكامل |
| `partial` | دفع جزئي |
| `refunded` | تم استرجاع المبلغ |

### InventoryAdjustmentType
| Value | Description |
|-------|-------------|
| `received` | استلام بضاعة (زيادة) |
| `sold` | بيع (نقص) |
| `adjustment` | تعديل يدوي |
| `damaged` | تالف |
| `returned` | مرتجع |

### PurchaseOrderStatus
| Value | Description |
|-------|-------------|
| `draft` | مسودة |
| `ordered` | تم الطلب من المورد |
| `partial` | تم استلام جزئي |
| `received` | تم الاستلام الكامل |
| `cancelled` | ملغي |

### DeliveryStatus
| Value | Description |
|-------|-------------|
| `pending` | في انتظار التعيين |
| `assigned` | تم تعيين السائق |
| `picked_up` | تم الاستلام من المتجر |
| `in_transit` | في الطريق |
| `delivered` | تم التوصيل |
| `failed` | فشل التوصيل |

### DebtType
| Value | Description |
|-------|-------------|
| `customer` | دين على العميل |
| `supplier` | دين للمورد |

---

## 1. Authentication

### POST /auth/send-otp
```json
Request: { "phone": "+966512345678" }
Response: { "data": { "message": "OTP sent" } }
```

### POST /auth/verify-otp
```json
Request: { "phone": "+966512345678", "otp": "123456" }
Response: {
  "data": {
    "user": { "id", "phone", "name", "role" },
    "tokens": { "accessToken", "refreshToken", "expiresAt" }
  }
}
```

### POST /auth/refresh
```json
Request: { "refresh_token": "..." }
Response: { "data": { "accessToken", "refreshToken", "expiresAt" } }
```

---

## 2. Products

### GET /products
```
?store_id=xxx (مطلوب) &page=1&limit=20&category_id=xxx&search=query
```
> ⚠️ `store_id` مطلوب دائماً - لا يُسمح بقراءة منتجات كل المتاجر

### GET /products/:id
### GET /products/barcode/:barcode
### POST /products
### PATCH /products/:id
### DELETE /products/:id

**Product Response:**
```json
{
  "data": {
    "id": "uuid",
    "storeId": "uuid",
    "name": "string",
    "nameAr": "string",
    "barcode": "string?",
    "sku": "string?",
    "categoryId": "uuid?",
    "costPrice": 10.00,
    "salePrice": 15.00,
    "stockQuantity": 100,
    "minStockLevel": 10,
    "imageThumbnail": "url?",
    "imageMedium": "url?",
    "imageLarge": "url?",
    "isActive": true,
    "createdAt": "ISO8601",
    "updatedAt": "ISO8601"
  }
}
```

---

## 3. Categories

### GET /categories?store_id=xxx (مطلوب)
### GET /categories/:id
### POST /categories
### PATCH /categories/:id
### DELETE /categories/:id

---

## 4. Orders

### GET /orders
```
?store_id=xxx (مطلوب) &status=pending|confirmed|delivered|cancelled&customer_id=xxx
```

### GET /orders/:id
### POST /orders (Idempotency-Key مطلوب)
### PATCH /orders/:id/status
### DELETE /orders/:id

**Order Response:**
```json
{
  "data": {
    "id": "uuid",
    "storeId": "uuid",
    "orderNumber": "ORD-2026-0001",
    "customerId": "uuid?",
    "status": "pending",
    "paymentMethod": "cash|card|wallet",
    "paymentStatus": "pending|paid|refunded",
    "subtotal": 100.00,
    "discount": 10.00,
    "tax": 13.50,
    "total": 103.50,
    "items": [...],
    "createdAt": "ISO8601"
  }
}
```

---

## 5. Inventory

### GET /inventory/adjustments?product_id=xxx
### GET /inventory/store-adjustments?store_id=xxx (مطلوب) &type=received|sold|adjustment|damaged
### POST /inventory/adjust (Idempotency-Key مطلوب)
```json
{
  "productId": "uuid",
  "type": "received|sold|adjustment|damaged",
  "quantity": 10,
  "reason": "string?"
}
```
### GET /inventory/low-stock?store_id=xxx (مطلوب)
### GET /inventory/out-of-stock?store_id=xxx (مطلوب)

---

## 6. Suppliers

### GET /suppliers?store_id=xxx (مطلوب) &active_only=true
### GET /suppliers/:id
### POST /suppliers
### PATCH /suppliers/:id
### DELETE /suppliers/:id
### GET /suppliers/with-balance?store_id=xxx (مطلوب)

---

## 7. Purchases

### GET /purchase-orders?store_id=xxx (مطلوب) &status=draft|ordered|partial|received|cancelled
### GET /purchase-orders/:id
### POST /purchase-orders
### PATCH /purchase-orders/:id
### POST /purchase-orders/:id/cancel
### POST /purchase-orders/:id/receive (Idempotency-Key مطلوب)
### POST /purchase-orders/:id/payment (Idempotency-Key مطلوب)

---

## 8. Debts

### GET /debts?store_id=xxx (مطلوب) &type=customer|supplier&overdue_only=true
### GET /debts/:id
### GET /debts/party/:partyId
### POST /debts
### POST /debts/:id/payments (Idempotency-Key مطلوب)
### GET /debts/:id/payments
### GET /debts/summary?store_id=xxx (مطلوب)

---

## 9. Reports

### GET /reports/daily-summary?store_id=xxx (مطلوب) &date=2026-01-19
### GET /reports/sales-summaries?store_id=xxx (مطلوب) &start_date=...&end_date=...
### GET /reports/top-products?store_id=xxx (مطلوب) &start_date=...&end_date=...&limit=10
### GET /reports/category-sales?store_id=xxx (مطلوب) &start_date=...&end_date=...
### GET /reports/inventory-value?store_id=xxx (مطلوب)
### GET /reports/hourly-sales?store_id=xxx (مطلوب) &date=...
### GET /reports/monthly-comparison?store_id=xxx (مطلوب) &year=2026&month=1

---

## 10. Analytics

### GET /analytics/dashboard?store_id=xxx (مطلوب)
### GET /analytics/slow-moving?store_id=xxx (مطلوب) &days_threshold=30&limit=20
### GET /analytics/forecast?store_id=xxx (مطلوب) &days=7
### GET /analytics/alerts?store_id=xxx (مطلوب) &unread_only=false&limit=50
### PATCH /analytics/alerts/:id/read
### PATCH /analytics/alerts/read-all?store_id=xxx (مطلوب)
### GET /analytics/reorder-suggestions?store_id=xxx (مطلوب) &days_ahead=7
### GET /analytics/peak-hours?store_id=xxx (مطلوب) &start_date=...&end_date=...
### GET /analytics/customer-patterns?store_id=xxx (مطلوب) &limit=20

---

## 11. Delivery

### GET /deliveries?store_id=xxx (مطلوب) &status=...&driver_id=xxx
### GET /deliveries/:id
### POST /deliveries
### PATCH /deliveries/:id/status
### PATCH /deliveries/:id/assign
### GET /deliveries/:id/tracking

---

## 12. Addresses

### GET /addresses?user_id=xxx
### GET /addresses/:id
### POST /addresses
### PATCH /addresses/:id
### DELETE /addresses/:id
### PATCH /addresses/:id/set-default

---

## 13. Stores

### GET /stores?owner_id=xxx
### GET /stores/:id
### POST /stores
### PATCH /stores/:id
### GET /stores/:id/stats

---

*Last Updated: 2026-01-19 v1.1.0*
