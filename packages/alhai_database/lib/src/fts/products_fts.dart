/// Full-Text Search للمنتجات
///
/// يستخدم SQLite FTS5 للبحث السريع والذكي
/// مع دعم:
/// - البحث الجزئي (prefix matching)
/// - البحث بالعربية
/// - الترتيب حسب الصلة (relevance)
library products_fts;

import 'package:drift/drift.dart';
import '../app_database.dart';

/// خدمة البحث السريع في المنتجات
class ProductsFtsService {
  final AppDatabase _db;

  /// كاش نتيجة فحص وجود جدول FTS (يُفحص مرة واحدة فقط)
  static bool? _ftsTableExistsCache;

  ProductsFtsService(this._db);

  /// إنشاء جدول FTS5 للبحث السريع
  /// يجب استدعاء هذا عند تهيئة قاعدة البيانات
  Future<void> createFtsTable() async {
    // إنشاء جدول FTS5 إن لم يكن موجوداً
    await _db.customStatement('''
      CREATE VIRTUAL TABLE IF NOT EXISTS products_fts USING fts5(
        id UNINDEXED,
        store_id UNINDEXED,
        name,
        barcode,
        sku,
        description,
        content='products',
        content_rowid='rowid',
        tokenize='unicode61 remove_diacritics 1'
      )
    ''');

    // إنشاء triggers لمزامنة FTS مع الجدول الأصلي
    await _db.customStatement('''
      CREATE TRIGGER IF NOT EXISTS products_fts_insert AFTER INSERT ON products BEGIN
        INSERT INTO products_fts(rowid, id, store_id, name, barcode, sku, description)
        VALUES (NEW.rowid, NEW.id, NEW.store_id, NEW.name, NEW.barcode, NEW.sku, NEW.description);
      END
    ''');

    await _db.customStatement('''
      CREATE TRIGGER IF NOT EXISTS products_fts_delete AFTER DELETE ON products BEGIN
        INSERT INTO products_fts(products_fts, rowid, id, store_id, name, barcode, sku, description)
        VALUES ('delete', OLD.rowid, OLD.id, OLD.store_id, OLD.name, OLD.barcode, OLD.sku, OLD.description);
      END
    ''');

    await _db.customStatement('''
      CREATE TRIGGER IF NOT EXISTS products_fts_update AFTER UPDATE ON products BEGIN
        INSERT INTO products_fts(products_fts, rowid, id, store_id, name, barcode, sku, description)
        VALUES ('delete', OLD.rowid, OLD.id, OLD.store_id, OLD.name, OLD.barcode, OLD.sku, OLD.description);
        INSERT INTO products_fts(rowid, id, store_id, name, barcode, sku, description)
        VALUES (NEW.rowid, NEW.id, NEW.store_id, NEW.name, NEW.barcode, NEW.sku, NEW.description);
      END
    ''');

    // تحديث الكاش بعد إنشاء الجدول بنجاح
    _ftsTableExistsCache = true;
  }

  /// إعادة بناء فهرس FTS من البيانات الموجودة
  Future<void> rebuildFtsIndex() async {
    // حذف البيانات القديمة
    await _db.customStatement("DELETE FROM products_fts");

    // إعادة إدراج جميع المنتجات
    await _db.customStatement('''
      INSERT INTO products_fts(rowid, id, store_id, name, barcode, sku, description)
      SELECT rowid, id, store_id, name, barcode, sku, description FROM products
    ''');

    // تحسين الفهرس
    await _db.customStatement("INSERT INTO products_fts(products_fts) VALUES('optimize')");
  }

  /// البحث السريع باستخدام FTS5
  ///
  /// [query] - نص البحث
  /// [storeId] - معرف المتجر
  /// [limit] - الحد الأقصى للنتائج
  /// [offset] - للـ pagination
  ///
  /// يدعم:
  /// - البحث الجزئي: "مان" يجد "مانجو"
  /// - البحث في عدة حقول: الاسم، الباركود، SKU، الوصف
  Future<List<FtsSearchResult>> search(
    String query,
    String storeId, {
    int limit = 20,
    int offset = 0,
  }) async {
    if (query.isEmpty) return [];

    // تنظيف الاستعلام وإضافة * للبحث الجزئي
    final cleanQuery = _prepareQuery(query);

    final results = await _db.customSelect(
      '''
      SELECT
        p.*,
        bm25(products_fts) as rank
      FROM products_fts fts
      INNER JOIN products p ON fts.id = p.id
      WHERE products_fts MATCH ?
        AND fts.store_id = ?
        AND p.is_active = 1
      ORDER BY rank
      LIMIT ? OFFSET ?
      ''',
      variables: [
        Variable.withString(cleanQuery),
        Variable.withString(storeId),
        Variable.withInt(limit),
        Variable.withInt(offset),
      ],
      readsFrom: {},
    ).get();

    return results.map((row) => FtsSearchResult.fromRow(row)).toList();
  }

  /// البحث مع عدد النتائج الكلي
  Future<FtsSearchResponse> searchWithCount(
    String query,
    String storeId, {
    int limit = 20,
    int offset = 0,
  }) async {
    if (query.isEmpty) {
      return FtsSearchResponse(results: [], totalCount: 0);
    }

    final cleanQuery = _prepareQuery(query);

    // عدد النتائج
    final countResult = await _db.customSelect(
      '''
      SELECT COUNT(*) as count
      FROM products_fts fts
      INNER JOIN products p ON fts.id = p.id
      WHERE products_fts MATCH ?
        AND fts.store_id = ?
        AND p.is_active = 1
      ''',
      variables: [
        Variable.withString(cleanQuery),
        Variable.withString(storeId),
      ],
      readsFrom: {},
    ).getSingle();

    final totalCount = countResult.read<int>('count');

    // النتائج
    final results = await search(query, storeId, limit: limit, offset: offset);

    return FtsSearchResponse(results: results, totalCount: totalCount);
  }

  /// بحث سريع بالباركود (exact match)
  Future<String?> findIdByBarcode(String barcode, String storeId) async {
    final result = await _db.customSelect(
      '''
      SELECT id FROM products
      WHERE barcode = ? AND store_id = ? AND is_active = 1
      LIMIT 1
      ''',
      variables: [
        Variable.withString(barcode),
        Variable.withString(storeId),
      ],
      readsFrom: {},
    ).getSingleOrNull();

    return result?.read<String>('id');
  }

  /// اقتراحات البحث (autocomplete)
  Future<List<String>> getSuggestions(
    String query,
    String storeId, {
    int limit = 5,
  }) async {
    if (query.isEmpty) return [];

    final cleanQuery = _prepareQuery(query);

    final results = await _db.customSelect(
      '''
      SELECT DISTINCT name
      FROM products_fts fts
      INNER JOIN products p ON fts.id = p.id
      WHERE products_fts MATCH ?
        AND fts.store_id = ?
        AND p.is_active = 1
      ORDER BY bm25(products_fts)
      LIMIT ?
      ''',
      variables: [
        Variable.withString(cleanQuery),
        Variable.withString(storeId),
        Variable.withInt(limit),
      ],
      readsFrom: {},
    ).get();

    return results.map((row) => row.read<String>('name')).toList();
  }

  /// تحضير استعلام البحث
  String _prepareQuery(String query) {
    // تنظيف الاستعلام
    var cleaned = query
        .trim()
        .replaceAll(RegExp(r'[^\w\u0600-\u06FF\s]'), ' ') // إزالة الأحرف الخاصة مع الحفاظ على العربية
        .replaceAll(RegExp(r'\s+'), ' '); // تقليل المسافات

    // إضافة * لكل كلمة للبحث الجزئي
    final words = cleaned.split(' ').where((w) => w.isNotEmpty);
    return words.map((w) => '$w*').join(' ');
  }

  /// التحقق من وجود جدول FTS (مع كاش لتجنب الاستعلام المتكرر)
  Future<bool> isFtsTableExists() async {
    // إرجاع النتيجة المخزنة إذا كانت متاحة
    if (_ftsTableExistsCache != null) return _ftsTableExistsCache!;

    try {
      final result = await _db.customSelect(
        "SELECT 1 FROM sqlite_master WHERE type='table' AND name='products_fts'",
        readsFrom: {},
      ).getSingleOrNull();
      _ftsTableExistsCache = result != null;
      return _ftsTableExistsCache!;
    } catch (_) {
      _ftsTableExistsCache = false;
      return false;
    }
  }
}

/// نتيجة بحث FTS
class FtsSearchResult {
  final String id;
  final String storeId;
  final String name;
  final String? barcode;
  final String? sku;
  final String? description;
  final double price;
  final int stockQty;
  final String? imageThumbnail;
  final String? categoryId;
  final double rank;

  FtsSearchResult({
    required this.id,
    required this.storeId,
    required this.name,
    this.barcode,
    this.sku,
    this.description,
    required this.price,
    required this.stockQty,
    this.imageThumbnail,
    this.categoryId,
    required this.rank,
  });

  factory FtsSearchResult.fromRow(QueryRow row) {
    return FtsSearchResult(
      id: row.read<String>('id'),
      storeId: row.read<String>('store_id'),
      name: row.read<String>('name'),
      barcode: row.readNullable<String>('barcode'),
      sku: row.readNullable<String>('sku'),
      description: row.readNullable<String>('description'),
      price: row.read<double>('price'),
      stockQty: row.read<int>('stock_qty'),
      imageThumbnail: row.readNullable<String>('image_thumbnail'),
      categoryId: row.readNullable<String>('category_id'),
      rank: row.read<double>('rank'),
    );
  }
}

/// استجابة البحث مع العدد الكلي
class FtsSearchResponse {
  final List<FtsSearchResult> results;
  final int totalCount;

  FtsSearchResponse({
    required this.results,
    required this.totalCount,
  });

  bool get hasMore => results.length < totalCount;
  int get currentCount => results.length;
}
