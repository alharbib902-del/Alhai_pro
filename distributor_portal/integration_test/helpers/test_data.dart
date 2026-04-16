/// Test data constants and sample records for distributor portal integration tests.
///
/// Uses plain [Map<String, dynamic>] literals instead of model class instances
/// to keep integration tests self-contained and free from lib/ imports.
///
/// Arabic-first data mirrors realistic distributor onboarding and order flows
/// in the Saudi market.
library;

// ============================================================================
// DISTRIBUTOR IDENTITY
// ============================================================================

/// Test distributor user ID (maps to auth.uid).
const kTestDistributorId = 'dist-001';

/// Test organization ID.
const kTestOrgId = 'org-001';

/// Test organization name (Arabic).
const kTestOrgName = 'شركة الأمانة للتوزيع';

// ============================================================================
// ORDER
// ============================================================================

/// Test order ID.
const kTestOrderId = 'order-001';

/// Distributor-side order statuses in lifecycle order.
///
/// These match the status values stored in the database `distributor_orders`
/// table and used by [ordersProvider]'s status filter parameter.
const kOrderStatuses = [
  'sent',
  'approved',
  'preparing',
  'packed',
  'shipped',
  'delivered',
  'rejected',
];

/// Sample distributor order as a JSON-like map.
const kSampleOrder = <String, dynamic>{
  'id': kTestOrderId,
  'org_id': kTestOrgId,
  'store_id': kTestStoreId,
  'store_name': 'بقالة النور',
  'status': 'sent',
  'total_before_vat': 1500.0,
  'vat_amount': 225.0,
  'total': 1725.0,
  'discount_amount': 0.0,
  'item_count': 3,
  'notes': 'طلب عاجل - التوصيل قبل الظهر',
  'created_at': '2026-04-15T08:30:00Z',
  'updated_at': '2026-04-15T08:30:00Z',
};

/// Sample order items.
const kSampleOrderItems = <Map<String, dynamic>>[
  {
    'id': 'oi-001',
    'order_id': kTestOrderId,
    'product_id': kTestProductId,
    'product_name': 'حليب السعودية كامل الدسم 1 لتر',
    'sku': 'MILK-001',
    'quantity': 24,
    'unit_price': 5.50,
    'total': 132.0,
  },
  {
    'id': 'oi-002',
    'order_id': kTestOrderId,
    'product_id': 'prod-002',
    'product_name': 'عصير المراعي برتقال 1.5 لتر',
    'sku': 'JUICE-001',
    'quantity': 12,
    'unit_price': 7.25,
    'total': 87.0,
  },
  {
    'id': 'oi-003',
    'order_id': kTestOrderId,
    'product_id': 'prod-003',
    'product_name': 'أرز بسمتي أبو كأس 5 كيلو',
    'sku': 'RICE-001',
    'quantity': 48,
    'unit_price': 26.75,
    'total': 1284.0,
  },
];

// ============================================================================
// INVOICE
// ============================================================================

/// Test invoice ID.
const kTestInvoiceId = 'inv-001';

/// Invoice statuses in lifecycle order.
const kInvoiceStatuses = [
  'draft',
  'issued',
  'paid',
  'cancelled',
];

/// Sample distributor invoice as a JSON-like map.
const kSampleInvoice = <String, dynamic>{
  'id': kTestInvoiceId,
  'org_id': kTestOrgId,
  'order_id': kTestOrderId,
  'store_id': kTestStoreId,
  'invoice_number': 'INV-2026-00001',
  'status': 'draft',
  'subtotal': 1500.0,
  'vat_rate': 0.15,
  'vat_amount': 225.0,
  'total': 1725.0,
  'qr_code': 'ARXYZ123ZATCAQR==',
  'zatca_hash': 'abc123def456',
  'issued_at': '2026-04-15T09:00:00Z',
  'due_date': '2026-05-15',
  'created_at': '2026-04-15T08:45:00Z',
};

// ============================================================================
// PRODUCT
// ============================================================================

/// Test product ID.
const kTestProductId = 'prod-001';

/// Sample distributor product as a JSON-like map.
const kSampleProduct = <String, dynamic>{
  'id': kTestProductId,
  'org_id': kTestOrgId,
  'name': 'حليب السعودية كامل الدسم 1 لتر',
  'name_en': 'Almarai Full Fat Milk 1L',
  'sku': 'MILK-001',
  'barcode': '6281000000001',
  'unit_price': 5.50,
  'cost_price': 4.00,
  'unit': 'حبة',
  'category': 'ألبان',
  'is_active': true,
  'stock_qty': 500,
  'min_qty': 50,
  'created_at': '2026-01-01T00:00:00Z',
};

/// Second product for list tests.
const kSampleProduct2 = <String, dynamic>{
  'id': 'prod-002',
  'org_id': kTestOrgId,
  'name': 'عصير المراعي برتقال 1.5 لتر',
  'name_en': 'Almarai Orange Juice 1.5L',
  'sku': 'JUICE-001',
  'barcode': '6281000000002',
  'unit_price': 7.25,
  'cost_price': 5.50,
  'unit': 'حبة',
  'category': 'عصائر',
  'is_active': true,
  'stock_qty': 200,
  'min_qty': 20,
  'created_at': '2026-01-01T00:00:00Z',
};

// ============================================================================
// PRICING TIER
// ============================================================================

/// Test pricing tier ID.
const kTestTierId = 'tier-001';

/// Sample pricing tier.
const kSampleTier = <String, dynamic>{
  'id': kTestTierId,
  'org_id': kTestOrgId,
  'name': 'ذهبي',
  'name_en': 'Gold',
  'discount_percent': 10.0,
  'min_order_amount': 5000.0,
  'is_default': false,
  'is_active': true,
  'created_at': '2026-01-15T00:00:00Z',
};

/// Second pricing tier.
const kSampleTier2 = <String, dynamic>{
  'id': 'tier-002',
  'org_id': kTestOrgId,
  'name': 'فضي',
  'name_en': 'Silver',
  'discount_percent': 5.0,
  'min_order_amount': 2000.0,
  'is_default': true,
  'is_active': true,
  'created_at': '2026-01-15T00:00:00Z',
};

// ============================================================================
// STORE
// ============================================================================

/// Test store ID.
const kTestStoreId = 'store-001';

/// Sample store assignment.
const kSampleStoreAssignment = <String, dynamic>{
  'id': 'assign-001',
  'store_id': kTestStoreId,
  'store_name': 'بقالة النور',
  'tier_id': kTestTierId,
  'tier_name': 'ذهبي',
  'assigned_at': '2026-03-01T00:00:00Z',
};

// ============================================================================
// ADMIN / PENDING DISTRIBUTOR
// ============================================================================

/// Sample pending distributor for admin review.
const kSamplePendingDistributor = <String, dynamic>{
  'id': 'org-pending-001',
  'name': 'شركة المستقبل للتوزيع',
  'name_en': 'Future Distribution Co.',
  'phone': '0501234567',
  'email': 'info@future-dist.sa',
  'city': 'الرياض',
  'address': 'حي العليا، طريق الملك فهد',
  'commercial_reg': '1010234567',
  'tax_number': '300123456700003',
  'status': 'pending_review',
  'owner_id': 'user-pending-001',
  'company_type': 'distributor',
  'terms_accepted_at': '2026-04-14T10:00:00Z',
  'created_at': '2026-04-14T10:00:00Z',
};

/// Sample admin notification.
const kSampleNotification = <String, dynamic>{
  'id': 'notif-001',
  'type': 'new_distributor',
  'title': 'طلب تسجيل موزع جديد',
  'message': 'شركة المستقبل للتوزيع قدمت طلب تسجيل',
  'related_id': 'org-pending-001',
  'related_type': 'organization',
  'is_read': false,
  'read_by': null,
  'read_at': null,
  'created_at': '2026-04-14T10:05:00Z',
};

/// Sample document for review.
const kSampleDocument = <String, dynamic>{
  'id': 'doc-001',
  'org_id': 'org-pending-001',
  'type': 'commercial_registration',
  'file_url': 'https://storage.example.com/docs/cr-001.pdf',
  'status': 'pending',
  'uploaded_at': '2026-04-14T10:01:00Z',
  'reviewed_at': null,
  'reviewed_by': null,
  'rejection_reason': null,
};

// ============================================================================
// AUDIT
// ============================================================================

/// Sample price audit entry.
const kSampleAuditEntry = <String, dynamic>{
  'id': 'audit-001',
  'org_id': kTestOrgId,
  'product_id': kTestProductId,
  'product_name': 'حليب السعودية كامل الدسم 1 لتر',
  'field_changed': 'unit_price',
  'old_value': '5.00',
  'new_value': '5.50',
  'changed_by': kTestDistributorId,
  'changed_at': '2026-04-10T14:30:00Z',
};
