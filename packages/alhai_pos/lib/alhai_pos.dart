library alhai_pos;

// ─── Screens: POS ───────────────────────────────────────────────
export 'src/screens/pos/pos_screen.dart';
export 'src/screens/pos/payment_screen.dart';
export 'src/screens/pos/receipt_screen.dart';
export 'src/screens/pos/quick_sale_screen.dart';
export 'src/screens/pos/favorites_screen.dart';
export 'src/screens/pos/hold_invoices_screen.dart';
export 'src/screens/pos/kiosk_screen.dart';
export 'src/screens/pos/customer_display_screen.dart';
export 'src/screens/pos/phone_entry_dialog.dart';
// Phase 4.5 — expose the public `showPosDiscountDialog` helper so shell-level
// keyboard shortcuts (Ctrl+D) can open the same discount dialog the cart
// panel uses, without re-implementing PIN/approval logic.
export 'src/screens/pos/pos_cart_panel.dart' show showPosDiscountDialog;

// ─── Screens: Returns ───────────────────────────────────────────
export 'src/screens/returns/returns_screen.dart';
export 'src/screens/returns/refund_request_screen.dart';
export 'src/screens/returns/refund_reason_screen.dart';
export 'src/screens/returns/refund_receipt_screen.dart';
export 'src/screens/returns/void_transaction_screen.dart';

// ─── Screens: Supporting ────────────────────────────────────────
export 'src/screens/inventory/barcode_scanner_screen.dart';
export 'src/screens/cash/cash_drawer_screen.dart';

// ─── Providers ──────────────────────────────────────────────────
export 'src/providers/cart_providers.dart';
export 'src/providers/sale_providers.dart';
export 'src/providers/favorites_providers.dart';
export 'src/providers/held_invoices_providers.dart';
export 'src/providers/returns_providers.dart';
export 'src/providers/customer_display_providers.dart';
export 'src/providers/pos_feedback_providers.dart';
export 'src/providers/pos_focus_controller.dart';
export 'src/providers/tax_settings_provider.dart';

// ─── Services ───────────────────────────────────────────────────
export 'src/services/sale_service.dart';
export 'src/services/invoice_service.dart';
export 'src/services/receipt_printer_service.dart';
export 'src/services/receipt_pdf_generator.dart';
export 'src/services/payment/payment_gateway.dart';
export 'src/services/manager_approval_service.dart';
export 'src/services/zatca_service.dart';
export 'src/services/zatca_invoice_mapper.dart';
export 'src/services/credit_limit_enforcer.dart';
export 'src/widgets/credit_limit_dialog.dart';
export 'src/services/whatsapp_service.dart';
export 'src/services/whatsapp_receipt_service.dart';
export 'src/services/customer_display/customer_display_service.dart';
export 'src/services/customer_display/customer_display_state.dart';
export 'src/services/customer_display/web_display_channel_factory.dart';
export 'src/services/payment/nfc_capability_service.dart';
export 'src/services/payment/nfc_listener_service.dart';

// ─── Widgets: Cash ──────────────────────────────────────────────
export 'src/widgets/cash/denomination_counter_widget.dart';

// ─── Widgets: POS ───────────────────────────────────────────────
// NOTE [M142]: PaymentMethod and PaymentResult are defined in both
// inline_payment.dart and split_payment_dialog.dart (different enums).
// pos_widgets.dart also re-exports inline_payment.dart.
// The `hide` clauses below prevent duplicate/conflicting barrel exports.
export 'src/widgets/pos/barcode_listener.dart';
export 'src/widgets/pos/favorites_row.dart';
export 'src/widgets/pos/instant_search.dart';
export 'src/widgets/pos/pos_widgets.dart' hide PaymentMethod, PaymentResult;
export 'src/widgets/pos/sale_note_dialog.dart';
export 'src/widgets/pos/customer_search_dialog.dart';
export 'src/widgets/pos/inline_payment.dart' hide PaymentMethod, PaymentResult;
export 'src/widgets/pos/payment_success_dialog.dart';
export 'src/widgets/pos/quantity_input_dialog.dart';
export 'src/widgets/pos/split_payment_dialog.dart' hide PaymentMethod;
export 'src/widgets/pos/customer_quick_info.dart';

// ─── Widgets: Returns ───────────────────────────────────────────
export 'src/widgets/returns/create_return_drawer.dart';
export 'src/widgets/returns/returns_data_table.dart';
export 'src/widgets/returns/returns_stat_card.dart';

// ─── Widgets: Orders ────────────────────────────────────────────
export 'src/widgets/orders/orders_widgets.dart';
