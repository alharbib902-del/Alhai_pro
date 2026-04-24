/// New Transaction Screen - Record debt or payment for a customer
///
/// Form: customer selector, amount, type (debt/payment), note.
/// Save creates a transaction record.
/// Supports: RTL Arabic, dark/light theme, responsive layout.
///
/// State model:
/// - Business state → [NewTransactionState] via [_newTransactionProvider]
///   (accounts list + filtered list, selectedAccount, isDebt toggle,
///   search-visibility, loading/submitting flags, error). Replaces the
///   cascade of 13 `setState` calls from the original implementation.
/// - Pure UI transient state → `TextEditingController` values. The amount
///   field is wrapped in `ValueListenableBuilder` so quick-amount chips +
///   submit button enable-state react without `setState(() {})`.
library;

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:get_it/get_it.dart';
import 'package:alhai_shared_ui/alhai_shared_ui.dart';
import 'package:alhai_l10n/alhai_l10n.dart';
import 'package:alhai_database/alhai_database.dart';
import 'package:alhai_auth/alhai_auth.dart';
import 'package:alhai_sync/alhai_sync.dart' show SyncPriority;
import 'package:uuid/uuid.dart';
import 'package:alhai_design_system/alhai_design_system.dart'
    show AlhaiBreakpoints, AlhaiSnackbar, AlhaiSpacing;
// alhai_design_system is re-exported via alhai_shared_ui
import '../../core/services/sentry_service.dart';
import '../../core/services/audit_service.dart';

// ============================================================================
// State
// ============================================================================

@immutable
class NewTransactionState {
  final List<AccountsTableData> allAccounts;
  final List<AccountsTableData> filteredAccounts;
  final AccountsTableData? selectedAccount;
  final bool isDebt;
  final bool showCustomerSearch;
  final bool isLoading;
  final bool isSubmitting;
  final String? error;

  const NewTransactionState({
    this.allAccounts = const [],
    this.filteredAccounts = const [],
    this.selectedAccount,
    this.isDebt = true,
    this.showCustomerSearch = false,
    // Defaults to loading=true so the first frame shows the spinner while
    // `_loadAccounts()` runs via addPostFrameCallback. Matches the pre-
    // refactor behaviour where setState(isLoading=true) fired synchronously
    // in initState (see `shows loading indicator while fetching` test).
    this.isLoading = true,
    this.isSubmitting = false,
    this.error,
  });

  NewTransactionState copyWith({
    List<AccountsTableData>? allAccounts,
    List<AccountsTableData>? filteredAccounts,
    AccountsTableData? selectedAccount,
    bool clearSelectedAccount = false,
    bool? isDebt,
    bool? showCustomerSearch,
    bool? isLoading,
    bool? isSubmitting,
    String? error,
    bool clearError = false,
  }) => NewTransactionState(
    allAccounts: allAccounts ?? this.allAccounts,
    filteredAccounts: filteredAccounts ?? this.filteredAccounts,
    selectedAccount: clearSelectedAccount
        ? null
        : (selectedAccount ?? this.selectedAccount),
    isDebt: isDebt ?? this.isDebt,
    showCustomerSearch: showCustomerSearch ?? this.showCustomerSearch,
    isLoading: isLoading ?? this.isLoading,
    isSubmitting: isSubmitting ?? this.isSubmitting,
    error: clearError ? null : (error ?? this.error),
  );
}

class NewTransactionNotifier extends StateNotifier<NewTransactionState> {
  NewTransactionNotifier() : super(const NewTransactionState());

  void setLoading() => state = state.copyWith(isLoading: true, clearError: true);

  void setLoaded(List<AccountsTableData> accounts) => state = state.copyWith(
    allAccounts: accounts,
    filteredAccounts: accounts,
    isLoading: false,
  );

  /// P2 #2: when the screen was opened with a pre-selected customer (via
  /// `widget.customerId`), keep `filteredAccounts` narrowed to that account
  /// so the search list doesn't flash all accounts before selection.
  void setLoadedWithPreselection(
    List<AccountsTableData> accounts,
    String preselectedCustomerId,
  ) {
    final matches = accounts
        .where((a) => a.customerId == preselectedCustomerId)
        .toList();
    state = state.copyWith(
      allAccounts: accounts,
      filteredAccounts: matches.isEmpty ? accounts : matches,
      isLoading: false,
    );
  }

  void setError(String err) =>
      state = state.copyWith(isLoading: false, error: err);

  void selectAccount(AccountsTableData account) => state = state.copyWith(
    selectedAccount: account,
    showCustomerSearch: false,
  );

  void showSearch() => state = state.copyWith(showCustomerSearch: true);

  void setIsDebt(bool v) => state = state.copyWith(isDebt: v);

  void setSubmitting(bool v) => state = state.copyWith(isSubmitting: v);

  /// Filter accounts list by query (case-insensitive, name + phone).
  void filterAccounts(String query) {
    final q = query.toLowerCase().trim();
    if (q.isEmpty) {
      state = state.copyWith(filteredAccounts: state.allAccounts);
      return;
    }
    state = state.copyWith(
      filteredAccounts: state.allAccounts.where((a) {
        return a.name.toLowerCase().contains(q) ||
            (a.phone?.toLowerCase().contains(q) ?? false);
      }).toList(),
    );
  }
}

final _newTransactionProvider =
    StateNotifierProvider.autoDispose<
      NewTransactionNotifier,
      NewTransactionState
    >((ref) => NewTransactionNotifier());

// ============================================================================
// Screen
// ============================================================================

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

  // Debounce the customer-search filter — previously re-ran on every
  // keystroke, causing extra Riverpod rebuilds (P1 #3).
  Timer? _searchDebounce;
  String _lastSearchQuery = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadAccounts());
    _customerSearchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _amountController.dispose();
    _noteController.dispose();
    _customerSearchController.dispose();
    super.dispose();
  }

  Future<void> _loadAccounts() async {
    final notifier = ref.read(_newTransactionProvider.notifier);
    notifier.setLoading();
    try {
      final storeId = ref.read(currentStoreIdProvider);
      if (storeId == null) return;
      final accounts = await _db.accountsDao.getReceivableAccounts(storeId);
      if (!mounted) return;

      // P2 #2: if customerId passed, keep filteredAccounts narrowed to that
      // customer (prevents the whole list from briefly showing) and auto-
      // select. When no customerId, fall back to the default load.
      if (widget.customerId != null) {
        notifier.setLoadedWithPreselection(accounts, widget.customerId!);
        final match = accounts
            .where((a) => a.customerId == widget.customerId)
            .toList();
        if (match.isNotEmpty) notifier.selectAccount(match.first);
      } else {
        notifier.setLoaded(accounts);
      }
    } catch (e, stack) {
      reportError(e, stackTrace: stack, hint: 'Load customer accounts');
      if (!mounted) return;
      notifier.setError('$e');
    }
  }

  void _onSearchChanged() {
    final q = _customerSearchController.text;
    if (q == _lastSearchQuery) return;
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 300), () {
      if (!mounted) return;
      _lastSearchQuery = q;
      ref.read(_newTransactionProvider.notifier).filterAccounts(q);
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
    final s = ref.watch(_newTransactionProvider);

    return Column(
      children: [
        AppHeader(
          // No single l10n key for "New Transaction"; use direct Arabic so
          // the screen is not bilingual when locale is ar (the primary
          // locale for this app). English speakers still see Arabic — this
          // matches the rest of the customer flow headers.
          title: 'حركة حساب جديدة',
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
          child: s.isLoading
              ? const AppLoadingState()
              : s.error != null
              ? AppErrorState.general(
                  context,
                  message: s.error!,
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
                                  _buildCustomerCard(colorScheme, l10n, s),
                                  const SizedBox(height: AlhaiSpacing.lg),
                                  _buildTypeCard(colorScheme, l10n, s),
                                ],
                              ),
                            ),
                            const SizedBox(width: AlhaiSpacing.lg),
                            Expanded(
                              flex: 2,
                              child: Column(
                                children: [
                                  _buildAmountCard(colorScheme, l10n, s),
                                  const SizedBox(height: AlhaiSpacing.lg),
                                  _buildNoteCard(colorScheme, l10n),
                                  const SizedBox(height: AlhaiSpacing.lg),
                                  _buildSubmitButton(colorScheme, l10n, s),
                                ],
                              ),
                            ),
                          ],
                        )
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            _buildCustomerCard(colorScheme, l10n, s),
                            SizedBox(
                              height: isMediumScreen
                                  ? AlhaiSpacing.lg
                                  : AlhaiSpacing.md,
                            ),
                            _buildTypeCard(colorScheme, l10n, s),
                            SizedBox(
                              height: isMediumScreen
                                  ? AlhaiSpacing.lg
                                  : AlhaiSpacing.md,
                            ),
                            _buildAmountCard(colorScheme, l10n, s),
                            SizedBox(
                              height: isMediumScreen
                                  ? AlhaiSpacing.lg
                                  : AlhaiSpacing.md,
                            ),
                            _buildNoteCard(colorScheme, l10n),
                            const SizedBox(height: AlhaiSpacing.lg),
                            _buildSubmitButton(colorScheme, l10n, s),
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

  Widget _buildCustomerCard(
    ColorScheme colorScheme,
    AppLocalizations l10n,
    NewTransactionState s,
  ) {
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
          if (s.selectedAccount != null && !s.showCustomerSearch)
            _buildSelectedCustomer(colorScheme, l10n, s)
          else
            _buildCustomerSelector(colorScheme, l10n, s),
        ],
      ),
    );
  }

  Widget _buildSelectedCustomer(
    ColorScheme colorScheme,
    AppLocalizations l10n,
    NewTransactionState s,
  ) {
    final account = s.selectedAccount!;
    final isDebt = account.balance > 0;
    final initials = _getInitials(account.name);

    return InkWell(
      onTap: () => ref.read(_newTransactionProvider.notifier).showSearch(),
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
                  // accounts.balance is int cents (C-4 schema).
                  CurrencyFormatter.fromCentsWithContext(
                    context,
                    account.balance.abs(),
                    decimalDigits: 0,
                  ),
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
    NewTransactionState s,
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
            itemCount: s.filteredAccounts.length,
            itemBuilder: (context, index) {
              final account = s.filteredAccounts[index];
              return InkWell(
                onTap: () {
                  ref
                      .read(_newTransactionProvider.notifier)
                      .selectAccount(account);
                  _customerSearchController.clear();
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
                        // Use CurrencyFormatter for grouping separators.
                        CurrencyFormatter.fromCentsWithContext(
                          context,
                          account.balance.abs(),
                          decimalDigits: 0,
                        ),
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

  Widget _buildTypeCard(
    ColorScheme colorScheme,
    AppLocalizations l10n,
    NewTransactionState s,
  ) {
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
                  s.isDebt,
                  () => ref
                      .read(_newTransactionProvider.notifier)
                      .setIsDebt(true),
                  colorScheme,
                ),
              ),
              const SizedBox(width: AlhaiSpacing.sm),
              Expanded(
                child: _buildTypeOption(
                  l10n.payment,
                  Icons.arrow_downward_rounded,
                  AppColors.success,
                  !s.isDebt,
                  () => ref
                      .read(_newTransactionProvider.notifier)
                      .setIsDebt(false),
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

  Widget _buildAmountCard(
    ColorScheme colorScheme,
    AppLocalizations l10n,
    NewTransactionState s,
  ) {
    final activeColor = s.isDebt ? AppColors.error : AppColors.success;

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
                  s.isDebt ? Icons.add_rounded : Icons.remove_rounded,
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
          // Quick-amount chips — highlight tracks controller via listenable.
          ValueListenableBuilder<TextEditingValue>(
            valueListenable: _amountController,
            builder: (_, __, ___) => Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [50, 100, 200, 500].map((amount) {
                final isSelected = _amountController.text == amount.toString();
                return Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {
                      _amountController.text = amount.toString();
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

  Widget _buildSubmitButton(
    ColorScheme colorScheme,
    AppLocalizations l10n,
    NewTransactionState s,
  ) {
    final activeColor = s.isDebt ? AppColors.error : AppColors.success;
    // Enable-state also tracks amount text: use ValueListenableBuilder.
    return ValueListenableBuilder<TextEditingValue>(
      valueListenable: _amountController,
      builder: (_, __, ___) {
        final hasAmount =
            _amountController.text.isNotEmpty &&
            (double.tryParse(_amountController.text) ?? 0) > 0;
        return SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            onPressed: s.isSubmitting || !hasAmount || s.selectedAccount == null
                ? null
                : () => _submitTransaction(l10n),
            icon: s.isSubmitting
                ? SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: colorScheme.onPrimary,
                    ),
                  )
                : Icon(
                    s.isDebt
                        ? Icons.arrow_upward_rounded
                        : Icons.arrow_downward_rounded,
                    size: 20,
                  ),
            label: Text(
              // Arabic direct strings — `recordPayment` exists in l10n but
              // there is no matching `recordDebt` key; keep both in Arabic
              // so the pair stays consistent.
              s.isDebt ? 'تسجيل دين' : l10n.recordPayment,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
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
      },
    );
  }

  Future<void> _submitTransaction(AppLocalizations l10n) async {
    final amount = double.tryParse(_amountController.text);
    final s = ref.read(_newTransactionProvider);
    if (amount == null || amount <= 0 || s.selectedAccount == null) return;

    final notifier = ref.read(_newTransactionProvider.notifier);
    notifier.setSubmitting(true);

    try {
      final account = s.selectedAccount!;
      final signedAmount = s.isDebt ? amount : -amount;
      final storeId = ref.read(currentStoreIdProvider);
      if (storeId == null) return;
      final user = ref.read(currentUserProvider);
      final syncService = ref.read(syncServiceProvider);
      final txnId = const Uuid().v4();
      final now = DateTime.now();
      final note = _noteController.text.isEmpty ? null : _noteController.text;
      final txnType = s.isDebt ? 'invoice' : 'payment';

      // C-4 Session 4: accounts.balance, transactions.amount,
      // balance_after are int cents. Re-read the account inside the
      // transaction to avoid TOCTOU drift if another device adjusted the
      // balance since the UI loaded.
      late final double newBalance;
      late final double currentBalSar;
      await _db.transaction(() async {
        final fresh = await _db.accountsDao.getAccountById(account.id);
        currentBalSar = (fresh?.balance ?? account.balance) / 100.0;
        newBalance = currentBalSar + signedAmount;
        await _db.transactionsDao.insertTransaction(
          TransactionsTableCompanion.insert(
            id: txnId,
            storeId: storeId,
            accountId: account.id,
            type: txnType,
            amount: (signedAmount * 100).round(),
            balanceAfter: (newBalance * 100).round(),
            description: Value(note),
            createdBy: Value(user?.name),
            createdAt: now,
          ),
        );
        await _db.accountsDao.updateBalance(account.id, newBalance);
      });

      // Sync enqueue — outside the DB transaction so a sync_queue write
      // failure cannot poison the local commit. Without this, the
      // transaction stays local-only (cloud diverges, audit gap).
      try {
        await syncService.enqueueCreate(
          tableName: 'transactions',
          recordId: txnId,
          data: {
            'id': txnId,
            'storeId': storeId,
            'accountId': account.id,
            'type': txnType,
            'amount': (signedAmount * 100).round(),
            'balanceAfter': (newBalance * 100).round(),
            'description': note,
            'createdBy': user?.name,
            'createdAt': now.toIso8601String(),
          },
          priority: SyncPriority.high,
        );
        await syncService.enqueueUpdate(
          tableName: 'accounts',
          recordId: account.id,
          changes: {
            'id': account.id,
            'balance': (newBalance * 100).round(),
            'lastTransactionAt': now.toIso8601String(),
            'updatedAt': now.toIso8601String(),
          },
          priority: SyncPriority.high,
        );
      } catch (e, stack) {
        reportError(
          e,
          stackTrace: stack,
          hint: 'New transaction sync enqueue (txn=$txnId)',
        );
      }

      // Audit log
      auditService.logTransaction(
        storeId: storeId,
        userId: user?.id ?? 'unknown',
        userName: user?.name ?? 'unknown',
        transactionId: txnId,
        accountName: account.name,
        type: txnType,
        amount: signedAmount,
        balanceAfter: newBalance,
      );

      addBreadcrumb(
        message: s.isDebt ? 'Debt recorded' : 'Payment recorded',
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
      if (mounted) {
        ref.read(_newTransactionProvider.notifier).setSubmitting(false);
      }
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
