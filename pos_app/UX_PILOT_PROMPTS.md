# UX Pilot Design Prompts — Alhai POS App

## Global Design Requirements (Apply to ALL screens)

```
Design a modern, clean UI screen for a grocery/supermarket POS web application called "Alhai POS".

BRAND:
- Primary color: #10B981 (Fresh Emerald Green)
- Secondary color: #F97316 (Orange)
- Font: Tajawal (Arabic-first)
- Style: Modern, minimal, professional — suitable for Saudi Arabia market

LAYOUT REQUIREMENTS:
- Desktop (>900px): Left sidebar (280px collapsed to 80px) + Top header bar + Main content area
- Mobile (<900px): Bottom navigation or hamburger drawer + Top header + Full-width content
- The sidebar has: store logo, navigation items with icons, user profile card at bottom
- The header has: page title, search bar (desktop only), notification bell, user avatar

MANDATORY REQUIREMENTS:
- RTL layout (Arabic as primary language, English as secondary)
- Dark mode AND Light mode versions (show both)
- Responsive: Desktop AND Mobile versions (show both)
- Cards: border-radius 12px, subtle border (#E5E7EB light / #374151 dark), no heavy shadows
- Buttons: border-radius 12px, primary filled (#10B981), secondary outlined
- Spacing: 8px grid system (8, 16, 24, 32, 40)
- Icons: Material Design rounded style
- Status colors: Success #22C55E, Warning #F59E0B, Error #EF4444, Info #3B82F6
- Empty states: Illustration + text + action button
- Loading states: Skeleton shimmer placeholders
- All text in Arabic (with English labels where appropriate for codes/IDs)
```

---

## Mandatory UX Rules (Apply to EVERY screen)

```
RULE 1 — TABLE → CARDS:
- Desktop: Use data tables with sortable columns, sticky headers, and pagination
- Mobile: Convert ALL tables to card lists with "View Details" bottom sheet or expand
- Never show horizontal-scrolling tables on mobile

RULE 2 — ACTIONS PATTERN:
- Desktop: ONE primary CTA in the header + "⋯ More" dropdown for secondary actions
- Mobile: Either FAB OR Bottom action bar (choose one per screen, not both) + "⋯" for rest
- Row/card actions: Maximum 1 visible icon + "⋯" menu for additional actions
- Never show more than 3 action buttons in a single row

RULE 3 — LTR CODES INSIDE RTL:
- All codes (SKU, Barcode, Invoice#, Receipt#, Order#, PO#) must display in:
  - Monospace font (e.g., Courier, Source Code Pro)
  - LTR text direction (even inside RTL layout)
  - With a copy-to-clipboard button (icon) next to each code
  - Show "تم النسخ" (Copied) toast on tap

RULE 4 — SYSTEM STATES (Unified across all screens):
- Empty state: Centered illustration (SVG) + descriptive Arabic text + primary CTA button
- Loading state: Skeleton shimmer placeholders matching the final layout shape
- Error state: Error illustration + error message + "إعادة المحاولة" (Retry) button
- No results: "لا توجد نتائج مطابقة" + suggestion to adjust filters/search

RULE 5 — ACCESSIBILITY:
- Focus ring: Visible 2px ring on all interactive elements (keyboard navigation)
- Dark mode contrast: All text must meet WCAG AA contrast ratio (4.5:1 minimum)
- Disabled state: Reduced opacity (0.5) + no pointer cursor + tooltip explaining why disabled
- Hover state: Subtle background color change on desktop (not applicable on mobile)
- Touch targets: Minimum 44x44px on mobile

RULE 6 — CONFIRMATION & UNDO:
- Destructive actions (Delete/Void/Cancel/Deactivate): ALWAYS show Confirmation dialog with:
  - Warning icon + clear description of consequences
  - "إلغاء" (Cancel) as outlined button + destructive action as red filled button
- Where applicable, offer "تراجع" (Undo) via a snackbar for 5 seconds after action
- Non-destructive but important actions (Approve/Submit/Send): Show summary before confirming
```

---

## SECTION 1: Products Management (3 screens)

### Screen 1: Product Detail
```
Screen name: "تفاصيل المنتج" (Product Detail)

Purpose: View complete product information with quick actions.

Layout - Desktop:
- App shell (sidebar + header)
- Main content split: Product info card (60%) + Side panel (40%)

Left section (Product Info):
- Large product image (240px) with edit overlay icon
- Product name (large bold), SKU badge, barcode badge
- Price card: Selling price (large green), Cost price (small muted)
- Status badge: Active/Inactive/Out of Stock
- Description text area

Right section (Side Panel):
- Stock card: Current quantity (large number), low stock threshold, reorder point
- "تسجيل حركة مخزون" (Record stock movement) small button inside stock card
- Stock movement mini chart (last 7 days bar chart, newest on right even in RTL)
- Category & supplier info card
- Quick stats: Total sold, Revenue generated, Last sold date

Bottom section:
- Tabs: "حركة المخزون" (Stock Movement) | "تاريخ الأسعار" (Price History) | "المبيعات" (Sales)
- Desktop: data table per tab | Mobile: card list per tab

Action buttons:
- Desktop: "تعديل" (Edit) outlined button + "⋯" menu (Delete, Print Barcode, Share)
- "نسخ SKU" and "نسخ الباركود" copy buttons next to each code badge

Mobile layout:
- Single column scrollable
- Image at top (full width, 200px height)
- Collapsible sections for details
- Bottom action bar: Edit, Print Barcode, Share (NO FAB — use bottom bar only)
- Tabs content: card lists instead of tables
```

---

### Screen 2: Product Form (Add/Edit)
```
Screen name: "إضافة منتج" / "تعديل منتج" (Add/Edit Product)

Purpose: Create new product or edit existing one with all fields.

Layout - Desktop:
- App shell (sidebar + header)
- Two-column form: Main fields (60%) + Media & extras (40%)

Left column (Main Fields):
- Section "المعلومات الأساسية" (Basic Info):
  - Product name (text input, required, with Arabic validation message below)
  - Barcode (text input + scan button icon, with validation)
  - SKU (auto-generated) with "إعادة توليد" (Regenerate) + "تحرير" (Edit) inline buttons
  - Category dropdown with search (required, with validation)
  - Brand/Supplier dropdown

- Section "التسعير" (Pricing):
  - Selling price (number input, large, green highlight, required with validation)
  - Cost price (number input)
  - Profit margin (auto-calculated, read-only chip)
  - Tax rate dropdown (15% VAT default)
  - Price includes VAT toggle

- Section "المخزون" (Inventory):
  - Current stock quantity
  - Low stock alert threshold
  - Reorder quantity
  - Unit type dropdown (piece, kg, liter, box)
  - Expiry date picker (optional)

Right column (Media & Extras):
- Product image upload (drag & drop zone, 200x200 preview)
  - States: idle / uploading (progress) / uploaded (preview) / failed (retry button)
- Additional images gallery (up to 4)
- Description textarea (Arabic)
- Tags/keywords chips input
- Toggle switches: Active, Featured, Track inventory

Bottom bar (sticky):
- Cancel button (outlined)
- Save as Draft button (outlined)
- Save button (filled primary)
- Show "تغييرات غير محفوظة" (Unsaved changes) indicator when form is dirty

Mobile layout:
- Single column, sections as Accordion (collapsible)
- Image upload at top
- Sticky bottom bar: Save (primary) only — Cancel inside "⋯" to reduce clutter
- Required fields: clear asterisk + short Arabic error messages below field
```

---

### Screen 3: Product Categories
```
Screen name: "تصنيفات المنتجات" (Product Categories)

Purpose: Manage product categories with drag-and-drop reordering and hierarchy.

Layout - Desktop:
- App shell (sidebar + header)
- Split view: Category tree (40%) + Category detail (60%)

Left panel (Category Tree):
- Search bar at top
- "وضع الترتيب" (Reorder Mode) toggle button — drag handles only visible when enabled
- Expandable tree list of categories
- Each item: Colored icon (circle 32px) + Category name + Product count badge
- Drag handle icon on the right for reordering (only in reorder mode)
- Active category highlighted with primary color left border
- "إضافة تصنيف" (Add Category) button at bottom

Right panel (Category Detail):
- When category selected:
  - Category icon (large, editable)
  - Name field (Arabic + English)
  - Parent category dropdown
  - Color picker (8 preset colors)
  - Product count stat
  - Toggle: Active/Inactive
  - Products grid preview (first 6 products as small cards)
- When no category selected:
  - Empty state illustration: "اختر تصنيفاً لعرض التفاصيل"

Action buttons:
- Desktop: "إضافة" (Add) CTA + "⋯" menu (Delete with warning about products impact)
- Delete: Confirmation dialog explaining "سيتم نقل X منتج إلى التصنيف الافتراضي" (X products will be moved to default category)
- Prevent deleting category with products without handling them first
- Reorder save (appears after drag changes)

Mobile layout:
- Single list view
- Tap to open details in Bottom sheet (not inline expand)
- Long press to drag reorder (only in reorder mode)
- Bottom sheet for add/edit category
- "تصنيف افتراضي" (Default category) cannot be deleted
```

---

## SECTION 2: Invoices & Orders (4 screens)

### Screen 4: Invoices List
```
Screen name: "الفواتير" (Invoices)

Purpose: Browse, search, and filter all invoices with summary statistics.

Layout - Desktop:
- App shell (sidebar + header)
- Top stats row: 4 stat cards in a row
  - Total invoices (blue icon), Paid total (green), Pending total (orange), Overdue total (red)
- Filter bar (sticky): Search input + Status dropdown + Date range picker + "حفظ الفلتر" (Save filter) optional
- Tab bar: "الكل" | "مدفوعة" | "معلقة" | "متأخرة" | "ملغاة"
- Data table with columns:
  - Invoice # (bold, clickable link, monospace LTR + copy)
  - Customer name
  - Date
  - Amount (right-aligned, bold)
  - Status badge (color-coded chip)
  - Payment method icon
  - Actions: View (icon) + "⋯" (Print, PDF, WhatsApp)
- Pagination bar at bottom
- Empty states: "لا توجد فواتير" + "لا توجد نتائج مطابقة" (when filtered)

Action buttons:
- "إنشاء فاتورة" (Create Invoice) - primary button in header
- Bulk actions: Select all checkbox → bulk bar appears (print, export)

Mobile layout:
- Stat cards: horizontal scroll (2 visible at a time)
- Filter: chips bar + "فلترة" button opens Bottom sheet with full filters
- Card list instead of table (each card: invoice#, customer, amount, status badge, date)
- Row actions: tap card → detail, "⋯" for Print/WhatsApp
- Pull to refresh
- FAB: Create invoice
```

---

### Screen 5: Invoice Detail
```
Screen name: "تفاصيل الفاتورة" (Invoice Detail)

Purpose: View full invoice with items, totals, payment status, and ZATCA QR.

Layout - Desktop:
- App shell (sidebar + header)
- Status banner (sticky top of card): Paid (green) / Pending (orange) / Overdue (red) / Voided (grey strikethrough)
  - If voided/returned: show reason text next to status
- Invoice card (centered, max-width 700px, receipt-like styling):
  - Header: Store logo + Store name + Address + VAT number
  - Divider line (dashed)
  - "فاتورة ضريبية مبسطة" title
  - Invoice number (monospace LTR + copy button), Date, Cashier name
  - Divider
  - Items table: Product name | Qty | Price | Total
  - Divider
  - Subtotal row
  - Discount row (if applicable, green)
  - VAT 15% row
  - Total row (large, bold, highlighted background)
  - Divider
  - Payment method + amount paid + change
  - Divider
  - ZATCA QR code (centered, 140px)
    - If QR unavailable: show reason (disconnected/incomplete settings) + CTA "فحص الاتصال"
  - "يشمل ضريبة القيمة المضافة 15%" text
  - Footer: "شكراً لزيارتكم!"

Side panel (desktop only):
- Timeline: Invoice created → Paid → Printed events
- Related actions: Print, Download PDF, WhatsApp, Duplicate, Void, Return (in "⋯" menu)
- Customer info card (if linked)
- Payment details card

Mobile layout:
- Full-width scrollable invoice card
- Bottom action bar: Print, Share, WhatsApp — rest in "⋯"
```

---

### Screen 6: Order History
```
Screen name: "سجل الطلبات" (Order History)

Purpose: View and filter all past orders by status, channel, date.

Layout - Desktop:
- App shell (sidebar + header)
- Top: Quick stats row (Total orders, Completed, Pending, Cancelled - with counts)
- Filter bar: Search + Status filter chips (All/Completed/Pending/Cancelled) + Channel filter chips (POS/Online/WhatsApp) + Date range
- Order list: Click card → opens Side panel with full details (instead of inline expand)
  - Each card: Order # (bold, monospace LTR) + Status badge + Date
  - Customer name + phone icon
  - Items count + Total amount (large, bold)
  - Payment method chip + Channel chip
  - "مدفوع/غير مدفوع" (Paid/Unpaid) badge

Action buttons:
- Export inside "⋯" menu (CSV/PDF options)
- Click card to view full order detail in side panel

Mobile layout:
- Filter chips: horizontal scroll
- Cards stack vertically
- Swipe right on card for quick actions (reprint receipt, reorder) with confirmation
- Tap card → full detail page
```

---

### Screen 7: Order Tracking
```
Screen name: "تتبع الطلبات" (Order Tracking)

Purpose: Live tracking of active delivery orders with driver info.

Layout - Desktop:
- App shell (sidebar + header)
- Split view: Order list (40%) + Map view (60%)

Left panel (Active Orders):
- Filter tabs: "جميع" | "قيد التحضير" | "قيد التوصيل"
- Order cards:
  - Order # + Time elapsed badge
  - Customer name + address (truncated)
  - Driver name + vehicle info
  - Status stepper (Received → Preparing → On the way → Delivered)
    - Each step clickable to show timestamp (mini timeline)
  - ETA badge (e.g., "15 دقيقة")
  - "آخر تحديث قبل X دقيقة" (Last updated X min ago) indicator

Right panel (Map):
- Map placeholder with driver pin + customer pin + route line
- Driver info overlay card at bottom of map

Edge states:
- "لا توجد طلبات نشطة" empty state illustration
- "الخريطة غير متاحة" (Map unavailable) fallback
- "بدون صلاحية موقع" (No location permission) with CTA

Mobile layout:
- Map takes 50% top of screen
- Scrollable order list at bottom 50%
- Bottom sheet expandable with CTA: "اتصال بالسائق" / "واتساب"
```

---

## SECTION 3: Customer Management (4 screens)

### Screen 8: Customer Detail
```
Screen name: "تفاصيل العميل" (Customer Detail)

Purpose: View comprehensive customer profile with purchase history and financial status.

Layout - Desktop:
- App shell (sidebar + header)
- Top: Customer profile card (full width)
  - Avatar (large, 64px, initials) + Name (headline) + Phone + Email
  - 4 stat chips in row: Total purchases | Balance | Loyalty points | Last visit
  - Status badge: Active/VIP/Blocked
  - CTA: "بيع جديد" (New Sale) primary + "⋯" menu (Edit, WhatsApp, Block/Unblock with reason + audit date)

- Content tabs below:
  - "المشتريات" (Purchases) — recent orders table (desktop) / cards (mobile)
  - "الحساب" (Account) — ledger/transactions
  - "الديون" (Debts) — outstanding amounts with due dates
  - "التحليلات" (Analytics) — spending chart, favorite products, visit frequency

Each tab content:
- Purchases: Table with date, invoice #, amount, status, items count
- Account: Ledger with credit/debit entries, running balance
- Debts: Cards with amount, due date, status (overdue red, upcoming orange)
- Analytics: Mini charts (bar chart for monthly spending, pie for categories)

Mobile layout:
- Profile card: avatar + name + key stat (balance)
- Horizontal tab scroll (remember last selected tab)
- Card-based content per tab
- Analytics on mobile: indicator cards instead of complex charts
```

---

### Screen 9: Customer Debts
```
Screen name: "ديون العملاء" (Customer Debts)

Purpose: Track and manage all customer debts with payment collection.

Layout - Desktop:
- App shell (sidebar + header)
- Top stats: Total debt amount (red, large) + Overdue count (badge) + Collected this month (green)
- Aging breakdown bar: 0-30 days | 30-60 | 60+ (colored segments above tabs)
- Tabs: "الكل" | "متأخرة" | "قادمة" | "مسددة"
- Sort dropdown: By amount (desc) | By date | By customer name
- Debt list (table format):
  - Customer name + phone
  - Total debt amount (bold, red if overdue)
  - Due date + days overdue badge
  - Last payment date
  - Status chip (overdue/pending/partial)
  - Actions: "تحصيل" (Collect) visible + "⋯" (WhatsApp reminder, View details)

Action buttons:
- "تسجيل دفعة" (Record Payment) opens Drawer with: amount + payment method + notes + receipt reference
- Export report inside "⋯"
- Send bulk reminders: confirmation dialog + message preview before sending

Mobile layout:
- Summary card at top (total debt, overdue)
- Card list with customer name, amount, status, quick "تحصيل" (Collect) button + "⋯"
```

---

### Screen 10: Customer Ledger
```
Screen name: "كشف حساب العميل" (Customer Ledger)

Purpose: Detailed transaction history for a specific customer account.

Layout - Desktop:
- App shell (sidebar + header)
- Customer info bar: Name + Current balance (highlighted)
- Filter row: Date range picker + Transaction type filter (All/Invoice/Payment/Interest/Adjustment)
- Transaction table:
  - Date column
  - Reference # (invoice or receipt number, monospace LTR + copy)
  - Description (Arabic)
  - Debit column (red)
  - Credit column (green)
  - Running balance column (bold) — show "رصيد قبل/بعد" (Before/After balance) clearly
  - Manual adjustment rows highlighted differently
- Summary footer: Opening balance + Total debit + Total credit + Closing balance

Action buttons:
- Desktop: Print statement + "⋯" (Export PDF, Add manual adjustment)
- "تسوية يدوية" (Manual adjustment): requires permission level + mandatory reason field

Mobile layout:
- Customer name + balance card at top
- Filter: type chips (horizontal scroll) + date range in bottom sheet
- Card list: date, description, amount (colored +/-), balance
- Export/Print inside "⋯"
```

---

### Screen 11: Customer Analytics
```
Screen name: "تحليلات العملاء" (Customer Analytics)

Purpose: Visual insights into customer base metrics and trends.

Layout - Desktop:
- App shell (sidebar + header)
- Period selector: Week | Month | Quarter | Year
- Top stats row (4 cards):
  - Total customers (with trend arrow)
  - New customers this period
  - Repeat customer rate % (with tooltip: "نسبة العملاء الذين اشتروا أكثر من مرة")
  - Average spend per visit
- Charts section (2-column grid, limit to 2-3 main charts):
  - Customer growth line chart (new vs returning)
  - Spending distribution pie chart (by category)
  - Additional charts in optional collapsible "عرض المزيد" section:
    - Top 10 customers bar chart (by revenue)
    - Visit frequency histogram
- Best customers table:
  - Rank + Avatar + Name + Orders count + Total spent + Tier badge (Bronze/Silver/Gold/Diamond)
- Add tooltips for metrics definitions (Repeat rate, Churn, etc.)

Mobile layout:
- Period selector: horizontal chips
- Stats: 2x2 grid
- Tabs: "مؤشرات" (Indicators) | "رسوم" (Charts) | "أفضل العملاء" (Top Customers)
- Charts: full width, stacked vertically
- Best customers: cards instead of table
```

---

## SECTION 4: Returns & Transactions (2 screens)

### Screen 12: Returns
```
Screen name: "المرتجعات" (Returns)

Purpose: Process and manage sales returns and purchase returns.

Layout - Desktop:
- App shell (sidebar + header)
- Tabs: "مرتجعات المبيعات" (Sales Returns) | "مرتجعات المشتريات" (Purchase Returns)
- Top stats per tab: Total returns | Total amount | Most returned product
- Filter: Search + Date range + Status filter
- Returns table:
  - Return # (monospace LTR + copy) + Date
  - Original invoice/PO number (linked, monospace LTR)
  - Customer/Supplier name
  - Amount (bold)
  - Reason (chip: defective/wrong item/expired/customer request)
  - Status (pending/approved/refunded/rejected) with Timeline on detail view
  - Actions: View (icon) + "⋯" (Approve, Reject)

Create return flow (Drawer on desktop / Bottom sheet wizard on mobile):
- Step 1: Enter invoice number → auto-load items
- Step 2: Select items to return + quantities
  - Validation: cannot return qty > sold qty — show "الكمية المتاحة للإرجاع: X"
- Step 3: Select reason per item (short list + "أخرى" with required text)
- Step 4: Choose refund method (cash/credit/store credit)
- Step 5: Confirm + Print return receipt
- Consistent wizard across Desktop/Mobile

Mobile layout:
- Tab bar at top
- Card list with return #, amount, status badge
- FAB: New return
- Bottom sheet wizard for return creation steps
```

---

### Screen 13: Void Transaction
```
Screen name: "إلغاء عملية" (Void Transaction)

Purpose: Cancel a complete transaction with safety checks and reason tracking.

Layout - Desktop:
- App shell (sidebar + header)
- Warning banner at top (red/amber background):
  - Warning icon + "هذا الإجراء سيلغي الفاتورة ويعيد المخزون" (This will void the invoice and restore stock)
  - "لا يمكن التراجع عن هذا الإجراء" (This cannot be undone)

- Search section:
  - Large search input: "أدخل رقم الفاتورة" (Enter invoice number)
  - + Barcode scan button (if scanner available)
  - Search button

- When invoice found:
  - Invoice summary card: Invoice #, Date, Customer, Total, Items count
  - "ملخص أثر الإلغاء" (Impact summary): "سيُعاد X أصناف للمخزون، سيُعاد/يُخصم مبلغ Y ر.س"
  - Items list preview (collapsed, expandable)
  - Void reason selector (required):
    - Radio buttons: Customer request | Wrong items | Duplicate | System error | Other
    - Notes textarea (optional, required if "Other")
  - Manager approval section (show when amount > threshold or time > X hours):
    - PIN input for manager
  - Confirmation checkbox: "أؤكد إلغاء هذه العملية"

- When invoice not found:
  - Empty state: "لم يتم العثور على الفاتورة" + suggest barcode scan

Action buttons:
- Cancel (outlined)
- Void Transaction (red filled button, disabled until: reason + checkbox + PIN if needed)

Mobile layout:
- Same flow, single column
- Warning banner full width
- Bottom sticky button bar
```

---

## SECTION 5: Shifts & Cash (4 screens)

### Screen 14: Shifts List
```
Screen name: "الورديات" (Shifts)

Purpose: View all shifts with open/close status and cash summaries.

Layout - Desktop:
- App shell (sidebar + header)
- Current shift status card (highlighted, top):
  - If open: Green border, cashier name, open time, running total
    - CTA: "إغلاق الوردية" (Close Shift) + "تفاصيل" (Details) secondary
  - If no open shift: "لا يوجد وردية مفتوحة" + "فتح وردية جديدة" button

- Stats row: Total shifts today | Total cash sales | Total card sales

- Shifts history table:
  - Shift # + Cashier name
  - Open time + Close time (or "مفتوحة" badge if still open)
  - Opening cash | Total sales | Expected cash | Actual cash
  - Difference (green if match, red if variance)
  - Status badge (open/closed/variance)
  - Actions: View details
- Filter: "فروقات فقط" (Variances only) filter toggle
- Export daily report inside "⋯"

Mobile layout:
- Current shift card at top
- Card list for history with Open/Closed/Variance badges
- FAB: Open new shift
```

---

### Screen 15: Open Shift
```
Screen name: "فتح وردية" (Open Shift)

Purpose: Start a new shift by setting opening cash amount.

Layout - Desktop:
- App shell (sidebar + header)
- Alert: If shift already open → show warning "يوجد وردية مفتوحة بالفعل" + CTA to navigate to it
- Centered card (max-width 500px):
  - Cashier info: Avatar + Name + Role
  - Date/Time display (current, auto-filled)
  - Opening cash input (large number input with currency symbol ر.س)
    - Validation: amount ≥ 0, SAR format
  - Quick amount buttons: 500, 1000, 1500, 2000 (note for designer: make customizable later)
  - Notes textarea (optional)
  - Confirm button (primary, full width)

Mobile layout:
- Same centered card, full width with padding
- Numeric keypad overlay for cash input
- Sticky confirm button at bottom
```

---

### Screen 16: Close Shift
```
Screen name: "إغلاق الوردية" (Close Shift)

Purpose: Close shift with cash reconciliation and variance detection.

Layout - Desktop:
- App shell (sidebar + header)
- Two-column: Summary (50%) + Reconciliation (50%)

Left (Shift Summary):
- Cashier name + Shift duration
- Summary card sections:
  - Opening cash
  - Cash sales (+)
  - Card sales (info only)
  - Returns/Refunds (-)
  - Cash in (+) / Cash out (-)
  - Divider
  - Expected cash (bold, calculated)

Right (Reconciliation):
- Actual cash input (large number input)
- Auto-calculated difference:
  - If match: Green checkmark "متطابق"
  - If surplus: Blue "فائض: +XX ر.س"
  - If shortage: Red "عجز: -XX ر.س"
- "سبب الفروقات" (Variance reason) — REQUIRED if difference ≠ 0
- Denomination counter (optional, collapsible section):
  - 500 x __ | 100 x __ | 50 x __ | 20 x __ | 10 x __ | 5 x __ | 1 x __
  - Auto-sum (fills actual cash automatically when used)
- Notes textarea
- Close shift button (primary, with confirmation dialog showing Expected/Actual/Diff summary)

Mobile layout:
- Steps flow: Summary card → Cash input → Difference display → Confirm
- Each step on its own section
```

---

### Screen 17: Shift Summary (after close)
```
Screen name: "ملخص الوردية" (Shift Summary)

Purpose: Post-close shift report with all details.

Layout - Desktop:
- App shell (sidebar + header)
- If variance exists: Warning banner at top showing variance amount + recorded reason
- Receipt-style card (centered, max-width 600px):
  - Header: Shift # + Date + Duration
  - Cashier info
  - Financial summary table (all rows)
  - Payment method breakdown (pie chart on desktop / simple color bar on mobile)
  - Top sold products (top 5 list + "عرض المزيد" expand for more)
  - Variance indicator (if any)
  - Print button + "⋯" (Export PDF, Share WhatsApp)

Mobile layout:
- Scrollable receipt card
- Bottom bar: Print + Share
```

---

## SECTION 6: Expenses (1 screen)

### Screen 18: Expenses
```
Screen name: "المصروفات" (Expenses)

Purpose: Track and categorize business expenses.

Layout - Desktop:
- App shell (sidebar + header)
- Top summary card (light tinted surface, NOT heavy gradient — keep minimal):
  - Total this month (large) + comparison with last month (trend arrow)
  - Budget progress bar (if budget set)

- Category cards (horizontal scroll or grid):
  - Each: Icon + Category name + Amount + Percentage of total
  - Categories: Rent, Utilities, Salaries, Supplies, Maintenance, Transport, Other
  - Color-coded borders
  - If many categories: show 6 visible + "عرض الكل" (Show all) button

- Filter bar: Date range + Category dropdown + Search
- Expenses table:
  - Date | Description | Category chip | Amount | Payment method | Attachment icon (present/absent indicator)
  - Row actions: View (icon) + "⋯" (Edit, Delete with confirmation, View attachment)

Action buttons:
- "إضافة مصروف" (Add Expense) button in header
- Add dialog: Amount, Category dropdown, Description, Date, Payment method, Attachment upload
  - Attachment: show states (attached/none) + preview + retry on failure

Mobile layout:
- Summary card (compact, no gradient)
- Category chips: horizontal scroll
- Card list for expenses
- FAB: Add expense
- Filters in bottom sheet
```

---

## SECTION 7: Reports (9 screens)

### Screen 19: Sales Analytics
```
Screen name: "تحليلات المبيعات" (Sales Analytics)

Purpose: Dashboard-style view of sales performance with charts.

Layout - Desktop:
- App shell (sidebar + header)
- Period selector (top right, unified with other reports): Today | This Week | This Month | Custom range
- Stats row (4 cards): Total sales | Orders count | Average order | Growth %
- Charts section:
  - Large: Sales trend line chart (main area, 60% width)
  - Side: Sales by payment method doughnut chart (40%)
  - Bottom row: Hourly sales bar chart + Sales by category horizontal bars
- Top products table (bottom section): Rank, product, units, revenue
- Add tooltip: "مصدر البيانات: نقاط البيع فقط" (Data source: POS only) or include online if applicable

Mobile layout:
- Period: dropdown
- Stats: 2x2 grid
- Charts: show 2 main charts + rest in Accordion "عرض المزيد"
- Top products: cards instead of table
- Scrollable
```

---

### Screen 20: Profit Report
```
Screen name: "تقرير الأرباح" (Profit Report)

Purpose: Financial profit/loss analysis.

Layout - Desktop:
- App shell (sidebar + header)
- Period: Week | Month | Quarter | Year tabs
- Hero card: Net profit (large number, green if positive, red if negative) + margin %
- Waterfall chart: Revenue → COGS → Gross Profit → Expenses → Net Profit
  - Designer note: If waterfall is complex, use stacked horizontal bars as alternative
- Breakdown table:
  - Revenue (total sales)
  - Cost of goods sold
  - Gross profit (calculated)
  - Operating expenses (expandable/collapsible: rent, salaries, utilities... with subtotal)
  - Net profit
  - Profit margin %
- "مقارنة الفترة السابقة" (Compare previous period) toggle — shows side-by-side or overlay

Action buttons: Export PDF, Print inside "⋯"

Mobile layout:
- Hero profit card at top
- Breakdown: summary cards (Revenue/Cost/Expenses/Net) + one chart
- Expandable expenses detail
```

---

### Screen 21: Tax Report
```
Screen name: "تقرير الضرائب" (Tax Report)

Purpose: Tax liability summary for ZATCA compliance.

Layout - Desktop:
- App shell (sidebar + header)
- Period: Monthly | Quarterly | Yearly segmented control
- "جاهز للتقديم" / "غير جاهز" (Ready to file / Not ready) badge based on settings completeness
- Net tax due card (highlighted, green border): Amount + Period label
- Two-column breakdown:
  - Left: Sales VAT (output tax) — Total sales, VAT collected
  - Right: Purchase VAT (input tax) — Total purchases, VAT paid
- Net VAT calculation card: Collected - Paid = Due/Refundable
- Tax category breakdown table (Standard 15%, Zero-rated, Exempt)
  - Code column: monospace LTR + copy
- Filing status indicator (Filed/Not filed badge)

Action buttons: Export PDF, Print inside "⋯"
- CTA "File with ZATCA": Disabled with tooltip "(قريباً)" (Coming soon)

Mobile layout:
- Net tax card at top
- Stacked breakdown cards
- Details table in "عرض المزيد"
- Bottom action bar
```

---

### Screen 22: VAT Report
```
Screen name: "تقرير ضريبة القيمة المضافة" (VAT Report)

Purpose: Detailed VAT collected vs paid breakdown.

Layout - Desktop:
- App shell (sidebar + header)
- Date range selector card
- Type filter: "مبيعات" (Sales) | "مشتريات" (Purchases) | "الكل" (All) chips
- Summary cards row: Sales VAT collected | Purchase VAT paid | Net VAT
- Detailed table:
  - Date | Invoice/PO # (monospace LTR) | Type (Sale/Purchase) | Base amount | VAT amount | Total
- Totals footer row (sticky on desktop)
- Pie chart: VAT by category

Action buttons: Export PDF, Export Excel inside "⋯"

Mobile: Summary cards + sortable card list + totals at top
```

---

### Screen 23: Top Products Report
```
Screen name: "أفضل المنتجات" (Top Products)

Purpose: Analyze best and worst performing products.

Layout - Desktop:
- App shell (sidebar + header)
- Date range + Category filter + Sort by (Revenue/Units/Profit)
- Toggle: Top products | Worst products
  - Worst products: tooltip "قد تكون منتجات موسمية" (May be seasonal products)
- Additional filter: "إظهار المنخفض مخزونهم فقط" (Show low stock only) toggle
- Products table:
  - Rank # | Product image (small) + Name | Category | Units sold | Revenue | Profit | Margin % | Stock | Trend arrow
  - Trend: based on comparison with selected period (tooltip explains)
- Bar chart: Top 10 by revenue

Mobile layout:
- Filter chips
- Ranked card list with product image, name, revenue + small indicator bar
- Table columns reduced to: Rank, Name, Revenue, Trend
```

---

### Screen 24: Customer Report
```
Screen name: "تقرير العملاء" (Customer Report)

Purpose: Customer base analysis and segmentation.

Layout - Desktop:
- App shell (sidebar + header)
- Tabs: "نظرة عامة" (Overview) | "أفضل العملاء" (Top) | "الشرائح" (Segments)
- Overview tab:
  - Stats: Total, New, Active, Churned
  - Growth chart (line)
  - Hide churn/repeat metrics if insufficient data (< 30 days)
- Top customers tab:
  - Table: Rank, Name, Orders, Revenue, Avg order, Tier badge
- Segments tab:
  - Segment cards: VIP, Regular, Occasional, New
  - Each with count + avg spend + % of revenue
  - Tooltip explaining segment rules (e.g., "VIP: > 5000 ر.س مشتريات")
  - CTA: "تصدير قائمة الشريحة" (Export segment list)

Mobile: Tabs + card lists (tables → cards)
```

---

### Screen 25: Debts Report
```
Screen name: "تقرير الديون" (Debts Report)

Purpose: Overview of all outstanding customer debts.

Layout - Desktop:
- App shell (sidebar + header)
- Summary: Total outstanding | Overdue amount | Average debt age
- Aging chart: 0-30 days | 30-60 | 60-90 | 90+ (horizontal stacked bar, color gradient)
  - If chart unavailable: use 4 colored cards as fallback
- Debt table: Customer | Phone | Total debt | Oldest invoice | Last payment | Days overdue
  - Date format unified across app
- Sort: By amount, date, name

Action buttons: Export inside "⋯"
- Send bulk reminders: message preview + template selection + confirmation

Mobile: Summary card + sorted card list with "متأخر X يوم" badge
```

---

### Screen 26: Peak Hours Report
```
Screen name: "ساعات الذروة" (Peak Hours)

Purpose: Identify busy times for staffing decisions.

Layout - Desktop:
- App shell (sidebar + header)
- Date range selector
- View toggle: Hourly | Daily | Weekly (unified with other reports)
- Heatmap chart: Hours (x-axis) × Days (y-axis), color intensity = transaction count
  - Legend: clear color scale + "شرح القراءة" (How to read) tooltip
- Bar chart below: Transactions per hour (or per day)
- Insight cards: Busiest hour, Busiest day, Slowest period, Recommended staffing
  - Cards: copyable as summary text

Mobile:
- Heatmap may be narrow; provide alternative: "أكثر 5 ساعات ذروة" (Top 5 peak hours) as cards
- Charts full width
- Insight cards horizontally scrollable
```

---

### Screen 27: Staff Performance
```
Screen name: "أداء الموظفين" (Staff Performance)

Purpose: Monitor cashier productivity and sales metrics.

Layout - Desktop:
- App shell (sidebar + header)
- Period: Today | Week | Month
- Criteria toggle: "مبيعات" (Sales) | "عدد العمليات" (Transactions) | "متوسط الفاتورة" (Avg ticket)
- Leaderboard cards (top 3, podium style):
  - #1 (large), #2 (medium left), #3 (medium right)
  - Each: Avatar + Name + Total (based on selected criteria)
- Full table below:
  - Name | Role | Transactions | Sales total | Avg ticket | Hours worked | Sales/hour
  - Filter by role (Cashier/Manager)
- Comparison chart: Staff sales side-by-side bar chart
- Toggle: "استبعاد المرتجعات" (Exclude returns) optional

Mobile: Podium cards horizontal → table as cards + "عرض التفاصيل" per staff
```

---

## SECTION 8: Inventory Operations (6 screens)

### Screen 28: Inventory Alerts
```
Screen name: "تنبيهات المخزون" (Inventory Alerts)

Purpose: Monitor low stock and expiry warnings.

Layout - Desktop:
- App shell (sidebar + header)
- Tabs: "مخزون منخفض" (Low Stock) | "قرب الانتهاء" (Near Expiry) | "نفد" (Out of Stock)
- Alert cards with priority indicator (red dot = urgent, orange = warning):
  - Product image + Name + SKU (monospace LTR)
  - Current stock vs Threshold
  - Days until expiry (for expiry tab)
  - Quick action: "طلب" (Reorder) visible + "⋯" (Dismiss)
- Bulk actions: appear in top bar when items selected (Reorder selected, Export list)
- Dismiss alert: requires optional reason or "تجاهل حتى تاريخ" (Ignore until date)
- Optional filter: "المورد" (Supplier) in low stock tab

Mobile: Tab bar + alert card list, swipe for actions (Reorder/Dismiss) with confirmation
```

---

### Screen 29: Stock Take (Inventory Count)
```
Screen name: "الجرد" (Stock Take)

Purpose: Conduct physical inventory count with variance detection.

Layout - Desktop:
- App shell (sidebar + header)
- Status bar: Progress (items counted / total) + Progress bar
- Two modes: Not started → In Progress
- "حفظ تلقائي" (Auto-save) indicator + "آخر حفظ" (Last saved) timestamp

In Progress mode:
- Search/Scan bar (large input with barcode icon)
  - "وضع المسح السريع" (Quick scan mode): large scan button + success sound/vibration (note for designer)
- Currently scanning product card (highlighted)
- Three-column table: Product | System Qty | Counted Qty (editable with +/- stepper) | Variance
- Color coding: Match (green), Over (blue), Short (red)
- Running stats: Matched %, Discrepancies count

Action buttons: Start Count, Scan Barcode, Finish & Save, Cancel Count
- Finish & Save: shows variance summary dialog before final confirmation

Mobile: Large scan button, list of counted items, +/- stepper per item, swipe to adjust
```

---

### Screen 30: Stock Transfer
```
Screen name: "نقل المخزون" (Stock Transfer)

Purpose: Transfer inventory between branches.

Layout - Desktop:
- App shell (sidebar + header)
- Tabs: "نقل جديد" (New Transfer) | "السجل" (History)

New Transfer tab:
- From branch dropdown + To branch dropdown (with swap icon between)
  - Validation: From ≠ To (show error if same)
- Product search + Add to transfer list (supports barcode/SKU)
- Transfer items table: Product | Available Qty | Transfer Qty (editable) | Unit
  - Validation: Transfer Qty ≤ Available Qty (show warning)
- Notes field
- Submit transfer button

History tab:
- Transfer table: Transfer # (monospace LTR) | Date | From → To | Items count | Status | Actions
- Status: Pending/In Transit/Completed/Cancelled (with timeline on detail view)

Mobile: Same flow, single column, bottom sheet for product search, items as cards
```

---

### Screen 31: Inventory Adjustment
```
Screen name: "تعديل المخزون" (Inventory Adjustment)

Purpose: Manual stock adjustments with audit trail.

Layout - Desktop:
- App shell (sidebar + header)
- Form card (centered, max-width 600px):
  - Product search input (with barcode scan)
  - Selected product card: Image + Name + Current stock (bold)
  - Adjustment type: Add (+) green / Reduce (-) red toggle buttons (clear colors but not overpowering in dark mode)
  - New quantity input OR adjustment amount input
  - Reason dropdown (required): Count correction | Damage | Theft | Return | Expired | Other
    - If Damage/Theft: optional attachment field (note for designer)
  - Notes textarea
  - Submit button
  - Each adjustment gets a Reference ID (auto-generated, monospace LTR + copy)

- Recent adjustments table below:
  - Date | Product | Type (+/-) | Qty | Reason | User | Reference ID

Mobile: Form full width, reason as bottom sheet picker, recent adjustments as cards
```

---

### Screen 32: Barcode Print
```
Screen name: "طباعة باركود" (Barcode Print)

Purpose: Generate and print barcode labels for products.

Layout - Desktop:
- App shell (sidebar + header)
- Split: Product search (40%) + Print preview (60%)

Left (Search & Select):
- Search input (supports name/barcode/SKU)
- "تحديد الكل" (Select All) + filter: "نفد/منخفض" (Out of stock/Low stock) filter
- Product list (checkboxes): Image + Name + Barcode + Price
- Quantity input per selected product
- Selected count badge

Right (Preview):
- Label size selector: Small | Medium | Large
- Label template selector: "اسم+سعر+باركود" | "باركود فقط" | custom (as base templates)
- Label template preview (shows how barcode will look)
- Include options: Barcode, Product name, Price, SKU (toggles)
- "اختبار طباعة" (Test print) small button
- Print button (large, primary)

Mobile: Search → Select → Preview steps (3-step wizard with progress indicator)
```

---

### Screen 33: Expiry Tracking
```
Screen name: "تتبع الصلاحية" (Expiry Tracking)

Purpose: Monitor product expiration dates and batches.

Layout - Desktop:
- App shell (sidebar + header)
- Tabs: "منتهية" (Expired) | "هذا الأسبوع" (This Week) | "هذا الشهر" (This Month) | "لاحقاً" (Later)
- Filter: Category dropdown + "الدفعة" (Batch) filter + "المورد" (Supplier) filter
- Table: Product | Barcode (monospace LTR) | Category | Batch # | Qty | Expiry Date | Days remaining
- Color coding: Expired (red row), This week (orange), This month (yellow)
- Actions per row: "⋯" menu (Remove from shelf, Discount, Write off)
  - Discount/Write off: opens flow affecting price/inventory with confirmation
- "تصدير القائمة" (Export list) for expired/this week tabs inside "⋯"

Mobile: Tab bar + card list with color-coded left borders + "⋯" per card
```

---

## SECTION 9: Suppliers & Branches (4 screens)

### Screen 34: Suppliers List
```
Screen name: "الموردين" (Suppliers)

Purpose: Manage supplier directory.

Layout - Desktop:
- App shell (sidebar + header)
- Stats: Total suppliers | Active | Total purchases this month (clickable → opens filtered report)
- Search bar (sticky) + Filter (active/inactive)
- Supplier cards grid (3 columns):
  - Avatar/Logo + Supplier name
  - Phone + Email
  - Total purchases amount
  - Last order date
  - Active badge
  - Quick actions: "اتصال" (Call) + "واتساب" (WhatsApp) visible + "⋯" (New PO, Edit, Deactivate)
- Empty state: "لا يوجد موردين" + CTA "إضافة مورد"

Mobile: Card list + FAB for add + search sticky at top
```

---

### Screen 35: Supplier Detail
```
Screen name: "تفاصيل المورد" (Supplier Detail)

Purpose: View supplier profile and purchase history.

Layout - Desktop:
- App shell (sidebar + header)
- Profile card: Name + Phone + Email + Address + Balance
- Stats row: Total purchases | Orders count | Avg delivery time | Rating
- CTA: "إنشاء أمر شراء" (Create PO) primary
- Tabs: "أوامر الشراء" (Purchase Orders) | "المنتجات" (Products) | "الحساب" (Account)
  - POs: Table with PO# (monospace LTR), date, amount, status, delivery date
  - Products: Grid of products from this supplier
  - Account: Ledger (reuse same component pattern as customer ledger)
- Optional: "معلومات الفاتورة الضريبية" (Tax invoice info) section if applicable

Mobile: Profile card + scrollable tabs + tables → cards
```

---

### Screen 36: Purchase Order Form
```
Screen name: "أمر شراء" (Purchase Order)

Purpose: Create purchase orders to suppliers.

Layout - Desktop:
- App shell (sidebar + header)
- Form: Supplier dropdown + PO number (auto, monospace LTR + copy) + Date
- Items table (editable):
  - Product search + Add row (supports barcode/SKU search)
  - Product | Qty | Unit price | Total
  - Validation: Qty > 0, Price > 0 (show error if zero without reason)
  - Delete row button
- Subtotal + Tax + Total (auto-calculated, sticky on desktop)
- Payment status: Not paid / Partial / Paid (with amounts displayed)
- Notes textarea
- Save buttons: Save Draft | Confirm PO

Mobile: Single column form, items as cards with subtotal sticky at bottom
```

---

### Screen 37: Branch Management
```
Screen name: "إدارة الفروع" (Branch Management)

Purpose: Manage multiple business branches.

Layout - Desktop:
- App shell (sidebar + header)
- Stats row: Total branches | Active | Today's total sales
- Branch cards grid (2 columns):
  - Branch name + Address
  - Manager name + Employee count
  - Today's sales (highlighted)
  - "حالة المزامنة" (Sync status) indicator if sync is available
  - Status toggle: Active/Inactive (with reason + confirmation)
  - Quick stats: Orders today, Revenue today
- Click card → Branch detail page
- CTA: "تعيين مدير" (Assign Manager) as clear action

Mobile: Branch cards stacked, tap → details in bottom sheet
```

---

## SECTION 10: Marketing & Loyalty (3 screens)

### Screen 38: Special Offers
```
Screen name: "العروض الخاصة" (Special Offers)

Purpose: Create and manage promotional campaigns.

Layout - Desktop:
- App shell (sidebar + header)
- Stats: Total offers | Active now | Expiring soon
- Offer cards grid:
  - Offer name + Type badge (Buy X Get Y / % Discount / Bundle)
  - Date range (start → end)
  - Products included (thumbnails)
  - "الأثر" (Impact): discount value/percentage shown clearly
  - Status: Active (green) / Scheduled (blue) / Expired (grey)
  - Toggle: Enable/Disable
- Create offer wizard (Drawer on desktop / Bottom sheet on mobile):
  - Step 1: Offer type selection
  - Step 2: Select products/categories
  - Step 3: Set discount/conditions
  - Step 4: Set date range + Review (merged to 4 steps total)
  - Validation: Check date conflicts / overlapping offers with warning

Mobile: Card list + FAB for create, wizard bottom sheet with progress indicator
```

---

### Screen 39: Coupon Management
```
Screen name: "إدارة الكوبونات" (Coupon Management)

Purpose: Create and track discount codes.

Layout - Desktop:
- App shell (sidebar + header)
- Stats: Total coupons | Active | Total usage | Revenue from coupons
- Coupon table:
  - Code (monospace LTR, copy button prominent) | Type (% / Fixed / Free delivery) | Value
  - Min order | Usage (used/max) + progress bar (ensure contrast in dark mode)
  - Expiry date | Status badge
  - Actions: Copy code (visible) + "⋯" (Edit, Deactivate, Delete)
- Create coupon dialog:
  - Code (auto-generate or custom)
  - Type selector, Value input
  - Conditions: Min order, Max uses, Customer restriction, Date range
  - Validation: Expiry > today, Max uses > 0
- "تم النسخ" (Copied) toast on code copy

Mobile: Card list with copy-code button prominent + "⋯" for rest
```

---

### Screen 40: Loyalty Program
```
Screen name: "برنامج الولاء" (Loyalty Program)

Purpose: Configure loyalty rewards and view members.

Layout - Desktop:
- App shell (sidebar + header)
- Tabs: "الأعضاء" (Members) | "المكافآت" (Rewards) | "الإعدادات" (Settings)

Members tab:
- Stats: Total members | Points issued | Points redeemed
- Members table: Name | Phone | Points | Tier (Bronze/Silver/Gold/Diamond) | Total spent | Joined date
  - Mobile: card list

Rewards tab:
- Rewards grid cards: Reward name + Points required + Type (discount/free product/free delivery)
- Each reward: Enable/Disable toggle with immediate effect confirmation
- Add reward button

Settings tab:
- Points per riyal input
- Redemption rate input
- Tier thresholds (Bronze: 0, Silver: 500, Gold: 2000, Diamond: 5000)
  - Validation: thresholds must be ascending
- Enable/disable toggle
- Optional: "محاكاة" (Simulation): Enter amount → show points earned (helpful UX)

Mobile: Tab bar + card content per tab
```

---

## SECTION 11: Settings (9 screens)

### Screen 41: Store Settings
```
Screen name: "إعدادات المتجر" (Store Settings)

Purpose: Configure store information.

Layout:
- App shell (sidebar + header)
- Form sections in cards:
  - "معلومات المتجر": Store name, Address (with typeahead suggestions — note for designer), City, Phone, Email
  - "الإعدادات المالية": Currency (SAR), Tax enabled toggle, Tax rate (15%), Prices include tax toggle
  - "الهوية": Logo upload, Receipt header text, Receipt footer text
  - "التشغيل": Default language, Timezone
- Save button (sticky bottom bar) + "تغييرات غير محفوظة" (Unsaved changes) indicator
- "إعادة ضبط" (Reset) per section inside "⋯" (with caution)

Mobile: Stacked cards as accordion to reduce scroll length, inline editing
```

---

### Screen 42: Printer Settings
```
Screen name: "إعدادات الطابعة" (Printer Settings)

Purpose: Configure receipt printer connection.

Layout:
- App shell
- Connection type: USB | Bluetooth | Network | PDF (radio cards with icons + short description per type)
- Connected printer card (if connected): Printer name + Status (green dot)
- Test print button → show result banner: success (green) / failure (red + error details)
- Auto-print toggle + "متى؟" (When?): Invoices / Returns / Reports toggles
- Paper size: 58mm | 80mm radio
- Receipt template selector (dropdown)

Mobile: Same layout, single column, test result banner clearly visible
```

---

### Screen 43: Tax Settings
```
Screen name: "إعدادات الضرائب" (Tax Settings)

Purpose: Configure VAT and ZATCA compliance.

Layout:
- App shell
- VAT section card:
  - Enable VAT toggle
  - VAT rate input (15%)
  - Prices include VAT toggle
  - Show VAT on receipt toggle
- ZATCA section card:
  - Enable ZATCA toggle
  - Phase selector (Phase 1 / Phase 2)
  - VAT number input (15 digits, input mask)
  - CR number input (10 digits, input mask)
  - Test connection button → loading state → success/failure + "تفاصيل الخطأ" expandable
- Tax categories: add/edit in Drawer (not dialog) for more space
  - Table: Name | Code (monospace LTR) | Rate | Actions (edit/delete)
  - Add category button

Mobile: Stacked cards, tax categories as list
```

---

### Screen 44: Security Settings
```
Screen name: "إعدادات الأمان" (Security Settings)

Purpose: Configure PIN, biometrics, and session security.

Layout:
- App shell
- Sections:
  - "رمز PIN": Enable toggle, "تغيير PIN" button → flow (old PIN → new PIN → confirm)
    - Require PIN for: void, discount, refund (clear list with explanations)
  - "البصمة": Enable biometric toggle (if available), device support status
  - "الجلسة": Auto-lock timeout dropdown (5/10/15/30 min), Lock on minimize toggle
    - Show "آخر نشاط" or "سيتم القفل بعد X دقيقة" indicator
  - "الصلاحيات": Manager override PIN for sensitive operations (list which operations)

Mobile: Toggle-heavy single column, PIN change via bottom sheet
```

---

### Screen 45: Users Management
```
Screen name: "إدارة المستخدمين" (Users Management)

Purpose: Create and manage store staff accounts.

Layout:
- App shell
- User cards grid (or table):
  - Avatar + Name + Role badge (Owner/Manager/Cashier)
  - Phone + Email
  - Active/Inactive toggle
  - Last login date
  - Actions: Edit (icon) + "⋯" (Reset PIN, Resend code, Deactivate)
- Add user dialog: Name, Phone, Role dropdown, Set initial PIN
- Role permissions summary (collapsible per role + "تفاصيل الصلاحيات" link)
- Validation: Cannot deactivate the last Owner account

Mobile: User card list + FAB for add
```

---

### Screen 46: Backup Settings
```
Screen name: "النسخ الاحتياطي" (Backup Settings)

Purpose: Configure automatic and manual data backup.

Layout:
- App shell
- Auto backup card: Toggle + Frequency dropdown (Daily/Weekly/Monthly)
  - Show: "آخر نسخة ناجحة" (Last successful backup) + "النسخة التالية" (Next backup)
- Backup destination: Cloud toggle + Local toggle
- Manual backup button (large, outlined)
- Restore button (with multi-step warning + confirmation)
- Backup history table: Date | Size | Type (auto/manual) | Status (success/failed) | Actions (Restore, Download where applicable)

Mobile: Cards + history list
```

---

### Screen 47: Receipt Template
```
Screen name: "قالب الإيصال" (Receipt Template)

Purpose: Customize receipt appearance.

Layout - Desktop:
- App shell
- Split: Settings (40%) + Live preview (60%)

Settings panel:
- Grouped toggles:
  - "الرأس" (Header): Show logo, Store name, Address, Phone, VAT number
  - "المحتوى" (Body): Show items, prices, QR code
  - "الذيل" (Footer): Thank you message, Footer note
- Text inputs: Thank you message, Footer note
- Font size slider: Small / Medium / Large
- Paper size: 58mm / 80mm (preview width changes accordingly)

Preview panel:
- Real-time receipt preview (styled like actual receipt)
- Updates live as settings change
- Skeleton loading while preview regenerates

Mobile: Tabs: "إعدادات" (Settings) | "معاينة" (Preview)
```

---

### Screen 48: ZATCA Compliance
```
Screen name: "توافق هيئة الزكاة" (ZATCA Compliance)

Purpose: Monitor ZATCA e-invoicing status.

Layout:
- App shell
- Status card: Connected/Disconnected indicator (large icon + text)
  - Show: "آخر فحص اتصال" (Last connection check) + "آخر مزامنة" (Last sync) + failure reason if any
- Phase progress: Phase 1 ✓ | Phase 2 (in progress indicator)
  - Tooltip: brief explanation of each phase
- Configuration: VAT number + CR number display (with edit buttons)
- QR code sample preview
- Last sync info: Date + status
- Action bar: Test Connection | Sync Now + "⋯" (Export Invoices)

Mobile: Priority order: Status → Action buttons → Configuration → Details
```

---

### Screen 49: Notifications Settings
```
Screen name: "إعدادات الإشعارات" (Notifications Settings)

Purpose: Configure notification preferences.

Layout:
- App shell
- Notification categories (toggle cards):
  - Each category: toggle + sub-settings appear ONLY when enabled
  - Low stock alerts: Toggle + Threshold input
  - Expiry alerts: Toggle + Days before expiry input
  - New orders: Toggle
  - Payment received: Toggle
  - Daily summary: Toggle + Time picker (Asia/Riyadh timezone fixed)
  - Shift reminders: Toggle
- Delivery method: multi-select (Push / Email / SMS)
  - SMS: requires phone number validation
- Sound toggle

Mobile: Collapsible sections per category
```

---

## SECTION 12: Remaining Screens (7 screens)

### Screen 50: Notifications
```
Screen name: "الإشعارات" (Notifications)

Purpose: View and manage system notifications.

Layout:
- App shell (sidebar + header)
- Filter: All | Unread + Type filter dropdown
- Notification list:
  - Icon (color-coded by type) + Title + Message + Time ago
  - Unread indicator (dot)
  - Tap to mark read + navigate to related screen (CTA)
  - Swipe to dismiss
- Types: Order (blue), Inventory (orange), Payment (green), System (grey), Expiry (red)
- Empty state when all read

Action buttons: Mark all read + Clear all (with confirmation)

Mobile: Full-screen list, pull to refresh, swipe dismiss + undo snackbar
```

---

### Screen 51: Cash Drawer
```
Screen name: "الدرج النقدي" (Cash Drawer)

Purpose: Monitor cash drawer status and movements.

Layout:
- App shell
- Status card: Open (green) / Closed (red) with open/close time
- Balance card:
  - Opening amount
  - Cash sales (+)
  - Cash returns (-)
  - Cash in (+) / Cash out (-)
  - Current balance (large, bold)
- Quick actions: "إدخال نقدي" Cash In (green) + "سحب نقدي" Cash Out (red)
  - Each opens Drawer with: amount + reason (required) + optional reference
- Recent movements table: Time | Type | Amount | Reference | User
  - Desktop: table | Mobile: colored list (green in, red out)
- Close drawer button (with confirmation showing current balance)
- "طباعة تقرير الدرج" (Print drawer report) inside "⋯"

Mobile: Status + balance cards stacked, movements list
```

---

### Screen 52: Profile
```
Screen name: "الملف الشخصي" (Profile)

Purpose: View and edit user profile.

Layout:
- App shell
- Profile header card (light tinted surface, not heavy gradient):
  - Large avatar (80px) + Edit photo overlay
  - Name (headline) + Role badge
  - Email + Phone
- Stats row: Sales count | Days active | Average daily sales
- Edit: Opens in Drawer (not inline expand) with:
  - Name, Phone, Email inputs
  - Change PIN button (same flow as Security settings)
  - Language preference
- Activity log: Recent logins with device + time
  - Mobile: show last 3 + "عرض المزيد" (Show more)
- Optional: "تسجيل خروج من كل الأجهزة" (Logout all devices) inside "⋯"

Mobile: Header card + stats + scrollable content
```

---

### Screen 53: Sync Status
```
Screen name: "حالة المزامنة" (Sync Status)

Purpose: Monitor data synchronization between local and cloud.

Layout:
- App shell
- Connection status card: Online (green) / Offline (red) indicator
  - If offline: show reason + CTA "إعادة المحاولة" (Retry)
- Sync progress: Pending items count + Last sync time
- Sync button (large, primary, sticky on mobile)
- Pending items breakdown: Sales | Products | Customers | Inventory (with counts)
  - Each clickable to show pending items list
- Sync log table: Time | Table | Action | Status | Error (if any)
  - Click error → expand to show details

Mobile: Status card + pending count cards + sync button (sticky)
```

---

### Screen 54: Driver Management
```
Screen name: "إدارة السائقين" (Driver Management)

Purpose: Manage delivery drivers.

Layout:
- App shell
- Stats: Total drivers | Active now | Delivering | Offline
- Driver cards grid:
  - Avatar + Name + Phone
  - Vehicle type + Plate number
  - Status badge (active/delivering/offline) + "آخر تحديث" (Last update)
  - Delivery stats: Today count + Rating stars
  - Quick actions: "اتصال" (Call) visible + "⋯" (Assign order, View location)
- Add driver dialog: Name, Phone (validated), Vehicle type, Plate number (validated)

Mobile: Card list + FAB
```

---

### Screen 55: Print Queue
```
Screen name: "قائمة الطباعة" (Print Queue)

Purpose: Manage pending and failed print jobs.

Layout:
- App shell
- Printer status card: Connected/Disconnected + Printer name
  - CTA: "إعادة الاتصال" (Reconnect) / "اختبار" (Test) if disconnected
- Queue table:
  - Job # | Type (Receipt/Report) | Reference # (monospace LTR) | Status (pending/printing/failed)
    - Failed: show reason expandable
  - Time created
  - Actions: Retry (icon) + "⋯" (Cancel, Delete)
- Bulk actions: appear only when pending/failed items exist (Print all, Clear queue)

Mobile: Status card + job list, swipe for actions (Retry/Cancel)
```

---

### Screen 56: Expense Categories
```
Screen name: "تصنيفات المصروفات" (Expense Categories)

Purpose: Manage expense categories.

Layout:
- App shell
- "وضع الترتيب" (Reorder mode) toggle
- Category list (reorderable when in reorder mode):
  - Color dot + Icon + Category name + Expense count
  - Actions: "⋯" (Edit, Delete with confirmation)
- Add/Edit: Opens in Drawer with: Name, Icon picker, Color picker
- Budget per category (optional): Monthly budget input
  - Note for designer: "Optional — may not be in MVP"

Mobile: Simple list + FAB for add
```

---

> End of prompts. Total: 56 screens covering the complete POS application.
> All screens include: RTL, Dark/Light mode, Desktop/Mobile responsive, Arabic-first, unified design system.
> Mandatory UX Rules (6 rules) apply to every screen.
