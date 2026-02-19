/// بيانات اختبار شاملة - Section A
///
/// يحتوي على بيانات الاختبار المشتركة والدوال المساعدة
/// لجميع أقسام الاختبارات الشاملة (B-S)
library;

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:mocktail/mocktail.dart';

import 'package:alhai_core/alhai_core.dart' hide CartItem;
import 'package:pos_app/data/local/app_database.dart';
import 'package:pos_app/providers/cart_providers.dart';
import 'package:pos_app/services/sale_service.dart';
import 'package:pos_app/services/sync/sync_service.dart';

// ============================================================================
// CONSTANTS
// ============================================================================

const vatRate = 0.15;
const currency = 'SAR';
const lineDiscountMax = 0.50; // 50%
const invoiceDiscountMax = 0.30; // 30%

// ============================================================================
// MOCKS
// ============================================================================

class MockSyncService extends Mock implements SyncService {}

// ============================================================================
// COMPUTATION HELPERS
// ============================================================================

/// تقريب لمنزلتين عشريتين (SAR)
double roundSar(double v) => (v * 100).roundToDouble() / 100;

/// حساب ضريبة القيمة المضافة
double computeVat(double netAmount, {bool exempt = false}) =>
    exempt ? 0.0 : roundSar(netAmount * vatRate);

/// تسقيف الخصم: لا يتجاوز subtotal
double capDiscount(double discount, double subtotal) =>
    discount > subtotal ? subtotal : discount;

/// حساب خصم نسبة مع تقريب
double percentDiscount(double subtotal, double percent) =>
    roundSar(subtotal * percent);

/// التحقق من أن خصم السطر ضمن الحدود
bool isLineDiscountAllowed(double discountPercent) =>
    discountPercent <= lineDiscountMax;

/// التحقق من أن خصم الفاتورة ضمن الحدود
bool isInvoiceDiscountAllowed(double discountPercent) =>
    discountPercent <= invoiceDiscountMax;

/// تطبيق stacking: خصم سطر أولاً ثم خصم فاتورة على المتبقي
double applyStacking({
  required double subtotal,
  required double lineDiscountPercent,
  required double invoiceDiscountPercent,
}) {
  final lineDisc = percentDiscount(subtotal, lineDiscountPercent);
  final netAfterLine = roundSar(subtotal - lineDisc);
  final invoiceDisc = percentDiscount(netAfterLine, invoiceDiscountPercent);
  final net = roundSar(netAfterLine - invoiceDisc);
  final vat = computeVat(net);
  return roundSar(net + vat);
}

// ============================================================================
// PRODUCT FACTORIES
// ============================================================================

/// P1: بيبسي 2L - 7.00 ر.س، مخزون=50، متتبع، خاضع للضريبة
Product createP1({int? stockQty}) => Product(
      id: 'p1-pepsi',
      storeId: 'store-1',
      name: 'بيبسي 2L',
      price: 7.00,
      stockQty: stockQty ?? 50,
      isActive: true,
      trackInventory: true,
      createdAt: DateTime(2025, 1, 1),
    );

/// P2: أرز بسمتي 5kg - 45.50 ر.س، مخزون=20، متتبع، خاضع للضريبة
Product createP2({int? stockQty}) => Product(
      id: 'p2-rice',
      storeId: 'store-1',
      name: 'أرز بسمتي 5kg',
      price: 45.50,
      stockQty: stockQty ?? 20,
      isActive: true,
      trackInventory: true,
      createdAt: DateTime(2025, 1, 1),
    );

/// P3: حليب المراعي 1L - 6.75 ر.س، مخزون=0، متتبع، خاضع للضريبة
Product createP3({int? stockQty}) => Product(
      id: 'p3-milk',
      storeId: 'store-1',
      name: 'حليب المراعي 1L',
      price: 6.75,
      stockQty: stockQty ?? 0,
      isActive: true,
      trackInventory: true,
      createdAt: DateTime(2025, 1, 1),
    );

/// P4: خدمة توصيل - 15.00 ر.س، غير متتبع، معفى من الضريبة
Product createP4() => Product(
      id: 'p4-delivery',
      storeId: 'store-1',
      name: 'خدمة توصيل',
      price: 15.00,
      stockQty: 0,
      isActive: true,
      trackInventory: false,
      createdAt: DateTime(2025, 1, 1),
    );

/// هل المنتج معفى من الضريبة؟
/// P4 (خدمة توصيل، trackInventory=false) معفى
bool isVatExempt(Product product) => !product.trackInventory;

// ============================================================================
// CUSTOMER DATA
// ============================================================================

/// C1: عميل VIP - حد ائتمان 5000
const c1Id = 'customer-c1-vip';
const c1Name = 'عميل VIP';
const c1CreditLimit = 5000.0;

/// C2: عميل عادي - حد ائتمان 500
const c2Id = 'customer-c2-regular';
const c2Name = 'عميل عادي';
const c2CreditLimit = 500.0;

// ============================================================================
// USER DATA
// ============================================================================

const uCashierId = 'user-cashier';
const uManagerId = 'user-manager';
const uAdminId = 'user-admin';

// ============================================================================
// DATABASE HELPERS
// ============================================================================

/// إنشاء قاعدة بيانات اختبار في الذاكرة
AppDatabase createTestDb() => AppDatabase.forTesting(NativeDatabase.memory());

/// إدراج منتج في قاعدة البيانات
Future<void> insertProduct(AppDatabase db, Product product) async {
  await db.productsDao.insertProduct(ProductsTableCompanion.insert(
    id: product.id,
    storeId: product.storeId,
    name: product.name,
    price: product.price,
    stockQty: Value(product.stockQty),
    isActive: Value(product.isActive),
    trackInventory: Value(product.trackInventory),
    createdAt: product.createdAt,
  ));
}

/// إدراج جميع المنتجات الاختبارية
Future<void> seedAllProducts(AppDatabase db) async {
  await insertProduct(db, createP1());
  await insertProduct(db, createP2());
  await insertProduct(db, createP3());
  await insertProduct(db, createP4());
}

/// إعداد SaleService مع mocks
SaleServiceTestSetup createSaleServiceSetup() {
  final db = createTestDb();
  final mockSync = MockSyncService();

  when(() => mockSync.enqueueCreate(
        tableName: any(named: 'tableName'),
        recordId: any(named: 'recordId'),
        data: any(named: 'data'),
        priority: any(named: 'priority'),
      )).thenAnswer((_) async => 'sync-id');

  when(() => mockSync.enqueueUpdate(
        tableName: any(named: 'tableName'),
        recordId: any(named: 'recordId'),
        changes: any(named: 'changes'),
        priority: any(named: 'priority'),
      )).thenAnswer((_) async => 'sync-id');

  final saleService = SaleService(db: db, syncService: mockSync);

  return SaleServiceTestSetup(
    db: db,
    syncService: mockSync,
    saleService: saleService,
  );
}

/// حاوية إعداد SaleService
class SaleServiceTestSetup {
  final AppDatabase db;
  final MockSyncService syncService;
  final SaleService saleService;

  SaleServiceTestSetup({
    required this.db,
    required this.syncService,
    required this.saleService,
  });

  Future<void> dispose() async {
    await db.close();
  }
}

/// إنشاء بيع مكتمل كامل (helper للاختبارات)
Future<String> createCompletedSale({
  required SaleService saleService,
  required List<PosCartItem> items,
  required double subtotal,
  required double discount,
  required double tax,
  required double total,
  String paymentMethod = 'cash',
  String? customerId,
  String? customerName,
  String storeId = 'store-1',
  String cashierId = 'cashier-1',
}) async {
  return saleService.createSale(
    storeId: storeId,
    cashierId: cashierId,
    items: items,
    subtotal: subtotal,
    discount: discount,
    tax: tax,
    total: total,
    paymentMethod: paymentMethod,
    customerId: customerId,
    customerName: customerName,
  );
}

// ============================================================================
// INVOICE CALCULATION (Pure, deterministic)
// ============================================================================

/// نتيجة حساب فاتورة
class InvoiceCalcResult {
  final double subtotal;
  final double discount;
  final double net;
  final double vat;
  final double total;

  const InvoiceCalcResult({
    required this.subtotal,
    required this.discount,
    required this.net,
    required this.vat,
    required this.total,
  });
}

/// حساب فاتورة كاملة
/// discount يُطبّق على الـ subtotal، ثم VAT على الـ net
InvoiceCalcResult computeInvoice({
  required double subtotal,
  required double discountAmount,
  bool vatExempt = false,
}) {
  final capped = capDiscount(discountAmount, subtotal);
  final net = roundSar(subtotal - capped);
  final vat = computeVat(net, exempt: vatExempt);
  final total = roundSar(net + vat);
  return InvoiceCalcResult(
    subtotal: subtotal,
    discount: capped,
    net: net,
    vat: vat,
    total: total,
  );
}

/// حساب فاتورة مع عناصر مختلطة (خاضعة + معفاة)
MixedInvoiceResult computeMixedInvoice({
  required double taxableSubtotal,
  required double exemptSubtotal,
  required double discountOnTaxable,
}) {
  final taxableNet = roundSar(taxableSubtotal - capDiscount(discountOnTaxable, taxableSubtotal));
  final vat = computeVat(taxableNet);
  final total = roundSar(taxableNet + vat + exemptSubtotal);
  return MixedInvoiceResult(
    taxableSubtotal: taxableSubtotal,
    exemptSubtotal: exemptSubtotal,
    taxableNet: taxableNet,
    vat: vat,
    total: total,
  );
}

/// نتيجة فاتورة مختلطة
class MixedInvoiceResult {
  final double taxableSubtotal;
  final double exemptSubtotal;
  final double taxableNet;
  final double vat;
  final double total;

  const MixedInvoiceResult({
    required this.taxableSubtotal,
    required this.exemptSubtotal,
    required this.taxableNet,
    required this.vat,
    required this.total,
  });
}
