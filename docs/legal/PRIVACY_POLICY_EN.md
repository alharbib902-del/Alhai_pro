# Privacy Policy — Alhai Platform

> **Notice:** This template requires review by a licensed attorney in the Kingdom of Saudi Arabia before official use.

**Effective Date:** 2026-05-01
**Last Updated:** 2026-04-16
**Version:** 1.0

---

## 1. Introduction

Welcome to **Alhai** (حي). **BLTech Solutions** ("Company", "we", "us", "our") — headquartered in Jeddah, Kingdom of Saudi Arabia — operates a suite of grocery delivery applications:

| Application | Purpose | Platform |
|-------------|---------|----------|
| **Alhai — Customer** (Customer App) | Order products and track delivery | iOS, Android |
| **Alhai — Driver** (Driver App) | Manage delivery orders | iOS, Android |
| **Distributor Portal** | Manage inventory and e-invoicing | Web browser |

This Privacy Policy explains how we collect, use, share, and protect your personal data when you use any of our applications or services (collectively, the "Service").

By using the Service, you consent to the practices described in this policy. If you do not agree, please discontinue use of the Service.

This policy complies with:
- The **Saudi Personal Data Protection Law** (PDPL), issued by Royal Decree No. M/19 dated 9/2/1443H, and its implementing regulations.
- **GDPR**-aligned best practices.
- **App Store** and **Google Play Store** privacy requirements.

---

## 2. Data We Collect

### 2.1 Data Common to All Applications

| Data Type | Examples | Legal Basis (PDPL) |
|-----------|---------|-------------------|
| Account data | Name, phone number, email address | Contract performance (Art. 5) |
| Device data | Device model, OS, app version | Legitimate interest (Art. 6) |
| Error logs | Crash reports and technical diagnostics | Legitimate interest (Art. 6) |
| Authentication data | OTP verification code, encrypted session tokens | Contract performance (Art. 5) |

### 2.2 Customer App — Additional Data

| Data Type | Details | Why We Collect It |
|-----------|---------|-------------------|
| Geolocation | GPS coordinates while app is in use only | Delivery address identification, nearby store display |
| Addresses | Saved delivery addresses | Streamline ordering process |
| Order history | Products ordered, amounts, order dates | Purchase history display, customer support |
| Payment data | Payment method (cash/electronic) — we do not store card details | Order processing |
| Phone number | Saudi mobile number | Registration and OTP verification |

### 2.3 Driver App — Additional Data

| Data Type | Details | Why We Collect It |
|-----------|---------|-------------------|
| Geolocation (continuous) | GPS coordinates during active delivery — runs in background | Real-time delivery tracking |
| Camera | Proof-of-delivery photos (optional) | Delivery confirmation |
| Earnings data | Completed task records and commissions | Payment calculation |
| Phone number | Saudi mobile number | Registration and customer communication |

> **Important Note:** You can disable location sharing at any time in your device settings, but this will prevent you from receiving delivery orders.

### 2.4 Distributor Portal — Additional Data

| Data Type | Details | Why We Collect It |
|-----------|---------|-------------------|
| Business data | Commercial Registration (CR), VAT number | ZATCA e-invoicing compliance |
| Financial data | Invoices, pricing, sales volume | Business relationship management |
| Product data | Product catalog and inventory | Display products in Customer App |
| Multi-factor authentication (MFA) | TOTP code and encrypted recovery codes | Super admin account protection |

---

## 3. How We Use Your Data

We use your data for the following purposes:

1. **Service delivery:** Process orders, facilitate delivery, issue e-invoices.
2. **Service improvement:** Analyze usage patterns to enhance our applications (aggregated data only).
3. **Security:** Fraud detection, account protection, suspicious activity logging.
4. **Legal compliance:** ZATCA e-invoicing system, Value Added Tax (15%).
5. **Communication:** Order notifications, technical updates, security alerts.
6. **Technical support:** Resolve technical issues and respond to inquiries.

**We do not use your data for marketing or advertising purposes without your explicit consent.**

---

## 4. Data Sharing

### 4.1 Service Providers (Data Processors)

| Provider | Service | Processing Location | Shared Data |
|----------|---------|-------------------|-------------|
| **Supabase** | Database and authentication | Cloud servers (EU-compliant region) | Account data, transactions |
| **Sentry** | Error monitoring | Germany (GDPR-compliant) | Crash reports — no personal financial data (`sendDefaultPii: false`) |
| **ZATCA** | Zakat, Tax and Customs Authority | Kingdom of Saudi Arabia | E-invoice data (legal obligation) |
| **Firebase** (future) | Push notifications | United States (Google Cloud) | Device token only |

### 4.2 We Do NOT Share Your Data With:
- Advertising or marketing parties.
- Data brokers.
- Any entity for purposes unrelated to the Service.

### 4.3 Legal Disclosure
We may disclose your data when:
- Required by court order or official request from a competent government authority.
- Necessary to protect our legal rights or user safety.

---

## 5. Data Storage Location

- **Primary data:** Stored on **Supabase** cloud servers. We aim to use a server region compliant with Kingdom of Saudi Arabia requirements.
- **Error reports:** Stored on **Sentry** servers in Germany (European Union).
- **Local data:** Some data is stored locally on your device using encrypted secure storage (`flutter_secure_storage` with `EncryptedSharedPreferences` on Android).
- **ZATCA data:** Sent directly to ZATCA servers in the Kingdom of Saudi Arabia.

Security measures include:
- Data encryption in transit (TLS 1.2+) with Certificate Pinning on mobile applications.
- Access control via Row Level Security (RLS) policies.
- HTTP security headers on all requests (`X-Content-Type-Options`, `X-Frame-Options`, `Strict-Transport-Security`).

---

## 6. Data Retention Period

| Data Type | Retention Period | Reason |
|-----------|-----------------|--------|
| Account data | Duration of active account + 30 days after deletion | Allow account recovery |
| Transaction records | 7 years from transaction date | ZATCA and tax regulation requirements |
| Location data | 90 days | Delivery dispute resolution |
| Crash reports | 90 days | Service quality improvement |
| E-invoice data | 7 years | Legal obligation (ZATCA) |
| Audit logs | 1 year | Security and compliance |

After the retention period expires, data is permanently deleted or anonymized so it cannot be linked to an identified individual.

---

## 7. Your Rights (Under PDPL)

Under the Saudi Personal Data Protection Law, you have the following rights:

| Right | Description | How to Exercise |
|-------|-------------|----------------|
| **Access** (Art. 4) | View the personal data we hold about you | Contact us via email below |
| **Rectification** (Art. 4) | Request correction of inaccurate data | Through account settings or contact us |
| **Erasure** (Art. 4) | Request deletion of your personal data | See Section 8 below |
| **Objection** (Art. 7) | Object to processing of your data for certain purposes | Contact us via email below |
| **Data portability** (Art. 4) | Obtain a copy of your data in a machine-readable format | Contact us via email below |
| **Withdraw consent** | Withdraw your consent to data processing at any time | Contact us or delete your account |

**Response time:** We commit to responding to your request within **30 days** of submission per PDPL requirements.

**Complaints authority:** If you are not satisfied with our response, you have the right to file a complaint with the **Saudi Data and Artificial Intelligence Authority** (SDAIA).

---

## 8. Account Deletion

### 8.1 Customer App
You can delete your account directly from the app:
1. Open **Profile**
2. Tap **Delete Account**
3. Confirm the deletion

Upon account deletion:
- Your personal data will be deleted within 30 days.
- Transaction records are retained for 7 years (legal obligation).
- Order history and saved addresses are deleted.
- This action is irreversible.

### 8.2 Driver App
Contact technical support via the email below to request account deletion. This requires:
- Settlement of all outstanding financial dues.
- No active delivery orders.

### 8.3 Distributor Portal
Contact technical support to request organization account deletion. This requires:
- Settlement of all outstanding invoices.
- Retention of e-invoice data per ZATCA regulations.

---

## 9. Cookies

### 9.1 Mobile Applications (Customer App, Driver App)
Mobile applications do not use cookies. Instead, we use:
- Local secure storage (`flutter_secure_storage`) for session data.
- PKCE authentication to secure the login process.

### 9.2 Distributor Portal (Web)
We use essential cookies only:
- **Session cookies:** Maintain your login state. Expire when the browser is closed.
- **Authentication cookies:** Supabase Auth tokens. Required for service functionality.

We do not use analytical or advertising cookies.

---

## 10. Children's Protection

Alhai services are **not intended for individuals under 18 years of age**. We do not knowingly collect personal data from children or minors.

- **Customer App:** Requires a Saudi phone number and OTP verification.
- **Driver App:** Requires the driver to be an adult (18+) with a valid driver's license.
- **Distributor Portal:** Requires an active commercial registration.

If we discover that a user under 18 has created an account, we will immediately delete their account and data.

---

## 11. Changes to This Policy

- We may update this policy periodically to reflect changes in our services or applicable laws.
- We will notify you of material changes via:
  - In-app notification.
  - Email (if registered with us).
- Your continued use of the Service after changes are published constitutes acceptance.
- You can review the last update date at the top of this page.

---

## 12. Contact Information

For any inquiries or requests related to privacy or your personal data:

| | |
|---|---|
| **Company** | BLTech Solutions |
| **Address** | Jeddah, Kingdom of Saudi Arabia |
| **Email** | privacy@alhai.store |
| **Support** | support@alhai.store |
| **Phone** | [To be added] |

**Data Protection Officer (DPO):** Not yet appointed — will be announced before official launch per PDPL requirements.

---

## 13. Technical Appendix — Data Processing Summary

| Element | Value |
|---------|-------|
| Encryption in transit | TLS 1.2+ with Certificate Pinning |
| Local storage | `EncryptedSharedPreferences` (Android), Keychain (iOS) |
| Database provider | Supabase (PostgreSQL) |
| Error monitoring provider | Sentry (Germany — EU) |
| Authentication | Supabase Auth + PKCE + MFA (TOTP) for admins |
| PII sent to Sentry | `sendDefaultPii: false` |
| Sentry screenshots | `attachScreenshot: true` (crash reports only) |
| Performance trace rate | 30% in production, 100% in development |

---

*Last updated: April 16, 2026*
*Version: 1.0 — Draft requiring legal review*
