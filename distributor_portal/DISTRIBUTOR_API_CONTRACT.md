# 🔌 Distributor Portal - API Contract

**Version:** 1.0.0  
**Date:** 2026-01-15  
**Base URL:** `https://api.alhai.sa/v1`

---

## 🔐 Authentication

All APIs require Bearer token authentication.

```
Authorization: Bearer {distributor_token}
```

---

## 📦 Product Management

### GET /distributor/products
**List all products**

Response:
```json
{
  "products": [
    {
      "id": "uuid",
      "name": "دقيق فاخر",
      "sku": "FLOUR-50",
      "wholesale_price": 45.00,
      "min_order_quantity": 10,
      "unit": "كرتون",
      "category": "دقيق",
      "brand": "النخبة",
      "in_stock": true,
      "stock_quantity": 500
    }
  ]
}
```

### POST /distributor/products
**Add new product**

Request:
```json
{
  "name": "دقيق فاخر",
  "sku": "FLOUR-50",
  "wholesale_price": 45.00,
  "min_order_quantity": 10,
  "unit": "كرتون",
  "category": "دقيق"
}
```

---

## 🎁 Bulk Offers

### POST /distributor/offers
**Create bulk offer**

Request:
```json
{
  "title": "عرض رمضان",
  "products": [
    {
      "product_id": "uuid",
      "quantity": 10,
      "special_price": 42.00
    }
  ],
  "discount_percentage": 10,
  "valid_from": "2026-03-01",
  "valid_until": "2026-03-15"
}
```

---

## 📋 Orders

### GET /distributor/orders
**List wholesale orders**

### PATCH /distributor/orders/:id
**Update order status**

Request:
```json
{
  "status": "confirmed|shipped|delivered"
}
```

---

## 💰 Invoices & Payments

### GET /distributor/invoices
**List invoices**

### GET /distributor/payments
**Payment history**

---

**📅 Last Updated**: 2026-01-15
