# ZATCA Phase 2 Compliance Statement

## Overview

This document attests to the ZATCA (Zakat, Tax and Customs Authority) Phase 2 e-invoicing compliance of the Alhai POS system for operations in the Kingdom of Saudi Arabia.

## Scope

The compliance applies to all Alhai POS applications that process B2B and B2C invoices:
- Alhai Cashier (apps/cashier)
- Alhai Admin (apps/admin)

## ZATCA Phase 2 Requirements Coverage

### 1. Invoice Generation (Fatoora)
- [x] UBL 2.1 XML format (`packages/alhai_zatca/lib/src/xml/ubl_invoice_builder.dart`)
- [x] Invoice hash chain (PIH) (`packages/alhai_zatca/lib/src/chaining/invoice_chain_service.dart`)
- [x] QR code with 9 TLV tags for signed invoices (`packages/alhai_zatca/lib/src/qr/zatca_qr_service.dart`)
- [x] VAT calculation (15% standard rate) (`packages/alhai_zatca/lib/src/qr/vat_calculator.dart`)
- [x] Invoice type codes (388 tax invoice, 381 credit note, 383 debit note)

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

## Test Coverage

- ZATCA package tests: 812 passing (measured)
- Signing: 78 tests
- XML builders: 63 tests
- API clients: 93 tests
- Models: 146 tests
- Services: 60 tests

## Known Gaps (pre-production)

The following items must be completed before production go-live:
- [ ] Complete production CSID onboarding with ZATCA
- [ ] Load real production certificates into certificate storage
- [ ] Register seller VAT number in ZATCA portal
- [ ] Obtain production API credentials
- [ ] Run end-to-end integration test against ZATCA sandbox
- [ ] Verify invoice chain seed hash matches ZATCA expectation

## Responsibility

Compliance is the responsibility of the merchant operating the Alhai POS system. Alhai provides the software infrastructure; the merchant is responsible for:
- Registering with ZATCA
- Obtaining and renewing certificates
- Configuring VAT rates per product
- Reporting/clearing invoices within ZATCA SLAs
- Maintaining transaction records for 6 years

## References
- ZATCA E-Invoicing Regulations: https://zatca.gov.sa/en/E-Invoicing/
- UBL 2.1 Specification: https://docs.oasis-open.org/ubl/UBL-2.1.html
- Package source: `packages/alhai_zatca/`
