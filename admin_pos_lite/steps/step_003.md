# Admin POS Lite - Step 003: Alerts + Quick Actions

> **المرحلة:** Phase 3 | **المدة:** أسبوعين | **الأولوية:** P0

---

## 🎯 الهدف

إنشاء نظام التنبيهات والموافقات السريعة:
- Alerts بالأولوية (🔴🟠🟡)
- Quick Approvals مع Swipe
- One-tap actions

---

## 📋 المهام

### ALERT-001: Alerts List (8h)

**Route:** `/alerts`

**الترتيب بالأولوية:**
```
├── 🔴 Critical (3)
│   └── Stock نفذ - حليب نادك
├── 🟠 Important (5)
│   └── Debt overdue 60 days
└── 🟡 Info (2)
    └── New customer
```

### ALERT-003: Quick Approvals (10h)

**Route:** `/approvals`

**Swipe Gestures:**
```dart
Dismissible(
  background: Container(color: Colors.green),  // Approve
  secondaryBackground: Container(color: Colors.red),  // Reject
  onDismissed: (direction) {
    if (direction == DismissDirection.startToEnd) {
      quickApprove(approval.id);
    } else {
      quickReject(approval.id);
    }
  },
  child: ApprovalCard(approval: approval),
)
```

### One-tap actions:

```dart
Future<void> quickApprove(String id) async {
  // Optimistic update
  _updateLocalState(id, ApprovalStatus.APPROVED);
  
  try {
    await _repository.approve(id);
    _showSuccess('تمت الموافقة');
  } catch (e) {
    _revertLocalState(id);
    _showError('فشل الموافقة');
  }
}
```

---

## ✅ معايير الإنجاز

- [ ] Alerts مرتبة بالأولوية
- [ ] Swipe للموافقة/الرفض يعمل
- [ ] Badge count صحيح
- [ ] Push notifications

---

## 📚 المراجع

- [PROD.json](../PROD.json) - ALERT-*
- [ADMIN_LITE_SPEC.md](../ADMIN_LITE_SPEC.md) - Quick Actions
