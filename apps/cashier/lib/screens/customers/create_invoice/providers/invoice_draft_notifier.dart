/// Invoice Draft Notifier — حالة مسودة الفاتورة (عميل + بنود + خصم + شروط دفع)
///
/// يحمل تكوين الفاتورة بصيغة ثابتة (immutable) ويُعرض عبر
/// [invoiceDraftProvider] لتتابعه الـ widgets بدل `setState` المتعدّدة.
///
/// C-4 Stage B: أسعار البنود هنا بوحدة SAR (double). عند الحفظ في
/// قواعد البيانات يجب التحويل إلى cents (int) وفق قواعد
/// [invoice_service] — ZATCA QR يُولَّد تلقائياً في
/// `upsertInvoice` وإلا يُرفع `ZatcaComplianceException`.
library;

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_it/get_it.dart';
import 'package:alhai_database/alhai_database.dart';

/// بند في مسودة الفاتورة (price بوحدة SAR)
@immutable
class InvoiceDraftItem {
  final String productId;
  final String productName;

  /// السعر بوحدة SAR (double). مصدره `product.price / 100.0`.
  final double price;
  final int qty;

  const InvoiceDraftItem({
    required this.productId,
    required this.productName,
    required this.price,
    required this.qty,
  });

  double get lineTotal => price * qty;

  InvoiceDraftItem copyWithQty(int newQty) => InvoiceDraftItem(
    productId: productId,
    productName: productName,
    price: price,
    qty: newQty,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is InvoiceDraftItem &&
          runtimeType == other.runtimeType &&
          productId == other.productId &&
          productName == other.productName &&
          price == other.price &&
          qty == other.qty;

  @override
  int get hashCode => Object.hash(productId, productName, price, qty);
}

/// خيارات شروط الدفع (UI فقط، محفوظ مع الفاتورة في
/// حقول منفصلة لاحقاً عند دمج invoice_service).
enum PaymentTerm {
  /// الاستحقاق فوراً (cash / credit on pickup)
  immediate,

  /// صافي 15 يوم
  net15,

  /// صافي 30 يوم
  net30,

  /// صافي 60 يوم
  net60,
}

/// حالة مسودة الفاتورة الكاملة
@immutable
class InvoiceDraftState {
  final CustomersTableData? selectedCustomer;
  final List<InvoiceDraftItem> items;
  final double discount;
  final PaymentTerm paymentTerm;
  final DateTime? dueDate;

  /// نسبة VAT المُطبَّقة على الفاتورة.
  ///
  /// P2 #3: سابقاً كانت ثابتة `0.15` (const). الآن تُقرأ من
  /// `stores.tax_rate` عبر [InvoiceDraftNotifier.loadTaxRate] عند فتح
  /// الشاشة. الـ default 0.15 يبقى كاحتياطي حتى ينجح التحميل، وذلك
  /// للحفاظ على سلوك آمن إذا فشل جلب المتجر.
  ///
  /// ملاحظة للمستقبل: عندما تصبح إعدادات الضريبة مركّبة (tax_settings /
  /// معدّلات متعددة / exemptions)، حوّل الحساب إلى service مختص بدل
  /// الاعتماد على حقل double مُفرد هنا.
  final double taxRate;

  /// القيمة الافتراضية — VAT السعودية 15%. تُستخدم كـ fallback فقط.
  static const double defaultTaxRate = 0.15;

  const InvoiceDraftState({
    this.selectedCustomer,
    this.items = const [],
    this.discount = 0,
    this.paymentTerm = PaymentTerm.immediate,
    this.dueDate,
    this.taxRate = defaultTaxRate,
  });

  /// حالة ابتدائية فارغة
  factory InvoiceDraftState.empty() => const InvoiceDraftState();

  // ============================================================================
  // الحسابات المشتقة (مُستخدمة في invoice_summary widget)
  // ============================================================================

  double get subtotal =>
      items.fold<double>(0, (sum, i) => sum + i.lineTotal);

  double get taxableAmount {
    final v = subtotal - discount;
    return v > 0 ? v : 0;
  }

  double get tax => taxableAmount * taxRate;

  double get total => taxableAmount + tax;

  bool get canSubmit => items.isNotEmpty && selectedCustomer != null;

  InvoiceDraftState copyWith({
    CustomersTableData? selectedCustomer,
    bool clearCustomer = false,
    List<InvoiceDraftItem>? items,
    double? discount,
    PaymentTerm? paymentTerm,
    DateTime? dueDate,
    bool clearDueDate = false,
    double? taxRate,
  }) => InvoiceDraftState(
    selectedCustomer: clearCustomer
        ? null
        : (selectedCustomer ?? this.selectedCustomer),
    items: items ?? this.items,
    discount: discount ?? this.discount,
    paymentTerm: paymentTerm ?? this.paymentTerm,
    dueDate: clearDueDate ? null : (dueDate ?? this.dueDate),
    taxRate: taxRate ?? this.taxRate,
  );
}

/// Notifier لإدارة مسودة الفاتورة. يحلّ محلّ ~10 `setState` متعلّقة بالحالة
/// ويسمح للـ widgets المنفصلة بالاشتراك فقط بما يهمّها.
class InvoiceDraftNotifier extends StateNotifier<InvoiceDraftState> {
  InvoiceDraftNotifier() : super(InvoiceDraftState.empty());

  // --- Customer ---------------------------------------------------------------

  void selectCustomer(CustomersTableData customer) =>
      state = state.copyWith(selectedCustomer: customer);

  void clearCustomer() => state = state.copyWith(clearCustomer: true);

  // --- Items ------------------------------------------------------------------

  /// إضافة منتج جديد. إن كان البند موجوداً يُزاد عدده بواحد.
  void addProduct({
    required String productId,
    required String productName,
    required double priceSar,
  }) {
    final existing = state.items.indexWhere((i) => i.productId == productId);
    final newItems = List<InvoiceDraftItem>.from(state.items);
    if (existing >= 0) {
      newItems[existing] = newItems[existing].copyWithQty(
        newItems[existing].qty + 1,
      );
    } else {
      newItems.add(
        InvoiceDraftItem(
          productId: productId,
          productName: productName,
          price: priceSar,
          qty: 1,
        ),
      );
    }
    state = state.copyWith(items: newItems);
  }

  void removeItemAt(int index) {
    if (index < 0 || index >= state.items.length) return;
    final newItems = List<InvoiceDraftItem>.from(state.items)..removeAt(index);
    state = state.copyWith(items: newItems);
  }

  void updateQty(int index, int qty) {
    if (index < 0 || index >= state.items.length) return;
    if (qty <= 0) {
      removeItemAt(index);
      return;
    }
    final newItems = List<InvoiceDraftItem>.from(state.items);
    newItems[index] = newItems[index].copyWithQty(qty);
    state = state.copyWith(items: newItems);
  }

  // --- Discount ---------------------------------------------------------------

  void setDiscount(double discount) =>
      state = state.copyWith(discount: discount < 0 ? 0 : discount);

  // --- Payment terms ----------------------------------------------------------

  void setPaymentTerm(PaymentTerm term) {
    // عند تغيير الشروط نحسب dueDate تلقائياً (مع إمكانية التخصيص لاحقاً).
    //
    // P1 #7: لا نُعيد حساب dueDate إذا كان نفس الـ term محدداً مسبقاً وكان
    // للمستخدم قيمة يدوية — الاستدعاءات المكررة لنفس الـ term كانت تُلغي
    // تعديل المستخدم. لكن عند تغيير الـ term فعلياً نحسب قيمة جديدة.
    if (state.paymentTerm == term && state.dueDate != null) {
      // Same term, user has a (possibly custom) date — leave state alone.
      return;
    }
    final now = DateTime.now();
    DateTime? due;
    switch (term) {
      case PaymentTerm.immediate:
        due = null;
        break;
      case PaymentTerm.net15:
        due = now.add(const Duration(days: 15));
        break;
      case PaymentTerm.net30:
        due = now.add(const Duration(days: 30));
        break;
      case PaymentTerm.net60:
        due = now.add(const Duration(days: 60));
        break;
    }
    state = state.copyWith(
      paymentTerm: term,
      dueDate: due,
      clearDueDate: due == null,
    );
  }

  void setDueDate(DateTime date) => state = state.copyWith(dueDate: date);

  // --- Tax rate ---------------------------------------------------------------

  /// P2 #3: تحميل نسبة الضريبة الفعلية من جدول الإعدادات.
  ///
  /// القيمة تُخزَّن في `settings` بـ `key='tax_rate'` بصيغتين محتملتين:
  ///  - basis points (`1500` ⇒ 15.00%) — الصيغة القانونية
  ///  - decimal string (`15` أو `15.5`) — إرث (legacy)
  ///
  /// نُعيد القيمة كنسبة كسرية (0.15 للـ 15%) لتتوافق مع حساب `tax`
  /// getter. إذا لم يُعثر على إعداد، يُحتفظ بـ default (`0.15`)
  /// كاحتياطي آمن. مكتوب fire-and-forget لتتزامن مع initState الشاشة.
  ///
  /// TODO(future): عندما يصبح tax_settings جدولاً مستقلاً مع
  /// multi-rate / exemptions، استبدل هذه القراءة بخدمة مختصة.
  Future<void> loadTaxRate(String storeId) async {
    try {
      final db = GetIt.I<AppDatabase>();
      // Filter by storeId only, then pick the `tax_rate` row in Dart —
      // matches the pattern used in settings screens (tax_settings_screen.
      // _loadSettings) and sidesteps Drift's composite-where boilerplate.
      final rows = await (db.select(db.settingsTable)
            ..where((s) => s.storeId.equals(storeId)))
          .get();
      final taxRow = rows.where((s) => s.key == 'tax_rate').toList();
      if (taxRow.isEmpty) return;
      final raw = taxRow.first.value.trim();
      if (raw.isEmpty) return;
      double? percent;
      if (!raw.contains('.')) {
        // Integer → basis points (1500 → 15.00).
        final bps = int.tryParse(raw);
        if (bps != null) percent = bps / 100.0;
      } else {
        // Legacy decimal string → already a percent.
        percent = double.tryParse(raw);
      }
      if (percent == null || !percent.isFinite) return;
      if (percent < 0 || percent > 100) return; // ZATCA bounds.
      // Store as a fraction (0.15 for 15%) to match the tax getter below.
      state = state.copyWith(taxRate: percent / 100.0);
    } catch (_) {
      // Keep the default — tax computation stays correct for the SA market
      // even if the DB lookup momentarily fails.
    }
  }

  // --- Reset ------------------------------------------------------------------

  /// مسح الفاتورة بعد نجاح الإنهاء. يحافظ على PaymentTerm الابتدائي.
  ///
  /// P2 #3: نحافظ على `taxRate` الحالية — العودة إلى default 0.15 بعد
  /// reset ستُظهر ضريبة خاطئة إذا كان المتجر يُشغّل نسبة مختلفة.
  void reset() => state = InvoiceDraftState(taxRate: state.taxRate);
}

/// Provider مسودة الفاتورة — scoped per screen لتجنّب تسرّب الحالة بين شاشات.
final invoiceDraftProvider =
    StateNotifierProvider.autoDispose<
      InvoiceDraftNotifier,
      InvoiceDraftState
    >((ref) => InvoiceDraftNotifier());
