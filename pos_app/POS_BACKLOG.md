# POS App Backlog - Sprint A + B

**Version:** 1.3.1 (Production-Ready + Capacity Balanced)  
**Date:** 2026-01-20  
**Source:** POS_SITEMAP.md v1.4.0 + Consultant Feedback v4

**Major Changes (v1.3.1):**
- Sprint A capacity balanced: 95 → 92 points
- US-2.7 moved to Sprint B
- GDPR compliance added to Customer Lookup
- WhatsApp prerequisites clarified
- Pre-Sprint Checklist added
- Low Stock notification settings enhanced

**Major Changes (v1.3.0):**
- WhatsApp digital receipts (ZATCA Phase 2)
- Customer quick lookup & loyalty foundation
- Low stock alerts during checkout
- Sale notes for special instructions
- Custom receipt design & branding

**Major Changes (v1.2.0):**
- Enhanced VAT calculation (inclusive/exclusive)
- TOTP-based offline PIN security
- Network resilience patterns
- Stock overselling detection

---

## 📋 Epic Structure

```
Epic 1: Authentication & Store
Epic 2: Sales Flow (Core)
Epic 3: Payment & Receipt
Epic 4: Offline & Sync
Epic 5: Refunds
Epic 6: Shift & Cash
Epic 7: Permissions & Audit
Epic 8: Advanced Features (P2)
```

---

# 🚀 Pre-Sprint Checklist

> **⚠️ يجب إكمال هذه المتطلبات قبل بدء Sprint A**

## Backend APIs (Must be Ready)
- [ ] `/auth/send-otp` - OTP generation & SMS
- [ ] `/auth/validate-pin` - Supervisor PIN validation
- [ ] `/stores/my` - User's assigned stores
- [ ] `/products/search` - Product search with filters
- [ ] `/products/{barcode}` - Get product by barcode
- [ ] `/orders/create` - Create new order
- [ ] `/payments/process` - Process payment
- [ ] `/customers/search` - Customer lookup (US-2.5)
- [ ] `/stock/check` - Real-time stock levels (US-2.6)

## Third-Party Integrations

### WhatsApp Business API (US-3.4)
- [ ] Meta Business verification completed (2-3 weeks lead time)
- [ ] Phone number registered (+966 5X XXX XXXX)
- [ ] Message template approved by Meta:
  ```
  Template Name: "receipt_notification"
  Language: Arabic (ar)
  Category: Transactional
  Variables: {{customer_name}}, {{order_number}}, {{total}}, {{receipt_link}}
  ```
- [ ] API credentials stored in vault
- [ ] Test message sent successfully

### SMS Gateway (Fallback)
- [ ] Provider: [Twilio / AWS SNS / Mobily]
- [ ] Account credits: Min 1000 SAR
- [ ] Sender ID registered: "YourStore"

### ZATCA E-Invoice
- [ ] QR code library integrated (TLV format)
- [ ] Sample receipt generated & validated

## Infrastructure
- [ ] SQLite schema v1.0 deployed
- [ ] Secure storage configured (FlutterSecureStorage)
- [ ] Push notifications configured (FCM)
- [ ] Analytics initialized (Firebase/Crashlytics)

## Design & Assets
- [ ] UI mockups for all Sprint A screens
- [ ] Arabic fonts licensed (Tajawal/Cairo)
- [ ] Icon set prepared

---

# Sprint A (7 Days) - الأساسيات

## Epic 1: Authentication & Store

### US-1.1: Splash Screen
**As a** user  
**I want** the app to check my auth status on launch  
**So that** I'm automatically directed to the right screen

**Acceptance Criteria:**
- [ ] Shows logo/branding for 1-2 seconds
- [ ] Checks for valid token in secure storage
- [ ] Redirects to Login if no token or expired
- [ ] Redirects to Store Select if valid token
- [ ] Handles network errors gracefully

**Story Points:** 2

---

### US-1.2: Login with OTP
**As a** user  
**I want** to login using my phone number and OTP  
**So that** I can access the POS system

**Acceptance Criteria:**
- [ ] Phone number input with Saudi format validation (+966)
- [ ] "Send OTP" button calls `/auth/send-otp`
- [ ] 6-digit OTP input with auto-focus
- [ ] 60-second countdown for resend
- [ ] Error messages: invalid phone, wrong OTP, expired, rate limited
- [ ] Success saves token to secure storage

**Story Points:** 5

---

### US-1.3: Store Select
**As a** user  
**I want** to select my store after login  
**So that** all my operations are scoped to that store

**Acceptance Criteria:**
- [ ] Fetches stores from `/stores/my`
- [ ] Shows store name and address
- [ ] Single tap to select and proceed
- [ ] Saves selected store ID locally
- [ ] Shows error if no stores available

**Story Points:** 3

---

## Epic 2: Sales Flow (Core)

### US-2.1: Home Dashboard
**As a** cashier  
**I want** a home screen with quick actions and status  
**So that** I can start selling quickly

**Acceptance Criteria:**
- [ ] Connection status indicator (Online/Offline)
- [ ] Current shift status (Open/Closed)
- [ ] Pending transactions badge
- [ ] Today's sales total (P0 basic, P1 from API)
- [ ] Quick actions: New Sale, Scan, Cash Drawer, Search
- [ ] Low stock alert badge

**Story Points:** 5

---

### US-2.2: Quick Sale Screen
**As a** cashier  
**I want** to add products to cart by scanning or searching  
**So that** I can complete sales quickly

**Acceptance Criteria:**
- [ ] Camera barcode scanner (auto-activate option)
- [ ] Manual barcode input field
- [ ] Product search with name filter
- [ ] Add to cart on product select
- [ ] Quantity +/- buttons
- [ ] Cart summary always visible
- [ ] "Checkout" button when cart not empty

**Story Points:** 8

---

### US-2.3: Product Search
**As a** cashier  
**I want** to search products by name or category  
**So that** I can find products without barcode

**Acceptance Criteria:**
- [ ] Search input with debounce (300ms)
- [ ] Category filter chips (P1 - Sprint A uses text search only)
- [ ] Product grid with image, name, price
- [ ] Stock indicator: local snapshot when offline, server when online
- [ ] Tap to add to cart
- [ ] "No results" state

**Story Points:** 3

---

### US-2.4: Cart Screen
**As a** cashier  
**I want** to review and modify items before payment  
**So that** I can ensure the order is correct

**Acceptance Criteria:**
- [ ] List of cart items with qty, price, subtotal
- [ ] Quantity edit (tap to change)
- [ ] Remove item (swipe or delete button)
- [ ] Subtotal calculation
- [ ] Discount input (amount or %) - requires supervisor for >20%
- [ ] Support both tax-inclusive and tax-exclusive pricing
- [ ] Product model includes: price, taxInclusive (bool), taxCategory
- [ ] Tax calculation:
  - If taxInclusive: vat = price × (rate / (100 + rate))
  - If taxExclusive: vat = price × (rate / 100)
- [ ] Handle exempt items (0% VAT) correctly
- [ ] Receipt shows VAT breakdown grouped by tax rate
- [ ] Grand total
- [ ] "Pay" button

**Story Points:** 8

---

### US-2.5: Customer Quick Lookup
**As a** cashier  
**I want** to search for returning customers by phone  
**So that** I can apply loyalty benefits and personalize service

**Acceptance Criteria:**
- [ ] Cart screen: "🔍 عميل مسجّل؟" button (top-right)
- [ ] Tap opens bottom sheet search:
  - Input: "أدخل رقم الجوال أو الاسم"
  - Auto-suggest after 4 characters
  - Search by: Phone (last 4-8 digits) or Name (fuzzy match)
- [ ] Search results:
  - Customer card with:
    - Name (bold), Phone (masked: 05XX XXX 1234)
    - Total purchases: "X عملية - XXX ريال"
    - Loyalty points: "Y نقطة متاحة" (if enabled)
    - Outstanding debt indicator (without amount for cashier)
    - Last visit: "آخر زيارة: منذ X أيام"
  - Tap to select customer
- [ ] After selection:
  - Customer name shown at top of cart
  - Auto-apply available offers
  - Link sale to customer profile (customerId in Order)
- [ ] Create new customer flow:
  - Button: "➕ عميل جديد"
  - Quick form: Name (required), Phone (required)
  - Optional: Email, Birthday
  - Save and auto-select
- [ ] GDPR Compliance:
  - Consent checkbox on creation: "☐ أوافق على حفظ بياناتي لتحسين الخدمة"
  - Data retention policy: Auto-delete after 2 years of inactivity
  - Customer rights:
    - "📥 تصدير بياناتي" (export as JSON)
    - "🗑️ حذف حسابي" (with 30-day grace period)
  - Privacy notice: Link to privacy policy
  - Manager dashboard: "Customer Data Requests" queue
- [ ] Privacy & Security:
  - Mask phone on screen (show last 4 only)
  - Full details visible to Manager+ only
- [ ] Offline behavior:
  - Search local customer cache
  - New customers saved locally, synced when online

**Story Points:** 6

---

### US-2.6: Low Stock Alert During Sale
**As a** cashier  
**I want** to see low stock alerts when adding items  
**So that** I can inform customers of limited availability

**Acceptance Criteria:**
- [ ] Real-time stock check on "Add to Cart":
  - If online: Query server stock
  - If offline: Use local cached stock
- [ ] Visual indicators (in product card + cart):
  - Stock ≥ 10: ✅ No indicator (normal)
  - Stock 6-9: 🟡 Yellow badge "متبقي X فقط"
  - Stock 2-5: 🟠 Orange badge "⚠️ كمية محدودة (X)"
  - Stock = 1: 🔴 Red badge "🔴 آخر قطعة!"
  - Stock = 0 (online): ⛔ "غير متوفر" + disable add
  - Stock = 0 (offline): ⚠️ "المخزون المحلي منتهي"
- [ ] Cart screen:
  - Low stock items highlighted with colored border
- [ ] Stock update trigger points:
  - After each sale (decrement)
  - Every 5 minutes (background sync when online)
  - Manual refresh (pull-to-refresh)
- [ ] Manager notifications:
  - When item sold from last 5 units:
    - Push notification: "⚠️ تنبيه مخزون: [Product] متبقي X"
    - Badge on Home: "تنبيهات المخزون (Y)"
- [ ] Notification management:
  - Frequency limit: Max 1 alert per product per hour
  - Quiet hours: No alerts 10 PM - 8 AM (configurable)
  - Test notification button in Settings
- [ ] Per-category thresholds (Settings > Inventory):
  - Grocery: 5 units (default)
  - Electronics: 2 units
  - Perishables: 10 units
  - Custom categories: User-defined

**Story Points:** 4

---

## Epic 3: Payment & Receipt

### US-3.1: Payment Screen
**As a** cashier  
**I want** to select payment method and process payment  
**So that** I can complete the sale

**Acceptance Criteria:**
- [ ] Payment method buttons: Cash, Card, Mixed
- [ ] Cash: amount received input, change calculation
- [ ] Card payment workflow:
  1. Cashier processes payment on external terminal
  2. App prompts for: RRN (12 digits), Card Last 4 digits, Terminal ID
  3. Validate RRN format (numeric, 12 chars)
  4. Require supervisor PIN approval for card payments
  5. Save metadata: {rrn, cardLast4, terminalId, approvedBy, timestamp}
- [ ] Log all card payment attempts in audit
- [ ] Display warning: "تأكد من نجاح العملية على جهاز الدفع قبل الإدخال"
- [ ] Sprint A: Cash only (Card disabled with message: "قريباً")
- [ ] Sprint B: Enable semi-integrated card
- [ ] Mixed: add multiple payments until total covered
- [ ] When offline: Cash only (Card/Mixed disabled)
- [ ] Idempotency key generated for each attempt
- [ ] Loading state during API call
- [ ] Error handling with retry option
- [ ] Success navigates to Receipt

**Story Points:** 8

> **P1 Target:** Full integration with Mada/Visa SDK

---

### US-3.2: Receipt Screen
**As a** cashier  
**I want** to see and print the receipt after payment  
**So that** I can give it to the customer

**Acceptance Criteria:**
- [ ] Order number displayed
- [ ] Items list with quantities and prices
- [ ] Subtotal, discount, tax, total
- [ ] Payment method and amount
- [ ] Change given (if cash)
- [ ] Store info header
- [ ] Print button
- [ ] New Sale button
- [ ] Works even if print fails (shows receipt on screen)

**Story Points:** 5

---

### US-3.3: Print Queue
**As a** cashier  
**I want** to manage print jobs that failed  
**So that** I can print receipts later

**Acceptance Criteria:**
- [ ] Queue icon with badge count on Home
- [ ] List of pending print jobs
- [ ] Retry print button per item
- [ ] Clear single item
- [ ] "Print All" button
- [ ] Printer status indicator
- [ ] Access from Receipt screen (Reprint button)

**Story Points:** 5

---

### US-3.4: Digital Receipt via WhatsApp
**As a** customer  
**I want** to receive my receipt on WhatsApp  
**So that** I have a digital copy and don't lose it

**Acceptance Criteria:**
- [ ] Payment screen shows optional field: "رقم الجوال (اختياري)"
- [ ] Saudi format validation: +966 5XXXXXXXX (starts with 5)
- [ ] Auto-format input: 05XXXXXXXX → +966 5XXXXXXXX
- [ ] Checkbox: "☐ إرسال الفاتورة عبر واتساب" (default: unchecked)
- [ ] Privacy consent text: "سيتم استخدام رقمك للتواصل فقط"
- [ ] After successful payment:
  - If phone provided + checkbox enabled → Send WhatsApp message
  - Message uses pre-approved template:
    ```
    مرحباً {{customer_name}}! 👋
    شكراً لتسوقك معنا
    🧾 فاتورة رقم: {{order_number}}
    💰 المبلغ الإجمالي: {{total}} ريال
    📄 عرض الفاتورة: {{receipt_link}}
    نتطلع لخدمتك مجدداً ✨
    ```
  - Attach: PDF receipt (ZATCA-compliant with QR code)
- [ ] Fallback handling:
  - If WhatsApp API fails → Queue for retry (3 attempts)
  - If still fails → Send SMS with receipt link
- [ ] Customer profile:
  - Save phone to customer record (create if new)
  - Auto-suggest phone on next visit
- [ ] Store settings:
  - Toggle: "Enable WhatsApp receipts" (default: ON)
  - WhatsApp Business API credentials
- [ ] Offline behavior:
  - Queue message for sending when online
  - Show indicator: "⏳ سيتم الإرسال عند الاتصال"

**Technical Prerequisites:**
- Meta Business verification (2-3 weeks lead time)
- Message template pre-approval (24-48 hours)
- Cost: ~0.05-0.10 SAR per message
- ZATCA: QR code must be in receipt PDF (TLV format)

**Story Points:** 8

---

## Epic 6: Shift & Cash

### US-6.1: Open Shift
**As a** cashier  
**I want** to open a shift before selling  
**So that** my sales are tracked under my shift

**Acceptance Criteria:**
- [ ] Prompt if no open shift on Home
- [ ] Opening cash input (required)
- [ ] Confirm button
- [ ] Creates shift record with timestamp
- [ ] Enforce one open shift per cashier per store (server constraint)
- [ ] Redirect to Home after success

**Story Points:** 5

---

### US-6.2: Cash In/Out
**As a** cashier  
**I want** to record cash movements  
**So that** closing cash matches

**Acceptance Criteria:**
- [ ] Dialog accessible from Home
- [ ] Type: Cash In / Cash Out
- [ ] Amount input
- [ ] Reason input (required)
- [ ] Supervisor approval for Cash Out (PIN dialog)
- [ ] Records linked to current shift
- [ ] Updates expected cash calculation

**Story Points:** 5

---

## Epic 7: Permissions & Audit

### US-7.1: Role-Based Navigation
**As a** store owner  
**I want** different roles to see different features  
**So that** cashiers can't access sensitive areas

**Acceptance Criteria:**
- [ ] Cashier: Sales, Shift, limited Settings
- [ ] Supervisor: + Refunds, Reports (read)
- [ ] Manager: + Inventory, full Reports
- [ ] Owner: full access
- [ ] Hidden menu items based on role
- [ ] API enforces permissions

**Story Points:** 5

---

### US-7.2: Basic Audit Log
**As a** manager  
**I want** to see who did what  
**So that** I can investigate issues

**Acceptance Criteria:**
- [ ] Log: price changes (who, when, old/new)
- [ ] Log: refunds (who, reason, amount)
- [ ] Log: stock adjustments (who, type, qty)
- [ ] Log: cash drawer opens (who, when)
- [ ] Log: login/logout (who, device)
- [ ] Stored locally + synced to server
- [ ] Sprint A: logging only (no view UI)
- [ ] Sprint B/P1: View in Settings > Activity Log

**Story Points:** 3

---

### US-7.3: Supervisor PIN Approval
**As a** supervisor  
**I want** to approve sensitive actions with my PIN  
**So that** I can authorize without logging in

**Acceptance Criteria:**
- [ ] PIN dialog appears for: discount >20%, refund, void, cash out
- [ ] 4-digit PIN input
- [ ] Online PIN validation:
  - API call to /auth/validate-pin
  - Returns: {valid: bool, userId, role, permissions}
- [ ] Offline PIN validation:
  - Use TOTP (Time-based OTP) algorithm
  - Shared secret synced during login
  - Time window: 30 seconds tolerance
  - Falls back to emergency offline code (single-use, synced daily)
- [ ] Offline limitations (even with valid PIN):
  - Refund: max 100 SAR per transaction
  - Discount: max 20% (no >20% override)
  - Void: not allowed offline
  - Cash out: max 500 SAR per shift
- [ ] All approvals logged with approverId + method (online/offline)
- [ ] Timeout after 3 failed attempts

**Story Points:** 8

---

# Sprint B (7 Days) - المتانة

## Epic 2 (continued): Sales Flow

### US-2.7: Barcode Scanner Audio & Haptic Feedback
**As a** cashier  
**I want** instant feedback when scanning items  
**So that** I can work efficiently without looking at screen

**Acceptance Criteria:**
- [ ] Successful scan feedback:
  - Sound: "Beep" tone (500ms, 1000Hz)
  - Haptic: Single vibration (50ms, medium intensity)
  - Visual: Green flash border around camera frame (300ms)
  - Action: Auto-add to cart (no confirmation dialog)
  - Display: Toast with item name + price (2 seconds)
- [ ] Failed scan (barcode not found):
  - Sound: "Error buzz" (double beep, lower pitch 400Hz)
  - Haptic: Double vibration (100ms gap)
  - Visual: Red flash + shake animation
  - Message: "❌ منتج غير موجود في النظام"
  - Quick action: "➕ إضافة منتج جديد"
- [ ] Continuous scanning mode:
  - Toggle button: "المسح المستمر" (default: ON)
  - When ON: Camera stays open after scan
  - Item counter badge: "🛒 X منتجات"
  - Large "✓ تم" button to proceed to cart
- [ ] Settings:
  - Sound: ON/OFF + volume slider
  - Haptic: ON/OFF + intensity (Low/Medium/High)
  - Auto-add: ON/OFF
  - Scan mode: Continuous / Single
- [ ] Performance:
  - Debounce duplicate scans (500ms)
  - Cache recent scans (last 10) for faster lookup

**Story Points:** 3

---

### US-2.8: Sale Notes & Special Instructions
**As a** cashier  
**I want** to add notes to sales  
**So that** I can record special requests and internal reminders

**Acceptance Criteria:**
- [ ] Cart screen: "📝 ملاحظة" button (bottom toolbar)
- [ ] Tap opens note dialog:
  - Quick select chips:
    - "📦 طلب توصيل"
    - "⭐ عميل VIP"
    - "💰 خصم موافق عليه"
    - "🎁 هدية - تغليف مجاني"
    - "⏰ استلام لاحق"
  - Free text input: "ملاحظة أخرى..." (200 chars max)
  - Checkbox: "☐ عرض في الفاتورة" (default: OFF)
- [ ] After saving:
  - Note badge on cart: "📝 1"
  - Tap badge to edit/remove
- [ ] Receipt display (if enabled):
  - Section: "ملاحظات خاصة:"
- [ ] Order history integration:
  - Notes searchable
  - Filter orders by note type
- [ ] Audit log:
  - Log: who added note, when, original text

**Story Points:** 3

---

## Epic 3 (continued): Payment & Receipt

### US-3.5: Custom Receipt Design
**As a** store owner  
**I want** to customize receipt appearance  
**So that** I can strengthen branding and add promotions

**Acceptance Criteria:**
- [ ] Settings > Receipt Design screen:
  - **Header Section:**
    - Logo upload: PNG, JPG (max 200KB, 200x200px)
    - Store tagline: "شعار المحل" (50 chars)
    - Store slogan: "نص ترحيبي" (100 chars)
  - **Footer Section:**
    - Promotional message: (200 chars)
    - Social media handles
    - QR code customization:
      - ZATCA QR (required, always shown)
      - Payment Link / Website / Feedback Form
  - **Styling Options:**
    - Font: [Tajawal | Cairo | Amiri]
    - Font size: Small / Medium / Large
    - Receipt width: 58mm / 80mm
- [ ] Preview functionality:
  - Live preview panel
  - Download preview: PNG or PDF
- [ ] Apply settings:
  - "حفظ وتطبيق" button
  - Retroactive: Existing receipts keep old design
- [ ] Access control:
  - Owner/Manager: Full edit access
  - Supervisor/Cashier: View only

**Story Points:** 5

---

## Epic 4: Offline & Sync

### US-4.1: Offline Indicator
**As a** cashier  
**I want** to know when I'm offline  
**So that** I understand my sales are pending

**Acceptance Criteria:**
- [ ] Red banner/bar when offline
- [ ] Green when online
- [ ] Automatic detection (connectivity check)
- [ ] Shows on all screens

**Story Points:** 3

---

### US-4.2: Local Sales (Offline)
**As a** cashier  
**I want** to continue selling when offline  
**So that** I don't lose customers

**Acceptance Criteria:**
- [ ] Orders saved to SQLite
- [ ] UUID generated locally
- [ ] Stock decremented locally (per-category limits)
- [ ] Receipt shows "Pending Sync" indicator
- [ ] Graceful handling of negative stock (per category)
- [ ] When offline: available payment methods = Cash only
- [ ] Card/Mixed disabled with explanation message

**Story Points:** 8

---

### US-4.3: Pending Transactions Screen
**As a** manager  
**I want** to see pending offline transactions  
**So that** I can monitor sync status

**Acceptance Criteria:**
- [ ] List of unsynced orders
- [ ] Status per order: pending, syncing, failed, synced
- [ ] Manual retry button per order
- [ ] "Sync All" button
- [ ] Error details on failed orders
- [ ] Count shown on Home badge

**Story Points:** 5

---

### US-4.4: Sync Service
**As a** system  
**I want** to automatically sync when online  
**So that** data is consistent

**Acceptance Criteria:**
- [ ] Background sync when connectivity restored
- [ ] Retry with exponential backoff
- [ ] Idempotency keys prevent duplicates
- [ ] Conflict detection (handled by supervisor)
- [ ] Success removes from pending queue
- [ ] Detect stock overselling during sync
- [ ] Supervisor notification for stock issues
- [ ] All affected orders flagged: oversoldItem = true

**Story Points:** 13

---

### US-4.5: Conflict Resolution (Supervisor)
**As a** supervisor  
**I want** to resolve data conflicts  
**So that** sync completes correctly

**Acceptance Criteria:**
- [ ] Conflict list in supervisor Dashboard
- [ ] Shows: type, local value, server value
- [ ] Action: Accept local / Accept server / Create adjustment
- [ ] Badge shows pending conflicts
- [ ] Cashier never sees this screen
- [ ] Stock conflicts create adjustment log

**Story Points:** 5

---

### US-4.6: Network Resilience
**As a** system  
**I want** to handle network failures gracefully  
**So that** the app remains stable and user-friendly

**Acceptance Criteria:**
- [ ] Request timeout configuration (default: 30s)
- [ ] Retry strategy: Exponential backoff (1s, 2s, 4s, 8s, 16s)
- [ ] Max retries: 5 attempts with user feedback
- [ ] Circuit breaker pattern
- [ ] Partial sync handling with progress indicator
- [ ] Error categorization (network/server/client)

**Story Points:** 8

---

### US-4.7: Local Data Migration
**As a** system  
**I want** to migrate local database schema on app updates  
**So that** offline data remains compatible

**Acceptance Criteria:**
- [ ] Schema versioning: user_version pragma
- [ ] Migration runner: Run migrations sequentially
- [ ] Backward compatibility support
- [ ] Rollback safety: Backup old tables
- [ ] User notification during migration

**Story Points:** 5

---

## Epic 5: Refunds

### US-5.1: Orders History
**As a** supervisor  
**I want** to view past orders  
**So that** I can process refunds

**Acceptance Criteria:**
- [ ] Search by order number or date
- [ ] Filter by status
- [ ] Order details on tap
- [ ] "Refund" button on completed orders
- [ ] Shows refund history if any
- [ ] Reprint receipt action (permission-gated)

**Story Points:** 5

---

### US-5.2: Refund Request
**As a** supervisor  
**I want** to process a return/exchange/void  
**So that** the customer is satisfied

**Acceptance Criteria:**
- [ ] Three modes: Return, Exchange, Void
- [ ] Return: select items to return
- [ ] Exchange: return + add new items
- [ ] Same-day void rule (calendar day, not shift)
- [ ] Visual indicator for void eligibility
- [ ] Reason selection (required, logged)
- [ ] Stock adjustment option
- [ ] Manager approval via PIN

**Story Points:** 8

---

### US-5.3: Refund Receipt
**As a** cashier  
**I want** to print a refund receipt  
**So that** there's a record

**Acceptance Criteria:**
- [ ] Shows original order reference
- [ ] Items returned
- [ ] Refund amount
- [ ] Refund method (cash back, card reversal)
- [ ] Print button
- [ ] Logged in audit log

**Story Points:** 3

---

## Epic 7 (continued): Security

### US-7.4: Device Time Lock
**As a** system  
**I want** to detect time manipulation  
**So that** timestamps are trustworthy

**Acceptance Criteria:**
- [ ] Sync server time on each API call
- [ ] Detect drift > 5 minutes: show warning
- [ ] Drift > 1 hour: block refunds/discounts (not sales)

**Story Points:** 3

---

### US-7.5: Global Error Handler
**As a** cashier  
**I want** consistent error messages  
**So that** I know what to do

**Acceptance Criteria:**
- [ ] Network error: "اتصال ضعيف - حاول مرة أخرى"
- [ ] Auth error: redirect to login, preserve cart
- [ ] Validation error: show field-specific messages
- [ ] Retry dialog with countdown
- [ ] Offline fallback for critical operations

**Story Points:** 3

---

## Epic 6 (continued): Shift

### US-6.3: Close Shift
**As a** cashier  
**I want** to close my shift  
**So that** I can end my workday

**Acceptance Criteria:**
- [ ] Closing cash input (counted by cashier)
- [ ] Expected cash calculation:
  ```
  expectedCash = openingCash
               + cashPayments
               + mixedCashPortion
               - cashRefunds
               + cashIn
               - cashOut
  ```
- [ ] Breakdown display with each component
- [ ] Card totals shown separately
- [ ] Difference = Counted - Expected
- [ ] Notes input for discrepancy
- [ ] Supervisor approval if difference > threshold
- [ ] Shift summary printed

**Story Points:** 5

---

# Summary

## Sprint A (7 Days) - v1.3.1 ✅ Balanced
| Epic | Stories | Points |
|------|---------|--------|
| Auth & Store | 3 | 10 |
| Sales Flow | 6 | 34 |
| Payment & Receipt | 4 | 26 |
| Shift & Cash | 2 | 10 |
| Permissions | 3 | 16 |
| **Total** | **18** | **92** |

## Sprint B (7 Days) - v1.3.1
| Epic | Stories | Points |
|------|---------|--------|
| Sales Flow | 2 | 6 |
| Payment & Receipt | 1 | 5 |
| Offline & Sync | 7 | 47 |
| Refunds | 3 | 16 |
| Security | 2 | 6 |
| Shift (close) | 1 | 5 |
| **Total** | **16** | **85** |

---

## Velocity Notes

✅ **Capacity Balanced:**
- Sprint A: 92 points (reduced from 95)
- Sprint B: 85 points (increased from 82)
- **Total: 177 points across 34 stories**
- Average: 5.2 points/story

**Confidence Level: High (90%)** - Realistic for 3-4 developer team

---

## Patch Notes (v1.3.1) - Capacity Balance

| Change | الحقل | التعديل |
|--------|-------|---------|
| US-2.7 | Moved | Sprint A → Sprint B |
| US-2.5 | Points | 5 → 6 (GDPR compliance) |
| US-2.6 | Points | 3 → 4 (notification settings) |
| US-3.4 | Tech Notes | WhatsApp prerequisites clarified |
| NEW | Section | Pre-Sprint Checklist added |
| Sprint A | Total | 95 → 92 points |
| Sprint B | Total | 82 → 85 points |

---

## Patch Notes (v1.3.0)

| US | الحقل | التعديل |
|----|-------|---------|
| US-3.4 | NEW | WhatsApp digital receipts - 8 points |
| US-2.5 | NEW | Customer quick lookup - 5 points |
| US-2.6 | NEW | Low stock alerts - 3 points |
| US-2.7 | NEW | Scanner feedback - 3 points |
| US-2.8 | NEW | Sale notes - 3 points |
| US-3.5 | NEW | Receipt customization - 5 points |

---

## Patch Notes (v1.2.0)

| US | الحقل | التعديل |
|----|-------|---------|
| US-2.4 | AC + Points | VAT inclusive/exclusive + 5→8 |
| US-7.3 | AC + Points | TOTP offline PIN + 5→8 |
| US-4.4 | AC + Points | Stock overselling + 8→13 |
| US-4.6 | NEW | Network resilience - 8 points |
| US-4.7 | NEW | Schema migration - 5 points |

---

# Future Features (P2 - Post-Launch)

## Epic 8: Advanced Features

### US-8.1: Voice Quantity Input (BETA)
**Priority:** P2 | **Points:** 5  
**Description:** Speech-to-text for hands-free quantity entry

### US-8.2: Smart Discount Suggestions (AI)
**Priority:** P2 | **Points:** 8  
**Description:** AI suggests discounts for slow-moving/expiring items

### US-8.3: Additional Payment Methods
**Priority:** P2 | **Points:** 13  
**Description:** Bank transfer, STC Pay, Apple Pay, Mada QR

### US-8.4: Daily Sales Target Tracker
**Priority:** P2 | **Points:** 5  
**Description:** Gamification - target progress, leaderboards

### US-8.5: Customer Reservation System
**Priority:** P2 | **Points:** 8  
**Description:** Reserve low-stock items for customers

---

**Total P2 Features:** 5 stories, 39 points  
**Estimated Timeline:** Sprint C-D (Post-launch)

---

**Generated from POS_SITEMAP.md v1.4.0 + Consultant Feedback v4**
