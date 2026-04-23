/// New Transaction Screen - Record debt or payment for a customer
///
/// Form: customer selector, amount, type (debt/payment), note.
/// Save creates a transaction record.
/// Supports: RTL Arabic, dark/light theme, responsive layout.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:get_it/get_it.dart';
import 'package:alhai_shared_ui/alhai_shared_ui.dart';
import 'package:alhai_l10n/alhai_l10n.dart';
import 'package:alhai_database/alhai_database.dart';
import 'package:alhai_auth/alhai_auth.dart';
import 'package:uuid/uuid.dart';
import 'package:alhai_design_system/alhai_design_system.dart'
    show AlhaiBreakpoints, AlhaiSnackbar, AlhaiSpacing;
// alhai_design_system is re-exported via alhai_shared_ui
import '../../core/services/sentry_service.dart';
import '../../core/services/audit_service.dart';

/// شاشة حركة حساب جديدة
class NewTransactionScreen extends ConsumerStatefulWidget {
  final String? customerId;

  const NewTransactionScreen({super.key, this.customerId});

  @override
  ConsumerState<NewTransactionScreen> createState() =>
      _NewTransactionScreenState();
}

class _NewTransactionScreenState extends ConsumerState<NewTransactionScreen> {
  final _db = GetIt.I<AppDatabase>();
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();
  final _customerSearchController = TextEditingController();

  bool _isDebt = true;
  bool _isLoading = false;
  bool _isSubmitting = false;
  String? _error;

  List<AccountsTableData> _allAccounts = [];
  List<AccountsTableData> _filteredAccounts = [];
  AccountsTableData? _selectedAccount;
  bool _showCustomerSearch = false;

  @override
  void initState() {
    super.initState();
    _loadAccounts();
    _customerSearchController.addListener(_filterAccounts);
  }

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    _customerSearchController.dispose();
    super.dispose();
  }

  Future<void> _loadAccounts() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final storeId = ref.read(currentStoreIdProvider);
      if (storeId == null) return;
      final accounts = await _db.accountsDao.getReceivableAccounts(storeId);
      if (mounted) {
        setState(() {
          _allAccounts = accounts;
          _filteredAccounts = accounts;
          _isLoading = false;
        });

        // If customerId is passed, pre-select the account
        if (widget.customerId != null) {
          final match = accounts
              .where((a) => a.customerId == widget.customerId)
              .toList();
          if (match.isNotEmpty) {
            setState(() => _selectedAccount = match.first);
          }
        }
      }
    } catch (e, stack) {
      reportError(e, stackTrace: stack, hint: 'Load customer accounts');
      if (mounted) {
        setState(() {
          _isLoading = false;
          _error = '$e';
        });
      }
    }
  }

  void _filterAccounts() {
    final query = _customerSearchController.text.toLowerCase().trim();
    setState(() {
      if (query.isEmpty) {
        _filteredAccounts = _allAccounts;
      } else {
        _filteredAccounts = _allAccounts.where((a) {
          return a.name.toLowerCase().contains(query) ||
              (a.phone?.toLowerCase().contains(query) ?? false);
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isWideScreen = size.width >= AlhaiBreakpoints.desktop;
    final isMediumScreen = size.width >= AlhaiBreakpoints.tablet;
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context);
    final user = ref.watch(currentUserProvider);

    return Column(
      children: [
        AppHeader(
          title: 'New Transaction',
          subtitle: _getDateSubtitle(l10n),
          showSearch: false,
          searchHint: l10n.searchPlaceholder,
          onMenuTap: isWideScreen
              ? null
              : () => Scaffold.of(context).openDrawer(),
          onNotificationsTap: () => context.push('/notifications'),
          notificationsCount: 3,
          userName: user?.name ?? l10n.cashCustomer,
          userRole: l10n.branchManager,
          onUserTap: () {},
        ),
        Expanded(
          child: _isLoading
              ? const AppLoadingState()
              : _error != null
              ? AppErrorState.general(
                  context,
                  message: _error!,
                  onRetry: _loadAccounts,
                )
              : SingleChildScrollView(
                  padding: EdgeInsets.all(
                    isMediumScreen ? AlhaiSpacing.lg : AlhaiSpacing.md,
                  ),
                  child: isWideScreen
                      ? Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              flex: 3,
                              child: Column(
                                children: [
                                  _buildCustomerCard(colorScheme, l10n),
                                  const SizedBox(height: AlhaiSpacing.lg),
                                  _buildTypeCard(colorScheme, l10n),
                                ],
                              ),
                            ),
                            const SizedBox(width: AlhaiSpacing.lg),
                            Expanded(
                              flex: 2,
                              child: Column(
                                children: [
                                  _buildAmountCard(colorScheme, l10n),
                                  const SizedBox(height: AlhaiSpacing.lg),
                                  _buildNoteCard(colorScheme, l10n),
                                  const SizedBox(height: AlhaiSpacing.lg),
                                  _buildSubmitButton(colorScheme, l10n),
                                ],
                              ),
                            ),
                          ],
                        )
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            _buildCustomerCard(colorScheme, l10n),
                            SizedBox(
                              height: isMediumScreen
                                  ? AlhaiSpacing.lg
                                  : AlhaiSpacing.md,
                            ),
                            _buildTypeCard(colorScheme, l10n),
                            SizedBox(
                              height: isMediumScreen
                                  ? AlhaiSpacing.lg
                                  : AlhaiSpacing.md,
                            ),
                            _buildAmountCard(colorScheme, l10n),
                            SizedBox(
                              height: isMediumScreen
                                  ? AlhaiSpacing.lg
                                  : AlhaiSpacing.md,
                            ),
                            _buildNoteCard(colorScheme, l10n),
                            const SizedBox(height: AlhaiSpacing.lg),
                            _buildSubmitButton(colorScheme, l10n),
                            const SizedBox(height: AlhaiSpacing.lg),
                          ],
                        ),
                ),
        ),
      ],
    );
  }

  String _getDateSubtitle(AppLocalizations l10n) {
    final now = DateTime.now();
    return '${now.day}/${now.month}/${now.year} \u2022 ${l10n.mainBranch}';
  }

  Widget _buildCustomerCard(ColorScheme colorScheme, AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(AlhaiSpacing.mdl),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AlhaiSpacing.xs),
                decoration: BoxDecoration(
                  color: AppColors.info.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.person_rounded,
                  color: AppColors.info,
                  size: 20,
                ),
              ),
              const SizedBox(width: AlhaiSpacing.sm),
              Text(
                l10n.customerName,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: AlhaiSpacing.md),
          if (_selectedAccount != null && !_showCustomerSearch)
            _buildSelectedCustomer(colorScheme, l10n)
          else
            _buildCustomerSelector(colorScheme, l10n),
        ],
      ),
    );
  }

  Widget _buildSelectedCustomer(
    ColorScheme colorScheme,
    AppLocalizations l10n,
  ) {
    final account = _selectedAccount!;
    final isDebt = account.balance > 0;
    final initials = _getInitials(account.name);

    return InkWell(
      onTap: () => setState(() => _showCustomerSearch = true),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(
            alpha: Theme.of(context).brightness == Brightness.dark
                ? 0.12
                : 0.06,
          ),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppColors.primary.withValues(alpha: 0.4),
            width: 2,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                gradient: AppColors.avatarGradient,
                borderRadius: BorderRadius.circular(10),
              ),
              alignment: Alignment.center,
              child: Text(
                initials,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: colorScheme.onPrimary,
                ),
              ),
            ),
            const SizedBox(width: AlhaiSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    account.name,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  if (account.phone != null)
                    Directionality(
                      textDirection: TextDirection.ltr,
                      child: Text(
                        account.phone!,
                        style: TextStyle(
                          fontSize: 12,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${account.balance.abs().toStringAsFixed(0)} ${l10n.sar}',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: isDebt ? AppColors.error : AppColors.success,
                  ),
                ),
                Text(
                  isDebt ? l10n.dueOnCustomer : l10n.customerHasCredit,
                  style: TextStyle(fontSize: 10, color: colorScheme.outline),
                ),
              ],
            ),
            const SizedBox(width: AlhaiSpacing.xs),
            const Icon(Icons.edit_rounded, size: 18, color: AppColors.primary),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomerSelector(
    ColorScheme colorScheme,
    AppLocalizations l10n,
  ) {
    return Column(
      children: [
        TextField(
          controller: _customerSearchController,
          style: TextStyle(color: colorScheme.onSurface),
          decoration: InputDecoration(
            hintText: l10n.searchPlaceholder,
            hintStyle: TextStyle(color: colorScheme.outline),
            prefixIcon: Icon(Icons.search_rounded, color: colorScheme.outline),
            filled: true,
            fillColor: colorScheme.surfaceContainerHighest,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: colorScheme.outlineVariant),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: colorScheme.outlineVariant),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.primary, width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: AlhaiSpacing.md,
              vertical: 14,
            ),
          ),
        ),
        const SizedBox(height: AlhaiSpacing.sm),
        ConstrainedBox(
          constraints: const BoxConstraints(maxHeight: 200),
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: _filteredAccounts.length,
            itemBuilder: (context, index) {
              final account = _filteredAccounts[index];
              return InkWell(
                onTap: () {
                  setState(() {
                    _selectedAccount = account;
                    _showCustomerSearch = false;
                    _customerSearchController.clear();
                  });
                },
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AlhaiSpacing.sm,
                    vertical: 10,
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.person_outline_rounded,
                        size: 18,
                        color: colorScheme.outline,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          account.name,
                          style: TextStyle(
                            fontSize: 14,
                            color: colorScheme.onSurface,
                          ),
                        ),
                      ),
                      Text(
                        // C-4 Session 4: accounts.balance is int cents.
                        '${(account.balance / 100.0).toStringAsFixed(0)} ${l10n.sar}',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: account.balance > 0
                              ? AppColors.error
                              : AppColors.success,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildTypeCard(ColorScheme colorScheme, AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(AlhaiSpacing.mdl),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AlhaiSpacing.xs),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.swap_vert_rounded,
                  color: AppColors.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: AlhaiSpacing.sm),
              Text(
                l10n.type,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: AlhaiSpacing.mdl),
          Row(
            children: [
              Expanded(
                child: _buildTypeOption(
                  l10n.debitAdjustment,
                  Icons.arrow_upward_rounded,
                  AppColors.error,
                  _isDebt,
                  () => setState(() => _isDebt = true),
                  colorScheme,
                ),
              ),
              const SizedBox(width: AlhaiSpacing.sm),
              Expanded(
                child: _buildTypeOption(
                  l10n.payment,
                  Icons.arrow_downward_rounded,
                  AppColors.success,
                  !_isDebt,
                  () => setState(() => _isDebt = false),
                  colorScheme,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTypeOption(
    String label,
    IconData icon,
    Color color,
    bool isSelected,
    VoidCallback onTap,
    ColorScheme colorScheme,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: AlhaiSpacing.mdl),
        decoration: BoxDecoration(
          color: isSelected
              ? color.withValues(alpha: 0.1)
              : colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? color : colorScheme.outlineVariant,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 32,
              color: isSelected ? color : colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 10),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? color : colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAmountCard(ColorScheme colorScheme, AppLocalizations l10n) {
    final activeColor = _isDebt ? AppColors.error : AppColors.success;

    return Container(
      padding: const EdgeInsets.all(AlhaiSpacing.mdl),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AlhaiSpacing.xs),
                decoration: BoxDecoration(
                  color: activeColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.attach_money_rounded,
                  color: activeColor,
                  size: 20,
                ),
              ),
              const SizedBox(width: AlhaiSpacing.sm),
              Text(
                l10n.amount,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: AlhaiSpacing.mdl),
          TextField(
            controller: _amountController,
            keyboardType: TextInputType.number,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
            onChanged: (_) => setState(() {}),
            decoration: InputDecoration(
              hintText: '0.00',
              hintStyle: TextStyle(
                color: colorScheme.outline,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
              suffixText: l10n.sar,
              suffixStyle: TextStyle(
                fontSize: 16,
                color: colorScheme.onSurfaceVariant,
              ),
              prefixIcon: Padding(
                padding: const EdgeInsets.all(AlhaiSpacing.sm),
                child: Icon(
                  _isDebt ? Icons.add_rounded : Icons.remove_rounded,
                  size: 28,
                  color: activeColor,
                ),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: colorScheme.outlineVariant),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: colorScheme.outlineVariant),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: activeColor, width: 2),
              ),
              filled: true,
              fillColor: colorScheme.surfaceContainerHighest,
            ),
          ),
          const SizedBox(height: AlhaiSpacing.sm),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [50, 100, 200, 500].map((amount) {
              final isSelected = _amountController.text == amount.toString();
              return Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    _amountController.text = amount.toString();
                    setState(() {});
                  },
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AlhaiSpacing.md,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? activeColor.withValues(alpha: 0.1)
                          : colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: isSelected
                            ? activeColor.withValues(alpha: 0.5)
                            : colorScheme.outlineVariant,
                      ),
                    ),
                    child: Text(
                      '$amount ${l10n.sar}',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: isSelected
                            ? activeColor
                            : colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildNoteCard(ColorScheme colorScheme, AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(AlhaiSpacing.mdl),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AlhaiSpacing.xs),
                decoration: BoxDecoration(
                  color: AppColors.warning.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.note_alt_rounded,
                  color: AppColors.warning,
                  size: 20,
                ),
              ),
              const SizedBox(width: AlhaiSpacing.sm),
              Text(
                l10n.noteLabel,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: AlhaiSpacing.md),
          TextField(
            controller: _noteController,
            maxLines: 3,
            style: TextStyle(color: colorScheme.onSurface),
            decoration: InputDecoration(
              hintText: l10n.reasonHint,
              hintStyle: TextStyle(color: colorScheme.outline),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: colorScheme.outlineVariant),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: colorScheme.outlineVariant),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: AppColors.primary,
                  width: 2,
                ),
              ),
              filled: true,
              fillColor: colorScheme.surfaceContainerHighest,
              contentPadding: const EdgeInsets.all(AlhaiSpacing.md),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubmitButton(ColorScheme colorScheme, AppLocalizations l10n) {
    final activeColor = _isDebt ? AppColors.error : AppColors.success;
    final hasAmount =
        _amountController.text.isNotEmpty &&
        (double.tryParse(_amountController.text) ?? 0) > 0;

    return SizedBox(
      width: double.infinity,
      child: FilledButton.icon(
        onPressed: _isSubmitting || !hasAmount || _selectedAccount == null
            ? null
            : () => _submitTransaction(l10n),
        icon: _isSubmitting
            ? SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: colorScheme.onPrimary,
                ),
              )
            : Icon(
                _isDebt
                    ? Icons.arrow_upward_rounded
                    : Icons.arrow_downward_rounded,
                size: 20,
              ),
        label: Text(
          _isDebt ? 'Record Debt' : 'Record Payment',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        style: FilledButton.styleFrom(
          backgroundColor: activeColor,
          foregroundColor: colorScheme.onPrimary,
          padding: const EdgeInsets.symmetric(vertical: AlhaiSpacing.md),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  Future<void> _submitTransaction(AppLocalizations l10n) async {
    final amount = double.tryParse(_amountController.text);
    if (amount == null || amount <= 0 || _selectedAccount == null) return;

    setState(() => _isSubmitting = true);

    try {
      final account = _selectedAccount!;
      final signedAmount = _isDebt ? amount : -amount;
      // C-4 Session 4: accounts.balance, transactions.amount, balance_after are int cents.
      final currentBalSar = account.balance / 100.0;
      final newBalance = currentBalSar + signedAmount;
      final storeId = ref.read(currentStoreIdProvider);
      if (storeId == null) return;
      final user = ref.read(currentUserProvider);
      final txnId = const Uuid().v4();

      await _db.transaction(() async {
        await _db.transactionsDao.insertTransaction(
          TransactionsTableCompanion.insert(
            id: txnId,
            storeId: storeId,
            accountId: account.id,
            type: _isDebt ? 'invoice' : 'payment',
            amount: (signedAmount * 100).round(),
            balanceAfter: (newBalance * 100).round(),
            description: Value(
              _noteController.text.isEmpty ? null : _noteController.text,
            ),
            createdBy: Value(user?.name),
            createdAt: DateTime.now(),
          ),
        );
        await _db.accountsDao.updateBalance(account.id, newBalance);
      });

      // Audit log
      auditService.logTransaction(
        storeId: storeId,
        userId: user?.id ?? 'unknown',
        userName: user?.name ?? 'unknown',
        transactionId: txnId,
        accountName: account.name,
        type: _isDebt ? 'invoice' : 'payment',
        amount: signedAmount,
        balanceAfter: newBalance,
      );

      addBreadcrumb(
        message: _isDebt ? 'Debt recorded' : 'Payment recorded',
        category: 'payment',
        data: {'amount': signedAmount, 'accountId': account.id},
      );

      if (!mounted) return;
      AlhaiSnackbar.success(
        context,
        AppLocalizations.of(context).transactionRecordedSuccess,
      );

      // Reset form
      _amountController.clear();
      _noteController.clear();
      await _loadAccounts();
    } catch (e, stack) {
      reportError(e, stackTrace: stack, hint: 'Save new transaction');
      if (!mounted) return;
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          icon: const Icon(
            Icons.error_outline,
            color: AppColors.error,
            size: 48,
          ),
          title: Text(l10n.error),
          content: Text(l10n.errorWithDetails('$e')),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(l10n.close),
            ),
          ],
        ),
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  String _getInitials(String name) {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.isNotEmpty ? name[0].toUpperCase() : '?';
  }
}
