"""
Real data aggregations - التجميعات الحقيقية من البيانات.

Pure functions that take raw Supabase rows and return the Pydantic response
schemas defined in models.schemas. These replace the deterministic mocks in
ml_service.py with factual aggregations from the actual database.

Each function:
- Takes already-fetched rows (so it's trivially unit-testable with dicts)
- Returns a fully-populated response with is_mock_data=False, data_source="real"
- Raises InsufficientDataError when there isn't enough data for meaningful
  analysis (the router then falls back to mock with is_mock_data=True)

Schema assumptions (defensive: every field uses .get with sensible defaults):
- products: id, name, current_stock|stock, reorder_point|min_stock,
            max_stock, cost|cost_price, price|sell_price, category_id
- sales:    id, total_amount|total, created_at, employee_id|cashier_id,
            discount|discount_amount, customer_id, items_count
- sale_items: id, sale_id, product_id, product_name, quantity|qty,
              price|unit_price, total|subtotal, created_at (joined from sales)
- users:    id, full_name|name, email
"""

from __future__ import annotations

import logging
import math
from collections import defaultdict
from datetime import datetime, timedelta, timezone
from typing import Any

from i18n.translations import t
from models.schemas import (
    AssociationRule,
    BasketResponse,
    BasketSummary,
    EmployeePerformance,
    ForecastPrediction,
    ForecastResponse,
    ForecastSummary,
    FraudAlert,
    FraudResponse,
    FraudSummary,
    InventoryAlert,
    InventoryOptimization,
    InventoryResponse,
    ReportInsight,
    ReportResponse,
    ReportSection,
    StaffResponse,
    StaffSummary,
)

logger = logging.getLogger(__name__)


class InsufficientDataError(Exception):
    """Raised when there isn't enough data for meaningful aggregation."""


# ---------------------------------------------------------------------------
# Generic helpers
# ---------------------------------------------------------------------------


def _num(value: Any, default: float = 0.0) -> float:
    """Safely cast a Supabase field to float."""
    if value is None:
        return default
    try:
        return float(value)
    except (TypeError, ValueError):
        return default


def _int(value: Any, default: int = 0) -> int:
    if value is None:
        return default
    try:
        return int(float(value))
    except (TypeError, ValueError):
        return default


def _field(row: dict, *candidates: str, default: Any = None) -> Any:
    """Return the first non-None field from a list of candidate keys."""
    for key in candidates:
        if key in row and row[key] is not None:
            return row[key]
    return default


def _parse_dt(value: Any) -> datetime | None:
    """Parse a Supabase timestamp (ISO string) into an aware datetime."""
    if value is None:
        return None
    if isinstance(value, datetime):
        return value if value.tzinfo else value.replace(tzinfo=timezone.utc)
    if not isinstance(value, str):
        return None
    try:
        # Supabase returns ISO 8601; handle trailing Z
        s = value.replace("Z", "+00:00")
        return datetime.fromisoformat(s)
    except ValueError:
        return None


# ---------------------------------------------------------------------------
# 1. SMART INVENTORY — pure aggregation (no ML)
# ---------------------------------------------------------------------------


def inventory_from_products(
    products: list[dict],
    language: str = "ar",
    min_products: int = 1,
) -> InventoryResponse:
    """Compute stock alerts + ABC classification from real product rows.

    Required fields on each product:
      - id / product_id
      - name
      - current_stock (defaults to 0)
      - reorder_point (defaults to 10)
      - price, cost (optional, for valuation)
    """
    if len(products) < min_products:
        raise InsufficientDataError(
            f"need at least {min_products} products, got {len(products)}"
        )

    alerts: list[InventoryAlert] = []
    overstock = 0
    understock = 0
    optimal = 0
    dead_stock_value = 0.0
    potential_savings = 0.0

    # For ABC classification we compute value = price * current_stock
    product_values: list[tuple[str, float]] = []

    for p in products:
        pid = str(_field(p, "id", "product_id", default=""))
        name = str(_field(p, "name", "product_name", default="Unknown"))
        stock = _int(_field(p, "current_stock", "stock", "quantity"))
        reorder = _int(_field(p, "reorder_point", "min_stock"), default=10)
        max_stock = _int(_field(p, "max_stock"), default=max(reorder * 4, 40))
        price = _num(_field(p, "price", "sell_price"))
        cost = _num(_field(p, "cost", "cost_price"), default=price * 0.7)

        # Compute avg daily sales proxy for days_until_stockout
        # Without real sales data per product, use a simple heuristic:
        # assume reorder_point ≈ ~10 days of supply → daily ≈ reorder/10
        daily_sales = max(reorder / 10.0, 0.1)
        days_until = int(stock / daily_sales) if daily_sales > 0 else 999

        # Classify
        if stock == 0:
            priority = "critical"
            reason_key = "inv_reorder_now"
            understock += 1
            suggested_qty = max(reorder * 2, 20)
        elif stock < reorder * 0.5:
            priority = "critical"
            reason_key = "inv_critical_low"
            understock += 1
            suggested_qty = reorder * 2 - stock
        elif stock < reorder:
            priority = "high"
            reason_key = "inv_low_reorder_week"
            understock += 1
            suggested_qty = reorder * 2 - stock
        elif stock < reorder * 1.3:
            priority = "medium"
            reason_key = "inv_near_reorder"
            optimal += 1
            suggested_qty = reorder
        elif stock > max_stock:
            priority = "low"
            reason_key = "inv_overstock_promo"
            overstock += 1
            suggested_qty = 0
            # Overstock above max_stock is potential dead stock
            dead_stock_value += (stock - max_stock) * cost
            potential_savings += (stock - max_stock) * cost * 0.3
        else:
            priority = "low"
            reason_key = "inv_good"
            optimal += 1
            suggested_qty = 0

        # Only surface alerts that need action (critical/high/medium) + top overstock
        if priority in ("critical", "high", "medium") or (
            priority == "low" and stock > max_stock
        ):
            alerts.append(
                InventoryAlert(
                    product_id=pid,
                    product_name=name,
                    current_stock=stock,
                    reorder_point=reorder,
                    suggested_order_qty=int(suggested_qty),
                    days_until_stockout=min(days_until, 365),
                    priority=priority,
                    reason=t(reason_key, language),
                )
            )

        product_values.append((pid, price * stock))

    # ABC classification by value contribution (80/15/5 rule)
    product_values.sort(key=lambda x: x[1], reverse=True)
    total_value = sum(v for _, v in product_values) or 1.0
    cumulative = 0.0
    abc = {"A": 0, "B": 0, "C": 0}
    for _pid, val in product_values:
        cumulative += val
        pct = cumulative / total_value
        if pct <= 0.80:
            abc["A"] += 1
        elif pct <= 0.95:
            abc["B"] += 1
        else:
            abc["C"] += 1

    priority_order = {"critical": 0, "high": 1, "medium": 2, "low": 3}
    alerts.sort(key=lambda a: priority_order[a.priority])

    return InventoryResponse(
        alerts=alerts[:50],  # cap response size
        optimization=InventoryOptimization(
            overstock_items=overstock,
            understock_items=understock,
            optimal_items=optimal,
            potential_savings=round(potential_savings, 2),
            dead_stock_value=round(dead_stock_value, 2),
        ),
        abc_classification=abc,
        is_mock_data=False,
        data_source="real",
    )


# ---------------------------------------------------------------------------
# 2. SMART REPORTS — pure aggregation (no ML)
# ---------------------------------------------------------------------------


def reports_from_sales(
    sales: list[dict],
    sale_items: list[dict] | None,
    report_type: str,
    language: str = "ar",
    min_sales: int = 1,
) -> ReportResponse:
    """Generate a real report from sales rows.

    Required fields on each sale:
      - total_amount|total
      - created_at
      - customer_id (optional)
    """
    if len(sales) < min_sales:
        raise InsufficientDataError(
            f"need at least {min_sales} sales, got {len(sales)}"
        )

    now = datetime.now(timezone.utc)
    today = now.date()
    yesterday = today - timedelta(days=1)
    week_start = today - timedelta(days=today.weekday())
    last_week_start = week_start - timedelta(days=7)
    last_week_end = week_start - timedelta(days=1)

    today_total = 0.0
    yesterday_total = 0.0
    this_week_total = 0.0
    last_week_total = 0.0
    all_total = 0.0
    customers = set()

    for s in sales:
        amt = _num(_field(s, "total_amount", "total"))
        dt = _parse_dt(_field(s, "created_at", "sale_date"))
        cust = _field(s, "customer_id")
        if cust:
            customers.add(cust)
        all_total += amt
        if dt is None:
            continue
        d = dt.date()
        if d == today:
            today_total += amt
        elif d == yesterday:
            yesterday_total += amt
        if week_start <= d <= today:
            this_week_total += amt
        elif last_week_start <= d <= last_week_end:
            last_week_total += amt

    avg_basket = all_total / max(len(sales), 1)

    # Daily growth %
    daily_growth = (
        ((today_total - yesterday_total) / yesterday_total * 100)
        if yesterday_total > 0
        else 0.0
    )
    weekly_growth = (
        ((this_week_total - last_week_total) / last_week_total * 100)
        if last_week_total > 0
        else 0.0
    )

    # Top products from sale_items
    top_products_data: dict = {}
    if sale_items:
        qty_by_product: dict[str, tuple[str, float]] = {}
        for it in sale_items:
            pid = str(_field(it, "product_id", default=""))
            pname = str(_field(it, "product_name", "name", default=pid))
            qty = _num(_field(it, "quantity", "qty"))
            prev_name, prev_qty = qty_by_product.get(pid, (pname, 0.0))
            qty_by_product[pid] = (prev_name, prev_qty + qty)
        top = sorted(qty_by_product.values(), key=lambda x: x[1], reverse=True)[:3]
        for idx, (pname, qty) in enumerate(top, start=1):
            top_products_data[f"top_{idx}"] = f"{pname} - {int(qty)}"

    sections: list[ReportSection] = [
        ReportSection(
            title=t("report_sales_summary", language),
            data={
                "today": round(today_total, 2),
                "yesterday": round(yesterday_total, 2),
                "this_week": round(this_week_total, 2),
                "last_week": round(last_week_total, 2),
            },
            insights=[
                ReportInsight(
                    title=t("report_sales_summary", language),
                    description=(
                        f"Today: {today_total:.0f} vs yesterday: {yesterday_total:.0f}"
                    ),
                    impact="positive" if daily_growth >= 0 else "negative",
                    metric_value=round(today_total, 2),
                    metric_change=round(daily_growth, 1),
                ),
                ReportInsight(
                    title=t("report_sales_summary", language),
                    description=(
                        f"This week: {this_week_total:.0f} vs last: {last_week_total:.0f}"
                    ),
                    impact="positive" if weekly_growth >= 0 else "negative",
                    metric_value=round(this_week_total, 2),
                    metric_change=round(weekly_growth, 1),
                ),
            ],
        ),
    ]

    if top_products_data:
        sections.append(
            ReportSection(
                title=t("report_top_products", language),
                data=top_products_data,
                insights=[
                    ReportInsight(
                        title=t("report_top_products", language),
                        description=list(top_products_data.values())[0],
                        impact="positive",
                    ),
                ],
            )
        )

    exec_summary = (
        f"Analyzed {len(sales)} sales. Today's revenue: {today_total:.0f} "
        f"({daily_growth:+.1f}% vs yesterday). "
        f"This week: {this_week_total:.0f} ({weekly_growth:+.1f}% vs last week)."
    )

    return ReportResponse(
        report_type=report_type,
        generated_at=now.isoformat(),
        sections=sections,
        executive_summary=exec_summary,
        key_metrics={
            "daily_revenue": round(today_total, 2),
            "weekly_revenue": round(this_week_total, 2),
            "avg_basket": round(avg_basket, 2),
            "customer_count": float(len(customers)),
            "total_sales": round(all_total, 2),
        },
        is_mock_data=False,
        data_source="real",
    )


# ---------------------------------------------------------------------------
# 3. STAFF ANALYTICS — pure aggregation (no ML)
# ---------------------------------------------------------------------------


def staff_from_sales_employees(
    sales: list[dict],
    employees: list[dict],
    language: str = "ar",
    min_employees: int = 1,
) -> StaffResponse:
    """Per-employee performance from real sales + users rows."""
    if len(employees) < min_employees:
        raise InsufficientDataError(
            f"need at least {min_employees} employees, got {len(employees)}"
        )

    # Aggregate per employee
    stats: dict[str, dict] = defaultdict(
        lambda: {"sales": 0.0, "count": 0}
    )
    for s in sales:
        eid = str(_field(s, "employee_id", "cashier_id", "user_id", default=""))
        if not eid:
            continue
        stats[eid]["sales"] += _num(_field(s, "total_amount", "total"))
        stats[eid]["count"] += 1

    # Build employee name map
    name_map = {
        str(e.get("id", "")): str(_field(e, "full_name", "name", "email", default="?"))
        for e in employees
    }

    # Compute max for normalization
    max_sales = max((s["sales"] for s in stats.values()), default=1.0) or 1.0
    max_count = max((s["count"] for s in stats.values()), default=1) or 1

    perf_list: list[EmployeePerformance] = []
    for eid, name in name_map.items():
        st = stats.get(eid, {"sales": 0.0, "count": 0})
        total_sales = st["sales"]
        count = st["count"]
        avg_txn = total_sales / count if count > 0 else 0.0
        # Performance score: 60% sales + 40% transaction count, normalized to 0-100
        score = (
            (total_sales / max_sales) * 60 + (count / max_count) * 40
        )
        perf_list.append(
            EmployeePerformance(
                employee_id=eid,
                employee_name=name,
                total_sales=round(total_sales, 2),
                transaction_count=count,
                avg_transaction_value=round(avg_txn, 2),
                performance_score=round(score, 1),
                rank=0,  # assigned after sort
                strengths=[],
                improvement_areas=[],
            )
        )

    # Rank by performance_score descending
    perf_list.sort(key=lambda e: e.performance_score, reverse=True)
    for i, emp in enumerate(perf_list, start=1):
        emp.rank = i

    total_revenue = sum(e.total_sales for e in perf_list)
    avg_perf = (
        sum(e.performance_score for e in perf_list) / len(perf_list)
        if perf_list
        else 0.0
    )
    top_name = perf_list[0].employee_name if perf_list else "-"

    return StaffResponse(
        employees=perf_list,
        summary=StaffSummary(
            total_employees=len(perf_list),
            avg_performance_score=round(avg_perf, 1),
            top_performer=top_name,
            total_revenue=round(total_revenue, 2),
            efficiency_index=round(avg_perf / 100, 2),
        ),
        shift_recommendations=[],
        is_mock_data=False,
        data_source="real",
    )


# ---------------------------------------------------------------------------
# 4. SALES FORECAST — statistical model with fallback
# ---------------------------------------------------------------------------


def forecast_from_sales(
    sales: list[dict],
    days_ahead: int,
    language: str = "ar",
    min_days: int = 7,
    avg_ticket: float | None = None,
) -> ForecastResponse:
    """Forecast daily revenue using ARIMA when possible, else moving average.

    Strategy:
    - Bucket sales by day to build a time series
    - If >=14 unique days, fit statsmodels ARIMA(1,1,1)
    - If 7-13 days, use 7-day moving average × day-of-week seasonality
    - If <7 days, raise InsufficientDataError → router falls back to mock
    """
    # Bucket by date
    daily: dict[datetime, float] = defaultdict(float)
    # Group amounts by transaction id (sale_id/invoice_id/order_id/id)
    # so we can derive a real per-store average ticket instead of a
    # hardcoded constant. Fall back to row-level amounts if no key exists.
    txn_totals: dict[str, float] = defaultdict(float)
    txn_row_amounts: list[float] = []
    for s in sales:
        dt = _parse_dt(_field(s, "created_at", "sale_date"))
        if dt is None:
            continue
        day = datetime(dt.year, dt.month, dt.day, tzinfo=timezone.utc)
        amount = _num(_field(s, "total_amount", "total"))
        daily[day] += amount
        txn_row_amounts.append(amount)
        txn_key = _field(s, "sale_id", "invoice_id", "order_id", "id")
        if txn_key is not None:
            txn_totals[str(txn_key)] += amount

    if len(daily) < min_days:
        raise InsufficientDataError(
            f"need at least {min_days} distinct days of sales, got {len(daily)}"
        )

    # Per-dataset average ticket: mean of totals per transaction id.
    # If the caller passed avg_ticket explicitly, honor it. If we can't
    # compute a meaningful value (too few transactions), log a warning
    # and fall back to the historic default of 45 that was hardcoded
    # here before — see ai_server/docs/aggregations_map.md.
    DEFAULT_AVG_TICKET = 45.0
    MIN_TXNS_FOR_AVG = 5
    if avg_ticket is not None and avg_ticket > 0:
        avg_ticket_value = float(avg_ticket)
    else:
        if len(txn_totals) >= MIN_TXNS_FOR_AVG:
            avg_ticket_value = sum(txn_totals.values()) / len(txn_totals)
        elif len(txn_row_amounts) >= MIN_TXNS_FOR_AVG:
            avg_ticket_value = sum(txn_row_amounts) / len(txn_row_amounts)
        else:
            store_id = sales[0].get("store_id") if sales else None
            logger.warning(
                "forecast_from_sales: cannot compute avg_ticket "
                "(store_id=%s, txn_count=%d, row_count=%d) — "
                "falling back to default %.2f",
                store_id,
                len(txn_totals),
                len(txn_row_amounts),
                DEFAULT_AVG_TICKET,
            )
            avg_ticket_value = DEFAULT_AVG_TICKET
    if avg_ticket_value <= 0:
        avg_ticket_value = DEFAULT_AVG_TICKET

    # Build dense series (fill missing days with 0)
    sorted_days = sorted(daily.keys())
    start, end = sorted_days[0], sorted_days[-1]
    series: list[float] = []
    dates: list[datetime] = []
    cur = start
    while cur <= end:
        series.append(daily.get(cur, 0.0))
        dates.append(cur)
        cur = cur + timedelta(days=1)

    # Day-of-week factor (measured on observed data)
    dow_sum = [0.0] * 7
    dow_count = [0] * 7
    for d, v in zip(dates, series):
        dow_sum[d.weekday()] += v
        dow_count[d.weekday()] += 1
    mean = sum(series) / len(series) if series else 1.0
    dow_factor = [
        (dow_sum[i] / dow_count[i] / mean) if dow_count[i] > 0 and mean > 0 else 1.0
        for i in range(7)
    ]

    method = "moving_average"
    forecast_values: list[float] = []

    if len(series) >= 14:
        try:
            from statsmodels.tsa.arima.model import ARIMA

            model = ARIMA(series, order=(1, 1, 1))
            fit = model.fit()
            fc = fit.forecast(steps=days_ahead)
            forecast_values = [max(0.0, float(x)) for x in fc]
            method = "arima"
        except Exception as exc:
            logger.warning("ARIMA fit failed, falling back to MA: %s", exc)

    if not forecast_values:
        # 7-day moving average (or fewer if not enough data)
        window = min(7, len(series))
        recent = series[-window:]
        base = sum(recent) / len(recent) if recent else 0.0
        forecast_values = [base] * days_ahead

    # Apply day-of-week seasonality to smooth forecast
    today = datetime.now(timezone.utc)
    predictions: list[ForecastPrediction] = []
    for i in range(days_ahead):
        d = today + timedelta(days=i + 1)
        factor = dow_factor[d.weekday()]
        rev = max(0.0, forecast_values[i] * factor)
        # Confidence decays with forecast horizon
        conf = max(0.5, 0.92 - i * 0.01)
        predictions.append(
            ForecastPrediction(
                date=d.strftime("%Y-%m-%d"),
                product_id=None,
                # Divide forecast revenue by this dataset's average
                # ticket to get a rough predicted quantity proxy.
                predicted_qty=round(rev / avg_ticket_value, 1),
                predicted_revenue=round(rev, 2),
                confidence=round(conf, 2),
            )
        )

    total_rev = sum(p.predicted_revenue for p in predictions)
    avg_daily = total_rev / max(len(predictions), 1)
    peak = max(predictions, key=lambda p: p.predicted_revenue)
    trend_val = (
        predictions[-1].predicted_revenue - predictions[0].predicted_revenue
    )
    trend = "up" if trend_val > mean * 0.05 else "down" if trend_val < -mean * 0.05 else "stable"

    # Rough accuracy: in-sample MAPE proxy
    if len(series) >= 7:
        last_7 = series[-7:]
        mean_7 = sum(last_7) / 7
        if mean_7 > 0:
            mape = sum(abs(v - mean_7) for v in last_7) / 7 / mean_7
            accuracy = max(0.5, min(0.95, 1.0 - mape))
        else:
            accuracy = 0.5
    else:
        accuracy = 0.6

    return ForecastResponse(
        predictions=predictions,
        summary=ForecastSummary(
            total_revenue=round(total_rev, 2),
            trend=trend,
            trend_label=t(f"trend_{trend}", language),
            avg_daily_revenue=round(avg_daily, 2),
            peak_day=peak.date,
        ),
        accuracy=round(accuracy, 2),
        is_mock_data=False,
        data_source="real",
    )


# ---------------------------------------------------------------------------
# 5. BASKET ANALYSIS — apriori on real sale_items
# ---------------------------------------------------------------------------


def basket_from_items(
    sale_items: list[dict],
    min_support: float = 0.05,
    min_confidence: float = 0.3,
    top_n: int = 20,
    language: str = "ar",
    min_transactions: int = 20,
) -> BasketResponse:
    """Run apriori association rules on real transaction data."""
    # Group items by sale_id
    baskets: dict[str, list[str]] = defaultdict(list)
    basket_values: dict[str, float] = defaultdict(float)
    product_totals: dict[str, float] = defaultdict(float)
    product_names: dict[str, str] = {}

    for it in sale_items:
        sid = str(_field(it, "sale_id", default=""))
        pid = str(_field(it, "product_id", default=""))
        pname = str(_field(it, "product_name", "name", default=pid))
        qty = _num(_field(it, "quantity", "qty"), default=1.0)
        total = _num(_field(it, "total", "subtotal"))
        if not sid or not pid:
            continue
        baskets[sid].append(pname)
        basket_values[sid] += total
        product_totals[pname] += qty
        product_names[pid] = pname

    transactions = list(baskets.values())
    if len(transactions) < min_transactions:
        raise InsufficientDataError(
            f"need at least {min_transactions} transactions, got {len(transactions)}"
        )

    rules: list[AssociationRule] = []
    try:
        import pandas as pd
        from mlxtend.frequent_patterns import apriori, association_rules
        from mlxtend.preprocessing import TransactionEncoder

        te = TransactionEncoder()
        te_ary = te.fit(transactions).transform(transactions)
        df = pd.DataFrame(te_ary, columns=te.columns_)
        freq = apriori(df, min_support=min_support, use_colnames=True)
        if not freq.empty:
            ar = association_rules(
                freq, metric="confidence", min_threshold=min_confidence
            )
            ar = ar.sort_values("lift", ascending=False).head(top_n)
            for _, row in ar.iterrows():
                ant = list(row["antecedents"])
                con = list(row["consequents"])
                rules.append(
                    AssociationRule(
                        antecedent=ant,
                        consequent=con,
                        support=round(float(row["support"]), 3),
                        confidence=round(float(row["confidence"]), 3),
                        lift=round(float(row["lift"]), 2),
                        description=f"{' + '.join(ant)} → {' + '.join(con)}",
                    )
                )
    except Exception as exc:
        logger.warning("apriori failed: %s", exc)
        # No rules, but we still have stats → continue with empty rules

    avg_size = sum(len(b) for b in transactions) / len(transactions)
    avg_value = sum(basket_values.values()) / len(basket_values) if basket_values else 0.0
    top_product = (
        max(product_totals.items(), key=lambda x: x[1])[0]
        if product_totals
        else "-"
    )
    cross_sell = (
        f"{rules[0].antecedent[0]} → {rules[0].consequent[0]}"
        if rules
        else "-"
    )

    fbt: list[list[str]] = []
    for r in rules[:5]:
        fbt.append(list(r.antecedent) + list(r.consequent))

    return BasketResponse(
        rules=rules,
        summary=BasketSummary(
            avg_basket_size=round(avg_size, 1),
            avg_basket_value=round(avg_value, 2),
            total_transactions_analyzed=len(transactions),
            top_product=top_product,
            cross_sell_opportunity=cross_sell,
        ),
        frequently_bought_together=fbt,
        is_mock_data=False,
        data_source="real",
    )


# ---------------------------------------------------------------------------
# 6. FRAUD DETECTION — IsolationForest on real sales
# ---------------------------------------------------------------------------


def fraud_from_sales(
    sales: list[dict],
    language: str = "ar",
    min_sales: int = 50,
    contamination: float = 0.05,
) -> FraudResponse:
    """Flag anomalous sales using sklearn IsolationForest."""
    if len(sales) < min_sales:
        raise InsufficientDataError(
            f"need at least {min_sales} sales, got {len(sales)}"
        )

    # Build feature matrix: [amount, hour_of_day, discount_ratio, dow]
    features: list[list[float]] = []
    meta: list[dict] = []
    for s in sales:
        amt = _num(_field(s, "total_amount", "total"))
        discount = _num(_field(s, "discount", "discount_amount"))
        dt = _parse_dt(_field(s, "created_at", "sale_date"))
        hour = dt.hour if dt else 12
        dow = dt.weekday() if dt else 3
        disc_ratio = discount / amt if amt > 0 else 0.0
        features.append([amt, float(hour), disc_ratio, float(dow)])
        meta.append(
            {
                "sale_id": str(_field(s, "id", "sale_id", default="")),
                "amount": amt,
                "cashier_id": _field(s, "employee_id", "cashier_id"),
                "timestamp": dt.isoformat() if dt else datetime.now(timezone.utc).isoformat(),
            }
        )

    try:
        import numpy as np
        from sklearn.ensemble import IsolationForest

        X = np.array(features)
        model = IsolationForest(
            contamination=contamination, random_state=42, n_estimators=100
        )
        model.fit(X)
        scores = -model.score_samples(X)  # higher = more anomalous
        preds = model.predict(X)  # -1 = anomaly
    except Exception as exc:
        logger.warning("IsolationForest failed: %s", exc)
        raise InsufficientDataError(f"ML model unavailable: {exc}")

    # Normalize scores to 0..1 risk
    s_min, s_max = float(scores.min()), float(scores.max())
    s_range = s_max - s_min or 1.0

    alerts: list[FraudAlert] = []
    for i, (pred, score) in enumerate(zip(preds, scores)):
        if pred != -1:
            continue
        norm = (float(score) - s_min) / s_range
        risk = round(0.5 + norm * 0.5, 2)  # flagged → at least 0.5
        level = "high" if risk > 0.75 else "medium" if risk > 0.6 else "low"
        m = meta[i]
        feat = features[i]
        reasons = []
        patterns = []
        if feat[0] > sum(f[0] for f in features) / len(features) * 3:
            reasons.append(t("fraud_high_value", language))
            patterns.append(t("pattern_high_value", language))
        if feat[2] > 0.3:
            reasons.append(t("fraud_manual_discount", language))
            patterns.append(t("pattern_repeated_discount", language))
        if feat[1] < 6 or feat[1] > 23:
            reasons.append(t("fraud_off_hours", language))
            patterns.append(t("pattern_off_hours", language))
        if not reasons:
            reasons.append(t("fraud_suspicious_return", language))
            patterns.append(t("pattern_suspicious_qty", language))

        alerts.append(
            FraudAlert(
                sale_id=m["sale_id"],
                risk_score=risk,
                risk_level=level,
                reason=" / ".join(reasons),
                timestamp=m["timestamp"],
                cashier_id=str(m["cashier_id"]) if m["cashier_id"] else None,
                amount=m["amount"],
                patterns=patterns,
            )
        )

    alerts.sort(key=lambda a: a.risk_score, reverse=True)

    high = sum(1 for a in alerts if a.risk_level == "high")
    med = sum(1 for a in alerts if a.risk_level == "medium")
    low = sum(1 for a in alerts if a.risk_level == "low")
    total_amt = sum(a.amount or 0 for a in alerts)

    return FraudResponse(
        alerts=alerts[:100],
        summary=FraudSummary(
            total_flagged=len(alerts),
            high_risk_count=high,
            medium_risk_count=med,
            low_risk_count=low,
            total_amount_flagged=round(total_amt, 2),
            period=t("last_72_hours", language),
        ),
        is_mock_data=False,
        data_source="real",
    )
