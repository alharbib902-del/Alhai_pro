# POS App Flow Specification

**Version:** 1.0.0  
**Date:** 2026-01-19

---

## Screen List

| # | Screen | Slice | Priority |
|---|--------|-------|----------|
| 1 | Splash | Shared | P0 |
| 2 | Login (OTP) | A-Sales | P0 |
| 3 | Store Select | A-Sales | P0 |
| 4 | Home Dashboard | Shared | P0 |
| 5 | Quick Sale | A-Sales | P0 |
| 6 | Product Search | A-Sales | P0 |
| 7 | Cart | A-Sales | P0 |
| 8 | Payment | A-Sales | P0 |
| 9 | Receipt | A-Sales | P0 |
| 10 | Products List | B-Ops | P1 |
| 11 | Product Detail | B-Ops | P1 |
| 12 | Add/Edit Product | B-Ops | P1 |
| 13 | Inventory Adjust | B-Ops | P1 |
| 14 | Suppliers List | B-Ops | P2 |
| 15 | Daily Report | B-Ops | P1 |
| 16 | Settings | Shared | P2 |

---

## Flow Diagrams

### Authentication Flow
```
Splash → [has token?]
    ├─ Yes → [token valid?]
    │         ├─ Yes → Store Select
    │         └─ No → Login
    └─ No → Login

Login → Enter Phone → Send OTP
      → Enter OTP → [valid?]
            ├─ Yes → Store Select
            └─ No → Error → retry
```

### Sales Flow (Core)
```
Home → Quick Sale → [scan/search]
     → Product Found → Add to Cart
     → Cart → [more items?]
           ├─ Yes → [scan/search]
           └─ No → Payment
     → Payment → [method: cash/card]
     → Receipt → [print?] → Home
```

### Inventory Flow
```
Home → Products List → Product Detail
     → Adjust Stock → [type: +/-]
     → Enter Quantity → Confirm
     → Success → Product Detail
```

---

## Screen Specifications

### 1. Splash
| Item | Value |
|------|-------|
| **Inputs** | None |
| **Actions** | Check auth status |
| **API** | None (local check) |
| **Next** | Login or Store Select |
| **Errors** | None |

---

### 2. Login (OTP)
| Item | Value |
|------|-------|
| **Inputs** | Phone number, OTP code |
| **Actions** | Send OTP, Verify OTP |
| **API** | `POST /auth/send-otp`, `POST /auth/verify-otp` |
| **Next** | Store Select |
| **Errors** | Invalid phone, Wrong OTP, Expired OTP, Rate limited |

---

### 3. Store Select
| Item | Value |
|------|-------|
| **Inputs** | Store selection |
| **Actions** | Load stores, Select store |
| **API** | `GET /stores/my` (يُرجع متاجر المستخدم كـ owner أو staff) |
| **Next** | Home Dashboard |
| **Errors** | No stores found |

> 📝 **TODO:** إن لم يتوفر `/stores/my`، استخدم `GET /stores?owner_id=xxx` مؤقتاً  
> لكن هذا يمنع دخول الكاشير (staff)

---

### 4. Home Dashboard
| Item | Value |
|------|---------|
| **Inputs** | None |
| **Actions** | Navigate to features |
| **API** | Sprint 1: None (navigation only), Sprint 3: `GET /analytics/dashboard?store_id=xxx` |
| **Next** | Quick Sale, Products, Inventory, Reports |
| **Errors** | Network error |

**Sprint 1 بسيط:**
- Navigation grid فقط (بدون API)
- Low stock badge placeholder

**Sprint 3 كامل:**
- Today's sales total
- Orders count
- Low stock alerts count

---

### 5. Quick Sale
| Item | Value |
|------|---------|
| **Inputs** | Barcode scan, Manual search |
| **Actions** | Scan barcode, Search product, Add to cart |
| **API** | `GET /products/barcode/:barcode?store_id=xxx`, `GET /products?store_id=xxx&search=xxx` |
| **Next** | Cart |
| **Errors** | Product not found, Out of stock |

> ⚠️ **مهم:** `store_id` مطلوب حتى في barcode endpoint لضمان عزل المتاجر

---

### 6. Product Search
| Item | Value |
|------|-------|
| **Inputs** | Search query, Category filter |
| **Actions** | Search, Filter, Select product |
| **API** | `GET /products?store_id=xxx&search=xxx&category_id=xxx` |
| **Next** | Add to Cart |
| **Errors** | No results |

---

### 7. Cart
| Item | Value |
|------|---------|
| **Inputs** | Quantity changes, Discount |
| **Actions** | Update quantity, Remove item, Apply discount |
| **API** | None (local state) |
| **Next** | Payment, Quick Sale |
| **Errors** | None |

**Cart Calculations:**
```
Subtotal = Σ(item.price × item.quantity)
Discount = user input or percentage
Tax = (Subtotal - Discount) × TAX_RATE
Total = Subtotal - Discount + Tax
```

**Tax Source (v1):**
> ثابت 15% (السعودية)  
> v2: من `/stores/:id/settings` إن لزم

```dart
const double TAX_RATE = 0.15; // v1: hardcoded
```

---

### 8. Payment
| Item | Value |
|------|-------|
| **Inputs** | Payment method, Amount received (cash) |
| **Actions** | Select method, Process payment |
| **API** | `POST /orders` |
| **Next** | Receipt |
| **Errors** | Payment failed, Network error |

**Idempotency (مطلوب):**
```
Header: Idempotency-Key: <UUID>
```
- عند إعادة المحاولة بنفس key: نفس response
- عند key مختلف مع نفس البيانات: طلب جديد
- الـ Receipt يحتاج `orderNumber` و `id` من الـ response

**Payment Methods:**
- Cash (calculate change)
- Card (external terminal)
- Credit (creates debt) → **v1: TBD** (depends on `POST /debts` or debt-in-order integration)

**Order Payload:**
```json
{
  "store_id": "xxx",
  "items": [...],
  "subtotal": 100,
  "discount": 10,
  "tax": 13.50,
  "total": 103.50,
  "payment_method": "cash",
  "payment_status": "paid"
}
```

**Response:**
```json
{
  "data": {
    "id": "uuid",
    "orderNumber": "ORD-2026-0001",
    ...
  }
}
```

---

### 9. Receipt
| Item | Value |
|------|-------|
| **Inputs** | None |
| **Actions** | Print, Share, New sale |
| **API** | None |
| **Next** | Quick Sale (new), Home |
| **Errors** | Print failed |

---

### 10. Products List
| Item | Value |
|------|-------|
| **Inputs** | Search, Category filter |
| **Actions** | Search, Filter, Navigate to detail |
| **API** | `GET /products?store_id=xxx` |
| **Next** | Product Detail, Add Product |
| **Errors** | Network error |

---

### 11. Product Detail
| Item | Value |
|------|-------|
| **Inputs** | None |
| **Actions** | Edit, Delete, Adjust stock |
| **API** | `GET /products/:id` |
| **Next** | Edit Product, Inventory Adjust |
| **Errors** | Product not found |

---

### 12. Add/Edit Product
| Item | Value |
|------|-------|
| **Inputs** | Name, Price, Barcode, Category, Image |
| **Actions** | Save, Cancel |
| **API** | `POST /products`, `PATCH /products/:id` |
| **Next** | Products List |
| **Errors** | Validation error, Duplicate barcode |

---

### 13. Inventory Adjust
| Item | Value |
|------|-------|
| **Inputs** | Type, Quantity, Reason |
| **Actions** | Adjust stock |
| **API** | `POST /inventory/adjust` (Idempotency-Key required) |
| **Next** | Product Detail |
| **Errors** | Insufficient stock (for decrease) |

**Adjustment Types:**
- `received` - استلام بضاعة
- `sold` - بيع (auto from orders)
- `adjustment` - تعديل يدوي
- `damaged` - تالف

---

### 14. Suppliers List
| Item | Value |
|------|-------|
| **Inputs** | Search |
| **Actions** | View, Add, Edit |
| **API** | `GET /suppliers?store_id=xxx` |
| **Next** | Supplier Detail |
| **Errors** | Network error |

---

### 15. Daily Report
| Item | Value |
|------|-------|
| **Inputs** | Date |
| **Actions** | View summary, Export |
| **API** | `GET /reports/daily-summary?store_id=xxx&date=xxx` |
| **Next** | Home |
| **Errors** | No data for date |

**Report Data:**
- Total sales
- Total orders
- Payment breakdown (cash/card)
- Top selling products

---

### 16. Settings
| Item | Value |
|------|-------|
| **Inputs** | Various settings |
| **Actions** | Update settings, Logout |
| **API** | Various |
| **Next** | Home, Login |
| **Errors** | Update failed |

---

## API Endpoint Summary by Screen

| Screen | Endpoints |
|--------|-----------|
| Login | `/auth/send-otp`, `/auth/verify-otp` |
| Store Select | `/stores/my` |
| Home | Sprint 1: None, Sprint 3: `/analytics/dashboard?store_id=xxx` |
| Quick Sale | `/products/barcode/:barcode?store_id=xxx`, `/products?store_id=xxx&search=xxx` |
| Cart | None (local) |
| Payment | `/orders` (with `Idempotency-Key` header) |
| Products | `/products?store_id=xxx`, `/products/:id` |
| Inventory | `/inventory/adjust` (with `Idempotency-Key` header) |
| Suppliers | `/suppliers?store_id=xxx` |
| Reports | `/reports/daily-summary?store_id=xxx&date=xxx` |

---

*Ready for Slice Mapping*
