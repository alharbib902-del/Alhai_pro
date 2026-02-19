# Admin POS - Step 003: Staff + Products

> **المرحلة:** Phase 3-4 | **المدة:** 5 أسابيع | **الأولوية:** P0

---

## 🎯 الهدف

إنشاء:
- إدارة الموظفين (Cashier/Driver/Manager)
- إدارة المنتجات والمخزون
- نقل المخزون بين الفروع

---

## 📋 المهام

### STAFF-002: Add Cashier (8h)

**Route:** `/staff/add/cashier`

**المتطلبات:**
- الاسم، الجوال
- Store assignment
- PIN (4 digits)
- Permissions
- إرسال SMS + Email

### PROD-001: Products List (10h)

**Route:** `/products`

**الميزات:**
- عرض منتجات كل البقالات
- Filters: Store, Category, Stock
- Search
- Actions: Edit, Delete

### PROD-002: Add Product (10h)

**Route:** `/products/add`

**الحقول:**
- الاسم (عربي/إنجليزي)
- Barcode
- السعر (شراء/بيع)
- Category
- صور (R2)
- Stock per warehouse

### PROD-008: Transfer Inventory (12h)

**Route:** `/warehouses/transfer`

**Pro Plan Only!**

```dart
// Validation
if (!owner.plan.allowsTransfers) {
  throw "خطتك لا تسمح بالنقل. ترقية للـ Pro؟";
}
```

**Flow:**
1. From Warehouse → To Warehouse
2. Select products + quantities
3. Assign Driver
4. Confirm
5. Update inventory

---

## ✅ معايير الإنجاز

- [ ] Add Cashier/Driver/Manager يعمل
- [ ] Products CRUD كامل
- [ ] Transfer Inventory (Pro plan)
- [ ] Subscription enforcement

---

## 📚 المراجع

- [PROD.json](../PROD.json) - STAFF-*, PROD-*
- [ADMIN_POS_SPEC.md](../ADMIN_POS_SPEC.md) - Business Logic
