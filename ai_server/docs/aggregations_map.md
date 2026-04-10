# services/aggregations.py — Structural Map

File: `ai_server/services/aggregations.py` (~837 lines)
Purpose: Pure functions that transform pre-fetched Supabase rows into Pydantic response schemas for the six AI endpoints. Replaces deterministic mocks with real aggregations; raises `InsufficientDataError` when data is too thin, letting routers fall back to mock responses with `is_mock_data=True`.

Design notes:
- Takes already-fetched rows (dicts) — trivially unit-testable.
- Defensive field access via `_field(row, *candidates)` helper — tolerates multiple schema variants (e.g. `total_amount` vs `total`, `employee_id` vs `cashier_id`).
- All successful returns set `is_mock_data=False, data_source="real"`.
- Does NOT query Supabase directly — routers fetch rows and pass them in.

## Public classes

| Class | Purpose |
|---|---|
| `InsufficientDataError(Exception)` | Raised when a function cannot build a meaningful response; routers catch and fall back to mocks. |

## Private helpers

| Function | Purpose |
|---|---|
| `_num(value, default=0.0) -> float` | Safe float cast for Supabase fields. |
| `_int(value, default=0) -> int` | Safe int cast. |
| `_field(row, *candidates, default=None)` | Return first non-None candidate key — handles schema drift. |
| `_parse_dt(value) -> datetime | None` | Parse ISO 8601 Supabase timestamps into tz-aware UTC datetimes. |

## Public aggregation functions

| Function | Signature | Purpose |
|---|---|---|
| `inventory_from_products` | `(products, language="ar", min_products=1) -> InventoryResponse` | Computes stock alerts, overstock/understock counts, dead-stock value, and ABC classification (80/15/5 value-contribution rule) from product rows. No ML. |
| `reports_from_sales` | `(sales, sale_items, report_type, language="ar", min_sales=1) -> ReportResponse` | Builds today/yesterday/week/last-week revenue, daily and weekly growth %, top-3 products by quantity, executive summary, and key metrics. No ML. |
| `staff_from_sales_employees` | `(sales, employees, language="ar", min_employees=1) -> StaffResponse` | Per-employee aggregation: total sales, transaction count, avg ticket, performance score (60% sales + 40% count, normalized 0-100), rank. No ML. |
| `forecast_from_sales` | `(sales, days_ahead, language="ar", min_days=7) -> ForecastResponse` | Daily revenue forecast. Buckets sales by day, computes day-of-week factors, uses statsmodels `ARIMA(1,1,1)` when >=14 days of history, falls back to 7-day moving average otherwise. Raises `InsufficientDataError` below 7 days. |
| `basket_from_items` | `(sale_items, min_support=0.05, min_confidence=0.3, top_n=20, language="ar", min_transactions=20) -> BasketResponse` | Market-basket analysis via mlxtend `apriori` + `association_rules`, sorted by lift. Returns top-N rules, avg basket size/value, top product, cross-sell opportunity, frequently-bought-together bundles. |
| `fraud_from_sales` | `(sales, language="ar", min_sales=50, contamination=0.05) -> FraudResponse` | Anomaly detection via sklearn `IsolationForest` on features `[amount, hour_of_day, discount_ratio, day_of_week]`. Classifies flagged sales into high/medium/low risk with reason codes (high value, manual discount, off-hours). |

## Router import graph

All six of the `/ai/*` routers consume this module:

| Router | Imports |
|---|---|
| `routers/smart_inventory.py` | `InsufficientDataError, inventory_from_products` |
| `routers/smart_reports.py` | `InsufficientDataError, reports_from_sales` |
| `routers/staff_analytics.py` | `InsufficientDataError, staff_from_sales_employees` |
| `routers/sales_forecast.py` | `InsufficientDataError, forecast_from_sales` |
| `routers/basket_analysis.py` | `InsufficientDataError, basket_from_items` |
| `routers/fraud_detection.py` | `InsufficientDataError, fraud_from_sales` |

## Supabase tables referenced

The module does NOT execute Supabase queries — it takes pre-fetched rows from routers. It does, however, document (in the module docstring) the expected row shapes:

- `products` — `id, name, current_stock|stock, reorder_point|min_stock, max_stock, cost|cost_price, price|sell_price, category_id`
- `sales` — `id, total_amount|total, created_at, employee_id|cashier_id, discount|discount_amount, customer_id, items_count`
- `sale_items` — `id, sale_id, product_id, product_name, quantity|qty, price|unit_price, total|subtotal`
- `users` — `id, full_name|name, email`

## Tech debt / observations

1. **Hardcoded magic numbers scattered throughout — no config surface**
   - `inventory_from_products`: reorder-point multipliers (`0.5`, `1.3`, `*2`, `*4`), default reorder_point=10, default daily_sales heuristic `reorder/10`, 30% potential_savings multiplier on dead stock, alert cap of 50.
   - `staff_from_sales_employees`: performance score weights 60/40 are not configurable.
   - `forecast_from_sales`: `ARIMA(1,1,1)` order is hardcoded; confidence decay `0.92 - i*0.01`; `predicted_qty = revenue/45` is a "rough qty proxy" (comment admits it).
   - `fraud_from_sales`: `contamination=0.05`, `n_estimators=100`, thresholds `risk > 0.75 / 0.60`, off-hours window `<6 || >23`, high-value = `>3× mean`.

2. **`forecast_from_sales`: qty proxy is arbitrary** (`predicted_qty=round(rev/45, 1)`). The magic number 45 is an unexplained average unit price — likely wrong for any store whose basket avg is not ~45. Flag this for a real per-product forecast.

3. **Silent failure paths**
   - `basket_from_items` catches all exceptions from mlxtend apriori with a `logger.warning`, returning empty rules but still a successful response. Callers can't tell apriori failed.
   - `forecast_from_sales` catches all ARIMA exceptions and silently falls back to moving average.

4. **Unused imports** — `math` is imported but never used.

5. **No unit tests visible in `tests/`** for any of the six public functions (to be confirmed during pytest baseline).

6. **`min_transactions=20` in basket_from_items** vs `min_sales=50` in fraud — no consistent policy for "enough data" thresholds.

## Top-3 most important functions

1. `forecast_from_sales` — only function with real ML (ARIMA) and multi-tier fallback logic; most complex and highest-risk for silent degradation.
2. `fraud_from_sales` — sklearn IsolationForest with manual feature engineering; the feature matrix and anomaly thresholds drive the entire fraud UX.
3. `inventory_from_products` — the only fully deterministic pipeline consumed by the app's most-used screen (stock alerts). Pure aggregation but it hosts the most tunable business rules.

## Top TODO to flag

**`forecast_from_sales` line ~581: `predicted_qty=round(rev / 45, 1)`** — hardcoded divisor 45 as a "qty proxy" that silently lies to clients whose avg ticket is not ~45. Either remove `predicted_qty` from the response, compute it from real per-product history, or make the divisor a parameter. This is the most consequential magic number in the file because it surfaces directly to the UI as a prediction.
