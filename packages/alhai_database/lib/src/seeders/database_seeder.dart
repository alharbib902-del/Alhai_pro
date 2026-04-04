/// Database Seeder - تحميل بيانات المتجر من CSV
///
/// يقرأ بيانات الفئات والمنتجات من ملفات CSV
/// ويحملها في قاعدة البيانات المحلية (Drift)
library;

import 'package:flutter/foundation.dart';
import 'package:drift/drift.dart';
import 'package:csv/csv.dart';
import 'package:uuid/uuid.dart';

import '../app_database.dart';

/// خدمة تحميل البيانات
class DatabaseSeeder {
  final AppDatabase _db;
  static const _uuid = Uuid();

  /// معرف المتجر الحقيقي في Supabase
  static const String defaultStoreId = 'b10f215e-2c70-4832-a37e-a42a74406a8d';
  static const String defaultUserId = 'user_demo_001';

  DatabaseSeeder(this._db);

  /// التحقق من أن قاعدة البيانات فارغة (COUNT بدل تحميل كل المنتجات)
  Future<bool> isDatabaseEmpty() async {
    final result = await _db.customSelect(
      "SELECT EXISTS(SELECT 1 FROM products WHERE store_id = ? LIMIT 1) AS has_data",
      variables: [Variable.withString(defaultStoreId)],
      readsFrom: {},
    ).getSingle();
    return result.read<int>('has_data') == 0;
  }

  // ============================================================================
  // CSV SEEDING
  // ============================================================================

  /// تحميل البيانات من CSV
  ///
  /// [categoriesCsv] محتوى ملف categories.csv
  /// [productsCsv] محتوى ملف products.csv
  Future<void> seedFromCsv({
    required String categoriesCsv,
    required String productsCsv,
  }) async {
    // التحقق من وجود بيانات
    final existingProducts =
        await _db.productsDao.getAllProducts(defaultStoreId);
    if (existingProducts.isNotEmpty) {
      debugPrint('📦 البيانات موجودة مسبقاً - تخطي Seeding');
      return;
    }

    debugPrint('🌱 بدء تحميل بيانات المتجر من CSV...');

    await _seedStore();
    await _seedCategoriesFromCsv(categoriesCsv);
    await _seedProductsFromCsv(productsCsv);
    await seedAccounts();

    debugPrint('✅ تم تحميل بيانات المتجر بنجاح!');
  }

  /// إنشاء سجل المتجر الافتراضي في جدول stores
  Future<void> _seedStore() async {
    debugPrint('🏪 إنشاء سجل المتجر...');
    try {
      final existing = await _db.storesDao.getStoreById(defaultStoreId);
      if (existing != null) {
        debugPrint('   ✓ المتجر موجود مسبقاً');
        return;
      }
    } catch (_) {}

    await _db.storesDao.insertStore(StoresTableCompanion.insert(
      id: defaultStoreId,
      name: 'سوبرماركت الحي',
      createdAt: DateTime.now(),
      currency: const Value('SAR'),
      timezone: const Value('Asia/Riyadh'),
      isActive: const Value(true),
      address: const Value('الرياض، حي النزهة'),
      phone: const Value('0500000001'),
      city: const Value('الرياض'),
      nameEn: const Value('Al-Hai Supermarket'),
    ));
    debugPrint('   ✓ تم إنشاء المتجر');
  }

  /// تحميل الفئات من CSV
  Future<void> _seedCategoriesFromCsv(String csvData) async {
    debugPrint('📂 تحميل التصنيفات من CSV...');

    final rows = const CsvToListConverter().convert(csvData);
    if (rows.isEmpty) return;

    // تخطي الهيدر
    final dataRows = rows.skip(1);
    final now = DateTime.now();
    int count = 0;

    final categories = <CategoriesTableCompanion>[];

    for (final row in dataRows) {
      // CSV columns: id, store_id, name, name_en, sort_order, is_active
      final storeId = row[1].toString();

      // تصفية للمتجر المطلوب فقط
      if (storeId != defaultStoreId) continue;

      final id = row[0].toString();
      final name = row[2].toString();
      final nameEn = row[3].toString();
      final sortOrder = int.tryParse(row[4].toString()) ?? 0;
      final isActive = row[5].toString().toLowerCase() == 'true';

      categories.add(CategoriesTableCompanion.insert(
        id: id,
        storeId: storeId,
        name: name,
        nameEn: Value(nameEn),
        sortOrder: Value(sortOrder),
        isActive: Value(isActive),
        createdAt: now,
      ));
      count++;
    }

    if (categories.isNotEmpty) {
      await _db.batch((batch) {
        batch.insertAllOnConflictUpdate(_db.categoriesTable, categories);
      });
    }

    debugPrint('   ✓ تم تحميل $count تصنيف');
  }

  /// تحميل المنتجات من CSV (بدفعات)
  Future<void> _seedProductsFromCsv(String csvData) async {
    debugPrint('📦 تحميل المنتجات من CSV...');

    final rows = const CsvToListConverter().convert(csvData);
    if (rows.isEmpty) return;

    // تخطي الهيدر
    final dataRows = rows.skip(1).toList();
    final now = DateTime.now();
    int count = 0;

    // معالجة بدفعات لتجنب مشاكل الذاكرة
    const batchSize = 500;

    for (int i = 0; i < dataRows.length; i += batchSize) {
      final end =
          (i + batchSize > dataRows.length) ? dataRows.length : i + batchSize;
      final chunk = dataRows.sublist(i, end);

      final products = <ProductsTableCompanion>[];

      for (final row in chunk) {
        // CSV columns: id, store_id, name, price, category_id, barcode, stock_qty, is_active, image_url
        final storeId = row[1].toString();

        // تصفية للمتجر المطلوب فقط
        if (storeId != defaultStoreId) continue;

        final id = row[0].toString();
        final name = row[2].toString();
        final price = double.tryParse(row[3].toString()) ?? 0.0;
        final categoryId = row[4].toString();
        final barcode = row[5].toString();
        final stockQty = double.tryParse(row[6].toString()) ?? 0.0;
        final isActive = row[7].toString().toLowerCase() == 'true';
        final imageUrl = row.length > 8 ? row[8].toString().trim() : '';

        products.add(ProductsTableCompanion.insert(
          id: id,
          storeId: storeId,
          name: name,
          barcode: Value(barcode.isNotEmpty ? barcode : null),
          price: price,
          stockQty: Value(stockQty),
          categoryId: Value(categoryId.isNotEmpty ? categoryId : null),
          isActive: Value(isActive),
          imageThumbnail: Value(imageUrl.isNotEmpty ? imageUrl : null),
          imageMedium: Value(imageUrl.isNotEmpty ? imageUrl : null),
          imageLarge: Value(imageUrl.isNotEmpty ? imageUrl : null),
          trackInventory: const Value(true),
          createdAt: now,
        ));
        count++;
      }

      if (products.isNotEmpty) {
        await _db.batch((batch) {
          batch.insertAllOnConflictUpdate(_db.productsTable, products);
        });
      }
    }

    debugPrint('   ✓ تم تحميل $count منتج');
  }

  // ============================================================================
  // LEGACY SEED ALL (للاختبار فقط)
  // ============================================================================

  /// تشغيل جميع الـ Seeders بالبيانات التجريبية
  Future<void> seedAll() async {
    if (kReleaseMode) return;
    final existingProducts =
        await _db.productsDao.getAllProducts(defaultStoreId);
    if (existingProducts.isNotEmpty) {
      debugPrint('📦 البيانات موجودة مسبقاً - تخطي Seeding');
      return;
    }

    debugPrint('🌱 بدء إضافة البيانات التجريبية...');
    await seedAccounts();
    debugPrint('✅ تمت إضافة البيانات التجريبية بنجاح!');
  }

  /// مسح جميع البيانات
  Future<void> clearAll() async {
    debugPrint('🗑️ مسح جميع البيانات...');

    await _db.customStatement('DELETE FROM sale_items');
    await _db.customStatement('DELETE FROM sales');
    await _db.customStatement('DELETE FROM inventory_movements');
    await _db.customStatement('DELETE FROM transactions');
    await _db.customStatement('DELETE FROM accounts');
    await _db.customStatement('DELETE FROM products');
    await _db.customStatement('DELETE FROM categories');

    debugPrint('✅ تم مسح جميع البيانات');
  }

  /// إعادة تعيين وإضافة البيانات من جديد
  Future<void> resetAndSeed({
    String? categoriesCsv,
    String? productsCsv,
  }) async {
    await clearAll();
    if (categoriesCsv != null && productsCsv != null) {
      await seedFromCsv(
        categoriesCsv: categoriesCsv,
        productsCsv: productsCsv,
      );
    } else {
      await seedAll();
    }
  }

  // ============================================================================
  // ACCOUNTS SEEDER (العملاء)
  // ============================================================================

  /// بيانات العملاء
  static final List<Map<String, dynamic>> _accountsData = [
    {
      'name': 'أحمد محمد العلي',
      'phone': '0501234567',
      'balance': 350.00,
      'limit': 1000.00
    },
    {
      'name': 'فاطمة عبدالله',
      'phone': '0551234567',
      'balance': 0.00,
      'limit': 500.00
    },
    {
      'name': 'محمد سعد الدوسري',
      'phone': '0561234567',
      'balance': 1250.00,
      'limit': 2000.00
    },
    {
      'name': 'نورة أحمد',
      'phone': '0541234567',
      'balance': 75.50,
      'limit': 300.00
    },
    {
      'name': 'عبدالرحمن خالد',
      'phone': '0591234567',
      'balance': 0.00,
      'limit': 1500.00
    },
    {
      'name': 'سارة محمد',
      'phone': '0531234567',
      'balance': 450.00,
      'limit': 800.00
    },
    {
      'name': 'يوسف علي الغامدي',
      'phone': '0571234567',
      'balance': 2100.00,
      'limit': 3000.00
    },
    {
      'name': 'هند عبدالعزيز',
      'phone': '0521234567',
      'balance': 180.00,
      'limit': 500.00
    },
    {
      'name': 'خالد إبراهيم',
      'phone': '0581234567',
      'balance': 0.00,
      'limit': 1000.00
    },
    {
      'name': 'ريم سعود',
      'phone': '0511234567',
      'balance': 620.00,
      'limit': 1000.00
    },
  ];

  Future<void> seedAccounts() async {
    debugPrint('👥 إضافة العملاء...');

    final now = DateTime.now();

    // 1) إنشاء سجلات العملاء أولاً في جدول customers
    final customers = <CustomersTableCompanion>[];
    final accounts = <AccountsTableCompanion>[];

    for (final acc in _accountsData) {
      final customerId = 'cust_${_uuid.v4().substring(0, 8)}';
      final accountId = 'acc_${_uuid.v4().substring(0, 8)}';

      // سجل العميل
      customers.add(CustomersTableCompanion.insert(
        id: customerId,
        storeId: defaultStoreId,
        name: acc['name'],
        phone: Value(acc['phone']),
        isActive: const Value(true),
        createdAt: now,
      ));

      // سجل الحساب المرتبط
      accounts.add(AccountsTableCompanion.insert(
        id: accountId,
        storeId: defaultStoreId,
        type: 'receivable',
        customerId: Value(customerId),
        name: acc['name'],
        phone: Value(acc['phone']),
        balance: Value(acc['balance'].toDouble()),
        creditLimit: Value(acc['limit'].toDouble()),
        isActive: const Value(true),
        createdAt: now,
      ));
    }

    // إدخال العملاء أولاً (لتحقيق شرط Foreign Key)
    await _db.batch((batch) {
      batch.insertAllOnConflictUpdate(_db.customersTable, customers);
    });

    // ثم إدخال الحسابات
    await _db.batch((batch) {
      batch.insertAllOnConflictUpdate(_db.accountsTable, accounts);
    });

    debugPrint('   ✓ تم إضافة ${accounts.length} عميل');
  }
}
