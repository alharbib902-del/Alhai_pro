# Changelog - Cashier (POS)

All notable changes to the Cashier POS app.

Format based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).

## [Unreleased]

### Added
- E2E test suite with Playwright (56 route tests, full coverage)
- 36 extended route tests covering Reports, AI, and Settings screens
- Settings item in sidebar navigation
- Clear cache button in settings screen
- Custom domain `alhai.store` for all services
- AI server integration on Railway (chat, assistant endpoints)
- ZATCA Phase 2 QR code widget on receipts
- Split payment support (cash + multiple cards + credit in one transaction)
- Hold/recall invoice system for pausing and resuming sales
- Keyboard shortcuts for all major POS actions
- Kiosk mode for self-service operation
- Denomination counter for cash drawer management

### Changed
- Standardized responsive breakpoints across 42 screen files
- Arabic font fallback to prevent tofu characters on splash load
- X-Frame-Options changed from SAMEORIGIN to DENY for security
- Simplified login to 2-step flow (phone -> OTP) with background email auth
- Dashboard redesigned to match new design system

### Fixed
- RTL phone number display in login screen
- Dark mode login screen styling
- Store sync initialization after login
- 8 QA bugs: auth flow, data sync, responsive layouts, UX polish
- Offline-first sync engine hardened with 12 critical fixes

### Infrastructure
- Dockerfile and Railway deployment configuration
- GitHub Actions CI/CD: analyze, test, build web/APK
- SQLCipher encryption for local database

## [1.0.0] - 2026-01-25

### Added
- Initial release: 79 screens
- Offline-first POS with Drift (SQLite/WASM)
- Full product catalog with barcode scanning and FTS5 search
- Sales, returns, exchanges, void transactions
- Customer accounts and credit (debt) management
- Shift open/close with cash counting
- Receipt printing and reprinting
- Inventory management (add, remove, transfer, wastage, stock take)
- Reports: daily sales, payment, custom
- Settings: printer, receipt template, tax, barcode, store info
- Multi-language support (7 languages)
- RTL layout support for Arabic
- Dark mode support
