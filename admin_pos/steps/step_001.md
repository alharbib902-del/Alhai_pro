# Admin POS - Step 001: Project Foundation

> **المرحلة:** Phase 0 | **المدة:** أسبوعين | **الأولوية:** P0

---

## 🎯 الهدف

تجهيز أساس المشروع Multi-Tenant SaaS:
- Flutter + Riverpod + GoRouter (106 routes)
- Supabase مع RLS policies
- Responsive design system
- تكامل مع الحزم المشتركة

---

## 📋 المهام

### SETUP-001: Project setup (8h)

```bash
cd admin_pos
flutter pub get

flutter pub add riverpod flutter_riverpod
flutter pub add go_router
flutter pub add shared_preferences flutter_secure_storage
```

**الـ 106 routes:**
```dart
class AppRoutes {
  // Auth (6)
  static const splash = '/splash';
  static const onboarding = '/onboarding';
  static const login = '/login';
  static const signup = '/signup';
  // ... 100+ more
}
```

### SETUP-002: Multi-Tenant Models (10h)

**النماذج الجديدة:**
- `Owner` - صاحب البقالة
- `Subscription` - الاشتراك
- `StoreTransfer` - نقل المخزون
- `StaffTransfer` - نقل الموظفين

### SETUP-003: RLS Policies (12h)

```sql
-- Owner Isolation
CREATE POLICY "owner_access" ON stores
FOR ALL USING (owner_id = auth.uid());

-- Store Scope for Managers
CREATE POLICY "manager_access" ON products
FOR ALL USING (store_id IN (
  SELECT store_id FROM staff WHERE user_id = auth.uid()
));
```

### SETUP-004: Shared Packages (8h)

```yaml
dependencies:
  alhai_core:
    path: ../alhai_core
  alhai_services:
    path: ../alhai_services
  alhai_design_system:
    path: ../alhai_design_system
```

### SETUP-005: Responsive Design (10h)

```dart
// Mobile (<600px): Bottom nav
// Tablet (600-1200px): Side nav
// Desktop (>1200px): Persistent sidebar
```

---

## ✅ معايير الإنجاز

- [ ] `flutter run` على mobile/web/desktop
- [ ] RLS policies تعمل
- [ ] Supabase متصل
- [ ] Responsive layout يعمل

---

## 📚 المراجع

- [PROD.json](../PROD.json) - SETUP-001 to SETUP-005
- [ADMIN_POS_SPEC.md](../ADMIN_POS_SPEC.md) - RLS Strategy
