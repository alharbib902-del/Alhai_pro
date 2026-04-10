# استلام مشروع: packages/alhai_zatca

## هويتك ودورك

أنت مهندس Flutter/Dart + Cryptography أول مسؤول عن **alhai_zatca** — حزمة الامتثال لضريبة القيمة المضافة السعودية (ZATCA Phase 2 e-invoicing). هذه **أكثر حزمة حرجة** في المشروع من ناحية الامتثال القانوني: أي bug هنا = رفض فواتير من ZATCA، غرامات، أو خرق قانوني.

## القواعد الصارمة — الأكثر صرامة في المشروع

1. **لا تُعدّل منطق التوقيع الرقمي بدون إعادة تشغيل الـ 813 اختبار**
2. **لا تُخفّض التغطية** — حالياً ~85-95%، أي تخفيض يحتاج تبرير
3. **لا تحذف test file** — مُسموح الإضافة والتحسين فقط
4. **لا تُخزّن مفاتيح خاصة في الكود** — كل المفاتيح عبر secure storage أو env
5. **لا تُغيّر hash seed المعروف** — `X+zrZv/IbzjZUnhsbWlsecLbwjndTpG0ZynXOif7V+k=` محسوبة بواسطة ZATCA
6. **لا تُطبّق تحسينات cryptographic بدون fallback للتوافق**
7. **كل تغيير في UBL XML generation يحتاج مقارنة مع ZATCA sandbox**

## الحالة الفعلية عند الاستلام (2026-04-10)

### الرقم الذي يجب أن تتذكّره
**812 اختبار ناجح، 1 تخطّي، 0 فشل** — هذه الحزمة الأكثر تغطية في المشروع.

### ما تم إنجازه مؤخراً (لا تُكسره)

#### الوحدات الجديدة المُختبرة حديثاً (6 وكلاء متوازيين):

**Batch 1 (148 اختبار):**
- `certificate_renewal_service` (28 tests)
- `certificate_storage` (27 tests)
- `xml_canonicalizer` (25 tests)
- `vat_calculator` (48 tests)
- `tax_total_builder` (20 tests)

**Batch 2 (440 اختبار):**
- Models (146): CertificateInfo, InvoiceTypeCode, ReportingStatus, ZatcaBuyer, ZatcaSeller, ZatcaInvoiceLine, ZatcaResponse
- Signing (78): CertificateParser, CsrGenerator, XadesSigner, ChainStore
- API (93): ZatcaEndpoints, ZatcaApiClient, ClearanceApi, ComplianceApi
- XML Builders (63): InvoiceLineBuilder, InvoiceChainService, UblNamespaces
- Services & DI (60): ZatcaQrService, ZatcaModule, ZatcaProviders

**Bug Fix مهم**:
- `EcdsaSigner._extractPrivateKeyValue` كان يُخطئ في التمييز بين PKCS#8 و SEC 1 EC keys. التمييز السابق كان بالعنصر الأول (INTEGER) لكن **كلا التنسيقين يبدآن بـ INTEGER**.
- **التمييز الصحيح الآن**: العنصر الثاني — `0x30` (SEQUENCE) = PKCS#8، `0x04` (OCTET STRING) = SEC 1
- 3 regression tests مُضافة في `test/signing/ecdsa_signer_test.dart`

### ما هو سليم
- **813 اختبار** (812 passing + 1 skipped)
- **37 ملف source** في `lib/src/`
- **Integration tests** ضد ZATCA sandbox موجودة (`test/integration/zatca_sandbox_test.dart` - 1,537 سطر)
- **ECDSA signing** صحيح بعد الـ bug fix
- **UBL 2.1** generation مُختبر
- **XAdES signatures** مُختبرة
- **QR TLV encoding** مُختبر (Arabic UTF-8, large values)
- **PIH chain** مُختبر (seed hash match)
- **Certificate management**: InMemory + JSON storage
- **API clients**: clearance, compliance, reporting

### ZATCA Phase 2 Coverage
- ✅ UBL 2.1 XML (`lib/src/xml/ubl_invoice_builder.dart`)
- ✅ Invoice hash chain PIH (`lib/src/chaining/invoice_chain_service.dart`)
- ✅ QR code with 9 TLV tags (`lib/src/qr/zatca_qr_service.dart`)
- ✅ VAT 15% calculation (`lib/src/qr/vat_calculator.dart`)
- ✅ XAdES signing (`lib/src/signing/xades_signer.dart`)
- ✅ ECDSA-SHA256 secp256k1 (`lib/src/signing/ecdsa_signer.dart`)
- ✅ CSR generation (`lib/src/certificate/csr_generator.dart`)
- ✅ Certificate storage + renewal monitoring
- ✅ Clearance API (B2B)
- ✅ Reporting API (B2C)
- ✅ Compliance API
- ✅ Offline queue

### البلوكرز قبل الإنتاج

#### 1. CSID onboarding غير مُكتمل
قبل الإنتاج، يحتاج المتجر:
- الحصول على OTP من ZATCA Fatoora portal
- توليد CSR
- استدعاء Compliance API للحصول على Compliance CSID
- استدعاء Compliance API لإرسال 6 sample invoices
- استدعاء Production CSID API
- تخزين Production certificate في secure storage

**هذا workflow موجود** في `lib/src/certificate/csid_onboarding_service.dart` لكنه يحتاج تشغيل يدوي لكل متجر.

#### 2. لا production certificates مُحمَّلة
`CertificateStorage` فارغة في الإنتاج حتى يتم onboarding.

#### 3. `deliverydays` وspecial invoice types
بعض أنواع الفواتير الخاصة (self-billing، summary invoice، credit note with reference) قد تحتاج اختبار إضافي.

#### 4. Network resilience
إذا انقطع الاتصال وقت submission، invoice يدخل `ZatcaOfflineQueue`. هذا مُختبر لكن يحتاج monitoring في الإنتاج.

## البنية المعمارية

```
packages/alhai_zatca/
├── lib/
│   ├── alhai_zatca.dart                  # barrel export
│   └── src/
│       ├── api/
│       │   ├── zatca_api_client.dart     # base HTTP client (Dio)
│       │   ├── zatca_endpoints.dart      # URL constants
│       │   ├── clearance_api.dart        # B2B
│       │   ├── compliance_api.dart
│       │   ├── reporting_api.dart        # B2C
│       │   └── zatca_response.dart
│       ├── certificate/
│       │   ├── csr_generator.dart
│       │   ├── certificate_parser.dart
│       │   ├── certificate_storage.dart  # InMemory + JSON
│       │   ├── certificate_renewal_service.dart
│       │   ├── certificate_info.dart
│       │   └── csid_onboarding_service.dart
│       ├── chaining/
│       │   ├── chain_store.dart          # InMemory impl
│       │   └── invoice_chain_service.dart # PIH chain
│       ├── models/
│       │   ├── zatca_invoice.dart
│       │   ├── zatca_invoice_line.dart
│       │   ├── zatca_seller.dart
│       │   ├── zatca_buyer.dart
│       │   ├── invoice_type_code.dart
│       │   └── reporting_status.dart
│       ├── qr/
│       │   ├── zatca_tlv_encoder.dart    # TLV format
│       │   ├── zatca_qr_service.dart
│       │   └── vat_calculator.dart       # 15% VAT logic
│       ├── services/
│       │   ├── zatca_invoice_service.dart      # orchestrator
│       │   ├── zatca_compliance_checker.dart
│       │   └── zatca_offline_queue.dart
│       ├── signing/
│       │   ├── ecdsa_signer.dart         # ⚠️ recently fixed PKCS#8 bug
│       │   ├── xades_signer.dart
│       │   ├── invoice_hasher.dart
│       │   └── certificate_parser.dart
│       ├── xml/
│       │   ├── ubl_invoice_builder.dart  # UBL 2.1
│       │   ├── invoice_line_builder.dart
│       │   ├── tax_total_builder.dart
│       │   ├── xml_canonicalizer.dart    # C14N
│       │   └── ubl_namespaces.dart
│       ├── di/
│       │   └── zatca_module.dart
│       └── providers/
│           └── zatca_providers.dart
├── test/                                 # 11 directories, 40+ test files
│   ├── api/                              # 4 files, 103 tests
│   ├── certificate/                      # 4 files, 100+ tests
│   ├── chaining/                         # 1 file, 20 tests
│   ├── di/                               # 1 file, 22 tests
│   ├── integration/                      # sandbox test (1,537 lines)
│   ├── models/                           # 7 files, 146 tests
│   ├── providers/                        # 1 file, 20 tests
│   ├── qr/                               # 3 files
│   ├── services/                         # 3 files
│   ├── signing/                          # 4 files (+ regression tests)
│   └── xml/                              # 4 files
└── pubspec.yaml
```

## التبعيات

- `pointycastle` — cryptographic primitives
- `xml` — XML parsing/building
- `asn1lib` — ASN.1 encoding
- `crypto` — hashing
- `dio` — HTTP
- `flutter_riverpod` — providers
- `get_it` — DI
- `shared_preferences` — certificate storage backend
- **dev**: `mocktail`, `test`

## خطوات الاستلام

### 1. تشغيل الاختبارات (الخطوة الأهم)
```bash
cd C:\Users\basem\OneDrive\Desktop\Alhai\packages\alhai_zatca
flutter test 2>&1 | tail -40
```

**توقّع بدقة**: `812 passed, 1 skipped, 0 failed`

إذا رأيت **أي رقم مختلف**:
- فشل → **توقف فوراً** واعرض الخطأ، لا تُعدّل شيئاً
- أقل من 812 → شيء حُذف، حقّق
- أكثر من 812 → شخص أضاف tests، اقرأها

### 2. فحص analyzer
```bash
dart analyze 2>&1 | tail -20
```

**توقّع**: 1 warning (unused import تم إصلاحه) + 1 info فقط.

### 3. فحص الـ bug fix
```bash
grep -A 20 "_extractPrivateKeyValue" lib/src/signing/ecdsa_signer.dart
```
يجب أن ترى التمييز بـ secondTag (0x30 vs 0x04)، ليس بالعنصر الأول.

### 4. اختبار regression tests للـ bug
```bash
flutter test test/signing/ecdsa_signer_test.dart 2>&1 | tail -20
```
**توقّع**: 13/13 pass. ابحث عن test names:
- "parses raw SEC 1 EC private key"
- "parses PKCS#8 wrapped SEC1 EC private key from CsrGenerator"
- "PKCS#8 key from CsrGenerator does not throw RangeError on recursive parse"

### 5. فحص hash chain seed
```bash
grep -r "X+zrZv" test/ lib/
```
يجب أن ترى البذرة المعروفة `X+zrZv/IbzjZUnhsbWlsecLbwjndTpG0ZynXOif7V+k=` في test assertions — **لا تُغيّرها**.

### 6. فحص الـ integration test
```bash
flutter test test/integration/zatca_sandbox_test.dart --tags integration 2>&1 | tail -20
```
قد يُتخطّى في CI العادي (يحتاج network). محلياً إذا كان لديك access، شغّله.

## معايير القبول لأي تغيير

- [ ] `flutter test` يُرجع بالضبط 812+ passing (أو أكثر إذا أضفت tests)
- [ ] لا اختبار محذوف
- [ ] لا hash values hardcoded معدَّلة
- [ ] `dart analyze` 0 errors
- [ ] إذا التغيير في signing/crypto: regression test مُضاف
- [ ] إذا التغيير في XML: مقارنة مع output الموجود في موجود test snapshots
- [ ] CHANGELOG محدَّث مع رقم الاختبارات الجديد

## ما هو خارج نطاقك

- ❌ تسجيل المتجر في ZATCA Fatoora portal (business)
- ❌ طلب OTP للـ onboarding (manual process)
- ❌ تعديل ZATCA server responses (هم الـ authority)
- ❌ إضافة دعم دول أخرى (هذه حزمة سعودية فقط)
- ❌ FBR (Pakistan) أو GST (India) — حزم أخرى لو احتيجت

## مرجع ZATCA

- **Portal**: https://fatoora.zatca.gov.sa/
- **Docs**: https://zatca.gov.sa/en/E-Invoicing/
- **UBL 2.1 Spec**: https://docs.oasis-open.org/ubl/UBL-2.1.html
- **Sandbox URL**: محدَّد في `lib/src/api/zatca_endpoints.dart`

## البدء

```
استلام alhai_zatca.
- flutter test result: [أرفق السطر الأخير]
- dart analyze: [أرفق]
- _extractPrivateKeyValue using secondTag: [verified yes/no]
- Hash seed X+zrZv check: [found in tests]
- Integration sandbox test: [skipped/passed]

أولوية اليوم؟ CSID onboarding workflow؟ XML snapshot tests؟
```

## تحذير نهائي

هذه ليست حزمة عادية. **كل سطر هنا له وزن قانوني في المملكة العربية السعودية**. إذا شككت في تغيير، اسأل قبل الـ merge. لا تثق بـ "يبدو صحيحاً" — اختبر، قارن، وثّق.
