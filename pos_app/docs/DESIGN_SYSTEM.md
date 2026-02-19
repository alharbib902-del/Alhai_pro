# 🎨 Design System - نظام التصميم

## الهوية البصرية: Fresh Grocery (بقالة طازجة)

### الفلسفة
```
بسيط 🧹 → واجهة نظيفة بدون فوضى
سريع ⚡ → كل شيء واضح ومباشر
موثوق 💪 → يعطي إحساس بالأمان
ودود 🤝 → ليس رسمي جداً
```

### المنصة الرئيسية
- **Web** (Desktop & Tablet)
- Sidebar navigation
- Split view للشاشات الرئيسية
- Keyboard shortcuts

---

## 🎨 الألوان

### Primary - الأخضر الطازج
```
Primary:        #10B981 (Emerald 500)
Primary Light:  #34D399 (Emerald 400)
Primary Dark:   #059669 (Emerald 600)
Primary Surface:#ECFDF5 (Emerald 50)
Primary Border: #A7F3D0 (Emerald 200)
```

### Secondary - البرتقالي الدافئ
```
Secondary:        #F97316 (Orange 500)
Secondary Light:  #FB923C (Orange 400)
Secondary Dark:   #EA580C (Orange 600)
Secondary Surface:#FFF7ED (Orange 50)
```

### Semantic - ألوان المعاني
```
Success:  #22C55E / Surface: #DCFCE7
Warning:  #F59E0B / Surface: #FEF3C7
Error:    #EF4444 / Surface: #FEE2E2
Info:     #3B82F6 / Surface: #DBEAFE
```

### Money - ألوان المال
```
Cash:   #22C55E (نقد - أخضر)
Card:   #3B82F6 (بطاقة - أزرق)
Debt:   #EF4444 (دين - أحمر)
Credit: #14B8A6 (رصيد - تركواز)
```

### Stock - ألوان المخزون
```
Available: #22C55E (متوفر - أخضر)
Low:       #F59E0B (منخفض - أصفر)
Out:       #EF4444 (نفذ - أحمر)
```

### Neutral - Light Mode
```
Background:      #F9FAFB (Gray 50)
Surface:         #FFFFFF (White)
Surface Variant: #F3F4F6 (Gray 100)
Border:          #E5E7EB (Gray 200)
Divider:         #F3F4F6 (Gray 100)
```

### Neutral - Dark Mode
```
Background:      #111827 (Gray 900)
Surface:         #1F2937 (Gray 800)
Surface Variant: #374151 (Gray 700)
Border:          #4B5563 (Gray 600)
```

### Text Colors
```
Light Mode:
  Primary:   #111827 (Gray 900)
  Secondary: #6B7280 (Gray 500)
  Muted:     #9CA3AF (Gray 400)

Dark Mode:
  Primary:   #F9FAFB (Gray 50)
  Secondary: #D1D5DB (Gray 300)
  Muted:     #9CA3AF (Gray 400)
```

### Category Colors
```
Fruits:     #F97316 (فواكه - برتقالي)
Vegetables: #22C55E (خضروات - أخضر)
Dairy:      #3B82F6 (ألبان - أزرق)
Meat:       #EF4444 (لحوم - أحمر)
Bakery:     #F59E0B (مخبوزات - أصفر)
Drinks:     #06B6D4 (مشروبات - سماوي)
Snacks:     #8B5CF6 (سناكس - بنفسجي)
Cleaning:   #14B8A6 (تنظيف - تركواز)
```

---

## 🔤 Typography

### Font Family
```
Primary: Tajawal
Numbers: Tajawal (or IBM Plex Sans Arabic)
```

### Scale
```
Display Large:  36px / Bold (700)   - للأرقام الكبيرة
Display Medium: 28px / Bold (700)   - للعناوين الكبيرة
Headline Large: 24px / SemiBold (600)
Headline Medium:20px / SemiBold (600)
Title Large:    18px / SemiBold (600)
Title Medium:   16px / SemiBold (600)
Title Small:    14px / SemiBold (600)
Body Large:     16px / Regular (400)
Body Medium:    14px / Regular (400)
Body Small:     12px / Regular (400)
Label Large:    14px / SemiBold (600)
Label Medium:   12px / SemiBold (600)
Label Small:    11px / Medium (500)
```

### Price Typography
```
Price Large:  32px / Bold (700)
Price Medium: 20px / Bold (700)
Price Small:  16px / SemiBold (600)
```

---

## 📐 Spacing

### Scale
```
xxs:  2px
xs:   4px
sm:   8px
md:   12px
lg:   16px
xl:   20px
xxl:  24px
xxxl: 32px
huge: 48px
```

### Usage Guidelines
```
Tight spacing (4-8px):   Between related elements
Default spacing (12-16px): Between components
Section spacing (24-32px): Between sections
Page padding (24-48px):    Page margins
```

---

## 🔘 Border Radius

### Scale
```
none: 0px
xs:   4px   - Small elements, tags
sm:   6px   - Chips, small buttons
md:   8px   - Inputs, small cards
lg:   12px  - Cards, buttons
xl:   16px  - Large cards
xxl:  20px  - Modals, bottom sheets
full: 999px - Pills, avatars
```

### Usage Guidelines
```
Inputs:       8px (md)
Buttons:      8-10px (md)
Cards:        12px (lg)
Modals:       16-20px (xl-xxl)
Avatars:      full
Tags/Chips:   full
```

---

## 🌑 Shadows

### Light Mode
```
sm: 0 1px 2px rgba(0,0,0,0.04)
md: 0 2px 4px rgba(0,0,0,0.06)
lg: 0 4px 8px rgba(0,0,0,0.08)
xl: 0 8px 16px rgba(0,0,0,0.10)
```

### Primary Shadow (for buttons)
```
sm: 0 2px 8px rgba(16,185,129,0.25)
md: 0 4px 12px rgba(16,185,129,0.30)
```

### Dark Mode
```
Use lighter opacity and slightly blue tint
```

---

## 📱 Breakpoints

```
Mobile:  < 640px
Tablet:  640px - 1024px
Laptop:  1024px - 1280px
Desktop: 1280px - 1536px
Wide:    > 1536px
```

### Layout Behavior
```
< 768px:  Mobile layout (bottom nav, full-width)
768-1024: Tablet (collapsible sidebar)
> 1024:   Desktop (full sidebar, split views)
```

---

## ⌨️ Keyboard Shortcuts

```
F1:      البحث
F2:      ماسح الباركود
F3:      اختيار عميل
F4:      إضافة خصم
F5:      تحديث
F8:      تعليق الفاتورة
F9:      استرجاع فاتورة معلقة
F12:     إغلاق الوردية
Enter:   تأكيد/دفع
Escape:  إلغاء/رجوع
Ctrl+K:  بحث سريع (Spotlight)
Ctrl+N:  فاتورة جديدة
Ctrl+P:  طباعة
```

---

## 🧩 Components

### AppButton
```
Variants: primary, secondary, outlined, ghost, danger
Sizes: sm (36px), md (44px), lg (52px)
States: default, hover, pressed, disabled, loading
```

### AppCard
```
Variants: elevated, outlined, filled, gradient
Padding: sm (12px), md (16px), lg (20px)
States: default, hover (web), selected
```

### AppTextField
```
Variants: standard, search, password, number
States: default, focused, error, disabled
Features: floating label, error shake
```

### AppDialog
```
Types: confirmation, form, alert
Sizes: sm (400px), md (500px), lg (600px)
```

### DataTable
```
Features: sortable, paginated, selectable
Row height: 52px
Header height: 48px
```

---

## ✨ Animations

### Durations
```
instant: 100ms
fast:    200ms
normal:  300ms
slow:    400ms
slower:  500ms
```

### Easing
```
default:    ease-out
enter:      ease-out
exit:       ease-in
bounce:     cubic-bezier(0.68, -0.55, 0.265, 1.55)
```

### Guidelines
```
- Respect reduceMotion setting
- Keep animations under 400ms
- Use meaningful animations only
- Add haptic feedback on mobile
```

---

## 🌙 Dark Mode

### Principles
```
- Use surface colors, not pure black
- Maintain contrast ratios (WCAG AA)
- Reduce brightness, not invert
- Keep brand colors recognizable
```

### Color Adjustments
```
Primary stays same (#10B981)
Reduce shadow intensity
Use darker surfaces for elevation
```

---

## ♿ Accessibility

### Touch Targets
```
Minimum: 44x44px
Recommended: 48x48px
```

### Contrast Ratios
```
Normal text: 4.5:1 minimum
Large text: 3:1 minimum
UI components: 3:1 minimum
```

### Focus States
```
Always visible focus ring
2px solid primary color
4px offset
```

---

## 📁 File Structure

```
lib/
├── core/
│   └── theme/
│       ├── app_colors.dart
│       ├── app_typography.dart
│       ├── app_sizes.dart
│       ├── app_shadows.dart
│       └── app_theme.dart
├── widgets/
│   ├── common/
│   │   ├── app_button.dart
│   │   ├── app_card.dart
│   │   ├── app_text_field.dart
│   │   ├── app_dialog.dart
│   │   ├── skeleton_loader.dart
│   │   └── stat_card.dart
│   └── layout/
│       ├── app_scaffold.dart
│       ├── sidebar.dart
│       └── top_bar.dart
```
