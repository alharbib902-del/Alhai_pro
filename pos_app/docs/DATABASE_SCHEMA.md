# 🗄️ مخطط قاعدة البيانات (Database Schema)

**Schema Version:** 4

---

## 📊 الجداول

### users
| العمود | النوع | الوصف |
|--------|-------|-------|
| id | INTEGER PK | معرف |
| username | TEXT | اسم المستخدم |
| password_hash | TEXT | كلمة المرور (مشفرة) |
| name | TEXT | الاسم الكامل |
| role | TEXT | الدور (admin/cashier) |
| is_active | INTEGER | فعال؟ |
| created_at | DATETIME | تاريخ الإنشاء |

---

### products
| العمود | النوع | الوصف |
|--------|-------|-------|
| id | INTEGER PK | معرف |
| name | TEXT | اسم المنتج |
| barcode | TEXT UNIQUE | الباركود |
| category_id | INTEGER FK | الصنف |
| cost_price | REAL | سعر التكلفة |
| sale_price | REAL | سعر البيع |
| quantity | REAL | الكمية |
| min_quantity | REAL | الحد الأدنى |
| unit | TEXT | الوحدة |
| is_active | INTEGER | فعال؟ |
| image_path | TEXT | صورة |
| created_at | DATETIME | تاريخ الإنشاء |

---

### categories
| العمود | النوع | الوصف |
|--------|-------|-------|
| id | INTEGER PK | معرف |
| name | TEXT | اسم الصنف |
| parent_id | INTEGER FK | الصنف الأب |
| color | TEXT | اللون |
| icon | TEXT | الأيقونة |

---

### sales
| العمود | النوع | الوصف |
|--------|-------|-------|
| id | INTEGER PK | معرف |
| invoice_number | TEXT UNIQUE | رقم الفاتورة |
| customer_id | INTEGER FK | العميل |
| user_id | INTEGER FK | الكاشير |
| subtotal | REAL | الإجمالي الفرعي |
| discount | REAL | الخصم |
| vat | REAL | الضريبة |
| total | REAL | الإجمالي |
| payment_method | TEXT | طريقة الدفع |
| paid_amount | REAL | المدفوع |
| status | TEXT | الحالة |
| notes | TEXT | ملاحظات |
| created_at | DATETIME | التاريخ |

---

### sale_items
| العمود | النوع | الوصف |
|--------|-------|-------|
| id | INTEGER PK | معرف |
| sale_id | INTEGER FK | البيع |
| product_id | INTEGER FK | المنتج |
| quantity | REAL | الكمية |
| unit_price | REAL | سعر الوحدة |
| discount | REAL | الخصم |
| total | REAL | الإجمالي |

---

### accounts
| العمود | النوع | الوصف |
|--------|-------|-------|
| id | INTEGER PK | معرف |
| name | TEXT | الاسم |
| phone | TEXT | الهاتف |
| email | TEXT | البريد |
| type | TEXT | النوع (customer/supplier) |
| balance | REAL | الرصيد |
| credit_limit | REAL | الحد الائتماني |
| is_active | INTEGER | فعال؟ |

---

### transactions
| العمود | النوع | الوصف |
|--------|-------|-------|
| id | INTEGER PK | معرف |
| account_id | INTEGER FK | الحساب |
| type | TEXT | النوع (debit/credit) |
| amount | REAL | المبلغ |
| reference | TEXT | المرجع |
| notes | TEXT | ملاحظات |
| created_at | DATETIME | التاريخ |

---

### inventory_movements
| العمود | النوع | الوصف |
|--------|-------|-------|
| id | INTEGER PK | معرف |
| product_id | INTEGER FK | المنتج |
| type | TEXT | النوع (in/out/adjust) |
| quantity | REAL | الكمية |
| reference | TEXT | المرجع |
| notes | TEXT | ملاحظات |
| created_at | DATETIME | التاريخ |

---

### orders
| العمود | النوع | الوصف |
|--------|-------|-------|
| id | INTEGER PK | معرف |
| order_number | TEXT | رقم الطلب |
| customer_id | INTEGER FK | العميل |
| status | TEXT | الحالة |
| total | REAL | الإجمالي |
| delivery_address | TEXT | عنوان التوصيل |
| driver_id | INTEGER FK | السائق |
| created_at | DATETIME | التاريخ |

---

### audit_log
| العمود | النوع | الوصف |
|--------|-------|-------|
| id | INTEGER PK | معرف |
| user_id | INTEGER FK | المستخدم |
| action | TEXT | الإجراء |
| table_name | TEXT | الجدول |
| record_id | INTEGER | معرف السجل |
| old_value | TEXT | القيمة القديمة |
| new_value | TEXT | القيمة الجديدة |
| created_at | DATETIME | التاريخ |

---

### sync_queue
| العمود | النوع | الوصف |
|--------|-------|-------|
| id | INTEGER PK | معرف |
| table_name | TEXT | الجدول |
| record_id | INTEGER | معرف السجل |
| action | TEXT | الإجراء (create/update/delete) |
| payload | TEXT | البيانات (JSON) |
| status | TEXT | الحالة |
| retry_count | INTEGER | محاولات |
| created_at | DATETIME | التاريخ |

---

## 🔗 العلاقات

```
products ──┐
           ├── sale_items ──── sales
           │
categories ┘

accounts ──── transactions

products ──── inventory_movements

orders ──── order_items ──── products
```

---

## 📝 Migrations

```dart
// From v3 to v4
if (from < 4) {
  await m.createTable(orders);
  await m.createTable(orderItems);
  await m.createTable(auditLog);
}
```
