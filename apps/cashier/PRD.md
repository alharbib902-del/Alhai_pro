# Al-HAI Cashier - Product Requirements Document (PRD)

## 1. Product Overview

**Product Name:** Al-HAI Cashier (نظام الحي للكاشير)
**Version:** 1.0.0
**Platform:** Web, Android, iOS (Flutter)
**Type:** Point of Sale (POS) System for Retail Cashiers
**Core Principle:** 100% Offline-First with optional Cloud Sync

Al-HAI Cashier is a professional, enterprise-grade Point of Sale system designed for retail cashiers. It operates fully offline using a local SQLite database, with optional cloud synchronization via Supabase. The app supports 7 languages (including Arabic RTL), dark/light themes, thermal printer integration, and barcode scanning.

---

## 2. Authentication

- **Login Method:** OTP via WhatsApp (phone number verification)
- **Flow:** Phone input > OTP sent via WhatsApp > 6-digit code verification > Store selection
- **Dev Mode:** OTP displayed on-screen automatically (no WhatsApp needed)
- **Session Management:** Auto-timeout with configurable duration
- **Security:** HMAC-SHA256 hashed OTPs, rate limiting, brute-force protection

---

## 3. Core Features & Screens

### 3.1 Point of Sale (POS) - Main Screen
- Product grid/list with category filtering
- Full-text search and barcode scanning support
- Shopping cart with quantity editing, discounts
- Quick sale mode for fast transactions
- Favorites system for frequently sold items
- Hold/recall invoices
- Keyboard shortcuts for power users

**Routes:** `/pos`, `/pos/quick-sale`, `/pos/favorites`, `/pos/hold-invoices`, `/pos/barcode-scanner`

### 3.2 Payment Processing
- **Payment methods:** Cash, Card, Mixed (split), Customer Credit
- Cash payment with change calculation
- Card terminal integration
- Split payment across multiple methods
- Payment history with filtering and search
- Manager approval workflow for special operations

**Routes:** `/pos/payment`, `/payments/history`

### 3.3 Sales Management
- Sales history with detailed records
- Sale detail view with item breakdown
- Receipt reprinting
- Split receipt support

**Routes:** `/sales`, `/sales/:id`, `/sales/reprint`, `/sales/split-receipt/:id`

### 3.4 Returns & Exchanges
- Return/refund processing with reason codes
- Product exchange workflow
- Split refund across payment methods
- Return receipt generation

**Routes:** `/returns`, `/returns/request`, `/returns/reason`, `/returns/exchange`, `/returns/split-refund/:id`

### 3.5 Customer Management
- Customer list and detail view
- Account ledger with full transaction history
- Credit accounts with configurable limits
- Interest calculation on outstanding balances
- New transaction recording
- Customer analytics dashboard
- Debt overview

**Routes:** `/customers`, `/customers/:id`, `/customers/:id/ledger`, `/customers/accounts`, `/customers/debt`, `/customers/analytics`, `/customers/transaction`, `/customers/apply-interest`

### 3.6 Product Management
- Product catalog browsing
- Quick product addition
- Price editing
- Barcode printing
- Category management
- Price label customization
- Product detail view

**Routes:** `/products`, `/products/:id`, `/products/quick-add`, `/products/edit-price/:id`, `/products/print-barcode`, `/products/categories-view`, `/products/price-labels`

### 3.7 Inventory Management
- Add/remove stock
- Edit stock quantities
- Transfer between locations
- Physical stock take (count)
- Wastage and damage tracking
- Low stock alerts
- Expiry date tracking

**Routes:** `/inventory`, `/inventory/add`, `/inventory/remove`, `/inventory/edit/:id`, `/inventory/transfer`, `/inventory/stock-take`, `/inventory/wastage`, `/inventory/alerts`, `/inventory/expiry-tracking`

### 3.8 Shift Management
- Open shift with opening cash balance
- Close shift with reconciliation
- Cash in/out tracking during shift
- Daily summary report
- Shift history

**Routes:** `/shifts`, `/shifts/open`, `/shifts/close`, `/shifts/summary`, `/shifts/daily-summary`, `/shifts/cash-in-out`

### 3.9 Purchases & Receiving
- Purchase request creation for suppliers
- Goods receiving workflow with verification
- Purchase status tracking

**Routes:** `/purchase-request`, `/cashier-receiving`

### 3.10 Offers & Promotions
- Active offers management
- Coupon code system (create, validate, apply)
- Bundle deals (buy X get Y)

**Routes:** `/offers/active`, `/offers/coupon`, `/offers/bundles`

### 3.11 Reports & Analytics
- Daily sales report
- Top products report
- Cash flow analysis
- Customer reports
- Inventory reports
- Payment settlement reports
- Custom report builder

**Routes:** `/reports`, `/reports/daily-sales`, `/reports/top-products`, `/reports/cash-flow`, `/reports/customers`, `/reports/inventory`, `/reports/payments`, `/reports/custom`

### 3.12 Settings & Configuration
- Store information (name, logo, address, CR number)
- Tax settings (VAT rate, tax-inclusive/exclusive)
- Receipt template customization
- Printer configuration (thermal, Bluetooth, Sunmi)
- Payment device management
- User roles and permissions (owner, admin, manager, employee)
- Keyboard shortcuts reference
- Database backup and restore
- Privacy policy
- Language selection (7 languages)
- Theme selection (light/dark/system)

**Routes:** `/settings`, `/settings/store`, `/settings/tax`, `/settings/receipt`, `/settings/printer`, `/settings/payment-devices`, `/settings/users`, `/settings/keyboard-shortcuts`, `/settings/backup`, `/settings/privacy`, `/settings/language`, `/settings/theme`

---

## 4. Technical Architecture

### 4.1 Technology Stack
| Component | Technology |
|---|---|
| Framework | Flutter (Dart) |
| State Management | Riverpod |
| Navigation | GoRouter |
| Database | Drift (SQLite), WASM on web |
| Cloud Backend | Supabase |
| Analytics | Firebase |
| Error Tracking | Sentry |
| Localization | ARB files (7 languages) |
| Secure Storage | flutter_secure_storage |

### 4.2 Package Architecture
- `alhai_core` - Core business logic and configuration
- `alhai_database` - Drift ORM, DAOs, repositories
- `alhai_auth` - Authentication (WhatsApp OTP, Supabase auth)
- `alhai_pos` - POS-specific providers and screens
- `alhai_shared_ui` - Shared UI components, themes, router
- `alhai_design_system` - Design tokens, colors, typography
- `alhai_l10n` - Localization (ARB translations)
- `alhai_services` - Service layer
- `alhai_sync` - Cloud synchronization
- `alhai_reports` - Reporting engine

### 4.3 Database Schema (Key Tables)
- Products, Categories
- Sales, SaleItems, Returns
- Customers, Accounts, Transactions
- Inventory, StockMovements
- Shifts, CashMovements
- Orders, Purchases
- Suppliers, Expenses
- Discounts, Coupons
- Users, AuditLog
- WhatsAppMessages

### 4.4 Offline-First Design
- All data stored locally in encrypted SQLite database
- App works 100% without internet connection
- Optional cloud sync via Supabase when online
- Database seeded from CSV assets on first launch
- Background isolate for heavy data parsing

---

## 5. Hardware Integration

- **Thermal Printers:** ESC/POS protocol (USB, Bluetooth, Network)
- **Sunmi Devices:** Native Sunmi printer support
- **Barcode Scanners:** Keyboard-mode barcode gun support
- **Card Terminals:** Payment device integration
- **Cash Drawers:** Electronic cash drawer control

---

## 6. Security Features

- Encrypted local database (AES key stored in secure storage)
- HMAC-SHA256 OTP hashing with per-session salts
- Rate limiting on OTP send and verify attempts
- Constant-time comparison to prevent timing attacks
- Certificate pinning for API calls
- Session timeout with auto-lock
- Audit logging for sensitive operations
- Role-based access control (RBAC)
- Manager approval workflow for high-value operations

---

## 7. Localization & Accessibility

- **Languages:** Arabic, English, Urdu, Hindi, Bengali, French, Turkish
- **RTL Support:** Full right-to-left layout for Arabic/Urdu
- **Themes:** Light mode, Dark mode, System-follow
- **Responsive:** Adapts to mobile, tablet, and desktop screens

---

## 8. Key User Flows

### 8.1 First Launch
Onboarding (4 slides) > Login (phone + OTP) > Store Selection > POS Screen

### 8.2 Daily Operations
Open Shift > Process Sales > Cash In/Out > Close Shift > Daily Summary

### 8.3 Sale Flow
Search/Scan Product > Add to Cart > Apply Discounts > Select Payment Method > Process Payment > Print Receipt > (Optional) Send via WhatsApp

### 8.4 Return Flow
Find Original Sale > Select Items to Return > Choose Reason > Process Refund > Print Return Receipt

---

## 9. Non-Functional Requirements

- **Performance:** App launch < 2 seconds, sale processing < 1 second
- **Reliability:** 100% offline operation, no data loss
- **Storage:** Encrypted SQLite with secure key management
- **Scalability:** Supports thousands of products and transactions
- **Compliance:** ZATCA QR code support for Saudi tax compliance
