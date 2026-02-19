# UX Pilot Design Prompts - POS App
## 25 Core Screens Design System

---

# 📋 MASTER DESIGN CHECKLIST (Copy to Every Prompt)

```
STRICT DESIGN RULES - MUST FOLLOW:

🎨 COLORS:
- Primary GREEN: #10B981 (buttons, links, active states)
- Success GREEN: #22C55E (success messages, confirmations)
- Gradient: #10B981 → #047857 (headers, hero sections)
- Error: #EF4444 | Warning: #F59E0B | Info: #3B82F6

🌙 DARK MODE:
- Background: #0F172A
- Surface: #1E293B
- Cards: #334155
- Text Primary: #F8FAFC
- Text Secondary: #94A3B8
- Borders: #475569

☀️ LIGHT MODE:
- Background: #F8FAFC
- Surface: #FFFFFF
- Cards: #FFFFFF
- Text Primary: #0F172A
- Text Secondary: #64748B
- Borders: #E2E8F0

📐 SPACING (8px grid):
- XS: 4px | SM: 8px | MD: 16px | LG: 24px | XL: 32px
- Container padding: 24px
- Card padding: 16px
- Button padding: 12px vertical, 24px horizontal

🔲 BORDER RADIUS:
- Containers/Modals: 32px
- Cards: 16px
- Buttons: 12px
- Inputs: 12px
- Tags/Chips: 8px

✍️ TYPOGRAPHY:
- RTL Font: Noto Sans Arabic
- LTR Font: Noto Sans
- H1: 32px Bold | H2: 24px SemiBold | H3: 20px SemiBold
- Body: 16px Regular | Small: 14px | Caption: 12px

🌍 6 LANGUAGES:
- Arabic (ar) - RTL
- Urdu (ur) - RTL
- English (en) - LTR
- Hindi (hi) - LTR
- Bengali (bn) - LTR
- Indonesian (id) - LTR

📱 RESPONSIVE:
- Mobile: < 768px (single column, bottom nav)
- Tablet: 768px - 1024px (flexible grid)
- Desktop: > 1024px (sidebar, multi-column)

✅ ACCESSIBILITY:
- Min touch target: 44x44px
- Color contrast: 4.5:1 minimum
- Focus states visible
- Icons with labels
```

---

# 🔐 MODULE 1: AUTHENTICATION (4 Screens)

---

## Screen 1/25: Splash Screen

### Screen Information
| Property | Value |
|----------|-------|
| Screen Name | Splash Screen |
| Arabic Name | شاشة البداية |
| File | `splash_screen.dart` |
| Purpose | App launch, branding, loading, auto-login check |

### Design Requirements

**Layout:**
- Full screen with gradient background (#10B981 → #047857)
- Centered content vertically and horizontally
- No navigation elements

**Components:**
1. **Logo Area (Center)**
   - App logo: 120x120px
   - White color for contrast
   - Subtle scale animation (pulse)

2. **App Name**
   - Below logo, 24px margin top
   - "نقاط البيع" (Arabic) / "POS System" (English)
   - White, H1 (32px Bold)
   - Tagline below: "إدارة ذكية لأعمالك" / "Smart Business Management"
   - White/80% opacity, Body (16px)

3. **Loading Indicator**
   - Below tagline, 48px margin top
   - Circular progress indicator
   - White color, 32px size
   - Smooth rotation animation

4. **Version Number**
   - Bottom of screen, 32px from bottom
   - "v1.0.0"
   - White/60% opacity, Caption (12px)

**States:**
- Loading: Show progress indicator
- Error: Show error message + "إعادة المحاولة" / "Retry" button
- Success: Fade out transition to next screen

**Animations:**
- Logo: Fade in + scale (0.8 → 1.0) over 800ms
- Text: Fade in after 400ms delay
- Loader: Continuous rotation
- Exit: Fade out all elements over 300ms

**Dark/Light Mode:**
- This screen uses gradient background in both modes
- All elements are white for contrast

---

## Screen 2/25: Login Screen

### Screen Information
| Property | Value |
|----------|-------|
| Screen Name | Login Screen |
| Arabic Name | تسجيل الدخول |
| File | `login_screen.dart` |
| Purpose | WhatsApp OTP authentication |

### Design Requirements

**Layout - Desktop/Tablet (Split Screen):**
```
┌─────────────────────────────────────────────────┐
│  LEFT PANEL (50%)    │   RIGHT PANEL (50%)      │
│  ─────────────────   │   ──────────────────     │
│  Form Content        │   Brand/Illustration     │
│  (White/Dark bg)     │   (Gradient bg)          │
│                      │                          │
│  [Form Fields]       │   [Logo]                 │
│  [OTP Input]         │   [Tagline]              │
│  [Buttons]           │   [Features]             │
└─────────────────────────────────────────────────┘
```

**CRITICAL:** Left = Form, Right = Brand (FIXED positions regardless of language)
RTL/LTR affects text direction INSIDE panels only, NOT panel positions.

**Layout - Mobile (Single Column):**
- Full width form
- Brand section hidden or minimal header

**Left Panel - Form Content:**

1. **Header**
   - "تسجيل الدخول" / "Sign In" - H1 (32px Bold)
   - "أدخل رقم الجوال للمتابعة" / "Enter your phone to continue" - Body, secondary color

2. **Phone Input Field**
   - Label: "رقم الجوال" / "Phone Number"
   - Fixed chip: "+966" (Saudi flag + code) - NOT dropdown
   - Input: Placeholder "5XXXXXXXX"
   - Numeric keyboard on mobile
   - Validation: 9 digits starting with 5
   - Border radius: 12px
   - Height: 56px

3. **Send OTP Button**
   - Text: "إرسال رمز التحقق" / "Send OTP"
   - Full width
   - Primary color (#10B981)
   - Height: 56px
   - Border radius: 12px
   - Loading state with spinner

4. **OTP Input (After sending)**
   - 4 separate boxes (56x56px each)
   - Auto-focus next on input
   - 16px gap between boxes
   - Border radius: 12px
   - Active border: Primary color 2px

5. **Verify Button**
   - Text: "تأكيد" / "Verify"
   - Same style as Send OTP button

6. **Resend Timer**
   - "إعادة الإرسال خلال 30 ثانية" / "Resend in 30s"
   - Secondary text color
   - When timer ends: "إعادة الإرسال" / "Resend" link

7. **Footer Links**
   - "تحتاج مساعدة؟" / "Need help?" - Link color

**Right Panel - Brand:**
- Gradient background (#10B981 → #047857)
- Large app logo (white, 80px)
- "نظام نقاط البيع" / "POS System" - White, H2
- Feature list with icons:
  - ✓ "مزامنة تلقائية" / "Auto Sync"
  - ✓ "تقارير ذكية" / "Smart Reports"
  - ✓ "دعم متعدد اللغات" / "Multi-language"
- Decorative illustration (optional)

**States:**
- Default: Phone input visible
- OTP Sent: Show OTP input, hide phone input
- Loading: Button shows spinner
- Error: Red border on invalid input + error message
- Success: Green checkmark + transition

**Validation Messages:**
- Empty phone: "الرجاء إدخال رقم الجوال" / "Please enter phone number"
- Invalid phone: "رقم جوال غير صحيح" / "Invalid phone number"
- Invalid OTP: "رمز التحقق غير صحيح" / "Invalid OTP"

---

## Screen 3/25: Store Selection Screen

### Screen Information
| Property | Value |
|----------|-------|
| Screen Name | Store Selection |
| Arabic Name | اختيار المتجر |
| File | `store_select_screen.dart` |
| Purpose | Select store/branch to work with |

### Design Requirements

**Layout - Desktop/Tablet (Split Screen):**
- Same split as Login: LEFT = Content, RIGHT = Brand
- Form panel background: White (light) / #1E293B (dark)

**Layout - Mobile:**
- Full width, minimal brand header

**Content Panel:**

1. **Header**
   - Back arrow (top left/right based on RTL)
   - "اختيار المتجر" / "Select Store" - H1
   - "اختر المتجر الذي تريد العمل عليه" / "Choose the store you want to work on" - Body, secondary

2. **Search Bar (Optional - if many stores)**
   - Placeholder: "البحث في المتاجر..." / "Search stores..."
   - Search icon
   - Border radius: 12px

3. **Store Cards List**
   - Vertical list with 12px gap
   - Each card:
     ```
     ┌─────────────────────────────────────┐
     │ ○ Radio    Store Name      [Badge] │
     │            📍 Location             │
     │            Status indicator        │
     └─────────────────────────────────────┘
     ```
   - Card padding: 16px
   - Border radius: 16px
   - Border: 1px solid border color
   - Selected state: Primary border 2px + light primary background

4. **Store Card Details:**
   - Radio button (left for LTR, right for RTL)
   - Store name: Body Bold
   - Location: Caption, secondary color, with 📍 icon
   - Status badge:
     - Online: Green dot + "متصل" / "Online"
     - Offline: Gray dot + "غير متصل" / "Offline"
   - Last sync: Caption, "آخر مزامنة: منذ 5 دقائق" / "Last sync: 5 min ago"

5. **Remember Choice Checkbox**
   - "تذكر اختياري" / "Remember my choice"
   - Below store list
   - Checkbox with label

6. **Continue Button**
   - "متابعة" / "Continue"
   - Full width
   - Primary color
   - Disabled until store selected

**Brand Panel:**
- Same as Login screen
- Can show store illustration

**States:**
- Loading: Skeleton cards (3 items)
- Empty: "لا توجد متاجر" / "No stores found" with illustration
- Error: Error message with retry button
- Selected: Card highlighted with primary color

---

## Screen 4/25: Manager Approval Screen

### Screen Information
| Property | Value |
|----------|-------|
| Screen Name | Manager Approval |
| Arabic Name | موافقة المدير |
| File | `manager_approval_screen.dart` |
| Purpose | Manager PIN verification for sensitive operations |

### Design Requirements

**Layout - Desktop/Tablet:**
- Centered modal overlay
- Background: Semi-transparent black (50% opacity)
- Modal: White/Dark card, max-width 400px
- Border radius: 32px

**Layout - Mobile:**
- Full screen
- White/Dark background

**Modal/Screen Content:**

1. **Header**
   - Close button (X) top right/left
   - Lock icon: 48px, Primary color, centered
   - "موافقة المدير" / "Manager Approval" - H2, centered
   - "أدخل رمز PIN للمتابعة" / "Enter PIN to continue" - Body, secondary, centered

2. **Operation Info Card**
   - Light background card
   - Border radius: 12px
   - Padding: 16px
   - Content:
     - Operation type: "إلغاء عملية" / "Void Transaction"
     - Amount (if applicable): "150.00 ر.س" / "SAR 150.00"
     - Reference: "#TXN-12345"

3. **PIN Input**
   - 4 dots/boxes (48x48px each)
   - 16px gap
   - Filled dot = Primary color
   - Empty dot = Border only
   - Centered horizontally

4. **Custom Numeric Keypad**
   ```
   ┌─────┬─────┬─────┐
   │  1  │  2  │  3  │
   ├─────┼─────┼─────┤
   │  4  │  5  │  6  │
   ├─────┼─────┼─────┤
   │  7  │  8  │  9  │
   ├─────┼─────┼─────┤
   │ Bio │  0  │  ⌫  │
   └─────┴─────┴─────┘
   ```
   - Button size: 64x64px
   - Gap: 12px
   - Border radius: 12px
   - Background: Surface color
   - Bio = Fingerprint icon (if available)
   - ⌫ = Backspace icon

5. **Attempts Counter**
   - Below keypad
   - "المحاولات المتبقية: 3" / "Remaining attempts: 3"
   - Warning color when < 3
   - Error color when = 1

6. **Cancel Button**
   - "إلغاء" / "Cancel"
   - Text button, secondary color
   - Below attempts counter

**States:**
- Default: Empty PIN dots
- Entering: Fill dots as digits entered
- Verifying: Show loading spinner
- Success: Green checkmark animation, auto-close
- Error: Shake animation, red flash, clear dots
- Locked: Show lock message + countdown

**Animations:**
- Modal: Fade in + scale up
- Error: Shake left-right (3 times)
- Success: Checkmark draw animation
- Close: Fade out + scale down

---

# 🏠 MODULE 2: MAIN SCREENS (3 Screens)

---

## Screen 5/25: Home Screen

### Screen Information
| Property | Value |
|----------|-------|
| Screen Name | Home Screen |
| Arabic Name | الرئيسية |
| File | `home_screen.dart` |
| Purpose | Main dashboard with navigation and quick stats |

### Design Requirements

**Layout - Desktop:**
```
┌──────────────────────────────────────────────────┐
│ SIDEBAR (240px)  │  MAIN CONTENT                 │
│ ───────────────  │  ────────────────────────     │
│ Logo             │  Header Bar                   │
│ Nav Items        │  Stats Cards Row              │
│ ...              │  Quick Actions Grid           │
│ Settings         │  Recent Activity              │
│ Logout           │  AI Insights                  │
└──────────────────────────────────────────────────┘
```

**Layout - Mobile:**
```
┌─────────────────┐
│ App Bar         │
├─────────────────┤
│ Stats Cards     │
│ (Horizontal)    │
├─────────────────┤
│ Quick Actions   │
│ (2x2 Grid)      │
├─────────────────┤
│ Recent Activity │
├─────────────────┤
│ Bottom Nav Bar  │
└─────────────────┘
```

**Sidebar (Desktop):**

1. **Logo Section**
   - App logo: 40px
   - App name: "نقاط البيع" - H3
   - Divider below

2. **Navigation Items**
   - Icon + Label for each
   - Hover: Primary color background (10% opacity)
   - Active: Primary color background + white text
   - Items:
     - 🏠 الرئيسية / Home
     - 🛒 نقطة البيع / POS
     - 📦 المنتجات / Products
     - 📊 المخزون / Inventory
     - 👥 العملاء / Customers
     - 📈 التقارير / Reports
     - ⚙️ الإعدادات / Settings

3. **User Section (Bottom)**
   - User avatar (40px circle)
   - User name
   - Role badge
   - Logout button

**Main Content:**

1. **Header Bar**
   - Store name + branch
   - Search bar (expandable)
   - Notifications bell with badge
   - Dark mode toggle
   - Language selector

2. **Stats Cards Row (4 cards)**
   - Card style: Border radius 16px, padding 20px
   - Each card:
     - Icon in colored circle (40px)
     - Title: Caption, secondary
     - Value: H2, primary text
     - Trend: ↑12% or ↓5% with color

   Cards:
   - 💰 مبيعات اليوم / Today's Sales: "12,450 ر.س"
   - 🛒 عدد الطلبات / Orders: "47"
   - 👥 عملاء جدد / New Customers: "8"
   - 📦 منتجات منخفضة / Low Stock: "12" (warning color)

3. **Quick Actions Grid (2x3 Desktop, 2x2 Mobile)**
   - Large touch-friendly buttons (min 80x80px)
   - Icon + Label centered
   - Border radius: 16px
   - Subtle shadow

   Actions:
   - 🛒 بيع جديد / New Sale (Primary color)
   - ➕ إضافة منتج / Add Product
   - 👤 عميل جديد / New Customer
   - 📊 تقرير اليوم / Daily Report
   - 💵 درج النقد / Cash Drawer
   - 📦 استلام بضاعة / Receive Stock

4. **Recent Activity List**
   - Title: "النشاط الأخير" / "Recent Activity"
   - "عرض الكل" / "View All" link
   - List of 5 recent items:
     - Icon based on type
     - Description
     - Time: "منذ 5 دقائق" / "5 min ago"
     - Amount if applicable

5. **AI Insights Card (Optional)**
   - Gradient border (Primary)
   - ✨ "اقتراحات ذكية" / "Smart Insights"
   - 2-3 actionable insights
   - "عرض المزيد" / "View More" button

**Bottom Navigation (Mobile):**
- 5 items with icons + labels
- Active: Primary color
- Items: Home, POS, Products, Reports, More

---

## Screen 6/25: Dashboard Screen

### Screen Information
| Property | Value |
|----------|-------|
| Screen Name | Dashboard |
| Arabic Name | لوحة التحكم |
| File | `dashboard_screen.dart` |
| Purpose | Detailed analytics and business metrics |

### Design Requirements

**Layout:**
- Full width content area
- Scrollable vertically
- Grid system for charts

**Components:**

1. **Header**
   - "لوحة التحكم" / "Dashboard" - H1
   - Date range picker (Today, Week, Month, Custom)
   - Export button

2. **KPI Cards Row (4 cards)**
   - Similar to Home but more detailed
   - Include mini sparkline chart
   - Compare to previous period

   KPIs:
   - إجمالي المبيعات / Total Sales
   - صافي الربح / Net Profit
   - متوسط سلة الشراء / Avg Basket
   - معدل التحويل / Conversion Rate

3. **Sales Chart (Line/Bar)**
   - Full width card
   - Toggle: Daily/Weekly/Monthly
   - Interactive hover tooltips
   - Primary color for current, gray for previous

4. **Top Products (Horizontal Bar)**
   - "أفضل المنتجات" / "Top Products"
   - Top 5 by revenue
   - Progress bars with percentages
   - Product image thumbnails

5. **Sales by Category (Pie/Donut)**
   - Colorful segments
   - Legend below
   - Click to filter

6. **Recent Transactions Table**
   - Columns: ID, Time, Items, Total, Status, Action
   - Pagination
   - Search/filter

7. **Staff Performance (If manager)**
   - Employee name
   - Sales amount
   - Transactions count
   - Rating

**States:**
- Loading: Skeleton loaders for all sections
- Empty: Appropriate messages per section
- Error: Retry buttons

---

## Screen 7/25: Onboarding Screen

### Screen Information
| Property | Value |
|----------|-------|
| Screen Name | Onboarding |
| Arabic Name | شاشة الترحيب |
| File | `onboarding_screen.dart` |
| Purpose | First-time user introduction |

### Design Requirements

**Layout:**
- Full screen
- Swipeable pages (4 slides)
- Bottom navigation dots + buttons

**Structure per Slide:**
```
┌─────────────────────────────┐
│                             │
│      [Illustration]         │
│         (50%)               │
│                             │
├─────────────────────────────┤
│         Title               │
│       Description           │
│                             │
│    ● ● ○ ○   [Button]      │
└─────────────────────────────┘
```

**Slides Content:**

1. **Slide 1: Welcome**
   - Illustration: Store/POS
   - Title: "مرحباً بك في نقاط البيع" / "Welcome to POS"
   - Description: "نظام متكامل لإدارة مبيعاتك بكل سهولة"

2. **Slide 2: Easy Sales**
   - Illustration: Quick checkout
   - Title: "مبيعات سريعة وسهلة" / "Quick & Easy Sales"
   - Description: "أتمم عمليات البيع بنقرات قليلة"

3. **Slide 3: Reports**
   - Illustration: Charts/Analytics
   - Title: "تقارير ذكية" / "Smart Reports"
   - Description: "تابع أداء عملك بتقارير مفصلة"

4. **Slide 4: Multi-language**
   - Illustration: Globe/Languages
   - Title: "دعم متعدد اللغات" / "Multi-language Support"
   - Description: "استخدم التطبيق بلغتك المفضلة"

**Navigation:**
- Dots: Show current position
- "التالي" / "Next" button (slides 1-3)
- "ابدأ الآن" / "Get Started" button (slide 4)
- "تخطي" / "Skip" link (all slides)

**Animations:**
- Page transition: Slide horizontal
- Illustrations: Subtle float/bob animation
- Dots: Scale active dot

---

# 🛒 MODULE 3: POS SCREENS (6 Screens)

---

## Screen 8/25: POS Main Screen

### Screen Information
| Property | Value |
|----------|-------|
| Screen Name | POS Main |
| Arabic Name | نقطة البيع |
| File | `pos_screen.dart` |
| Purpose | Main sales interface |

### Design Requirements

**Layout - Desktop:**
```
┌────────────────────────────────────────────────────────┐
│ PRODUCTS AREA (65%)        │ CART AREA (35%)          │
│ ────────────────────────   │ ─────────────────────    │
│ [Search] [Scan] [Filter]   │ Cart Header              │
│ [Categories Tabs]          │ ─────────────────────    │
│ ┌─────┬─────┬─────┬─────┐ │ Cart Item 1              │
│ │ Prod│ Prod│ Prod│ Prod│ │ Cart Item 2              │
│ ├─────┼─────┼─────┼─────┤ │ Cart Item 3              │
│ │ Prod│ Prod│ Prod│ Prod│ │ ...                      │
│ └─────┴─────┴─────┴─────┘ │ ─────────────────────    │
│                            │ Subtotal                 │
│                            │ Discount                 │
│                            │ Tax                      │
│                            │ TOTAL                    │
│                            │ [PAY BUTTON]             │
└────────────────────────────────────────────────────────┘
```

**Layout - Mobile:**
- Products grid full width
- Cart as bottom sheet (expandable)
- FAB for cart with item count badge

**Products Area:**

1. **Search & Actions Bar**
   - Search input with icon
   - Barcode scan button
   - Filter button
   - View toggle (Grid/List)

2. **Categories Tabs**
   - Horizontal scrollable
   - "الكل" / "All" first
   - Category name + count
   - Active: Primary underline

3. **Products Grid**
   - 4 columns desktop, 2 columns mobile
   - Product card:
     ```
     ┌─────────────────┐
     │   [Image]       │
     │                 │
     │ Product Name    │
     │ SAR 25.00       │
     │ [Stock Badge]   │
     └─────────────────┘
     ```
   - Click: Add to cart (with animation)
   - Long press: Quick actions menu

4. **Product Card States:**
   - Normal: Default styling
   - Low stock: Warning badge
   - Out of stock: Grayed + "نفذ" badge
   - In cart: Primary border + quantity badge

**Cart Area:**

1. **Cart Header**
   - "السلة" / "Cart" + item count
   - Clear cart button (with confirmation)
   - Customer selector button

2. **Cart Items List**
   - Scrollable
   - Each item:
     - Product image (40px)
     - Name
     - Unit price
     - Quantity controls (- / qty / +)
     - Line total
     - Remove (swipe or X)

3. **Discount Section**
   - "إضافة خصم" / "Add Discount" button
   - Shows applied discount

4. **Totals Section**
   - المجموع الفرعي / Subtotal
   - الخصم / Discount (if any)
   - الضريبة (15%) / Tax (15%)
   - **الإجمالي / Total** - Large, bold

5. **Action Buttons**
   - "تعليق" / "Hold" - Secondary button
   - "الدفع" / "Pay" - Primary button, full width
   - Disabled if cart empty

**Keyboard Shortcuts (Desktop):**
- F1: New sale
- F2: Search products
- F3: Barcode scan
- F4: Hold order
- F12: Pay

---

## Screen 9/25: Payment Screen

### Screen Information
| Property | Value |
|----------|-------|
| Screen Name | Payment |
| Arabic Name | الدفع |
| File | `payment_screen.dart` |
| Purpose | Process payment for sale |

### Design Requirements

**Layout:**
```
┌─────────────────────────────────────────┐
│ ORDER SUMMARY    │  PAYMENT METHODS     │
│ ──────────────   │  ────────────────    │
│ Items list       │  [Cash] [Card]       │
│ (collapsible)    │  [Multiple]          │
│ ──────────────   │  ────────────────    │
│ Subtotal         │  Amount Input        │
│ Discount         │  Quick amounts       │
│ Tax              │  ────────────────    │
│ ══════════════   │  Change due          │
│ TOTAL: 150.00    │  [COMPLETE]          │
└─────────────────────────────────────────┘
```

**Order Summary Panel:**

1. **Header**
   - "ملخص الطلب" / "Order Summary"
   - Collapse/expand toggle

2. **Items List (Collapsible)**
   - Product name × quantity
   - Line total
   - Max 5 visible, scroll for more

3. **Totals**
   - Same as cart totals
   - Total highlighted large

**Payment Panel:**

1. **Payment Method Tabs**
   - 💵 نقدي / Cash
   - 💳 بطاقة / Card
   - 🔄 متعدد / Split
   - Active: Primary background

2. **Cash Payment:**
   - Amount received input (large)
   - Quick amount buttons:
     - Exact amount
     - 50, 100, 200, 500
   - Change calculation displayed
   - "الباقي: 35.00 ر.س" / "Change: SAR 35.00"

3. **Card Payment:**
   - Card type selector (Visa, Mastercard, Mada)
   - Reference number input (optional)
   - "في انتظار الدفع..." / "Waiting for payment..."

4. **Split Payment:**
   - Add payment method rows
   - Amount per method
   - Remaining to pay shown

5. **Complete Button**
   - "إتمام الدفع" / "Complete Payment"
   - Primary color, large
   - Disabled until amount >= total
   - Loading state

**Animations:**
- Payment success: Confetti/checkmark
- Amount input: Smooth number animation
- Method switch: Fade transition

---

## Screen 10/25: Receipt Screen

### Screen Information
| Property | Value |
|----------|-------|
| Screen Name | Receipt |
| Arabic Name | الإيصال |
| File | `receipt_screen.dart` |
| Purpose | Display and print/share receipt |

### Design Requirements

**Layout:**
```
┌─────────────────────────────┐
│     SUCCESS MESSAGE         │
│     ✓ تمت العملية بنجاح     │
├─────────────────────────────┤
│     RECEIPT PREVIEW         │
│     (Paper style)           │
│     ─────────────────       │
│     Store Name              │
│     Date/Time               │
│     ─────────────────       │
│     Items...                │
│     ─────────────────       │
│     Totals                  │
│     ─────────────────       │
│     QR Code                 │
│     Thank you message       │
├─────────────────────────────┤
│ [Print] [WhatsApp] [Email]  │
│ [New Sale]                  │
└─────────────────────────────┘
```

**Components:**

1. **Success Header**
   - Green checkmark animation
   - "تمت العملية بنجاح!" / "Transaction Successful!"
   - Transaction ID

2. **Receipt Preview**
   - Paper-like card styling
   - Slight shadow
   - Dashed borders for sections

   Content:
   - Store logo & name
   - VAT number
   - Date & time
   - Cashier name
   - Invoice number
   - ─────────────────
   - Items with qty, price, total
   - ─────────────────
   - Subtotal
   - Discount
   - VAT 15%
   - **TOTAL**
   - ─────────────────
   - Payment method
   - Amount paid
   - Change given
   - ─────────────────
   - QR code (ZATCA)
   - "شكراً لزيارتكم"

3. **Action Buttons**
   - 🖨️ طباعة / Print
   - 📱 واتساب / WhatsApp
   - 📧 إيميل / Email
   - All with icons, horizontal layout

4. **New Sale Button**
   - "عملية جديدة" / "New Sale"
   - Full width, Primary

---

## Screen 11/25: Quick Sale Screen

### Screen Information
| Property | Value |
|----------|-------|
| Screen Name | Quick Sale |
| Arabic Name | بيع سريع |
| File | `quick_sale_screen.dart` |
| Purpose | Fast checkout without product selection |

### Design Requirements

**Layout:**
```
┌─────────────────────────────┐
│ AMOUNT INPUT                │
│ ┌─────────────────────────┐│
│ │      SAR 0.00           ││
│ └─────────────────────────┘│
│                             │
│ ┌───┬───┬───┐              │
│ │ 7 │ 8 │ 9 │              │
│ ├───┼───┼───┤              │
│ │ 4 │ 5 │ 6 │              │
│ ├───┼───┼───┤              │
│ │ 1 │ 2 │ 3 │              │
│ ├───┼───┼───┤              │
│ │ . │ 0 │ ⌫ │              │
│ └───┴───┴───┘              │
│                             │
│ Quick amounts:              │
│ [10] [25] [50] [100] [200] │
│                             │
│ Description (optional):     │
│ [____________________]      │
│                             │
│ [         PAY         ]     │
└─────────────────────────────┘
```

**Components:**

1. **Header**
   - Back button
   - "بيع سريع" / "Quick Sale" - H2

2. **Amount Display**
   - Large font (48px)
   - SAR prefix
   - Right-aligned numbers
   - Cursor blink animation

3. **Numeric Keypad**
   - Same style as Manager Approval
   - Includes decimal point
   - Clear/backspace button

4. **Quick Amount Buttons**
   - Horizontal scroll
   - Common amounts: 10, 25, 50, 100, 200, 500
   - Outlined style

5. **Description Input**
   - Optional
   - Single line text
   - Placeholder: "وصف (اختياري)" / "Description (optional)"

6. **Pay Button**
   - Full width
   - Primary color
   - Disabled if amount = 0

---

## Screen 12/25: Hold Orders Screen

### Screen Information
| Property | Value |
|----------|-------|
| Screen Name | Hold Orders |
| Arabic Name | الطلبات المعلقة |
| File | `hold_orders_screen.dart` |
| Purpose | View and resume held orders |

### Design Requirements

**Layout:**
- List of held orders
- Search/filter options
- Actions per order

**Components:**

1. **Header**
   - "الطلبات المعلقة" / "Hold Orders"
   - Count badge
   - Search icon

2. **Filter Bar**
   - Today / This Week / All
   - Search by note/customer

3. **Orders List**
   - Card per order:
     ```
     ┌─────────────────────────────────┐
     │ #HD-001        10:30 AM Today   │
     │ ─────────────────────────────── │
     │ 👤 أحمد محمد                    │
     │ 📝 طلب انتظار العميل            │
     │ ─────────────────────────────── │
     │ 5 items       SAR 245.00        │
     │ [Resume]              [Delete]  │
     └─────────────────────────────────┘
     ```

4. **Order Card Details:**
   - Hold ID & Time
   - Customer name (if selected)
   - Note/reason
   - Item count & total
   - Resume button (Primary)
   - Delete button (with confirmation)

5. **Empty State**
   - Illustration
   - "لا توجد طلبات معلقة"
   - "Held orders will appear here"

---

## Screen 13/25: Favorites Screen

### Screen Information
| Property | Value |
|----------|-------|
| Screen Name | Favorites |
| Arabic Name | المفضلة |
| File | `favorites_screen.dart` |
| Purpose | Quick access to frequently sold items |

### Design Requirements

**Layout:**
- Grid of favorite products
- Edit mode toggle
- Add from products

**Components:**

1. **Header**
   - "المفضلة" / "Favorites"
   - Edit button (toggles edit mode)

2. **Products Grid**
   - Large cards for easy tapping
   - 3 columns desktop, 2 mobile
   - Card:
     - Product image
     - Name
     - Price
     - Remove button (edit mode only)

3. **Add Button**
   - FAB or empty slot card
   - "+" icon
   - Opens product picker

4. **Edit Mode:**
   - Cards shake slightly
   - Remove badges visible
   - Drag to reorder

5. **Empty State:**
   - "أضف منتجاتك المفضلة"
   - "Add your favorite products for quick access"
   - Add button

---

# 📦 MODULE 4: PRODUCTS (4 Screens)

---

## Screen 14/25: Products List Screen

### Screen Information
| Property | Value |
|----------|-------|
| Screen Name | Products List |
| Arabic Name | المنتجات |
| File | `products_screen.dart` |
| Purpose | View and manage all products |

### Design Requirements

**Layout:**
```
┌─────────────────────────────────────┐
│ Products                    [+ Add] │
│ ────────────────────────────────────│
│ [Search............] [Filter] [⊞⊟] │
│ ────────────────────────────────────│
│ Categories: [All] [Food] [Drinks].. │
│ ────────────────────────────────────│
│ ┌─────┬─────┬─────┬─────┐          │
│ │ Prod│ Prod│ Prod│ Prod│          │
│ ├─────┼─────┼─────┼─────┤          │
│ │ Prod│ Prod│ Prod│ Prod│          │
│ └─────┴─────┴─────┴─────┘          │
│ ────────────────────────────────────│
│ Showing 24 of 156 products          │
└─────────────────────────────────────┘
```

**Components:**

1. **Header**
   - "المنتجات" / "Products" - H1
   - Add button (Primary)

2. **Search & Actions Bar**
   - Search with debounce
   - Filter button (opens bottom sheet/modal)
   - View toggle: Grid / List

3. **Categories Chips**
   - Horizontal scroll
   - "الكل" first with count
   - Other categories
   - Active: Filled, Others: Outlined

4. **Products Grid/List**

   Grid Card:
   ```
   ┌─────────────────┐
   │   [Image]       │
   │                 │
   │ Product Name    │
   │ Category        │
   │ SAR 25.00       │
   │ Stock: 45       │
   │ [⋮ Menu]        │
   └─────────────────┘
   ```

   List Row:
   ```
   ┌──────────────────────────────────────────┐
   │ [Img] Name          Category  Price Stock│
   └──────────────────────────────────────────┘
   ```

5. **Filter Bottom Sheet**
   - Category multi-select
   - Price range slider
   - Stock status (All, In Stock, Low, Out)
   - Sort by (Name, Price, Stock, Recent)
   - Apply & Clear buttons

6. **Product Actions Menu**
   - View details
   - Edit
   - Duplicate
   - Print barcode
   - Delete

7. **Pagination/Infinite Scroll**
   - Load more on scroll
   - "Showing X of Y products"

---

## Screen 15/25: Product Detail Screen

### Screen Information
| Property | Value |
|----------|-------|
| Screen Name | Product Detail |
| Arabic Name | تفاصيل المنتج |
| File | `product_detail_screen.dart` |
| Purpose | View complete product information |

### Design Requirements

**Layout:**
```
┌─────────────────────────────────────┐
│ ← Product Name              [Edit]  │
│ ────────────────────────────────────│
│        [Large Product Image]        │
│                                     │
│ ────────────────────────────────────│
│ Price & Stock Cards                 │
│ ────────────────────────────────────│
│ Details Section                     │
│ ────────────────────────────────────│
│ Barcode Section                     │
│ ────────────────────────────────────│
│ Stock History                       │
│ ────────────────────────────────────│
│ Sales Analytics                     │
└─────────────────────────────────────┘
```

**Components:**

1. **Header**
   - Back button
   - Product name - H2
   - Edit button
   - More menu (Delete, Duplicate)

2. **Image Gallery**
   - Main image (large)
   - Thumbnail row if multiple
   - Tap to zoom

3. **Quick Info Cards Row**
   - Price card: SAR 25.00
   - Cost card: SAR 15.00
   - Profit card: SAR 10.00 (40%)
   - Stock card: 45 units

4. **Details Section**
   - SKU
   - Barcode
   - Category
   - Description
   - Unit (piece, kg, etc.)
   - Tax status

5. **Barcode Section**
   - Visual barcode display
   - Print button
   - Copy button

6. **Stock History**
   - Recent stock movements
   - Date, Type, Quantity, Reference
   - View all link

7. **Sales Analytics**
   - Units sold (30 days)
   - Revenue
   - Mini chart

---

## Screen 16/25: Product Form Screen

### Screen Information
| Property | Value |
|----------|-------|
| Screen Name | Product Form |
| Arabic Name | إضافة/تعديل منتج |
| File | `product_form_screen.dart` |
| Purpose | Add or edit product |

### Design Requirements

**Layout:**
- Scrollable form
- Section cards
- Sticky save button

**Form Sections:**

1. **Basic Information Card**
   - Product image upload
   - Name (required) - Arabic & English
   - SKU (auto-generate option)
   - Barcode (scan or enter)
   - Category dropdown
   - Description

2. **Pricing Card**
   - Cost price
   - Selling price
   - Profit margin (calculated)
   - Tax toggle (VAT 15%)

3. **Inventory Card**
   - Track inventory toggle
   - Current stock
   - Low stock alert level
   - Unit type dropdown

4. **Variants Card (Optional)**
   - Enable variants toggle
   - Size, Color, etc.
   - Variant price adjustments

5. **Form Actions**
   - Cancel button
   - Save button (Primary)
   - Save & Add Another (Secondary)

**Validation:**
- Name required
- Price > 0
- Real-time validation
- Error messages below fields

---

## Screen 17/25: Product Categories Screen

### Screen Information
| Property | Value |
|----------|-------|
| Screen Name | Categories |
| Arabic Name | الفئات |
| File | `product_categories_screen.dart` |
| Purpose | Manage product categories |

### Design Requirements

**Layout:**
- List of categories
- Drag to reorder
- Add/Edit modal

**Components:**

1. **Header**
   - "الفئات" / "Categories"
   - Add button

2. **Categories List**
   - Drag handle
   - Color indicator
   - Category name
   - Product count
   - Edit/Delete actions

   ```
   ┌─────────────────────────────────────┐
   │ ≡  🟢 Food           45 products ⋮ │
   ├─────────────────────────────────────┤
   │ ≡  🔵 Beverages      23 products ⋮ │
   ├─────────────────────────────────────┤
   │ ≡  🟡 Snacks         67 products ⋮ │
   └─────────────────────────────────────┘
   ```

3. **Add/Edit Modal**
   - Category name (AR & EN)
   - Color picker
   - Icon picker (optional)
   - Save/Cancel

---

# 📊 MODULE 5: INVENTORY (3 Screens)

---

## Screen 18/25: Inventory Main Screen

### Screen Information
| Property | Value |
|----------|-------|
| Screen Name | Inventory |
| Arabic Name | المخزون |
| File | `inventory_screen.dart` |
| Purpose | Overview of inventory status |

### Design Requirements

**Layout:**
```
┌─────────────────────────────────────┐
│ Inventory                           │
│ ────────────────────────────────────│
│ [Total] [Low] [Out] [Expiring]      │
│ ────────────────────────────────────│
│ Quick Actions                       │
│ [Adjust] [Transfer] [Count]         │
│ ────────────────────────────────────│
│ Products List with Stock            │
│ ────────────────────────────────────│
└─────────────────────────────────────┘
```

**Components:**

1. **Stats Cards**
   - Total items: 156
   - Low stock: 12 (Warning)
   - Out of stock: 3 (Error)
   - Expiring soon: 5 (Warning)

2. **Quick Actions**
   - تعديل المخزون / Adjust Stock
   - نقل بين الفروع / Transfer
   - جرد المخزون / Stock Count
   - تنبيهات / Alerts

3. **Products Table**
   - Image, Name, SKU
   - Current Stock
   - Min Level
   - Status badge
   - Actions

4. **Stock Status Badges**
   - In Stock: Green
   - Low Stock: Orange
   - Out of Stock: Red
   - Expiring: Yellow

---

## Screen 19/25: Stock Adjustment Screen

### Screen Information
| Property | Value |
|----------|-------|
| Screen Name | Stock Adjustment |
| Arabic Name | تعديل المخزون |
| File | `stock_adjustment_screen.dart` |
| Purpose | Add or remove stock |

### Design Requirements

**Layout:**
```
┌─────────────────────────────────────┐
│ ← Stock Adjustment                  │
│ ────────────────────────────────────│
│ Product Search                      │
│ [Selected Product Card]             │
│ ────────────────────────────────────│
│ Adjustment Type                     │
│ [Add] [Remove] [Set]                │
│ ────────────────────────────────────│
│ Quantity: [- 0 +]                   │
│ ────────────────────────────────────│
│ Reason: [Dropdown]                  │
│ Notes: [____________]               │
│ ────────────────────────────────────│
│ [       APPLY       ]               │
└─────────────────────────────────────┘
```

**Components:**

1. **Product Selector**
   - Search input
   - Barcode scan button
   - Selected product card shows:
     - Image, Name, SKU
     - Current stock
     - Last adjustment date

2. **Adjustment Type**
   - Add (+): Receiving, Returns, Correction
   - Remove (-): Damage, Loss, Correction
   - Set (=): Stock count adjustment

3. **Quantity Input**
   - Large number display
   - +/- buttons
   - Direct input
   - Shows new stock level preview

4. **Reason & Notes**
   - Reason dropdown:
     - Received shipment
     - Customer return
     - Damaged
     - Lost/Stolen
     - Stock count correction
     - Other
   - Notes textarea

5. **Apply Button**
   - Shows summary: "Add 50 units to Product X?"
   - Requires confirmation

---

## Screen 20/25: Inventory Alerts Screen

### Screen Information
| Property | Value |
|----------|-------|
| Screen Name | Inventory Alerts |
| Arabic Name | تنبيهات المخزون |
| File | `inventory_alerts_screen.dart` |
| Purpose | View and manage stock alerts |

### Design Requirements

**Layout:**
- Tabs: Low Stock, Out of Stock, Expiring
- List of alerts
- Quick actions

**Components:**

1. **Tabs**
   - منخفض / Low Stock (12)
   - نفذ / Out of Stock (3)
   - قارب الانتهاء / Expiring (5)

2. **Alert Cards**
   ```
   ┌─────────────────────────────────────┐
   │ [!] Product Name                    │
   │     Current: 5  |  Min: 20          │
   │     Last sold: 2 hours ago          │
   │     [Order] [Adjust] [Dismiss]      │
   └─────────────────────────────────────┘
   ```

3. **Bulk Actions**
   - Select all
   - Create purchase order
   - Dismiss selected

4. **Alert Settings Link**
   - Configure alert thresholds

---

# 👥 MODULE 6: CUSTOMERS (3 Screens)

---

## Screen 21/25: Customers List Screen

### Screen Information
| Property | Value |
|----------|-------|
| Screen Name | Customers |
| Arabic Name | العملاء |
| File | `customers_screen.dart` |
| Purpose | View and manage customers |

### Design Requirements

**Layout:**
```
┌─────────────────────────────────────┐
│ Customers                   [+ Add] │
│ ────────────────────────────────────│
│ [Search...] [Filter] [Export]       │
│ ────────────────────────────────────│
│ Customer Cards/Table                │
│ ────────────────────────────────────│
└─────────────────────────────────────┘
```

**Components:**

1. **Header**
   - Title + count
   - Add customer button

2. **Search & Filter**
   - Search by name/phone
   - Filter: All, With Debt, VIP
   - Export button

3. **Customer Cards**
   ```
   ┌─────────────────────────────────────┐
   │ [Avatar] أحمد محمد          [VIP]  │
   │          0512345678                 │
   │          ahmed@email.com            │
   │ ─────────────────────────────────── │
   │ Orders: 24  |  Total: SAR 4,560    │
   │ Debt: SAR 150                       │
   └─────────────────────────────────────┘
   ```

4. **Customer Actions**
   - View details
   - New sale
   - Send message
   - View debt

---

## Screen 22/25: Customer Detail Screen

### Screen Information
| Property | Value |
|----------|-------|
| Screen Name | Customer Detail |
| Arabic Name | تفاصيل العميل |
| File | `customer_detail_screen.dart` |
| Purpose | View customer profile and history |

### Design Requirements

**Layout:**
```
┌─────────────────────────────────────┐
│ ← Customer Name            [Edit]   │
│ ────────────────────────────────────│
│ [Avatar]                            │
│ Name, Phone, Email                  │
│ ────────────────────────────────────│
│ Stats Cards                         │
│ ────────────────────────────────────│
│ [Orders] [Payments] [Notes] Tabs    │
│ ────────────────────────────────────│
│ Tab Content                         │
│ ────────────────────────────────────│
│ [New Sale] [Send Message]           │
└─────────────────────────────────────┘
```

**Components:**

1. **Profile Header**
   - Large avatar
   - Name, Phone, Email
   - VIP badge if applicable
   - Member since date

2. **Stats Cards**
   - Total orders
   - Total spent
   - Average order
   - Outstanding debt

3. **Tabs**
   - Orders history
   - Payments/Ledger
   - Notes

4. **Quick Actions**
   - New sale with customer
   - Send WhatsApp
   - Add payment (if debt)

---

## Screen 23/25: Customer Debt Screen

### Screen Information
| Property | Value |
|----------|-------|
| Screen Name | Customer Debt |
| Arabic Name | ديون العميل |
| File | `customer_debt_screen.dart` |
| Purpose | Manage customer debt and payments |

### Design Requirements

**Layout:**
```
┌─────────────────────────────────────┐
│ ← Customer Debt                     │
│ ────────────────────────────────────│
│ Outstanding: SAR 1,250              │
│ ────────────────────────────────────│
│ [Add Payment]                       │
│ ────────────────────────────────────│
│ Transaction History                 │
│ ────────────────────────────────────│
│ - Invoice #123  +500                │
│ - Payment       -200                │
│ - Invoice #124  +950                │
│ ────────────────────────────────────│
└─────────────────────────────────────┘
```

**Components:**

1. **Debt Summary**
   - Total outstanding (large)
   - Last payment date
   - Overdue amount (if any)

2. **Add Payment Button**
   - Opens payment modal
   - Amount input
   - Payment method
   - Reference/Notes

3. **Transaction History**
   - Timeline view
   - Invoices (add to debt)
   - Payments (reduce debt)
   - Running balance

4. **Send Reminder**
   - WhatsApp reminder
   - Customizable message

---

# 📈 MODULE 7: REPORTS (2 Screens)

---

## Screen 24/25: Reports Hub Screen

### Screen Information
| Property | Value |
|----------|-------|
| Screen Name | Reports Hub |
| Arabic Name | التقارير |
| File | `reports_screen.dart` |
| Purpose | Central access to all reports |

### Design Requirements

**Layout:**
```
┌─────────────────────────────────────┐
│ Reports                             │
│ ────────────────────────────────────│
│ Quick Stats                         │
│ ────────────────────────────────────│
│ Report Categories Grid              │
│ ┌─────────┬─────────┬─────────┐    │
│ │ Sales   │Inventory│Financial│    │
│ ├─────────┼─────────┼─────────┤    │
│ │Customers│  Staff  │   Tax   │    │
│ └─────────┴─────────┴─────────┘    │
│ ────────────────────────────────────│
│ Recent Reports                      │
└─────────────────────────────────────┘
```

**Components:**

1. **Quick Stats**
   - Today's sales
   - This month
   - Comparison to last period

2. **Report Categories**
   - Sales Reports
   - Inventory Reports
   - Financial Reports
   - Customer Reports
   - Staff Reports
   - Tax Reports

   Each card:
   - Icon
   - Category name
   - Sub-reports count

3. **Recent/Favorite Reports**
   - Quick access to frequently used
   - Star to favorite

4. **Export Options**
   - PDF
   - Excel
   - Print

---

## Screen 25/25: Sales Report Screen

### Screen Information
| Property | Value |
|----------|-------|
| Screen Name | Sales Report |
| Arabic Name | تقرير المبيعات |
| File | `sales_report_screen.dart` |
| Purpose | Detailed sales analytics |

### Design Requirements

**Layout:**
```
┌─────────────────────────────────────┐
│ ← Sales Report     [Date Range ▼]   │
│ ────────────────────────────────────│
│ Summary Cards                       │
│ ────────────────────────────────────│
│ Sales Chart                         │
│ ────────────────────────────────────│
│ Top Products Table                  │
│ ────────────────────────────────────│
│ Sales by Category                   │
│ ────────────────────────────────────│
│ [Export PDF] [Export Excel]         │
└─────────────────────────────────────┘
```

**Components:**

1. **Date Range Selector**
   - Today
   - Yesterday
   - This Week
   - This Month
   - Custom Range

2. **Summary Cards**
   - Total Sales
   - Total Orders
   - Average Order Value
   - Profit Margin

3. **Sales Chart**
   - Line chart for trend
   - Toggle daily/weekly
   - Compare to previous period

4. **Top Products Table**
   - Rank, Product, Qty Sold, Revenue
   - Top 10 by default

5. **Sales by Category**
   - Pie/Donut chart
   - Legend with percentages

6. **Sales by Payment Method**
   - Cash vs Card breakdown

7. **Export Buttons**
   - PDF with branding
   - Excel for data analysis

---

# 📝 NOTES FOR DESIGNERS

## Consistency Checklist
- [ ] All colors from the defined palette
- [ ] 8px spacing grid followed
- [ ] Border radius consistent (32/16/12/8)
- [ ] Typography hierarchy respected
- [ ] RTL/LTR layouts provided
- [ ] Dark/Light mode variants
- [ ] All 6 languages considered
- [ ] Loading states included
- [ ] Empty states designed
- [ ] Error states handled
- [ ] Touch targets 44px minimum
- [ ] Accessibility contrast 4.5:1

## File Naming Convention
- `screen_name_light_en.png`
- `screen_name_light_ar.png`
- `screen_name_dark_en.png`
- `screen_name_dark_ar.png`

## Responsive Breakpoints
- Mobile: 375px width
- Tablet: 768px width
- Desktop: 1440px width

---

*Generated for POS App UX Pilot Design*
*Version 1.0*
