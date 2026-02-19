# Design System - Dashboard (design_dashboard.md)

> This file documents the complete dashboard design system for Al-HAI POS app.
> Use this as reference when applying the same design patterns to other screens.

---

## Table of Contents

1. [Design Principles](#design-principles)
2. [Color System](#color-system)
3. [Responsive Breakpoints](#responsive-breakpoints)
4. [Layout Structure](#layout-structure)
5. [Component: AppHeader](#component-appheader)
6. [Component: AppSidebar](#component-appsidebar)
7. [Component: StatCard](#component-statcard)
8. [Component: SalesChart (Bar Chart)](#component-saleschart)
9. [Component: QuickActions (Gradient Card)](#component-quickactions)
10. [Component: TopProductsList](#component-topproductslist)
11. [Component: RecentTransactions (Table)](#component-recenttransactions)
12. [Dark Mode Rules](#dark-mode-rules)
13. [Localization (l10n) Pattern](#localization-pattern)
14. [File Structure](#file-structure)

---

## Design Principles

| Principle | Implementation |
|-----------|---------------|
| **No GridView for cards** | Use `Row` + `Expanded` to avoid overflow bugs |
| **Intrinsic height** | Use `MainAxisSize.min` instead of `childAspectRatio` |
| **Hover effects** | `MouseRegion` + `AnimatedContainer` with 150ms duration |
| **Dark mode first** | Every widget checks `Theme.of(context).brightness` |
| **RTL support** | Use `EdgeInsetsDirectional`, `AlignmentDirectional` |
| **Responsive** | 3 breakpoints: mobile (<600), tablet (600-900), desktop (>900) |
| **l10n everywhere** | All strings come from `AppLocalizations.of(context)!` |

---

## Color System

```dart
// Primary (Emerald Green)
AppColors.primary       // #10B981
Color(0xFF047857)       // primary-dark (for gradients)

// Backgrounds
Colors.white                        // Light card bg
Color(0xFF0F172A)                   // Dark page bg (Slate 900)
Color(0xFF1E293B)                   // Dark card bg (Slate 800)
AppColors.backgroundSecondary       // Light page bg

// Text
AppColors.textPrimary     // Dark text
AppColors.textSecondary   // Medium text
AppColors.textTertiary    // Light text

// Borders
AppColors.border                    // Light border
Colors.white.withAlpha(26)          // Dark border (10% white)
Colors.white.withAlpha(13)          // Dark subtle border (5% white)

// Status Colors
AppColors.success   // Green - sales, positive
AppColors.error     // Red - alerts, destructive
AppColors.warning   // Amber - warnings
AppColors.info      // Blue - info, orders
Color(0xFF8B5CF6)   // Purple - customers
```

---

## Responsive Breakpoints

```dart
final size = MediaQuery.of(context).size;
final isWideScreen = size.width > 900;    // Desktop: sidebar visible
final isMediumScreen = size.width > 600;  // Tablet
final isMobile = size.width < 600;        // Mobile

// Padding
EdgeInsets.all(isMediumScreen ? 24 : 16)

// Border radius
BorderRadius.circular(isMobile ? 16 : 24)

// Font sizes
fontSize: isMobile ? 11 : 13   // labels
fontSize: isMobile ? 16 : 18   // titles
fontSize: isMobile ? 20 : 28   // values
```

---

## Layout Structure

### Desktop (>900px)
```
+------------------------------------------+
| AppHeader (72px height)                   |
+--------+---------------------------------+
|        |  Stats: [card][card][card][card] |
| Sidebar|  +------------------+---------+ |
| (280px)|  | SalesChart (2/3) | Quick   | |
|        |  |                  | Actions | |
|        |  |                  | +TopSell| |
|        |  +------------------+---------+ |
| User   |  RecentTransactions (table)     |
| Card   |                                 |
+--------+---------------------------------+
```

### Mobile (<600px)
```
+---------------------------+
| AppHeader (56px)    [menu] |
+---------------------------+
| [stat card] [stat card]   |
| [stat card] [stat card]   |
| SalesChart (full width)   |
| QuickActions (full width) |
| TopProducts (full width)  |
| RecentTransactions        |
+---------------------------+
```

### Screen Code Pattern

```dart
return Scaffold(
  backgroundColor: isDark ? const Color(0xFF0F172A) : AppColors.backgroundSecondary,
  drawer: isWideScreen ? null : _buildDrawer(l10n),
  body: Row(
    children: [
      if (isWideScreen)
        AppSidebar(
          storeName: l10n.brandName,
          groups: DefaultSidebarItems.defaultGroups,
          selectedId: _selectedNavId,
          onItemTap: _handleNavigation,
          userName: 'Name',
          userRole: l10n.branchManager,
          collapsed: _sidebarCollapsed,
        ),
      Expanded(
        child: Column(
          children: [
            AppHeader(
              title: l10n.screenTitle,
              subtitle: _getDateSubtitle(l10n),
              showSearch: isWideScreen,
              searchHint: l10n.searchPlaceholder,
              onMenuTap: isWideScreen
                  ? () => setState(() => _sidebarCollapsed = !_sidebarCollapsed)
                  : () => Scaffold.of(context).openDrawer(),
              userName: 'Name',
              userRole: l10n.branchManager,
            ),
            Expanded(
              child: RefreshIndicator(
                onRefresh: _loadData,
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(isMediumScreen ? 24 : 16),
                  child: _buildContent(isWideScreen, isMediumScreen, l10n),
                ),
              ),
            ),
          ],
        ),
      ),
    ],
  ),
);
```

---

## Component: AppHeader

**File:** `lib/widgets/layout/app_header.dart`

### API

```dart
AppHeader(
  title: 'Screen Title',
  subtitle: 'Date or subtitle',
  showSearch: isWideScreen,
  searchHint: l10n.searchPlaceholder,
  onMenuTap: () {},
  onNotificationsTap: () {},
  notificationsCount: 3,
  userName: 'Name',
  userRole: 'Role',
  onUserTap: () {},
  showDivider: true,
)
```

### Design Details

- Height: mobile 56px, desktop 72px
- Background: white (light) / `#0F172A` (dark)
- Bottom border + subtle shadow
- Search field: hidden on mobile, `⌘K` shortcut badge, focus glow effect
- Fullscreen button: desktop only
- Language selector: always visible
- Dark mode toggle: animated rotation
- Notifications: badge with count (red dot)
- User info: hidden on mobile to prevent overflow

### Key Widgets Inside

| Widget | Description |
|--------|-------------|
| `_HeaderIconButton` | Icon button with hover bg |
| `_SearchField` | Search with focus animation, `⌘K` badge |
| `_DarkModeToggle` | Animated sun/moon toggle |
| `_NotificationButton` | Bell icon with red badge |
| `_UserInfo` | Avatar + name + role + dropdown arrow |
| `AppBreadcrumb` | Breadcrumb navigation |
| `DateTimeDisplay` | Arabic date/time display |

---

## Component: AppSidebar

**File:** `lib/widgets/layout/app_sidebar.dart`

### API

```dart
AppSidebar(
  storeName: l10n.brandName,
  storeLogoUrl: null,
  groups: DefaultSidebarItems.defaultGroups,
  selectedId: 'dashboard',
  onItemTap: (item) {},
  onSettingsTap: () {},
  onSupportTap: () {},
  onLogoutTap: () {},
  collapsed: false,
  userName: 'Name',
  userRole: 'Role',
  onUserTap: () {},
)
```

### Design Details

- Width: 280px (expanded) / 80px (collapsed)
- Animated width transition (200ms)
- Background: white (light) / `#1E293B` (dark)
- Left border + shadow
- Header: gradient logo (primary -> #047857) with glow shadow
- Nav items: selected = green bg + right border (3px green)
- Hover: subtle bg change
- Badges: red rounded pill
- "New" tag: green rounded tag
- User card at bottom: avatar + online status (green dot) + name + role + chevron
- Footer: Settings, Support, Logout (red)

### Section Groups

```dart
// Default groups structure
[
  SidebarGroup(items: [dashboard, pos]),           // No title
  SidebarGroup(title: 'Store Management', items: [products, inventory, customers]),
  SidebarGroup(title: 'Finance', items: [sales, reports]),
  SidebarGroup(title: 'Team', items: [employees, loyalty]),
]
```

---

## Component: StatCard

**File:** `lib/widgets/dashboard/stat_card.dart`

### API

```dart
DashboardStatCard(
  title: l10n.todaySalesLabel,
  value: '1,250',
  valueSuffix: l10n.sar,    // optional suffix like "SAR" or "products"
  icon: Icons.attach_money_rounded,
  iconColor: AppColors.success,
  change: 12.5,
  changeType: ChangeType.increase,
  onTap: () {},
)
```

### Factory Methods

```dart
DefaultStatCards.todaySales(l10n: l10n, value: '1250', change: 12.5, onTap: () {})
DefaultStatCards.ordersCount(l10n: l10n, value: '45', change: 5.2, onTap: () {})
DefaultStatCards.newCustomers(l10n: l10n, value: '12', change: 0, onTap: () {})
DefaultStatCards.lowStock(l10n: l10n, value: '5', alertIncrease: 2, onTap: () {})
```

### Design Details

- Border radius: mobile 16px / desktop 24px
- Padding: mobile 12px / desktop 20px
- Background: white (light) / `#1E293B` (dark)
- Subtle border + shadow (hover intensifies shadow)
- Decorative circle: 128px, positioned top:-40 left:-40, icon color at 5% opacity
- Icon container: 40x40 (mobile) / 48x48 (desktop), rounded 12/16px
- Change indicator: pill with border, shows trend icon + percentage
  - On mobile: only shows trend icon (no percentage text)
  - Colors: green (increase), red (decrease), gray (neutral)
- Value: `FittedBox` with `scaleDown` to prevent overflow

### Layout Pattern (NO GridView!)

```dart
// Desktop: 4 in a row
if (isWideScreen) {
  return Row(
    children: cards.asMap().entries.map((entry) {
      return Expanded(
        child: Padding(
          padding: EdgeInsetsDirectional.only(
            end: entry.key < cards.length - 1 ? spacing : 0,
          ),
          child: entry.value,
        ),
      );
    }).toList(),
  );
}

// Mobile: 2x2 grid
return Column(
  children: [
    Row(children: [Expanded(child: cards[0]), SizedBox(width: spacing), Expanded(child: cards[1])]),
    SizedBox(height: spacing),
    Row(children: [Expanded(child: cards[2]), SizedBox(width: spacing), Expanded(child: cards[3])]),
  ],
);
```

---

## Component: SalesChart

**File:** `lib/widgets/dashboard/sales_chart.dart`

### API

```dart
SalesChartCard(
  title: l10n.salesAnalysis,
  subtitle: l10n.storePerformance,
  data: {
    ChartPeriod.weekly: [ChartDataPoint(label: 'Sat', value: 1200), ...],
    ChartPeriod.monthly: [...],
    ChartPeriod.yearly: [...],
  },
  initialPeriod: ChartPeriod.weekly,
  onPeriodChanged: (period) {},
)
```

### Design Details

- Container: white/dark bg, rounded 16/24px, border + shadow
- Title: bold 16/18px
- Subtitle: 12px tertiary color
- Period tabs: pill-style in `Container` with background
  - Selected: white bg + shadow, bold text
  - Unselected: transparent, medium weight
- Bar chart: `SimpleBarChart` custom painter
  - 5 horizontal grid lines
  - Bars: primary color at 80% opacity
  - Rounded top corners (4px)
  - Animated height (400ms easeOutCubic)
  - Tooltip on hover showing value
  - Labels below bars
- Height: mobile 200px / desktop 280px

---

## Component: QuickActions

**File:** `lib/widgets/dashboard/elegant_quick_actions.dart`

### API

```dart
ElegantQuickActions(
  onNewSale: () {},
  onAddProduct: () {},
  onRefund: () {},
  onDailyReport: () {},
)
```

### Design Details

- Container: gradient from `AppColors.primary` to `#047857`
- Glow shadow: primary at 30% opacity, 24px blur
- Border radius: 20px
- Decorative circle: top-right, 120px, white at 10%
- Title: "Quick Actions" in white, bold 18px
- 2x2 GridView with `childAspectRatio: 1.6`, min height 88px
- Buttons: white semi-transparent background
  - Primary button (newSale): white at 20%
  - Others: white at 10%
  - Border: white at 10%/5%
  - Icon: 28px white
  - Label: 13px white bold
- 4 actions: New Sale, Add Product, Refund, Daily Report

---

## Component: TopProductsList

**File:** `lib/widgets/dashboard/sales_chart.dart` (same file)

### API

```dart
TopProductsList(
  products: [
    TopProductItem(name: 'Latte', icon: Icons.coffee_rounded, quantity: 42, revenue: 630),
    TopProductItem(name: 'Cookie', icon: Icons.cookie_rounded, quantity: 28, revenue: 280),
  ],
  maxItems: 3,
)
```

### Design Details

- Container: same card style (white/dark, rounded 24px, border+shadow)
- Title: "Top Selling" bold 16px
- Each row: icon box (44x44 rounded 12px) + name/quantity + revenue in green
- Divider between rows (not after last)
- Revenue: `AppColors.primary` bold

---

## Component: RecentTransactions

**File:** `lib/widgets/dashboard/recent_transactions.dart`

### API

```dart
RecentTransactionsList(
  transactions: [
    Transaction(
      id: '#ORD-0245',
      customerName: 'Name',
      amount: 125.00,
      type: TransactionType.sale,
      timestamp: DateTime.now(),
      paymentMethod: 'cash',
    ),
  ],
  onViewAll: () {},
  onViewDetails: (orderId) {},
)
```

### Design Details

- Container: same card style
- Header: "Recent Transactions" + "View All" link (green)
- Table columns: Order# | Customer | Time | Status | Amount | Action

| Column | Desktop | Mobile | Details |
|--------|---------|--------|---------|
| Order# | flex: 2 | flex: 3 | Monospace font, bold |
| Customer | flex: 3 | flex: 3 | Avatar (colored initials) + name |
| Time | flex: 2 | HIDDEN | Relative time ("5 min ago") |
| Status | flex: 2 | flex: 2 | Colored badge (green/gray/red) |
| Amount | flex: 2 | flex: 2 | Bold, right-aligned |
| Action | 48px | 36px | Eye icon button |

- Avatar colors cycle: blue, purple, pink, cyan, amber
- Guest customers: italic text, no avatar
- Status badges: rounded pill with border
  - Sale/Completed: green bg + green text + green border
  - Refund: slate bg + slate text + slate border
  - Cancelled: red bg + red text + red border
- Hover effect on rows (subtle bg change)
- Refund amounts show negative sign

---

## Dark Mode Rules

```dart
// Page background
isDark ? const Color(0xFF0F172A) : AppColors.backgroundSecondary

// Card background
isDark ? const Color(0xFF1E293B) : Colors.white

// Card border
isDark ? Colors.white.withAlpha(13) : AppColors.border.withAlpha(128)

// Card shadow
Colors.black.withOpacity(isDark ? 0.2 : 0.04)

// Primary text
isDark ? Colors.white : AppColors.textPrimary

// Secondary text
isDark ? Colors.white.withAlpha(153) : AppColors.textSecondary

// Tertiary text
isDark ? Colors.white.withAlpha(102) : AppColors.textTertiary

// Borders
isDark ? Colors.white.withOpacity(0.06) : AppColors.border.withOpacity(0.7)

// Hover backgrounds
isDark ? Colors.white.withOpacity(0.05) : AppColors.backgroundSecondary
```

---

## Localization Pattern

### How to use l10n in widgets

```dart
final l10n = AppLocalizations.of(context)!;

// In titles
Text(l10n.salesAnalysis)

// In stat cards (pass l10n to factory)
DefaultStatCards.todaySales(l10n: l10n, value: '0', change: 12.5)

// In formatters
'${product.quantity} ${l10n.ordersText}'
'${amount.toStringAsFixed(0)} ${l10n.sar}'
```

### Key l10n Keys Used

| Key | AR | EN |
|-----|----|----|
| `dashboardTitle` | لوحة التحكم | Dashboard |
| `salesAnalysis` | تحليل المبيعات | Sales Analysis |
| `storePerformance` | أداء المتجر | Store Performance |
| `quickAction` | إجراء سريع | Quick Action |
| `topSelling` | الأكثر مبيعاً | Top Selling |
| `recentTransactions` | المعاملات الأخيرة | Recent Transactions |
| `todaySalesLabel` | مبيعات اليوم | Today's Sales |
| `ordersCountLabel` | عدد الطلبات | Orders Count |
| `newCustomersLabel` | عملاء جدد | New Customers |
| `stockAlertsLabel` | تنبيهات المخزون | Stock Alerts |
| `sar` | ر.س | SAR |
| `productsUnit` | منتجات | Products |
| `newSale` | بيع جديد | New Sale |
| `addProduct` | إضافة منتج | Add Product |
| `refund` | استرجاع | Refund |
| `dailyReport` | تقرير يومي | Daily Report |
| `viewAll` | عرض الكل | View All |
| `weekly` | أسبوعي | Weekly |
| `monthly` | شهري | Monthly |
| `yearly` | سنوي | Yearly |
| `guestCustomer` | عميل زائر | Guest Customer |
| `cashCustomer` | عميل كاش | Cash Customer |
| `ordersText` | طلبات | Orders |
| `searchPlaceholder` | بحث عام... | Search... |
| `branchManager` | مدير الفرع | Branch Manager |
| `brandName` | متجر الحل | Al-Hal POS |
| `fullscreen` | ملء الشاشة | Fullscreen |

### Languages Supported (7)

1. Arabic (ar) - RTL
2. English (en) - LTR
3. Urdu (ur) - RTL
4. Hindi (hi) - LTR
5. Bengali (bn) - LTR
6. Filipino (fil) - LTR
7. Indonesian (id) - LTR

---

## File Structure

```
lib/
  screens/
    dashboard/
      dashboard_screen.dart          # Main screen (461 lines)
  widgets/
    dashboard/
      stat_card.dart                 # Stat cards (346 lines)
      sales_chart.dart               # Bar chart + TopProducts (518 lines)
      elegant_quick_actions.dart     # Quick actions gradient card (201 lines)
      recent_transactions.dart       # Transactions table (647 lines)
    layout/
      app_header.dart                # Header with search, actions (810 lines)
      app_sidebar.dart               # Sidebar with user card (791 lines)
  l10n/
    app_ar.arb                       # Arabic translations
    app_en.arb                       # English translations
    app_ur.arb                       # Urdu translations
    app_hi.arb                       # Hindi translations
    app_bn.arb                       # Bengali translations
    app_fil.arb                      # Filipino translations
    app_id.arb                       # Indonesian translations
    generated/                       # Auto-generated l10n files
```

---

## Quick Reuse Checklist

When applying this design to a new screen:

- [ ] Use `AppHeader` with title, subtitle, search, notifications
- [ ] Use `AppSidebar` with user card (desktop) / `Drawer` (mobile)
- [ ] Use `Row` + `Expanded` for card grids (NOT `GridView`)
- [ ] Apply consistent card styling: white/dark bg, border, shadow, rounded 16/24
- [ ] Add hover effects with `MouseRegion` + `AnimatedContainer`
- [ ] Pass `AppLocalizations l10n` to all widgets
- [ ] Test at 3 widths: 375px, 768px, 1440px
- [ ] Verify dark mode colors
- [ ] Check RTL layout with Arabic
