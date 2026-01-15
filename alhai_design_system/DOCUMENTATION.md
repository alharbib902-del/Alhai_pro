# Alhai Design System Documentation

نظام التصميم الموحد للتطبيقات - RTL-first، Material 3، Token-based

---

## 📦 التثبيت

```yaml
# pubspec.yaml
dependencies:
  alhai_design_system:
    path: ../alhai_design_system
```

```dart
import 'package:alhai_design_system/alhai_design_system.dart';
```

---

## 🎨 Theme Setup

```dart
MaterialApp(
  theme: AlhaiTheme.light(),
  darkTheme: AlhaiTheme.dark(),
  themeMode: ThemeMode.system,
  builder: (context, child) => Directionality(
    textDirection: TextDirection.rtl,
    child: child!,
  ),
)
```

---

## 📐 Tokens

### Spacing
```dart
AlhaiSpacing.xxxs  // 2dp
AlhaiSpacing.xxs   // 4dp
AlhaiSpacing.xs    // 8dp
AlhaiSpacing.sm    // 12dp
AlhaiSpacing.md    // 16dp
AlhaiSpacing.lg    // 24dp
AlhaiSpacing.xl    // 32dp
AlhaiSpacing.xxl   // 48dp
AlhaiSpacing.xxxl  // 64dp
```

### Radius
```dart
AlhaiRadius.xs     // 4dp
AlhaiRadius.sm     // 8dp
AlhaiRadius.md     // 12dp
AlhaiRadius.lg     // 16dp
AlhaiRadius.xl     // 24dp
AlhaiRadius.full   // 9999dp
AlhaiRadius.card   // 16dp
AlhaiRadius.button // 12dp
```

### Durations
```dart
AlhaiDurations.instant     // 0ms
AlhaiDurations.fast        // 100ms
AlhaiDurations.standard    // 200ms
AlhaiDurations.slow        // 300ms
AlhaiDurations.shimmer     // 1500ms
```

---

## 🔘 Buttons

### AlhaiButton
```dart
// Primary (default)
AlhaiButton(
  label: 'أضف للسلة',
  onPressed: () {},
)

// Variants
AlhaiButton.secondary(label: 'إلغاء', onPressed: () {})
AlhaiButton.outlined(label: 'تفاصيل', onPressed: () {})
AlhaiButton.text(label: 'تخطي', onPressed: () {})
AlhaiButton.danger(label: 'حذف', onPressed: () {})

// With icons
AlhaiButton(
  label: 'أضف للسلة',
  leadingIcon: Icons.add_shopping_cart,
  onPressed: () {},
)

// Loading state
AlhaiButton(
  label: 'جاري الإرسال',
  isLoading: true,
  onPressed: () {},
)

// Full width
AlhaiButton(
  label: 'تأكيد الطلب',
  fullWidth: true,
  onPressed: () {},
)
```

### AlhaiIconButton
```dart
AlhaiIconButton(
  icon: Icons.favorite_border,
  onPressed: () {},
)

AlhaiIconButton.filled(
  icon: Icons.share,
  onPressed: () {},
)
```

---

## 📝 Inputs

### AlhaiTextField
```dart
AlhaiTextField(
  label: 'البريد الإلكتروني',
  hint: 'example@email.com',
  controller: _emailController,
  keyboardType: TextInputType.emailAddress,
  prefixIcon: Icons.email_outlined,
  validator: AlhaiValidators.email,
)

// Password
AlhaiTextField.password(
  label: 'كلمة المرور',
  controller: _passwordController,
)

// Multiline
AlhaiTextField.multiline(
  label: 'الملاحظات',
  maxLines: 4,
)
```

### AlhaiSearchField
```dart
AlhaiSearchField(
  hint: 'ابحث عن منتج...',
  onChanged: (query) {},
  onSubmitted: (query) {},
)
```

### AlhaiDropdown
```dart
AlhaiDropdown<String>(
  label: 'المدينة',
  value: selectedCity,
  items: cities.map((c) => DropdownMenuItem(
    value: c,
    child: Text(c),
  )).toList(),
  onChanged: (value) {},
)
```

### AlhaiQuantityControl
```dart
AlhaiQuantityControl(
  value: quantity,
  onChanged: (newValue) {},
  min: 1,
  max: 99,
)
```

### AlhaiCheckbox
```dart
AlhaiCheckbox(
  value: acceptTerms,
  onChanged: (value) {},
  label: 'أوافق على الشروط',
  subtitle: 'اقرأ الشروط والأحكام',
)

// Tristate
AlhaiCheckbox(
  value: null, // indeterminate
  tristate: true,
  onChanged: (value) {},
  label: 'تحديد الكل',
)
```

### AlhaiSwitch
```dart
AlhaiSwitch(
  value: notificationsEnabled,
  onChanged: (value) {},
  label: 'الإشعارات',
  subtitle: 'استلام إشعارات الطلبات',
  leading: Icon(Icons.notifications_outlined),
)
```

### AlhaiRadioGroup
```dart
AlhaiRadioGroup<String>(
  value: selectedPayment,
  onChanged: (value) {},
  options: [
    AlhaiRadioOption(value: 'cash', label: 'الدفع نقداً'),
    AlhaiRadioOption(value: 'card', label: 'بطاقة ائتمان'),
    AlhaiRadioOption(value: 'wallet', label: 'المحفظة'),
  ],
)
```

---

## 📊 Data Display

### AlhaiPriceText
```dart
AlhaiPriceText(
  amount: 125.50,
  currency: 'ر.س',
)

// With original price (discount)
AlhaiPriceText(
  amount: 99.00,
  originalAmount: 150.00,
  currency: 'ر.س',
)
```

### AlhaiProductCard
```dart
AlhaiProductCard(
  title: 'برجر كلاسيك',
  price: 35.00,
  imageUrl: 'https://...',
  onTap: () {},
  onAddToCart: () {},
  discount: 20,
  rating: 4.5,
)
```

### AlhaiCartItem
```dart
AlhaiCartItem(
  title: 'برجر كلاسيك',
  price: 35.00,
  quantity: 2,
  onQuantityChanged: (qty) {},
  onRemove: () {},
  leading: Image.network('...'),
)
```

### AlhaiOrderStatusBadge
```dart
AlhaiOrderStatusBadge(
  status: AlhaiOrderStatus.preparing,
  label: 'قيد التحضير',
)
```

### AlhaiOrderStatusTimeline
```dart
AlhaiOrderStatusTimeline(
  currentStatus: AlhaiOrderStatus.delivering,
  labels: {
    AlhaiOrderStatus.new_: 'جديد',
    AlhaiOrderStatus.confirmed: 'مؤكد',
    AlhaiOrderStatus.preparing: 'قيد التحضير',
    AlhaiOrderStatus.delivering: 'في الطريق',
    AlhaiOrderStatus.delivered: 'تم التوصيل',
  },
)
```

### AlhaiOrderRow
```dart
AlhaiOrderRow(
  orderNumber: '#1234',
  status: AlhaiOrderStatus.preparing,
  statusLabel: 'قيد التحضير',
  totalAmount: 125.50,
  itemCount: 3,
  createdAt: '10:30 ص',
  onTap: () {},
)
```

### AlhaiOrderCard
```dart
AlhaiOrderCard(
  orderNumber: '#1234',
  status: AlhaiOrderStatus.delivering,
  statusLabel: 'في الطريق',
  customer: 'أحمد محمد',
  phone: '0500000000',
  address: 'الرياض، حي النرجس',
  items: [
    AlhaiOrderCardItem(name: 'برجر', quantity: 2, price: 35),
  ],
  subtotal: 70.0,
  delivery: 15.0,
  total: 85.0,
  onTap: () {},
  onCall: () {},
  onMap: () {},
)
```

---

## 💬 Feedback

### AlhaiBadge
```dart
// Count badge
AlhaiBadge.count(
  count: 5,
  child: Icon(Icons.notifications),
)

// Dot badge
AlhaiBadge.dot(
  child: Icon(Icons.message),
)
```

### AlhaiSnackbar
```dart
AlhaiSnackbar.show(
  context,
  message: 'تمت الإضافة للسلة',
  variant: AlhaiSnackbarVariant.success,
  action: SnackBarAction(label: 'تراجع', onPressed: () {}),
);
```

### AlhaiDialog
```dart
AlhaiDialog.show(
  context,
  title: 'تأكيد الحذف',
  content: 'هل أنت متأكد من حذف هذا العنصر؟',
  confirmLabel: 'حذف',
  cancelLabel: 'إلغاء',
  isDestructive: true,
  onConfirm: () {},
);
```

### AlhaiBottomSheet
```dart
AlhaiBottomSheet.show(
  context,
  title: 'اختر طريقة الدفع',
  child: PaymentMethodsList(),
);
```

### AlhaiEmptyState
```dart
AlhaiEmptyState(
  icon: Icons.shopping_cart_outlined,
  title: 'السلة فارغة',
  subtitle: 'ابدأ بإضافة منتجات',
  action: AlhaiButton(
    label: 'تصفح المنتجات',
    onPressed: () {},
  ),
)
```

### AlhaiStateView
```dart
AlhaiStateView.loading()
AlhaiStateView.empty(title: 'لا توجد نتائج')
AlhaiStateView.error(
  message: 'حدث خطأ',
  onRetry: () {},
)
```

### AlhaiInlineAlert
```dart
AlhaiInlineAlert.info(message: 'معلومة مهمة')
AlhaiInlineAlert.warning(message: 'تحذير')
AlhaiInlineAlert.error(message: 'خطأ')
AlhaiInlineAlert.success(message: 'نجاح')
```

### AlhaiSkeleton / AlhaiShimmer
```dart
// Basic skeleton
AlhaiSkeleton.rectangle(width: 100, height: 20)
AlhaiSkeleton.circle(size: 48)
AlhaiSkeleton.text(lines: 3)

// Pre-built skeletons
AlhaiSkeleton.listTile()
AlhaiSkeleton.productCard()
AlhaiSkeleton.cartItem()

// With shimmer
AlhaiShimmer(
  child: AlhaiSkeleton.productCard(),
)
```

---

## 🧭 Navigation

### AlhaiAppBar
```dart
AlhaiAppBar(
  title: 'الطلبات',
  leading: BackButton(),
  actions: [
    AlhaiIconButton(icon: Icons.search, onPressed: () {}),
  ],
)
```

### AlhaiBottomNavBar
```dart
AlhaiBottomNavBar(
  currentIndex: _currentIndex,
  onTap: (index) {},
  items: [
    AlhaiBottomNavItem(icon: Icons.home, label: 'الرئيسية'),
    AlhaiBottomNavItem(icon: Icons.list, label: 'الطلبات', badgeCount: 3),
    AlhaiBottomNavItem(icon: Icons.person, label: 'حسابي'),
  ],
)
```

### AlhaiTabs / AlhaiTabBar
```dart
AlhaiTabBar(
  currentIndex: _tabIndex,
  onChanged: (index) {},
  tabs: [
    AlhaiTab(label: 'الكل'),
    AlhaiTab(label: 'جديد', badge: '5'),
    AlhaiTab(label: 'قيد التحضير'),
  ],
)
```

---

## 📐 Layout

### AlhaiCard
```dart
AlhaiCard(
  child: Column(...),
  onTap: () {},
)
```

### AlhaiSection
```dart
AlhaiSection(
  title: 'الأكثر مبيعاً',
  trailing: TextButton(child: Text('عرض الكل'), onPressed: () {}),
  child: ProductsGrid(),
)
```

### AlhaiListTile
```dart
AlhaiListTile(
  leading: Icon(Icons.settings),
  title: 'الإعدادات',
  subtitle: 'تخصيص التطبيق',
  trailing: Icon(Icons.chevron_right),
  onTap: () {},
)
```

### AlhaiDivider
```dart
// Horizontal
const AlhaiDivider()

// With indent
AlhaiDivider.horizontal(indent: 16, endIndent: 16)

// Vertical
AlhaiDivider.vertical(height: 24)

// With label
AlhaiDivider.withLabel(label: 'أو')
```

### AlhaiAvatar
```dart
AlhaiAvatar(
  imageUrl: 'https://...',
  name: 'أحمد محمد',
  size: AlhaiAvatarSize.md,
)
```

---

## 🛠 Utils

### Validators
```dart
AlhaiValidators.required
AlhaiValidators.email
AlhaiValidators.phone
AlhaiValidators.minLength(6)
AlhaiValidators.maxLength(100)
```

### Input Formatters
```dart
AlhaiInputFormatters.phone
AlhaiInputFormatters.digitsOnly
AlhaiInputFormatters.currency
```

---

## 📱 RTL Support

جميع المكونات تدعم RTL بشكل كامل:
- `EdgeInsetsDirectional` بدل `EdgeInsets`
- `AlignmentDirectional` بدل `Alignment`
- أيقونات اتجاهية (chevron_left/right حسب الاتجاه)
- `TextDirection` من السياق

---

## 🌙 Dark Mode

جميع المكونات تدعم الوضع الداكن تلقائياً عبر `ColorScheme`:
- `colorScheme.surface`
- `colorScheme.onSurface`
- `colorScheme.primary`
- `colorScheme.outlineVariant`
- إلخ...

---

## ♿ Accessibility

- `Semantics` مُطبق على جميع المكونات التفاعلية
- `MergeSemantics` للعناصر المركبة
- `tooltip` للأزرار الأيقونية
- `label` للعناصر القابلة للنقر

---

## 📦 Component List (38)

| Category | Components |
|----------|------------|
| Tokens | Colors, Spacing, Radius, Typography, Durations, Motion, OrderStatusTokens |
| Inputs | TextField, SearchField, Dropdown, QuantityControl, Checkbox, Switch, RadioGroup |
| Buttons | Button, IconButton |
| Feedback | Badge, EmptyState, Snackbar, BottomSheet, Dialog, StateView, InlineAlert, Skeleton/Shimmer |
| Navigation | AppBar, Tabs, BottomNavBar, TabBar |
| Layout | Card, Section, Scaffold, ListTile, Avatar, Divider |
| Data Display | PriceText, ProductCard, CartItem, OrderStatus, OrderRow, OrderCard |

---

**Last Updated:** 2026-01-10
**Version:** 1.0.0
