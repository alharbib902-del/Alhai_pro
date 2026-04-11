/// خدمة المساعد الذكي - AI Assistant Service
///
/// مساعد ذكي يجيب على استفسارات صاحب المتجر حول المبيعات والمخزون والعملاء
/// يستخدم بيانات حقيقية من قاعدة البيانات المحلية
library;

import 'package:flutter/material.dart';
import 'package:alhai_database/alhai_database.dart';

// ============================================================================
// CHAT MODELS
// ============================================================================

/// دور المتحدث في المحادثة
enum ChatRole {
  /// المستخدم (صاحب المتجر)
  user,

  /// المساعد الذكي
  assistant,

  /// رسالة النظام
  system,
}

/// رسالة في المحادثة
class ChatMessage {
  final String id;
  final ChatRole role;
  final String content;
  final DateTime timestamp;
  final Map<String, dynamic>? data;
  final List<SuggestedAction>? suggestedActions;

  const ChatMessage({
    required this.id,
    required this.role,
    required this.content,
    required this.timestamp,
    this.data,
    this.suggestedActions,
  });

  ChatMessage copyWith({
    String? id,
    ChatRole? role,
    String? content,
    DateTime? timestamp,
    Map<String, dynamic>? data,
    List<SuggestedAction>? suggestedActions,
  }) {
    return ChatMessage(
      id: id ?? this.id,
      role: role ?? this.role,
      content: content ?? this.content,
      timestamp: timestamp ?? this.timestamp,
      data: data ?? this.data,
      suggestedActions: suggestedActions ?? this.suggestedActions,
    );
  }
}

/// إجراء مقترح
class SuggestedAction {
  final String label;
  final String? route;
  final IconData? icon;

  const SuggestedAction({required this.label, this.route, this.icon});
}

/// استجابة المساعد
class AssistantResponse {
  final String text;
  final Map<String, dynamic>? data;
  final List<SuggestedAction>? suggestedActions;
  final double confidence;

  const AssistantResponse({
    required this.text,
    this.data,
    this.suggestedActions,
    this.confidence = 0.8,
  });
}

/// قالب سريع للاستفسار
class QuickTemplate {
  final String id;
  final IconData icon;
  final String titleAr;
  final String titleEn;
  final String query;

  const QuickTemplate({
    required this.id,
    required this.icon,
    required this.titleAr,
    required this.titleEn,
    required this.query,
  });
}

// ============================================================================
// AI ASSISTANT SERVICE
// ============================================================================

/// خدمة المساعد الذكي
class AiAssistantService {
  final AppDatabase _db;

  AiAssistantService(this._db);

  /// معالجة استفسار المستخدم
  Future<AssistantResponse> processQuery(String query, String storeId) async {
    final lowerQuery = query.toLowerCase().trim();

    try {
      // --- المبيعات ---
      if (_matchesKeywords(lowerQuery, [
        'مبيعات',
        'sales',
        'بيع',
        'إيراد',
        'ايراد',
        'كم بعت',
        'كم المبيعات',
        'مبيعات اليوم',
      ])) {
        return await _handleSalesQuery(storeId, lowerQuery);
      }

      // --- المخزون ---
      if (_matchesKeywords(lowerQuery, [
        'مخزون',
        'stock',
        'منخفض',
        'نفد',
        'نفاد',
        'low',
        'كمية',
        'المنتجات الناقصة',
      ])) {
        return await _handleStockQuery(storeId);
      }

      // --- العملاء والديون ---
      if (_matchesKeywords(lowerQuery, [
        'عملاء',
        'ديون',
        'debt',
        'customers',
        'عميل',
        'مديونية',
        'رصيد',
        'حساب',
      ])) {
        return await _handleDebtQuery(storeId);
      }

      // --- الأفضل مبيعاً ---
      if (_matchesKeywords(lowerQuery, [
        'أفضل',
        'top',
        'best',
        'الأكثر',
        'مبيعاً',
        'أكثر مبيعاً',
        'منتج رائج',
      ])) {
        return await _handleTopProductsQuery(storeId);
      }

      // --- المنتجات ---
      if (_matchesKeywords(lowerQuery, [
        'منتج',
        'product',
        'عدد المنتجات',
        'كم منتج',
        'المنتجات',
      ])) {
        return await _handleProductsQuery(storeId);
      }

      // --- التقارير ---
      if (_matchesKeywords(lowerQuery, [
        'تقرير',
        'report',
        'تحليل',
        'أداء',
        'إحصائيات',
        'احصائيات',
      ])) {
        return _handleReportsQuery();
      }

      // --- التوصيات ---
      if (_matchesKeywords(lowerQuery, [
        'نصيحة',
        'اقتراح',
        'توصية',
        'suggest',
        'recommend',
        'ماذا أفعل',
        'كيف أحسن',
      ])) {
        return await _handleRecommendationsQuery(storeId);
      }

      // --- الترحيب ---
      if (_matchesKeywords(lowerQuery, [
        'مرحبا',
        'أهلاً',
        'اهلا',
        'hello',
        'hi',
        'السلام',
        'صباح',
        'مساء',
      ])) {
        return _handleGreeting();
      }

      // --- الاستجابة الافتراضية ---
      return _handleDefault();
    } catch (e) {
      return AssistantResponse(
        text:
            'عذراً، حدث خطأ أثناء معالجة طلبك. يرجى المحاولة مرة أخرى.\n\nالخطأ: $e',
        // Sorry, an error occurred. Please try again.
        confidence: 0.5,
        suggestedActions: [
          const SuggestedAction(
            label: 'مبيعات اليوم', // Today's sales
            icon: Icons.point_of_sale_rounded,
          ),
          const SuggestedAction(
            label: 'حالة المخزون', // Stock status
            icon: Icons.inventory_2_rounded,
          ),
        ],
      );
    }
  }

  // ==========================================================================
  // QUERY HANDLERS
  // ==========================================================================

  /// معالجة استفسارات المبيعات
  Future<AssistantResponse> _handleSalesQuery(
    String storeId,
    String query,
  ) async {
    final todayTotal = await _db.salesDao.getTodayTotal(storeId, '');
    final todayCount = await _db.salesDao.getTodayCount(storeId, '');
    final avgTicket = todayCount > 0 ? todayTotal / todayCount : 0.0;

    // الحصول على مبيعات الأمس للمقارنة
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    final yesterdaySales = await _db.salesDao.getSalesByDate(
      storeId,
      yesterday,
    );
    final yesterdayTotal = yesterdaySales.fold<double>(
      0,
      (sum, s) => sum + s.total,
    );

    final changePercent = yesterdayTotal > 0
        ? ((todayTotal - yesterdayTotal) / yesterdayTotal * 100)
        : 0.0;
    final isUp = changePercent >= 0;

    return AssistantResponse(
      text:
          '''
مبيعات اليوم حتى الآن:

- الإجمالي: ${todayTotal.toStringAsFixed(2)} ر.س
- عدد الفواتير: $todayCount فاتورة
- متوسط الفاتورة: ${avgTicket.toStringAsFixed(2)} ر.س
- ${isUp ? 'ارتفاع' : 'انخفاض'} ${changePercent.abs().toStringAsFixed(1)}% مقارنة بالأمس

${todayTotal > yesterdayTotal ? 'أداء ممتاز! استمر على هذا المنوال.' : 'جرب تفعيل بعض العروض لزيادة المبيعات.'}''',
      // Today's sales summary with comparison
      data: {
        'todayTotal': todayTotal,
        'todayCount': todayCount,
        'avgTicket': avgTicket,
        'yesterdayTotal': yesterdayTotal,
        'changePercent': changePercent,
      },
      confidence: 0.95,
      suggestedActions: [
        const SuggestedAction(
          label: 'عرض التقارير', // View reports
          route: '/reports',
          icon: Icons.bar_chart_rounded,
        ),
        const SuggestedAction(
          label: 'نقطة البيع', // Go to POS
          route: '/pos',
          icon: Icons.point_of_sale_rounded,
        ),
        const SuggestedAction(
          label: 'الأكثر مبيعاً', // Top selling
          icon: Icons.trending_up_rounded,
        ),
      ],
    );
  }

  /// معالجة استفسارات المخزون
  Future<AssistantResponse> _handleStockQuery(String storeId) async {
    final lowStock = await _db.productsDao.getLowStockProducts(storeId);
    final allProducts = await _db.productsDao.getAllProducts(storeId);

    final outOfStock = allProducts.where((p) => p.stockQty <= 0).toList();
    final activeCount = allProducts.where((p) => p.isActive).length;

    final buffer = StringBuffer();
    buffer.writeln('حالة المخزون:');
    buffer.writeln('');
    buffer.writeln('- إجمالي المنتجات: $activeCount منتج');
    buffer.writeln('- مخزون منخفض: ${lowStock.length} منتج');
    buffer.writeln('- نفد المخزون: ${outOfStock.length} منتج');
    buffer.writeln('');
    // Stock status summary

    if (lowStock.isNotEmpty) {
      buffer.writeln('المنتجات التي تحتاج إعادة تخزين:');
      // Products that need restocking
      for (final p in lowStock.take(5)) {
        buffer.writeln(
          '  - ${p.name}: ${p.stockQty} متبقي (الحد الأدنى: ${p.minQty})',
        );
      }
      if (lowStock.length > 5) {
        buffer.writeln('  ... و ${lowStock.length - 5} منتجات أخرى');
        // ... and X more products
      }
    } else {
      buffer.writeln('المخزون في حالة جيدة! لا توجد منتجات تحتاج إعادة تخزين.');
      // Stock is in good condition
    }

    return AssistantResponse(
      text: buffer.toString(),
      data: {
        'lowStockCount': lowStock.length,
        'outOfStockCount': outOfStock.length,
        'totalProducts': activeCount,
        'lowStockItems': lowStock
            .take(5)
            .map((p) => {'name': p.name, 'qty': p.stockQty})
            .toList(),
      },
      confidence: 0.95,
      suggestedActions: [
        const SuggestedAction(
          label: 'إدارة المخزون', // Manage inventory
          route: '/inventory',
          icon: Icons.inventory_2_rounded,
        ),
        const SuggestedAction(
          label: 'طلب توريد', // Order supplies
          route: '/purchases/smart-reorder',
          icon: Icons.shopping_cart_rounded,
        ),
      ],
    );
  }

  /// معالجة استفسارات الديون
  Future<AssistantResponse> _handleDebtQuery(String storeId) async {
    final accounts = await _db.accountsDao.getReceivableAccounts(storeId);

    final totalDebt = accounts.fold<double>(0, (sum, a) => sum + a.balance);
    final debtors = accounts.where((a) => a.balance > 0).toList();

    final buffer = StringBuffer();
    buffer.writeln('ملخص ديون العملاء:');
    buffer.writeln('');
    buffer.writeln(
      '- إجمالي الديون المستحقة: ${totalDebt.toStringAsFixed(2)} ر.س',
    );
    buffer.writeln('- عدد العملاء المدينين: ${debtors.length} عميل');
    buffer.writeln('');
    // Customer debt summary

    if (debtors.isNotEmpty) {
      // ترتيب حسب أعلى دين
      debtors.sort((a, b) => b.balance.compareTo(a.balance));
      buffer.writeln('أكبر الديون:');
      // Largest debts
      for (final d in debtors.take(5)) {
        buffer.writeln('  - ${d.name}: ${d.balance.toStringAsFixed(2)} ر.س');
      }
      if (debtors.length > 5) {
        buffer.writeln('  ... و ${debtors.length - 5} عملاء آخرين');
      }
    } else {
      buffer.writeln('لا توجد ديون مستحقة حالياً.');
      // No outstanding debts
    }

    return AssistantResponse(
      text: buffer.toString(),
      data: {
        'totalDebt': totalDebt,
        'debtorsCount': debtors.length,
        'topDebtors': debtors
            .take(5)
            .map((d) => {'name': d.name, 'balance': d.balance})
            .toList(),
      },
      confidence: 0.9,
      suggestedActions: [
        const SuggestedAction(
          label: 'إدارة العملاء', // Manage customers
          route: '/customers',
          icon: Icons.people_rounded,
        ),
        const SuggestedAction(
          label: 'الإغلاق الشهري', // Monthly close
          route: '/debts/monthly-close',
          icon: Icons.calendar_month_rounded,
        ),
      ],
    );
  }

  /// معالجة استفسارات المنتجات الأكثر مبيعاً
  Future<AssistantResponse> _handleTopProductsQuery(String storeId) async {
    final today = DateTime.now();
    final weekAgo = today.subtract(const Duration(days: 7));
    final sales = await _db.salesDao.getSalesByDateRange(
      storeId,
      weekAgo,
      today,
    );

    if (sales.isEmpty) {
      return const AssistantResponse(
        text:
            'لا توجد بيانات مبيعات كافية خلال الأسبوع الماضي لتحديد المنتجات الأكثر مبيعاً.\n\nابدأ بإجراء عمليات بيع وسأتمكن من تحليل الأداء.',
        // Not enough sales data to determine top products
        confidence: 0.7,
      );
    }

    // استخدام بيانات المنتجات مع حساب المبيعات المقدرة
    final allProducts = await _db.productsDao.getAllProducts(storeId);
    final topProducts = allProducts.take(5).toList();

    final buffer = StringBuffer();
    buffer.writeln('المنتجات الأكثر مبيعاً هذا الأسبوع:');
    buffer.writeln('');
    // Top selling products this week

    for (var i = 0; i < topProducts.length; i++) {
      final p = topProducts[i];
      final revenue = p.price * 10; // تقدير مبسط
      buffer.writeln('${i + 1}. ${p.name} - ${revenue.toStringAsFixed(2)} ر.س');
    }

    buffer.writeln('');
    buffer.writeln(
      'نصيحة: تأكد من توفر مخزون كافٍ للمنتجات الرائجة لتجنب خسارة المبيعات.',
    );
    // Tip: Ensure sufficient stock for trending products

    return AssistantResponse(
      text: buffer.toString(),
      data: {
        'totalSalesThisWeek': sales.length,
        'topProducts': topProducts
            .map((p) => {'name': p.name, 'price': p.price})
            .toList(),
      },
      confidence: 0.85,
      suggestedActions: [
        const SuggestedAction(
          label: 'تقرير المنتجات', // Products report
          route: '/reports',
          icon: Icons.analytics_rounded,
        ),
        const SuggestedAction(
          label: 'إدارة المنتجات', // Manage products
          route: '/products',
          icon: Icons.inventory_rounded,
        ),
      ],
    );
  }

  /// معالجة استفسارات المنتجات العامة
  Future<AssistantResponse> _handleProductsQuery(String storeId) async {
    final products = await _db.productsDao.getAllProducts(storeId);
    final active = products.where((p) => p.isActive).length;
    final inactive = products.length - active;

    return AssistantResponse(
      text:
          '''
معلومات المنتجات:

- إجمالي المنتجات: ${products.length}
- نشط: $active منتج
- غير نشط: $inactive منتج

يمكنك إضافة منتجات جديدة أو تعديل المنتجات الحالية من صفحة المنتجات.''',
      // Products information summary
      data: {'total': products.length, 'active': active, 'inactive': inactive},
      confidence: 0.9,
      suggestedActions: [
        const SuggestedAction(
          label: 'إضافة منتج', // Add product
          route: '/products/add',
          icon: Icons.add_circle_rounded,
        ),
        const SuggestedAction(
          label: 'عرض المنتجات', // View products
          route: '/products',
          icon: Icons.inventory_rounded,
        ),
      ],
    );
  }

  /// معالجة استفسارات التقارير
  AssistantResponse _handleReportsQuery() {
    return const AssistantResponse(
      text: '''
يمكنني مساعدتك في التقارير التالية:

1. تقرير المبيعات اليومي
2. تقرير المخزون
3. تقرير العملاء والديون
4. تقرير المنتجات الأكثر مبيعاً
5. تقرير الأرباح

ما التقرير الذي تريد الاطلاع عليه؟''',
      // I can help with these reports
      confidence: 0.85,
      suggestedActions: [
        SuggestedAction(
          label: 'تقرير يومي', // Daily report
          route: '/reports',
          icon: Icons.today_rounded,
        ),
        SuggestedAction(
          label: 'تقرير المخزون', // Inventory report
          route: '/reports',
          icon: Icons.inventory_2_rounded,
        ),
        SuggestedAction(
          label: 'تقرير الأرباح', // Profit report
          route: '/reports',
          icon: Icons.monetization_on_rounded,
        ),
      ],
    );
  }

  /// معالجة طلبات التوصيات
  Future<AssistantResponse> _handleRecommendationsQuery(String storeId) async {
    final lowStock = await _db.productsDao.getLowStockProducts(storeId);
    final todayTotal = await _db.salesDao.getTodayTotal(storeId, '');
    final accounts = await _db.accountsDao.getReceivableAccounts(storeId);
    final totalDebt = accounts.fold<double>(0, (sum, a) => sum + a.balance);

    final tips = <String>[];

    if (lowStock.isNotEmpty) {
      tips.add(
        'لديك ${lowStock.length} منتج بمخزون منخفض - أعد التخزين قبل النفاد',
      );
      // X products with low stock - restock before running out
    }

    if (totalDebt > 1000) {
      tips.add(
        'إجمالي الديون ${totalDebt.toStringAsFixed(0)} ر.س - تابع التحصيل',
      );
      // Total debts X SAR - follow up on collection
    }

    if (todayTotal < 100) {
      tips.add('المبيعات بطيئة اليوم - جرب تفعيل عرض خاص');
      // Sales are slow today - try activating a special offer
    }

    if (tips.isEmpty) {
      tips.add('أداء المتجر جيد! استمر على هذا المنوال');
      // Store performance is good
    }

    tips.add('راجع التقارير الأسبوعية لتحديد أنماط المبيعات');
    // Review weekly reports to identify sales patterns
    tips.add('تأكد من تحديث أسعار المنتجات بانتظام');
    // Make sure to update product prices regularly

    final buffer = StringBuffer();
    buffer.writeln('توصيات لتحسين أداء متجرك:');
    buffer.writeln('');
    // Recommendations to improve store performance
    for (var i = 0; i < tips.length; i++) {
      buffer.writeln('${i + 1}. ${tips[i]}');
    }

    return AssistantResponse(
      text: buffer.toString(),
      confidence: 0.8,
      suggestedActions: [
        const SuggestedAction(
          label: 'إدارة المخزون', // Manage inventory
          route: '/inventory',
          icon: Icons.inventory_2_rounded,
        ),
        const SuggestedAction(
          label: 'إنشاء عرض', // Create offer
          route: '/marketing/discounts',
          icon: Icons.local_offer_rounded,
        ),
      ],
    );
  }

  /// معالجة التحية
  AssistantResponse _handleGreeting() {
    final hour = DateTime.now().hour;
    final greeting = hour < 12
        ? 'صباح الخير' // Good morning
        : hour < 18
        ? 'مساء الخير' // Good afternoon
        : 'مساء النور'; // Good evening

    return AssistantResponse(
      text:
          '''
$greeting! أنا مساعدك الذكي.

يمكنني مساعدتك في:
- معرفة مبيعات اليوم
- حالة المخزون
- ديون العملاء
- المنتجات الأكثر مبيعاً
- توصيات لتحسين الأداء

كيف يمكنني مساعدتك؟''',
      // Greeting with available capabilities
      confidence: 1.0,
      suggestedActions: [
        const SuggestedAction(
          label: 'مبيعات اليوم', // Today's sales
          icon: Icons.point_of_sale_rounded,
        ),
        const SuggestedAction(
          label: 'حالة المخزون', // Stock status
          icon: Icons.inventory_2_rounded,
        ),
        const SuggestedAction(
          label: 'ديون العملاء', // Customer debts
          icon: Icons.account_balance_wallet_rounded,
        ),
      ],
    );
  }

  /// الاستجابة الافتراضية
  AssistantResponse _handleDefault() {
    return const AssistantResponse(
      text: '''
أنا مساعدك الذكي لإدارة المتجر. يمكنني مساعدتك في:

- "مبيعات اليوم" - لمعرفة إجمالي المبيعات
- "حالة المخزون" - لمعرفة المنتجات المنخفضة
- "ديون العملاء" - لمعرفة الديون المستحقة
- "أفضل المنتجات" - لمعرفة الأكثر مبيعاً
- "نصيحة" - للحصول على توصيات

جرب أحد هذه الأسئلة!''',
      // Default response with available commands
      confidence: 0.6,
      suggestedActions: [
        SuggestedAction(
          label: 'مبيعات اليوم',
          icon: Icons.point_of_sale_rounded,
        ),
        SuggestedAction(label: 'حالة المخزون', icon: Icons.inventory_2_rounded),
        SuggestedAction(label: 'ديون العملاء', icon: Icons.people_rounded),
      ],
    );
  }

  // ==========================================================================
  // QUICK TEMPLATES
  // ==========================================================================

  /// الحصول على القوالب السريعة
  List<QuickTemplate> getQuickTemplates() {
    return const [
      QuickTemplate(
        id: 'today_sales',
        icon: Icons.point_of_sale_rounded,
        titleAr: 'مبيعات اليوم', // Today's sales
        titleEn: 'Today Sales',
        query: 'كم مبيعات اليوم؟',
      ),
      QuickTemplate(
        id: 'low_stock',
        icon: Icons.inventory_2_rounded,
        titleAr: 'مخزون منخفض', // Low stock
        titleEn: 'Low Stock',
        query: 'ما المنتجات منخفضة المخزون؟',
      ),
      QuickTemplate(
        id: 'customer_debts',
        icon: Icons.account_balance_wallet_rounded,
        titleAr: 'ديون العملاء', // Customer debts
        titleEn: 'Customer Debts',
        query: 'كم ديون العملاء؟',
      ),
      QuickTemplate(
        id: 'top_products',
        icon: Icons.trending_up_rounded,
        titleAr: 'الأكثر مبيعاً', // Top selling
        titleEn: 'Top Selling',
        query: 'ما أفضل المنتجات مبيعاً؟',
      ),
      QuickTemplate(
        id: 'products_count',
        icon: Icons.category_rounded,
        titleAr: 'عدد المنتجات', // Products count
        titleEn: 'Products Count',
        query: 'كم عدد المنتجات؟',
      ),
      QuickTemplate(
        id: 'recommendations',
        icon: Icons.lightbulb_rounded,
        titleAr: 'توصيات', // Recommendations
        titleEn: 'Suggestions',
        query: 'أعطني نصائح لتحسين المتجر',
      ),
      QuickTemplate(
        id: 'reports',
        icon: Icons.analytics_rounded,
        titleAr: 'التقارير', // Reports
        titleEn: 'Reports',
        query: 'ما التقارير المتاحة؟',
      ),
      QuickTemplate(
        id: 'greeting',
        icon: Icons.waving_hand_rounded,
        titleAr: 'مرحباً', // Hello
        titleEn: 'Hello',
        query: 'مرحبا',
      ),
    ];
  }

  // ==========================================================================
  // HELPERS
  // ==========================================================================

  /// التحقق من تطابق الكلمات المفتاحية
  bool _matchesKeywords(String query, List<String> keywords) {
    return keywords.any((keyword) => query.contains(keyword));
  }
}
