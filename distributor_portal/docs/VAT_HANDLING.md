# VAT Handling Strategy

## Overview

Saudi Arabia mandates 15% Value Added Tax (VAT) on commercial transactions.

## Current Implementation

### How it works

1. **Order prices are entered as subtotals** (before tax).
   The distributor enters their price per item — these are pre-tax values.

2. **VAT is calculated at display time** using `VatCalculator`:
   - `subtotal` = sum of (price × quantity) across items
   - `vat` = subtotal × 0.15
   - `total` = subtotal × 1.15

3. **Invoice model** already stores `tax_rate` (default 15%) and `tax_amount`
   as computed columns. The invoice generation flow calculates these correctly.

### Where VAT is displayed

- **Order detail screen**: Subtotal + VAT 15% + Total (with label "شامل ضريبة القيمة المضافة 15%")
- **Invoice detail screen**: Tax breakdown already present via `DistributorInvoice.taxAmount`

### What is NOT changed

- Existing `orders.total` in the database remains as-is (pre-tax subtotal).
- No database migration needed — VAT is a display-time calculation.
- Invoice amounts in the database include the tax fields computed during generation.

## Future Considerations

- If tax rate changes (e.g., government update), change `VatCalculator.saudiVatRate`.
- Consider storing the applicable tax rate per order for historical accuracy.
- Tax-exempt products (if any) would need a per-product flag.
