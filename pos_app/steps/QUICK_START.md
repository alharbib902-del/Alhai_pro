# 🚀 POS App - Quick Start Guide

**Version:** 1.0.0  
**Date:** 2026-01-20  
**Source:** Synced with POS_BACKLOG.md v1.3.1

---

## 📋 Source of Truth

| Document | Purpose |
|----------|---------|
| [`POS_BACKLOG.md`](../POS_BACKLOG.md) | User Stories + Acceptance Criteria |
| [`POS_SITEMAP.md`](../POS_SITEMAP.md) | Screen Map + Navigation |
| [`POS_API_CONTRACT.md`](../POS_API_CONTRACT.md) | API Endpoints |
| [`README.md`](../README.md) | Project Overview |

---

## 🎯 Sprint Overview

| Sprint | Stories | Points | Focus |
|--------|---------|--------|-------|
| **A** | 18 | 92 | Authentication, Sales, Payment |
| **B** | 16 | 85 | Offline, Sync, Refunds |
| **Total** | 34 | 177 | - |

---

## 🛠️ Development Steps

### 1. Setup
```bash
cd pos_app
flutter pub get
flutter pub run build_runner build
```

### 2. Run Dev Server
```bash
flutter run -d windows  # or macos, chrome
```

### 3. Run Tests
```bash
flutter analyze
flutter test
```

---

## 📱 Key Files

```
pos_app/
├── lib/
│   ├── main.dart
│   ├── app/
│   ├── features/
│   │   ├── auth/       ← US-1.1 to US-1.3
│   │   ├── sales/      ← US-2.1 to US-2.8
│   │   ├── payment/    ← US-3.1 to US-3.5
│   │   ├── shift/      ← US-6.1 to US-6.3
│   │   ├── offline/    ← US-4.1 to US-4.7
│   │   ├── refunds/    ← US-5.1 to US-5.3
│   │   └── settings/   ← US-7.1 to US-7.5
│   └── core/
└── test/
```

---

## 🔑 Key Decisions

| Decision | Details |
|----------|---------|
| **Offline-First** | SQLite + Sync Queue |
| **PIN Validation** | TOTP for offline |
| **Payment (Sprint A)** | Cash only |
| **Payment (Sprint B)** | Cash + Card (semi-integrated) |
| **WhatsApp** | ZATCA-compliant receipts |

---

## 📚 Next Steps

1. Read [`POS_BACKLOG.md`](../POS_BACKLOG.md) Pre-Sprint Checklist
2. Review Sprint A User Stories
3. Setup development environment
4. Start with US-1.1 (Splash Screen)

---

**Last Updated:** 2026-01-20
