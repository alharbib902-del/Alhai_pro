# POS App - Step 002: Sync Queue & POS Layout

> **المرحلة:** Phase 0 | **المدة:** 2-3 أيام | **الأولوية:** P0

---

## 🎯 الهدف

إنشاء:
- Sync Queue للـ Offline-first
- POS Screen layout (Split View)
- Products Grid + Categories
- Cart Panel

---

## 📋 المهام

### SETUP-003: Sync Queue skeleton (8h)

**الملفات المطلوبة:**
- `lib/core/sync/sync_queue.dart` - Queue logic
- `lib/core/sync/sync_status.dart` - Status enum
- `lib/core/sync/sync_service.dart` - Service

**الـ Schema:**
```dart
class SyncQueue {
  String id;
  String entityType;  // SALE, PURCHASE, etc.
  String entityId;
  String action;      // CREATE, UPDATE, DELETE
  String payload;     // JSON
  SyncStatus status;  // PENDING, SYNCED, FAILED
  int attempts;
  DateTime createdAt;
}
```

### UI-001: POS Screen layout (8h)

**الملفات المطلوبة:**
- `lib/features/pos/screens/pos_screen.dart`
- `lib/features/pos/widgets/` - Components

**التصميم:**
```
┌─────────────────────┬─────────────────┐
│                     │                 │
│   Products Grid     │   Cart Panel    │
│      (60%)          │     (40%)       │
│                     │                 │
│   [Categories]      │   [Items]       │
│   [Products]        │   [Totals]      │
│                     │   [Pay Button]  │
│                     │                 │
└─────────────────────┴─────────────────┘
```

### UI-002: Products Grid (8h)

**المتطلبات:**
- GridView responsive
- Category filter chips
- Product cards (image, name, price)
- Stock indicator

### UI-003: Cart Panel (8h)

**المتطلبات:**
- Cart items list
- Quantity edit (+/-)
- Remove item
- Subtotal, discount, tax, total
- Pay button

---

## ✅ معايير الإنجاز

- [ ] Sync Queue يحفظ ويسترجع العمليات
- [ ] POS Screen يعرض split view
- [ ] Products تُعرض في grid
- [ ] Cart يضيف/يحذف/يعدل items

---

## 📚 المراجع

- [PROD.json](../PROD.json) - Tasks: SETUP-003, UI-001, UI-002, UI-003
- [POS_SITEMAP.md](../POS_SITEMAP.md) - Screen flows
