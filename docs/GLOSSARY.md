# Glossary — Alhai Platform

---

## Arabic Terminology Used in the Codebase

| Arabic | Transliteration | English | Context |
|--------|----------------|---------|---------|
| حي | Hai / Alhai | Neighborhood | App name — "حي" means neighborhood |
| بقالة | Baqala | Grocery store | The type of store served by the platform |
| موزّع | Muwazzi' | Distributor | Business entity selling via the platform |
| سائق | Saa'iq | Driver | Delivery driver |
| عميل | 'Ameel | Customer | End user ordering products |
| طلب | Talab | Order | A customer's purchase order |
| فاتورة | Fatoora | Invoice | E-invoice (ZATCA-compliant) |
| سلّة | Salla | Cart/Basket | Shopping cart |
| توصيل | Tawseel | Delivery | Order delivery to customer |
| مخزون | Makhzoon | Inventory/Stock | Product stock levels |
| إشعار | Ish'aar | Notification | Push/in-app notification |
| ملف شخصي | Milaf Shakhsi | Profile | User profile screen |
| إعدادات | I'dadaat | Settings | App settings |
| حذف الحساب | Hadhf al-Hisab | Delete Account | Account deletion feature |
| الشاشة الرئيسية | Ash-Shasha ar-Ra'eesiyya | Home Screen | Main app screen |

---

## Technical Terms

| Term | Full Name | Description |
|------|-----------|-------------|
| **RLS** | Row Level Security | PostgreSQL feature that restricts data access per row based on user identity |
| **PKCE** | Proof Key for Code Exchange | OAuth 2.0 extension for secure auth in mobile/native apps |
| **MFA** | Multi-Factor Authentication | Two or more verification methods for login |
| **TOTP** | Time-based One-Time Password | Algorithm for generating 6-digit codes (Google Authenticator) |
| **OTP** | One-Time Password | Single-use code sent via SMS for verification |
| **CSP** | Content Security Policy | HTTP header that controls which resources a web page can load |
| **CORS** | Cross-Origin Resource Sharing | Mechanism allowing web apps to access resources from different domains |
| **TLS** | Transport Layer Security | Protocol for encrypted communication over networks |
| **AAL** | Authenticator Assurance Level | Level of authentication strength (aal1 = password, aal2 = password + MFA) |
| **CSID** | Cryptographic Stamp Identifier | Certificate issued by ZATCA for e-invoice signing |
| **PWA** | Progressive Web App | Web app that can be installed and used like a native app |
| **AAB** | Android App Bundle | Google's publishing format for Android apps |
| **APK** | Android Package Kit | Installation file format for Android apps |
| **DSN** | Data Source Name | Connection string for Sentry error reporting |
| **DPO** | Data Protection Officer | Person responsible for data protection compliance |
| **RTL** | Right-to-Left | Text direction for Arabic and Hebrew languages |
| **ASO** | App Store Optimization | Techniques to improve app visibility in store search |

---

## Saudi-Specific Terms

| Term | Arabic | Description |
|------|--------|-------------|
| **ZATCA** | هيئة الزكاة والضريبة والجمارك | Zakat, Tax and Customs Authority — Saudi Arabia's tax authority. Manages e-invoicing regulations. |
| **PDPL** | نظام حماية البيانات الشخصية | Personal Data Protection Law — Saudi Arabia's data privacy regulation (Royal Decree M/19, 1443H). |
| **SDAIA** | الهيئة السعودية للبيانات والذكاء الاصطناعي | Saudi Data and AI Authority — oversees data protection and AI governance. |
| **CR** | سجل تجاري | Commercial Registration — business license number issued by the Ministry of Commerce. Required for all businesses. |
| **VAT** | ضريبة القيمة المضافة | Value Added Tax — 15% tax on goods and services in Saudi Arabia. |
| **SAR** | ريال سعودي (ر.س) | Saudi Riyal — official currency. ISO 4217 code: SAR. |
| **Fatoora** | فاتورة | The ZATCA e-invoicing portal/API (gw-fatoora.zatca.gov.sa). |
| **Phase 2** | المرحلة الثانية | ZATCA e-invoicing Phase 2 (Integration Phase) — invoices must be reported/cleared via ZATCA API. |
| **B2C** | من شركة إلى مستهلك | Business-to-Consumer — simplified invoices (reporting to ZATCA). |
| **B2B** | من شركة إلى شركة | Business-to-Business — standard tax invoices (clearance by ZATCA). |
| **Simplified Invoice** | فاتورة مبسّطة | B2C invoice type. Invoice subtype starts with `02`. |
| **Standard Invoice** | فاتورة ضريبية | B2B invoice type. Invoice subtype starts with `01`. |
| **Credit Note** | إشعار دائن | Document issued to reduce the value of a previously issued invoice. Type code: 381. |
| **Debit Note** | إشعار مدين | Document issued to increase the value of a previously issued invoice. Type code: 383. |

---

## Platform & Infrastructure Terms

| Term | Description |
|------|-------------|
| **Supabase** | Open-source backend-as-a-service built on PostgreSQL. Provides database, auth, storage, realtime, and edge functions. Used as Alhai's primary backend. |
| **Sentry** | Error monitoring and performance tracking service. Each Alhai app has its own Sentry project. Servers in Germany (EU GDPR-compliant). |
| **Firebase** | Google's mobile platform. Used in Alhai for push notifications via Firebase Cloud Messaging (FCM). Not yet configured. |
| **Netlify** | Web hosting platform. Recommended for deploying the Distributor Portal. Provides free SSL, CDN, and CI/CD. |
| **Flutter** | Google's UI toolkit for building natively compiled applications for mobile, web, and desktop from a single codebase. Alhai uses Flutter for all apps. |
| **Riverpod** | State management library for Flutter. Successor to Provider. Used across all Alhai apps. |
| **Drift** | Reactive persistence library for Flutter (formerly Moor). Used for local database in mobile apps. |
| **dart-define** | Flutter mechanism for compile-time environment variables. All Alhai apps use `--dart-define-from-file=.env`. |

---

## Business Terms

| Term | Description |
|------|-------------|
| **BLTech Solutions** | The company developing and operating the Alhai platform. Headquartered in Jeddah, Saudi Arabia. |
| **Alhai** (حي) | The product/platform name. Means "neighborhood" in Arabic. |
| **Super Admin** | Highest privilege role in the Distributor Portal. Can manage all distributors, users, and platform settings. Requires MFA. |
| **Distributor** | A business (grocery store, supermarket) that lists products on the Alhai platform and fulfills customer orders. |
| **Commission** | Percentage fee charged by Alhai on each sale made through the platform. Rate set in individual distributor agreements. |
| **Staged Rollout** | Gradual release of an app update to a percentage of users (10% → 25% → 50% → 100%) to catch issues early. |

---

*Last updated: April 16, 2026*
