/// خدمة كشف الاحتيال بالذكاء الاصطناعي - AI Fraud Detection Service
///
/// تكشف الأنماط المشبوهة في المعاملات وسلوك الكاشير
/// - معدل الإلغاء العالي
/// - الخصومات غير المصرح بها
/// - المعاملات بعد الدوام
/// - أنماط الاسترجاع المشبوهة
library;

import 'package:alhai_database/alhai_database.dart';

// ============================================================================
// ENUMS
// ============================================================================

/// مستوى خطورة الاحتيال - Fraud Severity
enum FraudSeverity {
  /// منخفض - Low
  low,

  /// متوسط - Medium
  medium,

  /// عالي - High
  high,

  /// حرج - Critical
  critical,
}

/// نمط الاحتيال - Fraud Pattern
enum FraudPattern {
  /// استرجاع غير اعتيادي - Unusual Refund
  unusualRefund,

  /// معاملة بعد الدوام - After Hours Transaction
  afterHoursTransaction,

  /// إلغاء متكرر - Repeated Void
  repeatedVoid,

  /// خصم كبير - Large Discount
  largeDiscount,

  /// تقسيم معاملة - Split Transaction
  splitTransaction,

  /// شذوذ درج النقد - Cash Drawer Anomaly
  cashDrawerAnomaly,
}

/// حالة التحقيق - Investigation Status
enum InvestigationStatus {
  /// مفتوح - Open
  open,

  /// قيد التحقيق - Under Investigation
  underInvestigation,

  /// مغلق - Closed
  closed,

  /// تصعيد - Escalated
  escalated,
}

/// اتجاه السلوك - Behavior Trend
enum BehaviorTrend {
  /// تحسن - Up (improving)
  up,

  /// تراجع - Down (declining)
  down,

  /// مستقر - Stable
  stable,
}

// ============================================================================
// MODELS
// ============================================================================

/// تنبيه احتيال - Fraud Alert
class FraudAlert {
  final String id;
  final FraudPattern pattern;
  final FraudSeverity severity;
  final String description;
  final List<String> transactionIds;
  final String cashierId;
  final String cashierName;
  final DateTime timestamp;
  final String suggestedAction;
  final bool isReviewed;
  final double confidence;
  final double amount;

  const FraudAlert({
    required this.id,
    required this.pattern,
    required this.severity,
    required this.description,
    required this.transactionIds,
    required this.cashierId,
    required this.cashierName,
    required this.timestamp,
    required this.suggestedAction,
    this.isReviewed = false,
    this.confidence = 0.0,
    this.amount = 0.0,
  });

  FraudAlert copyWith({bool? isReviewed}) {
    return FraudAlert(
      id: id,
      pattern: pattern,
      severity: severity,
      description: description,
      transactionIds: transactionIds,
      cashierId: cashierId,
      cashierName: cashierName,
      timestamp: timestamp,
      suggestedAction: suggestedAction,
      isReviewed: isReviewed ?? this.isReviewed,
      confidence: confidence,
      amount: amount,
    );
  }
}

/// درجة سلوك الكاشير - Behavior Score
class BehaviorScore {
  final String cashierId;
  final String name;
  final double score; // 0-100
  final Map<String, double> factors;
  final BehaviorTrend trend;
  final DateTime lastUpdated;
  final int totalTransactions;
  final int alertCount;

  const BehaviorScore({
    required this.cashierId,
    required this.name,
    required this.score,
    required this.factors,
    required this.trend,
    required this.lastUpdated,
    this.totalTransactions = 0,
    this.alertCount = 0,
  });
}

/// حدث في الجدول الزمني - Timeline Event
class TimelineEvent {
  final DateTime timestamp;
  final String title;
  final String description;
  final String? actionTaken;

  const TimelineEvent({
    required this.timestamp,
    required this.title,
    required this.description,
    this.actionTaken,
  });
}

/// تحقيق - Investigation
class Investigation {
  final String alertId;
  final List<TimelineEvent> timeline;
  final InvestigationStatus status;
  final String notes;
  final String? assignedTo;

  const Investigation({
    required this.alertId,
    required this.timeline,
    required this.status,
    this.notes = '',
    this.assignedTo,
  });
}

/// ملخص كشف الاحتيال - Fraud Detection Summary
class FraudDetectionSummary {
  final int totalAlerts;
  final int criticalAlerts;
  final int unreviewedAlerts;
  final double overallRiskScore;
  final Map<FraudPattern, int> patternCounts;

  const FraudDetectionSummary({
    required this.totalAlerts,
    required this.criticalAlerts,
    required this.unreviewedAlerts,
    required this.overallRiskScore,
    required this.patternCounts,
  });
}

// ============================================================================
// SERVICE
// ============================================================================

/// خدمة كشف الاحتيال بالذكاء الاصطناعي
class AiFraudDetectionService {
  final AppDatabase _db;

  AiFraudDetectionService(this._db);

  /// كشف الاحتيال - Detect Fraud
  Future<List<FraudAlert>> detectFraud(String storeId) async {
    // في الإنتاج سيتم تحليل بيانات salesDao و returnsDao
    // حالياً نستخدم بيانات تجريبية واقعية
    final _ = _db.salesDao;
    final now = DateTime.now();

    return [
      // استرجاعات غير اعتيادية - Unusual refunds
      FraudAlert(
        id: 'FA001',
        pattern: FraudPattern.unusualRefund,
        severity: FraudSeverity.critical,
        description:
            'تم إرجاع 8 معاملات خلال ساعة واحدة بقيمة إجمالية 2,340 ر.س', // 8 refunds in 1 hour totaling 2,340 SAR
        transactionIds: [
          'TXN-001',
          'TXN-002',
          'TXN-003',
          'TXN-004',
          'TXN-005',
          'TXN-006',
          'TXN-007',
          'TXN-008',
        ],
        cashierId: 'CSH-003',
        cashierName: 'سعد الحربي', // Saad Al-Harbi
        timestamp: now.subtract(const Duration(hours: 2)),
        suggestedAction:
            'مراجعة فورية وإيقاف الكاشير مؤقتاً', // Immediate review and suspend cashier
        confidence: 0.94,
        amount: 2340.0,
      ),
      // إلغاء متكرر - Repeated void
      FraudAlert(
        id: 'FA002',
        pattern: FraudPattern.repeatedVoid,
        severity: FraudSeverity.high,
        description:
            'معدل إلغاء 18% (أعلى من الحد المسموح 10%) - 12 إلغاء من 67 معاملة', // 18% void rate, 12 voids out of 67
        transactionIds: ['TXN-101', 'TXN-102', 'TXN-103'],
        cashierId: 'CSH-005',
        cashierName: 'نورة العتيبي', // Noura Al-Otaibi
        timestamp: now.subtract(const Duration(hours: 4)),
        suggestedAction:
            'مراجعة سجل الإلغاءات ومقابلة الموظف', // Review void log and interview employee
        confidence: 0.88,
        amount: 890.0,
      ),
      // خصم كبير بدون موافقة - Large discount without approval
      FraudAlert(
        id: 'FA003',
        pattern: FraudPattern.largeDiscount,
        severity: FraudSeverity.high,
        description:
            'خصم 45% على فاتورة بقيمة 1,200 ر.س بدون موافقة المدير', // 45% discount on 1,200 SAR without manager approval
        transactionIds: ['TXN-201'],
        cashierId: 'CSH-002',
        cashierName: 'فهد القحطاني', // Fahad Al-Qahtani
        timestamp: now.subtract(const Duration(hours: 6)),
        suggestedAction:
            'التحقق من صلاحيات الخصم ومراجعة السياسة', // Verify discount permissions and review policy
        confidence: 0.92,
        amount: 540.0,
      ),
      // معاملة بعد الدوام - After hours transaction
      FraudAlert(
        id: 'FA004',
        pattern: FraudPattern.afterHoursTransaction,
        severity: FraudSeverity.medium,
        description:
            'تمت 3 معاملات بعد إغلاق الوردية الساعة 11:45 مساءً', // 3 transactions after shift end at 11:45 PM
        transactionIds: ['TXN-301', 'TXN-302', 'TXN-303'],
        cashierId: 'CSH-001',
        cashierName: 'أحمد المالكي', // Ahmed Al-Malki
        timestamp: now.subtract(const Duration(hours: 12)),
        suggestedAction:
            'مراجعة أسباب البقاء بعد الدوام', // Review reasons for staying after shift
        confidence: 0.76,
        amount: 350.0,
      ),
      // تقسيم معاملة - Split transaction
      FraudAlert(
        id: 'FA005',
        pattern: FraudPattern.splitTransaction,
        severity: FraudSeverity.medium,
        description:
            'تقسيم فاتورة 950 ر.س إلى 3 فواتير أقل من 350 ر.س (حد الخصم)', // Split 950 SAR into 3 invoices under 350 SAR discount limit
        transactionIds: ['TXN-401', 'TXN-402', 'TXN-403'],
        cashierId: 'CSH-004',
        cashierName: 'خالد الشمري', // Khaled Al-Shammari
        timestamp: now.subtract(const Duration(days: 1)),
        suggestedAction:
            'مراجعة سياسة تقسيم الفواتير', // Review invoice splitting policy
        confidence: 0.71,
        amount: 950.0,
      ),
      // شذوذ درج النقد - Cash drawer anomaly
      FraudAlert(
        id: 'FA006',
        pattern: FraudPattern.cashDrawerAnomaly,
        severity: FraudSeverity.low,
        description:
            'فرق 45 ر.س في درج النقد عند إغلاق الوردية', // 45 SAR discrepancy in cash drawer at shift close
        transactionIds: ['SHIFT-001'],
        cashierId: 'CSH-006',
        cashierName: 'ريم السبيعي', // Reem Al-Subaie
        timestamp: now.subtract(const Duration(days: 1, hours: 8)),
        suggestedAction:
            'مراقبة ومتابعة في الأيام القادمة', // Monitor in the coming days
        confidence: 0.65,
        amount: 45.0,
      ),
    ];
  }

  /// الحصول على درجات السلوك - Get Behavior Scores
  Future<List<BehaviorScore>> getBehaviorScores(String storeId) async {
    final _ = _db.salesDao;
    final now = DateTime.now();

    return [
      BehaviorScore(
        cashierId: 'CSH-001',
        name: 'أحمد المالكي', // Ahmed Al-Malki
        score: 82,
        factors: {
          'معدل الإلغاء': 0.85, // Void rate
          'الالتزام بالدوام': 0.70, // Shift adherence
          'دقة النقد': 0.90, // Cash accuracy
          'معدل الخصم': 0.85, // Discount rate
        },
        trend: BehaviorTrend.stable,
        lastUpdated: now,
        totalTransactions: 234,
        alertCount: 1,
      ),
      BehaviorScore(
        cashierId: 'CSH-002',
        name: 'فهد القحطاني', // Fahad Al-Qahtani
        score: 58,
        factors: {
          'معدل الإلغاء': 0.60,
          'الالتزام بالدوام': 0.80,
          'دقة النقد': 0.55,
          'معدل الخصم': 0.35,
        },
        trend: BehaviorTrend.down,
        lastUpdated: now,
        totalTransactions: 189,
        alertCount: 3,
      ),
      BehaviorScore(
        cashierId: 'CSH-003',
        name: 'سعد الحربي', // Saad Al-Harbi
        score: 31,
        factors: {
          'معدل الإلغاء': 0.40,
          'الالتزام بالدوام': 0.30,
          'دقة النقد': 0.25,
          'معدل الخصم': 0.30,
        },
        trend: BehaviorTrend.down,
        lastUpdated: now,
        totalTransactions: 156,
        alertCount: 5,
      ),
      BehaviorScore(
        cashierId: 'CSH-004',
        name: 'خالد الشمري', // Khaled Al-Shammari
        score: 72,
        factors: {
          'معدل الإلغاء': 0.75,
          'الالتزام بالدوام': 0.85,
          'دقة النقد': 0.70,
          'معدل الخصم': 0.60,
        },
        trend: BehaviorTrend.up,
        lastUpdated: now,
        totalTransactions: 312,
        alertCount: 1,
      ),
      BehaviorScore(
        cashierId: 'CSH-005',
        name: 'نورة العتيبي', // Noura Al-Otaibi
        score: 45,
        factors: {
          'معدل الإلغاء': 0.30,
          'الالتزام بالدوام': 0.65,
          'دقة النقد': 0.50,
          'معدل الخصم': 0.40,
        },
        trend: BehaviorTrend.down,
        lastUpdated: now,
        totalTransactions: 201,
        alertCount: 4,
      ),
      BehaviorScore(
        cashierId: 'CSH-006',
        name: 'ريم السبيعي', // Reem Al-Subaie
        score: 91,
        factors: {
          'معدل الإلغاء': 0.95,
          'الالتزام بالدوام': 0.90,
          'دقة النقد': 0.88,
          'معدل الخصم': 0.92,
        },
        trend: BehaviorTrend.up,
        lastUpdated: now,
        totalTransactions: 278,
        alertCount: 1,
      ),
    ];
  }

  /// الحصول على التنبيهات - Get Alerts
  Future<List<FraudAlert>> getAlerts(String storeId) async {
    return detectFraud(storeId);
  }

  /// الحصول على تحقيق - Get Investigation
  Future<Investigation> getInvestigation(String alertId) async {
    final now = DateTime.now();
    return Investigation(
      alertId: alertId,
      status: InvestigationStatus.open,
      notes: '',
      timeline: [
        TimelineEvent(
          timestamp: now.subtract(const Duration(hours: 2)),
          title: 'تم إنشاء التنبيه', // Alert created
          description:
              'تم اكتشاف نمط مشبوه بواسطة النظام', // Suspicious pattern detected by system
        ),
        TimelineEvent(
          timestamp: now.subtract(const Duration(hours: 1, minutes: 45)),
          title: 'تحليل تلقائي', // Auto analysis
          description:
              'تم تحليل المعاملات المرتبطة وتأكيد النمط', // Related transactions analyzed and pattern confirmed
        ),
        TimelineEvent(
          timestamp: now.subtract(const Duration(hours: 1, minutes: 30)),
          title: 'إشعار المدير', // Manager notified
          description:
              'تم إرسال إشعار للمدير المسؤول', // Notification sent to responsible manager
        ),
      ],
    );
  }

  /// الحصول على الملخص - Get Summary
  Future<FraudDetectionSummary> getSummary(String storeId) async {
    final alerts = await getAlerts(storeId);
    final criticalCount = alerts
        .where((a) => a.severity == FraudSeverity.critical)
        .length;
    final unreviewedCount = alerts.where((a) => !a.isReviewed).length;

    final patternCounts = <FraudPattern, int>{};
    for (final alert in alerts) {
      patternCounts[alert.pattern] = (patternCounts[alert.pattern] ?? 0) + 1;
    }

    return FraudDetectionSummary(
      totalAlerts: alerts.length,
      criticalAlerts: criticalCount,
      unreviewedAlerts: unreviewedCount,
      overallRiskScore: criticalCount > 0 ? 78.5 : 35.0,
      patternCounts: patternCounts,
    );
  }
}
