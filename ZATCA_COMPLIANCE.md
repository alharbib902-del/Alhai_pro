# ZATCA Phase 2 Compliance / الامتثال لهيئة الزكاة والضريبة

## Overview / نظرة عامة

This document attests to the ZATCA (Zakat, Tax and Customs Authority) Phase 2 e-invoicing compliance of the Alhai POS system for operations in the Kingdom of Saudi Arabia.

> For the full ZATCA package source, see `packages/alhai_zatca/`.
> For additional compliance details, see [docs/ZATCA_COMPLIANCE.md](docs/ZATCA_COMPLIANCE.md).

---

## Phase 2 Compliance Status / حالة الامتثال للمرحلة الثانية

**Status:** Phase 2 implementation complete. Pre-production items remain before go-live (see Known Gaps below).

---

## Scope / النطاق

Compliance applies to all Alhai POS applications that process B2B and B2C invoices:
- **Alhai Cashier** (`apps/cashier`) -- primary POS terminal
- **Alhai Admin** (`apps/admin`) -- store management and invoice review

---

## ZATCA Phase 2 Requirements Coverage / تغطية متطلبات المرحلة الثانية

### 1. Invoice Generation (Fatoora)

- [x] UBL 2.1 XML format (`packages/alhai_zatca/lib/src/xml/ubl_invoice_builder.dart`)
- [x] Invoice hash chain (PIH) (`packages/alhai_zatca/lib/src/chaining/invoice_chain_service.dart`)
- [x] QR code with 9 TLV tags for signed invoices (`packages/alhai_zatca/lib/src/qr/zatca_qr_service.dart`)
- [x] VAT calculation (15% standard rate) (`packages/alhai_zatca/lib/src/qr/vat_calculator.dart`)
- [x] Invoice type codes: 388 (tax invoice), 381 (credit note), 383 (debit note)

### 2. Cryptographic Signing

- [x] XAdES digital signatures (`packages/alhai_zatca/lib/src/signing/xades_signer.dart`)
- [x] ECDSA-SHA256 with secp256k1 curve (`packages/alhai_zatca/lib/src/signing/ecdsa_signer.dart`)
- [x] Certificate onboarding via CSR (`packages/alhai_zatca/lib/src/certificate/csr_generator.dart`)
- [x] Certificate storage and renewal (`packages/alhai_zatca/lib/src/certificate/`)

### 3. ZATCA API Integration

- [x] Compliance endpoint (`packages/alhai_zatca/lib/src/api/compliance_api.dart`)
- [x] Clearance endpoint for B2B invoices (`packages/alhai_zatca/lib/src/api/clearance_api.dart`)
- [x] Reporting endpoint for B2C invoices
- [x] Sandbox and production environment support

### 4. Offline Capability

- [x] Offline invoice queue (`packages/alhai_zatca/lib/src/services/zatca_offline_queue.dart`)
- [x] Automatic sync on reconnect
- [x] 24-hour reporting SLA support

---

## Architecture / البنية

| Component             | File                                       | Purpose                          |
|-----------------------|--------------------------------------------|----------------------------------|
| XML Generation        | `lib/src/xml/ubl_invoice_builder.dart`     | UBL 2.1 XML invoice generation   |
| Digital Signing       | `lib/src/signing/xades_signer.dart`        | XAdES signing with ECDSA-SHA256  |
| QR Code               | `lib/src/qr/zatca_qr_service.dart`        | TLV-encoded QR for receipts      |
| API Integration       | `lib/src/api/clearance_api.dart`           | Submit invoices to ZATCA portal  |
| Compliance Validation | `lib/src/api/compliance_api.dart`          | Pre-submission validation        |
| Offline Queue         | `lib/src/services/zatca_offline_queue.dart`| Queue invoices when offline      |
| Certificate Manager   | `lib/src/certificate/csr_generator.dart`   | CSR generation and cert handling |

### Invoice Flow

1. Sale completed -> Invoice data assembled
2. XML generated per UBL 2.1 spec
3. Invoice hash computed and chained (PIH)
4. Signed with store's ECDSA private key (XAdES)
5. QR code generated with TLV encoding (seller, VAT, timestamp, totals, hash)
6. Submitted to ZATCA API: clearance (B2B) or reporting (B2C)
7. If offline: queued and auto-submitted on reconnect within 24-hour SLA

**Dependencies:** `pointycastle` (crypto), `xml` (generation), `asn1lib` (certificate handling).

---

## Test Coverage / تغطية الاختبارات

| Area           | Tests  |
|----------------|--------|
| Signing        | 78     |
| XML builders   | 63     |
| API clients    | 93     |
| Models         | 146    |
| Services       | 60     |
| **Total**      | **820+** |

---

## Known Gaps (Pre-Production) / فجوات معروفة

The following items must be completed before production go-live:

- [ ] Complete production CSID onboarding with ZATCA
- [ ] Load real production certificates into certificate storage
- [ ] Register seller VAT number in ZATCA portal
- [ ] Obtain production API credentials
- [ ] Run end-to-end integration test against ZATCA sandbox
- [ ] Verify invoice chain seed hash matches ZATCA expectation

---

## Merchant Responsibility / مسؤولية التاجر

Compliance is the responsibility of the merchant operating the Alhai POS system. Alhai provides the software infrastructure; the merchant is responsible for:

- Registering with ZATCA
- Obtaining and renewing certificates
- Configuring VAT rates per product
- Reporting/clearing invoices within ZATCA SLAs
- Maintaining transaction records for 6 years

---

## References / المراجع

- ZATCA E-Invoicing Regulations: https://zatca.gov.sa/en/E-Invoicing/
- UBL 2.1 Specification: https://docs.oasis-open.org/ubl/UBL-2.1.html
- Package source: `packages/alhai_zatca/`
