library alhai_shared_ui;

// =============================================================================
// DEPRECATION NOTICE
// =============================================================================
//
// Re-exporting from upstream packages (alhai_design_system, alhai_auth) through
// this barrel file hides the true dependency graph and makes refactoring harder.
//
// **Preferred approach for new code:**
//   import 'package:alhai_design_system/alhai_design_system.dart';
//   import 'package:alhai_auth/alhai_auth.dart';
//
// The re-exports below are kept for backward compatibility but should be
// considered deprecated. When adding new features, import directly from the
// source package instead of adding more re-exports here.
//
// **Restructuring plan:**
// Phase 1: Stop adding new re-exports (NOW)
// Phase 2: Audit consumers and replace `import alhai_shared_ui` with direct
//          imports where only design_system/auth symbols are used
// Phase 3: Remove re-exports once all consumers import directly
// =============================================================================

// ─── Core Utilities (alhai_shared_ui's own code) ────────────────
export 'src/core/theme/app_sizes.dart';
export 'src/core/theme/app_typography.dart';
export 'src/core/theme/app_theme.dart';
export 'src/core/router/routes.dart';
export 'src/core/validators/validators.dart';
export 'src/core/validators/input_sanitizer.dart';
export 'src/core/sanitizers/input_sanitizer.dart';
export 'src/core/responsive/responsive_utils.dart';
export 'src/core/constants/breakpoints.dart';
export 'src/core/accessibility/semantic_labels.dart';
export 'src/core/utils/currency_formatter.dart';
export 'src/utils/number_formatter.dart';
export 'src/utils/debouncer.dart';
export 'src/utils/responsive_text.dart';
export 'src/utils/responsive_dialog.dart';

// ─── Re-exports from alhai_design_system (DEPRECATED - import directly) ─
// TODO(cleanup): Many consumer files rely on AppColors through this re-export.
//   Migrate consumers to: import 'package:alhai_design_system/alhai_design_system.dart';
//   Then remove this line.
export 'package:alhai_design_system/alhai_design_system.dart' show AppColors;

// ─── Re-exports from alhai_auth (DEPRECATED - import directly) ──
// TODO(cleanup): Many consumer files rely on currentStoreIdProvider through this re-export.
//   Migrate consumers to: import 'package:alhai_auth/alhai_auth.dart';
//   Then remove this line.
export 'package:alhai_auth/alhai_auth.dart'
    show currentStoreIdProvider, kDefaultStoreId;

// ─── Providers ──────────────────────────────────────────────────
export 'src/providers/products_providers.dart';
export 'src/providers/customers_providers.dart';
export 'src/providers/suppliers_providers.dart';
export 'src/providers/orders_providers.dart';
export 'src/providers/shifts_providers.dart';
export 'src/providers/expenses_providers.dart';
export 'src/providers/dashboard_providers.dart';
export 'src/providers/invoices_providers.dart';
export 'src/providers/notifications_provider.dart';
export 'src/providers/notifications_providers.dart';
export 'src/providers/settings_providers.dart';
export 'src/providers/sync_providers.dart';
export 'src/providers/theme_provider.dart';
export 'src/providers/cashier_mode_provider.dart';
export 'src/providers/print_providers.dart';
export 'src/providers/performance_provider.dart';
export 'src/providers/inventory_advanced_providers.dart';

// ─── Screens: Dashboard ─────────────────────────────────────────
export 'src/screens/dashboard/dashboard_screen.dart';

// ─── Screens: Customers ─────────────────────────────────────────
export 'src/screens/customers/customers_screen.dart';
export 'src/screens/customers/customer_detail_screen.dart';
export 'src/screens/customers/customer_debt_screen.dart';
export 'src/screens/customers/customer_analytics_screen.dart';

// ─── Screens: Products ──────────────────────────────────────────
export 'src/screens/products/products_screen.dart';
export 'src/screens/products/product_detail_screen.dart';

// ─── Screens: Inventory ─────────────────────────────────────────
export 'src/screens/inventory/inventory_screen.dart';
export 'src/screens/inventory/inventory_alerts_screen.dart';
export 'src/screens/inventory/expiry_tracking_screen.dart';

// ─── Screens: Suppliers ─────────────────────────────────────────
export 'src/screens/suppliers/suppliers_screen.dart';
export 'src/screens/suppliers/supplier_detail_screen.dart';

// ─── Screens: Orders ────────────────────────────────────────────
export 'src/screens/orders/orders_screen.dart';
export 'src/screens/orders/order_history_screen.dart';
export 'src/screens/orders/order_tracking_screen.dart';

// ─── Screens: Expenses ──────────────────────────────────────────
export 'src/screens/expenses/expenses_screen.dart';
export 'src/screens/expenses/expense_categories_screen.dart';

// ─── Screens: Shifts ────────────────────────────────────────────
export 'src/screens/shifts/shifts_screen.dart';
export 'src/screens/shifts/shift_summary_screen.dart';

// ─── Screens: Invoices ──────────────────────────────────────────
export 'src/screens/invoices/invoices_screen.dart';
export 'src/screens/invoices/invoice_detail_screen.dart';

// ─── Screens: Other ─────────────────────────────────────────────
export 'src/screens/notifications/notifications_screen.dart';
export 'src/screens/profile/profile_screen.dart';
export 'src/screens/sync/sync_status_screen.dart';
export 'src/screens/settings/language_screen.dart';
export 'src/screens/settings/theme_screen.dart';

// ─── Widgets: Common ────────────────────────────────────────────
export 'src/widgets/common/adaptive_icon.dart';
export 'src/widgets/common/animated_counter.dart';
export 'src/widgets/common/animated_switcher_wrapper.dart';
export 'src/widgets/common/app_badge.dart';
export 'src/widgets/common/app_button.dart';
export 'src/widgets/common/app_card.dart';
export 'src/widgets/common/app_data_table.dart';
export 'src/widgets/common/app_dialog.dart';
export 'src/widgets/common/app_empty_state.dart';
export 'src/widgets/common/app_input.dart';
export 'src/widgets/common/cashier_mode_wrapper.dart';
export 'src/widgets/common/common.dart';
export 'src/widgets/common/error_widget.dart';
export 'src/widgets/common/gradient_button.dart';
export 'src/widgets/common/language_selector.dart';
export 'src/widgets/common/lazy_screen.dart';
export 'src/widgets/common/loading_widget.dart'
    hide ShimmerList, ShimmerGrid, ShimmerCard;
export 'src/widgets/common/modern_card.dart';
export 'src/widgets/common/offline_banner.dart';
export 'src/widgets/common/performance_dashboard.dart';
export 'src/widgets/common/shimmer_loading.dart';
export 'src/widgets/common/skeleton_loader.dart';
export 'src/widgets/common/smart_animations.dart';
export 'src/widgets/common/smart_offline_banner.dart';
export 'src/widgets/common/sync_status_indicator.dart';
export 'src/widgets/common/undo_system.dart';
export 'src/widgets/common/user_feedback.dart';

// ─── Widgets: Layout ────────────────────────────────────────────
export 'src/widgets/layout/app_header.dart';
export 'src/widgets/layout/app_scaffold.dart';
export 'src/widgets/layout/app_sidebar.dart';
export 'src/widgets/layout/dashboard_shell.dart';
export 'src/widgets/layout/layout.dart';
export 'src/widgets/layout/sidebar.dart';
export 'src/widgets/layout/split_view.dart';
export 'src/widgets/layout/top_bar.dart';

// ─── Widgets: Dashboard ─────────────────────────────────────────
export 'src/widgets/dashboard/elegant_quick_actions.dart';
export 'src/widgets/dashboard/quick_action_grid.dart';
export 'src/widgets/dashboard/quick_actions_panel.dart';
export 'src/widgets/dashboard/recent_transactions.dart';
export 'src/widgets/dashboard/sales_chart.dart';
export 'src/widgets/dashboard/stat_card.dart';
export 'src/widgets/dashboard/top_selling_list.dart';

// ─── Widgets: Invoices ──────────────────────────────────────────
export 'src/widgets/invoices/create_invoice_dialog.dart';
export 'src/widgets/invoices/delete_invoice_dialog.dart';
export 'src/widgets/invoices/invoice_data_table.dart';
export 'src/widgets/invoices/invoice_filters.dart';
export 'src/widgets/invoices/invoice_payment_methods.dart';
export 'src/widgets/invoices/invoice_revenue_chart.dart';
export 'src/widgets/invoices/invoice_stat_card.dart';

// ─── Widgets: Responsive ────────────────────────────────────────
export 'src/widgets/responsive/responsive_builder.dart';

// ─── Widgets: Accessible ────────────────────────────────────────
export 'src/widgets/accessible/accessible_widgets.dart';
