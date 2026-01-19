# Alhai POS Team Workflow

## Branch Naming Convention

```
main                        # Production-ready code
└── develop                 # Integration branch
     ├── pos/sales           # Device A integration (Sales Slice)
     │    ├── feat-login
     │    ├── feat-cart
     │    └── fix-payment
     ├── pos/operations      # Device B integration (Operations Slice)
     │    ├── feat-inventory
     │    └── feat-products
     └── shared/xxx          # Shared features (يتطلب تنسيق A+B)
```

### قواعد الفروع:
- `pos/sales` و `pos/operations`: فروع integration لكل جهاز
- الفروع اليومية تكون دائمًا تحت `pos/sales/*` أو `pos/operations/*` أو `shared/*`
- `shared/xxx`: يتطلب تنسيق بين A+B قبل البدء

### Examples:
- `pos/sales/feat-login`
- `pos/sales/fix-cart-calculation`
- `pos/operations/feat-inventory-adjust`
- `shared/app-session`

---

## Commit Message Convention

```
<type>(<scope>): <description>

[optional body]
```

### Types:
| Type | Description |
|------|-------------|
| `feat` | New feature |
| `fix` | Bug fix |
| `refactor` | Code restructure |
| `style` | UI/formatting changes |
| `docs` | Documentation |
| `test` | Adding tests |
| `chore` | Build/config changes |

### Examples:
```
feat(sales): add barcode scanner to quick sale screen
fix(cart): correct tax calculation for discount items
refactor(auth): extract OTP validation to separate bloc
```

---

## Definition of Done (DoD)

A feature is **DONE** when:

- [ ] Code compiles without errors
- [ ] `flutter analyze` passes with no issues
- [ ] Related tests pass
- [ ] Code reviewed by peer (if pair working)
- [ ] Screen matches expected flow in POS_FLOW_SPEC.md
- [ ] No hardcoded strings (use localization)
- [ ] RTL layout verified

---

## Merge Rules

### Daily Workflow:
1. Start day:
   ```bash
   git checkout pos/sales && git pull origin pos/sales      # أو pos/operations
   git checkout pos/sales/feat-xxx && git rebase pos/sales  # تحديث فرعك الشخصي
   ```
2. Work on your feature branch
3. End day: commit + push to your branch

### Merge to Develop:
- **When**: Feature/screen complete + DoD met
- **How**: Pull Request → Self-review → Merge
- **After merge**: Delete feature branch

### Merge to Main:
- **When**: End of sprint/milestone
- **Who**: Lead developer decision
- **Requires**: All tests pass

---

## Rebase vs Merge

| Situation | Use | ملاحظة |
|-----------|-----|------|
| تحديث فرعك الشخصي من pos/sales | `git rebase pos/sales` | آمن |
| تحديث فرعك الشخصي من develop | `git rebase develop` | آمن (إذا احتجت آخر تغييرات) |
| تحديث pos/sales من develop | `git merge develop` | **لا rebase** |
| تحديث pos/operations من develop | `git merge develop` | **لا rebase** |
| دمج فرعك إلى pos/sales | **PR (self-review) + `merge --no-ff`** | |
| دمج فرعك إلى pos/operations | **PR (self-review) + `merge --no-ff`** | |
| دمج pos/sales إلى develop | **PR + `merge --no-ff`** | |
| دمج pos/operations إلى develop | **PR + `merge --no-ff`** | |

> ⚠️ **لا تستخدم rebase على فروع مشتركة أو تم دفعها**

---

## Slice Ownership (A/B Split)

### Device A (Sales Slice) - لا يعدل ملفات B
- `lib/features/auth/`
- `lib/features/sales/`
- `lib/features/cart/`
- `lib/features/payment/`

### Device B (Operations Slice) - لا يعدل ملفات A
- `lib/features/products/`
- `lib/features/inventory/`
- `lib/features/suppliers/`
- `lib/features/reports/`

### Shared (Both can read, coordinate before edit)
- `lib/core/` (app-level configs)
- `lib/shared/` (shared widgets)

---

## Conflict Prevention

1. **Before editing shared file**: Announce in chat
2. **Daily sync**: 5-minute call to sync progress
3. **End of day**: Push all changes

> 📝 **تعريف "التنسيق"**: رسالة في قناة الفريق + انتظار رد OK قبل البدء

---

## PR Path Validation (قواعد منع التعارض)

> **لا PR يُدمج على develop إذا عدّل مسارات ليست ضمن slice**

### Device A Allowed Paths
```
lib/features/auth/**
lib/features/store_select/**
lib/features/sales/**
lib/features/cart/**
lib/features/payment/**
lib/features/splash/**
lib/features/home/**     ← يُنشئ، وB يقرأ فقط
```

### Device B Allowed Paths
```
lib/features/products/**
lib/features/inventory/**
lib/features/suppliers/**
lib/features/reports/**
lib/features/settings/**
```

### Shared Paths (يتطلب تنسيق)
```
lib/core/**
lib/shared/**
pubspec.yaml
analysis_options.yaml
```

### PR Checklist (مراجعة يدوية حتى نضيف CI)
- [ ] All modified files are within my slice
- [ ] If editing shared paths, I coordinated with the other device
- [ ] `flutter analyze` passes
- [ ] Related tests pass

---

## Decision Ownership

| Decision | Owner |
|----------|-------|
| API Contract changes | Requires both A+B agreement |
| alhai_core changes | Requires both A+B agreement |
| Design System changes | Requires both A+B agreement |
| Feature implementation | Slice owner decides |
| UI details | Slice owner decides |

---

*Last Updated: 2026-01-19*
