import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:alhai_shared_ui/alhai_shared_ui.dart';
import 'package:alhai_l10n/alhai_l10n.dart';
import 'package:alhai_database/alhai_database.dart';
import 'package:get_it/get_it.dart';
import 'package:alhai_design_system/alhai_design_system.dart';

/// Smart Reorder Screen - شاشة الطلب الذكي من الموردين
class SmartReorderScreen extends ConsumerStatefulWidget {
  const SmartReorderScreen({super.key});

  @override
  ConsumerState<SmartReorderScreen> createState() => _SmartReorderScreenState();
}

class _SmartReorderScreenState extends ConsumerState<SmartReorderScreen> {
  final _budgetController = TextEditingController(text: '5000');
  String? _selectedSupplier;
  bool _isCalculating = false;
  List<_ReorderItem> _suggestions = [];

  bool _isLoadingSuppliers = true;
  List<SuppliersTableData> _suppliersList = [];

  @override
  void initState() {
    super.initState();
    _loadSuppliers();
  }

  @override
  void dispose() {
    _budgetController.dispose();
    super.dispose();
  }

  Future<void> _loadSuppliers() async {
    try {
      final db = GetIt.I<AppDatabase>();
      final storeId = ref.read(currentStoreIdProvider);
      if (storeId == null) {
        if (mounted) setState(() => _isLoadingSuppliers = false);
        return;
      }

      final suppliers = await db.suppliersDao.getActiveSuppliers(storeId);
      if (mounted) {
        setState(() {
          _suppliersList = suppliers;
          _isLoadingSuppliers = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoadingSuppliers = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isWideScreen = size.width > 900;
    final isMediumScreen = size.width > 600;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context);

    return Column(
      children: [
        AppHeader(
          title: l10n.smartReorderTitle,
          onMenuTap: isWideScreen ? null : () => Scaffold.of(context).openDrawer(),
          onNotificationsTap: () => context.push('/notifications'),
          notificationsCount: 3,
          userName: l10n.defaultUserName,
          userRole: l10n.branchManager,
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(isMediumScreen ? 24 : 16),
            child: _buildContent(isWideScreen, isMediumScreen, isDark, l10n),
          ),
        ),
      ],
    );
  }

  Widget _buildContent(bool isWideScreen, bool isMediumScreen, bool isDark, AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            IconButton(
              onPressed: () => context.pop(),
              icon: Icon(Icons.arrow_back_rounded, color: Theme.of(context).colorScheme.onSurface),
            ),
            const SizedBox(width: AlhaiSpacing.xs),
            Expanded(
              child: Text(l10n.smartReorderTitle, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface)),
            ),
            if (_suggestions.isNotEmpty)
              FilledButton.icon(onPressed: _sendOrder, icon: const Icon(Icons.send, size: 18), label: Text(l10n.sendOrder)),
          ],
        ),
        const SizedBox(height: AlhaiSpacing.lg),

        // AI Header Card
        Container(
          padding: const EdgeInsets.all(AlhaiSpacing.mdl),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isDark
                  ? [const Color(0xFF581C87), const Color(0xFF4C1D95)]
                  : [const Color(0xFFF3E8FF), const Color(0xFFEDE9FE)],
              begin: AlignmentDirectional.topStart,
              end: AlignmentDirectional.bottomEnd,
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: isDark ? Colors.purple.withValues(alpha: 0.3) : const Color(0xFFD8B4FE)),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AlhaiSpacing.sm),
                decoration: BoxDecoration(
                  color: isDark ? Colors.purple.withValues(alpha: 0.3) : Colors.purple.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.psychology, color: isDark ? Colors.purple.shade200 : Colors.purple, size: 28),
              ),
              const SizedBox(width: AlhaiSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(l10n.smartReorderAiTitle, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: isDark ? Colors.white : Colors.purple.shade900)),
                    const SizedBox(height: AlhaiSpacing.xxs),
                    Text(l10n.smartReorderDescription, style: TextStyle(fontSize: 13, color: isDark ? Colors.white.withValues(alpha: 0.7) : Colors.purple.shade700)),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AlhaiSpacing.lg),

        if (isWideScreen)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(flex: 1, child: _buildFormSection(isDark)),
              const SizedBox(width: AlhaiSpacing.lg),
              Expanded(flex: 2, child: _buildResultsSection(isDark)),
            ],
          )
        else
          Column(children: [
            _buildFormSection(isDark),
            const SizedBox(height: AlhaiSpacing.lg),
            _buildResultsSection(isDark),
          ]),
      ],
    );
  }

  Widget _buildFormSection(bool isDark) {
    final l10n = AppLocalizations.of(context);
    return Container(
      padding: const EdgeInsets.all(AlhaiSpacing.mdl),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Container(
              padding: const EdgeInsets.all(AlhaiSpacing.xs),
              decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
              child: const Icon(Icons.tune_rounded, color: AppColors.primary, size: 20),
            ),
            const SizedBox(width: AlhaiSpacing.sm),
            Text(l10n.orderSettings, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface)),
          ]),
          const SizedBox(height: AlhaiSpacing.mdl),
          TextField(
            controller: _budgetController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: l10n.availableBudget,
              suffixText: l10n.sar,
              prefixIcon: const Icon(Icons.account_balance_wallet),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              helperText: l10n.enterAvailableAmount,
            ),
          ),
          const SizedBox(height: AlhaiSpacing.md),
          DropdownButtonFormField<String>(
            initialValue: _selectedSupplier,
            decoration: InputDecoration(
              labelText: l10n.supplier,
              prefixIcon: const Icon(Icons.storefront),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
            items: _isLoadingSuppliers
                ? []
                : _suppliersList.map((s) => DropdownMenuItem(value: s.name, child: Text(s.name))).toList(),
            onChanged: (v) => setState(() => _selectedSupplier = v),
          ),
          const SizedBox(height: AlhaiSpacing.lg),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: _isCalculating ? null : _calculateSuggestions,
              icon: _isCalculating
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                  : const Icon(Icons.auto_awesome),
              label: Text(_isCalculating ? l10n.calculating : l10n.calculateSmartDistribution),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultsSection(bool isDark) {
    final l10n = AppLocalizations.of(context);
    if (_suggestions.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(AlhaiSpacing.xxxl),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Theme.of(context).dividerColor),
        ),
        child: Center(
          child: Column(children: [
            Icon(Icons.auto_awesome_outlined, size: 64, color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.5)),
            const SizedBox(height: AlhaiSpacing.md),
            Text(l10n.setBudgetAndCalculate, style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, fontSize: 16)),
          ]),
        ),
      );
    }

    return Column(
      children: [
        Row(children: [
          Expanded(child: _SummaryCard(title: l10n.numberOfProducts, value: '${_suggestions.length}', icon: Icons.inventory_2, color: AppColors.info, isDark: isDark)),
          const SizedBox(width: AlhaiSpacing.sm),
          Expanded(child: _SummaryCard(title: l10n.totalLabel, value: '${_totalCost.toStringAsFixed(0)} ${l10n.sar}', icon: Icons.payments, color: AppColors.success, isDark: isDark)),
        ]),
        const SizedBox(height: AlhaiSpacing.md),
        Container(
          padding: const EdgeInsets.all(AlhaiSpacing.mdl),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Theme.of(context).dividerColor),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(l10n.suggestedProducts, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface)),
              const SizedBox(height: AlhaiSpacing.md),
              ..._suggestions.map((item) => _ReorderItemCard(
                    item: item,
                    isDark: isDark,
                    onQuantityChanged: (qty) => setState(() => item.quantity = qty),
                  )),
            ],
          ),
        ),
        const SizedBox(height: AlhaiSpacing.md),
        Row(children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () => _sendVia('whatsapp'),
              icon: const Icon(Icons.message),
              label: const Text('WhatsApp'),
              style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14)),
            ),
          ),
          const SizedBox(width: AlhaiSpacing.sm),
          Expanded(
            child: FilledButton.icon(
              onPressed: () => _sendVia('email'),
              icon: const Icon(Icons.email),
              label: Text(l10n.emailLabel),
              style: FilledButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14)),
            ),
          ),
        ]),
      ],
    );
  }

  double get _totalCost => _suggestions.fold(0.0, (sum, item) => sum + (item.price * item.quantity));

  Future<void> _calculateSuggestions() async {
    final budget = double.tryParse(_budgetController.text) ?? 0;
    if (budget <= 0) {
      final l10n = AppLocalizations.of(context);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.enterValidBudget)));
      return;
    }

    setState(() => _isCalculating = true);

    try {
      final db = GetIt.I<AppDatabase>();
      final storeId = ref.read(currentStoreIdProvider);
      if (storeId == null) {
        if (mounted) setState(() => _isCalculating = false);
        return;
      }

      final lowStockProducts = await db.productsDao.getLowStockProducts(storeId);

      if (mounted) {
        setState(() {
          _suggestions = lowStockProducts.map((p) {
            final deficit = p.minQty - p.stockQty;
            final reorderQty = deficit > 0 ? deficit : p.minQty;
            final costPrice = p.costPrice ?? p.price;
            return _ReorderItem(
              name: p.name,
              currentStock: p.stockQty,
              minStock: p.minQty,
              turnoverRate: deficit > 0 ? ((deficit / p.minQty) * 100).round() : 0,
              price: costPrice,
              quantity: reorderQty,
            );
          }).toList();

          _suggestions.sort((a, b) {
            final aRatio = a.minStock > 0 ? (a.minStock - a.currentStock) / a.minStock : 0.0;
            final bRatio = b.minStock > 0 ? (b.minStock - b.currentStock) / b.minStock : 0.0;
            return bRatio.compareTo(aRatio);
          });

          double runningTotal = 0;
          for (int i = 0; i < _suggestions.length; i++) {
            final itemCost = _suggestions[i].price * _suggestions[i].quantity;
            if (runningTotal + itemCost > budget) {
              final remaining = budget - runningTotal;
              final maxQty = (remaining / _suggestions[i].price).floorToDouble();
              if (maxQty > 0) {
                _suggestions[i].quantity = maxQty;
                runningTotal += _suggestions[i].price * maxQty;
              }
              _suggestions = _suggestions.sublist(0, i + (maxQty > 0 ? 1 : 0));
              break;
            }
            runningTotal += itemCost;
          }

          _isCalculating = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isCalculating = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
      }
    }
  }

  void _sendOrder() {
    final l10n = AppLocalizations.of(context);
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.confirmSendTitle),
        content: Text(l10n.sendOrderToMsg(_selectedSupplier ?? l10n.supplierLabel)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext), child: Text(l10n.cancel)),
          FilledButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(l10n.orderSentSuccessMsg), backgroundColor: AppColors.success),
              );
            },
            child: Text(l10n.sendOrder),
          ),
        ],
      ),
    );
  }

  void _sendVia(String method) {
    final l10n = AppLocalizations.of(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l10n.sendingOrderVia(method == 'whatsapp' ? 'WhatsApp' : l10n.emailLabel))),
    );
  }
}

class _ReorderItem {
  final String name;
  final double currentStock;
  final double minStock;
  final int turnoverRate;
  final double price;
  double quantity;

  _ReorderItem({required this.name, required this.currentStock, required this.minStock, required this.turnoverRate, required this.price, required this.quantity});
}

class _SummaryCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final bool isDark;

  const _SummaryCard({required this.title, required this.value, required this.icon, required this.color, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AlhaiSpacing.mdl),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Column(children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
          child: Icon(icon, color: color, size: 28),
        ),
        const SizedBox(height: AlhaiSpacing.sm),
        Text(title, style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.onSurfaceVariant)),
        const SizedBox(height: AlhaiSpacing.xxs),
        Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color)),
      ]),
    );
  }
}

class _ReorderItemCard extends StatelessWidget {
  final _ReorderItem item;
  final bool isDark;
  final ValueChanged<double> onQuantityChanged;

  const _ReorderItemCard({required this.item, required this.isDark, required this.onQuantityChanged});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Container(
      margin: const EdgeInsets.only(bottom: AlhaiSpacing.sm),
      padding: const EdgeInsets.all(AlhaiSpacing.md),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.name, style: TextStyle(fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface)),
                const SizedBox(height: AlhaiSpacing.xs),
                Row(children: [
                  _Tag(icon: Icons.inventory, label: l10n.stockLabelCount(item.currentStock.toInt()), color: item.currentStock < item.minStock ? AppColors.error : AppColors.textSecondary, isDark: isDark),
                  const SizedBox(width: AlhaiSpacing.xs),
                  _Tag(icon: Icons.trending_up, label: l10n.turnoverLabel(item.turnoverRate), color: AppColors.info, isDark: isDark),
                ]),
              ],
            ),
          ),
          Column(children: [
            Text('${item.price.toStringAsFixed(1)} ${l10n.sar}', style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.onSurfaceVariant)),
            const SizedBox(height: AlhaiSpacing.xxs),
            Row(children: [
              IconButton(
                icon: Icon(Icons.remove_circle_outline, color: Theme.of(context).colorScheme.onSurfaceVariant),
                onPressed: item.quantity > 0 ? () => onQuantityChanged(item.quantity - 1) : null,
              ),
              Text('${item.quantity.toInt()}', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Theme.of(context).colorScheme.onSurface)),
              IconButton(icon: const Icon(Icons.add_circle_outline, color: AppColors.primary), onPressed: () => onQuantityChanged(item.quantity + 1)),
            ]),
          ]),
        ],
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final bool isDark;

  const _Tag({required this.icon, required this.label, required this.color, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AlhaiSpacing.xs, vertical: AlhaiSpacing.xxs),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: AlhaiSpacing.xxs),
          Text(label, style: TextStyle(fontSize: 11, color: color)),
        ],
      ),
    );
  }
}
