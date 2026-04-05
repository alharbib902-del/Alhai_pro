/// مكون البحث عن عميل - Customer Search Dialog
///
/// نافذة للبحث واختيار عميل في POS
library;

import 'package:alhai_shared_ui/alhai_shared_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:alhai_l10n/alhai_l10n.dart';
import 'package:alhai_database/alhai_database.dart';
import 'package:get_it/get_it.dart';
import 'package:alhai_design_system/alhai_design_system.dart';

/// نافذة البحث عن عميل
class CustomerSearchDialog extends StatefulWidget {
  final Function(CustomerSearchResult) onSelect;
  final VoidCallback? onAddNew;
  final String storeId;

  const CustomerSearchDialog({
    super.key,
    required this.onSelect,
    required this.storeId,
    this.onAddNew,
  });

  /// عرض النافذة
  static Future<CustomerSearchResult?> show(BuildContext context,
      {required String storeId}) {
    return showModalBottomSheet<CustomerSearchResult>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => CustomerSearchDialog(
        storeId: storeId,
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
  late final CustomersDao _customersDao;

  List<CustomerSearchResult> _allCustomers = [];
  List<CustomerSearchResult> _filteredCustomers = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _customersDao = GetIt.I<AppDatabase>().customersDao;
    _searchController.addListener(_filterCustomers);
    _loadCustomers();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  /// تحميل العملاء من قاعدة البيانات
  Future<void> _loadCustomers() async {
    try {
      final customers = await _customersDao.getActiveCustomers(widget.storeId);
      if (!mounted) return;
      setState(() {
        _allCustomers = customers
            .map((c) => CustomerSearchResult(
                  id: c.id,
                  name: c.name,
                  phone: c.phone ?? '',
                  balance: 0, // سيتم تحديثه لاحقاً من حساب العميل
                  loyaltyPoints: 0,
                  tier: null,
                ))
            .toList();
        _filteredCustomers = _allCustomers;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
    }
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
    if (query.isEmpty) {
      setState(() => _filteredCustomers = _allCustomers);
    } else {
      // بحث من قاعدة البيانات مباشرة
      _customersDao.searchCustomers(query, widget.storeId).then((results) {
        if (!mounted) return;
        setState(() {
          _filteredCustomers = results
              .map((c) => CustomerSearchResult(
                    id: c.id,
                    name: c.name,
                    phone: c.phone ?? '',
                    balance: 0,
                    loyaltyPoints: 0,
                    tier: null,
                  ))
              .toList();
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
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
                color: colorScheme.outlineVariant,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSizes.lg),
            child: Row(
              children: [
                Text(
                  AppLocalizations.of(context).selectCustomerTitle,
                  style: AppTypography.headlineSmall,
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                  tooltip: AppLocalizations.of(context).close,
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
                hintText: AppLocalizations.of(context).searchByNameOrPhoneHint,
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                        },
                        tooltip: AppLocalizations.of(context).clearField,
                      )
                    : null,
                filled: true,
                fillColor: colorScheme.surfaceContainerLow,
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
              color: colorScheme.surfaceContainerLow,
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: colorScheme.outlineVariant,
                  child: const Icon(Icons.person_outline,
                      color: AppColors.textMuted),
                ),
                title: Text(AppLocalizations.of(context).walkInCustomerLabel),
                subtitle:
                    Text(AppLocalizations.of(context).continueWithoutCustomer),
                trailing: const AdaptiveIcon(Icons.arrow_forward_ios, size: 16),
                onTap: () {
                  widget.onSelect(CustomerSearchResult(
                    id: 'walk-in',
                    name: AppLocalizations.of(context).walkInCustomerLabel,
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
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredCustomers.isEmpty
                    ? _buildEmptyState()
                    : ListView.builder(
                        padding:
                            const EdgeInsets.symmetric(horizontal: AppSizes.lg),
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
                  label:
                      Text(AppLocalizations.of(context).addNewCustomerButton),
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
    final l10n = AppLocalizations.of(context);

    return Semantics(
      label: '${customer.name}, ${customer.phone}',
      button: true,
      child: Card(
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
                  backgroundColor:
                      _getTierColor(customer.tier).withValues(alpha: 0.1),
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
                                  color: AppColors.textOnPrimary,
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
                          const SizedBox(width: AlhaiSpacing.xxs),
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
                          const SizedBox(width: AlhaiSpacing.xxs),
                          Text(
                            AppLocalizations.of(context)
                                .loyaltyPointsCountLabel(
                                    customer.loyaltyPoints.toString()),
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
                      AppLocalizations.of(context).customerBalanceAmount(
                          customer.balance.abs().toStringAsFixed(2)),
                      style: AppTypography.titleSmall.copyWith(
                        color: hasDebt
                            ? AppColors.error
                            : (hasCredit
                                ? AppColors.success
                                : AppColors.textSecondary),
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
      ),
    );
  }

  Widget _buildEmptyState() {
    final colorScheme = Theme.of(context).colorScheme;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off,
            size: 64,
            color: colorScheme.onSurfaceVariant,
          ),
          const SizedBox(height: AppSizes.md),
          Text(
            AppLocalizations.of(context).noResultsFoundTitle,
            style: AppTypography.titleMedium.copyWith(
              color: AppColors.textMuted,
            ),
          ),
          const SizedBox(height: AppSizes.xs),
          Text(
            AppLocalizations.of(context).tryAnotherSearch,
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.textMuted,
            ),
          ),
        ],
      ),
    );
  }

  Color _getTierColor(String? tier) {
    final colorScheme = Theme.of(context).colorScheme;
    switch (tier) {
      case 'diamond':
        return Colors.purple;
      case 'gold':
        return AppColors.warning;
      case 'silver':
        return colorScheme.outline;
      case 'bronze':
        return Colors.brown;
      default:
        return colorScheme.onSurfaceVariant;
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
