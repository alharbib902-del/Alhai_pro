"""
ML Service - خدمة التعلم الآلي
Returns realistic dummy data based on input parameters.
Uses deterministic seeding for consistent results per org/store.
"""

import hashlib
import math
from datetime import datetime, timedelta

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
                      product_ids: list[str] | None = None) -> ForecastResponse:
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
    trend_labels = {"up": "اتجاه صاعد 📈", "down": "اتجاه هابط 📉", "stable": "مستقر ➡️"}

    return ForecastResponse(
        predictions=predictions,
        summary=ForecastSummary(
            total_revenue=round(total_rev, 2),
            trend=trend,
            trend_label=trend_labels[trend],
            avg_daily_revenue=round(avg_daily, 2),
            peak_day=predictions[peak_idx].date,
        ),
        accuracy=round(0.82 + _pseudo_random(s, 99) * 0.12, 2),
    )


# ============================================================================
# 2. SMART PRICING
# ============================================================================

def generate_pricing(org_id: str, store_id: str, product_ids: list[str] | None,
                     strategy: str) -> PricingResponse:
    s = _seed(org_id, store_id)
    products = product_ids or [f"prod_{i}" for i in range(1, 8)]
    names_ar = ["حليب طازج", "خبز عربي", "أرز بسمتي", "زيت زيتون", "سكر أبيض", "شاي أحمر", "صابون يد"]
    suggestions = []

    for i, pid in enumerate(products):
        current = round(10 + _pseudo_random(s, i) * 90, 2)
        change = (_pseudo_random(s, i + 50) - 0.4) * 15
        suggested = round(max(current * 0.7, current + change), 2)
        reasons = [
            f"الطلب مرتفع - يمكن رفع السعر {abs(change):.0f}%",
            f"سعر المنافسين أقل - خفض السعر {abs(change):.0f}% للمنافسة",
            f"مرونة سعرية منخفضة - السعر الحالي مناسب مع تعديل طفيف",
            f"موسم ذروة - فرصة لرفع الهامش {abs(change):.0f}%",
        ]
        suggestions.append(PricingSuggestion(
            product_id=pid,
            product_name=names_ar[i % len(names_ar)],
            current_price=current,
            suggested_price=suggested,
            min_price=round(current * 0.7, 2),
            max_price=round(current * 1.4, 2),
            expected_revenue_change=round(change, 1),
            reason=reasons[i % len(reasons)],
            confidence=round(0.7 + _pseudo_random(s, i + 80) * 0.25, 2),
        ))

    total_increase = sum(sg.expected_revenue_change for sg in suggestions) / max(len(suggestions), 1)
    return PricingResponse(
        suggestions=suggestions,
        total_potential_increase=round(total_increase, 1),
        strategy_used=strategy,
    )


# ============================================================================
# 3. FRAUD DETECTION
# ============================================================================

def detect_fraud(org_id: str, store_id: str, sale_id: str | None = None) -> FraudResponse:
    s = _seed(org_id, store_id)
    now = datetime.now()
    alerts = []
    reasons_ar = [
        "عملية بيع بقيمة مرتفعة بشكل غير طبيعي",
        "خصم متكرر من نفس الكاشير خلال ساعة",
        "إلغاء عمليات متعددة في وقت قصير",
        "بيع خارج ساعات العمل المعتادة",
        "كمية غير طبيعية لمنتج واحد",
        "استخدام خصم يدوي مرتفع",
        "نمط إرجاع مشبوه - نفس المنتج عدة مرات",
    ]
    patterns_ar = ["قيمة_مرتفعة", "خصم_متكرر", "إلغاء_متعدد", "وقت_غير_معتاد", "كمية_مشبوهة"]
    count = 3 + int(_pseudo_random(s, 0) * 8)

    for i in range(count):
        risk = round(0.3 + _pseudo_random(s, i + 20) * 0.7, 2)
        level = "high" if risk > 0.7 else "medium" if risk > 0.4 else "low"
        ts = now - timedelta(hours=int(_pseudo_random(s, i + 30) * 72))
        alerts.append(FraudAlert(
            sale_id=sale_id or f"sale_{1000 + i}",
            risk_score=risk,
            risk_level=level,
            reason=reasons_ar[i % len(reasons_ar)],
            timestamp=ts.isoformat(),
            cashier_id=f"emp_{int(_pseudo_random(s, i + 40) * 5) + 1}",
            amount=round(50 + _pseudo_random(s, i + 50) * 2000, 2),
            patterns=[patterns_ar[i % len(patterns_ar)]],
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
            period="آخر 72 ساعة",
        ),
    )


# ============================================================================
# 4. BASKET ANALYSIS
# ============================================================================

def analyze_basket(org_id: str, store_id: str, top_n: int = 20) -> BasketResponse:
    s = _seed(org_id, store_id)
    product_pairs = [
        (["خبز", "جبن"], ["حليب"], "من يشتري خبز وجبن غالباً يشتري حليب"),
        (["أرز"], ["زيت طبخ", "بهارات"], "الأرز يُشترى مع زيت الطبخ والبهارات"),
        (["شاي"], ["سكر"], "الشاي والسكر يُشتريان معاً بنسبة عالية"),
        (["حفاضات"], ["مناديل مبللة"], "مستلزمات الأطفال تُشترى معاً"),
        (["دجاج"], ["ثوم", "بصل"], "الدجاج يُشترى مع التوابل الأساسية"),
        (["معكرونة"], ["صلصة طماطم"], "المعكرونة والصلصة زوج كلاسيكي"),
        (["قهوة"], ["كريمة", "سكر"], "القهوة تُشترى مع الكريمة والسكر"),
        (["شامبو"], ["بلسم"], "منتجات العناية بالشعر تُشترى معاً"),
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

    fbt = [["خبز", "جبن", "حليب"], ["أرز", "زيت", "بهارات"], ["شاي", "سكر", "بسكويت"]]
    return BasketResponse(
        rules=sorted(rules, key=lambda r: r.lift, reverse=True),
        summary=BasketSummary(
            avg_basket_size=round(3.2 + _pseudo_random(s, 100) * 2, 1),
            avg_basket_value=round(45 + _pseudo_random(s, 101) * 80, 2),
            total_transactions_analyzed=int(500 + _pseudo_random(s, 102) * 4500),
            top_product="خبز عربي",
            cross_sell_opportunity="إضافة رف الجبن بجانب الخبز سيزيد المبيعات ~15%",
        ),
        frequently_bought_together=fbt,
    )


# ============================================================================
# 5. CUSTOMER RECOMMENDATIONS
# ============================================================================

def generate_recommendations(org_id: str, store_id: str, customer_id: str | None,
                             top_n: int = 10) -> RecommendationResponse:
    s = _seed(org_id, store_id)
    products = [
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
    ]

    recs = []
    for i, (name, cat, reason) in enumerate(products[:top_n]):
        recs.append(ProductRecommendation(
            product_id=f"prod_{100 + i}",
            product_name=name, score=round(0.95 - i * 0.05, 2),
            reason=reason, category=cat,
            expected_purchase_probability=round(0.85 - i * 0.06, 2),
        ))

    segments = [
        CustomerSegment(segment_id="seg_1", name="عملاء VIP", description="عملاء ذوو إنفاق مرتفع ومتكرر", customer_count=45, avg_spend=850.0),
        CustomerSegment(segment_id="seg_2", name="عملاء منتظمون", description="يتسوقون أسبوعياً بمبالغ متوسطة", customer_count=320, avg_spend=280.0),
        CustomerSegment(segment_id="seg_3", name="عملاء عابرون", description="مشتريات قليلة وغير منتظمة", customer_count=180, avg_spend=65.0),
    ]

    return RecommendationResponse(
        recommendations=recs, customer_segments=segments,
        personalization_score=round(0.7 + _pseudo_random(s, 200) * 0.25, 2),
    )


# ============================================================================
# 6. SMART INVENTORY
# ============================================================================

def analyze_inventory(org_id: str, store_id: str) -> InventoryResponse:
    s = _seed(org_id, store_id)
    items = [
        ("حليب طازج", 12, 25, 50, 3, "critical", "مخزون منخفض جداً - خطر نفاد خلال 3 أيام"),
        ("خبز عربي", 8, 20, 40, 2, "critical", "يجب إعادة الطلب فوراً"),
        ("أرز بسمتي", 45, 30, 60, 15, "medium", "مخزون كافٍ لأسبوعين"),
        ("زيت زيتون", 5, 15, 30, 4, "high", "مخزون منخفض - أعد الطلب هذا الأسبوع"),
        ("سكر أبيض", 80, 40, 100, 25, "low", "مخزون جيد"),
        ("شاي أحمر", 18, 20, 40, 6, "high", "قارب على نقطة إعادة الطلب"),
        ("صابون يد", 100, 30, 60, 45, "low", "مخزون زائد - فرصة لعرض خاص"),
    ]

    alerts = [InventoryAlert(
        product_id=f"prod_{i}", product_name=n,
        current_stock=cs, reorder_point=rp, suggested_order_qty=sq,
        days_until_stockout=ds, priority=p, reason=r,
    ) for i, (n, cs, rp, sq, ds, p, r) in enumerate(items)]

    return InventoryResponse(
        alerts=sorted(alerts, key=lambda a: {"critical": 0, "high": 1, "medium": 2, "low": 3}[a.priority]),
        optimization=InventoryOptimization(
            overstock_items=2, understock_items=3, optimal_items=15,
            potential_savings=round(2500 + _pseudo_random(s, 300) * 5000, 2),
            dead_stock_value=round(800 + _pseudo_random(s, 301) * 3000, 2),
        ),
        abc_classification={"A": 25, "B": 45, "C": 130},
    )


# ============================================================================
# 7. COMPETITOR ANALYSIS
# ============================================================================

def analyze_competitors(org_id: str, store_id: str) -> CompetitorResponse:
    s = _seed(org_id, store_id)
    competitors = [
        CompetitorInfo(
            name="سوبرماركت الرياض", distance_km=1.2, price_index=0.95,
            strengths=["أسعار أقل 5%", "موقف سيارات واسع"],
            weaknesses=["خدمة بطيئة", "تنوع محدود"], threat_level="high",
        ),
        CompetitorInfo(
            name="بقالة النور", distance_km=0.5, price_index=1.05,
            strengths=["قريب من الحي السكني", "خدمة توصيل"],
            weaknesses=["أسعار أعلى", "مساحة صغيرة"], threat_level="medium",
        ),
        CompetitorInfo(
            name="هايبر ماركت الوطن", distance_km=3.8, price_index=0.88,
            strengths=["عروض قوية", "تشكيلة واسعة جداً"],
            weaknesses=["بعيد", "ازدحام في عطلة نهاية الأسبوع"], threat_level="medium",
        ),
    ]

    comparisons = [
        PriceComparison(product_name="حليب 1 لتر", your_price=6.5, avg_competitor_price=6.2, price_position="أغلى", recommendation="خفض السعر 0.3 ر.س للمنافسة"),
        PriceComparison(product_name="أرز 5 كجم", your_price=28.0, avg_competitor_price=30.5, price_position="أرخص", recommendation="ميزة تنافسية - أبرز هذا السعر"),
        PriceComparison(product_name="زيت زيتون 1 لتر", your_price=35.0, avg_competitor_price=34.0, price_position="متوسط", recommendation="السعر ضمن النطاق المقبول"),
    ]

    return CompetitorResponse(
        competitors=competitors, price_comparisons=comparisons,
        market_position="متوسط - لديك ميزة في بعض المنتجات وفرصة تحسين في أخرى",
        opportunities=["تحسين خدمة التوصيل", "برنامج ولاء للعملاء المتكررين", "عروض أسبوعية على المنتجات الأساسية"],
    )


# ============================================================================
# 8. SMART REPORTS
# ============================================================================

def generate_report(org_id: str, store_id: str, report_type: str) -> ReportResponse:
    s = _seed(org_id, store_id)
    now = datetime.now()
    sections = [
        ReportSection(
            title="ملخص المبيعات",
            data={"today": 4520.0, "yesterday": 3890.0, "this_week": 28500.0, "last_week": 26200.0},
            insights=[
                ReportInsight(title="نمو يومي", description="المبيعات اليوم أعلى بـ 16% من أمس", impact="positive", metric_value=4520, metric_change=16.2),
                ReportInsight(title="أداء أسبوعي", description="نمو أسبوعي 8.8% مقارنة بالأسبوع الماضي", impact="positive", metric_value=28500, metric_change=8.8),
            ],
        ),
        ReportSection(
            title="أفضل المنتجات",
            data={"top_1": "حليب طازج - 245 وحدة", "top_2": "خبز عربي - 198 وحدة", "top_3": "أرز بسمتي - 87 وحدة"},
            insights=[
                ReportInsight(title="منتج مميز", description="الحليب الطازج هو الأكثر مبيعاً بفارق كبير", impact="positive", action_items=["زيادة المخزون", "إضافة عروض bundle"]),
            ],
        ),
        ReportSection(
            title="تنبيهات المخزون",
            data={"low_stock": 5, "out_of_stock": 1, "overstock": 3},
            insights=[
                ReportInsight(title="نفاد مخزون", description="منتج واحد نفد من المخزون - زيت زيتون فلسطيني", impact="negative", action_items=["إعادة طلب فوري"]),
            ],
        ),
    ]

    return ReportResponse(
        report_type=report_type, generated_at=now.isoformat(),
        sections=sections,
        executive_summary="أداء جيد اليوم مع نمو 16% في المبيعات. يجب الانتباه لمخزون الزيت والحليب. الأسبوع الحالي أفضل من السابق بـ 8.8%.",
        key_metrics={"daily_revenue": 4520.0, "weekly_revenue": 28500.0, "avg_basket": 67.5, "customer_count": 67, "return_rate": 2.1},
    )


# ============================================================================
# 9. STAFF ANALYTICS
# ============================================================================

def analyze_staff(org_id: str, store_id: str) -> StaffResponse:
    s = _seed(org_id, store_id)
    employees_data = [
        ("أحمد محمد", 12500, 185, 67.6, 92, ["سرعة في الخدمة", "دقة في الحساب"], ["التعامل مع الشكاوى"]),
        ("سارة علي", 10800, 162, 66.7, 87, ["خدمة عملاء ممتازة", "بيع إضافي"], ["السرعة في أوقات الذروة"]),
        ("خالد حسن", 8900, 148, 60.1, 78, ["الالتزام بالمواعيد"], ["دقة الحساب", "سرعة الخدمة"]),
        ("فاطمة أحمد", 11200, 170, 65.9, 89, ["ترتيب الرفوف", "إدارة المخزون"], ["المبيعات المباشرة"]),
        ("محمد يوسف", 7500, 125, 60.0, 72, ["العمل الجماعي"], ["الحضور", "الإنتاجية"]),
    ]

    employees = [EmployeePerformance(
        employee_id=f"emp_{i+1}", employee_name=n,
        total_sales=ts, transaction_count=tc, avg_transaction_value=atv,
        performance_score=ps, rank=i+1, strengths=st, improvement_areas=ia,
    ) for i, (n, ts, tc, atv, ps, st, ia) in enumerate(employees_data)]

    return StaffResponse(
        employees=employees,
        summary=StaffSummary(
            total_employees=len(employees), avg_performance_score=83.6,
            top_performer="أحمد محمد", total_revenue=50900.0, efficiency_index=0.87,
        ),
        shift_recommendations=[
            "أحمد وسارة في وردية الذروة (5-9 مساءً) لأعلى أداء",
            "خالد ومحمد يوسف يحتاجان تدريب إضافي على نظام الكاشير",
            "فاطمة مثالية لإدارة المخزون في الوردية الصباحية",
        ],
    )


# ============================================================================
# 10. PRODUCT RECOGNITION
# ============================================================================

def recognize_product(org_id: str, store_id: str, barcode: str | None,
                      description: str | None) -> RecognitionResponse:
    if barcode:
        products = [RecognizedProduct(
            product_id="prod_42", name="حليب المراعي كامل الدسم 1 لتر",
            category="ألبان", confidence=0.98,
            suggested_price=6.50, barcode=barcode, is_new=False,
        )]
        method = "barcode"
    elif description:
        products = [
            RecognizedProduct(product_id="prod_15", name="أرز بسمتي هندي 5 كجم", category="حبوب", confidence=0.82, suggested_price=28.0, barcode=None, is_new=False),
            RecognizedProduct(product_id=None, name=description, category="غير مصنف", confidence=0.45, suggested_price=None, barcode=None, is_new=True),
        ]
        method = "text"
    else:
        products = [
            RecognizedProduct(product_id="prod_7", name="عصير تروبيكانا برتقال 1 لتر", category="مشروبات", confidence=0.75, suggested_price=8.50, barcode="6281048123456", is_new=False),
        ]
        method = "image"

    return RecognitionResponse(products=products, processing_time_ms=245, method=method)


# ============================================================================
# 11. SENTIMENT ANALYSIS
# ============================================================================

def analyze_sentiment(org_id: str, store_id: str, text: str | None = None) -> SentimentResponse:
    s = _seed(org_id, store_id)

    if text:
        # Analyze single text
        positive_words = ["ممتاز", "رائع", "جيد", "سريع", "نظيف", "أحسن", "شكراً", "حلو", "طازج"]
        negative_words = ["سيء", "بطيء", "غالي", "متأخر", "قديم", "فاسد", "رديء", "وسخ"]
        score = 0.0
        for w in positive_words:
            if w in text: score += 0.3
        for w in negative_words:
            if w in text: score -= 0.3
        score = max(-1, min(1, score))
        sentiment = "إيجابي" if score > 0.1 else "سلبي" if score < -0.1 else "محايد"
        results = [SentimentResult(text=text, sentiment=sentiment, score=round(score, 2), topics=["عام"], source="direct")]
    else:
        sample_reviews = [
            ("المتجر نظيف والموظفين محترمين", "إيجابي", 0.85, ["نظافة", "خدمة"]),
            ("الأسعار مرتفعة مقارنة بالمنافسين", "سلبي", -0.6, ["أسعار"]),
            ("تشكيلة جيدة لكن الازدحام مزعج", "محايد", 0.1, ["تشكيلة", "ازدحام"]),
            ("التوصيل سريع والمنتجات طازجة", "إيجابي", 0.9, ["توصيل", "جودة"]),
            ("موقف السيارات صغير جداً", "سلبي", -0.4, ["موقف"]),
            ("عروض ممتازة كل أسبوع", "إيجابي", 0.75, ["عروض"]),
            ("الخضار والفواكه طازجة دائماً", "إيجابي", 0.8, ["جودة", "خضار"]),
        ]
        results = [SentimentResult(
            text=t, sentiment=s_label, score=sc, topics=tp,
            timestamp=(datetime.now() - timedelta(days=i)).isoformat(), source="reviews",
        ) for i, (t, s_label, sc, tp) in enumerate(sample_reviews)]

    pos = sum(1 for r in results if r.sentiment == "إيجابي")
    neg = sum(1 for r in results if r.sentiment == "سلبي")
    neu = sum(1 for r in results if r.sentiment == "محايد")
    total = max(len(results), 1)

    return SentimentResponse(
        results=results,
        summary=SentimentSummary(
            positive_percent=round(pos / total * 100, 1),
            negative_percent=round(neg / total * 100, 1),
            neutral_percent=round(neu / total * 100, 1),
            avg_score=round(sum(r.score for r in results) / total, 2),
            total_analyzed=total,
            trending_topics=["نظافة", "أسعار", "جودة", "خدمة"],
            overall_sentiment="إيجابي" if pos > neg else "سلبي" if neg > pos else "محايد",
        ),
    )


# ============================================================================
# 12. RETURN PREDICTION
# ============================================================================

def predict_returns(org_id: str, store_id: str, days_ahead: int = 30) -> ReturnResponse:
    s = _seed(org_id, store_id)
    items = [
        ("ملابس رجالية", 0.18, 12, "مقاس غير مناسب", "high", 840.0),
        ("أحذية رياضية", 0.15, 8, "جودة غير مطابقة", "high", 1200.0),
        ("إلكترونيات", 0.08, 5, "عطل فني", "medium", 950.0),
        ("مواد غذائية", 0.03, 15, "قرب انتهاء الصلاحية", "medium", 320.0),
        ("مستحضرات تجميل", 0.12, 6, "حساسية", "medium", 480.0),
        ("أدوات منزلية", 0.05, 3, "عيب في التصنيع", "low", 180.0),
    ]

    predictions = [ReturnPrediction(
        product_id=f"cat_{i}", product_name=n,
        return_probability=prob, expected_returns=er,
        main_reason=reason, risk_level=rl, cost_impact=ci,
    ) for i, (n, prob, er, reason, rl, ci) in enumerate(items)]

    total_returns = sum(p.expected_returns for p in predictions)
    total_cost = sum(p.cost_impact for p in predictions)

    return ReturnResponse(
        predictions=predictions,
        summary=ReturnSummary(
            total_expected_returns=total_returns, total_cost_impact=total_cost,
            high_risk_products=2, top_return_reason="مقاس غير مناسب",
            return_rate_trend="مستقر",
        ),
        prevention_tips=[
            "إضافة جدول مقاسات تفصيلي للملابس والأحذية",
            "فحص جودة الإلكترونيات قبل التسليم",
            "عرض تواريخ الصلاحية بشكل واضح",
            "توفير عينات تجريبية لمستحضرات التجميل",
        ],
    )


# ============================================================================
# 13. PROMOTION DESIGNER
# ============================================================================

def design_promotions(org_id: str, store_id: str, goal: str,
                      duration_days: int = 7) -> PromotionResponse:
    s = _seed(org_id, store_id)
    promos = [
        PromotionSuggestion(
            title="Weekend Special", title_ar="عرض نهاية الأسبوع",
            description="خصم 20% على الألبان والمخبوزات الخميس والجمعة",
            type="discount", discount_percent=20.0,
            target_products=["ألبان", "مخبوزات"],
            expected_revenue_increase=15.0, expected_traffic_increase=25.0,
            estimated_cost=500.0, roi=3.2, priority=1,
        ),
        PromotionSuggestion(
            title="Buy 2 Get 1", title_ar="اشترِ 2 واحصل على 1 مجاناً",
            description="عرض على المشروبات - اشترِ 2 واحصل على الثالث مجاناً",
            type="bogo", discount_percent=None,
            target_products=["مشروبات"],
            expected_revenue_increase=22.0, expected_traffic_increase=18.0,
            estimated_cost=800.0, roi=2.8, priority=2,
        ),
        PromotionSuggestion(
            title="Basket Bundle", title_ar="سلة العائلة",
            description="باقة عائلية: أرز + زيت + بهارات بسعر مخفض 15%",
            type="bundle", discount_percent=15.0,
            target_products=["أرز بسمتي", "زيت طبخ", "بهارات"],
            expected_revenue_increase=12.0, expected_traffic_increase=10.0,
            estimated_cost=350.0, roi=4.1, priority=3,
        ),
        PromotionSuggestion(
            title="Loyalty Bonus", title_ar="مكافأة الولاء",
            description="نقاط مضاعفة لعملاء VIP هذا الأسبوع",
            type="loyalty", discount_percent=None,
            target_products=["جميع المنتجات"],
            expected_revenue_increase=8.0, expected_traffic_increase=5.0,
            estimated_cost=200.0, roi=5.5, priority=4,
        ),
    ]

    return PromotionResponse(
        promotions=promos, best_timing="الخميس والجمعة - أعلى حركة مرور",
        target_audience="العائلات والعملاء المنتظمون",
        estimated_total_roi=round(sum(p.roi for p in promos) / len(promos), 1),
    )


# ============================================================================
# 14. CHAT WITH DATA
# ============================================================================

def chat_with_data(org_id: str, store_id: str, message: str,
                   conversation_id: str | None = None) -> ChatResponse:
    s = _seed(org_id, store_id)
    conv_id = conversation_id or f"conv_{s % 10000}"
    msg_lower = message.lower()

    # Pattern matching for realistic responses
    if any(w in msg_lower for w in ["مبيعات", "sales", "إيراد", "revenue"]):
        return ChatResponse(
            reply="مبيعات اليوم بلغت 4,520 ر.س بزيادة 16% عن أمس. أعلى ساعة مبيعات كانت من 6-7 مساءً بقيمة 890 ر.س.",
            data=[
                ChatDataPoint(label="اليوم", value=4520, unit="ر.س"),
                ChatDataPoint(label="أمس", value=3890, unit="ر.س"),
                ChatDataPoint(label="متوسط الأسبوع", value=4071, unit="ر.س"),
            ],
            chart_type="bar",
            suggestions=["ما هي أفضل المنتجات مبيعاً؟", "قارن مبيعات هذا الأسبوع بالسابق", "ما هي ساعات الذروة؟"],
            conversation_id=conv_id,
        )
    elif any(w in msg_lower for w in ["مخزون", "inventory", "stock", "منتج"]):
        return ChatResponse(
            reply="لديك 5 منتجات بمخزون منخفض تحتاج إعادة طلب. أهمها: حليب طازج (12 وحدة متبقية) وخبز عربي (8 وحدات). المخزون الكلي بقيمة 125,000 ر.س.",
            data=[
                ChatDataPoint(label="منخفض", value=5, unit="منتج"),
                ChatDataPoint(label="نفد", value=1, unit="منتج"),
                ChatDataPoint(label="جيد", value=194, unit="منتج"),
            ],
            chart_type="pie",
            suggestions=["ما المنتجات الراكدة؟", "متى يجب إعادة طلب الحليب؟", "ما قيمة المخزون الراكد؟"],
            conversation_id=conv_id,
        )
    elif any(w in msg_lower for w in ["موظف", "staff", "أداء", "كاشير"]):
        return ChatResponse(
            reply="أفضل موظف أداءً هذا الشهر هو أحمد محمد بتقييم 92/100 ومبيعات 12,500 ر.س. متوسط أداء الفريق 83.6%.",
            data=[
                ChatDataPoint(label="أحمد", value=92, unit="نقطة"),
                ChatDataPoint(label="سارة", value=87, unit="نقطة"),
                ChatDataPoint(label="فاطمة", value=89, unit="نقطة"),
                ChatDataPoint(label="خالد", value=78, unit="نقطة"),
            ],
            chart_type="bar",
            suggestions=["من يحتاج تدريب؟", "ما أفضل توزيع للورديات؟", "قارن أداء الشهر الحالي بالسابق"],
            conversation_id=conv_id,
        )
    else:
        return ChatResponse(
            reply=f"مرحباً! أنا مساعدك الذكي. يمكنني مساعدتك في تحليل المبيعات والمخزون والموظفين والعملاء. كيف يمكنني مساعدتك؟",
            data=None, chart_type=None,
            suggestions=["كم مبيعات اليوم؟", "ما حالة المخزون؟", "من أفضل موظف؟", "ما توقعات الأسبوع القادم؟"],
            conversation_id=conv_id,
        )


# ============================================================================
# 15. ASSISTANT
# ============================================================================

def get_assistant_response(org_id: str, store_id: str, query: str,
                           context: str = "general") -> AssistantResponse:
    s = _seed(org_id, store_id)
    q_lower = query.lower()

    if any(w in q_lower for w in ["مبيعات", "بيع", "فاتورة"]):
        return AssistantResponse(
            answer="مبيعات اليوم 4,520 ر.س من 67 عملية بيع. الأداء أعلى من المتوسط بـ 11%. أوقات الذروة: 5-7 مساءً.",
            confidence=0.92,
            data={"today_sales": 4520, "transactions": 67, "avg_transaction": 67.5},
            actions=[
                SuggestedAction(action="view_sales", label="عرض تفاصيل المبيعات", route="/sales"),
                SuggestedAction(action="view_forecast", label="عرض التوقعات", route="/ai/forecast"),
            ],
            related_topics=["توقعات المبيعات", "أفضل المنتجات", "تحليل العملاء"],
        )
    elif any(w in q_lower for w in ["مخزون", "نقص", "طلب"]):
        return AssistantResponse(
            answer="5 منتجات بحاجة لإعادة طلب عاجل. حليب طازج وخبز عربي بأولوية قصوى. إجمالي قيمة المخزون المنخفض: 3,200 ر.س.",
            confidence=0.88,
            data={"low_stock": 5, "critical": 2, "total_value": 3200},
            actions=[
                SuggestedAction(action="view_inventory", label="عرض المخزون", route="/inventory"),
                SuggestedAction(action="create_order", label="إنشاء طلب شراء", route="/purchases/new"),
            ],
            related_topics=["المخزون الذكي", "طلبات الشراء", "الموردين"],
        )
    else:
        return AssistantResponse(
            answer="مرحباً! أنا المساعد الذكي للحي. يمكنني مساعدتك في إدارة المبيعات، المخزون، الموظفين، والعملاء. ماذا تريد أن تعرف؟",
            confidence=0.95,
            data=None,
            actions=[
                SuggestedAction(action="sales_summary", label="ملخص المبيعات", route="/ai/reports"),
                SuggestedAction(action="inventory_check", label="فحص المخزون", route="/ai/inventory"),
                SuggestedAction(action="staff_report", label="تقرير الموظفين", route="/ai/staff"),
            ],
            related_topics=["المبيعات", "المخزون", "الموظفين", "العملاء"],
        )
