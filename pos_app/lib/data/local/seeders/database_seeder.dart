/// Database Seeder - بيانات تجريبية شاملة للتطبيق
///
/// يوفر بيانات واقعية للاختبار تشمل:
/// - تصنيفات متنوعة
/// - منتجات بقالة حقيقية
/// - عملاء مع حسابات وأرصدة
/// - مبيعات تاريخية
/// - حركات مخزون
library;

import 'package:flutter/foundation.dart';
import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../app_database.dart';

/// خدمة إضافة البيانات التجريبية
class DatabaseSeeder {
  final AppDatabase _db;
  static const _uuid = Uuid();

  // Store ID ثابت للتجربة
  static const String defaultStoreId = 'store_demo_001';
  static const String defaultUserId = 'user_demo_001';

  DatabaseSeeder(this._db);

  /// التحقق من أن قاعدة البيانات فارغة
  Future<bool> isDatabaseEmpty() async {
    final products = await _db.productsDao.getAllProducts(defaultStoreId);
    return products.isEmpty;
  }

  /// تشغيل جميع الـ Seeders
  Future<void> seedAll() async {
    // التحقق من وجود بيانات
    final existingProducts = await _db.productsDao.getAllProducts(defaultStoreId);
    if (existingProducts.isNotEmpty) {
      debugPrint('📦 البيانات موجودة مسبقاً - تخطي Seeding');
      return;
    }

    debugPrint('🌱 بدء إضافة البيانات التجريبية...');

    await seedCategories();
    await seedProducts();
    await seedAccounts();
    await seedSales();

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
  Future<void> resetAndSeed() async {
    await clearAll();
    await seedAll();
  }

  // ============================================================================
  // CATEGORIES SEEDER
  // ============================================================================

  /// بيانات التصنيفات
  static final List<Map<String, dynamic>> _categoriesData = [
    {
      'id': 'cat_fruits',
      'name': 'فواكه',
      'nameEn': 'Fruits',
      'icon': 'apple',
      'color': '#F97316',
      'sortOrder': 1,
    },
    {
      'id': 'cat_vegetables',
      'name': 'خضروات',
      'nameEn': 'Vegetables',
      'icon': 'carrot',
      'color': '#22C55E',
      'sortOrder': 2,
    },
    {
      'id': 'cat_dairy',
      'name': 'ألبان وأجبان',
      'nameEn': 'Dairy',
      'icon': 'milk',
      'color': '#3B82F6',
      'sortOrder': 3,
    },
    {
      'id': 'cat_meat',
      'name': 'لحوم ودواجن',
      'nameEn': 'Meat & Poultry',
      'icon': 'drumstick',
      'color': '#EF4444',
      'sortOrder': 4,
    },
    {
      'id': 'cat_bakery',
      'name': 'مخبوزات',
      'nameEn': 'Bakery',
      'icon': 'bread',
      'color': '#F59E0B',
      'sortOrder': 5,
    },
    {
      'id': 'cat_drinks',
      'name': 'مشروبات',
      'nameEn': 'Beverages',
      'icon': 'bottle',
      'color': '#06B6D4',
      'sortOrder': 6,
    },
    {
      'id': 'cat_snacks',
      'name': 'سناكس وحلويات',
      'nameEn': 'Snacks & Sweets',
      'icon': 'cookie',
      'color': '#8B5CF6',
      'sortOrder': 7,
    },
    {
      'id': 'cat_cleaning',
      'name': 'تنظيف ومنزلية',
      'nameEn': 'Cleaning & Home',
      'icon': 'spray',
      'color': '#14B8A6',
      'sortOrder': 8,
    },
    {
      'id': 'cat_grains',
      'name': 'حبوب وبقوليات',
      'nameEn': 'Grains & Legumes',
      'icon': 'grain',
      'color': '#A3A3A3',
      'sortOrder': 9,
    },
    {
      'id': 'cat_frozen',
      'name': 'مجمدات',
      'nameEn': 'Frozen',
      'icon': 'snowflake',
      'color': '#60A5FA',
      'sortOrder': 10,
    },
  ];

  Future<void> seedCategories() async {
    debugPrint('📂 إضافة التصنيفات...');

    final categories = _categoriesData.map((cat) {
      return CategoriesTableCompanion.insert(
        id: cat['id'],
        storeId: defaultStoreId,
        name: cat['name'],
        nameEn: Value(cat['nameEn']),
        icon: Value(cat['icon']),
        color: Value(cat['color']),
        sortOrder: Value(cat['sortOrder']),
        isActive: const Value(true),
        createdAt: DateTime.now(),
      );
    }).toList();

    await _db.categoriesDao.insertCategories(categories);
    debugPrint('   ✓ تم إضافة ${categories.length} تصنيف');
  }

  // ============================================================================
  // PRODUCTS SEEDER
  // ============================================================================

  /// بيانات المنتجات
  static final List<Map<String, dynamic>> _productsData = [
    // فواكه
    {'name': 'تفاح أحمر', 'sku': 'FRU001', 'barcode': '6281000000001', 'price': 8.50, 'cost': 6.00, 'stock': 150, 'min': 20, 'unit': 'كيلو', 'category': 'cat_fruits'},
    {'name': 'موز', 'sku': 'FRU002', 'barcode': '6281000000002', 'price': 6.00, 'cost': 4.00, 'stock': 80, 'min': 15, 'unit': 'كيلو', 'category': 'cat_fruits'},
    {'name': 'برتقال', 'sku': 'FRU003', 'barcode': '6281000000003', 'price': 5.50, 'cost': 3.50, 'stock': 200, 'min': 30, 'unit': 'كيلو', 'category': 'cat_fruits'},
    {'name': 'عنب أخضر', 'sku': 'FRU004', 'barcode': '6281000000004', 'price': 15.00, 'cost': 10.00, 'stock': 45, 'min': 10, 'unit': 'كيلو', 'category': 'cat_fruits'},
    {'name': 'فراولة', 'sku': 'FRU005', 'barcode': '6281000000005', 'price': 18.00, 'cost': 12.00, 'stock': 30, 'min': 8, 'unit': 'علبة', 'category': 'cat_fruits'},
    {'name': 'مانجو', 'sku': 'FRU006', 'barcode': '6281000000006', 'price': 12.00, 'cost': 8.00, 'stock': 60, 'min': 15, 'unit': 'كيلو', 'category': 'cat_fruits'},
    {'name': 'بطيخ', 'sku': 'FRU007', 'barcode': '6281000000007', 'price': 3.00, 'cost': 1.50, 'stock': 25, 'min': 5, 'unit': 'حبة', 'category': 'cat_fruits'},

    // خضروات
    {'name': 'طماطم', 'sku': 'VEG001', 'barcode': '6281000000101', 'price': 4.00, 'cost': 2.50, 'stock': 180, 'min': 25, 'unit': 'كيلو', 'category': 'cat_vegetables'},
    {'name': 'خيار', 'sku': 'VEG002', 'barcode': '6281000000102', 'price': 3.50, 'cost': 2.00, 'stock': 150, 'min': 20, 'unit': 'كيلو', 'category': 'cat_vegetables'},
    {'name': 'بصل', 'sku': 'VEG003', 'barcode': '6281000000103', 'price': 3.00, 'cost': 1.80, 'stock': 200, 'min': 30, 'unit': 'كيلو', 'category': 'cat_vegetables'},
    {'name': 'بطاطس', 'sku': 'VEG004', 'barcode': '6281000000104', 'price': 4.50, 'cost': 3.00, 'stock': 250, 'min': 40, 'unit': 'كيلو', 'category': 'cat_vegetables'},
    {'name': 'جزر', 'sku': 'VEG005', 'barcode': '6281000000105', 'price': 4.00, 'cost': 2.50, 'stock': 120, 'min': 20, 'unit': 'كيلو', 'category': 'cat_vegetables'},
    {'name': 'خس', 'sku': 'VEG006', 'barcode': '6281000000106', 'price': 5.00, 'cost': 3.00, 'stock': 50, 'min': 10, 'unit': 'حبة', 'category': 'cat_vegetables'},
    {'name': 'فلفل رومي', 'sku': 'VEG007', 'barcode': '6281000000107', 'price': 8.00, 'cost': 5.00, 'stock': 80, 'min': 15, 'unit': 'كيلو', 'category': 'cat_vegetables'},
    {'name': 'كوسة', 'sku': 'VEG008', 'barcode': '6281000000108', 'price': 5.00, 'cost': 3.00, 'stock': 90, 'min': 15, 'unit': 'كيلو', 'category': 'cat_vegetables'},

    // ألبان وأجبان
    {'name': 'حليب المراعي طازج 2 لتر', 'sku': 'DAI001', 'barcode': '6281048000001', 'price': 11.50, 'cost': 9.00, 'stock': 100, 'min': 20, 'unit': 'علبة', 'category': 'cat_dairy'},
    {'name': 'لبن المراعي 1 لتر', 'sku': 'DAI002', 'barcode': '6281048000002', 'price': 5.50, 'cost': 4.00, 'stock': 80, 'min': 15, 'unit': 'علبة', 'category': 'cat_dairy'},
    {'name': 'جبنة كرافت شرائح', 'sku': 'DAI003', 'barcode': '6281048000003', 'price': 12.00, 'cost': 9.00, 'stock': 60, 'min': 10, 'unit': 'علبة', 'category': 'cat_dairy'},
    {'name': 'زبادي السعودية 170 جرام', 'sku': 'DAI004', 'barcode': '6281048000004', 'price': 2.00, 'cost': 1.30, 'stock': 150, 'min': 30, 'unit': 'حبة', 'category': 'cat_dairy'},
    {'name': 'جبنة بيضاء', 'sku': 'DAI005', 'barcode': '6281048000005', 'price': 18.00, 'cost': 13.00, 'stock': 40, 'min': 8, 'unit': 'كيلو', 'category': 'cat_dairy'},
    {'name': 'قشطة بوك', 'sku': 'DAI006', 'barcode': '6281048000006', 'price': 3.50, 'cost': 2.50, 'stock': 70, 'min': 15, 'unit': 'علبة', 'category': 'cat_dairy'},
    {'name': 'زبدة لورباك 200 جرام', 'sku': 'DAI007', 'barcode': '6281048000007', 'price': 14.00, 'cost': 10.00, 'stock': 35, 'min': 8, 'unit': 'علبة', 'category': 'cat_dairy'},

    // لحوم ودواجن
    {'name': 'دجاج كامل طازج', 'sku': 'MEA001', 'barcode': '6281000000201', 'price': 22.00, 'cost': 16.00, 'stock': 50, 'min': 10, 'unit': 'كيلو', 'category': 'cat_meat'},
    {'name': 'صدور دجاج', 'sku': 'MEA002', 'barcode': '6281000000202', 'price': 32.00, 'cost': 24.00, 'stock': 35, 'min': 8, 'unit': 'كيلو', 'category': 'cat_meat'},
    {'name': 'لحم بقري مفروم', 'sku': 'MEA003', 'barcode': '6281000000203', 'price': 48.00, 'cost': 38.00, 'stock': 25, 'min': 5, 'unit': 'كيلو', 'category': 'cat_meat'},
    {'name': 'لحم غنم', 'sku': 'MEA004', 'barcode': '6281000000204', 'price': 65.00, 'cost': 52.00, 'stock': 20, 'min': 5, 'unit': 'كيلو', 'category': 'cat_meat'},
    {'name': 'نقانق', 'sku': 'MEA005', 'barcode': '6281000000205', 'price': 18.00, 'cost': 12.00, 'stock': 40, 'min': 10, 'unit': 'علبة', 'category': 'cat_meat'},

    // مخبوزات
    {'name': 'خبز صامولي', 'sku': 'BAK001', 'barcode': '6281000000301', 'price': 3.00, 'cost': 2.00, 'stock': 100, 'min': 20, 'unit': 'كيس', 'category': 'cat_bakery'},
    {'name': 'خبز تميس', 'sku': 'BAK002', 'barcode': '6281000000302', 'price': 2.50, 'cost': 1.50, 'stock': 80, 'min': 15, 'unit': 'كيس', 'category': 'cat_bakery'},
    {'name': 'توست لوزين', 'sku': 'BAK003', 'barcode': '6281000000303', 'price': 8.00, 'cost': 5.50, 'stock': 60, 'min': 12, 'unit': 'كيس', 'category': 'cat_bakery'},
    {'name': 'كرواسون', 'sku': 'BAK004', 'barcode': '6281000000304', 'price': 1.50, 'cost': 0.80, 'stock': 50, 'min': 10, 'unit': 'حبة', 'category': 'cat_bakery'},
    {'name': 'صمون فرنسي', 'sku': 'BAK005', 'barcode': '6281000000305', 'price': 4.00, 'cost': 2.50, 'stock': 40, 'min': 8, 'unit': 'حبة', 'category': 'cat_bakery'},

    // مشروبات
    {'name': 'بيبسي 330 مل', 'sku': 'DRK001', 'barcode': '6281000000401', 'price': 2.00, 'cost': 1.20, 'stock': 200, 'min': 50, 'unit': 'علبة', 'category': 'cat_drinks'},
    {'name': 'كوكاكولا 330 مل', 'sku': 'DRK002', 'barcode': '6281000000402', 'price': 2.00, 'cost': 1.20, 'stock': 180, 'min': 50, 'unit': 'علبة', 'category': 'cat_drinks'},
    {'name': 'مياه أكوافينا 600 مل', 'sku': 'DRK003', 'barcode': '6281000000403', 'price': 1.00, 'cost': 0.50, 'stock': 300, 'min': 80, 'unit': 'زجاجة', 'category': 'cat_drinks'},
    {'name': 'عصير المراعي برتقال 1 لتر', 'sku': 'DRK004', 'barcode': '6281000000404', 'price': 6.50, 'cost': 4.50, 'stock': 80, 'min': 20, 'unit': 'علبة', 'category': 'cat_drinks'},
    {'name': 'ريد بول', 'sku': 'DRK005', 'barcode': '6281000000405', 'price': 8.00, 'cost': 5.50, 'stock': 60, 'min': 15, 'unit': 'علبة', 'category': 'cat_drinks'},
    {'name': 'شاي ليبتون علب', 'sku': 'DRK006', 'barcode': '6281000000406', 'price': 15.00, 'cost': 10.00, 'stock': 45, 'min': 10, 'unit': 'علبة', 'category': 'cat_drinks'},
    {'name': 'نسكافيه جولد 100 جرام', 'sku': 'DRK007', 'barcode': '6281000000407', 'price': 32.00, 'cost': 24.00, 'stock': 30, 'min': 8, 'unit': 'علبة', 'category': 'cat_drinks'},

    // سناكس وحلويات
    {'name': 'شيبس ليز 170 جرام', 'sku': 'SNK001', 'barcode': '6281000000501', 'price': 7.00, 'cost': 4.50, 'stock': 100, 'min': 25, 'unit': 'كيس', 'category': 'cat_snacks'},
    {'name': 'شوكولاتة جالكسي', 'sku': 'SNK002', 'barcode': '6281000000502', 'price': 5.00, 'cost': 3.20, 'stock': 80, 'min': 20, 'unit': 'حبة', 'category': 'cat_snacks'},
    {'name': 'بسكويت أوريو', 'sku': 'SNK003', 'barcode': '6281000000503', 'price': 4.50, 'cost': 3.00, 'stock': 90, 'min': 20, 'unit': 'علبة', 'category': 'cat_snacks'},
    {'name': 'كيندر بوينو', 'sku': 'SNK004', 'barcode': '6281000000504', 'price': 6.00, 'cost': 4.00, 'stock': 70, 'min': 15, 'unit': 'حبة', 'category': 'cat_snacks'},
    {'name': 'مكسرات مشكلة', 'sku': 'SNK005', 'barcode': '6281000000505', 'price': 25.00, 'cost': 18.00, 'stock': 35, 'min': 8, 'unit': 'كيس', 'category': 'cat_snacks'},
    {'name': 'تمر سكري', 'sku': 'SNK006', 'barcode': '6281000000506', 'price': 35.00, 'cost': 25.00, 'stock': 40, 'min': 10, 'unit': 'كيلو', 'category': 'cat_snacks'},

    // تنظيف ومنزلية
    {'name': 'صابون فيري', 'sku': 'CLN001', 'barcode': '6281000000601', 'price': 8.50, 'cost': 5.50, 'stock': 60, 'min': 15, 'unit': 'زجاجة', 'category': 'cat_cleaning'},
    {'name': 'مناديل كلينكس 200 ورقة', 'sku': 'CLN002', 'barcode': '6281000000602', 'price': 12.00, 'cost': 8.00, 'stock': 80, 'min': 20, 'unit': 'علبة', 'category': 'cat_cleaning'},
    {'name': 'معجون أسنان كولجيت', 'sku': 'CLN003', 'barcode': '6281000000603', 'price': 9.00, 'cost': 6.00, 'stock': 50, 'min': 12, 'unit': 'حبة', 'category': 'cat_cleaning'},
    {'name': 'شامبو هيد آند شولدرز', 'sku': 'CLN004', 'barcode': '6281000000604', 'price': 22.00, 'cost': 15.00, 'stock': 35, 'min': 8, 'unit': 'زجاجة', 'category': 'cat_cleaning'},
    {'name': 'منظف زجاج ويندكس', 'sku': 'CLN005', 'barcode': '6281000000605', 'price': 14.00, 'cost': 9.00, 'stock': 25, 'min': 6, 'unit': 'زجاجة', 'category': 'cat_cleaning'},

    // حبوب وبقوليات
    {'name': 'أرز بسمتي 5 كيلو', 'sku': 'GRN001', 'barcode': '6281000000701', 'price': 45.00, 'cost': 35.00, 'stock': 50, 'min': 10, 'unit': 'كيس', 'category': 'cat_grains'},
    {'name': 'سكر 5 كيلو', 'sku': 'GRN002', 'barcode': '6281000000702', 'price': 18.00, 'cost': 14.00, 'stock': 60, 'min': 15, 'unit': 'كيس', 'category': 'cat_grains'},
    {'name': 'طحين 2 كيلو', 'sku': 'GRN003', 'barcode': '6281000000703', 'price': 8.00, 'cost': 5.50, 'stock': 70, 'min': 15, 'unit': 'كيس', 'category': 'cat_grains'},
    {'name': 'معكرونة قودي', 'sku': 'GRN004', 'barcode': '6281000000704', 'price': 4.50, 'cost': 3.00, 'stock': 100, 'min': 25, 'unit': 'كيس', 'category': 'cat_grains'},
    {'name': 'فول مدمس', 'sku': 'GRN005', 'barcode': '6281000000705', 'price': 3.50, 'cost': 2.20, 'stock': 80, 'min': 20, 'unit': 'علبة', 'category': 'cat_grains'},
    {'name': 'حمص حب', 'sku': 'GRN006', 'barcode': '6281000000706', 'price': 6.00, 'cost': 4.00, 'stock': 45, 'min': 10, 'unit': 'كيلو', 'category': 'cat_grains'},
    {'name': 'عدس', 'sku': 'GRN007', 'barcode': '6281000000707', 'price': 7.00, 'cost': 4.50, 'stock': 40, 'min': 10, 'unit': 'كيلو', 'category': 'cat_grains'},

    // مجمدات
    {'name': 'بازلاء مجمدة', 'sku': 'FRZ001', 'barcode': '6281000000801', 'price': 8.00, 'cost': 5.00, 'stock': 40, 'min': 10, 'unit': 'كيس', 'category': 'cat_frozen'},
    {'name': 'سمبوسة جاهزة', 'sku': 'FRZ002', 'barcode': '6281000000802', 'price': 15.00, 'cost': 10.00, 'stock': 50, 'min': 12, 'unit': 'علبة', 'category': 'cat_frozen'},
    {'name': 'بطاطس فرنسية مجمدة', 'sku': 'FRZ003', 'barcode': '6281000000803', 'price': 12.00, 'cost': 8.00, 'stock': 60, 'min': 15, 'unit': 'كيس', 'category': 'cat_frozen'},
    {'name': 'آيس كريم فانيلا', 'sku': 'FRZ004', 'barcode': '6281000000804', 'price': 18.00, 'cost': 12.00, 'stock': 30, 'min': 8, 'unit': 'علبة', 'category': 'cat_frozen'},
    {'name': 'سمك فيليه', 'sku': 'FRZ005', 'barcode': '6281000000805', 'price': 35.00, 'cost': 25.00, 'stock': 20, 'min': 5, 'unit': 'كيلو', 'category': 'cat_frozen'},

    // منتجات منخفضة المخزون (للاختبار)
    {'name': 'زيت زيتون', 'sku': 'OIL001', 'barcode': '6281000000901', 'price': 45.00, 'cost': 35.00, 'stock': 5, 'min': 10, 'unit': 'زجاجة', 'category': 'cat_grains'},
    {'name': 'عسل طبيعي', 'sku': 'OIL002', 'barcode': '6281000000902', 'price': 65.00, 'cost': 50.00, 'stock': 3, 'min': 5, 'unit': 'علبة', 'category': 'cat_grains'},

    // منتجات نفذت (للاختبار)
    {'name': 'زعفران', 'sku': 'SPC001', 'barcode': '6281000000903', 'price': 120.00, 'cost': 90.00, 'stock': 0, 'min': 2, 'unit': 'جرام', 'category': 'cat_grains'},
  ];

  Future<void> seedProducts() async {
    debugPrint('📦 إضافة المنتجات...');

    final now = DateTime.now();
    final products = _productsData.map((prod) {
      return ProductsTableCompanion.insert(
        id: 'prod_${_uuid.v4().substring(0, 8)}',
        storeId: defaultStoreId,
        name: prod['name'],
        sku: Value(prod['sku']),
        barcode: Value(prod['barcode']),
        price: prod['price'].toDouble(),
        costPrice: Value(prod['cost'].toDouble()),
        stockQty: Value(prod['stock']),
        minQty: Value(prod['min']),
        unit: Value(prod['unit']),
        categoryId: Value(prod['category']),
        isActive: const Value(true),
        trackInventory: const Value(true),
        createdAt: now,
      );
    }).toList();

    await _db.batch((batch) {
      batch.insertAllOnConflictUpdate(_db.productsTable, products);
    });

    debugPrint('   ✓ تم إضافة ${products.length} منتج');
  }

  // ============================================================================
  // ACCOUNTS SEEDER (العملاء)
  // ============================================================================

  /// بيانات العملاء
  static final List<Map<String, dynamic>> _accountsData = [
    {'name': 'أحمد محمد العلي', 'phone': '0501234567', 'balance': 350.00, 'limit': 1000.00},
    {'name': 'فاطمة عبدالله', 'phone': '0551234567', 'balance': 0.00, 'limit': 500.00},
    {'name': 'محمد سعد الدوسري', 'phone': '0561234567', 'balance': 1250.00, 'limit': 2000.00},
    {'name': 'نورة أحمد', 'phone': '0541234567', 'balance': 75.50, 'limit': 300.00},
    {'name': 'عبدالرحمن خالد', 'phone': '0591234567', 'balance': 0.00, 'limit': 1500.00},
    {'name': 'سارة محمد', 'phone': '0531234567', 'balance': 450.00, 'limit': 800.00},
    {'name': 'يوسف علي الغامدي', 'phone': '0571234567', 'balance': 2100.00, 'limit': 3000.00},
    {'name': 'هند عبدالعزيز', 'phone': '0521234567', 'balance': 180.00, 'limit': 500.00},
    {'name': 'خالد إبراهيم', 'phone': '0581234567', 'balance': 0.00, 'limit': 1000.00},
    {'name': 'ريم سعود', 'phone': '0511234567', 'balance': 620.00, 'limit': 1000.00},
  ];

  Future<void> seedAccounts() async {
    debugPrint('👥 إضافة العملاء...');

    final now = DateTime.now();
    final accounts = _accountsData.map((acc) {
      final customerId = 'cust_${_uuid.v4().substring(0, 8)}';
      return AccountsTableCompanion.insert(
        id: 'acc_${_uuid.v4().substring(0, 8)}',
        storeId: defaultStoreId,
        type: 'receivable',
        customerId: Value(customerId),
        name: acc['name'],
        phone: Value(acc['phone']),
        balance: Value(acc['balance'].toDouble()),
        creditLimit: Value(acc['limit'].toDouble()),
        isActive: const Value(true),
        createdAt: now,
      );
    }).toList();

    await _db.batch((batch) {
      batch.insertAllOnConflictUpdate(_db.accountsTable, accounts);
    });

    debugPrint('   ✓ تم إضافة ${accounts.length} عميل');
  }

  // ============================================================================
  // SALES SEEDER
  // ============================================================================

  Future<void> seedSales() async {
    debugPrint('💰 إضافة المبيعات...');

    // الحصول على المنتجات للاستخدام في المبيعات
    final products = await _db.productsDao.getAllProducts(defaultStoreId);
    if (products.isEmpty) {
      debugPrint('   ⚠️ لا توجد منتجات - تخطي المبيعات');
      return;
    }

    final now = DateTime.now();
    int salesCount = 0;
    int itemsCount = 0;

    // إنشاء 25 فاتورة في آخر 7 أيام
    for (int dayOffset = 0; dayOffset < 7; dayOffset++) {
      final salesPerDay = dayOffset == 0 ? 5 : (3 + (dayOffset % 3)); // اليوم 5، باقي الأيام 3-5

      for (int i = 0; i < salesPerDay; i++) {
        final saleId = 'sale_${_uuid.v4().substring(0, 8)}';
        final saleDate = now.subtract(Duration(days: dayOffset, hours: i * 2));
        final receiptNo = 'INV-${saleDate.year}${saleDate.month.toString().padLeft(2, '0')}${saleDate.day.toString().padLeft(2, '0')}-${(salesCount + 1).toString().padLeft(4, '0')}';

        // اختيار 2-5 منتجات عشوائية
        final itemCount = 2 + (salesCount % 4);
        final selectedProducts = _getRandomProducts(products, itemCount);

        double subtotal = 0;
        final saleItems = <SaleItemsTableCompanion>[];

        for (final product in selectedProducts) {
          final qty = 1 + (salesCount % 3);
          final itemTotal = product.price * qty;
          subtotal += itemTotal;

          saleItems.add(SaleItemsTableCompanion.insert(
            id: 'item_${_uuid.v4().substring(0, 8)}',
            saleId: saleId,
            productId: product.id,
            productName: product.name,
            productSku: Value(product.sku),
            productBarcode: Value(product.barcode),
            qty: qty,
            unitPrice: product.price,
            costPrice: Value(product.costPrice),
            subtotal: itemTotal,
            discount: const Value(0),
            total: itemTotal,
          ));
          itemsCount++;
        }

        // حساب الخصم (أحياناً)
        final discount = (salesCount % 5 == 0) ? subtotal * 0.05 : 0.0;
        final tax = (subtotal - discount) * 0.15;
        final total = subtotal - discount + tax;

        // طريقة الدفع
        final paymentMethods = ['cash', 'cash', 'cash', 'card', 'credit'];
        final paymentMethod = paymentMethods[salesCount % paymentMethods.length];

        // إدراج البيع
        await _db.into(_db.salesTable).insert(SalesTableCompanion.insert(
          id: saleId,
          receiptNo: receiptNo,
          storeId: defaultStoreId,
          cashierId: defaultUserId,
          subtotal: subtotal,
          discount: Value(discount),
          tax: Value(tax),
          total: total,
          paymentMethod: paymentMethod,
          isPaid: Value(paymentMethod != 'credit'),
          amountReceived: Value(paymentMethod == 'cash' ? total + 10 : total),
          changeAmount: Value(paymentMethod == 'cash' ? 10.0 : 0.0),
          channel: const Value('POS'),
          status: const Value('completed'),
          createdAt: saleDate,
        ));

        // إدراج العناصر
        await _db.batch((batch) {
          batch.insertAll(_db.saleItemsTable, saleItems);
        });

        salesCount++;
      }
    }

    debugPrint('   ✓ تم إضافة $salesCount فاتورة و $itemsCount عنصر');
  }

  /// اختيار منتجات عشوائية
  List<ProductsTableData> _getRandomProducts(List<ProductsTableData> products, int count) {
    final shuffled = List<ProductsTableData>.from(products)..shuffle();
    return shuffled.take(count).toList();
  }
}
