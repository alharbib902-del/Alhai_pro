"""
Pydantic request/response models for all 15 AI endpoints.
نماذج الطلب والاستجابة لجميع نقاط النهاية الـ 15
"""

from pydantic import BaseModel, Field
from datetime import datetime, date
from enum import Enum


# ============================================================================
# COMMON / مشترك
# ============================================================================

class BaseRequest(BaseModel):
    """Base request with required org/store IDs."""
    org_id: str = Field(..., description="معرّف المنظمة - Organization ID")
    store_id: str = Field(..., description="معرّف المتجر - Store ID")
    language: str = Field("ar", description="Language: ar/en/ur/hi/bn/fil/id")


class ConfidenceScore(BaseModel):
    value: float = Field(..., ge=0, le=1, description="درجة الثقة (0-1)")
    label: str = Field(..., description="تصنيف الثقة")


# ============================================================================
# 1. SALES FORECAST / التنبؤ بالمبيعات
# ============================================================================

class ForecastRequest(BaseRequest):
    """طلب التنبؤ بالمبيعات"""
    product_ids: list[str] | None = Field(None, description="معرّفات المنتجات (اختياري)")
    days_ahead: int = Field(7, description="عدد أيام التنبؤ", ge=1, le=90)
    category_id: str | None = Field(None, description="معرّف الفئة (اختياري)")


class ForecastPrediction(BaseModel):
    date: str = Field(..., description="التاريخ")
    product_id: str | None = Field(None, description="معرّف المنتج")
    predicted_qty: float = Field(..., description="الكمية المتوقعة")
    predicted_revenue: float = Field(..., description="الإيراد المتوقع")
    confidence: float = Field(..., ge=0, le=1, description="درجة الثقة")


class ForecastSummary(BaseModel):
    total_revenue: float = Field(..., description="إجمالي الإيراد المتوقع")
    trend: str = Field(..., description="الاتجاه: up/down/stable")
    trend_label: str = Field(..., description="وصف الاتجاه بالعربية")
    avg_daily_revenue: float = Field(..., description="متوسط الإيراد اليومي")
    peak_day: str = Field(..., description="يوم الذروة المتوقع")


class ForecastResponse(BaseModel):
    predictions: list[ForecastPrediction]
    summary: ForecastSummary
    accuracy: float = Field(..., description="دقة النموذج")
    is_mock_data: bool = False
    data_source: str = "real"  # "real" | "mock" | "cached"


# ============================================================================
# 2. SMART PRICING / التسعير الذكي
# ============================================================================

class PricingRequest(BaseRequest):
    """طلب التسعير الذكي"""
    product_ids: list[str] | None = Field(None, description="معرّفات المنتجات")
    category_id: str | None = None
    strategy: str = Field("optimal", description="استراتيجية: optimal/competitive/margin")


class PricingSuggestion(BaseModel):
    product_id: str
    product_name: str
    current_price: float
    suggested_price: float
    min_price: float
    max_price: float
    expected_revenue_change: float = Field(..., description="التغير المتوقع في الإيراد %")
    reason: str = Field(..., description="سبب الاقتراح بالعربية")
    confidence: float


class PricingResponse(BaseModel):
    suggestions: list[PricingSuggestion]
    total_potential_increase: float = Field(..., description="إجمالي الزيادة المحتملة %")
    strategy_used: str
    is_mock_data: bool = False
    data_source: str = "real"  # "real" | "mock" | "cached"


# ============================================================================
# 3. FRAUD DETECTION / كشف الاحتيال
# ============================================================================

class FraudRequest(BaseRequest):
    """طلب كشف الاحتيال"""
    sale_id: str | None = Field(None, description="معرّف عملية البيع (اختياري)")
    date_from: str | None = None
    date_to: str | None = None


class FraudAlert(BaseModel):
    sale_id: str
    risk_score: float = Field(..., ge=0, le=1, description="درجة الخطورة")
    risk_level: str = Field(..., description="مستوى الخطورة: high/medium/low")
    reason: str = Field(..., description="سبب التنبيه بالعربية")
    timestamp: str
    cashier_id: str | None = None
    amount: float | None = None
    patterns: list[str] = Field(default_factory=list, description="الأنماط المكتشفة")


class FraudSummary(BaseModel):
    total_flagged: int
    high_risk_count: int
    medium_risk_count: int
    low_risk_count: int
    total_amount_flagged: float
    period: str


class FraudResponse(BaseModel):
    alerts: list[FraudAlert]
    summary: FraudSummary
    is_mock_data: bool = False
    data_source: str = "real"  # "real" | "mock" | "cached"


# ============================================================================
# 4. BASKET ANALYSIS / تحليل سلة المشتريات
# ============================================================================

class BasketRequest(BaseRequest):
    """طلب تحليل سلة المشتريات"""
    min_support: float = Field(0.05, description="الحد الأدنى للدعم", ge=0, le=1)
    min_confidence: float = Field(0.3, description="الحد الأدنى للثقة", ge=0, le=1)
    top_n: int = Field(20, description="عدد القواعد المطلوبة")


class AssociationRule(BaseModel):
    antecedent: list[str] = Field(..., description="المنتجات الأساسية")
    consequent: list[str] = Field(..., description="المنتجات المرتبطة")
    support: float
    confidence: float
    lift: float
    description: str = Field(..., description="وصف القاعدة بالعربية")


class BasketSummary(BaseModel):
    avg_basket_size: float
    avg_basket_value: float
    total_transactions_analyzed: int
    top_product: str
    cross_sell_opportunity: str


class BasketResponse(BaseModel):
    rules: list[AssociationRule]
    summary: BasketSummary
    frequently_bought_together: list[list[str]]
    is_mock_data: bool = False
    data_source: str = "real"  # "real" | "mock" | "cached"


# ============================================================================
# 5. CUSTOMER RECOMMENDATIONS / توصيات العملاء
# ============================================================================

class RecommendationRequest(BaseRequest):
    """طلب توصيات العملاء"""
    customer_id: str | None = Field(None, description="معرّف العميل (اختياري)")
    top_n: int = Field(10, description="عدد التوصيات")
    context: str = Field("general", description="السياق: general/upsell/cross_sell/retention")


class ProductRecommendation(BaseModel):
    product_id: str
    product_name: str
    score: float
    reason: str
    category: str
    expected_purchase_probability: float


class CustomerSegment(BaseModel):
    segment_id: str
    name: str
    description: str
    customer_count: int
    avg_spend: float


class RecommendationResponse(BaseModel):
    recommendations: list[ProductRecommendation]
    customer_segments: list[CustomerSegment]
    personalization_score: float
    is_mock_data: bool = False
    data_source: str = "real"  # "real" | "mock" | "cached"


# ============================================================================
# 6. SMART INVENTORY / المخزون الذكي
# ============================================================================

class InventoryRequest(BaseRequest):
    """طلب تحليل المخزون الذكي"""
    product_ids: list[str] | None = None
    category_id: str | None = None
    include_reorder: bool = Field(True, description="تضمين توصيات إعادة الطلب")


class InventoryAlert(BaseModel):
    product_id: str
    product_name: str
    current_stock: int
    reorder_point: int
    suggested_order_qty: int
    days_until_stockout: int
    priority: str = Field(..., description="الأولوية: critical/high/medium/low")
    reason: str


class InventoryOptimization(BaseModel):
    overstock_items: int
    understock_items: int
    optimal_items: int
    potential_savings: float
    dead_stock_value: float


class InventoryResponse(BaseModel):
    alerts: list[InventoryAlert]
    optimization: InventoryOptimization
    abc_classification: dict[str, int] = Field(..., description="تصنيف ABC")
    is_mock_data: bool = False
    data_source: str = "real"  # "real" | "mock" | "cached"


# ============================================================================
# 7. COMPETITOR ANALYSIS / تحليل المنافسين
# ============================================================================

class CompetitorRequest(BaseRequest):
    """طلب تحليل المنافسين"""
    category_id: str | None = None
    radius_km: float = Field(5.0, description="نطاق البحث بالكيلومتر")


class CompetitorInfo(BaseModel):
    name: str
    distance_km: float
    price_index: float = Field(..., description="مؤشر السعر مقارنة بمتجرك")
    strengths: list[str]
    weaknesses: list[str]
    threat_level: str


class PriceComparison(BaseModel):
    product_name: str
    your_price: float
    avg_competitor_price: float
    price_position: str = Field(..., description="أرخص/متوسط/أغلى")
    recommendation: str


class CompetitorResponse(BaseModel):
    competitors: list[CompetitorInfo]
    price_comparisons: list[PriceComparison]
    market_position: str
    opportunities: list[str]
    is_mock_data: bool = False
    data_source: str = "real"  # "real" | "mock" | "cached"


# ============================================================================
# 8. SMART REPORTS / التقارير الذكية
# ============================================================================

class ReportRequest(BaseRequest):
    """طلب التقارير الذكية"""
    report_type: str = Field("daily_summary", description="نوع التقرير")
    date_from: str | None = None
    date_to: str | None = None
    format: str = Field("json", description="صيغة التقرير: json/summary")


class ReportInsight(BaseModel):
    title: str
    description: str
    impact: str = Field(..., description="تأثير: positive/negative/neutral")
    metric_value: float | None = None
    metric_change: float | None = None
    action_items: list[str] = Field(default_factory=list)


class ReportSection(BaseModel):
    title: str
    data: dict
    insights: list[ReportInsight]


class ReportResponse(BaseModel):
    report_type: str
    generated_at: str
    sections: list[ReportSection]
    executive_summary: str
    key_metrics: dict[str, float]
    is_mock_data: bool = False
    data_source: str = "real"  # "real" | "mock" | "cached"


# ============================================================================
# 9. STAFF ANALYTICS / تحليل الموظفين
# ============================================================================

class StaffRequest(BaseRequest):
    """طلب تحليل أداء الموظفين"""
    employee_id: str | None = None
    date_from: str | None = None
    date_to: str | None = None


class EmployeePerformance(BaseModel):
    employee_id: str
    employee_name: str
    total_sales: float
    transaction_count: int
    avg_transaction_value: float
    performance_score: float = Field(..., ge=0, le=100)
    rank: int
    strengths: list[str]
    improvement_areas: list[str]


class StaffSummary(BaseModel):
    total_employees: int
    avg_performance_score: float
    top_performer: str
    total_revenue: float
    efficiency_index: float


class StaffResponse(BaseModel):
    employees: list[EmployeePerformance]
    summary: StaffSummary
    shift_recommendations: list[str]
    is_mock_data: bool = False
    data_source: str = "real"  # "real" | "mock" | "cached"


# ============================================================================
# 10. PRODUCT RECOGNITION / التعرف على المنتجات
# ============================================================================

class RecognitionRequest(BaseRequest):
    """طلب التعرف على المنتج"""
    image_base64: str | None = Field(None, description="صورة المنتج بتنسيق Base64")
    barcode: str | None = Field(None, description="الباركود")
    description: str | None = Field(None, description="وصف نصي للمنتج")


class RecognizedProduct(BaseModel):
    product_id: str | None
    name: str
    category: str
    confidence: float
    suggested_price: float | None
    barcode: str | None
    is_new: bool = Field(..., description="منتج جديد غير موجود في النظام")


class RecognitionResponse(BaseModel):
    products: list[RecognizedProduct]
    processing_time_ms: int
    method: str = Field(..., description="طريقة التعرف: image/barcode/text")
    is_mock_data: bool = False
    data_source: str = "real"  # "real" | "mock" | "cached"


# ============================================================================
# 11. SENTIMENT ANALYSIS / تحليل المشاعر
# ============================================================================

class SentimentRequest(BaseRequest):
    """طلب تحليل المشاعر"""
    text: str | None = Field(None, description="نص لتحليله")
    source: str = Field("reviews", description="المصدر: reviews/social/support")
    date_from: str | None = None
    date_to: str | None = None


class SentimentResult(BaseModel):
    text: str
    sentiment: str = Field(..., description="إيجابي/سلبي/محايد")
    score: float = Field(..., ge=-1, le=1)
    topics: list[str]
    timestamp: str | None = None
    source: str


class SentimentSummary(BaseModel):
    positive_percent: float
    negative_percent: float
    neutral_percent: float
    avg_score: float
    total_analyzed: int
    trending_topics: list[str]
    overall_sentiment: str


class SentimentResponse(BaseModel):
    results: list[SentimentResult]
    summary: SentimentSummary
    is_mock_data: bool = False
    data_source: str = "real"  # "real" | "mock" | "cached"


# ============================================================================
# 12. RETURN PREDICTION / التنبؤ بالمرتجعات
# ============================================================================

class ReturnRequest(BaseRequest):
    """طلب التنبؤ بالمرتجعات"""
    product_ids: list[str] | None = None
    days_ahead: int = Field(30, ge=1, le=90)


class ReturnPrediction(BaseModel):
    product_id: str
    product_name: str
    return_probability: float
    expected_returns: int
    main_reason: str
    risk_level: str
    cost_impact: float


class ReturnSummary(BaseModel):
    total_expected_returns: int
    total_cost_impact: float
    high_risk_products: int
    top_return_reason: str
    return_rate_trend: str


class ReturnResponse(BaseModel):
    predictions: list[ReturnPrediction]
    summary: ReturnSummary
    prevention_tips: list[str]
    is_mock_data: bool = False
    data_source: str = "real"  # "real" | "mock" | "cached"


# ============================================================================
# 13. PROMOTION DESIGNER / تصميم العروض
# ============================================================================

class PromotionRequest(BaseRequest):
    """طلب تصميم العروض"""
    goal: str = Field("increase_sales", description="الهدف: increase_sales/clear_stock/attract_customers/increase_basket")
    budget: float | None = None
    target_products: list[str] | None = None
    duration_days: int = Field(7, ge=1, le=90)


class PromotionSuggestion(BaseModel):
    title: str
    title_ar: str
    description: str
    type: str = Field(..., description="النوع: discount/bundle/bogo/loyalty")
    discount_percent: float | None = None
    target_products: list[str]
    expected_revenue_increase: float
    expected_traffic_increase: float
    estimated_cost: float
    roi: float
    priority: int


class PromotionResponse(BaseModel):
    promotions: list[PromotionSuggestion]
    best_timing: str
    target_audience: str
    estimated_total_roi: float
    is_mock_data: bool = False
    data_source: str = "real"  # "real" | "mock" | "cached"


# ============================================================================
# 14. CHAT WITH DATA / الدردشة مع البيانات
# ============================================================================

class ChatRequest(BaseRequest):
    """طلب الدردشة مع البيانات"""
    message: str = Field(..., description="رسالة المستخدم")
    conversation_id: str | None = Field(None, description="معرّف المحادثة (لاستمرار السياق)")


class ChatDataPoint(BaseModel):
    label: str
    value: float
    unit: str | None = None


class ChatResponse(BaseModel):
    reply: str = Field(..., description="رد المساعد")
    data: list[ChatDataPoint] | None = Field(None, description="بيانات مرتبطة بالرد")
    chart_type: str | None = Field(None, description="نوع الرسم البياني المقترح")
    suggestions: list[str] = Field(default_factory=list, description="أسئلة مقترحة")
    conversation_id: str
    is_mock_data: bool = False
    data_source: str = "real"  # "real" | "mock" | "cached"


# ============================================================================
# 15. ASSISTANT / المساعد الذكي
# ============================================================================

class AssistantRequest(BaseRequest):
    """طلب المساعد الذكي"""
    query: str = Field(..., description="استفسار المستخدم")
    context: str = Field("general", description="السياق: general/sales/inventory/finance/operations")
    include_actions: bool = Field(True, description="تضمين إجراءات مقترحة")


class SuggestedAction(BaseModel):
    action: str
    label: str
    route: str | None = None
    params: dict | None = None


class AssistantResponse(BaseModel):
    answer: str
    confidence: float
    data: dict | None = None
    actions: list[SuggestedAction] = Field(default_factory=list)
    related_topics: list[str] = Field(default_factory=list)
    is_mock_data: bool = False
    data_source: str = "real"  # "real" | "mock" | "cached"
