/// مكون البحث عن عميل - Customer Search Dialog
///
/// نافذة للبحث واختيار عميل في POS
library;

import 'package:pos_app/widgets/common/adaptive_icon.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_sizes.dart';
import '../../core/theme/app_typography.dart';
import '../../core/validators/input_sanitizer.dart';
import '../../l10n/generated/app_localizations.dart';

/// نافذة البحث عن عميل
class CustomerSearchDialog extends StatefulWidget {
  final Function(CustomerSearchResult) onSelect;
  final VoidCallback? onAddNew;

  const CustomerSearchDialog({
    super.key,
    required this.onSelect,
    this.onAddNew,
  });

  /// عرض النافذة
  static Future<CustomerSearchResult?> show(BuildContext context) {
    return showModalBottomSheet<CustomerSearchResult>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => CustomerSearchDialog(
        onSelect: (customer) => Navigator.pop(context, customer),
        onAddNew: () {
          Navigator.pop(context);
          // TODO: Navigate to add customer
        },
      ),
    );
  }

  @override
  State<CustomerSearchDialog> createState() => _CustomerSearchDialogState();
}

class _CustomerSearchDialogState extends State<CustomerSearchDialog> {
  final _searchController = TextEditingController();
  final _focusNode = FocusNode();

  // قائمة العملاء (بيانات تجريبية)
  final List<CustomerSearchResult> _allCustomers = [
    CustomerSearchResult(
      id: '1',
      name: 'أحمد محمد العلي',
      phone: '0501234567',
      balance: -250.00,
      loyaltyPoints: 1250,
      tier: 'gold',
    ),
    CustomerSearchResult(
      id: '2',
      name: 'سارة عبدالله الأحمد',
      phone: '0559876543',
      balance: 500.00,
      loyaltyPoints: 800,
      tier: 'silver',
    ),
    CustomerSearchResult(
      id: '3',
      name: 'محمد خالد السعيد',
      phone: '0541112222',
      balance: 0.00,
      loyaltyPoints: 2500,
      tier: 'diamond',
    ),
    CustomerSearchResult(
      id: '4',
      name: 'فاطمة علي الحربي',
      phone: '0563334444',
      balance: -1200.00,
      loyaltyPoints: 350,
      tier: 'bronze',
    ),
    CustomerSearchResult(
      id: '5',
      name: 'عمر حسين النجار',
      phone: '0525556666',
      balance: 150.00,
      loyaltyPoints: 600,
      tier: 'silver',
    ),
  ];

  List<CustomerSearchResult> _filteredCustomers = [];

  @override
  void initState() {
    super.initState();
    _filteredCustomers = _allCustomers;
    _searchController.addListener(_filterCustomers);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _filterCustomers() {
    final sanitized = InputSanitizer.sanitize(_searchController.text);
    if (sanitized != _searchController.text) {
      _searchController.text = sanitized;
      _searchController.selection = TextSelection.fromPosition(
        TextPosition(offset: sanitized.length),
      );
      return; // listener will re-fire after text update
    }
    final query = sanitized.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _filteredCustomers = _allCustomers;
      } else {
        _filteredCustomers = _allCustomers.where((customer) {
          return customer.name.toLowerCase().contains(query) ||
              customer.phone.contains(query);
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(AppSizes.radiusXl),
        ),
      ),
      child: Column(
        children: [
          // Handle
          Padding(
            padding: const EdgeInsets.all(AppSizes.md),
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.grey300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSizes.lg),
            child: Row(
              children: [
                const Text(
                  'اختيار عميل',
                  style: AppTypography.headlineSmall,
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
          ),

          // Search
          Padding(
            padding: const EdgeInsets.all(AppSizes.lg),
            child: TextField(
              controller: _searchController,
              focusNode: _focusNode,
              maxLength: 100,
              decoration: InputDecoration(
                counterText: '',
                hintText: 'البحث بالاسم أو رقم الهاتف...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                        },
                      )
                    : null,
                filled: true,
                fillColor: AppColors.grey100,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          // Walk-in Customer Option
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSizes.lg),
            child: Card(
              color: AppColors.grey100,
              child: ListTile(
                leading: const CircleAvatar(
                  backgroundColor: AppColors.grey300,
                  child: Icon(Icons.person_outline, color: AppColors.textMuted),
                ),
                title: const Text('عميل عابر'),
                subtitle: const Text('متابعة بدون تحديد عميل'),
                trailing: const AdaptiveIcon(Icons.arrow_forward_ios, size: 16),
                onTap: () {
                  widget.onSelect(CustomerSearchResult(
                    id: 'walk-in',
                    name: 'عميل عابر',
                    phone: '',
                    balance: 0,
                    loyaltyPoints: 0,
                    tier: null,
                  ));
                },
              ),
            ),
          ),

          const Divider(height: AppSizes.xl),

          // Results
          Expanded(
            child: _filteredCustomers.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: AppSizes.lg),
                    itemCount: _filteredCustomers.length,
                    itemBuilder: (context, index) {
                      return _buildCustomerCard(_filteredCustomers[index]);
                    },
                  ),
          ),

          // Add New Customer
          if (widget.onAddNew != null)
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(AppSizes.lg),
                child: OutlinedButton.icon(
                  onPressed: widget.onAddNew,
                  icon: const Icon(Icons.person_add),
                  label: const Text('إضافة عميل جديد'),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size.fromHeight(48),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  String _localizedTier(AppLocalizations l10n, String? tier) {
    switch (tier) {
      case 'gold':
        return l10n.gold;
      case 'silver':
        return l10n.silver;
      case 'diamond':
        return l10n.diamond;
      case 'bronze':
        return l10n.bronze;
      default:
        return tier ?? '';
    }
  }

  Widget _buildCustomerCard(CustomerSearchResult customer) {
    final hasDebt = customer.balance < 0;
    final hasCredit = customer.balance > 0;
    final l10n = AppLocalizations.of(context)!;

    return Card(
      margin: const EdgeInsets.only(bottom: AppSizes.sm),
      child: InkWell(
        onTap: () {
          HapticFeedback.selectionClick();
          widget.onSelect(customer);
        },
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.md),
          child: Row(
            children: [
              // Avatar
              CircleAvatar(
                backgroundColor: _getTierColor(customer.tier).withValues(alpha: 0.1),
                child: Text(
                  customer.name[0],
                  style: TextStyle(
                    color: _getTierColor(customer.tier),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: AppSizes.md),

              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          customer.name,
                          style: AppTypography.titleSmall.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        if (customer.tier != null) ...[
                          const SizedBox(width: AppSizes.xs),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: _getTierColor(customer.tier),
                              borderRadius:
                                  BorderRadius.circular(AppSizes.radiusSm),
                            ),
                            child: Text(
                              _localizedTier(l10n, customer.tier),
                              style: AppTypography.labelSmall.copyWith(
                                color: Colors.white,
                                fontSize: 10,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        const Icon(
                          Icons.phone_outlined,
                          size: 14,
                          color: AppColors.textMuted,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          customer.phone,
                          style: AppTypography.bodySmall.copyWith(
                            color: AppColors.textMuted,
                          ),
                        ),
                        const SizedBox(width: AppSizes.md),
                        const Icon(
                          Icons.stars,
                          size: 14,
                          color: AppColors.warning,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${customer.loyaltyPoints} نقطة',
                          style: AppTypography.bodySmall.copyWith(
                            color: AppColors.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Balance
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    l10n.balanceLabel,
                    style: AppTypography.labelSmall.copyWith(
                      color: AppColors.textMuted,
                    ),
                  ),
                  Text(
                    '${customer.balance.abs().toStringAsFixed(2)} ر.س',
                    style: AppTypography.titleSmall.copyWith(
                      color: hasDebt
                          ? AppColors.error
                          : (hasCredit ? AppColors.success : AppColors.textSecondary),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (hasDebt)
                    Text(
                      l10n.debtor,
                      style: AppTypography.labelSmall.copyWith(
                        color: AppColors.error,
                      ),
                    ),
                  if (hasCredit)
                    Text(
                      l10n.creditor,
                      style: AppTypography.labelSmall.copyWith(
                        color: AppColors.success,
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.search_off,
            size: 64,
            color: AppColors.grey400,
          ),
          const SizedBox(height: AppSizes.md),
          Text(
            'لا توجد نتائج',
            style: AppTypography.titleMedium.copyWith(
              color: AppColors.textMuted,
            ),
          ),
          const SizedBox(height: AppSizes.xs),
          Text(
            'جرب البحث بكلمة أخرى',
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.textMuted,
            ),
          ),
        ],
      ),
    );
  }

  Color _getTierColor(String? tier) {
    switch (tier) {
      case 'diamond':
        return Colors.purple;
      case 'gold':
        return AppColors.warning;
      case 'silver':
        return AppColors.grey500;
      case 'bronze':
        return Colors.brown;
      default:
        return AppColors.grey400;
    }
  }
}

/// نموذج نتيجة البحث عن عميل
class CustomerSearchResult {
  final String id;
  final String name;
  final String phone;
  final double balance;
  final int loyaltyPoints;
  final String? tier;

  CustomerSearchResult({
    required this.id,
    required this.name,
    required this.phone,
    required this.balance,
    required this.loyaltyPoints,
    this.tier,
  });

  bool get isWalkIn => id == 'walk-in';
}
