/// خدمة إرسال الإيصالات عبر واتساب
///
/// الإصدار الجديد: يدعم إرسال الإيصالات كنص أو كمستند PDF.
/// جميع الرسائل تُحفظ في طابور قاعدة البيانات (whatsapp_messages)
/// ثم تُرسل تلقائياً عبر WhatsAppQueueProcessor.
///
/// طرق الإرسال:
/// - [sendReceiptText]: إرسال الإيصال كرسالة نصية
/// - [sendReceiptPdf]: إرسال الإيصال كمستند PDF
/// - [sendReceipt]: إرسال ذكي (PDF أولاً، نص كبديل)
library;

import 'dart:io';
import 'dart:typed_data';

import 'package:drift/drift.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

import 'package:pos_app/data/local/app_database.dart';
import 'package:pos_app/data/local/daos/whatsapp_messages_dao.dart';
import 'package:pos_app/services/whatsapp/phone_validation_service.dart';
import 'package:pos_app/services/whatsapp/wasender_api_client.dart';

// ============================================================================
// RECEIPT LINE ITEM
// ============================================================================

/// عنصر في الإيصال
class ReceiptLineItem {
  final String name;
  final int quantity;
  final double total;

  const ReceiptLineItem({
    required this.name,
    required this.quantity,
    required this.total,
  });
}

// ============================================================================
// RECEIPT RESULT
// ============================================================================

/// نتيجة إرسال الإيصال
class WhatsAppReceiptResult {
  final bool isSuccess;
  final String? error;
  final String? messageId;

  const WhatsAppReceiptResult._({
    required this.isSuccess,
    this.error,
    this.messageId,
  });

  factory WhatsAppReceiptResult.success({String? messageId}) =>
      WhatsAppReceiptResult._(isSuccess: true, messageId: messageId);

  factory WhatsAppReceiptResult.error(String message) =>
      WhatsAppReceiptResult._(isSuccess: false, error: message);
}

// ============================================================================
// WHATSAPP RECEIPT SERVICE
// ============================================================================

/// خدمة إرسال الإيصالات عبر واتساب
///
/// تدعم إرسال الإيصالات كنص عادي أو كمستند PDF عبر طابور قاعدة البيانات.
class WhatsAppReceiptService {
  final WaSenderApiClient _apiClient;
  final WhatsAppMessagesDao _messagesDao;
  final String _storeId;
  static const _uuid = Uuid();

  WhatsAppReceiptService({
    required WaSenderApiClient apiClient,
    required WhatsAppMessagesDao messagesDao,
    String storeId = 'default',
  })  : _apiClient = apiClient,
        _messagesDao = messagesDao,
        _storeId = storeId;

  // ============================================================================
  // تنسيق الإيصال (Static - لا يحتاج instance)
  // ============================================================================

  /// تنسيق بيانات البيع كنص إيصال لواتساب
  ///
  /// يُنشئ نص إيصال منسّق يتضمن:
  /// - اسم المتجر ورقم الفاتورة والتاريخ
  /// - قائمة المنتجات مع الكميات والأسعار
  /// - المجموع الفرعي والضريبة والخصم والإجمالي
  /// - طريقة الدفع
  static String formatReceipt({
    required String storeName,
    required String receiptNo,
    required DateTime date,
    required List<ReceiptLineItem> items,
    required double subtotal,
    required double tax,
    required double discount,
    required double total,
    required String paymentMethod,
    double taxRate = 0.15,
  }) {
    final dateFormatter = DateFormat('yyyy/MM/dd - hh:mm a', 'ar');
    final formattedDate = dateFormatter.format(date);

    final buffer = StringBuffer();

    // Header
    buffer.writeln('\u{1F9FE} إيصال إلكتروني');
    buffer.writeln('المتجر: $storeName');
    buffer.writeln('رقم الفاتورة: $receiptNo');
    buffer.writeln('التاريخ: $formattedDate');
    buffer.writeln('──────────');

    // Items
    for (final item in items) {
      buffer.writeln(
        '${item.quantity}x ${item.name} ... ${item.total.toStringAsFixed(2)} ر.س',
      );
    }
    buffer.writeln('──────────');

    // Subtotal
    buffer.writeln(
      'المجموع الفرعي: ${subtotal.toStringAsFixed(2)} ر.س',
    );

    // Tax
    final taxPercent = (taxRate * 100).toStringAsFixed(0);
    buffer.writeln(
      'الضريبة $taxPercent%: ${tax.toStringAsFixed(2)} ر.س',
    );

    // Discount (only if > 0)
    if (discount > 0) {
      buffer.writeln(
        'الخصم: -${discount.toStringAsFixed(2)} ر.س',
      );
    }

    buffer.writeln('──────────');

    // Total (bold with WhatsApp markdown)
    buffer.writeln(
      '*الإجمالي: ${total.toStringAsFixed(2)} ر.س*',
    );

    // Payment method
    buffer.writeln('طريقة الدفع: $paymentMethod');

    buffer.writeln('──────────');
    buffer.writeln('شكراً لتسوقكم! \u{1F31F}');

    return buffer.toString();
  }

  // ============================================================================
  // إرسال الإيصال كمستند PDF
  // ============================================================================

  /// إرسال إيصال كمستند PDF عبر الطابور
  ///
  /// يحفظ ملف PDF في المجلد المؤقت ثم يُنشئ سجل رسالة
  /// بنوع "document" في طابور قاعدة البيانات.
  ///
  /// يُرجع معرف الرسالة (UUID) لتتبعها.
  Future<String> sendReceiptPdf({
    required String phone,
    required Uint8List pdfBytes,
    required String receiptNo,
    String? customerId,
    String? saleId,
  }) async {
    // حفظ PDF في المجلد المؤقت
    final tempDir = await getTemporaryDirectory();
    final pdfFileName = 'receipt_$receiptNo.pdf';
    final pdfFile = File('${tempDir.path}/$pdfFileName');
    await pdfFile.writeAsBytes(pdfBytes);

    final id = _uuid.v4();
    final formattedPhone = PhoneValidationService.formatPhone(phone);

    await _messagesDao.enqueue(
      WhatsAppMessagesTableCompanion.insert(
        id: id,
        storeId: _storeId,
        phone: formattedPhone,
        messageType: 'document',
        textContent: Value('إيصال فاتورة رقم $receiptNo'),
        mediaLocalPath: Value(pdfFile.path),
        fileName: Value(pdfFileName),
        customerId: Value(customerId),
        referenceType: const Value('sale'),
        referenceId: Value(saleId ?? receiptNo),
        createdAt: DateTime.now(),
        priority: const Value(3), // high priority for receipts
      ),
    );

    return id;
  }

  // ============================================================================
  // إرسال الإيصال كنص
  // ============================================================================

  /// إرسال إيصال كرسالة نصية عبر الطابور
  ///
  /// يُنشئ سجل رسالة بنوع "text" في طابور قاعدة البيانات.
  /// يُرجع معرف الرسالة (UUID) لتتبعها.
  Future<String> sendReceiptText({
    required String phone,
    required String receiptText,
    String? customerId,
    String? saleId,
  }) async {
    final id = _uuid.v4();
    final formattedPhone = PhoneValidationService.formatPhone(phone);

    await _messagesDao.enqueue(
      WhatsAppMessagesTableCompanion.insert(
        id: id,
        storeId: _storeId,
        phone: formattedPhone,
        messageType: 'text',
        textContent: Value(receiptText),
        customerId: Value(customerId),
        referenceType: const Value('sale'),
        referenceId: Value(saleId),
        createdAt: DateTime.now(),
        priority: const Value(3), // high priority for receipts
      ),
    );

    return id;
  }

  // ============================================================================
  // الإرسال الذكي (PDF أولاً، نص كبديل)
  // ============================================================================

  /// إرسال إيصال بالطريقة المُثلى
  ///
  /// إذا تم توفير [pdfBytes] و [preferPdf] = true:
  ///   يتم إرسال PDF كمستند.
  ///
  /// إذا لم يتوفر PDF أو [preferPdf] = false:
  ///   يتم إرسال النص كرسالة عادية.
  ///
  /// إذا لم يتوفر أي محتوى، يتم رمي خطأ.
  ///
  /// يُرجع معرف الرسالة (UUID) لتتبعها.
  Future<String> sendReceipt({
    required String phone,
    Uint8List? pdfBytes,
    String? receiptText,
    required String receiptNo,
    bool preferPdf = true,
    String? customerId,
    String? saleId,
  }) async {
    // محاولة إرسال PDF إذا متوفر ومفضّل
    if (preferPdf && pdfBytes != null && pdfBytes.isNotEmpty) {
      return sendReceiptPdf(
        phone: phone,
        pdfBytes: pdfBytes,
        receiptNo: receiptNo,
        customerId: customerId,
        saleId: saleId,
      );
    }

    // إرسال نص إذا متوفر
    if (receiptText != null && receiptText.isNotEmpty) {
      return sendReceiptText(
        phone: phone,
        receiptText: receiptText,
        customerId: customerId,
        saleId: saleId,
      );
    }

    // لا يوجد محتوى للإرسال
    throw ArgumentError(
      'يجب توفير pdfBytes أو receiptText على الأقل',
    );
  }
}
