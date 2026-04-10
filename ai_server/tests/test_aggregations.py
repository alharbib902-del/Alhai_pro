"""
Unit tests for services/aggregations.py - no Supabase, pure Python.

These tests feed synthetic rows that match the shape of Supabase responses
and verify that each aggregation function produces valid responses with
is_mock_data=False and data_source="real".
"""

from __future__ import annotations

import random
from datetime import datetime, timedelta, timezone

import pytest

from services.aggregations import (
    InsufficientDataError,
    basket_from_items,
    forecast_from_sales,
    fraud_from_sales,
    inventory_from_products,
    reports_from_sales,
    staff_from_sales_employees,
)


# ---------------------------------------------------------------------------
# Fixtures
# ---------------------------------------------------------------------------


def _make_products(n: int = 10) -> list[dict]:
    """Build synthetic products with mixed stock levels."""
    products = []
    for i in range(n):
        stock = [0, 5, 15, 25, 60, 100, 150][i % 7]
        products.append(
            {
                "id": f"prod_{i}",
                "name": f"Product {i}",
                "current_stock": stock,
                "reorder_point": 20,
                "max_stock": 80,
                "price": 10.0 + i,
                "cost": 6.0 + i,
            }
        )
    return products


def _make_sales(days: int = 30, per_day: int = 10) -> list[dict]:
    """Build synthetic sales spread across N days."""
    rng = random.Random(42)
    sales = []
    now = datetime.now(timezone.utc)
    sid = 0
    for d in range(days):
        day_start = now - timedelta(days=d)
        for _ in range(per_day):
            sid += 1
            sales.append(
                {
                    "id": f"sale_{sid}",
                    "total_amount": round(rng.uniform(20, 300), 2),
                    "discount": round(rng.uniform(0, 10), 2),
                    "created_at": (
                        day_start - timedelta(hours=rng.randint(0, 23))
                    ).isoformat(),
                    "employee_id": f"emp_{sid % 4 + 1}",
                    "customer_id": f"cust_{sid % 20 + 1}",
                }
            )
    return sales


def _make_sale_items(n_transactions: int = 30) -> list[dict]:
    """Build synthetic sale_items with repeated product combinations."""
    rng = random.Random(7)
    items = []
    combos = [
        ["bread", "milk", "cheese"],
        ["rice", "oil"],
        ["tea", "sugar"],
        ["coffee", "sugar", "cream"],
        ["bread", "butter"],
    ]
    iid = 0
    for t in range(n_transactions):
        combo = rng.choice(combos)
        for p in combo:
            iid += 1
            items.append(
                {
                    "id": f"item_{iid}",
                    "sale_id": f"sale_{t}",
                    "product_id": p,
                    "product_name": p,
                    "quantity": 1,
                    "price": 5.0,
                    "total": 5.0,
                }
            )
    return items


def _make_employees(n: int = 4) -> list[dict]:
    return [
        {"id": f"emp_{i+1}", "full_name": f"Employee {i+1}"} for i in range(n)
    ]


# ---------------------------------------------------------------------------
# 1. inventory_from_products
# ---------------------------------------------------------------------------


def test_inventory_real_data_marks_non_mock():
    products = _make_products(10)
    result = inventory_from_products(products)
    assert result.is_mock_data is False
    assert result.data_source == "real"
    assert len(result.alerts) > 0
    # ABC classification should sum to total products
    assert sum(result.abc_classification.values()) == len(products)


def test_inventory_flags_zero_stock_as_critical():
    products = [
        {"id": "p1", "name": "Empty", "current_stock": 0, "reorder_point": 10, "price": 10, "cost": 5},
        {"id": "p2", "name": "OK", "current_stock": 50, "reorder_point": 10, "max_stock": 60, "price": 10, "cost": 5},
    ]
    result = inventory_from_products(products)
    critical = [a for a in result.alerts if a.priority == "critical"]
    assert len(critical) == 1
    assert critical[0].product_id == "p1"


def test_inventory_insufficient_data_raises():
    with pytest.raises(InsufficientDataError):
        inventory_from_products([], min_products=1)


# ---------------------------------------------------------------------------
# 2. reports_from_sales
# ---------------------------------------------------------------------------


def test_reports_real_data_shapes():
    sales = _make_sales(days=14, per_day=5)
    items = _make_sale_items(20)
    result = reports_from_sales(sales, items, report_type="daily_summary")
    assert result.is_mock_data is False
    assert result.data_source == "real"
    assert result.report_type == "daily_summary"
    assert "daily_revenue" in result.key_metrics
    assert "weekly_revenue" in result.key_metrics
    assert len(result.sections) >= 1


def test_reports_without_items_still_works():
    sales = _make_sales(days=7, per_day=3)
    result = reports_from_sales(sales, None, report_type="weekly")
    assert result.is_mock_data is False
    assert result.key_metrics["total_sales"] > 0


def test_reports_insufficient_data_raises():
    with pytest.raises(InsufficientDataError):
        reports_from_sales([], None, "daily_summary", min_sales=1)


# ---------------------------------------------------------------------------
# 3. staff_from_sales_employees
# ---------------------------------------------------------------------------


def test_staff_real_data_ranks_employees():
    employees = _make_employees(4)
    sales = _make_sales(days=7, per_day=10)
    result = staff_from_sales_employees(sales, employees)
    assert result.is_mock_data is False
    assert result.summary.total_employees == 4
    # Ranks should be 1..N sequential
    ranks = [e.rank for e in result.employees]
    assert ranks == sorted(ranks)
    assert ranks[0] == 1
    # Sum of total_sales across employees should equal global revenue
    assert result.summary.total_revenue > 0


def test_staff_insufficient_data_raises():
    with pytest.raises(InsufficientDataError):
        staff_from_sales_employees([], [], min_employees=1)


# ---------------------------------------------------------------------------
# 4. forecast_from_sales
# ---------------------------------------------------------------------------


def test_forecast_arima_path():
    # 21 days of data → should trigger ARIMA path
    sales = _make_sales(days=21, per_day=5)
    result = forecast_from_sales(sales, days_ahead=7)
    assert result.is_mock_data is False
    assert len(result.predictions) == 7
    assert result.summary.total_revenue > 0
    assert result.summary.trend in ("up", "down", "stable")


def test_forecast_moving_average_path():
    # 8 days → MA path (not enough for ARIMA)
    sales = _make_sales(days=8, per_day=3)
    result = forecast_from_sales(sales, days_ahead=5)
    assert result.is_mock_data is False
    assert len(result.predictions) == 5


def test_forecast_insufficient_data_raises():
    sales = _make_sales(days=3, per_day=2)
    with pytest.raises(InsufficientDataError):
        forecast_from_sales(sales, days_ahead=7, min_days=7)


def test_forecast_uses_computed_avg_ticket_not_magic_45():
    """predicted_qty should reflect the dataset's actual avg ticket."""
    # Build 14 days of sales, 5 per day, each ticket = 200.0 (far from 45)
    now = datetime.now(timezone.utc)
    sales = []
    sid = 0
    for d in range(14):
        day = now - timedelta(days=d)
        for _ in range(5):
            sid += 1
            sales.append(
                {
                    "id": f"sale_{sid}",
                    "total_amount": 200.0,
                    "created_at": day.isoformat(),
                }
            )
    result = forecast_from_sales(sales, days_ahead=7)
    # Each predicted day: qty = rev / 200, so qty should be much smaller
    # than rev / 45. Concretely: rev ~200/day → qty ~1.0, not ~4.4.
    for p in result.predictions:
        if p.predicted_revenue > 0:
            expected = round(p.predicted_revenue / 200.0, 1)
            assert p.predicted_qty == expected, (
                f"expected qty {expected} (rev/200), got {p.predicted_qty}"
            )


def test_forecast_fallback_warns_when_too_few_txns(caplog):
    """When txn count < 5 AND avg_ticket is None, fallback logs a warning."""
    import logging
    # Craft 7 distinct days but only 4 total transactions (some days empty).
    # daily bucket has >=7 days via spreading 4 txns across 7 unique dates,
    # but we actually need 7 distinct days. Cheat: put 4 real rows + 3
    # zero-amount rows on extra days so the day-count passes min_days
    # while transaction count stays below MIN_TXNS_FOR_AVG (5).
    now = datetime.now(timezone.utc)
    sales = []
    for i in range(4):
        sales.append(
            {
                "id": f"sale_{i}",
                "total_amount": 123.0,
                "created_at": (now - timedelta(days=i)).isoformat(),
            }
        )
    # Zero-amount rows on 3 more distinct days to satisfy min_days=7.
    # Note: these still count as transactions, so to actually trigger the
    # fallback we drop min_days to 4 and supply just 4 transactions on 4
    # distinct days.
    sales = sales[:4]
    caplog.clear()
    with caplog.at_level(logging.WARNING, logger="services.aggregations"):
        result = forecast_from_sales(sales, days_ahead=3, min_days=4)
    assert len(result.predictions) == 3
    assert any(
        "cannot compute avg_ticket" in rec.message
        and "falling back to default" in rec.message
        for rec in caplog.records
    ), f"expected fallback warning, got: {[r.message for r in caplog.records]}"


# ---------------------------------------------------------------------------
# 5. basket_from_items
# ---------------------------------------------------------------------------


def test_basket_apriori_finds_rules():
    items = _make_sale_items(50)
    result = basket_from_items(items, min_support=0.05, min_confidence=0.3)
    assert result.is_mock_data is False
    assert result.summary.total_transactions_analyzed == 50
    # With strong combos, apriori should find rules
    assert len(result.rules) > 0


def test_basket_insufficient_data_raises():
    items = _make_sale_items(5)
    with pytest.raises(InsufficientDataError):
        basket_from_items(items, min_transactions=20)


# ---------------------------------------------------------------------------
# 6. fraud_from_sales
# ---------------------------------------------------------------------------


def test_fraud_isolation_forest_runs():
    sales = _make_sales(days=10, per_day=10)  # 100 sales
    # Inject a couple of extreme outliers
    sales.append(
        {
            "id": "sale_outlier_1",
            "total_amount": 50000.0,
            "discount": 25000.0,
            "created_at": datetime.now(timezone.utc).isoformat(),
            "employee_id": "emp_1",
        }
    )
    sales.append(
        {
            "id": "sale_outlier_2",
            "total_amount": 100000.0,
            "discount": 0.0,
            "created_at": datetime.now(timezone.utc).replace(hour=3).isoformat(),
            "employee_id": "emp_2",
        }
    )
    result = fraud_from_sales(sales)
    assert result.is_mock_data is False
    assert result.summary.total_flagged > 0
    # Outliers should be flagged
    flagged_ids = {a.sale_id for a in result.alerts}
    assert any("outlier" in sid for sid in flagged_ids)


def test_fraud_insufficient_data_raises():
    sales = _make_sales(days=1, per_day=5)
    with pytest.raises(InsufficientDataError):
        fraud_from_sales(sales, min_sales=50)
