# 🛒 POS App - Alhai Grocery Store

**Version:** 1.0.0-dev  
**Date:** 2026-01-20  
**Platform:** Flutter (iOS/Android)

---

## 📋 Overview

تطبيق نقاط البيع (POS) لمتاجر البقالة الذكية. يدعم:
- البيع السريع (Online/Offline)
- إدارة المخزون والمنتجات
- إدارة العملاء والديون
- تقارير المبيعات والضرائب (ZATCA)
- الإيصالات الرقمية عبر WhatsApp

---

## 🏗️ Project Structure

```
pos_app/
├── lib/
│   ├── main.dart
│   ├── app/
│   ├── features/
│   ├── core/
│   └── shared/
├── docs/
│   ├── POS_SITEMAP.md      ← خريطة الشاشات
│   ├── POS_BACKLOG.md      ← Backlog التطوير
│   ├── POS_API_CONTRACT.md ← عقد الـ API
│   └── POS_APP_SPEC.md     ← المواصفات التفصيلية
└── test/
```

---

## 📊 Development Status

| Sprint | Stories | Points | Status |
|--------|---------|--------|--------|
| Sprint A | 18 | 92 | 🔲 Not Started |
| Sprint B | 16 | 85 | 🔲 Not Started |
| **Total** | **34** | **177** | - |

---

## 🚀 Quick Start

```bash
# Clone the repository
git clone https://github.com/alhai/pos_app.git

# Install dependencies
flutter pub get

# Run code generation
flutter pub run build_runner build

# Run the app
flutter run
```

---

## 📚 Documentation

| Document | Description |
|----------|-------------|
| [POS_SITEMAP.md](./POS_SITEMAP.md) | خريطة الشاشات والتنقل |
| [POS_BACKLOG.md](./POS_BACKLOG.md) | User Stories + Acceptance Criteria |
| [POS_API_CONTRACT.md](./POS_API_CONTRACT.md) | عقد الـ API |
| [POS_APP_SPEC.md](./POS_APP_SPEC.md) | المواصفات التفصيلية |

---

## 🔧 Tech Stack

- **Framework:** Flutter 3.16+
- **State Management:** Riverpod + ChangeNotifier
- **Local DB:** SQLite (Drift)
- **Network:** Dio
- **Code Generation:** freezed, json_serializable
- **Testing:** flutter_test, mockito

---

## 📱 Features (Sprint A)

- ✅ OTP Authentication
- ✅ Store Selection
- ✅ Quick Sale (Scan/Search)
- ✅ Cart Management
- ✅ Payment Processing (Cash)
- ✅ Receipt Printing
- ✅ WhatsApp Digital Receipts
- ✅ Customer Lookup
- ✅ Low Stock Alerts
- ✅ Shift Management
- ✅ Role-Based Access

---

## 📱 Features (Sprint B)

- ⏳ Offline Sales
- ⏳ Background Sync
- ⏳ Conflict Resolution
- ⏳ Refunds & Returns
- ⏳ Card Payments (Semi-integrated)
- ⏳ Receipt Customization
- ⏳ Scanner Audio/Haptic Feedback

---

## 👥 Team

| Role | Name |
|------|------|
| Owner | Basem Al-Harbi |
| Developer A | TBD |
| Developer B | TBD |

---

## 📄 License

Proprietary - Alhai © 2026
