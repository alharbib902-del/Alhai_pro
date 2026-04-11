/// PDF Font Helper - تحميل خطوط عربية لتوليد PDF
///
/// يحمل خطوط Tajawal ويوفر ThemeData جاهز للاستخدام مع pw.Document
library;

import 'package:flutter/services.dart' show rootBundle;
import 'package:pdf/widgets.dart' as pw;

/// مساعد تحميل خطوط PDF
class PdfFontHelper {
  static pw.Font? _regularFont;
  static pw.Font? _boldFont;

  /// تحميل خطوط Tajawal (مع كاش)
  static Future<void> loadFonts() async {
    if (_regularFont != null && _boldFont != null) return;

    final regularData = await rootBundle.load(
      'packages/alhai_design_system/assets/fonts/Tajawal-Regular.ttf',
    );
    final boldData = await rootBundle.load(
      'packages/alhai_design_system/assets/fonts/Tajawal-Bold.ttf',
    );

    _regularFont = pw.Font.ttf(regularData);
    _boldFont = pw.Font.ttf(boldData);
  }

  /// الحصول على ThemeData مع خطوط عربية
  static pw.ThemeData get arabicTheme =>
      pw.ThemeData.withFont(base: _regularFont, bold: _boldFont);

  /// إنشاء Document مع دعم Unicode عربي
  static Future<pw.Document> createDocument() async {
    await loadFonts();
    return pw.Document(theme: arabicTheme);
  }
}
