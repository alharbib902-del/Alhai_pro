import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

import 'package:alhai_database/alhai_database.dart';
import 'package:alhai_sync/alhai_sync.dart';
import 'package:alhai_zatca/alhai_zatca.dart' as zatca;

import 'receipt_pdf_generator.dart';
import 'zatca_invoice_mapper.dart';
import 'zatca_service.dart';

/// يُرفع عندما يستحيل توليد رمز ZATCA QR المطلوب لفاتورة ضريبية
/// مبسطة. الفاتورة بدون QR غير متوافقة مع هيئة الزكاة والضريبة
/// ولا تصلح للإصدار، فنُوقف إنشاءها عوضاً عن حفظ فاتورة معطوبة.
class ZatcaComplianceException implements Exception {
  final String message;
  final Object? cause;
  const ZatcaComplianceException(this.message, {this.cause});

  @override
  String toString() =>
      'ZatcaComplianceException: $message${cause != null ? ' (cause: $cause)' : ''}';
}

/// أنواع الفواتير المدعومة
enum InvoiceType {
  /// فاتورة ضريبية مبسطة (B2C - نقطة البيع)
  simplifiedTax('simplified_tax', 'INV'),

  /// فاتورة ضريبية (B2B - بين الشركات)
  standardTax('standard_tax', 'TAX'),

  /// إشعار دائن (مرتجع/تعديل بالنقص)
  creditNote('credit_note', 'CN'),

  /// إشعار مدين (تعديل بالزيادة)
  debitNote('debit_note', 'DN');

  final String value;
  final String prefix;

  const InvoiceType(this.value, this.prefix);
}

/// خدمة الفواتير المتكاملة
///
/// تدعم:
/// - إنشاء فواتير تلقائية عند البيع
/// - ترقيم تسلسلي حسب النوع والسنة
/// - إشعارات دائن/مدين
/// - أرشفة PDF في Supabase Storage
/// - تقارير وإحصائيات
///
/// ### Sync payload format
///
/// Drift stores invoice money columns as int cents (post b0f04fa1 on
/// 2026-04-22). The Supabase `invoices` table is still DOUBLE PRECISION
/// (v15 schema — the int-cents counterpart migration is deferred to a
/// dedicated Supabase-side session). So every [_syncService.enqueueCreate]
/// payload here divides cents by 100 before emitting. Matches the
/// sale_service / sale_items push contract.
class InvoiceService {
  final AppDatabase _db;
  final SyncService? _syncService;
  final ImageUploadService? _uploadService;

  /// Optional clock offset callback. When provided, returns the measured
  /// difference (device - server). Used to generate ZATCA-compliant timestamps.
  /// If null or returns Duration.zero, `DateTime.now()` is used as-is.
  final Duration Function()? _clockOffsetProvider;

  /// Wave 3b-2b: optional ZATCA Phase-2 service. When wired AND
  /// [_isZatcaPhase2EnabledFor] returns true for the sale's store,
  /// every newly-created invoice is also signed and submitted to the
  /// ZATCA portal. When null OR the per-store flag is off, the legacy
  /// Phase-1-only flow runs unchanged (TLV QR, no UBL XML, no signing).
  /// `processInvoice` itself never throws — failures land in the
  /// returned invoice's `errors` list and we persist them so the cashier
  /// can retry from the queue UI without losing the receipt.
  final zatca.ZatcaInvoiceService? _zatcaInvoiceService;

  /// Per-store Phase-2 toggle. Returns `true` when the store has
  /// completed onboarding (cert installed) AND the admin flipped the
  /// switch ON. Defaults to "always off" — keeps stores that haven't
  /// onboarded on the legacy path until they explicitly opt in.
  final Future<bool> Function(String storeId)? _isZatcaPhase2EnabledFor;

  static const _uuid = Uuid();

  InvoiceService({
    required AppDatabase db,
    SyncService? syncService,
    ImageUploadService? uploadService,
    Duration Function()? clockOffsetProvider,
    zatca.ZatcaInvoiceService? zatcaInvoiceService,
    Future<bool> Function(String storeId)? isZatcaPhase2EnabledFor,
  }) : _db = db,
       _syncService = syncService,
       _uploadService = uploadService,
       _clockOffsetProvider = clockOffsetProvider,
       _zatcaInvoiceService = zatcaInvoiceService,
       _isZatcaPhase2EnabledFor = isZatcaPhase2EnabledFor;

  /// Get a corrected timestamp that accounts for device clock drift.
  /// ZATCA requires accurate timestamps; this uses the server-measured offset.
  DateTime _correctedNow() {
    final offset = _clockOffsetProvider?.call() ?? Duration.zero;
    return DateTime.now().subtract(offset);
  }

  /// إنشاء فاتورة تلقائية عند عملية بيع
  ///
  /// يُستدعى بعد إتمام البيع لإنشاء الفاتورة الرسمية.
  /// يعيد المحاولة حتى 3 مرات عند تعارض رقم الفاتورة (unique constraint).
  Future<InvoicesTableData?> createFromSale({
    required SalesTableData sale,
    required List<SaleItemsTableData> items,
    InvoiceType type = InvoiceType.simplifiedTax,
    StoreInfo store = StoreInfo.defaultStore,
    String? cashierName,
    String? customerVatNumber,
    String? customerAddress,
    DateTime? dueAt,
  }) async {
    const maxRetries = 3;
    for (int attempt = 0; attempt < maxRetries; attempt++) {
      try {
        final id = _uuid.v4();
        final now = _correctedNow();
        final invoiceNumber = await _generateInvoiceNumber(
          storeId: sale.storeId,
          type: type,
        );

        // ZATCA Phase-1 compliance (C-4 §4h — P0 blocker):
        // توليد QR قبل حفظ الفاتورة. إن فشل التوليد (اسم بائع طويل جداً،
        // VAT مفقود، أي TlvLengthOverflow) نرفع استثناءً ونُلغي العملية —
        // إصدار فاتورة ضريبية مبسطة بدون QR ZATCA مخالفة قانونية في
        // السعودية ولا نقبل تمريرها بصمت كما كان يفعل المسار السابق.
        final String zatcaQrBase64;
        try {
          zatcaQrBase64 = ZatcaService.generateQrData(
            sellerName: store.name,
            vatNumber: store.vatNumber,
            timestamp: now,
            totalWithVat: sale.total / 100.0,
            vatAmount: sale.tax / 100.0,
          );
        } catch (e, st) {
          if (kDebugMode) {
            debugPrint(
              '[InvoiceService] ❌ ZATCA QR generation FAILED — aborting '
              'invoice. saleId=${sale.id}, storeName="${store.name}", '
              'vatNumber="${store.vatNumber}", error=$e\n$st',
            );
          }
          throw ZatcaComplianceException(
            'Failed to generate ZATCA QR for sale ${sale.id}. '
            'Invoice creation aborted — a simplified tax invoice without a '
            'compliant QR code is not legally valid in Saudi Arabia.',
            cause: e,
          );
        }

        final companion = InvoicesTableCompanion.insert(
          id: id,
          orgId: Value(sale.orgId),
          storeId: sale.storeId,
          invoiceNumber: invoiceNumber,
          invoiceType: Value(type.value),
          status: Value(sale.isPaid ? 'paid' : 'issued'),
          saleId: Value(sale.id),
          customerId: Value(sale.customerId),
          customerName: Value(sale.customerName),
          customerPhone: Value(sale.customerPhone),
          customerVatNumber: Value(customerVatNumber),
          customerAddress: Value(customerAddress),
          // C-4 Session 2: sale.* are already int cents (after the C-4 Session 3
          // sales migration). Pass straight through — the previous `* 100` was a
          // 100× overflow that corrupted every invoice created from a POS sale
          // and broke ZATCA compliance on stored totals.
          subtotal: Value(sale.subtotal),
          discount: Value(sale.discount),
          taxAmount: Value(sale.tax),
          total: Value(sale.total),
          paymentMethod: Value(sale.paymentMethod),
          amountPaid: Value(
            sale.isPaid ? sale.total : (sale.amountReceived ?? 0),
          ),
          amountDue: Value(
            sale.isPaid ? 0 : (sale.total - (sale.amountReceived ?? 0)),
          ),
          createdBy: Value(sale.cashierId),
          cashierName: Value(cashierName),
          issuedAt: Value(now),
          dueAt: Value(dueAt),
          paidAt: sale.isPaid ? Value(now) : const Value.absent(),
          createdAt: now,
          // ZATCA Phase-1 QR: محفوظ مع الفاتورة لضمان ثباته عبر إعادة
          // الطباعة والاستعلامات (بدل إعادة توليده عند كل عرض/طباعة).
          zatcaQr: Value(zatcaQrBase64),
          zatcaUuid: Value(id),
        );

        await _db.invoicesDao.upsertInvoice(companion);

        // C-4 Session 2 follow-up — Bug B fix: push newly-created invoice
        // to the sync queue so it lands on Supabase. Before this, local
        // invoices were never enqueued → every POS-generated invoice stayed
        // local only → ZATCA compliance gap server-side.
        // Non-blocking: same pattern as sale_service — invoice is saved
        // locally regardless of sync enqueue outcome.
        if (_syncService != null) {
          try {
            await _syncService.enqueueCreate(
              tableName: 'invoices',
              recordId: id,
              data: {
                'id': id,
                'orgId': sale.orgId,
                'storeId': sale.storeId,
                'invoiceNumber': invoiceNumber,
                'invoiceType': type.value,
                'status': sale.isPaid ? 'paid' : 'issued',
                'saleId': sale.id,
                'customerId': sale.customerId,
                'customerName': sale.customerName,
                'customerPhone': sale.customerPhone,
                'customerVatNumber': customerVatNumber,
                'customerAddress': customerAddress,
                // C-4 §4h (Session 53): Supabase invoice money columns are
                // INTEGER (cents) — audit confirmed 2026-04-25. Drift values
                // are already cents, so pass them through untouched. The
                // earlier `/100.0` conversion from Session 45 was based on
                // a stale handover claim that the server was still DOUBLE.
                'subtotal': sale.subtotal,
                'discount': sale.discount,
                // Sprint 1 / P0-03: the tax rate is no longer hardcoded at
                // 15%. POS screens now read from TaxSettings and compute
                // sale.tax accordingly (0 for disabled/zero-rated, 14/15/
                // other for configured rates). Infer the rate back out of
                // sale.tax ÷ sale.subtotal so the Supabase row matches
                // what was actually charged. Both columns are int cents.
                'taxRate': sale.subtotal > 0
                    ? double.parse(
                        (sale.tax / sale.subtotal * 100).toStringAsFixed(2),
                      )
                    : 0.0,
                'taxAmount': sale.tax,
                'total': sale.total,
                'paymentMethod': sale.paymentMethod,
                'amountPaid': sale.isPaid
                    ? sale.total
                    : (sale.amountReceived ?? 0),
                'amountDue': sale.isPaid
                    ? 0
                    : (sale.total - (sale.amountReceived ?? 0)),
                'currency': 'SAR',
                'createdBy': sale.cashierId,
                'cashierName': cashierName,
                'issuedAt': now.toIso8601String(),
                'paidAt': sale.isPaid ? now.toIso8601String() : null,
                'createdAt': now.toIso8601String(),
                // ZATCA Phase-1: QR و UUID ضمن نفس payload حتى لا تصل
                // الفاتورة لـ Supabase بدون رمزها — يضمن الاتساق بين
                // السجل المحلي والسحابي للمراجعة والتدقيق.
                'zatcaQr': zatcaQrBase64,
                'zatcaUuid': id,
              },
              priority: SyncPriority.high,
            );
          } catch (e) {
            if (kDebugMode) {
              debugPrint(
                '[InvoiceService] sync enqueue failed (non-blocking, invoice saved locally): $e',
              );
            }
          }
        }

        // Wave 3b-2b: ZATCA Phase-2 sign + submit (per-store opt-in).
        // Runs after the local insert so we always have a row to update,
        // and before the PDF so the receipt can carry the Phase-2 QR
        // when signing succeeds. Failure is non-blocking — the cashier
        // still gets a Phase-1-only receipt and the queue retry UI can
        // pick up failed invoices later.
        await _maybeProcessZatcaPhase2(
          invoiceId: id,
          sale: sale,
          items: items,
          invoiceNumber: invoiceNumber,
          invoiceType: type,
          customerVatNumber: customerVatNumber,
          customerName: sale.customerName,
          customerAddress: customerAddress,
          issuedAt: now,
        );

        // توليد وأرشفة PDF
        await _generateAndArchivePdf(
          invoiceId: id,
          sale: sale,
          items: items,
          store: store,
          cashierName: cashierName ?? 'كاشير',
          invoiceNumber: invoiceNumber,
          invoiceType: type,
        );

        return _db.invoicesDao.getById(id);
      } on ZatcaComplianceException {
        // ZATCA compliance failure is NOT retryable — same inputs will
        // produce the same encoding error. Bubble up so the caller (POS
        // flow) can block the sale instead of proceeding with an invalid
        // invoice. Do NOT fall through to the unique-constraint retry path.
        rethrow;
      } catch (e) {
        // Check if this is a unique constraint violation on invoice number (race condition).
        final errorStr = e.toString().toLowerCase();
        final isUniqueViolation =
            errorStr.contains('unique constraint failed') ||
            errorStr.contains('unique constraint') ||
            errorStr.contains('unique');
        if (isUniqueViolation && attempt < maxRetries - 1) {
          if (kDebugMode) {
            debugPrint(
              'InvoiceService: Invoice number collision (attempt ${attempt + 1}/$maxRetries), retrying...',
            );
          }
          await Future.delayed(Duration(milliseconds: 50 * (attempt + 1)));
          continue;
        }
        // Not a collision or exhausted retries — log and return null (don't crash the sale)
        if (kDebugMode) {
          debugPrint('InvoiceService: createFromSale failed: $e');
        }
        return null;
      }
    }
    // Should not reach here, but return null as safety net
    return null;
  }

  /// إنشاء إشعار دائن (مرتجع)
  Future<InvoicesTableData?> createCreditNote({
    required String storeId,
    required String refInvoiceId,
    required String reason,
    required double amount,
    required double taxAmount,
    String? orgId,
    String? customerId,
    String? customerName,
    String? createdBy,
  }) async {
    try {
      final id = _uuid.v4();
      final now = _correctedNow();
      final invoiceNumber = await _generateInvoiceNumber(
        storeId: storeId,
        type: InvoiceType.creditNote,
      );

      final companion = InvoicesTableCompanion.insert(
        id: id,
        orgId: Value(orgId),
        storeId: storeId,
        invoiceNumber: invoiceNumber,
        invoiceType: const Value('credit_note'),
        status: const Value('issued'),
        refInvoiceId: Value(refInvoiceId),
        refReason: Value(reason),
        customerId: Value(customerId),
        customerName: Value(customerName),
        subtotal: Value((amount * 100).round()),
        taxAmount: Value((taxAmount * 100).round()),
        total: Value(((amount + taxAmount) * 100).round()),
        amountPaid: Value(((amount + taxAmount) * 100).round()),
        createdBy: Value(createdBy),
        issuedAt: Value(now),
        createdAt: now,
      );

      await _db.invoicesDao.upsertInvoice(companion);

      // C-4 §4h (Session 53): Supabase invoice money columns are INTEGER
      // cents — pass cents, not SAR doubles. Caller still passes SAR
      // doubles, so convert at the wire boundary.
      if (_syncService != null) {
        try {
          final subtotalCents = (amount * 100).round();
          final taxCents = (taxAmount * 100).round();
          final totalCents = subtotalCents + taxCents;
          await _syncService.enqueueCreate(
            tableName: 'invoices',
            recordId: id,
            data: {
              'id': id,
              'orgId': orgId,
              'storeId': storeId,
              'invoiceNumber': invoiceNumber,
              'invoiceType': 'credit_note',
              'status': 'issued',
              'refInvoiceId': refInvoiceId,
              'refReason': reason,
              'customerId': customerId,
              'customerName': customerName,
              'subtotal': subtotalCents,
              'taxRate': 15.0,
              'taxAmount': taxCents,
              'total': totalCents,
              'amountPaid': totalCents,
              'currency': 'SAR',
              'createdBy': createdBy,
              'issuedAt': now.toIso8601String(),
              'createdAt': now.toIso8601String(),
            },
            priority: SyncPriority.high,
          );
        } catch (e) {
          if (kDebugMode) {
            debugPrint(
              '[InvoiceService] credit-note sync enqueue failed (non-blocking): $e',
            );
          }
        }
      }

      // Wave 3b-2b: ZATCA Phase-2 for credit notes. Same gating + non-
      // blocking semantics as createFromSale — when the store has
      // Phase-2 enabled, the credit note is signed and submitted with
      // type code 381 + a billingReferenceId pointing at the original.
      await _maybeProcessZatcaPhase2CreditNote(
        invoiceId: id,
        storeId: storeId,
        invoiceNumber: invoiceNumber,
        refInvoiceId: refInvoiceId,
        reason: reason,
        amount: amount,
        taxAmount: taxAmount,
        customerName: customerName,
        issuedAt: now,
      );

      return _db.invoicesDao.getById(id);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('InvoiceService: createCreditNote failed: $e');
      }
      return null;
    }
  }

  /// إنشاء إشعار مدين (تعديل بالزيادة)
  Future<InvoicesTableData?> createDebitNote({
    required String storeId,
    required String refInvoiceId,
    required String reason,
    required double amount,
    required double taxAmount,
    String? orgId,
    String? customerId,
    String? customerName,
    String? createdBy,
  }) async {
    try {
      final id = _uuid.v4();
      final now = _correctedNow();
      final invoiceNumber = await _generateInvoiceNumber(
        storeId: storeId,
        type: InvoiceType.debitNote,
      );

      final companion = InvoicesTableCompanion.insert(
        id: id,
        orgId: Value(orgId),
        storeId: storeId,
        invoiceNumber: invoiceNumber,
        invoiceType: const Value('debit_note'),
        status: const Value('issued'),
        refInvoiceId: Value(refInvoiceId),
        refReason: Value(reason),
        customerId: Value(customerId),
        customerName: Value(customerName),
        subtotal: Value((amount * 100).round()),
        taxAmount: Value((taxAmount * 100).round()),
        total: Value(((amount + taxAmount) * 100).round()),
        amountDue: Value(((amount + taxAmount) * 100).round()),
        createdBy: Value(createdBy),
        issuedAt: Value(now),
        createdAt: now,
      );

      await _db.invoicesDao.upsertInvoice(companion);

      // C-4 §4h (Session 53): Supabase invoice money columns are INTEGER
      // cents — pass cents, not SAR doubles.
      if (_syncService != null) {
        try {
          final subtotalCents = (amount * 100).round();
          final taxCents = (taxAmount * 100).round();
          final totalCents = subtotalCents + taxCents;
          await _syncService.enqueueCreate(
            tableName: 'invoices',
            recordId: id,
            data: {
              'id': id,
              'orgId': orgId,
              'storeId': storeId,
              'invoiceNumber': invoiceNumber,
              'invoiceType': 'debit_note',
              'status': 'issued',
              'refInvoiceId': refInvoiceId,
              'refReason': reason,
              'customerId': customerId,
              'customerName': customerName,
              'subtotal': subtotalCents,
              'taxRate': 15.0,
              'taxAmount': taxCents,
              'total': totalCents,
              'amountDue': totalCents,
              'currency': 'SAR',
              'createdBy': createdBy,
              'issuedAt': now.toIso8601String(),
              'createdAt': now.toIso8601String(),
            },
            priority: SyncPriority.high,
          );
        } catch (e) {
          if (kDebugMode) {
            debugPrint(
              '[InvoiceService] debit-note sync enqueue failed (non-blocking): $e',
            );
          }
        }
      }

      return _db.invoicesDao.getById(id);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('InvoiceService: createDebitNote failed: $e');
      }
      return null;
    }
  }

  // ═══════════ الترقيم ═══════════

  /// توليد رقم فاتورة تسلسلي
  ///
  /// الصيغة: {PREFIX}-{YEAR}-{SEQUENCE:5}
  /// مثال: INV-2026-00001, CN-2026-00002
  Future<String> _generateInvoiceNumber({
    required String storeId,
    required InvoiceType type,
  }) async {
    final year = _correctedNow().year;
    final lastSeq = await _db.invoicesDao.getLastSequence(
      storeId,
      type.prefix,
      year,
    );
    final nextSeq = (lastSeq + 1).toString().padLeft(5, '0');
    return '${type.prefix}-$year-$nextSeq';
  }

  // ═══════════ PDF ═══════════

  /// توليد وأرشفة PDF للفاتورة
  Future<void> _generateAndArchivePdf({
    required String invoiceId,
    required SalesTableData sale,
    required List<SaleItemsTableData> items,
    required StoreInfo store,
    required String cashierName,
    required String invoiceNumber,
    required InvoiceType invoiceType,
  }) async {
    try {
      // Wave 3b-2b: re-fetch the row so we pick up the Phase-2 QR if
      // `_maybeProcessZatcaPhase2` ran ahead of this and overwrote it.
      // Falls through to the Phase-1 TLV inside the generator when null.
      final latest = await _db.invoicesDao.getById(invoiceId);
      final qrOverride = latest?.zatcaQr;

      // توليد PDF
      final pdfBytes = await ReceiptPdfGenerator.generate(
        sale: sale,
        items: items,
        store: store,
        cashierName: cashierName,
        qrOverride: qrOverride,
      );

      // أرشفة في Supabase Storage (إذا متاح)
      if (_uploadService != null) {
        final pdfUrl = await _uploadService.archiveInvoicePdf(
          storeId: sale.storeId,
          invoiceNumber: invoiceNumber,
          pdfBytes: pdfBytes,
        );

        if (pdfUrl != null) {
          await _db.invoicesDao.updatePdfUrl(invoiceId, pdfUrl);
        }
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('InvoiceService: PDF generation/archive failed: $e');
      }
    }
  }

  // ═══════════ ZATCA Phase-2 ═══════════

  /// Run the ZATCA Phase-2 pipeline for a freshly-created invoice.
  ///
  /// Returns silently on any of:
  ///   - service or flag callback not wired (legacy app)
  ///   - flag returns false for this store (per-store opt-out)
  ///   - the store row is missing structured-address columns
  ///   - the ZATCA service returns an error/queued status
  ///
  /// In all of those cases the local Phase-1 row remains the source of
  /// truth — the only effect is that `signed_xml` / `reporting_status`
  /// stay null and the queue UI can pick the failed/queued ones up
  /// later. This protects the cashier flow from being blocked by
  /// network or signing problems.
  Future<void> _maybeProcessZatcaPhase2({
    required String invoiceId,
    required SalesTableData sale,
    required List<SaleItemsTableData> items,
    required String invoiceNumber,
    required InvoiceType invoiceType,
    required String? customerVatNumber,
    required String? customerName,
    required String? customerAddress,
    required DateTime issuedAt,
  }) async {
    final svc = _zatcaInvoiceService;
    final flag = _isZatcaPhase2EnabledFor;
    if (svc == null || flag == null) return;

    try {
      if (!await flag(sale.storeId)) return;

      final storeRow = await _db.storesDao.getStoreById(sale.storeId);
      if (storeRow == null) return;

      final icv = await _db.invoiceCounterDao.nextIcv(
        storeId: sale.storeId,
        invoiceType: invoiceType.value,
      );

      final zatcaInvoice = ZatcaInvoiceMapper.fromSale(
        sale: sale,
        items: items,
        store: storeRow,
        invoiceNumber: invoiceNumber,
        invoiceCounterValue: icv,
        type: invoiceType,
        issuedAt: issuedAt,
        customerVatNumber: customerVatNumber,
        customerName: customerName,
        customerAddress: customerAddress,
      );

      final processed = await svc.processInvoice(
        invoice: zatcaInvoice,
        storeId: sale.storeId,
      );

      await _persistZatcaResult(invoiceId: invoiceId, result: processed);
    } catch (e, st) {
      if (kDebugMode) {
        debugPrint(
          '[InvoiceService] ZATCA Phase-2 pipeline failed (non-blocking): '
          '$e\n$st',
        );
      }
    }
  }

  /// Credit-note variant of `_maybeProcessZatcaPhase2`. Same gating; the
  /// difference is the `ZatcaInvoiceMapper.fromCreditNote` path and the
  /// fact we look up the original invoice number to populate
  /// `billingReferenceId`.
  Future<void> _maybeProcessZatcaPhase2CreditNote({
    required String invoiceId,
    required String storeId,
    required String invoiceNumber,
    required String refInvoiceId,
    required String reason,
    required double amount,
    required double taxAmount,
    required String? customerName,
    required DateTime issuedAt,
  }) async {
    final svc = _zatcaInvoiceService;
    final flag = _isZatcaPhase2EnabledFor;
    if (svc == null || flag == null) return;

    try {
      if (!await flag(storeId)) return;

      final storeRow = await _db.storesDao.getStoreById(storeId);
      if (storeRow == null) return;

      // Resolve the original invoice's number — the credit-note UBL
      // expects the human-readable number, not the DB id.
      final original = await _db.invoicesDao.getById(refInvoiceId);
      final refNumber = original?.invoiceNumber ?? refInvoiceId;
      final originalLines = original?.saleId == null
          ? const <SaleItemsTableData>[]
          : await _db.saleItemsDao.getItemsBySaleId(original!.saleId!);

      final icv = await _db.invoiceCounterDao.nextIcv(
        storeId: storeId,
        invoiceType: InvoiceType.creditNote.value,
      );

      final zatcaInvoice = ZatcaInvoiceMapper.fromCreditNote(
        store: storeRow,
        invoiceNumber: invoiceNumber,
        invoiceCounterValue: icv,
        issuedAt: issuedAt,
        refInvoiceNumber: refNumber,
        reason: reason,
        subtotalCents: (amount * 100).round(),
        taxCents: (taxAmount * 100).round(),
        customerName: customerName,
        originalLines: originalLines,
      );

      final processed = await svc.processInvoice(
        invoice: zatcaInvoice,
        storeId: storeId,
      );

      await _persistZatcaResult(invoiceId: invoiceId, result: processed);
    } catch (e, st) {
      if (kDebugMode) {
        debugPrint(
          '[InvoiceService] ZATCA Phase-2 credit-note pipeline failed '
          '(non-blocking): $e\n$st',
        );
      }
    }
  }

  /// Persist the post-process fields from a `ZatcaInvoice` back to the
  /// local `invoices` row. JSON-encodes warnings/errors as arrays so a
  /// future schema migration can flip the columns to typed JSON1 paths
  /// without changing call sites.
  Future<void> _persistZatcaResult({
    required String invoiceId,
    required zatca.ZatcaInvoice result,
  }) async {
    await _db.invoicesDao.updateZatcaPhase2Result(
      id: invoiceId,
      signedXml: result.signedXml,
      reportingStatus: result.reportingStatus.name,
      warningsJson: result.warnings.isNotEmpty
          ? jsonEncode(result.warnings)
          : null,
      errorsJson: result.errors.isNotEmpty ? jsonEncode(result.errors) : null,
      // Phase-2 enhanced QR replaces the Phase-1 TLV when signing
      // succeeds (it embeds the signature and cert info — strict
      // superset of the Phase-1 fields).
      zatcaQr: result.qrCode,
      zatcaHash: result.invoiceHash,
      icv: result.invoiceCounterValue,
    );
  }
}
