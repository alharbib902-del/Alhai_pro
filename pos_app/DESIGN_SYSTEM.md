# 🎨 ALHAI POS - Design System v2.0

> **تاريخ:** 2026-02-02 | **الحالة:** معتمد | **الإصدار:** 2.0

---

## 📋 جدول المحتويات

1. [المبادئ الأساسية](#المبادئ-الأساسية)
2. [Design Tokens](#design-tokens)
3. [الألوان](#الألوان)
4. [Typography](#typography)
5. [Spacing & Layout](#spacing--layout)
6. [Components](#components)
7. [Patterns](#patterns)
8. [Icons](#icons)
9. [Motion](#motion)
10. [Accessibility](#accessibility)
11. [Split Payment Components](#split-payment-components) ⭐ NEW
12. [Loyalty Program Components](#loyalty-program-components) ⭐ NEW
13. [Multi-Branch Components](#multi-branch-components) ⭐ NEW
14. [Debt Reminder Components](#debt-reminder-components) ⭐ NEW

---

# 1️⃣ المبادئ الأساسية

## الفلسفة

```
┌─────────────────────────────────────────────────────────────────┐
│                                                                 │
│   🧹 بسيط        لا فوضى، كل عنصر له سبب                       │
│   ⚡ سريع        أقل توقفات، أقل قرارات                         │
│   💪 موثوق       يعطي إحساس بالأمان والثقة                      │
│   🤝 ودود        ليس رسمي جداً، قريب من المستخدم                │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

## مقاييس النجاح

| المقياس | الهدف | الطريقة |
|---------|-------|---------|
| **Stop Count** | 0-1 لكل Flow أساسي | عدد المرات التي يُجبر المستخدم على التوقف والتفكير |
| **Click Count** | حسب الجدول أدناه | عدد النقرات لإتمام المهمة |
| **Time to Complete** | أقل وقت ممكن | الوقت من البداية للنهاية |

### أهداف النقرات للـ Flows الأساسية

| Flow | الحالي | الهدف |
|------|--------|-------|
| بيع (باركود) | 4 | **2** |
| بيع (بحث) | 5 | **3** |
| دفع نقد | 3 | **2** |
| دفع آجل | 6 | **3** |
| طباعة | 2 | **1** (تلقائي) |
| استلام بضاعة | 15+ | **8** |

---

# 2️⃣ Design Tokens

## المتغيرات الأساسية

```scss
// ============================================
// SPACING
// ============================================
$space-0: 0;
$space-1: 4px;    // Micro spacing
$space-2: 8px;    // Tight spacing
$space-3: 12px;   // Compact spacing
$space-4: 16px;   // Default spacing
$space-5: 20px;   // Comfortable spacing
$space-6: 24px;   // Relaxed spacing
$space-8: 32px;   // Section spacing
$space-10: 40px;  // Large section
$space-12: 48px;  // Page padding
$space-16: 64px;  // Hero spacing

// ============================================
// BORDER RADIUS
// ============================================
$radius-none: 0;
$radius-sm: 4px;    // Subtle rounding
$radius-md: 8px;    // Default (buttons, cards)
$radius-lg: 12px;   // Prominent (modals, panels)
$radius-xl: 16px;   // Large cards
$radius-full: 9999px; // Pills, avatars

// ============================================
// SHADOWS
// ============================================
$shadow-none: none;
$shadow-sm: 0 1px 2px rgba(0, 0, 0, 0.05);
$shadow-md: 0 4px 6px rgba(0, 0, 0, 0.07);
$shadow-lg: 0 10px 15px rgba(0, 0, 0, 0.1);
$shadow-xl: 0 20px 25px rgba(0, 0, 0, 0.15);

// Dark mode shadows (with glow)
$shadow-md-dark: 0 4px 6px rgba(0, 0, 0, 0.25);
$shadow-lg-dark: 0 10px 15px rgba(0, 0, 0, 0.35);

// ============================================
// TRANSITIONS
// ============================================
$duration-fast: 100ms;
$duration-normal: 200ms;
$duration-slow: 300ms;
$duration-slower: 500ms;

$ease-default: cubic-bezier(0.4, 0, 0.2, 1);
$ease-in: cubic-bezier(0.4, 0, 1, 1);
$ease-out: cubic-bezier(0, 0, 0.2, 1);
$ease-bounce: cubic-bezier(0.34, 1.56, 0.64, 1);

// ============================================
// Z-INDEX
// ============================================
$z-base: 0;
$z-dropdown: 100;
$z-sticky: 200;
$z-fixed: 300;
$z-modal-backdrop: 400;
$z-modal: 500;
$z-popover: 600;
$z-tooltip: 700;
$z-toast: 800;
```

---

# 3️⃣ الألوان

## 3.1 Brand Colors

```scss
// ============================================
// PRIMARY - الأخضر الطازج (Fresh Grocery)
// ============================================
$primary-50:  #ECFDF5;  // خلفية فاتحة جداً
$primary-100: #D1FAE5;  // hover على الفاتح
$primary-200: #A7F3D0;  // borders فاتحة
$primary-300: #6EE7B7;  // disabled state
$primary-400: #34D399;  // hover على الأساسي
$primary-500: #10B981;  // ✅ اللون الأساسي (Brand)
$primary-600: #059669;  // pressed state
$primary-700: #047857;  // نص على خلفية فاتحة
$primary-800: #065F46;  // داكن
$primary-900: #064E3B;  // أغمق

// ============================================
// SECONDARY - البرتقالي (العروض والإيجابية)
// ============================================
$secondary-50:  #FFF7ED;
$secondary-100: #FFEDD5;
$secondary-500: #F97316;  // ✅ اللون الثانوي
$secondary-600: #EA580C;
$secondary-700: #C2410C;
```

## 3.2 Semantic Colors (الألوان الوظيفية)

```scss
// ============================================
// ⚠️ مهم: هذه الألوان للحالات فقط، ليس للـ Brand
// ============================================

// ✅ SUCCESS - تم بنجاح، متوفر، مكتمل
$success-50:  #F0FDF4;
$success-100: #DCFCE7;
$success-500: #22C55E;  // ✅ مختلف عن Primary!
$success-600: #16A34A;
$success-700: #15803D;

// ⚠️ WARNING - مخزون منخفض، انتبه، قيد المعالجة
$warning-50:  #FFFBEB;
$warning-100: #FEF3C7;
$warning-500: #F59E0B;
$warning-600: #D97706;
$warning-700: #B45309;

// ❌ DANGER - خطأ، حذف، دين، نفذ
$danger-50:  #FEF2F2;
$danger-100: #FEE2E2;
$danger-500: #EF4444;
$danger-600: #DC2626;
$danger-700: #B91C1C;

// ℹ️ INFO - معلومة، رابط ثانوي
$info-50:  #EFF6FF;
$info-100: #DBEAFE;
$info-500: #3B82F6;
$info-600: #2563EB;
$info-700: #1D4ED8;
```

## 3.3 Neutral Colors (الرمادي)

```scss
// ============================================
// GRAY - للنصوص والخلفيات والحدود
// ============================================
$gray-50:  #F9FAFB;  // خلفية الصفحة (Light)
$gray-100: #F3F4F6;  // خلفية ثانوية
$gray-200: #E5E7EB;  // حدود فاتحة
$gray-300: #D1D5DB;  // حدود عادية
$gray-400: #9CA3AF;  // نص placeholder
$gray-500: #6B7280;  // نص ثانوي
$gray-600: #4B5563;  // نص عادي (Light mode)
$gray-700: #374151;  // نص أساسي (Light mode)
$gray-800: #1F2937;  // خلفية (Dark mode)
$gray-900: #111827;  // خلفية الصفحة (Dark)
$gray-950: #030712;  // أغمق
```

## 3.4 Payment Method Colors

```scss
// ألوان طرق الدفع (ثابتة)
$payment-cash:    #22C55E;  // 💵 نقد - أخضر
$payment-card:    #3B82F6;  // 💳 بطاقة - أزرق
$payment-credit:  #EF4444;  // 📋 آجل/دين - أحمر
$payment-online:  #8B5CF6;  // 📱 أونلاين - بنفسجي
$payment-transfer:#14B8A6;  // 🏦 تحويل - تركواز
```

## 3.5 Category Colors (Soft/Muted)

```scss
// ⚠️ مهم: هذه ألوان النقطة/الأيقونة فقط، ليس الخلفية الكاملة
$category-fruits:     #F97316;  // 🍊 فواكه
$category-vegetables: #22C55E;  // 🥬 خضروات
$category-dairy:      #3B82F6;  // 🥛 ألبان
$category-meat:       #EF4444;  // 🍖 لحوم
$category-bakery:     #F59E0B;  // 🍞 مخبوزات
$category-drinks:     #06B6D4;  // 🥤 مشروبات
$category-snacks:     #8B5CF6;  // 🍿 سناكس
$category-cleaning:   #14B8A6;  // 🧹 تنظيف
$category-other:      #6B7280;  // 📦 أخرى

// طريقة الاستخدام الصحيحة:
// ┌────────────────────────────────────┐
// │  ● ألبان                           │  ← نقطة ملونة + نص رمادي
// │  ⬜ background: gray-100           │  ← خلفية محايدة
// └────────────────────────────────────┘
```

## 3.6 Stock Status Colors

```scss
// حالة المخزون
$stock-available: #22C55E;  // ✅ متوفر (>30% من الحد)
$stock-low:       #F59E0B;  // ⚠️ منخفض (<الحد الأدنى)
$stock-critical:  #EF4444;  // 🔴 حرج (<30% من الحد)
$stock-out:       #6B7280;  // ❌ نفذ (0)
```

## 3.7 Dark Mode Adaptations

```scss
// ============================================
// LIGHT MODE (الافتراضي)
// ============================================
:root {
  --bg-primary:    #{$gray-50};
  --bg-secondary:  #FFFFFF;
  --bg-tertiary:   #{$gray-100};
  --text-primary:  #{$gray-900};
  --text-secondary:#{$gray-600};
  --text-muted:    #{$gray-500};
  --border:        #{$gray-200};
  --border-focus:  #{$primary-500};
}

// ============================================
// DARK MODE
// ============================================
[data-theme="dark"] {
  --bg-primary:    #{$gray-900};
  --bg-secondary:  #{$gray-800};
  --bg-tertiary:   #{$gray-700};
  --text-primary:  #{$gray-50};
  --text-secondary:#{$gray-400};
  --text-muted:    #{$gray-500};
  --border:        #{$gray-700};
  --border-focus:  #{$primary-400};

  // ⚠️ الألوان الوظيفية في الداكن:
  // استخدم overlay شفاف بدل الألوان الفاتحة
  --success-surface: rgba(34, 197, 94, 0.12);
  --warning-surface: rgba(245, 158, 11, 0.12);
  --danger-surface:  rgba(239, 68, 68, 0.12);
  --info-surface:    rgba(59, 130, 246, 0.12);
}
```

## 3.8 قواعد استخدام الألوان

### ✅ استخدم

| اللون | متى تستخدمه |
|-------|-------------|
| **Primary** | الأزرار الرئيسية، الروابط، العناصر النشطة، Brand |
| **Success** | رسائل "تم بنجاح"، حالة "متوفر"، "مكتمل" |
| **Warning** | تحذيرات غير حرجة، "مخزون منخفض"، "انتبه" |
| **Danger** | أخطاء، حذف، "دين"، "نفذ"، إجراءات خطرة |
| **Info** | معلومات إضافية، روابط ثانوية |
| **Gray** | نصوص، خلفيات، حدود، عناصر محايدة |

### ❌ لا تستخدم

| الخطأ | الصواب |
|-------|--------|
| Success للأزرار الأساسية | Primary للأزرار الأساسية |
| Danger لكل شيء سلبي | Danger فقط للإجراءات الخطرة |
| ألوان التصنيف كخلفية كاملة | نقطة ملونة + خلفية محايدة |
| نص ملون على خلفية ملونة | تأكد من تباين 7:1 |

### قاعدة التباين

```scss
// الحد الأدنى للتباين: 7:1 للنص العادي، 4.5:1 للنص الكبير

// ✅ صحيح
.light-bg { background: $gray-50;  color: $gray-900; }  // 15.8:1
.dark-bg  { background: $gray-900; color: $gray-50;  }  // 15.8:1

// ❌ خطأ - تباين ضعيف
.primary-surface {
  background: $primary-50;
  // color: $primary-500;  // ❌ 3.2:1 - ضعيف!
  color: $primary-900;     // ✅ 7.5:1 - ممتاز
}
```

---

# 4️⃣ Typography

## 4.1 Font Family

```scss
// ============================================
// FONTS
// ============================================

// العربية (الأساسي)
$font-arabic: 'Tajawal', 'Noto Sans Arabic', sans-serif;

// الإنجليزية
$font-english: 'Inter', 'Roboto', sans-serif;

// Monospace (للأرقام والأكواد)
$font-mono: 'JetBrains Mono', 'Fira Code', monospace;

// الاستخدام
body {
  font-family: $font-arabic;
  &[lang="en"] { font-family: $font-english; }
}

// الأرقام في الفواتير
.receipt-number { font-family: $font-mono; }
```

## 4.2 Font Sizes

```scss
// ============================================
// TYPE SCALE (1.25 ratio)
// ============================================
$text-xs:   12px;   // التفاصيل الصغيرة، التواريخ
$text-sm:   14px;   // النص الثانوي، الوصف
$text-base: 16px;   // النص العادي (الافتراضي)
$text-lg:   18px;   // النص المميز
$text-xl:   20px;   // العناوين الصغيرة
$text-2xl:  24px;   // العناوين المتوسطة
$text-3xl:  30px;   // العناوين الكبيرة
$text-4xl:  36px;   // العناوين الرئيسية
$text-5xl:  48px;   // الأرقام الكبيرة (Dashboard)

// Line Heights
$leading-tight:  1.25;
$leading-normal: 1.5;
$leading-relaxed: 1.75;
```

## 4.3 Font Weights

```scss
$font-normal:   400;  // النص العادي
$font-medium:   500;  // النص المميز قليلاً
$font-semibold: 600;  // العناوين الصغيرة
$font-bold:     700;  // العناوين، الأرقام المهمة
```

## 4.4 Text Styles (Pre-defined)

```scss
// Headings
.heading-1 { font-size: $text-4xl; font-weight: $font-bold; line-height: $leading-tight; }
.heading-2 { font-size: $text-3xl; font-weight: $font-bold; line-height: $leading-tight; }
.heading-3 { font-size: $text-2xl; font-weight: $font-semibold; line-height: $leading-tight; }
.heading-4 { font-size: $text-xl;  font-weight: $font-semibold; line-height: $leading-tight; }

// Body
.body-lg { font-size: $text-lg;   font-weight: $font-normal; line-height: $leading-normal; }
.body    { font-size: $text-base; font-weight: $font-normal; line-height: $leading-normal; }
.body-sm { font-size: $text-sm;   font-weight: $font-normal; line-height: $leading-normal; }

// Special
.price     { font-size: $text-xl;  font-weight: $font-bold; font-family: $font-mono; }
.price-lg  { font-size: $text-3xl; font-weight: $font-bold; font-family: $font-mono; }
.caption   { font-size: $text-xs;  font-weight: $font-normal; color: var(--text-muted); }
.label     { font-size: $text-sm;  font-weight: $font-medium; }
```

---

# 5️⃣ Spacing & Layout

## 5.1 Grid System

```scss
// ============================================
// BREAKPOINTS
// ============================================
$breakpoint-sm:  640px;   // Mobile landscape
$breakpoint-md:  768px;   // Tablet
$breakpoint-lg:  1024px;  // Desktop
$breakpoint-xl:  1280px;  // Large desktop
$breakpoint-2xl: 1536px;  // Extra large

// ============================================
// CONTAINER
// ============================================
.container {
  width: 100%;
  margin: 0 auto;
  padding: 0 $space-4;

  @media (min-width: $breakpoint-lg) {
    max-width: 1200px;
    padding: 0 $space-6;
  }
}
```

## 5.2 Layout Patterns

### Split View (POS)

```scss
// Layout: 70% Products | 30% Cart
.pos-layout {
  display: grid;
  grid-template-columns: 1fr 380px;
  gap: $space-4;
  height: calc(100vh - 64px); // minus TopBar

  @media (max-width: $breakpoint-lg) {
    grid-template-columns: 1fr;
    // Cart becomes bottom sheet
  }
}
```

### Sidebar Layout

```scss
.dashboard-layout {
  display: grid;
  grid-template-columns: 240px 1fr;

  @media (max-width: $breakpoint-md) {
    grid-template-columns: 1fr;
    // Sidebar becomes collapsible
  }
}
```

## 5.3 Spacing Guidelines

```
Page Padding:      $space-6 (24px)
Section Gap:       $space-8 (32px)
Card Padding:      $space-4 (16px)
List Item Gap:     $space-3 (12px)
Form Field Gap:    $space-4 (16px)
Button Padding:    $space-3 $space-4 (12px 16px)
Icon + Text Gap:   $space-2 (8px)
```

---

# 6️⃣ Components

## 6.1 Component Hierarchy

```
📁 components/
├── 📁 core/              # مكونات أساسية (لا تعتمد على business)
│   ├── Button/
│   ├── Input/
│   ├── Select/
│   ├── Checkbox/
│   ├── Radio/
│   ├── Switch/
│   ├── Card/
│   ├── Badge/
│   ├── Avatar/
│   ├── Dialog/
│   ├── Drawer/
│   ├── Toast/
│   ├── Tooltip/
│   ├── Dropdown/
│   ├── Table/
│   ├── Tabs/
│   ├── Pagination/
│   └── Skeleton/
│
├── 📁 layout/            # مكونات الهيكل
│   ├── Sidebar/
│   ├── TopBar/
│   ├── PageHeader/
│   ├── SplitView/
│   ├── BottomSheet/
│   └── EmptyState/
│
├── 📁 forms/             # مكونات الفورمات
│   ├── SearchInput/
│   ├── PriceInput/
│   ├── PhoneInput/
│   ├── QuantityInput/
│   ├── DatePicker/
│   └── FileUpload/
│
├── 📁 domain/            # مكونات خاصة بالـ Business
│   ├── pos/
│   │   ├── ProductCard/
│   │   ├── CartPanel/
│   │   ├── CartItem/
│   │   ├── PaymentSheet/
│   │   ├── ReceiptPreview/
│   │   └── BarcodeScanner/
│   ├── inventory/
│   │   ├── StockBadge/
│   │   ├── StockIndicator/
│   │   └── ExpiryAlert/
│   ├── customers/
│   │   ├── CustomerCard/
│   │   ├── BalanceIndicator/
│   │   └── TransactionItem/
│   └── orders/
│       ├── OrderCard/
│       ├── StatusBadge/
│       └── StatusFlow/
│
└── 📁 patterns/          # أنماط متكررة (تركيبات)
    ├── SearchPattern/
    ├── MasterDetailPattern/
    ├── WizardPattern/
    └── ConfirmationPattern/
```

## 6.2 Button

### Variants

```tsx
// Primary - الإجراء الأساسي
<Button variant="primary">إتمام البيع</Button>

// Secondary - إجراء ثانوي
<Button variant="secondary">إلغاء</Button>

// Outlined - إجراء بديل
<Button variant="outlined">عرض التفاصيل</Button>

// Ghost - إجراء خفيف
<Button variant="ghost">تخطي</Button>

// Danger - إجراء خطر
<Button variant="danger">حذف</Button>
```

### Sizes

```tsx
<Button size="sm">صغير</Button>   // 32px height
<Button size="md">متوسط</Button>  // 40px height (default)
<Button size="lg">كبير</Button>   // 48px height
<Button size="xl">أكبر</Button>   // 56px height
```

### States

```scss
.btn-primary {
  background: $primary-500;
  color: white;

  &:hover   { background: $primary-600; }
  &:active  { background: $primary-700; }
  &:focus   { box-shadow: 0 0 0 3px rgba($primary-500, 0.3); }
  &:disabled { background: $gray-300; cursor: not-allowed; }
}
```

## 6.3 Input

### Types

```tsx
<Input type="text" label="الاسم" />
<Input type="search" placeholder="ابحث..." />
<Input type="number" label="الكمية" />
<Input type="phone" label="الجوال" prefix="+966" />
<Input type="price" label="السعر" suffix="ر.س" />
```

### States

```scss
.input {
  border: 1px solid var(--border);

  &:focus   { border-color: var(--border-focus); box-shadow: 0 0 0 3px rgba($primary-500, 0.1); }
  &:invalid { border-color: $danger-500; }
  &:disabled { background: $gray-100; cursor: not-allowed; }
}
```

## 6.4 Card

### Types

```tsx
// Elevated - بظل (للـ Dashboard cards)
<Card variant="elevated">...</Card>

// Outlined - بحدود (للقوائم)
<Card variant="outlined">...</Card>

// Filled - بخلفية (للعناصر المختارة)
<Card variant="filled">...</Card>
```

## 6.5 Badge

### Semantic Badges

```tsx
<Badge variant="success">متوفر</Badge>
<Badge variant="warning">منخفض</Badge>
<Badge variant="danger">نفذ</Badge>
<Badge variant="info">جديد</Badge>
```

### Status Badges

```tsx
<StatusBadge status="pending">جديد</StatusBadge>      // 🟡
<StatusBadge status="processing">قيد التجهيز</StatusBadge> // 🟠
<StatusBadge status="ready">جاهز</StatusBadge>        // 🟢
<StatusBadge status="completed">مكتمل</StatusBadge>   // ✅
<StatusBadge status="cancelled">ملغي</StatusBadge>    // 🔴
```

### Stock Badges

```tsx
<StockBadge quantity={25} minStock={10} />  // ✅ متوفر (أخضر)
<StockBadge quantity={8} minStock={10} />   // ⚠️ منخفض (أصفر)
<StockBadge quantity={2} minStock={10} />   // 🔴 حرج (أحمر)
<StockBadge quantity={0} minStock={10} />   // ❌ نفذ (رمادي)
```

## 6.6 Dialog

### متى نستخدم Dialog vs Page

| الموقف | استخدم |
|--------|--------|
| إجراء سريع (< 3 حقول) | Dialog |
| تأكيد (نعم/لا) | Dialog |
| إجراء معقد (> 3 حقول) | Page |
| قائمة + تفاصيل | Page |
| خطوات متعددة (Wizard) | Page أو Drawer |

### Types

```tsx
// Confirmation - تأكيد
<Dialog.Confirm
  title="حذف المنتج؟"
  message="سيتم حذف المنتج نهائياً"
  confirmLabel="حذف"
  variant="danger"
/>

// Alert - تنبيه
<Dialog.Alert
  title="تم بنجاح!"
  message="تم حفظ المنتج"
  variant="success"
/>

// Form - نموذج صغير
<Dialog.Form title="إضافة عميل سريع">
  <Input label="الاسم" />
  <Input label="الجوال" />
</Dialog.Form>
```

## 6.7 Toast

```tsx
// Success
toast.success("تم حفظ الفاتورة");

// Warning
toast.warning("المخزون منخفض");

// Error
toast.error("فشل الاتصال بالطابعة");

// Info
toast.info("تم تحديث الأسعار");

// With Action
toast.error("فشل الطباعة", {
  action: { label: "إعادة المحاولة", onClick: () => retry() }
});
```

---

# 7️⃣ Patterns

## 7.1 Search Pattern

```tsx
// البحث الموحد - يُستخدم في كل مكان
<SearchPattern
  placeholder="ابحث بالاسم أو الباركود..."
  patterns={['*', '#', '@']}  // * جزئي، # ID، @ فئة
  onSearch={handleSearch}
  onSelect={handleSelect}
  enterToSelect  // Enter يختار أفضل تطابق
  showSuggestions // اقتراحات سريعة
/>
```

### سلوك البحث

```
1. المستخدم يكتب
2. Debounce 300ms
3. إظهار "أفضل تطابق" أولاً
4. Enter → يختار أفضل تطابق
5. ↑↓ → التنقل
6. Escape → إغلاق
```

### أنماط البحث

```
"حليب"     → بحث بالاسم
"*راعي"    → بحث جزئي (contains)
"#123"     → بحث بالـ ID
"@ألبان"   → فلترة بالفئة
"6281..."  → بحث بالباركود (تلقائي)
```

## 7.2 Master-Detail Pattern

```tsx
// قائمة + تفاصيل
<MasterDetailPattern
  list={<ProductList />}
  detail={<ProductDetail />}
  emptyState={<EmptyProducts />}
  ratio={[1, 2]}  // 33% / 67%
/>
```

## 7.3 Wizard Pattern

```tsx
// خطوات متعددة (مثل Import Invoice)
<WizardPattern
  steps={[
    { title: "التقاط الصورة", component: <CaptureStep /> },
    { title: "تحليل الفاتورة", component: <AnalyzeStep /> },
    { title: "المراجعة", component: <ReviewStep /> },
  ]}
  onComplete={handleComplete}
  allowSaveDraft  // حفظ كمسودة
/>
```

## 7.4 Confirmation Pattern

```tsx
// تأكيد إجراء خطر
<ConfirmationPattern
  trigger={<Button variant="danger">حذف</Button>}
  title="حذف المنتج؟"
  message="هذا الإجراء لا يمكن التراجع عنه"
  confirmLabel="نعم، احذف"
  cancelLabel="إلغاء"
  variant="danger"
  onConfirm={handleDelete}
/>
```

---

# 8️⃣ Icons

## 8.1 Icon Library

نستخدم **Lucide Icons** (مفتوح المصدر، 1000+ أيقونة)

```tsx
import { ShoppingCart, Package, Users, Settings } from 'lucide-react';

<ShoppingCart size={24} />
```

## 8.2 Icon Sizes

```scss
$icon-xs: 14px;  // داخل النص
$icon-sm: 16px;  // أزرار صغيرة
$icon-md: 20px;  // أزرار عادية (default)
$icon-lg: 24px;  // أزرار كبيرة
$icon-xl: 32px;  // عناوين
$icon-2xl: 48px; // Empty states
```

## 8.3 Icon + Text Spacing

```tsx
// الأيقونة قبل النص
<Button>
  <Icon className="ml-2" />  // في RTL: margin-left
  إضافة
</Button>

// الأيقونة بعد النص
<Button>
  المزيد
  <Icon className="mr-2" />  // في RTL: margin-right
</Button>
```

---

# 9️⃣ Motion

## 9.1 Principles

```
1. سريع: الـ UI يجب أن يستجيب فوراً
2. طبيعي: الحركة تتبع فيزياء واقعية
3. هادف: كل حركة لها سبب (feedback, attention, transition)
```

## 9.2 Durations

```scss
// Micro-interactions (buttons, toggles)
$duration-fast: 100ms;

// UI feedback (hover, focus)
$duration-normal: 200ms;

// Content transitions (pages, modals)
$duration-slow: 300ms;

// Complex animations (wizards, onboarding)
$duration-slower: 500ms;
```

## 9.3 Easing

```scss
// Default - لمعظم الحركات
$ease-default: cubic-bezier(0.4, 0, 0.2, 1);

// Entering - للعناصر الداخلة
$ease-out: cubic-bezier(0, 0, 0.2, 1);

// Exiting - للعناصر الخارجة
$ease-in: cubic-bezier(0.4, 0, 1, 1);

// Bouncy - للـ feedback الإيجابي
$ease-bounce: cubic-bezier(0.34, 1.56, 0.64, 1);
```

## 9.4 Common Animations

```scss
// Fade In
@keyframes fadeIn {
  from { opacity: 0; }
  to { opacity: 1; }
}

// Slide Up (for modals, toasts)
@keyframes slideUp {
  from { transform: translateY(16px); opacity: 0; }
  to { transform: translateY(0); opacity: 1; }
}

// Scale (for buttons on press)
@keyframes scaleDown {
  from { transform: scale(1); }
  to { transform: scale(0.98); }
}

// Shake (for errors)
@keyframes shake {
  0%, 100% { transform: translateX(0); }
  25% { transform: translateX(-4px); }
  75% { transform: translateX(4px); }
}
```

---

# 🔟 Accessibility

## 10.1 Focus Management

```scss
// Focus ring visible
*:focus-visible {
  outline: 2px solid var(--border-focus);
  outline-offset: 2px;
}

// Skip hidden focus (for mouse users)
*:focus:not(:focus-visible) {
  outline: none;
}
```

## 10.2 Color Contrast

```
• نص عادي: تباين 7:1 على الأقل
• نص كبير (>18px): تباين 4.5:1 على الأقل
• UI elements: تباين 3:1 على الأقل
```

## 10.3 Keyboard Navigation

```tsx
// كل العناصر التفاعلية يجب أن تكون قابلة للوصول بالـ Tab
<Button tabIndex={0}>...</Button>

// الـ Dialogs يجب أن تحبس الـ Focus
<Dialog trapFocus>...</Dialog>

// الاختصارات
F1  → البحث
F2  → الباركود
F12 → إتمام البيع
Escape → إغلاق/رجوع
Enter → تأكيد
```

## 10.4 Screen Readers

```tsx
// استخدم aria-labels للأيقونات
<Button aria-label="إضافة منتج">
  <PlusIcon />
</Button>

// استخدم aria-live للتنبيهات
<Toast aria-live="polite">تم الحفظ</Toast>

// استخدم role للعناصر المخصصة
<div role="alert">خطأ في الاتصال</div>
```

---

# 📌 ملخص القرارات السريعة

| السؤال | الجواب |
|--------|--------|
| Dialog أم Page؟ | < 3 حقول = Dialog |
| أي لون للأزرار الأساسية؟ | Primary دائماً |
| متى نستخدم Danger؟ | حذف، إلغاء، ديون |
| ألوان التصنيفات؟ | نقطة ملونة + خلفية محايدة |
| Dark Mode surfaces؟ | Overlay شفاف (12-16%) |
| Enter في البحث؟ | يختار أفضل تطابق |
| فشل الطباعة؟ | لا يوقف البيع |

---

**تم الاعتماد:** 2026-02-02

---

# 1️⃣1️⃣ Split Payment Components ⭐ NEW

## 11.1 Payment Method Card

```tsx
// بطاقة اختيار طريقة الدفع
interface PaymentMethodCardProps {
  method: 'cash' | 'card' | 'credit' | 'online' | 'transfer';
  amount: number;
  maxAmount: number;
  isActive: boolean;
  onAmountChange: (amount: number) => void;
}

<PaymentMethodCard
  method="cash"
  amount={150}
  maxAmount={500}
  isActive={true}
  onAmountChange={handleCashChange}
/>
```

### Visual Design

```scss
.payment-method-card {
  display: flex;
  flex-direction: column;
  padding: $space-4;
  border-radius: $radius-lg;
  border: 2px solid var(--border);
  transition: all $duration-normal $ease-default;

  &.active {
    border-color: $primary-500;
    background: $primary-50;
  }

  // أيقونات طرق الدفع
  .method-icon {
    width: 48px;
    height: 48px;
    border-radius: $radius-md;
    display: flex;
    align-items: center;
    justify-content: center;

    &.cash     { background: rgba($payment-cash, 0.1);    color: $payment-cash; }
    &.card     { background: rgba($payment-card, 0.1);    color: $payment-card; }
    &.credit   { background: rgba($payment-credit, 0.1);  color: $payment-credit; }
    &.online   { background: rgba($payment-online, 0.1);  color: $payment-online; }
    &.transfer { background: rgba($payment-transfer, 0.1);color: $payment-transfer; }
  }
}
```

## 11.2 Split Payment Summary

```tsx
// ملخص الدفع المقسم
<SplitPaymentSummary
  total={500}
  payments={[
    { method: 'cash', amount: 200, label: 'نقداً' },
    { method: 'card', amount: 150, label: 'بطاقة' },
    { method: 'credit', amount: 150, label: 'آجل' },
  ]}
  remaining={0}
/>
```

### Layout

```
┌──────────────────────────────────────────────────────────────┐
│                     💳 تقسيم الدفع                            │
├──────────────────────────────────────────────────────────────┤
│  ┌─────────┐  ┌─────────┐  ┌─────────┐                      │
│  │  💵     │  │  💳     │  │  📋     │                      │
│  │  نقداً  │  │  بطاقة  │  │  آجل    │                      │
│  │ 200 ر.س │  │ 150 ر.س │  │ 150 ر.س │                      │
│  └─────────┘  └─────────┘  └─────────┘                      │
│                                                              │
│  ┌──────────────────────────────────────────────────────┐   │
│  │ الإجمالي                              500.00 ر.س     │   │
│  │ المدفوع                               500.00 ر.س     │   │
│  │ المتبقي                               ✅ 0.00 ر.س    │   │
│  └──────────────────────────────────────────────────────┘   │
│                                                              │
│           [  ✅ تأكيد الدفع  ]    [  ❌ إلغاء  ]            │
└──────────────────────────────────────────────────────────────┘
```

## 11.3 Amount Input Slider

```tsx
// شريط تحديد المبلغ
<AmountSlider
  value={150}
  min={0}
  max={500}
  step={10}
  color="cash" // 'cash' | 'card' | 'credit'
  quickAmounts={[50, 100, 150, 200]}
  onChange={handleChange}
/>
```

### Visual

```scss
.amount-slider {
  // الشريط
  .slider-track {
    height: 8px;
    border-radius: $radius-full;
    background: $gray-200;

    .slider-fill {
      height: 100%;
      border-radius: inherit;
      background: var(--method-color);
    }
  }

  // أزرار سريعة
  .quick-amounts {
    display: flex;
    gap: $space-2;
    margin-top: $space-3;

    button {
      padding: $space-1 $space-3;
      border-radius: $radius-full;
      background: $gray-100;
      font-size: $text-sm;

      &:hover { background: $gray-200; }
      &.active { background: var(--method-color); color: white; }
    }
  }
}
```

## 11.4 Payment Progress Bar

```tsx
// شريط تقدم الدفع (يظهر التقسيم بصرياً)
<PaymentProgressBar
  payments={[
    { method: 'cash', amount: 200, percentage: 40 },
    { method: 'card', amount: 150, percentage: 30 },
    { method: 'credit', amount: 150, percentage: 30 },
  ]}
  total={500}
/>
```

### Visual

```
┌─────────────────────────────────────────────────────────────┐
│ 💵 40%          │ 💳 30%         │ 📋 30%                   │
│ ████████████████│▓▓▓▓▓▓▓▓▓▓▓▓▓▓│░░░░░░░░░░░░░░░░░░░░░░░░│
│     نقد         │     بطاقة     │     آجل                  │
└─────────────────────────────────────────────────────────────┘
```

---

# 1️⃣2️⃣ Loyalty Program Components ⭐ NEW

## 12.1 Loyalty Tier Badge

```tsx
// شارة مستوى الولاء
interface LoyaltyTierBadgeProps {
  tier: 'bronze' | 'silver' | 'gold' | 'diamond';
  points: number;
  nextTierPoints?: number;
  size?: 'sm' | 'md' | 'lg';
}

<LoyaltyTierBadge tier="gold" points={2500} nextTierPoints={5000} />
```

### Tier Colors

```scss
// ألوان مستويات الولاء
$loyalty-bronze:  #CD7F32;  // 🥉 برونزي
$loyalty-silver:  #C0C0C0;  // 🥈 فضي
$loyalty-gold:    #FFD700;  // 🥇 ذهبي
$loyalty-diamond: #B9F2FF;  // 💎 ماسي

.tier-badge {
  display: inline-flex;
  align-items: center;
  gap: $space-2;
  padding: $space-1 $space-3;
  border-radius: $radius-full;
  font-weight: $font-semibold;

  &.bronze {
    background: rgba($loyalty-bronze, 0.15);
    color: darken($loyalty-bronze, 20%);
    border: 1px solid rgba($loyalty-bronze, 0.3);
  }

  &.silver {
    background: rgba($loyalty-silver, 0.15);
    color: $gray-700;
    border: 1px solid rgba($loyalty-silver, 0.5);
  }

  &.gold {
    background: rgba($loyalty-gold, 0.15);
    color: darken($loyalty-gold, 30%);
    border: 1px solid rgba($loyalty-gold, 0.5);
  }

  &.diamond {
    background: linear-gradient(135deg, rgba($loyalty-diamond, 0.2), rgba(#E0E7FF, 0.3));
    color: #4338CA;
    border: 1px solid rgba($loyalty-diamond, 0.5);
  }
}
```

## 12.2 Points Display

```tsx
// عرض النقاط
<PointsDisplay
  currentPoints={2500}
  pendingPoints={150} // نقاط قيد الانتظار
  expiringPoints={300} // نقاط تنتهي قريباً
  expiryDate="2026-03-01"
/>
```

### Layout

```
┌──────────────────────────────────────────────────────────┐
│                    ⭐ نقاط الولاء                        │
├──────────────────────────────────────────────────────────┤
│                                                          │
│       ┌─────────────────────────────────────────┐       │
│       │         2,500                            │       │
│       │         نقطة متاحة                       │       │
│       └─────────────────────────────────────────┘       │
│                                                          │
│   ⏳ +150 قيد المعالجة      ⚠️ 300 تنتهي في مارس        │
│                                                          │
└──────────────────────────────────────────────────────────┘
```

## 12.3 Points Redemption Dialog

```tsx
// نافذة استبدال النقاط (في شاشة الدفع)
<PointsRedemptionDialog
  availablePoints={2500}
  pointValue={0.1} // قيمة النقطة = 0.1 ر.س
  maxRedemption={250} // أقصى خصم = 250 ر.س
  cartTotal={500}
  onRedeem={handleRedeem}
/>
```

### Layout

```
┌──────────────────────────────────────────────────────────┐
│                  🎁 استبدال النقاط                       │
├──────────────────────────────────────────────────────────┤
│                                                          │
│  لديك: 2,500 نقطة  =  250.00 ر.س                        │
│                                                          │
│  ┌──────────────────────────────────────────────────┐   │
│  │  كم نقطة تريد استخدامها؟                          │   │
│  │                                                    │   │
│  │  [       1000        ]  نقطة                      │   │
│  │                                                    │   │
│  │  ══════════●═════════════════════  (40%)          │   │
│  │                                                    │   │
│  │  [ 500 ] [ 1000 ] [ 1500 ] [ كلها ]              │   │
│  └──────────────────────────────────────────────────┘   │
│                                                          │
│  💰 الخصم: 100.00 ر.س                                   │
│  📦 الإجمالي بعد الخصم: 400.00 ر.س                      │
│                                                          │
│         [  ✅ تطبيق الخصم  ]    [  ❌ إلغاء  ]          │
└──────────────────────────────────────────────────────────┘
```

## 12.4 Tier Progress Card

```tsx
// بطاقة تقدم المستوى
<TierProgressCard
  currentTier="silver"
  nextTier="gold"
  currentPoints={2500}
  requiredPoints={5000}
  benefits={['خصم 5%', 'توصيل مجاني', 'عروض حصرية']}
/>
```

### Visual

```
┌──────────────────────────────────────────────────────────┐
│  🥈 فضي ─────────────────●───────────────── 🥇 ذهبي     │
│                        50%                               │
│           2,500 / 5,000 نقطة                            │
├──────────────────────────────────────────────────────────┤
│  🎯 عند الوصول للذهبي:                                   │
│     • خصم 5% على كل مشترياتك                            │
│     • توصيل مجاني                                        │
│     • عروض حصرية                                         │
└──────────────────────────────────────────────────────────┘
```

## 12.5 Points History List

```tsx
// قائمة سجل النقاط
<PointsHistoryList
  items={[
    { type: 'earn', points: 50, source: 'فاتورة #1234', date: '2026-02-01' },
    { type: 'redeem', points: -100, source: 'استبدال', date: '2026-01-28' },
    { type: 'expire', points: -30, source: 'انتهاء صلاحية', date: '2026-01-15' },
    { type: 'bonus', points: 200, source: 'مكافأة ترقية', date: '2026-01-01' },
  ]}
/>
```

### Item Styles

```scss
.points-history-item {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: $space-3;
  border-bottom: 1px solid var(--border);

  .points-value {
    font-weight: $font-bold;
    font-family: $font-mono;

    &.earn   { color: $success-600; }  // +50 ✅
    &.redeem { color: $info-600; }     // -100 🎁
    &.expire { color: $warning-600; }  // -30 ⏰
    &.bonus  { color: $primary-600; }  // +200 🎉
  }
}
```

---

# 1️⃣3️⃣ Multi-Branch Components ⭐ NEW

## 13.1 Branch Card

```tsx
// بطاقة الفرع
interface BranchCardProps {
  branch: {
    id: string;
    name: string;
    address: string;
    isMain: boolean;
    status: 'active' | 'inactive';
    productsCount: number;
    lowStockCount: number;
  };
  isSelected: boolean;
  onSelect: () => void;
}

<BranchCard
  branch={branchData}
  isSelected={true}
  onSelect={handleSelect}
/>
```

### Layout

```
┌──────────────────────────────────────────────────────────┐
│  🏪 فرع الرياض - العليا                      [الرئيسي]  │
├──────────────────────────────────────────────────────────┤
│  📍 شارع العليا، حي الورود                              │
│                                                          │
│  📦 1,234 منتج    ⚠️ 23 منخفض    ✅ نشط                 │
│                                                          │
│  [ 📊 التقارير ]  [ 📦 المخزون ]  [ ⚙️ الإعدادات ]      │
└──────────────────────────────────────────────────────────┘
```

### Styles

```scss
.branch-card {
  border: 2px solid var(--border);
  border-radius: $radius-lg;
  padding: $space-4;
  transition: all $duration-normal $ease-default;

  &.selected {
    border-color: $primary-500;
    background: $primary-50;
  }

  &.main {
    .main-badge {
      background: $primary-500;
      color: white;
      padding: $space-1 $space-2;
      border-radius: $radius-sm;
      font-size: $text-xs;
    }
  }

  .stats {
    display: flex;
    gap: $space-4;

    .stat {
      display: flex;
      align-items: center;
      gap: $space-1;

      &.warning { color: $warning-600; }
      &.success { color: $success-600; }
    }
  }
}
```

## 13.2 Branch Selector

```tsx
// محدد الفرع (في Header)
<BranchSelector
  currentBranch={selectedBranch}
  branches={allBranches}
  onChange={handleBranchChange}
  showAllOption={true} // "كل الفروع" للتقارير
/>
```

### Dropdown Layout

```
┌──────────────────────────────────────┐
│  🏪 فرع الرياض - العليا  ▼          │
├──────────────────────────────────────┤
│  ○ 🌐 كل الفروع                     │
│  ──────────────────────────────────  │
│  ● 🏪 فرع الرياض - العليا ⭐        │
│  ○ 🏪 فرع جدة - الكورنيش            │
│  ○ 🏪 فرع الدمام - الفيصلية         │
│  ──────────────────────────────────  │
│  [ + إضافة فرع جديد ]               │
└──────────────────────────────────────┘
```

## 13.3 Stock Transfer Card

```tsx
// بطاقة نقل المخزون
<StockTransferCard
  transfer={{
    id: 'TR-001',
    fromBranch: 'فرع الرياض',
    toBranch: 'فرع جدة',
    itemsCount: 15,
    status: 'IN_TRANSIT',
    createdAt: '2026-02-01',
    isAiSuggested: true,
  }}
  onView={handleView}
  onApprove={handleApprove}
/>
```

### Layout

```
┌──────────────────────────────────────────────────────────┐
│  📦 TR-001                                   🤖 AI       │
├──────────────────────────────────────────────────────────┤
│                                                          │
│  🏪 فرع الرياض  ──────➡️──────  🏪 فرع جدة             │
│                                                          │
│  📦 15 منتج      🚚 في الطريق      📅 1 فبراير          │
│                                                          │
│  [ 👁️ التفاصيل ]  [ ✅ تم الاستلام ]                    │
└──────────────────────────────────────────────────────────┘
```

### Status Colors

```scss
$transfer-draft:     $gray-500;      // مسودة
$transfer-pending:   $warning-500;   // بانتظار الموافقة
$transfer-transit:   $info-500;      // في الطريق
$transfer-received:  $success-500;   // تم الاستلام
$transfer-cancelled: $danger-500;    // ملغي
```

## 13.4 AI Transfer Suggestion Card

```tsx
// بطاقة اقتراح النقل الذكي
<AiTransferSuggestionCard
  suggestion={{
    fromBranch: 'فرع الرياض',
    toBranch: 'فرع جدة',
    product: 'حليب المراعي 1 لتر',
    suggestedQty: 50,
    reason: 'سينفد في فرع جدة خلال يومين',
    priority: 'URGENT',
    fromStock: 200,
    toStock: 10,
    daysUntilStockout: 2,
  }}
  onApply={handleApply}
  onIgnore={handleIgnore}
/>
```

### Layout

```
┌──────────────────────────────────────────────────────────┐
│  🤖 اقتراح ذكي                              🔴 عاجل     │
├──────────────────────────────────────────────────────────┤
│                                                          │
│  📦 حليب المراعي 1 لتر                                  │
│                                                          │
│  ┌─────────────────┐      ┌─────────────────┐           │
│  │ فرع الرياض      │  ➡️  │ فرع جدة         │           │
│  │ 📦 200 (فائض)   │      │ 📦 10 (نقص)     │           │
│  └─────────────────┘      └─────────────────┘           │
│                                                          │
│  💡 سينفد في فرع جدة خلال يومين                          │
│  📊 الكمية المقترحة: 50 وحدة                            │
│                                                          │
│         [ ✅ تطبيق الاقتراح ]  [ ❌ تجاهل ]             │
└──────────────────────────────────────────────────────────┘
```

### Priority Badges

```scss
.priority-badge {
  padding: $space-1 $space-2;
  border-radius: $radius-sm;
  font-size: $text-xs;
  font-weight: $font-semibold;

  &.urgent { background: $danger-100; color: $danger-700; }
  &.normal { background: $warning-100; color: $warning-700; }
  &.low    { background: $gray-100; color: $gray-700; }
}
```

## 13.5 Branch Comparison Chart

```tsx
// مخطط مقارنة الفروع
<BranchComparisonChart
  metric="sales" // 'sales' | 'stock' | 'customers'
  branches={['فرع الرياض', 'فرع جدة', 'فرع الدمام']}
  data={chartData}
  period="week"
/>
```

---

# 1️⃣4️⃣ Debt Reminder Components ⭐ NEW

## 14.1 Reminder Settings Card

```tsx
// بطاقة إعدادات التذكير
<ReminderSettingsCard
  settings={{
    isEnabled: true,
    channels: ['whatsapp', 'sms'],
    schedule: [7, 15, 30], // أيام بعد الاستحقاق
    minAmount: 100, // الحد الأدنى للدين
    autoSend: false, // إرسال تلقائي
  }}
  onSave={handleSave}
/>
```

### Layout

```
┌──────────────────────────────────────────────────────────┐
│  📧 إعدادات تذكير الديون                     [ تفعيل ]  │
├──────────────────────────────────────────────────────────┤
│                                                          │
│  📱 قنوات الإرسال:                                       │
│     [✓] واتساب    [✓] SMS    [ ] البريد                 │
│                                                          │
│  ⏰ جدول التذكير (أيام بعد الاستحقاق):                   │
│     [ 7 أيام ]  [ 15 يوم ]  [ 30 يوم ]  [ + إضافة ]     │
│                                                          │
│  💰 الحد الأدنى للدين:  [ 100 ] ر.س                      │
│                                                          │
│  🤖 إرسال تلقائي:  [ ] (يتطلب موافقة يدوية)             │
│                                                          │
│                              [ 💾 حفظ الإعدادات ]        │
└──────────────────────────────────────────────────────────┘
```

## 14.2 Reminder Schedule Timeline

```tsx
// الخط الزمني لجدول التذكيرات
<ReminderScheduleTimeline
  dueDate="2026-01-15"
  reminders={[
    { day: 7, status: 'sent', sentAt: '2026-01-22' },
    { day: 15, status: 'scheduled', scheduledAt: '2026-01-30' },
    { day: 30, status: 'pending' },
  ]}
/>
```

### Visual

```
     📅 الاستحقاق                              📅 اليوم
        ▼                                         ▼
───●────────────●────────────○─────────────○─────────►
   │            │            │             │
   │         7 أيام       15 يوم        30 يوم
   │          ✅ تم           ⏳ غداً        ⬜ لاحقاً
```

## 14.3 Reminder Log Item

```tsx
// عنصر سجل التذكيرات
<ReminderLogItem
  log={{
    id: 'RL-001',
    customer: 'أحمد محمد',
    amount: 1500,
    channel: 'whatsapp',
    status: 'delivered',
    sentAt: '2026-02-01 10:30',
    response: 'read', // 'delivered' | 'read' | 'failed'
  }}
/>
```

### Layout

```
┌──────────────────────────────────────────────────────────┐
│  📱 واتساب                              ✓✓ تمت القراءة  │
├──────────────────────────────────────────────────────────┤
│  👤 أحمد محمد          💰 1,500 ر.س                     │
│  📅 1 فبراير 2026 - 10:30 صباحاً                        │
│  📝 "مرحباً أحمد، نذكرك بمبلغ 1,500 ر.س..."            │
└──────────────────────────────────────────────────────────┘
```

### Status Icons

```scss
.reminder-status {
  &.sent      { color: $info-500; }     // ✓ تم الإرسال
  &.delivered { color: $success-500; }  // ✓✓ تم التوصيل
  &.read      { color: $success-600; }  // ✓✓ تمت القراءة (أزرق)
  &.failed    { color: $danger-500; }   // ❌ فشل
}
```

## 14.4 Message Template Editor

```tsx
// محرر قوالب الرسائل
<MessageTemplateEditor
  template={{
    name: 'تذكير بعد 7 أيام',
    channel: 'whatsapp',
    content: 'مرحباً {customer_name}، نذكرك بمبلغ {amount} ر.س المستحق منذ {days} يوم.',
    variables: ['customer_name', 'amount', 'days', 'store_name'],
  }}
  onSave={handleSave}
/>
```

### Variables

```
المتغيرات المتاحة:
{customer_name}  - اسم العميل
{amount}         - مبلغ الدين
{days}           - عدد الأيام
{due_date}       - تاريخ الاستحقاق
{store_name}     - اسم المتجر
{payment_link}   - رابط الدفع
```

## 14.5 Debt Summary Widget (Dashboard)

```tsx
// ودجت ملخص الديون للداشبورد
<DebtSummaryWidget
  totalDebt={45000}
  overdueDebt={15000}
  customersCount={23}
  remindersToday={5}
  onViewAll={handleViewAll}
/>
```

### Layout

```
┌──────────────────────────────────────────────────────────┐
│  💸 ملخص الديون                          [ عرض الكل ]   │
├──────────────────────────────────────────────────────────┤
│                                                          │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐      │
│  │   45,000    │  │   15,000    │  │     23      │      │
│  │  إجمالي    │  │  🔴 متأخر  │  │   عميل     │      │
│  └─────────────┘  └─────────────┘  └─────────────┘      │
│                                                          │
│  📧 5 تذكيرات مجدولة اليوم                              │
│                                                          │
└──────────────────────────────────────────────────────────┘
```

---

# 📌 ملخص المكونات الجديدة

| الفئة | المكونات | العدد |
|-------|----------|-------|
| **Split Payment** | PaymentMethodCard, SplitPaymentSummary, AmountSlider, PaymentProgressBar | 4 |
| **Loyalty** | TierBadge, PointsDisplay, RedemptionDialog, TierProgressCard, PointsHistoryList | 5 |
| **Multi-Branch** | BranchCard, BranchSelector, TransferCard, AiSuggestionCard, ComparisonChart | 5 |
| **Debt Reminders** | ReminderSettingsCard, ScheduleTimeline, ReminderLogItem, TemplateEditor, DebtSummaryWidget | 5 |
| **المجموع** | | **19 مكون** |

---

**آخر تحديث:** 2026-02-02 | **الإصدار:** 2.0
