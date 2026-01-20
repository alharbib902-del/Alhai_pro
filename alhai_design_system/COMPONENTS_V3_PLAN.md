# 🎨 alhai_design_system v3.0.0 - Missing Components

**Version**: 3.0.0 (Planned)  
**Current**: v2.0.0  
**Date**: 2026-01-15

---

## 📋 New Components Needed

### 1. Desktop Components (5)

#### ADesktopDrawer
```dart
/// Desktop-optimized drawer (always visible sidebar)
class ADesktopDrawer extends StatelessWidget {
  final List<DrawerItem> items;
  final bool collapsed; // collapse to icons only
  final Widget? header;
  
  // Features:
  // - Always visible (not overlay)
  // - Collapsible
  // - Keyboard navigation
  // - Dark mode support
}
```

#### ADataGrid
```dart
/// Advanced data grid for desktop
class ADataGrid<T> extends StatelessWidget {
  final List<T> data;
  final List<GridColumn<T>> columns;
  final bool sortable;
  final bool filterable;
  final bool resizableColumns;
  final bool exportable; // CSV, Excel
  
  // Features:
  // - Virtual scrolling (1M+ rows)
  // - Multi-column sort
  // - Advanced filters
  // - Column reordering
  // - Frozen columns
}
```

#### AMultiSelect
```dart
/// Multi-select dropdown for desktop
class AMultiSelect<T> extends StatelessWidget {
  final List<T> items;
  final List<T> selectedItems;
  final ValueChanged<List<T>> onChanged;
  
  // Features:
  // - Search/filter
  // - Select all/none
  // - Checkboxes
  // - Keyboard navigation
}
```

#### ADateRangePicker
```dart
/// Date range picker (desktop optimized)
class ADateRangePicker extends StatelessWidget {
  final DateTime? startDate;
  final DateTime? endDate;
  final ValueChanged<DateRange> onChanged;
  
  // Features:
  // - Calendar view
  // - Quick ranges (this week, last month, etc.)
  // - Keyboard input
}
```

#### AContextMenu
```dart
/// Right-click context menu
class AContextMenu extends StatelessWidget {
  final List<ContextMenuItem> items;
  final Widget child;
  
  // Features:
  // - Right-click activation
  // - Keyboard shortcuts display
  // - Nested menus
  // - Icons support
}
```

---

### 2. B2B Components (4)

#### AProductCatalog
```dart
/// B2B product catalog grid
class AProductCatalog extends StatelessWidget {
  final List<Product> products;
  final ViewMode mode; // grid, list, table
  final bool showWholesalePrice;
  
  // Features:
  // - Bulk select
  // - Quick order
  // - Price tiers display
  // - Stock indicators
}
```

#### ABulkOrderForm
```dart
/// Bulk order creation form
class ABulkOrderForm extends StatelessWidget {
  final List<OrderItem> items;
  final ValueChanged<BulkOrder> onSubmit;
  
  // Features:
  // - Quantity steppers
  // - Subtotal calculation
  // - Min order validation
  // - Estimated delivery
}
```

#### AInvoiceTemplate
```dart
/// Professional invoice template
class AInvoiceTemplate extends StatelessWidget {
  final Invoice invoice;
  final bool printable;
  
  // Features:
  // - Print layout
  // - PDF export
  // - QR code
  // - Customizable branding
}
```

#### ADistributorCard
```dart
/// Distributor profile card
class ADistributorCard extends StatelessWidget {
  final Distributor distributor;
  final bool compact;
  
  // Features:
  // - Rating stars
  // - Quick stats
  // - Contact buttons
  // - Favorite toggle
}
```

---

### 3. Payment Components (3)

#### ASplitPaymentInput
```dart
/// Split payment input widget
class ASplitPaymentInput extends StatelessWidget {
  final double totalAmount;
  final ValueChanged<SplitPayment> onChanged;
  
  // Features:
  // - Add payment method
  // - Amount validation
  // - Remaining display
  // - Card swipe integration
}
```

#### ACardReaderIndicator
```dart
/// Card reader status indicator
class ACardReaderIndicator extends StatelessWidget {
  final CardReaderStatus status;
  
  // Features:
  // - Swipe animation
  // - Error states
  // - Success feedback
}
```

#### APaymentReceipt
```dart
/// Enhanced receipt for split payments
class APaymentReceipt extends StatelessWidget {
  final SplitPayment payment;
  final bool printable;
  
  // Features:
  // - Itemized breakdown
  // - Payment methods listed
  // - QR code
  // - Print layout
}
```

---

### 4. AI Components (2)

#### AAISuggestionCard
```dart
/// AI suggestion card
class AAISuggestionCard extends StatelessWidget {
  final AIReorderSuggestion suggestion;
  final VoidCallback onAccept;
  final VoidCallback onReject;
  
  // Features:
  // - Highlighted savings
  // - Item breakdown
  // - Reasoning display
  // - 1-tap actions
}
```

#### AStockAnalysisChart
```dart
/// Stock level analysis chart
class AStockAnalysisChart extends StatelessWidget {
  final List<StockLevel> data;
  final int daysToShow;
  
  // Features:
  // - Line chart (current stock)
  // - Sales velocity
  // - Reorder point line
  // - Forecast (AI)
}
```

---

### 5. Specialized Components (3)

#### ASignaturePad
```dart
/// Signature capture pad
class ASignaturePad extends StatelessWidget {
  final ValueChanged<Uint8List> onSigned;
  
  // Features:
  // - Touch/mouse drawing
  // - Clear button
  // - Save as image
  // - Smooth curves
}
```

#### AVoiceRecorder
```dart
/// Voice recording widget
class AVoiceRecorder extends StatelessWidget {
  final ValueChanged<String> onRecorded; // audio file path
  
  // Features:
  // - Record/pause/stop
  // - Waveform visualization
  // - Duration display
  // - Playback
}
```

#### AMapMarkerCluster
```dart
/// Advanced map with clustering
class AMapMarkerCluster extends StatelessWidget {
  final List<MapMarker> markers;
  final LatLng center;
  
  // Features:
  // - Marker clustering
  // - Info windows
  // - Route drawing
  // - Real-time updates
}
```

---

## 📦 Migration Plan

### Phase 1: Desktop Components (Week 1)
- ADesktopDrawer
- ADataGrid
- AMultiSelect
- ADateRangePicker
- AContextMenu

### Phase 2: B2B + Payment (Week 2)
- AProductCatalog
- ABulkOrderForm
- AInvoiceTemplate
- ADistributorCard
- ASplitPaymentInput
- ACardReaderIndicator
- APaymentReceipt

### Phase 3: AI + Specialized (Week 3)
- AAISuggestionCard
- AStockAnalysisChart
- ASignaturePad
- AVoiceRecorder
- AMapMarkerCluster

---

## 🚀 Implementation

### Update pubspec.yaml:
```yaml
name: alhai_design_system
version: 3.0.0

description: >
  Complete design system for Alhai platform.
  Now includes desktop, B2B, payment, and AI components.

dependencies:
  flutter:
    sdk: flutter
  signature: ^5.3.0  # for ASignaturePad
  record: ^5.0.0     # for AVoiceRecorder
  google_maps_flutter: ^2.5.0
```

---

**📅 Target Release**: v3.0.0 (Week 4)  
**✅ Status**: Specification Complete
