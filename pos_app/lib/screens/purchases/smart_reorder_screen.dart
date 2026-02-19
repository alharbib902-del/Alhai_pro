import 'package:pos_app/widgets/common/adaptive_icon.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../data/local/app_database.dart';
import '../../di/injection.dart';
import '../../providers/products_providers.dart';
import '../../widgets/layout/app_header.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../core/theme/app_colors.dart';

/// شاشة الطلب الذكي من الموردين - مدعومة بالذكاء الاصطناعي
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
      final db = getIt<AppDatabase>();
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
    final l10n = AppLocalizations.of(context)!;

    return Column(
              children: [
                AppHeader(
                  title: '\u0627\u0644\u0637\u0644\u0628 \u0627\u0644\u0630\u0643\u064A', // TODO: localize
                  onMenuTap: isWideScreen
                      ? null
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
            );
  }
  Widget _buildContent(
      bool isWideScreen, bool isMediumScreen, bool isDark, AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Back button row
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
                '\u0627\u0644\u0637\u0644\u0628 \u0627\u0644\u0630\u0643\u064A', // TODO: localize
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : AppColors.textPrimary,
                ),
              ),
            ),
            if (_suggestions.isNotEmpty)
              FilledButton.icon(
                onPressed: _sendOrder,
                icon: const AdaptiveIcon(Icons.send, size: 18),
                label: const Text('\u0625\u0631\u0633\u0627\u0644 \u0627\u0644\u0637\u0644\u0628'), // TODO: localize
              ),
          ],
        ),
        const SizedBox(height: 24),

        // AI Header Card
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isDark
                  ? [const Color(0xFF581C87), const Color(0xFF4C1D95)]
                  : [const Color(0xFFF3E8FF), const Color(0xFFEDE9FE)],
              begin: AlignmentDirectional.topStart,
              end: AlignmentDirectional.bottomEnd,
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDark
                  ? Colors.purple.withValues(alpha: 0.3)
                  : const Color(0xFFD8B4FE),
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.purple.withValues(alpha: 0.3)
                      : Colors.purple.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.psychology,
                    color: isDark ? Colors.purple.shade200 : Colors.purple,
                    size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '\u0627\u0644\u0637\u0644\u0628 \u0627\u0644\u0630\u0643\u064A \u0628\u0627\u0644\u0640 AI', // TODO: localize
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: isDark ? Colors.white : Colors.purple.shade900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '\u062D\u062F\u062F \u0627\u0644\u0645\u064A\u0632\u0627\u0646\u064A\u0629 \u0648\u0633\u064A\u0642\u0648\u0645 \u0627\u0644\u0646\u0638\u0627\u0645 \u0628\u062A\u0648\u0632\u064A\u0639\u0647\u0627 \u0639\u0644\u0649 \u0627\u0644\u0645\u0646\u062A\u062C\u0627\u062A \u062D\u0633\u0628 \u0645\u0639\u062F\u0644 \u0627\u0644\u062F\u0648\u0631\u0627\u0646', // TODO: localize
                      style: TextStyle(
                        fontSize: 13,
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.7)
                            : Colors.purple.shade700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // Form section
        if (isWideScreen)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 1,
                child: _buildFormSection(isDark),
              ),
              const SizedBox(width: 24),
              Expanded(
                flex: 2,
                child: _buildResultsSection(isDark),
              ),
            ],
          )
        else
          Column(
            children: [
              _buildFormSection(isDark),
              const SizedBox(height: 24),
              _buildResultsSection(isDark),
            ],
          ),
      ],
    );
  }

  Widget _buildFormSection(bool isDark) {
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
                child: const Icon(Icons.tune_rounded,
                    color: AppColors.primary, size: 20),
              ),
              const SizedBox(width: 12),
              Text(
                '\u0625\u0639\u062F\u0627\u062F\u0627\u062A \u0627\u0644\u0637\u0644\u0628', // TODO: localize
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          TextField(
            controller: _budgetController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: '\u0627\u0644\u0645\u064A\u0632\u0627\u0646\u064A\u0629 \u0627\u0644\u0645\u062A\u0627\u062D\u0629', // TODO: localize
              suffixText: '\u0631.\u0633',
              prefixIcon: const Icon(Icons.account_balance_wallet),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              helperText: '\u0623\u062F\u062E\u0644 \u0627\u0644\u0645\u0628\u0644\u063A \u0627\u0644\u0645\u062A\u0627\u062D \u0644\u0644\u0634\u0631\u0627\u0621', // TODO: localize
            ),
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            initialValue: _selectedSupplier,
            decoration: InputDecoration(
              labelText: '\u0627\u0644\u0645\u0648\u0631\u062F', // TODO: localize
              prefixIcon: const Icon(Icons.storefront),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            items: _isLoadingSuppliers
                ? []
                : _suppliersList
                    .map((s) => DropdownMenuItem(value: s.name, child: Text(s.name)))
                    .toList(),
            onChanged: (v) => setState(() => _selectedSupplier = v),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: _isCalculating ? null : _calculateSuggestions,
              icon: _isCalculating
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.auto_awesome),
              label: Text(_isCalculating
                  ? '\u062C\u0627\u0631\u064A \u0627\u0644\u062D\u0633\u0627\u0628...'
                  : '\u062D\u0633\u0627\u0628 \u0627\u0644\u062A\u0648\u0632\u064A\u0639 \u0627\u0644\u0630\u0643\u064A'), // TODO: localize
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultsSection(bool isDark) {
    if (_suggestions.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(48),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E293B) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark
                ? Colors.white.withValues(alpha: 0.1)
                : AppColors.border,
          ),
        ),
        child: Center(
          child: Column(
            children: [
              Icon(Icons.auto_awesome_outlined,
                  size: 64,
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.2)
                      : AppColors.textTertiary),
              const SizedBox(height: 16),
              Text(
                '\u062D\u062F\u062F \u0627\u0644\u0645\u064A\u0632\u0627\u0646\u064A\u0629 \u0648\u0627\u0636\u063A\u0637 \u062D\u0633\u0627\u0628', // TODO: localize
                style: TextStyle(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.5)
                      : AppColors.textTertiary,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      children: [
        // Summary Cards
        Row(
          children: [
            Expanded(
              child: _SummaryCard(
                title: '\u0639\u062F\u062F \u0627\u0644\u0645\u0646\u062A\u062C\u0627\u062A', // TODO: localize
                value: '${_suggestions.length}',
                icon: Icons.inventory_2,
                color: AppColors.info,
                isDark: isDark,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _SummaryCard(
                title: '\u0627\u0644\u0625\u062C\u0645\u0627\u0644\u064A', // TODO: localize
                value: '${_totalCost.toStringAsFixed(0)} \u0631.\u0633',
                icon: Icons.payments,
                color: AppColors.success,
                isDark: isDark,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Items list
        Container(
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
              Text(
                '\u0627\u0644\u0645\u0646\u062A\u062C\u0627\u062A \u0627\u0644\u0645\u0642\u062A\u0631\u062D\u0629', // TODO: localize
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 16),
              ..._suggestions.map((item) => _ReorderItemCard(
                    item: item,
                    isDark: isDark,
                    onQuantityChanged: (qty) {
                      setState(() => item.quantity = qty);
                    },
                  )),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Send Options
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _sendVia('whatsapp'),
                icon: const Icon(Icons.message),
                label: const Text('WhatsApp'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: FilledButton.icon(
                onPressed: () => _sendVia('email'),
                icon: const Icon(Icons.email),
                label: const Text('\u0627\u0644\u0628\u0631\u064A\u062F'), // TODO: localize
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  double get _totalCost => _suggestions.fold(
        0.0,
        (sum, item) => sum + (item.price * item.quantity),
      );

  Future<void> _calculateSuggestions() async {
    final budget = double.tryParse(_budgetController.text) ?? 0;
    if (budget <= 0) {
      final messenger = ScaffoldMessenger.of(context);
      messenger.showSnackBar(
        const SnackBar(
            content:
                Text('\u0627\u0644\u0631\u062C\u0627\u0621 \u0625\u062F\u062E\u0627\u0644 \u0645\u064A\u0632\u0627\u0646\u064A\u0629 \u0635\u062D\u064A\u062D\u0629')),
      );
      return;
    }

    setState(() => _isCalculating = true);

    try {
      final db = getIt<AppDatabase>();
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

          // Sort by deficit ratio (highest need first)
          _suggestions.sort((a, b) {
            final aRatio = a.minStock > 0 ? (a.minStock - a.currentStock) / a.minStock : 0.0;
            final bRatio = b.minStock > 0 ? (b.minStock - b.currentStock) / b.minStock : 0.0;
            return bRatio.compareTo(aRatio);
          });

          // Cap total cost to budget
          double runningTotal = 0;
          for (int i = 0; i < _suggestions.length; i++) {
            final itemCost = _suggestions[i].price * _suggestions[i].quantity;
            if (runningTotal + itemCost > budget) {
              final remaining = budget - runningTotal;
              final maxQty = (remaining / _suggestions[i].price).floor();
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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    }
  }

  void _sendOrder() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('\u062A\u0623\u0643\u064A\u062F \u0627\u0644\u0625\u0631\u0633\u0627\u0644'),
        content: Text(
            '\u0625\u0631\u0633\u0627\u0644 \u0627\u0644\u0637\u0644\u0628 \u0625\u0644\u0649 ${_selectedSupplier ?? '\u0627\u0644\u0645\u0648\u0631\u062F'}\u061F'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('\u0625\u0644\u063A\u0627\u0621'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('\u062A\u0645 \u0625\u0631\u0633\u0627\u0644 \u0627\u0644\u0637\u0644\u0628 \u0628\u0646\u062C\u0627\u062D'),
                  backgroundColor: AppColors.success,
                ),
              );
            },
            child: const Text('\u0625\u0631\u0633\u0627\u0644'),
          ),
        ],
      ),
    );
  }

  void _sendVia(String method) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
            '\u062C\u0627\u0631\u064A \u0625\u0631\u0633\u0627\u0644 \u0627\u0644\u0637\u0644\u0628 \u0639\u0628\u0631 ${method == 'whatsapp' ? 'WhatsApp' : '\u0627\u0644\u0628\u0631\u064A\u062F'}...'),
      ),
    );
  }
}

// Models
class _ReorderItem {
  final String name;
  final int currentStock;
  final int minStock;
  final int turnoverRate;
  final double price;
  int quantity;

  _ReorderItem({
    required this.name,
    required this.currentStock,
    required this.minStock,
    required this.turnoverRate,
    required this.price,
    required this.quantity,
  });
}

class _SummaryCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final bool isDark;

  const _SummaryCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
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
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: isDark
                  ? Colors.white.withValues(alpha: 0.6)
                  : AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _ReorderItemCard extends StatelessWidget {
  final _ReorderItem item;
  final bool isDark;
  final ValueChanged<int> onQuantityChanged;

  const _ReorderItemCard({
    required this.item,
    required this.isDark,
    required this.onQuantityChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.05)
            : AppColors.backgroundSecondary,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.05)
              : AppColors.border,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _Tag(
                      icon: Icons.inventory,
                      label:
                          '\u0627\u0644\u0645\u062E\u0632\u0648\u0646: ${item.currentStock}', // TODO: localize
                      color: item.currentStock < item.minStock
                          ? AppColors.error
                          : AppColors.textSecondary,
                      isDark: isDark,
                    ),
                    const SizedBox(width: 8),
                    _Tag(
                      icon: Icons.trending_up,
                      label:
                          '\u0627\u0644\u062F\u0648\u0631\u0627\u0646: ${item.turnoverRate}%', // TODO: localize
                      color: AppColors.info,
                      isDark: isDark,
                    ),
                  ],
                ),
              ],
            ),
          ),
          Column(
            children: [
              Text(
                '${item.price.toStringAsFixed(1)} \u0631.\u0633',
                style: TextStyle(
                  fontSize: 12,
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.6)
                      : AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.remove_circle_outline,
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.6)
                            : AppColors.textSecondary),
                    onPressed: item.quantity > 0
                        ? () => onQuantityChanged(item.quantity - 1)
                        : null,
                  ),
                  Text(
                    '${item.quantity}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: isDark ? Colors.white : AppColors.textPrimary,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add_circle_outline,
                        color: AppColors.primary),
                    onPressed: () => onQuantityChanged(item.quantity + 1),
                  ),
                ],
              ),
            ],
          ),
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

  const _Tag({
    required this.icon,
    required this.label,
    required this.color,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(label, style: TextStyle(fontSize: 11, color: color)),
        ],
      ),
    );
  }
}
