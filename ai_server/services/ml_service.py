"""
ML Service - خدمة التعلم الآلي
Returns realistic dummy data based on input parameters.
Uses deterministic seeding for consistent results per org/store.
Supports 7 languages: ar, en, ur, hi, bn, fil, id
"""

import hashlib
import math
from datetime import datetime, timedelta

from i18n.translations import t, t_fmt, get_product_names, get_currency_symbol

from models.schemas import (
    # Forecast
    ForecastPrediction, ForecastSummary, ForecastResponse,
    # Pricing
    PricingSuggestion, PricingResponse,
    # Fraud
    FraudAlert, FraudSummary, FraudResponse,
    # Basket
    AssociationRule, BasketSummary, BasketResponse,
    # Recommendations
    ProductRecommendation, CustomerSegment, RecommendationResponse,
    # Inventory
    InventoryAlert, InventoryOptimization, InventoryResponse,
    # Competitor
    CompetitorInfo, PriceComparison, CompetitorResponse,
    # Reports
    ReportInsight, ReportSection, ReportResponse,
    # Staff
    EmployeePerformance, StaffSummary, StaffResponse,
    # Recognition
    RecognizedProduct, RecognitionResponse,
    # Sentiment
    SentimentResult, SentimentSummary, SentimentResponse,
    # Returns
    ReturnPrediction, ReturnSummary, ReturnResponse,
    # Promotions
    PromotionSuggestion, PromotionResponse,
    # Chat
    ChatDataPoint, ChatResponse,
    # Assistant
    SuggestedAction, AssistantResponse,
)


def _seed(org_id: str, store_id: str) -> int:
    """Deterministic seed from org+store for consistent results."""
    h = hashlib.md5(f"{org_id}:{store_id}".encode()).hexdigest()
    return int(h[:8], 16)


def _pseudo_random(seed: int, index: int) -> float:
    """Simple deterministic pseudo-random 0..1."""
    val = math.sin(seed * 9301 + index * 49297) * 233280
    return val - math.floor(val)


# ============================================================================
# 1. SALES FORECAST
# ============================================================================

def generate_forecast(org_id: str, store_id: str, days_ahead: int,
                      product_ids: list[str] | None = None,
                      language: str = "ar") -> ForecastResponse:
    s = _seed(org_id, store_id)
    base_revenue = 1500 + _pseudo_random(s, 0) * 3000
    today = datetime.now()
    predictions = []

    for i in range(days_ahead):
        d = today + timedelta(days=i + 1)
        dow_factor = [0.85, 0.90, 0.95, 1.00, 1.10, 1.25, 1.20][d.weekday()]
        noise = (_pseudo_random(s, i + 10) - 0.5) * 200
        predicted_rev = base_revenue * dow_factor + noise
        predictions.append(ForecastPrediction(
            date=d.strftime("%Y-%m-%d"),
            product_id=product_ids[i % len(product_ids)] if product_ids else None,
            predicted_qty=round(predicted_rev / 45, 1),
            predicted_revenue=round(max(0, predicted_rev), 2),
            confidence=round(max(0.5, 0.95 - i * 0.005), 2),
        ))

    total_rev = sum(p.predicted_revenue for p in predictions)
    avg_daily = total_rev / max(len(predictions), 1)
    peak_idx = max(range(len(predictions)), key=lambda i: predictions[i].predicted_revenue)
    trend_val = predictions[-1].predicted_revenue - predictions[0].predicted_revenue
    trend = "up" if trend_val > 100 else "down" if trend_val < -100 else "stable"

    return ForecastResponse(
        predictions=predictions,
        summary=ForecastSummary(
            total_revenue=round(total_rev, 2),
            trend=trend,
            trend_label=t(f"trend_{trend}", language),
            avg_daily_revenue=round(avg_daily, 2),
            peak_day=predictions[peak_idx].date,
        ),
        accuracy=round(0.82 + _pseudo_random(s, 99) * 0.12, 2),
        is_mock_data=True,
        data_source="mock",
    )


# ============================================================================
# 2. SMART PRICING
# ============================================================================

def generate_pricing(org_id: str, store_id: str, product_ids: list[str] | None,
                     strategy: str, language: str = "ar") -> PricingResponse:
    s = _seed(org_id, store_id)
    products = product_ids or [f"prod_{i}" for i in range(1, 8)]
    names = get_product_names(language)
    suggestions = []

    pricing_reason_keys = [
        "pricing_high_demand", "pricing_competitor_lower",
        "pricing_low_elasticity", "pricing_peak_season",
    ]

    for i, pid in enumerate(products):
        current = round(10 + _pseudo_random(s, i) * 90, 2)
        change = (_pseudo_random(s, i + 50) - 0.4) * 15
        suggested = round(max(current * 0.7, current + change), 2)
        suggestions.append(PricingSuggestion(
            product_id=pid,
            product_name=names[i % len(names)],
            current_price=current,
            suggested_price=suggested,
            min_price=round(current * 0.7, 2),
            max_price=round(current * 1.4, 2),
            expected_revenue_change=round(change, 1),
            reason=t(pricing_reason_keys[i % len(pricing_reason_keys)], language),
            confidence=round(0.7 + _pseudo_random(s, i + 80) * 0.25, 2),
        ))

    total_increase = sum(sg.expected_revenue_change for sg in suggestions) / max(len(suggestions), 1)
    return PricingResponse(
        suggestions=suggestions,
        total_potential_increase=round(total_increase, 1),
        strategy_used=strategy,
        is_mock_data=True,
        data_source="mock",
    )


# ============================================================================
# 3. FRAUD DETECTION
# ============================================================================

def detect_fraud(org_id: str, store_id: str, sale_id: str | None = None,
                 language: str = "ar") -> FraudResponse:
    s = _seed(org_id, store_id)
    now = datetime.now()
    alerts = []
    reason_keys = [
        "fraud_high_value", "fraud_repeated_discount", "fraud_multiple_void",
        "fraud_off_hours", "fraud_abnormal_qty", "fraud_manual_discount",
        "fraud_suspicious_return",
    ]
    pattern_keys = [
        "pattern_high_value", "pattern_repeated_discount", "pattern_multiple_void",
        "pattern_off_hours", "pattern_suspicious_qty",
    ]
    count = 3 + int(_pseudo_random(s, 0) * 8)

    for i in range(count):
        risk = round(0.3 + _pseudo_random(s, i + 20) * 0.7, 2)
        level = "high" if risk > 0.7 else "medium" if risk > 0.4 else "low"
        ts = now - timedelta(hours=int(_pseudo_random(s, i + 30) * 72))
        alerts.append(FraudAlert(
            sale_id=sale_id or f"sale_{1000 + i}",
            risk_score=risk,
            risk_level=level,
            reason=t(reason_keys[i % len(reason_keys)], language),
            timestamp=ts.isoformat(),
            cashier_id=f"emp_{int(_pseudo_random(s, i + 40) * 5) + 1}",
            amount=round(50 + _pseudo_random(s, i + 50) * 2000, 2),
            patterns=[t(pattern_keys[i % len(pattern_keys)], language)],
        ))

    high = sum(1 for a in alerts if a.risk_level == "high")
    med = sum(1 for a in alerts if a.risk_level == "medium")
    low = sum(1 for a in alerts if a.risk_level == "low")
    total_amt = sum(a.amount or 0 for a in alerts)

    return FraudResponse(
        alerts=sorted(alerts, key=lambda a: a.risk_score, reverse=True),
        summary=FraudSummary(
            total_flagged=len(alerts),
            high_risk_count=high,
            medium_risk_count=med,
            low_risk_count=low,
            total_amount_flagged=round(total_amt, 2),
            period=t("last_72_hours", language),
        ),
        is_mock_data=True,
        data_source="mock",
    )


# ============================================================================
# 4. BASKET ANALYSIS
# ============================================================================

def analyze_basket(org_id: str, store_id: str, top_n: int = 20,
                   language: str = "ar") -> BasketResponse:
    s = _seed(org_id, store_id)
    product_pairs = [
        ([t("bread", language), t("cheese", language)], [t("milk", language)], t("basket_bread_cheese_milk", language)),
        ([t("rice", language)], [t("cooking_oil", language), t("spices", language)], t("basket_rice_oil_spices", language)),
        ([t("tea", language)], [t("sugar", language)], t("basket_tea_sugar", language)),
        ([t("diapers", language)], [t("wet_wipes", language)], t("basket_diapers_wipes", language)),
        ([t("chicken", language)], [t("garlic", language), t("onion", language)], t("basket_chicken_garlic_onion", language)),
        ([t("pasta", language)], [t("tomato_sauce", language)], t("basket_pasta_sauce", language)),
        ([t("coffee", language)], [t("cream", language), t("sugar", language)], t("basket_coffee_cream_sugar", language)),
        ([t("shampoo", language)], [t("conditioner", language)], t("basket_shampoo_conditioner", language)),
    ]

    rules = []
    for i, (ant, cons, desc) in enumerate(product_pairs[:top_n]):
        support = round(0.05 + _pseudo_random(s, i) * 0.25, 3)
        confidence = round(0.3 + _pseudo_random(s, i + 10) * 0.5, 3)
        lift = round(1.2 + _pseudo_random(s, i + 20) * 3.0, 2)
        rules.append(AssociationRule(
            antecedent=ant, consequent=cons,
            support=support, confidence=confidence, lift=lift,
            description=desc,
        ))

    fbt = [
        [t("bread", language), t("cheese", language), t("milk", language)],
        [t("rice", language), t("oil", language), t("spices", language)],
        [t("tea", language), t("sugar", language), t("biscuit", language)],
    ]
    return BasketResponse(
        rules=sorted(rules, key=lambda r: r.lift, reverse=True),
        summary=BasketSummary(
            avg_basket_size=round(3.2 + _pseudo_random(s, 100) * 2, 1),
            avg_basket_value=round(45 + _pseudo_random(s, 101) * 80, 2),
            total_transactions_analyzed=int(500 + _pseudo_random(s, 102) * 4500),
            top_product=t("top_product_bread", language),
            cross_sell_opportunity=t("cross_sell_cheese_bread", language),
        ),
        frequently_bought_together=fbt,
        is_mock_data=True,
        data_source="mock",
    )


# ============================================================================
# 5. CUSTOMER RECOMMENDATIONS
# ============================================================================

_REC_PRODUCTS = {
    "ar": [
        ("حليب كامل الدسم", "ألبان", "بناءً على سجل الشراء المتكرر"),
        ("خبز أبيض طازج", "مخبوزات", "منتج أساسي يُشترى أسبوعياً"),
        ("أرز بسمتي 5 كجم", "حبوب", "شراء دوري - حان وقت التجديد"),
        ("زيت زيتون فلسطيني", "زيوت", "عميل مهتم بالمنتجات الصحية"),
        ("عسل طبيعي", "محليات", "مكمل لمشتريات الشاي والإفطار"),
        ("لبنة طازجة", "ألبان", "يُشترى غالباً مع الخبز والزيت"),
        ("تمر سكري", "فواكه مجففة", "منتج موسمي - الطلب مرتفع حالياً"),
        ("بهارات مشكلة", "بهارات", "مكمل لمشتريات الأرز والدجاج"),
        ("صابون يد معطر", "نظافة", "منتج يُشترى شهرياً"),
        ("عصير برتقال طبيعي", "مشروبات", "مشتريات الإفطار المتكررة"),
    ],
    "en": [
        ("Full Fat Milk", "Dairy", "Based on frequent purchase history"),
        ("Fresh White Bread", "Bakery", "Essential product bought weekly"),
        ("Basmati Rice 5kg", "Grains", "Periodic purchase - time to restock"),
        ("Palestinian Olive Oil", "Oils", "Customer interested in healthy products"),
        ("Natural Honey", "Sweeteners", "Complement to tea and breakfast purchases"),
        ("Fresh Labneh", "Dairy", "Often bought with bread and oil"),
        ("Sukari Dates", "Dried Fruits", "Seasonal product - high demand currently"),
        ("Mixed Spices", "Spices", "Complement to rice and chicken purchases"),
        ("Scented Hand Soap", "Hygiene", "Monthly purchase product"),
        ("Natural Orange Juice", "Beverages", "Frequent breakfast purchases"),
    ],
}

_SEGMENTS = {
    "ar": [
        ("عملاء VIP", "عملاء ذوو إنفاق مرتفع ومتكرر"),
        ("عملاء منتظمون", "يتسوقون أسبوعياً بمبالغ متوسطة"),
        ("عملاء عابرون", "مشتريات قليلة وغير منتظمة"),
    ],
    "en": [
        ("VIP Customers", "High-spending and frequent customers"),
        ("Regular Customers", "Shop weekly with moderate spending"),
        ("Casual Customers", "Few and irregular purchases"),
    ],
}


def generate_recommendations(org_id: str, store_id: str, customer_id: str | None,
                             top_n: int = 10, language: str = "ar") -> RecommendationResponse:
    s = _seed(org_id, store_id)
    lang_key = language if language in _REC_PRODUCTS else "ar"
    products = _REC_PRODUCTS.get(lang_key, _REC_PRODUCTS["ar"])

    recs = []
    for i, (name, cat, reason) in enumerate(products[:top_n]):
        recs.append(ProductRecommendation(
            product_id=f"prod_{100 + i}",
            product_name=name, score=round(0.95 - i * 0.05, 2),
            reason=reason, category=cat,
            expected_purchase_probability=round(0.85 - i * 0.06, 2),
        ))

    seg_data = _SEGMENTS.get(lang_key, _SEGMENTS["ar"])
    segments = [
        CustomerSegment(segment_id=f"seg_{i+1}", name=n, description=d,
                        customer_count=[45, 320, 180][i], avg_spend=[850.0, 280.0, 65.0][i])
        for i, (n, d) in enumerate(seg_data)
    ]

    return RecommendationResponse(
        recommendations=recs, customer_segments=segments,
        personalization_score=round(0.7 + _pseudo_random(s, 200) * 0.25, 2),
        is_mock_data=True,
        data_source="mock",
    )


# ============================================================================
# 6. SMART INVENTORY
# ============================================================================

def analyze_inventory(org_id: str, store_id: str,
                      language: str = "ar") -> InventoryResponse:
    s = _seed(org_id, store_id)
    names = get_product_names(language)
    reason_keys = [
        "inv_critical_low", "inv_reorder_now", "inv_sufficient_2weeks",
        "inv_low_reorder_week", "inv_good", "inv_near_reorder", "inv_overstock_promo",
    ]
    items_data = [
        (names[0], 12, 25, 50, 3, "critical", t_fmt("inv_critical_low", language, days=3)),
        (names[1], 8, 20, 40, 2, "critical", t("inv_reorder_now", language)),
        (names[2], 45, 30, 60, 15, "medium", t("inv_sufficient_2weeks", language)),
        (names[3], 5, 15, 30, 4, "high", t("inv_low_reorder_week", language)),
        (names[4], 80, 40, 100, 25, "low", t("inv_good", language)),
        (names[5], 18, 20, 40, 6, "high", t("inv_near_reorder", language)),
        (names[6], 100, 30, 60, 45, "low", t("inv_overstock_promo", language)),
    ]

    alerts = [InventoryAlert(
        product_id=f"prod_{i}", product_name=n,
        current_stock=cs, reorder_point=rp, suggested_order_qty=sq,
        days_until_stockout=ds, priority=p, reason=r,
    ) for i, (n, cs, rp, sq, ds, p, r) in enumerate(items_data)]

    return InventoryResponse(
        alerts=sorted(alerts, key=lambda a: {"critical": 0, "high": 1, "medium": 2, "low": 3}[a.priority]),
        optimization=InventoryOptimization(
            overstock_items=2, understock_items=3, optimal_items=15,
            potential_savings=round(2500 + _pseudo_random(s, 300) * 5000, 2),
            dead_stock_value=round(800 + _pseudo_random(s, 301) * 3000, 2),
        ),
        abc_classification={"A": 25, "B": 45, "C": 130},
        is_mock_data=True,
        data_source="mock",
    )


# ============================================================================
# 7. COMPETITOR ANALYSIS
# ============================================================================

_COMPETITOR_DATA = {
    "ar": {
        "strengths": [
            ["أسعار أقل 5%", "موقف سيارات واسع"],
            ["قريب من الحي السكني", "خدمة توصيل"],
            ["عروض قوية", "تشكيلة واسعة جداً"],
        ],
        "weaknesses": [
            ["خدمة بطيئة", "تنوع محدود"],
            ["أسعار أعلى", "مساحة صغيرة"],
            ["بعيد", "ازدحام في عطلة نهاية الأسبوع"],
        ],
        "products": ["حليب 1 لتر", "أرز 5 كجم", "زيت زيتون 1 لتر"],
        "positions": ["أغلى", "أرخص", "متوسط"],
        "recommendations": [
            "خفض السعر 0.3 ر.س للمنافسة",
            "ميزة تنافسية - أبرز هذا السعر",
            "السعر ضمن النطاق المقبول",
        ],
        "market_position": "متوسط - لديك ميزة في بعض المنتجات وفرصة تحسين في أخرى",
        "opportunities": ["تحسين خدمة التوصيل", "برنامج ولاء للعملاء المتكررين", "عروض أسبوعية على المنتجات الأساسية"],
    },
    "en": {
        "strengths": [
            ["5% lower prices", "Large parking lot"],
            ["Close to residential area", "Delivery service"],
            ["Strong offers", "Very wide selection"],
        ],
        "weaknesses": [
            ["Slow service", "Limited variety"],
            ["Higher prices", "Small space"],
            ["Far away", "Crowded on weekends"],
        ],
        "products": ["Milk 1L", "Rice 5kg", "Olive Oil 1L"],
        "positions": ["Most expensive", "Cheapest", "Average"],
        "recommendations": [
            "Reduce price by 0.3 SAR to compete",
            "Competitive advantage - highlight this price",
            "Price within acceptable range",
        ],
        "market_position": "Average - you have an advantage in some products and room for improvement in others",
        "opportunities": ["Improve delivery service", "Loyalty program for repeat customers", "Weekly deals on essential products"],
    },
}


def analyze_competitors(org_id: str, store_id: str,
                        language: str = "ar") -> CompetitorResponse:
    s = _seed(org_id, store_id)
    lang_key = language if language in _COMPETITOR_DATA else "ar"
    cd = _COMPETITOR_DATA[lang_key]

    competitors = [
        CompetitorInfo(
            name=t("competitor_1", language), distance_km=1.2, price_index=0.95,
            strengths=cd["strengths"][0], weaknesses=cd["weaknesses"][0], threat_level="high",
        ),
        CompetitorInfo(
            name=t("competitor_2", language), distance_km=0.5, price_index=1.05,
            strengths=cd["strengths"][1], weaknesses=cd["weaknesses"][1], threat_level="medium",
        ),
        CompetitorInfo(
            name=t("competitor_3", language), distance_km=3.8, price_index=0.88,
            strengths=cd["strengths"][2], weaknesses=cd["weaknesses"][2], threat_level="medium",
        ),
    ]

    comparisons = [
        PriceComparison(product_name=cd["products"][i], your_price=p, avg_competitor_price=ap,
                        price_position=cd["positions"][i], recommendation=cd["recommendations"][i])
        for i, (p, ap) in enumerate([(6.5, 6.2), (28.0, 30.5), (35.0, 34.0)])
    ]

    return CompetitorResponse(
        competitors=competitors, price_comparisons=comparisons,
        market_position=cd["market_position"],
        opportunities=cd["opportunities"],
        is_mock_data=True,
        data_source="mock",
    )


# ============================================================================
# 8. SMART REPORTS
# ============================================================================

_REPORT_DATA = {
    "ar": {
        "daily_growth": ("نمو يومي", "المبيعات اليوم أعلى بـ 16% من أمس"),
        "weekly_perf": ("أداء أسبوعي", "نمو أسبوعي 8.8% مقارنة بالأسبوع الماضي"),
        "top_product_insight": ("منتج مميز", "الحليب الطازج هو الأكثر مبيعاً بفارق كبير"),
        "top_actions": ["زيادة المخزون", "إضافة عروض bundle"],
        "stockout_insight": ("نفاد مخزون", "منتج واحد نفد من المخزون - زيت زيتون فلسطيني"),
        "stockout_actions": ["إعادة طلب فوري"],
        "top_products_data": {"top_1": "حليب طازج - 245 وحدة", "top_2": "خبز عربي - 198 وحدة", "top_3": "أرز بسمتي - 87 وحدة"},
        "executive_summary": "أداء جيد اليوم مع نمو 16% في المبيعات. يجب الانتباه لمخزون الزيت والحليب. الأسبوع الحالي أفضل من السابق بـ 8.8%.",
    },
    "en": {
        "daily_growth": ("Daily Growth", "Today's sales are 16% higher than yesterday"),
        "weekly_perf": ("Weekly Performance", "Weekly growth of 8.8% compared to last week"),
        "top_product_insight": ("Top Product", "Fresh Milk is the best seller by a significant margin"),
        "top_actions": ["Increase stock", "Add bundle offers"],
        "stockout_insight": ("Stock Out", "One product is out of stock - Palestinian Olive Oil"),
        "stockout_actions": ["Immediate reorder"],
        "top_products_data": {"top_1": "Fresh Milk - 245 units", "top_2": "Arabic Bread - 198 units", "top_3": "Basmati Rice - 87 units"},
        "executive_summary": "Good performance today with 16% sales growth. Pay attention to oil and milk stock. Current week is 8.8% better than last week.",
    },
}


def generate_report(org_id: str, store_id: str, report_type: str,
                    language: str = "ar") -> ReportResponse:
    s = _seed(org_id, store_id)
    now = datetime.now()
    lang_key = language if language in _REPORT_DATA else "ar"
    rd = _REPORT_DATA[lang_key]

    sections = [
        ReportSection(
            title=t("report_sales_summary", language),
            data={"today": 4520.0, "yesterday": 3890.0, "this_week": 28500.0, "last_week": 26200.0},
            insights=[
                ReportInsight(title=rd["daily_growth"][0], description=rd["daily_growth"][1], impact="positive", metric_value=4520, metric_change=16.2),
                ReportInsight(title=rd["weekly_perf"][0], description=rd["weekly_perf"][1], impact="positive", metric_value=28500, metric_change=8.8),
            ],
        ),
        ReportSection(
            title=t("report_top_products", language),
            data=rd["top_products_data"],
            insights=[
                ReportInsight(title=rd["top_product_insight"][0], description=rd["top_product_insight"][1], impact="positive", action_items=rd["top_actions"]),
            ],
        ),
        ReportSection(
            title=t("report_inventory_alerts", language),
            data={"low_stock": 5, "out_of_stock": 1, "overstock": 3},
            insights=[
                ReportInsight(title=rd["stockout_insight"][0], description=rd["stockout_insight"][1], impact="negative", action_items=rd["stockout_actions"]),
            ],
        ),
    ]

    return ReportResponse(
        report_type=report_type, generated_at=now.isoformat(),
        sections=sections,
        executive_summary=rd["executive_summary"],
        key_metrics={"daily_revenue": 4520.0, "weekly_revenue": 28500.0, "avg_basket": 67.5, "customer_count": 67, "return_rate": 2.1},
        is_mock_data=True,
        data_source="mock",
    )


# ============================================================================
# 9. STAFF ANALYTICS
# ============================================================================

_STAFF_DATA = {
    "ar": {
        "strengths": [
            ["سرعة في الخدمة", "دقة في الحساب"],
            ["خدمة عملاء ممتازة", "بيع إضافي"],
            ["الالتزام بالمواعيد"],
            ["ترتيب الرفوف", "إدارة المخزون"],
            ["العمل الجماعي"],
        ],
        "improvements": [
            ["التعامل مع الشكاوى"],
            ["السرعة في أوقات الذروة"],
            ["دقة الحساب", "سرعة الخدمة"],
            ["المبيعات المباشرة"],
            ["الحضور", "الإنتاجية"],
        ],
        "shift_recs": [
            "أحمد وسارة في وردية الذروة (5-9 مساءً) لأعلى أداء",
            "خالد ومحمد يوسف يحتاجان تدريب إضافي على نظام الكاشير",
            "فاطمة مثالية لإدارة المخزون في الوردية الصباحية",
        ],
    },
    "en": {
        "strengths": [
            ["Fast service", "Accurate billing"],
            ["Excellent customer service", "Upselling"],
            ["Punctuality"],
            ["Shelf organization", "Inventory management"],
            ["Teamwork"],
        ],
        "improvements": [
            ["Handling complaints"],
            ["Speed during peak hours"],
            ["Billing accuracy", "Service speed"],
            ["Direct sales"],
            ["Attendance", "Productivity"],
        ],
        "shift_recs": [
            "Ahmed and Sara for peak shift (5-9 PM) for best performance",
            "Khaled and Mohammed Youssef need additional POS training",
            "Fatima is ideal for inventory management in the morning shift",
        ],
    },
}


def analyze_staff(org_id: str, store_id: str,
                  language: str = "ar") -> StaffResponse:
    s = _seed(org_id, store_id)
    lang_key = language if language in _STAFF_DATA else "ar"
    sd = _STAFF_DATA[lang_key]

    emp_names = [t(f"emp_{i+1}", language) for i in range(5)]
    emp_numbers = [
        (12500, 185, 67.6, 92),
        (10800, 162, 66.7, 87),
        (8900, 148, 60.1, 78),
        (11200, 170, 65.9, 89),
        (7500, 125, 60.0, 72),
    ]

    employees = [EmployeePerformance(
        employee_id=f"emp_{i+1}", employee_name=emp_names[i],
        total_sales=ts, transaction_count=tc, avg_transaction_value=atv,
        performance_score=ps, rank=i+1,
        strengths=sd["strengths"][i], improvement_areas=sd["improvements"][i],
    ) for i, (ts, tc, atv, ps) in enumerate(emp_numbers)]

    return StaffResponse(
        employees=employees,
        summary=StaffSummary(
            total_employees=len(employees), avg_performance_score=83.6,
            top_performer=emp_names[0], total_revenue=50900.0, efficiency_index=0.87,
        ),
        shift_recommendations=sd["shift_recs"],
        is_mock_data=True,
        data_source="mock",
    )


# ============================================================================
# 10. PRODUCT RECOGNITION
# ============================================================================

_RECOGNITION_DATA = {
    "ar": {
        "barcode_product": ("حليب المراعي كامل الدسم 1 لتر", "ألبان"),
        "text_product": ("أرز بسمتي هندي 5 كجم", "حبوب"),
        "uncategorized": "غير مصنف",
        "image_product": ("عصير تروبيكانا برتقال 1 لتر", "مشروبات"),
    },
    "en": {
        "barcode_product": ("Almarai Full Fat Milk 1L", "Dairy"),
        "text_product": ("Indian Basmati Rice 5kg", "Grains"),
        "uncategorized": "Uncategorized",
        "image_product": ("Tropicana Orange Juice 1L", "Beverages"),
    },
}


def recognize_product(org_id: str, store_id: str, barcode: str | None,
                      description: str | None, language: str = "ar") -> RecognitionResponse:
    lang_key = language if language in _RECOGNITION_DATA else "ar"
    rd = _RECOGNITION_DATA[lang_key]

    if barcode:
        products = [RecognizedProduct(
            product_id="prod_42", name=rd["barcode_product"][0],
            category=rd["barcode_product"][1], confidence=0.98,
            suggested_price=6.50, barcode=barcode, is_new=False,
        )]
        method = "barcode"
    elif description:
        products = [
            RecognizedProduct(product_id="prod_15", name=rd["text_product"][0], category=rd["text_product"][1], confidence=0.82, suggested_price=28.0, barcode=None, is_new=False),
            RecognizedProduct(product_id=None, name=description, category=rd["uncategorized"], confidence=0.45, suggested_price=None, barcode=None, is_new=True),
        ]
        method = "text"
    else:
        products = [
            RecognizedProduct(product_id="prod_7", name=rd["image_product"][0], category=rd["image_product"][1], confidence=0.75, suggested_price=8.50, barcode="6281048123456", is_new=False),
        ]
        method = "image"

    return RecognitionResponse(
        products=products, processing_time_ms=245, method=method,
        is_mock_data=True, data_source="mock",
    )


# ============================================================================
# 11. SENTIMENT ANALYSIS
# ============================================================================

_SENTIMENT_REVIEWS = {
    "ar": [
        ("المتجر نظيف والموظفين محترمين", "إيجابي", 0.85, ["نظافة", "خدمة"]),
        ("الأسعار مرتفعة مقارنة بالمنافسين", "سلبي", -0.6, ["أسعار"]),
        ("تشكيلة جيدة لكن الازدحام مزعج", "محايد", 0.1, ["تشكيلة", "ازدحام"]),
        ("التوصيل سريع والمنتجات طازجة", "إيجابي", 0.9, ["توصيل", "جودة"]),
        ("موقف السيارات صغير جداً", "سلبي", -0.4, ["موقف"]),
        ("عروض ممتازة كل أسبوع", "إيجابي", 0.75, ["عروض"]),
        ("الخضار والفواكه طازجة دائماً", "إيجابي", 0.8, ["جودة", "خضار"]),
    ],
    "en": [
        ("Store is clean and staff are respectful", "Positive", 0.85, ["cleanliness", "service"]),
        ("Prices are high compared to competitors", "Negative", -0.6, ["prices"]),
        ("Good selection but the crowding is annoying", "Neutral", 0.1, ["selection", "crowding"]),
        ("Fast delivery and fresh products", "Positive", 0.9, ["delivery", "quality"]),
        ("Parking lot is too small", "Negative", -0.4, ["parking"]),
        ("Excellent offers every week", "Positive", 0.75, ["offers"]),
        ("Vegetables and fruits are always fresh", "Positive", 0.8, ["quality", "vegetables"]),
    ],
}

_TRENDING_TOPICS = {
    "ar": ["نظافة", "أسعار", "جودة", "خدمة"],
    "en": ["cleanliness", "prices", "quality", "service"],
}


def analyze_sentiment(org_id: str, store_id: str, text: str | None = None,
                      language: str = "ar") -> SentimentResponse:
    s = _seed(org_id, store_id)
    pos_label = t("sentiment_positive", language)
    neg_label = t("sentiment_negative", language)
    neu_label = t("sentiment_neutral", language)

    if text:
        positive_words = ["ممتاز", "رائع", "جيد", "سريع", "نظيف", "أحسن", "شكراً", "حلو", "طازج",
                          "excellent", "great", "good", "fast", "clean", "fresh", "best", "thanks"]
        negative_words = ["سيء", "بطيء", "غالي", "متأخر", "قديم", "فاسد", "رديء", "وسخ",
                          "bad", "slow", "expensive", "late", "old", "rotten", "poor", "dirty"]
        score = 0.0
        text_lower = text.lower()
        for w in positive_words:
            if w in text_lower: score += 0.3
        for w in negative_words:
            if w in text_lower: score -= 0.3
        score = max(-1, min(1, score))
        sentiment = pos_label if score > 0.1 else neg_label if score < -0.1 else neu_label
        results = [SentimentResult(text=text, sentiment=sentiment, score=round(score, 2), topics=["general"], source="direct")]
    else:
        lang_key = language if language in _SENTIMENT_REVIEWS else "ar"
        sample_reviews = _SENTIMENT_REVIEWS[lang_key]
        results = [SentimentResult(
            text=txt, sentiment=s_label, score=sc, topics=tp,
            timestamp=(datetime.now() - timedelta(days=i)).isoformat(), source="reviews",
        ) for i, (txt, s_label, sc, tp) in enumerate(sample_reviews)]

    # Count by translated labels
    lang_key = language if language in _SENTIMENT_REVIEWS else "ar"
    pos_labels = {t("sentiment_positive", language), "إيجابي", "Positive"}
    neg_labels = {t("sentiment_negative", language), "سلبي", "Negative"}

    pos = sum(1 for r in results if r.sentiment in pos_labels)
    neg = sum(1 for r in results if r.sentiment in neg_labels)
    neu = len(results) - pos - neg
    total = max(len(results), 1)

    trending = _TRENDING_TOPICS.get(lang_key, _TRENDING_TOPICS["ar"])

    return SentimentResponse(
        results=results,
        summary=SentimentSummary(
            positive_percent=round(pos / total * 100, 1),
            negative_percent=round(neg / total * 100, 1),
            neutral_percent=round(neu / total * 100, 1),
            avg_score=round(sum(r.score for r in results) / total, 2),
            total_analyzed=total,
            trending_topics=trending,
            overall_sentiment=pos_label if pos > neg else neg_label if neg > pos else neu_label,
        ),
        is_mock_data=True,
        data_source="mock",
    )


# ============================================================================
# 12. RETURN PREDICTION
# ============================================================================

def predict_returns(org_id: str, store_id: str, days_ahead: int = 30,
                    language: str = "ar") -> ReturnResponse:
    s = _seed(org_id, store_id)
    cat_keys = ["cat_mens_clothing", "cat_sports_shoes", "cat_electronics", "cat_food", "cat_cosmetics", "cat_household"]
    reason_keys = ["return_wrong_size", "return_quality_mismatch", "return_technical_defect", "return_near_expiry", "return_allergy", "return_manufacturing_defect"]
    numbers = [(0.18, 12, "high", 840.0), (0.15, 8, "high", 1200.0), (0.08, 5, "medium", 950.0),
               (0.03, 15, "medium", 320.0), (0.12, 6, "medium", 480.0), (0.05, 3, "low", 180.0)]

    predictions = [ReturnPrediction(
        product_id=f"cat_{i}", product_name=t(cat_keys[i], language),
        return_probability=prob, expected_returns=er,
        main_reason=t(reason_keys[i], language), risk_level=rl, cost_impact=ci,
    ) for i, (prob, er, rl, ci) in enumerate(numbers)]

    total_returns = sum(p.expected_returns for p in predictions)
    total_cost = sum(p.cost_impact for p in predictions)

    return ReturnResponse(
        predictions=predictions,
        summary=ReturnSummary(
            total_expected_returns=total_returns, total_cost_impact=total_cost,
            high_risk_products=2, top_return_reason=t("return_wrong_size", language),
            return_rate_trend=t("trend_stable", language),
        ),
        prevention_tips=[
            t("tip_size_chart", language),
            t("tip_quality_check", language),
            t("tip_expiry_display", language),
            t("tip_cosmetics_samples", language),
        ],
        is_mock_data=True,
        data_source="mock",
    )


# ============================================================================
# 13. PROMOTION DESIGNER
# ============================================================================

_PROMO_DATA = {
    "ar": {
        "titles_ar": ["عرض نهاية الأسبوع", "اشترِ 2 واحصل على 1 مجاناً", "سلة العائلة", "مكافأة الولاء"],
        "descriptions": [
            "خصم 20% على الألبان والمخبوزات الخميس والجمعة",
            "عرض على المشروبات - اشترِ 2 واحصل على الثالث مجاناً",
            "باقة عائلية: أرز + زيت + بهارات بسعر مخفض 15%",
            "نقاط مضاعفة لعملاء VIP هذا الأسبوع",
        ],
        "targets": [["ألبان", "مخبوزات"], ["مشروبات"], ["أرز بسمتي", "زيت طبخ", "بهارات"], ["جميع المنتجات"]],
        "best_timing": "الخميس والجمعة - أعلى حركة مرور",
        "target_audience": "العائلات والعملاء المنتظمون",
    },
    "en": {
        "titles_ar": ["Weekend Special", "Buy 2 Get 1 Free", "Family Basket", "Loyalty Bonus"],
        "descriptions": [
            "20% off dairy and bakery on Thursday and Friday",
            "Buy 2 beverages and get the 3rd free",
            "Family bundle: Rice + Oil + Spices at 15% off",
            "Double loyalty points for VIP customers this week",
        ],
        "targets": [["Dairy", "Bakery"], ["Beverages"], ["Basmati Rice", "Cooking Oil", "Spices"], ["All Products"]],
        "best_timing": "Thursday and Friday - highest foot traffic",
        "target_audience": "Families and regular customers",
    },
}


def design_promotions(org_id: str, store_id: str, goal: str,
                      duration_days: int = 7, language: str = "ar") -> PromotionResponse:
    s = _seed(org_id, store_id)
    lang_key = language if language in _PROMO_DATA else "ar"
    pd = _PROMO_DATA[lang_key]
    titles_en = ["Weekend Special", "Buy 2 Get 1", "Basket Bundle", "Loyalty Bonus"]
    types = ["discount", "bogo", "bundle", "loyalty"]
    discounts = [20.0, None, 15.0, None]
    rev_inc = [15.0, 22.0, 12.0, 8.0]
    traffic_inc = [25.0, 18.0, 10.0, 5.0]
    costs = [500.0, 800.0, 350.0, 200.0]
    rois = [3.2, 2.8, 4.1, 5.5]

    promos = [PromotionSuggestion(
        title=titles_en[i], title_ar=pd["titles_ar"][i],
        description=pd["descriptions"][i],
        type=types[i], discount_percent=discounts[i],
        target_products=pd["targets"][i],
        expected_revenue_increase=rev_inc[i], expected_traffic_increase=traffic_inc[i],
        estimated_cost=costs[i], roi=rois[i], priority=i+1,
    ) for i in range(4)]

    return PromotionResponse(
        promotions=promos, best_timing=pd["best_timing"],
        target_audience=pd["target_audience"],
        estimated_total_roi=round(sum(rois) / len(rois), 1),
        is_mock_data=True,
        data_source="mock",
    )


# ============================================================================
# 14. CHAT WITH DATA
# ============================================================================

_CHAT_RESPONSES = {
    "ar": {
        "sales": {
            "reply": "مبيعات اليوم بلغت 4,520 ر.س بزيادة 16% عن أمس. أعلى ساعة مبيعات كانت من 6-7 مساءً بقيمة 890 ر.س.",
            "labels": ["اليوم", "أمس", "متوسط الأسبوع"],
            "suggestions": ["ما هي أفضل المنتجات مبيعاً؟", "قارن مبيعات هذا الأسبوع بالسابق", "ما هي ساعات الذروة؟"],
        },
        "inventory": {
            "reply": "لديك 5 منتجات بمخزون منخفض تحتاج إعادة طلب. أهمها: حليب طازج (12 وحدة متبقية) وخبز عربي (8 وحدات). المخزون الكلي بقيمة 125,000 ر.س.",
            "labels": ["منخفض", "نفد", "جيد"],
            "unit": "منتج",
            "suggestions": ["ما المنتجات الراكدة؟", "متى يجب إعادة طلب الحليب؟", "ما قيمة المخزون الراكد؟"],
        },
        "staff": {
            "reply": "أفضل موظف أداءً هذا الشهر هو أحمد محمد بتقييم 92/100 ومبيعات 12,500 ر.س. متوسط أداء الفريق 83.6%.",
            "suggestions": ["من يحتاج تدريب؟", "ما أفضل توزيع للورديات؟", "قارن أداء الشهر الحالي بالسابق"],
        },
    },
    "en": {
        "sales": {
            "reply": "Today's sales reached 4,520 SAR, a 16% increase from yesterday. Peak sales hour was 6-7 PM with 890 SAR.",
            "labels": ["Today", "Yesterday", "Week Average"],
            "suggestions": ["What are the best-selling products?", "Compare this week's sales to last week", "What are the peak hours?"],
        },
        "inventory": {
            "reply": "You have 5 low-stock products that need reordering. Most critical: Fresh Milk (12 units remaining) and Arabic Bread (8 units). Total inventory value: 125,000 SAR.",
            "labels": ["Low", "Out", "Good"],
            "unit": "product",
            "suggestions": ["What are the dead stock items?", "When should I reorder milk?", "What's the dead stock value?"],
        },
        "staff": {
            "reply": "Best performing employee this month is Ahmed Mohammed with a score of 92/100 and 12,500 SAR in sales. Team average performance: 83.6%.",
            "suggestions": ["Who needs training?", "What's the best shift schedule?", "Compare this month's performance to last month"],
        },
    },
}


def chat_with_data(org_id: str, store_id: str, message: str,
                   conversation_id: str | None = None,
                   language: str = "ar") -> ChatResponse:
    s = _seed(org_id, store_id)
    conv_id = conversation_id or f"conv_{s % 10000}"
    msg_lower = message.lower()
    lang_key = language if language in _CHAT_RESPONSES else "ar"
    cr = _CHAT_RESPONSES[lang_key]
    cur = get_currency_symbol(language)

    if any(w in msg_lower for w in ["مبيعات", "sales", "إيراد", "revenue"]):
        d = cr["sales"]
        return ChatResponse(
            reply=d["reply"],
            data=[
                ChatDataPoint(label=d["labels"][0], value=4520, unit=cur),
                ChatDataPoint(label=d["labels"][1], value=3890, unit=cur),
                ChatDataPoint(label=d["labels"][2], value=4071, unit=cur),
            ],
            chart_type="bar", suggestions=d["suggestions"], conversation_id=conv_id,
            is_mock_data=True, data_source="mock",
        )
    elif any(w in msg_lower for w in ["مخزون", "inventory", "stock", "منتج"]):
        d = cr["inventory"]
        return ChatResponse(
            reply=d["reply"],
            data=[
                ChatDataPoint(label=d["labels"][0], value=5, unit=d["unit"]),
                ChatDataPoint(label=d["labels"][1], value=1, unit=d["unit"]),
                ChatDataPoint(label=d["labels"][2], value=194, unit=d["unit"]),
            ],
            chart_type="pie", suggestions=d["suggestions"], conversation_id=conv_id,
            is_mock_data=True, data_source="mock",
        )
    elif any(w in msg_lower for w in ["موظف", "staff", "أداء", "كاشير", "employee"]):
        d = cr["staff"]
        emp_names = [t(f"emp_{i+1}", language) for i in range(4)]
        return ChatResponse(
            reply=d["reply"],
            data=[
                ChatDataPoint(label=emp_names[0], value=92, unit="pts"),
                ChatDataPoint(label=emp_names[1], value=87, unit="pts"),
                ChatDataPoint(label=emp_names[3], value=89, unit="pts"),
                ChatDataPoint(label=emp_names[2], value=78, unit="pts"),
            ],
            chart_type="bar", suggestions=d["suggestions"], conversation_id=conv_id,
            is_mock_data=True, data_source="mock",
        )
    else:
        return ChatResponse(
            reply=t("greeting", language),
            data=None, chart_type=None,
            suggestions=[
                t("suggest_today_sales", language),
                t("suggest_inventory_status", language),
                t("suggest_best_employee", language),
                t("suggest_next_week_forecast", language),
            ],
            conversation_id=conv_id,
            is_mock_data=True, data_source="mock",
        )


# ============================================================================
# 15. ASSISTANT
# ============================================================================

_ASSISTANT_DATA = {
    "ar": {
        "sales_answer": "مبيعات اليوم 4,520 ر.س من 67 عملية بيع. الأداء أعلى من المتوسط بـ 11%. أوقات الذروة: 5-7 مساءً.",
        "sales_actions": [
            ("view_sales", "عرض تفاصيل المبيعات", "/sales"),
            ("view_forecast", "عرض التوقعات", "/ai/forecast"),
        ],
        "sales_topics": ["توقعات المبيعات", "أفضل المنتجات", "تحليل العملاء"],
        "inv_answer": "5 منتجات بحاجة لإعادة طلب عاجل. حليب طازج وخبز عربي بأولوية قصوى. إجمالي قيمة المخزون المنخفض: 3,200 ر.س.",
        "inv_actions": [
            ("view_inventory", "عرض المخزون", "/inventory"),
            ("create_order", "إنشاء طلب شراء", "/purchases/new"),
        ],
        "inv_topics": ["المخزون الذكي", "طلبات الشراء", "الموردين"],
        "default_actions": [
            ("sales_summary", "ملخص المبيعات", "/ai/reports"),
            ("inventory_check", "فحص المخزون", "/ai/inventory"),
            ("staff_report", "تقرير الموظفين", "/ai/staff"),
        ],
        "default_topics": ["المبيعات", "المخزون", "الموظفين", "العملاء"],
    },
    "en": {
        "sales_answer": "Today's sales: 4,520 SAR from 67 transactions. Performance is 11% above average. Peak hours: 5-7 PM.",
        "sales_actions": [
            ("view_sales", "View Sales Details", "/sales"),
            ("view_forecast", "View Forecast", "/ai/forecast"),
        ],
        "sales_topics": ["Sales Forecast", "Top Products", "Customer Analysis"],
        "inv_answer": "5 products need urgent reordering. Fresh Milk and Arabic Bread are critical priority. Total low-stock value: 3,200 SAR.",
        "inv_actions": [
            ("view_inventory", "View Inventory", "/inventory"),
            ("create_order", "Create Purchase Order", "/purchases/new"),
        ],
        "inv_topics": ["Smart Inventory", "Purchase Orders", "Suppliers"],
        "default_actions": [
            ("sales_summary", "Sales Summary", "/ai/reports"),
            ("inventory_check", "Check Inventory", "/ai/inventory"),
            ("staff_report", "Staff Report", "/ai/staff"),
        ],
        "default_topics": ["Sales", "Inventory", "Staff", "Customers"],
    },
}


def get_assistant_response(org_id: str, store_id: str, query: str,
                           context: str = "general",
                           language: str = "ar") -> AssistantResponse:
    s = _seed(org_id, store_id)
    q_lower = query.lower()
    lang_key = language if language in _ASSISTANT_DATA else "ar"
    ad = _ASSISTANT_DATA[lang_key]

    if any(w in q_lower for w in ["مبيعات", "بيع", "فاتورة", "sales", "revenue", "invoice"]):
        return AssistantResponse(
            answer=ad["sales_answer"], confidence=0.92,
            data={"today_sales": 4520, "transactions": 67, "avg_transaction": 67.5},
            actions=[SuggestedAction(action=a, label=l, route=r) for a, l, r in ad["sales_actions"]],
            related_topics=ad["sales_topics"],
            is_mock_data=True, data_source="mock",
        )
    elif any(w in q_lower for w in ["مخزون", "نقص", "طلب", "inventory", "stock", "order"]):
        return AssistantResponse(
            answer=ad["inv_answer"], confidence=0.88,
            data={"low_stock": 5, "critical": 2, "total_value": 3200},
            actions=[SuggestedAction(action=a, label=l, route=r) for a, l, r in ad["inv_actions"]],
            related_topics=ad["inv_topics"],
            is_mock_data=True, data_source="mock",
        )
    else:
        return AssistantResponse(
            answer=t("assistant_greeting", language), confidence=0.95,
            data=None,
            actions=[SuggestedAction(action=a, label=l, route=r) for a, l, r in ad["default_actions"]],
            related_topics=ad["default_topics"],
            is_mock_data=True, data_source="mock",
        )
