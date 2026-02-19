# Distributor Portal - Step 001: Foundation

> **المرحلة:** Phase 0-1 | **المدة:** أسبوعين | **الأولوية:** P0

---

## 🎯 الهدف

تجهيز أساس بوابة الموزعين B2B:
- Flutter Web only
- Distributor RLS policies
- B2B data models
- Core screens

---

## 📋 المهام

### SETUP-001: Project setup (6h)

```bash
cd distributor_portal
flutter pub get

flutter pub add flutter_riverpod go_router
flutter pub add fl_chart  # Charts
```

### SETUP-002: Distributor RLS (6h)

```sql
-- Distributor sees only their data
CREATE POLICY "distributor_access" ON products
FOR ALL USING (distributor_id = auth.uid());

-- Distributors see stores they serve
CREATE POLICY "served_stores" ON stores
FOR SELECT USING (
  id IN (SELECT store_id FROM distributor_stores WHERE distributor_id = auth.uid())
);
```

### CORE-002: Dashboard (10h)

**Route:** `/`

- Revenue overview
- Recent orders
- Pending offers
- Analytics summary

### CORE-003: Product Catalog (8h)

**Route:** `/products`

- قائمة المنتجات
- Tiered pricing
- Stock levels
- Bulk actions

---

## ✅ معايير الإنجاز

- [ ] `flutter run -d chrome` يعمل
- [ ] Login/Registration يعمل
- [ ] Dashboard يعرض البيانات
- [ ] Product catalog يعمل

---

## 📚 المراجع

- [PROD.json](../PROD.json) - SETUP-*, CORE-*
- [PRD_FINAL.md](../PRD_FINAL.md) - Screens
