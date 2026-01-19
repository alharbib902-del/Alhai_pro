# Alhai Platform Team Workflow

**Version:** 2.0.0  
**Date:** 2026-01-19

---

## تقسيم العمل (App-Based Split)

```
┌─────────────────────────────────────────────────────────┐
│                   Alhai Platform                         │
├─────────────────────────┬───────────────────────────────┤
│       Device A          │          Device B             │
│       POS App           │        Customer App           │
├─────────────────────────┼───────────────────────────────┤
│ • نظام نقطة البيع       │ • تطبيق طلبات العملاء          │
│ • إدارة المخزون         │ • عرض المنتجات والعروض         │
│ • التقارير اليومية       │ • سلة الشراء                  │
│ • المبيعات والفواتير     │ • تتبع الطلبات                │
│ • إدارة الموردين         │ • ملف العميل                  │
└─────────────────────────┴───────────────────────────────┘
                    ↓
         ┌─────────────────────┐
         │   Shared Libraries   │
         │ • alhai_core         │
         │ • alhai_design_system│
         └─────────────────────┘
```

---

## Branch Naming Convention

```
main                        # Production-ready code
└── develop                 # Integration branch
     ├── pos/*              # Device A (POS App)
     │    ├── feat-login
     │    ├── feat-cart
     │    └── fix-payment
     ├── customer/*         # Device B (Customer App)
     │    ├── feat-catalog
     │    └── feat-orders
     └── shared/*           # Shared libraries (يتطلب تنسيق A+B)
```

### قواعد الفروع:
- `pos/*`: فروع خاصة بتطبيق POS (Device A فقط)
- `customer/*`: فروع خاصة بتطبيق العملاء (Device B فقط)
- `shared/*`: يتطلب تنسيق بين A+B قبل البدء

### Examples:
- `pos/feat-login`
- `pos/fix-cart-calculation`
- `customer/feat-product-catalog`
- `customer/feat-order-tracking`
- `shared/core-auth-update`

---

## File Ownership

### Device A Owns (POS App)
```
pos_app/                    ← A owns exclusively
├── lib/
├── test/
├── pubspec.yaml
└── ...
```

### Device B Owns (Customer App)
```
customer_app/               ← B owns exclusively
├── lib/
├── test/
├── pubspec.yaml
└── ...
```

### Shared (Coordinate Before Edit!)
```
alhai_core/                 ← تنسيق مطلوب
alhai_design_system/        ← تنسيق مطلوب
docs/                       ← تنسيق مطلوب
```

> ⚠️ **قاعدة ذهبية**: لا يعدل Device A على `customer_app/` ولا يعدل Device B على `pos_app/`

---

## Commit Message Convention

```
<type>(<app>): <description>

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

### App Scopes:
| Scope | App |
|-------|-----|
| `pos` | POS App (Device A) |
| `customer` | Customer App (Device B) |
| `core` | alhai_core (Shared) |
| `design` | alhai_design_system (Shared) |

### Examples:
```
feat(pos): add barcode scanner to quick sale screen
fix(customer): correct cart total calculation
feat(core): add new ProductStatus enum
refactor(design): extract button styles to theme
```

---

## Definition of Done (DoD)

A feature is **DONE** when:

- [ ] Code compiles without errors
- [ ] `flutter analyze` passes with no issues
- [ ] Related tests pass
- [ ] Screen matches expected flow in specs
- [ ] No hardcoded strings (use localization)
- [ ] RTL layout verified

---

## Merge Rules

### Daily Workflow:
1. Start day:
   ```bash
   git checkout develop && git pull origin develop
   git checkout pos/feat-xxx && git rebase develop  # Device A
   # أو
   git checkout customer/feat-xxx && git rebase develop  # Device B
   ```
2. Work on your feature branch
3. End day: commit + push to your branch

### Merge to Develop:
- **When**: Feature complete + DoD met
- **How**: Pull Request → Self-review → Merge
- **After merge**: Delete feature branch

### Merge to Main:
- **When**: End of sprint/milestone
- **Who**: Lead developer decision
- **Requires**: All tests pass

---

## Rebase vs Merge

| Situation | Use | ملاحظة |
|-----------|-----|--------|
| تحديث فرعك الشخصي من develop | `git rebase develop` | آمن |
| دمج فرعك إلى develop | **PR + `merge --no-ff`** | |
| دمج develop إلى main | **PR + `merge --no-ff`** | |

> ⚠️ **لا تستخدم rebase على فروع مشتركة أو تم دفعها**

---

## Shared Libraries Protocol

عند الحاجة لتعديل `alhai_core` أو `alhai_design_system`:

### 1. إعلان النية
```
📢 "أحتاج إضافة X إلى alhai_core - هل عندك تعديلات قيد العمل؟"
```

### 2. انتظار التأكيد
```
✅ "واضح، تفضل"
```

### 3. العمل على فرع shared
```bash
git checkout -b shared/core-add-feature
# ... work ...
git push origin shared/core-add-feature
```

### 4. إبلاغ الطرف الآخر بعد الدمج
```
📢 "تم دمج التحديث - يرجى عمل git pull قبل المتابعة"
```

---

## Conflict Prevention Checklist

Before each commit:
- [ ] Am I only editing files in my app folder?
- [ ] If editing shared libraries, did I coordinate?
- [ ] Does my code compile?
- [ ] Are my tests passing?

---

## Decision Ownership

| Decision | Owner |
|----------|-------|
| POS App features & UI | Device A |
| Customer App features & UI | Device B |
| alhai_core changes | Requires A+B agreement |
| alhai_design_system changes | Requires A+B agreement |
| API Contract changes | Requires A+B agreement |

---

*Last Updated: 2026-01-19*
