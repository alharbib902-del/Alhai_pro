# Super Admin - Step 001: Foundation

> **المرحلة:** Phase 0-1 | **المدة:** أسبوعين | **الأولوية:** P0

---

## 🎯 الهدف

تجهيز أساس God Mode Dashboard:
- Flutter Web only
- Super Admin RLS policies
- Role-based access control
- Audit logging

---

## 📋 المهام

### SETUP-001: Project setup (8h)

```bash
cd super_admin
flutter pub get

flutter pub add flutter_riverpod go_router
flutter pub add fl_chart  # Charts
flutter pub add data_table_2  # Tables
```

### SETUP-002: Super Admin RLS (8h)

```sql
-- Super Admin can see everything
CREATE POLICY "super_admin_access" ON ALL TABLES
FOR ALL USING (
  EXISTS (
    SELECT 1 FROM super_admins
    WHERE user_id = auth.uid()
  )
);
```

### SETUP-003: Role-based Access (8h)

```dart
enum AdminLevel {
  OWNER,          // Level 1 - Everything
  TECH_LEAD,      // Level 2 - System only
  SUPPORT_MGR,    // Level 3 - Tickets only
  FINANCE_MGR,    // Level 4 - Finance only
}
```

### SETUP-004: Audit Logging (8h)

```dart
// Every action logged
await auditLog.create({
  'action': 'IMPERSONATE',
  'admin_id': currentAdminId,
  'target_user_id': userId,
  'timestamp': DateTime.now(),
  'reason': 'Support ticket #12345',
});
```

---

## ✅ معايير الإنجاز

- [ ] `flutter run -d chrome` يعمل
- [ ] RLS policies تعمل
- [ ] Role-based access
- [ ] Audit logging

---

## 📚 المراجع

- [PROD.json](../PROD.json) - SETUP-*
- [SUPER_ADMIN_VISION.md](../SUPER_ADMIN_VISION.md) - Security
