# تقرير المرحلة 2 — فحص ZATCA Phase 2

**التاريخ:** 2026-04-14
**الحزمة:** `packages/alhai_zatca/`
**الإصدار:** 1.0.0
**الفاحص:** Claude Opus 4.6 (Automated Compliance Audit)

---

## 1. ملخص تنفيذي

| البند | النتيجة |
|-------|---------|
| **الحالة العامة** | 🟡 قريب من الجاهزية |
| **الاختبارات** | 820 ناجح / 0 فاشل / 1 تخطّي |
| **تغطية الكود** | 91.7% |
| **Golden Snapshots** | 7 ملفات XML |
| **عيوب حرجة** | 1 |
| **عيوب عالية** | 2 |
| **عيوب متوسطة** | 3 |

### التوصية المختصرة

الكود **ممتاز بنيوياً** ويغطي كل متطلبات ZATCA Phase 2 الجوهرية. يوجد **عيب حرج واحد** (غياب `SignaturePolicyIdentifier` في XAdES) وعيبان عاليان يجب إصلاحهما قبل التسجيل الرسمي. بعد إصلاح هذه العيوب الثلاثة، الكود جاهز لبدء عملية التسجيل في ZATCA sandbox.

### أهم 3 عيوب

1. **❌ CRITICAL** — غياب `SignaturePolicyIdentifier` في XAdES SignedProperties
2. **🔴 HIGH** — عدم وجود XSD validation مدمج
3. **🔴 HIGH** — غياب `CountrySubentity` في عنوان البائع

---

## 2. جرد الحزمة (Package Inventory)

### 2.1 بنية الملفات

| المجلد | الملفات | المسؤولية |
|--------|---------|----------|
| `lib/src/xml/` | 5 ملفات | بناء UBL 2.1 XML |
| `lib/src/signing/` | 4 ملفات | XAdES-BES + ECDSA + SHA-256 |
| `lib/src/qr/` | 3 ملفات | TLV QR encoding (Tags 1-9) |
| `lib/src/api/` | 5 ملفات | ZATCA API (reporting/clearance/compliance) |
| `lib/src/certificate/` | 4 ملفات | CSR + CSID onboarding + renewal |
| `lib/src/chaining/` | 2 ملفات | PIH (Previous Invoice Hash) |
| `lib/src/models/` | 8 ملفات | نماذج البيانات |
| `lib/src/services/` | 3 ملفات | Orchestration + offline queue + compliance checker |
| `lib/src/di/` | 1 ملف | Dependency injection |
| `lib/src/providers/` | 1 ملف | Riverpod providers |

**المجموع:** 36 ملف مصدري + 35 ملف اختبار + 7 golden snapshots

### 2.2 الـ APIs العامة المُصدَّرة

الحزمة تُصدِّر **57 رمزاً** عبر `alhai_zatca.dart`:
- 8 نماذج (Invoice, Seller, Buyer, Line, CertificateInfo, Response, TypeCode, Status)
- 5 XML builders (UBL, InvoiceLine, TaxTotal, Namespaces, Canonicalizer)
- 4 Signing (XAdES, ECDSA, Hasher, CertParser)
- 3 QR (TLV encoder, QR service, VAT calculator)
- 5 API (Client, Endpoints, Compliance, Reporting, Clearance)
- 4 Certificate (CSR, Onboarding, Storage, Renewal)
- 2 Chaining (ChainService, ChainStore)
- 3 Services (InvoiceService, OfflineQueue, ComplianceChecker)
- 2 DI/Providers

### 2.3 الاعتماديات

| الحزمة | الاستخدام | الحالة |
|--------|----------|--------|
| `xml: ^6.5.0` | XML generation/parsing | ✅ pub.dev موثوقة |
| `pointycastle: ^3.9.1` | ECDSA + secp256k1 | ✅ pub.dev موثوقة |
| `asn1lib: ^1.5.3` | ASN.1 DER parsing (X.509, CSR) | ✅ pub.dev موثوقة |
| `basic_utils: ^5.7.0` | Certificate utilities | ✅ pub.dev موثوقة |
| `crypto: ^3.0.3` | SHA-256 hashing | ✅ pub.dev (Dart team) |
| `dio: ^5.4.0` | HTTP client | ✅ pub.dev موثوقة |
| `uuid: ^4.4.0` | UUID generation | ✅ pub.dev موثوقة |
| `shared_preferences: ^2.2.2` | Offline queue persistence | ✅ pub.dev (Flutter team) |
| `flutter_riverpod: ^2.4.9` | State management | ✅ pub.dev موثوقة |
| `get_it: ^7.7.0` | DI | ✅ pub.dev موثوقة |

**الحكم:** ✅ PASSED — كل الاعتماديات من مصادر موثوقة على pub.dev.

### 2.4 التوثيق الداخلي

- **README.md:** ❌ غير موجود
- **تعليقات الكود:** ✅ كل الملفات تحتوي doc comments تشرح القرارات (لماذا SHA-256, لماذا secp256k1, لماذا exc-c14n)
- **مراجع المواصفات:** ✅ إشارات لـ OASIS UBL 2.1, W3C exc-c14n, ZATCA Data Dictionary

**الحكم:** 🟡 PARTIAL — الكود موثّق جيداً لكن ينقصه README.

---

## 3. UBL 2.1 XML Generation

### 3.1 أنواع الفواتير المدعومة

| النوع | الكود | الدعم | ملاحظة |
|-------|-------|-------|--------|
| Standard Tax Invoice | 388 | ✅ | B2B |
| Simplified Tax Invoice | 388 + subType 0200000 | ✅ | B2C |
| Credit Note | 381 | ✅ | مع BillingReference |
| Debit Note | 383 | ✅ | مع BillingReference |
| Third-party Invoice | 388 + subType 0110000 | ✅ | Golden snapshot موجود |
| Export Invoice | 388 + subType 0100100 | ✅ | Golden snapshot موجود |
| Self-billed Invoice | 388 + subType 0100010 | ✅ | Golden snapshot موجود |

**الحكم:** ✅ PASSED — كل أنواع الفواتير المطلوبة مدعومة مع 7+ سيناريوهات.

### 3.2 الحقول الإلزامية في XML

#### رأس الفاتورة (Header)

| الحقل | المتطلب | الحالة | المصدر |
|-------|---------|--------|--------|
| `cbc:ProfileID` | `reporting:1.0` | ✅ | `ubl_invoice_builder.dart:23` |
| `cbc:ID` | رقم الفاتورة | ✅ | `ubl_invoice_builder.dart:38` |
| `cbc:UUID` | UUID فريد | ✅ | `ubl_invoice_builder.dart:41` |
| `cbc:IssueDate` | yyyy-MM-dd | ✅ | `ubl_invoice_builder.dart:44` |
| `cbc:IssueTime` | HH:mm:ss | ✅ | `ubl_invoice_builder.dart:47` |
| `cbc:InvoiceTypeCode` + name | 388/381/383 + subType | ✅ | `ubl_invoice_builder.dart:50-56` |
| `cbc:DocumentCurrencyCode` | SAR | ✅ | `ubl_invoice_builder.dart:59` |
| `cbc:TaxCurrencyCode` | SAR | ✅ | `ubl_invoice_builder.dart:62` |

#### معلومات البائع (AccountingSupplierParty)

| الحقل | الحالة | ملاحظة |
|-------|--------|--------|
| `cac:PartyIdentification` (CRN) | ✅ | مع `schemeID="CRN"` |
| `cac:PostalAddress/StreetName` | ✅ | |
| `cac:PostalAddress/BuildingNumber` | ✅ | |
| `cac:PostalAddress/CitySubdivisionName` | ✅ | District |
| `cac:PostalAddress/CityName` | ✅ | |
| `cac:PostalAddress/PostalZone` | ✅ | |
| `cac:PostalAddress/CountrySubentity` | ❌ مفقود | **راجع العيب HIGH-2** |
| `cac:Country/IdentificationCode` | ✅ | |
| `cac:PartyTaxScheme/CompanyID` | ✅ | VAT number |
| `cac:PartyLegalEntity/RegistrationName` | ✅ | |

#### معلومات المشتري (AccountingCustomerParty)

| الحقل | الحالة | ملاحظة |
|-------|--------|--------|
| مطلوب للعادية | ✅ | يُحقَّق في ComplianceChecker |
| اختياري للمبسّطة | ✅ | `buyer` nullable في ZatcaInvoice |

#### المنتجات (InvoiceLine)

| الحقل | الحالة |
|-------|--------|
| `cbc:ID` | ✅ |
| `cbc:InvoicedQuantity` + `unitCode` | ✅ |
| `cbc:LineExtensionAmount` | ✅ |
| `cac:TaxTotal/TaxAmount` | ✅ |
| `cac:TaxTotal/RoundingAmount` | ✅ |
| `cac:Item/Name` | ✅ |
| `cac:Item/ClassifiedTaxCategory` | ✅ |
| `cac:Price/PriceAmount` | ✅ |

#### الإجماليات (LegalMonetaryTotal)

| الحقل | الحالة |
|-------|--------|
| `cbc:LineExtensionAmount` | ✅ |
| `cbc:TaxExclusiveAmount` | ✅ |
| `cbc:TaxInclusiveAmount` | ✅ |
| `cbc:AllowanceTotalAmount` | ✅ |
| `cbc:PayableAmount` | ✅ |

#### الضرائب (TaxTotal)

| الحقل | الحالة | ملاحظة |
|-------|--------|--------|
| TaxTotal #1 (TaxAmount فقط) | ✅ | `tax_total_builder.dart:21-27` |
| TaxTotal #2 (مع TaxSubtotal) | ✅ | `tax_total_builder.dart:30-67` |
| تجميع حسب فئة ضريبية | ✅ | `_groupByVatCategory` |
| ExemptionReason لـ E/Z | ✅ | |

**الحكم:** ✅ PASSED — كل الحقول الإلزامية موجودة (باستثناء CountrySubentity - راجع HIGH-2).

### 3.3 XSD Validation

- **XSD validator مدمج:** ❌ غير موجود
- **Golden tests:** ✅ 7 snapshots XML ثابتة تُقارَن بالمخرجات
- **Structural validation:** ✅ عبر الاختبارات (حقل بحقل)

**الحكم:** 🟡 PARTIAL — لا يوجد XSD validation رسمي. التحقق يتم عبر golden tests و unit tests.

### 3.4 Namespaces

| Namespace | URI | الحالة |
|-----------|-----|--------|
| Default (Invoice) | `urn:oasis:names:specification:ubl:schema:xsd:Invoice-2` | ✅ |
| `cac:` | `urn:oasis:names:specification:ubl:schema:xsd:CommonAggregateComponents-2` | ✅ |
| `cbc:` | `urn:oasis:names:specification:ubl:schema:xsd:CommonBasicComponents-2` | ✅ |
| `ext:` | `urn:oasis:names:specification:ubl:schema:xsd:CommonExtensionComponents-2` | ✅ |
| `sig:` | `urn:oasis:names:specification:ubl:schema:xsd:CommonSignatureComponents-2` | ✅ |
| `sac:` | `urn:oasis:names:specification:ubl:schema:xsd:SignatureAggregateComponents-2` | ✅ |
| `sbc:` | `urn:oasis:names:specification:ubl:schema:xsd:SignatureBasicComponents-2` | ✅ |
| `ds:` | `http://www.w3.org/2000/09/xmldsig#` | ✅ |
| `xades:` | `http://uri.etsi.org/01903/v1.3.2#` | ✅ |

**الحكم:** ✅ PASSED — جميع الـ namespaces صحيحة ومطابقة للمواصفات.

### 3.5 امتدادات ZATCA الخاصة

| الامتداد | الحالة | ملاحظة |
|----------|--------|--------|
| ProfileID = "reporting:1.0" | ✅ | ثابت لكل أنواع الفواتير (صحيح لـ Phase 2) |
| InvoiceTypeCode name attribute | ✅ | 7-digit subType (0100000, 0200000, ...) |
| AdditionalDocumentReference (ICV) | ✅ | `resolvedIcv` — عداد رقمي |
| AdditionalDocumentReference (PIH) | ✅ | مع EmbeddedDocumentBinaryObject |
| AdditionalDocumentReference (QR) | ✅ | مع EmbeddedDocumentBinaryObject |
| cac:Signature placeholder | ✅ | URN صحيح |
| UBLExtensions (signature) | ✅ | placeholder يُستبدَل عند التوقيع |

**الحكم:** ✅ PASSED

---

## 4. XAdES Signing (التوقيع الرقمي)

### 4.1 الخوارزميات

| المتطلب | التنفيذ | الحالة |
|---------|---------|--------|
| Hash: SHA-256 | `crypto: sha256` | ✅ |
| Signature: ECDSA-SHA256 | `pointycastle: SHA-256/DET-ECDSA` | ✅ |
| Curve: secp256k1 | `ECDomainParameters('secp256k1')` | ✅ |
| Canonicalization: C14N 1.1 | `http://www.w3.org/2006/12/xml-c14n11` | ✅ |
| Transform: XPath (exclude UBLExtensions) | `not(//ancestor-or-self::ext:UBLExtensions)` | ✅ |

**الحكم:** ✅ PASSED

### 4.2 التوقيع

| النقطة | الحالة | ملاحظة |
|--------|--------|--------|
| استخدام private key من X.509 | ✅ | `CertificateInfo.privateKeyPem` |
| تخزين المفتاح الخاص | 🟡 | `CertificateStorage` abstract مع تحذير أمني واضح |
| `InMemoryCertificateStorage` محمي | ✅ | `assert(kDebugMode)` يمنع الاستخدام في production |
| `JsonCertificateStorage` تحذير | ✅ | WARNING واضح في التعليقات عن ضرورة التشفير |

**ملاحظة أمنية:** التخزين الآمن يعتمد على implementation خارجية. الحزمة توفر الأساس الصحيح (abstract class + تحذيرات) لكن التشفير الفعلي مسؤولية التطبيق. هذا تصميم سليم.

### 4.3 SignedProperties

| الحقل | الحالة | ملاحظة |
|-------|--------|--------|
| SigningTime | ✅ | `xades_signer.dart:126` |
| SigningCertificate (مع digest) | ✅ | `xades_signer.dart:131-144` |
| CertDigest (SHA-256) | ✅ | `certificateParser.computeCertificateDigest` |
| IssuerSerial | ✅ | `X509IssuerName` + `X509SerialNumber` |
| **SignaturePolicyIdentifier** | **❌ مفقود** | **راجع العيب CRITICAL-1** |

### 4.4 PIH (Previous Invoice Hash)

| النقطة | الحالة | ملاحظة |
|--------|--------|--------|
| الفاتورة الأولى: seed hash | ✅ | `InvoiceHasher.hashString('0')` = Base64(SHA-256("0")) |
| الفواتير اللاحقة: hash من السابقة | ✅ | `InvoiceChainService.computeAndStore` |
| التخزين per-store | ✅ | `ChainStore.saveLastHash(storeId:...)` |
| الاسترجاع | ✅ | `ChainStore.getLastHash(storeId:...)` |
| Reset chain | ✅ | `InvoiceChainService.resetChain` |

**الحكم:** ✅ PASSED

### 4.5 ICV (Invoice Counter Value)

| النقطة | الحالة | ملاحظة |
|--------|--------|--------|
| عداد رقمي متسلسل | ✅ | `invoiceCounterValue: int?` |
| Fallback من رقم الفاتورة | ✅ | `resolvedIcv` يستخرج الأرقام |
| تسلسل عند حذف فاتورة | 🟡 | ICV يعتمد على الـ caller — الحزمة لا تدير التسلسل |

**الحكم:** ✅ PASSED (مع ملاحظة أن إدارة التسلسل مسؤولية الـ app)

### 4.6 SignatureValue

| النقطة | الحالة |
|--------|--------|
| ECDSA signature generation | ✅ |
| DER encoding (SEQUENCE { INTEGER r, INTEGER s }) | ✅ |
| Base64 encoding | ✅ |
| Verify capability | ✅ |
| Deterministic ECDSA (DET-ECDSA) | ✅ |

**الحكم:** ✅ PASSED

---

## 5. TLV QR Code (Phase 2)

### 5.1 الحقول التسعة

| Tag | الحقل | الحالة | المصدر |
|-----|-------|--------|--------|
| 1 | Seller Name (UTF-8) | ✅ | `zatca_tlv_encoder.dart:41` |
| 2 | VAT Registration Number | ✅ | `zatca_tlv_encoder.dart:44` |
| 3 | Invoice Timestamp (ISO 8601) | ✅ | `zatca_tlv_encoder.dart:47` |
| 4 | Invoice Total (with VAT) | ✅ | `zatca_tlv_encoder.dart:50` |
| 5 | VAT Total | ✅ | `zatca_tlv_encoder.dart:53` |
| 6 | XML Hash (SHA-256 raw bytes) | ✅ | `zatca_tlv_encoder.dart:56` |
| 7 | ECDSA Signature (raw bytes) | ✅ | `zatca_tlv_encoder.dart:59` |
| 8 | ECDSA Public Key (raw bytes) | ✅ | `zatca_tlv_encoder.dart:62` |
| 9 | Certificate Signature (B2B فقط) | ✅ | `zatca_tlv_encoder.dart:65` — اختياري للمبسّطة |

**الحكم:** ✅ PASSED — جميع الحقول الـ 9 مُنفَّذة بشكل صحيح.

### 5.2 صياغة TLV

| النقطة | الحالة | ملاحظة |
|--------|--------|--------|
| Tag: 1 byte | ✅ | `_addTlv(data, tag, value)` |
| Length ≤ 127: 1 byte | ✅ | |
| Length 128-255: 0x81 prefix + 1 byte | ✅ | |
| Length 256-65535: 0x82 prefix + 2 bytes BE | ✅ | |
| Final Base64 encoding | ✅ | `base64Encode(Uint8List.fromList(tlvBytes))` |

**الحكم:** ✅ PASSED

### 5.3 ترميز النصوص

- الأسماء العربية: ✅ `utf8.encode(sellerName)` — UTF-8 صحيح
- TLV length يعكس UTF-8 byte count: ✅ `value.length` بعد `utf8.encode`

**الحكم:** ✅ PASSED

### 5.4 اختبار QR

- **Unit test لفك TLV:** ✅ `decodeToStrings()` موجود ومُختبَر
- **Validation method:** ✅ `validateQrData()` يتحقق من Tags 1-8 + VAT format
- **اختبار بتطبيق ZATCA الرسمي:** 🔄 Deferred — يتطلب بيئة ZATCA (سجّلت كـ deferred test)

**الحكم:** ✅ PASSED

---

## 6. إدارة الشهادات والمفاتيح

### 6.1 الشهادة الرقمية

| النقطة | الحالة | ملاحظة |
|--------|--------|--------|
| تخزين X.509 | ✅ | `CertificateInfo.certificatePem` |
| تخزين المفتاح الخاص | ✅ | `CertificateInfo.privateKeyPem` |
| فصل Compliance/Production | ✅ | `CertificateInfo.isProduction` flag |
| Abstract storage | ✅ | `CertificateStorage` — يفرض على المنفِّذ توفير تخزين آمن |
| Debug-only in-memory | ✅ | `assert(kDebugMode)` |
| JSON storage base | ✅ | مع WARNING عن ضرورة التشفير |

### 6.2 طلب CSID

| الخطوة | الحالة | المصدر |
|--------|--------|--------|
| Step 1: Generate CSR + request Compliance CSID | ✅ | `csid_onboarding_service.dart:38-93` |
| Step 2: Submit 6 compliance invoices | ✅ | `csid_onboarding_service.dart:103-220` |
| Step 3: Exchange for Production CSID | ✅ | `csid_onboarding_service.dart:225-251` |
| Full onboarding flow | ✅ | `performFullOnboarding()` |
| CSR fields (ZATCA-specific OIDs) | ✅ | `csr_generator.dart` — كل الـ OIDs صحيحة |

### 6.3 OTP من ZATCA

| النقطة | الحالة | ملاحظة |
|--------|--------|--------|
| OTP parameter في API | ✅ | `requestComplianceCsid(otp:...)` |
| OTP يُمرَّر في HTTP header | ✅ | `headers: {'OTP': otp}` |
| UI لإدخال OTP | 🟡 | مسؤولية الـ app — الحزمة توفر API فقط |

### 6.4 تجديد الشهادات

| النقطة | الحالة | ملاحظة |
|--------|--------|--------|
| مراقبة انتهاء الصلاحية | ✅ | `CertificateRenewalService` مع Timer |
| تنبيه قبل 30 يوم | ✅ | `renewalThresholdDays = 30` |
| تجديد سريع (بدون compliance) | ✅ | `renewCertificate()` |
| تجديد كامل (مع compliance) | ✅ | `renewWithComplianceChecks()` |
| Callbacks (nearExpiry, expired, renewed) | ✅ | |

**الحكم:** ✅ PASSED

---

## 7. الإرسال (Reporting/Clearance)

### 7.1 آلية الإرسال

| النقطة | الحالة | ملاحظة |
|--------|--------|--------|
| فصل Reporting vs Clearance | ✅ | `ReportingApi` و `ClearanceApi` منفصلان |
| اختيار تلقائي حسب نوع الفاتورة | ✅ | `if (invoice.isStandard)` في `ZatcaInvoiceService` |
| Clearance-Status header لـ B2B | ✅ | `extraHeaders: {'Clearance-Status': '1'}` |

### 7.2 Queue للإرسال

| النقطة | الحالة | ملاحظة |
|--------|--------|--------|
| Offline queue مستقل | ✅ | `ZatcaOfflineQueue` |
| Persistence (SharedPreferences fallback) | ✅ | `_prefsKey = 'zatca_offline_queue'` |
| DB persistence hook | ✅ | `onQueueChanged` / `onLoadQueue` callbacks |
| Retry logic | ✅ | Exponential backoff (2^attempt seconds) |
| عدد محاولات الـ retry | ✅ | `maxRetries = 10` |
| لا retry لـ 4xx (validation errors) | ✅ | `if (response.statusCode == 400) break` |
| Dedup بحسب invoiceNumber | ✅ | |

### 7.3 معالجة الاستجابة

| الاستجابة | الحالة | ملاحظة |
|-----------|--------|--------|
| ACCEPTED (200/202) | ✅ | `isSuccess = statusCode == 200 \|\| statusCode == 202` |
| WARNING | ✅ | يُسجَّل في `warnings` ويُسمح بالاستمرار |
| REJECTED (400) | ✅ | يُسجَّل في `errors` + يُنبَّه |
| CLEARED (B2B) | ✅ | `clearedInvoiceXml` يُحفظ |
| Network error | ✅ | يُوجَّه للـ offline queue |

### 7.4 أرشفة

| النقطة | الحالة | ملاحظة |
|--------|--------|--------|
| حفظ XML الموقّع | ✅ | `signedXml` في ZatcaInvoice model |
| حفظ استجابة ZATCA | ✅ | `warnings` + `errors` + `reportingStatus` |
| حفظ 6 سنوات | 🟡 | مسؤولية الـ app/DB — الحزمة توفر البيانات |

**الحكم:** ✅ PASSED

---

## 8. الحالات الخاصة (Edge Cases)

### 8.1 فاتورة إرجاع (Credit Note)

| النقطة | الحالة | ملاحظة |
|--------|--------|--------|
| InvoiceTypeCode = 381 | ✅ | `InvoiceTypeCode.creditNote` |
| BillingReference | ✅ | `cac:BillingReference/cac:InvoiceDocumentReference/cbc:ID` |
| التحقق من وجود reference | ✅ | `_validateBillingReference` في ComplianceChecker |
| Golden snapshot | ✅ | `credit_note.xml` |

### 8.2 فاتورة بعملاء أجانب

| النقطة | الحالة | ملاحظة |
|--------|--------|--------|
| VAT number اختياري | ✅ | `ZatcaBuyer.vatNumber` nullable |
| عناوين أجنبية | ✅ | `countryCode` قابل للتغيير |

### 8.3 فاتورة بدون عميل (Walk-in)

| النقطة | الحالة | ملاحظة |
|--------|--------|--------|
| بدون buyer info | ✅ | `buyer` nullable في ZatcaInvoice |
| مبسّطة تلقائياً | ✅ | ComplianceChecker يفرض buyer لـ B2B |

### 8.4 فواتير بإجمالي صفر

| النقطة | الحالة | ملاحظة |
|--------|--------|--------|
| مسموحة | ✅ | `totalWithVat >= 0` في ComplianceChecker |

### 8.5 فواتير بأكثر من ضريبة

| النقطة | الحالة | ملاحظة |
|--------|--------|--------|
| Multi-tax categories | ✅ | `_groupByVatCategory` يجمّع بحسب `vatCategoryCode_vatRate` |
| فئات مدعومة | ✅ | S (Standard), Z (Zero), E (Exempt), O (Out of Scope) |
| ExemptionReason لـ E/Z | ✅ | مطلوب في ComplianceChecker |

**الحكم:** ✅ PASSED

---

## 9. الاختبارات

### 9.1 نتائج التشغيل

```
flutter test packages/alhai_zatca/
00:43 +820 ~1: All tests passed!
```

| المؤشر | القيمة |
|--------|--------|
| **إجمالي الاختبارات** | 820 |
| **ناجحة** | 820 |
| **فاشلة** | 0 |
| **تخطّي** | 1 (sandbox integration — يتطلب اتصال) |
| **وقت التنفيذ** | ~43 ثانية |

### 9.2 تغطية الكود

```
flutter test --coverage packages/alhai_zatca/
TOTAL: 2143/2338 (91.7%)
```

| الملف | التغطية | ملاحظة |
|-------|---------|--------|
| `ecdsa_signer.dart` | عالية | |
| `xml_canonicalizer.dart` | عالية | |
| `ubl_invoice_builder.dart` | عالية | |
| `zatca_compliance_checker.dart` | عالية | |
| `certificate_parser.dart` | عالية | |
| `zatca_offline_queue.dart` | عالية | |
| `csr_generator.dart` | عالية | |
| `zatca_invoice_service.dart` | متوسطة | |

**91.7% تغطية شاملة** — أعلى بكثير من الحد الأدنى المطلوب (70%).

### 9.3 أنواع الاختبارات

| النوع | العدد التقريبي | ملاحظة |
|-------|---------------|--------|
| Unit tests | ~750 | كل مكون |
| Snapshot/Golden tests | ~50 | 7 XML snapshots |
| Integration tests | ~20 | Sandbox (skipped بدون اتصال) |

### 9.4 Golden Tests (XML Snapshots)

| الملف | النوع | الحالة |
|-------|-------|--------|
| `standard_b2b_full.xml` | B2B كامل مع خصومات | ✅ |
| `standard_b2b_minimal.xml` | B2B بسيط | ✅ |
| `simplified_b2c_minimal.xml` | B2C بسيط | ✅ |
| `credit_note.xml` | إشعار دائن | ✅ |
| `standard_export.xml` | فاتورة تصدير | ✅ |
| `standard_third_party.xml` | فاتورة طرف ثالث | ✅ |
| `standard_self_billed.xml` | فاتورة ذاتية | ✅ |

**الحكم:** ✅ PASSED — تغطية ممتازة بـ 820 اختبار و 91.7% coverage.

---

## 10. الجاهزية للتسجيل (Pre-Registration Readiness)

### 10.1 Sandbox ready

| النقطة | الحالة | ملاحظة |
|--------|--------|--------|
| Sandbox URL منفصل | ✅ | `ZatcaEndpoints.sandboxBase` |
| Simulation URL | ✅ | `ZatcaEndpoints.simulationBase` |
| Production URL | ✅ | `ZatcaEndpoints.productionBase` |
| Sandbox URL صحيح | ✅ | `https://gw-fatoora.zatca.gov.sa/e-invoicing/developer-portal` |
| Production URL صحيح | ✅ | `https://gw-fatoora.zatca.gov.sa/e-invoicing/core` |
| `ZatcaEnvironment` enum | ✅ | `sandbox`, `simulation`, `production` |
| `isSandbox` helper | ✅ | |

### 10.2 Compliance Test Scenarios

ZATCA يطلب 6+ سيناريوهات. الكود يدعم:

| السيناريو | الحالة | ملاحظة |
|-----------|--------|--------|
| فاتورة مبسّطة عادية | ✅ | 388 + 0200000 |
| فاتورة عادية (Standard) | ✅ | 388 + 0100000 |
| Credit Note عادية | ✅ | 381 + 0100000 |
| Credit Note مبسّطة | ✅ | 381 + 0200000 |
| Debit Note عادية | ✅ | 383 + 0100000 |
| Debit Note مبسّطة | ✅ | 383 + 0200000 |
| فاتورة بخصومات | ✅ | AllowanceCharge مدعوم |
| فاتورة بفئات ضريبية متعددة | ✅ | Multi-tax grouping |

**`CsidOnboardingService.runComplianceChecks`** يُنشئ الـ 6 سيناريوهات تلقائياً.

### 10.3 المتطلبات الفنية للتسجيل

| المتطلب | الحالة | ملاحظة |
|---------|--------|--------|
| شهادة Compliance CSID | ✅ | `requestComplianceCsid()` |
| رقم سجل تجاري (CRN) | ✅ | `ZatcaSeller.crNumber` |
| رقم VAT | ✅ | `ZatcaSeller.vatNumber` |
| عنوان كامل | ✅ | `ZatcaSeller` — كل الحقول موجودة |
| CSR مع OIDs صحيحة | ✅ | `CsrGenerator` — كل الـ OIDs مطابقة |
| config placeholders | ✅ | `CsrConfig` class |

### ما هو موجود ومستعد:

1. ✅ بناء XML كامل مع كل الحقول الإلزامية
2. ✅ توقيع XAdES-BES مع ECDSA-SHA256
3. ✅ QR code مع 9 حقول TLV
4. ✅ سلسلة الفواتير (PIH/ICV)
5. ✅ 3 أنواع فواتير + 6 أنواع فرعية
6. ✅ API client مع sandbox/simulation/production
7. ✅ عملية التسجيل الكاملة (3 خطوات)
8. ✅ Offline queue مع retry
9. ✅ Certificate renewal monitoring
10. ✅ Pre-submission compliance validation
11. ✅ 820 اختبار (91.7% تغطية)

### ما هو ناقص ويجب إكماله:

1. **❌ CRITICAL:** إضافة `SignaturePolicyIdentifier` في XAdES SignedProperties
2. **🔴 HIGH:** إضافة XSD validation أو على الأقل validation against ZATCA SDK samples
3. **🔴 HIGH:** إضافة `CountrySubentity` في PostalAddress
4. **🟡 MEDIUM:** إضافة README.md للحزمة
5. **🟡 MEDIUM:** إضافة `ProfileID` ديناميكي إذا طلبت ZATCA `tax-invoice:1.0` للـ clearance (تحقق عند التسجيل)
6. **🟡 MEDIUM:** اختبار فعلي على ZATCA sandbox بعد الحصول على OTP

### خطوات التسجيل التالية الموصى بها:

1. إصلاح العيوب الحرجة والعالية (CRITICAL-1, HIGH-1, HIGH-2)
2. إنشاء حساب في بوابة Fatoora (https://fatoora.zatca.gov.sa)
3. تسجيل الجهاز والحصول على OTP
4. تشغيل `performFullOnboarding()` على بيئة sandbox
5. التحقق من نجاح الـ 6 compliance invoices
6. التبديل لبيئة simulation ثم production

---

## 11. العيوب الحرجة

### CRITICAL-1: غياب SignaturePolicyIdentifier في XAdES

| | |
|---|---|
| **الخطورة** | ❌ CRITICAL |
| **الملف** | `lib/src/signing/xades_signer.dart:120-145` |
| **الوصف** | `SignedProperties` لا تحتوي `SignaturePolicyIdentifier`. ZATCA SDK يتطلب هذا الحقل مع URN محدد: `urn:oasis:names:specification:ubl:signature:1`. بدونه، قد يُرفض التوقيع عند الإرسال. |
| **الإصلاح** | إضافة `<xades:SignaturePolicyIdentifier>` بعد `<xades:SigningCertificate>` مع `<xades:SignaturePolicyId>` و `<xades:SigPolicyHash>` (SHA-256 hash of the policy document). |
| **المرجع** | ZATCA E-Invoice XML Implementation Standard, Section 3.3 |

### HIGH-1: عدم وجود XSD Validation مدمج

| | |
|---|---|
| **الخطورة** | 🔴 HIGH |
| **الوصف** | لا يوجد XSD validator يتحقق من XML المُولَّد مقابل UBL 2.1 XSD الرسمي. الاعتماد فقط على golden tests قد لا يكشف أخطاء في حالات غير مغطاة. |
| **الإصلاح** | إما: (أ) إضافة XSD validation عبر external tool/service، أو (ب) زيادة golden snapshots لتغطية كل الحالات الحدية، أو (ج) التحقق يدوياً من ZATCA SDK reference XMLs. |
| **التأثير** | قد يُكتشف خطأ XML فقط عند الإرسال لـ ZATCA. |

### HIGH-2: غياب CountrySubentity في عنوان البائع

| | |
|---|---|
| **الخطورة** | 🔴 HIGH |
| **الملف** | `lib/src/xml/ubl_invoice_builder.dart:222-241` |
| **الوصف** | PostalAddress لا يحتوي `cbc:CountrySubentity` (المنطقة/المحافظة). بعض تطبيقات ZATCA تتطلب هذا الحقل. الكود يستخدم `CitySubdivisionName` (الحي) لكن CountrySubentity (المنطقة مثل "الرياض" أو "مكة المكرمة") مفقود. |
| **الإصلاح** | إضافة حقل `region` أو `countrySubentity` في `ZatcaSeller` وإدراجه في PostalAddress. |

### MEDIUM-1: عدم وجود README.md

| | |
|---|---|
| **الخطورة** | 🟡 MEDIUM |
| **الوصف** | الحزمة بدون README. هذا يصعّب عملية الصيانة والتسليم. |

### MEDIUM-2: ProfileID ثابت

| | |
|---|---|
| **الخطورة** | 🟡 MEDIUM |
| **الملف** | `lib/src/xml/ubl_invoice_builder.dart:23` |
| **الوصف** | `ProfileID` ثابت كـ `"reporting:1.0"` لكل أنواع الفواتير. في ZATCA Phase 2، هذا صحيح حالياً، لكن يُنصح بجعله configurable تحسّباً لتغيير مستقبلي. |

### MEDIUM-3: Timestamp بدون timezone offset

| | |
|---|---|
| **الخطورة** | 🟡 MEDIUM |
| **الملف** | `lib/src/qr/zatca_tlv_encoder.dart:47` |
| **الوصف** | Tag 3 في QR يستخدم `timestamp.toIso8601String()`. إذا كان الـ DateTime بدون timezone info، قد لا يُولِّد التنسيق الصحيح. ZATCA يتوقع `2026-04-01T14:30:00+03:00` (بتوقيت السعودية). يجب التأكد أن الـ DateTime دائماً يحمل timezone. |

---

## 12. التوصية النهائية

### 🟡 الكود قريب من الجاهزية — أصلح العيوب التالية أولاً:

| # | العيب | الجهد المتوقع | الأولوية |
|---|-------|-------------|---------|
| 1 | إضافة `SignaturePolicyIdentifier` في XAdES | ساعة واحدة | فوري |
| 2 | إضافة `CountrySubentity` في PostalAddress | 30 دقيقة | فوري |
| 3 | التحقق من XML مقابل ZATCA SDK samples | ساعتان | قبل التسجيل |

**بعد إصلاح هذه العيوب الثلاثة:**
- ابدأ بالتسجيل في ZATCA sandbox
- شغّل `performFullOnboarding()` لاختبار العملية الكاملة
- تأكد من نجاح الـ 6 compliance invoices على sandbox
- انتقل للـ simulation ثم production

### ملخص الأقسام:

| القسم | النتيجة |
|-------|---------|
| 1. جرد الحزمة | ✅ PASSED |
| 2. UBL 2.1 XML | ✅ PASSED (مع HIGH-2) |
| 3. XAdES Signing | 🟡 PARTIAL (CRITICAL-1) |
| 4. TLV QR Code | ✅ PASSED |
| 5. إدارة الشهادات | ✅ PASSED |
| 6. الإرسال | ✅ PASSED |
| 7. الحالات الخاصة | ✅ PASSED |
| 8. الاختبارات | ✅ PASSED (820 tests, 91.7%) |
| 9. الجاهزية للتسجيل | 🟡 PARTIAL (3 عيوب) |

---

*تم إنشاء هذا التقرير آلياً بواسطة Claude Opus 4.6 بتاريخ 2026-04-14*
*Co-Audited-By: Claude Opus 4.6 <noreply@anthropic.com>*
