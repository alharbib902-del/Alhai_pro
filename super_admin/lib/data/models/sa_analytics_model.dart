/// Dashboard KPIs.
class SADashboardKPIs {
  final int activeStores;
  final int activeSubscriptions;
  final int trialSubscriptions;
  final int newSignups;
  final double mrr;
  final double arr;

  const SADashboardKPIs({
    this.activeStores = 0,
    this.activeSubscriptions = 0,
    this.trialSubscriptions = 0,
    this.newSignups = 0,
    this.mrr = 0,
    this.arr = 0,
  });

  factory SADashboardKPIs.fromJson(Map<String, dynamic> json) {
    final mrr = (json['mrr'] as num?)?.toDouble() ?? 0;
    return SADashboardKPIs(
      activeStores: json['active_stores'] as int? ?? 0,
      activeSubscriptions: json['active_subscriptions'] as int? ?? 0,
      trialSubscriptions: json['trial_subscriptions'] as int? ?? 0,
      newSignups: json['new_signups'] as int? ?? 0,
      mrr: mrr,
      arr: (json['arr'] as num?)?.toDouble() ?? mrr * 12,
    );
  }

  Map<String, dynamic> toJson() => {
        'active_stores': activeStores,
        'active_subscriptions': activeSubscriptions,
        'trial_subscriptions': trialSubscriptions,
        'new_signups': newSignups,
        'mrr': mrr,
        'arr': arr,
      };
}

/// Monthly revenue data point.
class SARevenueData {
  final String month;
  final double revenue;

  const SARevenueData({
    required this.month,
    this.revenue = 0,
  });

  factory SARevenueData.fromJson(Map<String, dynamic> json) {
    return SARevenueData(
      month: json['month'] as String? ?? '',
      revenue: (json['revenue'] as num?)?.toDouble() ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        'month': month,
        'revenue': revenue,
      };
}

/// Revenue breakdown by plan.
class SARevenueByPlan {
  final String name;
  final String slug;
  final int subscribers;
  final double revenue;

  const SARevenueByPlan({
    required this.name,
    required this.slug,
    this.subscribers = 0,
    this.revenue = 0,
  });

  factory SARevenueByPlan.fromJson(Map<String, dynamic> json) {
    return SARevenueByPlan(
      name: json['name'] as String? ?? '',
      slug: json['slug'] as String? ?? '',
      subscribers: json['subscribers'] as int? ?? 0,
      revenue: (json['revenue'] as num?)?.toDouble() ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'slug': slug,
        'subscribers': subscribers,
        'revenue': revenue,
      };
}

/// Top store by revenue.
class SATopStoreRevenue {
  final String storeId;
  final String storeName;
  final double revenue;

  const SATopStoreRevenue({
    required this.storeId,
    required this.storeName,
    this.revenue = 0,
  });

  factory SATopStoreRevenue.fromJson(Map<String, dynamic> json) {
    return SATopStoreRevenue(
      storeId: json['store_id'] as String? ?? '',
      storeName: json['store_name'] as String? ?? '',
      revenue: (json['revenue'] as num?)?.toDouble() ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        'store_id': storeId,
        'store_name': storeName,
        'revenue': revenue,
      };
}

/// Top store by transactions.
class SATopStoreTransactions {
  final String storeId;
  final String storeName;
  final int transactions;
  final int avgPerDay;
  final int products;

  const SATopStoreTransactions({
    required this.storeId,
    required this.storeName,
    this.transactions = 0,
    this.avgPerDay = 0,
    this.products = 0,
  });

  factory SATopStoreTransactions.fromJson(Map<String, dynamic> json) {
    return SATopStoreTransactions(
      storeId: json['store_id'] as String? ?? '',
      storeName: json['store_name'] as String? ?? '',
      transactions: json['transactions'] as int? ?? 0,
      avgPerDay: json['avg_per_day'] as int? ?? 0,
      products: json['products'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        'store_id': storeId,
        'store_name': storeName,
        'transactions': transactions,
        'avg_per_day': avgPerDay,
        'products': products,
      };
}

/// Active users per store.
class SAActiveUsersPerStore {
  final String storeId;
  final String storeName;
  final int activeUsers;

  const SAActiveUsersPerStore({
    required this.storeId,
    required this.storeName,
    this.activeUsers = 0,
  });

  factory SAActiveUsersPerStore.fromJson(Map<String, dynamic> json) {
    return SAActiveUsersPerStore(
      storeId: json['store_id'] as String? ?? '',
      storeName: json['store_name'] as String? ?? '',
      activeUsers: json['active_users'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        'store_id': storeId,
        'store_name': storeName,
        'active_users': activeUsers,
      };
}

/// System health info.
class SASystemHealth {
  final String status;
  final int? dbResponseMs;
  final String? error;
  final String timestamp;

  const SASystemHealth({
    this.status = 'unknown',
    this.dbResponseMs,
    this.error,
    required this.timestamp,
  });

  factory SASystemHealth.fromJson(Map<String, dynamic> json) {
    return SASystemHealth(
      status: json['status'] as String? ?? 'unknown',
      dbResponseMs: json['db_response_ms'] as int?,
      error: json['error'] as String?,
      timestamp:
          json['timestamp'] as String? ?? DateTime.now().toIso8601String(),
    );
  }

  Map<String, dynamic> toJson() => {
        'status': status,
        'db_response_ms': dbResponseMs,
        'error': error,
        'timestamp': timestamp,
      };

  bool get isHealthy => status == 'healthy';
}

/// Platform settings.
class SAPlatformSettings {
  final bool zatcaEnabled;
  final String zatcaEnvironment;
  final double vatRate;
  final String defaultLanguage;
  final String defaultCurrency;
  final int trialPeriodDays;
  final bool moyasarEnabled;
  final bool hyperpayEnabled;
  final bool tabbyEnabled;
  final bool tamaraEnabled;

  const SAPlatformSettings({
    this.zatcaEnabled = true,
    this.zatcaEnvironment = 'production',
    this.vatRate = 15.0,
    this.defaultLanguage = 'ar',
    this.defaultCurrency = 'SAR',
    this.trialPeriodDays = 14,
    this.moyasarEnabled = true,
    this.hyperpayEnabled = false,
    this.tabbyEnabled = true,
    this.tamaraEnabled = false,
  });

  factory SAPlatformSettings.fromJson(Map<String, dynamic> json) {
    return SAPlatformSettings(
      zatcaEnabled: json['zatca_enabled'] as bool? ?? true,
      zatcaEnvironment:
          json['zatca_environment'] as String? ?? 'production',
      vatRate: (json['vat_rate'] as num?)?.toDouble() ?? 15.0,
      defaultLanguage: json['default_language'] as String? ?? 'ar',
      defaultCurrency: json['default_currency'] as String? ?? 'SAR',
      trialPeriodDays: json['trial_period_days'] as int? ?? 14,
      moyasarEnabled: json['moyasar_enabled'] as bool? ?? true,
      hyperpayEnabled: json['hyperpay_enabled'] as bool? ?? false,
      tabbyEnabled: json['tabby_enabled'] as bool? ?? true,
      tamaraEnabled: json['tamara_enabled'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
        'zatca_enabled': zatcaEnabled,
        'zatca_environment': zatcaEnvironment,
        'vat_rate': vatRate,
        'default_language': defaultLanguage,
        'default_currency': defaultCurrency,
        'trial_period_days': trialPeriodDays,
        'moyasar_enabled': moyasarEnabled,
        'hyperpay_enabled': hyperpayEnabled,
        'tabby_enabled': tabbyEnabled,
        'tamara_enabled': tamaraEnabled,
      };
}
