import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../widgets/layout/app_sidebar.dart';
import '../../widgets/layout/app_header.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../core/theme/app_colors.dart';
import '../../core/router/routes.dart';

/// شاشة إضافة فاتورة شراء
class PurchaseFormScreen extends ConsumerStatefulWidget {
  const PurchaseFormScreen({super.key});

  @override
  ConsumerState<PurchaseFormScreen> createState() => _PurchaseFormScreenState();
}

class _PurchaseFormScreenState extends ConsumerState<PurchaseFormScreen> {
  bool _sidebarCollapsed = false;
  String _selectedNavId = 'products';

  String? _selectedSupplierId;
  final List<_PurchaseItem> _items = [];
  String _paymentStatus = 'paid';
  final _invoiceNoController = TextEditingController();

  double get _subtotal => _items.fold(0, (sum, item) => sum + item.total);

  @override
  void dispose() {
    _invoiceNoController.dispose();
    super.dispose();
  }

  void _handleNavigation(AppSidebarItem item) {
    setState(() => _selectedNavId = item.id);
    switch (item.id) {
      case 'dashboard':
        context.go(AppRoutes.dashboard);
        break;
      case 'pos':
        context.go(AppRoutes.pos);
        break;
      case 'products':
        context.push(AppRoutes.products);
        break;
      case 'categories':
        context.push(AppRoutes.categories);
        break;
      case 'inventory':
        context.push(AppRoutes.inventory);
        break;
      case 'customers':
        context.push(AppRoutes.customers);
        break;
      case 'invoices':
        context.push(AppRoutes.invoices);
        break;
      case 'orders':
        context.push(AppRoutes.orders);
        break;
      case 'sales':
        context.push(AppRoutes.invoices);
        break;
      case 'returns':
        context.push(AppRoutes.returns);
        break;
      case 'reports':
        context.push(AppRoutes.reports);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isWideScreen = size.width > 900;
    final isMediumScreen = size.width > 600;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor:
          isDark ? const Color(0xFF0F172A) : AppColors.backgroundSecondary,
      drawer: isWideScreen ? null : _buildDrawer(l10n),
      body: Row(
        children: [
          if (isWideScreen)
            AppSidebar(
              storeName: l10n.brandName,
              groups: DefaultSidebarItems.getGroups(context),
              selectedId: _selectedNavId,
              onItemTap: _handleNavigation,
              onSettingsTap: () => context.push(AppRoutes.settings),
              onSupportTap: () {},
              onLogoutTap: () => context.go('/login'),
              collapsed: _sidebarCollapsed,
              userName: '\u0623\u062D\u0645\u062F \u0645\u062D\u0645\u062F',
              userRole: l10n.branchManager,
              onUserTap: () {},
            ),
          Expanded(
            child: Column(
              children: [
                AppHeader(
                  title: '\u0641\u0627\u062A\u0648\u0631\u0629 \u0634\u0631\u0627\u0621 \u062C\u062F\u064A\u062F\u0629', // TODO: localize
                  onMenuTap: isWideScreen
                      ? () => setState(
                          () => _sidebarCollapsed = !_sidebarCollapsed)
                      : () => Scaffold.of(context).openDrawer(),
                  onNotificationsTap: () => context.push('/notifications'),
                  notificationsCount: 3,
                  userName: '\u0623\u062D\u0645\u062F \u0645\u062D\u0645\u062F',
                  userRole: l10n.branchManager,
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.all(isMediumScreen ? 24 : 16),
                    child: _buildContent(
                        isWideScreen, isMediumScreen, isDark, l10n),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawer(AppLocalizations l10n) {
    return Drawer(
      child: AppSidebar(
        storeName: l10n.brandName,
        groups: DefaultSidebarItems.getGroups(context),
        selectedId: _selectedNavId,
        onItemTap: (item) {
          Navigator.pop(context);
          _handleNavigation(item);
        },
        onSettingsTap: () {
          Navigator.pop(context);
          context.push(AppRoutes.settings);
        },
        onSupportTap: () => Navigator.pop(context),
        onLogoutTap: () {
          Navigator.pop(context);
          context.go('/login');
        },
        userName: '\u0623\u062D\u0645\u062F \u0645\u062D\u0645\u062F',
        userRole: l10n.branchManager,
        onUserTap: () {},
      ),
    );
  }

  Widget _buildContent(
      bool isWideScreen, bool isMediumScreen, bool isDark, AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Action bar
        Row(
          children: [
            IconButton(
              onPressed: () => context.pop(),
              icon: Icon(Icons.arrow_back_rounded,
                  color: isDark ? Colors.white : AppColors.textPrimary),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                '\u0641\u0627\u062A\u0648\u0631\u0629 \u0634\u0631\u0627\u0621 \u062C\u062F\u064A\u062F\u0629', // TODO: localize
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : AppColors.textPrimary,
                ),
              ),
            ),
            FilledButton.icon(
              onPressed: _items.isEmpty ? null : _savePurchase,
              icon: const Icon(Icons.save),
              label: const Text('\u062D\u0641\u0638'), // TODO: localize
            ),
          ],
        ),
        const SizedBox(height: 24),

        // Main content - responsive
        if (isWideScreen)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 2,
                child: Column(
                  children: [
                    _buildSupplierCard(isDark),
                    const SizedBox(height: 16),
                    _buildItemsCard(isDark),
                  ],
                ),
              ),
              const SizedBox(width: 24),
              Expanded(
                flex: 1,
                child: Column(
                  children: [
                    _buildPaymentCard(isDark),
                    const SizedBox(height: 16),
                    _buildTotalCard(isDark),
                  ],
                ),
              ),
            ],
          )
        else
          Column(
            children: [
              _buildSupplierCard(isDark),
              const SizedBox(height: 16),
              _buildItemsCard(isDark),
              const SizedBox(height: 16),
              _buildPaymentCard(isDark),
              const SizedBox(height: 16),
              _buildTotalCard(isDark),
            ],
          ),
      ],
    );
  }

  Widget _buildSupplierCard(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.1)
              : AppColors.border,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.store_rounded,
                    color: AppColors.primary, size: 20),
              ),
              const SizedBox(width: 12),
              Text(
                '\u0628\u064A\u0627\u0646\u0627\u062A \u0627\u0644\u0645\u0648\u0631\u062F', // TODO: localize
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            decoration: InputDecoration(
              labelText: '\u0627\u062E\u062A\u0631 \u0627\u0644\u0645\u0648\u0631\u062F *', // TODO: localize
              prefixIcon: const Icon(Icons.store),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            value: _selectedSupplierId,
            items: const [
              DropdownMenuItem(value: '1', child: Text('\u0645\u0648\u0631\u062F 1')),
              DropdownMenuItem(value: '2', child: Text('\u0645\u0648\u0631\u062F 2')),
              DropdownMenuItem(value: '3', child: Text('\u0645\u0648\u0631\u062F 3')),
            ],
            onChanged: (v) => setState(() => _selectedSupplierId = v),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _invoiceNoController,
            decoration: InputDecoration(
              labelText: '\u0631\u0642\u0645 \u0641\u0627\u062A\u0648\u0631\u0629 \u0627\u0644\u0645\u0648\u0631\u062F', // TODO: localize
              prefixIcon: const Icon(Icons.receipt),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItemsCard(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.1)
              : AppColors.border,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.info.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.inventory_2_rounded,
                        color: AppColors.info, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    '\u0627\u0644\u0645\u0646\u062A\u062C\u0627\u062A', // TODO: localize
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
              FilledButton.tonalIcon(
                onPressed: _addProduct,
                icon: const Icon(Icons.add, size: 18),
                label: const Text('\u0625\u0636\u0627\u0641\u0629 \u0645\u0646\u062A\u062C'), // TODO: localize
              ),
            ],
          ),
          const SizedBox(height: 16),
          Divider(
            color: isDark
                ? Colors.white.withValues(alpha: 0.1)
                : AppColors.border,
          ),
          if (_items.isEmpty)
            Padding(
              padding: const EdgeInsets.all(32),
              child: Center(
                child: Column(
                  children: [
                    Icon(Icons.inventory_2_outlined,
                        size: 48,
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.3)
                            : AppColors.textTertiary),
                    const SizedBox(height: 12),
                    Text(
                      '\u0644\u0645 \u064A\u062A\u0645 \u0625\u0636\u0627\u0641\u0629 \u0645\u0646\u062A\u062C\u0627\u062A \u0628\u0639\u062F', // TODO: localize
                      style: TextStyle(
                          color: isDark
                              ? Colors.white.withValues(alpha: 0.5)
                              : AppColors.textTertiary),
                    ),
                  ],
                ),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _items.length,
              separatorBuilder: (_, __) => Divider(
                height: 1,
                color: isDark
                    ? Colors.white.withValues(alpha: 0.05)
                    : AppColors.border,
              ),
              itemBuilder: (context, index) {
                final item = _items[index];
                return ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 4, vertical: 4),
                  title: Text(
                    item.productName,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white : AppColors.textPrimary,
                    ),
                  ),
                  subtitle: Text(
                    '${item.qty} \u00D7 ${item.cost.toStringAsFixed(2)} \u0631.\u0633',
                    style: TextStyle(
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.6)
                            : AppColors.textSecondary),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '${item.total.toStringAsFixed(2)} \u0631.\u0633',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : AppColors.textPrimary,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline,
                            color: AppColors.error),
                        onPressed: () =>
                            setState(() => _items.removeAt(index)),
                      ),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildPaymentCard(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.1)
              : AppColors.border,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.warning.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.payment_rounded,
                    color: AppColors.warning, size: 20),
              ),
              const SizedBox(width: 12),
              Text(
                '\u062D\u0627\u0644\u0629 \u0627\u0644\u062F\u0641\u0639', // TODO: localize
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SegmentedButton<String>(
            segments: const [
              ButtonSegment(
                  value: 'paid',
                  label: Text('\u0645\u062F\u0641\u0648\u0639\u0629'),
                  icon: Icon(Icons.check_circle)),
              ButtonSegment(
                  value: 'credit',
                  label: Text('\u0622\u062C\u0644'),
                  icon: Icon(Icons.schedule)),
            ],
            selected: {_paymentStatus},
            onSelectionChanged: (s) =>
                setState(() => _paymentStatus = s.first),
          ),
        ],
      ),
    );
  }

  Widget _buildTotalCard(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [const Color(0xFF065F46), const Color(0xFF064E3B)]
              : [
                  AppColors.primary.withValues(alpha: 0.1),
                  AppColors.primary.withValues(alpha: 0.05)
                ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark
              ? AppColors.primary.withValues(alpha: 0.3)
              : AppColors.primaryBorder,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '\u0627\u0644\u0625\u062C\u0645\u0627\u0644\u064A', // TODO: localize
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white : AppColors.textPrimary,
            ),
          ),
          Text(
            '${_subtotal.toStringAsFixed(2)} \u0631.\u0633',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: isDark ? AppColors.primaryLight : AppColors.primaryDark,
            ),
          ),
        ],
      ),
    );
  }

  void _addProduct() {
    showDialog(
      context: context,
      builder: (context) {
        final nameController = TextEditingController();
        final qtyController = TextEditingController(text: '1');
        final costController = TextEditingController();

        return AlertDialog(
          title: const Text('\u0625\u0636\u0627\u0641\u0629 \u0645\u0646\u062A\u062C'), // TODO: localize
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: '\u0627\u0633\u0645 \u0627\u0644\u0645\u0646\u062A\u062C *'),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: qtyController,
                      decoration: const InputDecoration(labelText: '\u0627\u0644\u0643\u0645\u064A\u0629'),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: costController,
                      decoration: const InputDecoration(labelText: '\u0633\u0639\u0631 \u0627\u0644\u0634\u0631\u0627\u0621'),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('\u0625\u0644\u063A\u0627\u0621'),
            ),
            FilledButton(
              onPressed: () {
                final name = nameController.text;
                final qty = int.tryParse(qtyController.text) ?? 1;
                final cost = double.tryParse(costController.text) ?? 0;

                if (name.isNotEmpty && cost > 0) {
                  setState(() {
                    _items.add(_PurchaseItem(
                      productId: 'temp_${_items.length}',
                      productName: name,
                      qty: qty,
                      cost: cost,
                    ));
                  });
                }
                Navigator.pop(context);
              },
              child: const Text('\u0625\u0636\u0627\u0641\u0629'),
            ),
          ],
        );
      },
    );
  }

  void _savePurchase() {
    if (_selectedSupplierId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('\u064A\u0631\u062C\u0649 \u0627\u062E\u062A\u064A\u0627\u0631 \u0627\u0644\u0645\u0648\u0631\u062F')),
      );
      return;
    }

    // TODO: Save purchase via service
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content: Text(
              '\u062A\u0645 \u062D\u0641\u0638 \u0641\u0627\u062A\u0648\u0631\u0629 \u0627\u0644\u0634\u0631\u0627\u0621 \u0628\u0625\u062C\u0645\u0627\u0644\u064A ${_subtotal.toStringAsFixed(2)} \u0631.\u0633')),
    );
    context.pop();
  }
}

class _PurchaseItem {
  final String productId;
  final String productName;
  final int qty;
  final double cost;

  _PurchaseItem({
    required this.productId,
    required this.productName,
    required this.qty,
    required this.cost,
  });

  double get total => qty * cost;
}
