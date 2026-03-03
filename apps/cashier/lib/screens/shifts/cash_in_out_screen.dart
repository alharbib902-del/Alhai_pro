/// Cash In/Out Screen - Cash movement form
///
/// Form: type (in/out), amount, reason, confirm button.
/// Supports: RTL Arabic, dark/light theme, responsive layout.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:alhai_shared_ui/alhai_shared_ui.dart';
import 'package:alhai_auth/alhai_auth.dart';
import 'package:alhai_l10n/alhai_l10n.dart';
import 'package:alhai_database/alhai_database.dart';
import '../../widgets/cash/denomination_counter_widget.dart';
// alhai_design_system is re-exported via alhai_shared_ui
import '../../core/services/sentry_service.dart';
import '../../core/services/audit_service.dart';

/// شاشة إيداع/سحب نقدي
class CashInOutScreen extends ConsumerStatefulWidget {
  const CashInOutScreen({super.key});

  @override
  ConsumerState<CashInOutScreen> createState() => _CashInOutScreenState();
}

class _CashInOutScreenState extends ConsumerState<CashInOutScreen> {
  final _amountController = TextEditingController();
  final _reasonController = TextEditingController();
  bool _isCashIn = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _amountController.dispose();
    _reasonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isWideScreen = size.width > 900;
    final isMediumScreen = size.width > 600;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context);
    final user = ref.watch(currentUserProvider);

    return Column(
      children: [
        AppHeader(
          title: l10n.cashMovement,
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
          child: ref.watch(openShiftProvider).when(
            data: (shift) {
              if (shift == null) {
                return _buildNoShiftMessage(isDark, l10n);
              }
              return SingleChildScrollView(
                padding: EdgeInsets.all(isMediumScreen ? 24 : 16),
                child: _buildContent(
                    shift, isWideScreen, isMediumScreen, isDark, l10n),
              );
            },
            loading: () => const AppLoadingState(),
            error: (e, _) => AppErrorState.general(
              message: '$e',
              onRetry: () => ref.invalidate(openShiftProvider),
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

  Widget _buildNoShiftMessage(bool isDark, AppLocalizations l10n) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.timer_off_rounded, size: 64,
              color: AppColors.getTextMuted(isDark)),
          const SizedBox(height: 16),
          Text(l10n.noOpenShift,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold,
                  color: AppColors.getTextSecondary(isDark))),
          const SizedBox(height: 8),
          Text(l10n.noOpenShiftCurrently,
              style: TextStyle(fontSize: 13,
                  color: AppColors.getTextMuted(isDark))),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: () => context.pop(),
            icon: const Icon(Icons.arrow_back_rounded),
            label: Text(l10n.goBack),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(
    ShiftsTableData shift,
    bool isWideScreen,
    bool isMediumScreen,
    bool isDark,
    AppLocalizations l10n,
  ) {
    if (isWideScreen) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 3,
            child: Column(
              children: [
                _buildTypeSelector(isDark, l10n),
                const SizedBox(height: 24),
                _buildAmountCard(isDark, l10n),
              ],
            ),
          ),
          const SizedBox(width: 24),
          Expanded(
            flex: 2,
            child: Column(
              children: [
                _buildReasonCard(isDark, l10n),
                const SizedBox(height: 24),
                _buildConfirmButton(shift, isDark, l10n),
              ],
            ),
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildTypeSelector(isDark, l10n),
        SizedBox(height: isMediumScreen ? 24 : 16),
        _buildAmountCard(isDark, l10n),
        SizedBox(height: isMediumScreen ? 24 : 16),
        _buildReasonCard(isDark, l10n),
        const SizedBox(height: 24),
        _buildConfirmButton(shift, isDark, l10n),
      ],
    );
  }

  Widget _buildTypeSelector(bool isDark, AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.getSurface(isDark),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.getBorder(isDark)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.info.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.swap_vert_rounded,
                    color: AppColors.info, size: 20),
              ),
              const SizedBox(width: 12),
              Text(l10n.movementType,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold,
                      color: AppColors.getTextPrimary(isDark))),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _buildTypeOption(
                  l10n.cashIn,
                  Icons.add_circle_rounded,
                  AppColors.success,
                  _isCashIn,
                  () => setState(() => _isCashIn = true),
                  isDark,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildTypeOption(
                  l10n.cashOut,
                  Icons.remove_circle_rounded,
                  AppColors.error,
                  !_isCashIn,
                  () => setState(() => _isCashIn = false),
                  isDark,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTypeOption(String label, IconData icon, Color color,
      bool isSelected, VoidCallback onTap, bool isDark) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: isSelected
              ? color.withValues(alpha: 0.1)
              : AppColors.getSurfaceVariant(isDark),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? color : AppColors.getBorder(isDark),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(icon,
                size: 32,
                color: isSelected
                    ? color
                    : AppColors.getTextSecondary(isDark)),
            const SizedBox(height: 10),
            Text(label,
                style: TextStyle(
                    fontSize: 14,
                    fontWeight:
                        isSelected ? FontWeight.w700 : FontWeight.w500,
                    color: isSelected
                        ? color
                        : AppColors.getTextSecondary(isDark))),
          ],
        ),
      ),
    );
  }

  Widget _buildAmountCard(bool isDark, AppLocalizations l10n) {
    final activeColor = _isCashIn ? AppColors.success : AppColors.error;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.getSurface(isDark),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.getBorder(isDark)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: activeColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(Icons.attach_money_rounded,
                    color: activeColor, size: 20),
              ),
              const SizedBox(width: 12),
              Text(l10n.amount,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold,
                      color: AppColors.getTextPrimary(isDark))),
            ],
          ),
          const SizedBox(height: 20),
          TextField(
            controller: _amountController,
            keyboardType: TextInputType.number,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: AppColors.getTextPrimary(isDark),
            ),
            onChanged: (_) => setState(() {}),
            decoration: InputDecoration(
              hintText: '0.00',
              hintStyle: TextStyle(
                color: AppColors.getTextMuted(isDark),
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
              suffixText: l10n.sar,
              suffixStyle: TextStyle(
                  fontSize: 16,
                  color: AppColors.getTextSecondary(isDark)),
              prefixIcon: Padding(
                padding: const EdgeInsets.all(12),
                child: Icon(
                  _isCashIn
                      ? Icons.add_rounded
                      : Icons.remove_rounded,
                  size: 28,
                  color: activeColor,
                ),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: AppColors.getBorder(isDark)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: AppColors.getBorder(isDark)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: activeColor, width: 2),
              ),
              filled: true,
              fillColor: AppColors.getSurfaceVariant(isDark),
            ),
          ),
          const SizedBox(height: 16),
          // زر عد العملات
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () async {
                final total = await showDenominationCounterSheet(
                  context,
                  initialTotal: double.tryParse(_amountController.text) ?? 0,
                );
                if (total != null && mounted) {
                  setState(() {
                    _amountController.text = total.toStringAsFixed(2);
                  });
                }
              },
              icon: const Icon(Icons.calculate_rounded, size: 18),
              label: const Text('عد العملات 🪙'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 10),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ),
          const SizedBox(height: 12),
          // Quick amount chips
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [50, 100, 200, 500].map((amount) {
              final isSelected =
                  _amountController.text == amount.toString();
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
                        horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? activeColor.withValues(alpha: 0.1)
                          : AppColors.getSurfaceVariant(isDark),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: isSelected
                            ? activeColor.withValues(alpha: 0.5)
                            : AppColors.getBorder(isDark),
                      ),
                    ),
                    child: Text('$amount ${l10n.sar}',
                        style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: isSelected
                                ? activeColor
                                : AppColors.getTextSecondary(isDark))),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildReasonCard(bool isDark, AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.getSurface(isDark),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.getBorder(isDark)),
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
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.note_alt_rounded,
                    color: AppColors.warning, size: 20),
              ),
              const SizedBox(width: 12),
              Text(l10n.noteLabel,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold,
                      color: AppColors.getTextPrimary(isDark))),
            ],
          ),
          const SizedBox(height: 20),
          TextField(
            controller: _reasonController,
            maxLines: 3,
            style: TextStyle(color: AppColors.getTextPrimary(isDark)),
            decoration: InputDecoration(
              hintText: l10n.reasonHint,
              hintStyle:
                  TextStyle(color: AppColors.getTextMuted(isDark)),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: AppColors.getBorder(isDark)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: AppColors.getBorder(isDark)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide:
                    const BorderSide(color: AppColors.primary, width: 2),
              ),
              filled: true,
              fillColor: AppColors.getSurfaceVariant(isDark),
              contentPadding: const EdgeInsets.all(16),
            ),
          ),
          const SizedBox(height: 12),
          // Quick reason chips
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildReasonChip(
                  _isCashIn ? l10n.bankDeposit : l10n.bankWithdrawal,
                  isDark),
              _buildReasonChip(l10n.expenses, isDark),
              _buildReasonChip(l10n.changeForDrawer, isDark),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildReasonChip(String reason, bool isDark) {
    final isSelected = _reasonController.text == reason;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          _reasonController.text = reason;
          setState(() {});
        },
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.primary.withValues(alpha: 0.1)
                : AppColors.getSurfaceVariant(isDark),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isSelected
                  ? AppColors.primary.withValues(alpha: 0.5)
                  : AppColors.getBorder(isDark),
            ),
          ),
          child: Text(reason,
              style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: isSelected
                      ? AppColors.primary
                      : AppColors.getTextSecondary(isDark))),
        ),
      ),
    );
  }

  Widget _buildConfirmButton(
      ShiftsTableData shift, bool isDark, AppLocalizations l10n) {
    final activeColor = _isCashIn ? AppColors.success : AppColors.error;
    final hasAmount = _amountController.text.isNotEmpty &&
        (double.tryParse(_amountController.text) ?? 0) > 0;

    return SizedBox(
      width: double.infinity,
      child: FilledButton.icon(
        onPressed: _isLoading || !hasAmount
            ? null
            : () => _submitMovement(shift, l10n),
        icon: _isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                    strokeWidth: 2, color: Colors.white),
              )
            : Icon(
                _isCashIn
                    ? Icons.add_circle_rounded
                    : Icons.remove_circle_rounded,
                size: 20),
        label: Text(
          _isCashIn ? l10n.confirmDeposit : l10n.confirmWithdrawal,
          style:
              const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        style: FilledButton.styleFrom(
          backgroundColor: activeColor,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }

  Future<void> _submitMovement(
      ShiftsTableData shift, AppLocalizations l10n) async {
    final amount = double.tryParse(_amountController.text);
    if (amount == null || amount <= 0) return;

    setState(() => _isLoading = true);

    try {
      final user = ref.read(currentUserProvider);
      final addMovement = ref.read(addCashMovementProvider);
      await addMovement(
        shiftId: shift.id,
        type: _isCashIn ? 'cash_in' : 'cash_out',
        amount: amount,
        reason: _reasonController.text.isNotEmpty
            ? _reasonController.text
            : null,
        createdBy: user?.name,
      );

      // Audit log
      final storeId = ref.read(currentStoreIdProvider)!;
      auditService.logCashDrawer(
        storeId: storeId,
        userId: user?.id ?? 'unknown',
        userName: user?.name ?? 'unknown',
        type: _isCashIn ? 'cash_in' : 'cash_out',
        amount: amount,
        reason: _reasonController.text.isNotEmpty ? _reasonController.text : null,
      );

      addBreadcrumb(
        message: _isCashIn ? 'Cash deposit' : 'Cash withdrawal',
        category: 'shift',
        data: {'amount': double.tryParse(_amountController.text)},
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              _isCashIn ? l10n.depositDone : l10n.withdrawalDone),
          backgroundColor: AppColors.success,
        ),
      );

      // Clear form
      _amountController.clear();
      _reasonController.clear();
      setState(() {});
    } catch (e, stack) {
      reportError(e, stackTrace: stack, hint: 'Save cash in/out');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.errorWithDetails('$e')),
          backgroundColor: AppColors.error,
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
}
