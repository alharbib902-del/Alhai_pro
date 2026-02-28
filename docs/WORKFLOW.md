# Alhai Platform Team Workflow

**Version:** 2.2.0  
**Date:** 2026-01-19

---

> [!CAUTION]
> **ممنوع استخدام Google Drive أو Dropbox أو أي Sync Tool لمزامنة الكود.**  
> **Git (GitHub) هو المصدر الوحيد للكود.**  
> أي تعديل خارج Git = تضارب وفقدان عمل.

---

## هيكلة المشروع (Repo Structure)

```
alhai-platform/                 ← GitHub Repo (Private)
├── apps/
│   ├── cashier/                ← Device A يملك
│   └── customer_app/           ← Device B يملك
├── packages/
│   ├── alhai_core/             ← مشترك (تنسيق مطلوب)
│   └── alhai_design_system/    ← مشترك (تنسيق مطلوب)
└── docs/
    ├── WORKFLOW.md             ← أنت هنا
    ├── POS_FLOW_SPEC.md
    └── ...
```

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
cashier/                    ← A owns exclusively
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

> ⚠️ **قاعدة ذهبية**: لا يعدل Device A على `customer_app/` ولا يعدل Device B على `cashier/`

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

## 🚀 Git Quick Start (للمبتدئين)

> إذا هذه أول مرة تستخدم Git، اتبع هذه الخطوات:

### الإعداد (مرة واحدة فقط)

```bash
# 1. تثبيت Git
# حمّل من: https://git-scm.com/downloads

# 2. إعداد الاسم والإيميل
git config --global user.name "اسمك"
git config --global user.email "email@example.com"

# 3. استنساخ المشروع
# (استبدل <org> باسم المؤسسة الفعلي)
git clone https://github.com/<org>/alhai-platform.git
cd alhai-platform
```

### العمل اليومي (10 خطوات)

```bash
# === بداية اليوم ===
# 1. اسحب آخر التحديثات (دائمًا من develop)
git checkout develop
git pull origin develop

# 2. أنشئ فرع جديد لعملك
git checkout -b pos/feat-my-feature    # Device A
# أو
git checkout -b customer/feat-my-feature  # Device B

# === أثناء العمل ===
# 3. اعمل على الكود...

# 4. شوف التغييرات
git status

# 5. أضف التغييرات
git add .

# 6. احفظ (commit)
git commit -m "feat(pos): add my new feature"

# === نهاية اليوم ===
# 7. ارفع التغييرات
git push origin pos/feat-my-feature

# === عند الانتهاء من الميزة ===
# 8. افتح Pull Request على GitHub
# 9. راجع وادمج (Merge)
# 10. احذف الفرع
git branch -d pos/feat-my-feature
```

### أوامر مفيدة

| الأمر | الوظيفة |
|-------|---------|
| `git status` | عرض الملفات المتغيرة |
| `git log --oneline -5` | آخر 5 commits |
| `git diff` | عرض التغييرات |
| `git stash` | حفظ مؤقت (بدون commit) |
| `git stash pop` | استرجاع المحفوظ مؤقتًا |

> [!WARNING]
> **لا تعمل أبدًا `git push` على `main` أو `develop` مباشرة**  
> كل العمل يتم عبر feature branches + Pull Request.

---

## 📦 ملاحظة للتوسع المستقبلي

> نستخدم **Melos** لإدارة Flutter Monorepo (مرحلة لاحقة)  
> التفاصيل: https://melos.invertase.dev

---

*Last Updated: 2026-01-19*

