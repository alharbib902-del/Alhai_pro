/// Coupon Code Screen - Apply coupon codes at POS
///
/// Text input for coupon code, scan barcode button, validate/apply buttons,
/// recent coupons used list.
/// Supports: RTL Arabic, dark/light theme, responsive layout.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:get_it/get_it.dart';
import 'package:alhai_shared_ui/alhai_shared_ui.dart';
import 'package:alhai_auth/alhai_auth.dart';
import 'package:alhai_l10n/alhai_l10n.dart';
import 'package:alhai_database/alhai_database.dart';
import 'package:alhai_design_system/alhai_design_system.dart' show AlhaiBreakpoints, AlhaiSpacing;
// alhai_design_system is re-exported via alhai_shared_ui
import '../../core/services/sentry_service.dart';

/// شاشة كود الكوبون
class CouponCodeScreen extends ConsumerStatefulWidget {
  const CouponCodeScreen({super.key});

  @override
  ConsumerState<CouponCodeScreen> createState() => _CouponCodeScreenState();
}

class _CouponCodeScreenState extends ConsumerState<CouponCodeScreen> {
  final _db = GetIt.I<AppDatabase>();
  final _codeController = TextEditingController();

  bool _isValidating = false;
  bool _isValidated = false;
  String? _validationError;
  Map<String, dynamic>? _discountDetails;

  // Recent coupons loaded from validated history (empty by default)
  final List<Map<String, dynamic>> _recentCoupons = [];

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isWideScreen = size.width >= AlhaiBreakpoints.desktop;
    final isMediumScreen = size.width >= AlhaiBreakpoints.tablet;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context);
    final user = ref.watch(currentUserProvider);

    return Column(
      children: [
        AppHeader(
          title: l10n.couponCode,
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
          child: SingleChildScrollView(
            padding: EdgeInsets.all(isMediumScreen ? AlhaiSpacing.lg : AlhaiSpacing.md),
            child: _buildContent(isWideScreen, isMediumScreen, isDark, l10n),
          ),
        ),
      ],
    );
  }

  String _getDateSubtitle(AppLocalizations l10n) {
    final now = DateTime.now();
    return '${now.day}/${now.month}/${now.year} \u2022 ${l10n.mainBranch}';
  }

  Widget _buildContent(
      bool isWideScreen, bool isMediumScreen, bool isDark, AppLocalizations l10n) {
    if (isWideScreen) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 3,
            child: Column(
              children: [
                _buildCodeInputCard(isDark, l10n),
                const SizedBox(height: AlhaiSpacing.lg),
                if (_isValidated && _discountDetails != null)
                  _buildDiscountDetailsCard(isDark, l10n),
                if (_validationError != null)
                  _buildErrorCard(isDark, l10n),
              ],
            ),
          ),
          const SizedBox(width: AlhaiSpacing.lg),
          Expanded(
            flex: 2,
            child: _buildRecentCouponsCard(isDark, l10n),
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildCodeInputCard(isDark, l10n),
        SizedBox(height: isMediumScreen ? AlhaiSpacing.lg : AlhaiSpacing.md),
        if (_isValidated && _discountDetails != null)
          ...[_buildDiscountDetailsCard(isDark, l10n), SizedBox(height: isMediumScreen ? AlhaiSpacing.lg : AlhaiSpacing.md)],
        if (_validationError != null)
          ...[_buildErrorCard(isDark, l10n), SizedBox(height: isMediumScreen ? AlhaiSpacing.lg : AlhaiSpacing.md)],
        _buildRecentCouponsCard(isDark, l10n),
      ],
    );
  }

  Widget _buildCodeInputCard(bool isDark, AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(AlhaiSpacing.mdl),
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
                padding: const EdgeInsets.all(AlhaiSpacing.xs),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.confirmation_number_rounded,
                    color: AppColors.primary, size: 20),
              ),
              const SizedBox(width: AlhaiSpacing.sm),
              Text(l10n.enterCouponCode,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold,
                      color: AppColors.getTextPrimary(isDark))),
            ],
          ),
          const SizedBox(height: AlhaiSpacing.mdl),
          // Code input
          TextField(
            controller: _codeController,
            textCapitalization: TextCapitalization.characters,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: AppColors.getTextPrimary(isDark),
              letterSpacing: 3,
              fontFamily: 'monospace',
            ),
            textAlign: TextAlign.center,
            onChanged: (_) => setState(() {
              _isValidated = false;
              _validationError = null;
              _discountDetails = null;
            }),
            decoration: InputDecoration(
              hintText: 'XXXXXXXX',
              hintStyle: TextStyle(
                color: AppColors.getTextMuted(isDark),
                fontSize: 22,
                fontWeight: FontWeight.bold,
                letterSpacing: 3,
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
                borderSide: const BorderSide(color: AppColors.primary, width: 2),
              ),
              filled: true,
              fillColor: AppColors.getSurfaceVariant(isDark),
              contentPadding: const EdgeInsets.symmetric(horizontal: AlhaiSpacing.md, vertical: 18),
            ),
          ),
          const SizedBox(height: AlhaiSpacing.md),
          // Scan button
          SizedBox(
            width:double.infinity,
            child: OutlinedButton.icon(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(l10n.scanBarcode),
                      backgroundColor: AppColors.info),
                );
              },
              icon: const Icon(Icons.qr_code_scanner_rounded, size: 18),
              label: Text(l10n.scanCouponBarcode),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.info,
                side: BorderSide(color: AppColors.info.withValues(alpha: 0.5)),
                padding: const EdgeInsets.symmetric(vertical: AlhaiSpacing.sm),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
          const SizedBox(height: AlhaiSpacing.mdl),
          // Action buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _codeController.text.isEmpty || _isValidating
                      ? null
                      : _validateCoupon,
                  icon: _isValidating
                      ? const SizedBox(width: 18, height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2))
                      : const Icon(Icons.check_circle_outlined, size: 18),
                  label: Text(l10n.validateCoupon),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.getTextSecondary(isDark),
                    side: BorderSide(color: AppColors.getBorder(isDark)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
              const SizedBox(width: AlhaiSpacing.sm),
              Expanded(
                child: FilledButton.icon(
                  onPressed: _isValidated && _discountDetails != null
                      ? _applyCoupon
                      : null,
                  icon: const Icon(Icons.add_shopping_cart_rounded, size: 18),
                  label: Text(l10n.apply),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.success,
                    foregroundColor: AppColors.textOnPrimary,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDiscountDetailsCard(bool isDark, AppLocalizations l10n) {
    final details = _discountDetails!;
    return Container(
      padding: const EdgeInsets.all(AlhaiSpacing.mdl),
      decoration: BoxDecoration(
        color: AppColors.success.withValues(alpha: isDark ? 0.1 : 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.success.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.check_circle_rounded, color: AppColors.success, size: 24),
              const SizedBox(width: AlhaiSpacing.sm),
              Text(l10n.couponValid,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700,
                      color: AppColors.getTextPrimary(isDark))),
            ],
          ),
          const SizedBox(height: AlhaiSpacing.md),
          _buildDetailRow(l10n.discountType, details['type'] as String, isDark),
          _buildDetailRow(l10n.discountValue, details['value'] as String, isDark),
          _buildDetailRow('Valid Until', details['validUntil'] as String, isDark),
          if (details['minPurchase'] != null)
            _buildDetailRow('Minimum Purchase', details['minPurchase'] as String, isDark),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AlhaiSpacing.xxs),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: TextStyle(fontSize: 13,
                  color: AppColors.getTextSecondary(isDark))),
          Text(value,
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600,
                  color: AppColors.getTextPrimary(isDark))),
        ],
      ),
    );
  }

  Widget _buildErrorCard(bool isDark, AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(AlhaiSpacing.mdl),
      decoration: BoxDecoration(
        color: AppColors.error.withValues(alpha: isDark ? 0.1 : 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline_rounded, color: AppColors.error, size: 24),
          const SizedBox(width: AlhaiSpacing.sm),
          Expanded(
            child: Text(
              _validationError!,
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500,
                  color: AppColors.getTextPrimary(isDark)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentCouponsCard(bool isDark, AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(AlhaiSpacing.mdl),
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
                padding: const EdgeInsets.all(AlhaiSpacing.xs),
                decoration: BoxDecoration(
                  color: AppColors.warning.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.history_rounded,
                    color: AppColors.warning, size: 20),
              ),
              const SizedBox(width: AlhaiSpacing.sm),
              Text(l10n.recentCoupons,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold,
                      color: AppColors.getTextPrimary(isDark))),
            ],
          ),
          const SizedBox(height: AlhaiSpacing.md),
          if (_recentCoupons.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(AlhaiSpacing.md),
                child: Text(l10n.noRecentCoupons,
                    style: TextStyle(fontSize: 13,
                        color: AppColors.getTextMuted(isDark))),
              ),
            )
          else
            ..._recentCoupons.map((coupon) {
              final date = coupon['date'] as DateTime;
              return InkWell(
                onTap: () {
                  _codeController.text = coupon['code'] as String;
                  setState(() {
                    _isValidated = false;
                    _validationError = null;
                    _discountDetails = null;
                  });
                },
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  margin: const EdgeInsets.only(bottom: AlhaiSpacing.xs),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.getSurfaceVariant(isDark),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 36, height: 36,
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        alignment: Alignment.center,
                        child: const Icon(Icons.confirmation_number_outlined,
                            color: AppColors.primary, size: 18),
                      ),
                      const SizedBox(width: AlhaiSpacing.sm),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(coupon['code'] as String,
                                style: TextStyle(fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.getTextPrimary(isDark),
                                    fontFamily: 'monospace')),
                            Text(
                              '${date.day}/${date.month}/${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}',
                              style: TextStyle(fontSize: 11,
                                  color: AppColors.getTextMuted(isDark)),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: AlhaiSpacing.xs, vertical: AlhaiSpacing.xxs),
                        decoration: BoxDecoration(
                          color: AppColors.success.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(coupon['discount'] as String,
                            style: const TextStyle(fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: AppColors.success)),
                      ),
                    ],
                  ),
                ),
              );
            }),
        ],
      ),
    );
  }

  Future<void> _validateCoupon() async {
    final code = _codeController.text.trim().toUpperCase();
    if (code.isEmpty) return;

    setState(() {
      _isValidating = true;
      _validationError = null;
      _discountDetails = null;
      _isValidated = false;
    });

    try {
      final storeId = ref.read(currentStoreIdProvider);
      if (storeId == null) throw Exception('No store');

      // Try to find discount by code
      final discounts = await _db.discountsDao.getActiveDiscounts(storeId);
      final match = discounts.where((d) =>
          d.name.toUpperCase() == code).toList();

      if (match.isNotEmpty) {
        final discount = match.first;
        if (mounted) {
          setState(() {
            _isValidated = true;
            _discountDetails = {
              'type': discount.type == 'percentage'
                  ? 'Percentage Off'
                  : AppLocalizations.of(context).fixedAmount,
              'value': discount.type == 'percentage'
                  ? '${discount.value.toStringAsFixed(0)}%'
                  : '${discount.value.toStringAsFixed(0)} ${AppLocalizations.of(context).sar}',
              'validUntil': discount.endDate != null
                  ? '${discount.endDate!.day}/${discount.endDate!.month}/${discount.endDate!.year}'
                  : AppLocalizations.of(context).noExpiry,
            };
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _validationError = AppLocalizations.of(context).invalidCouponCode;
          });
        }
      }
    } catch (e, stack) {
      reportError(e, stackTrace: stack, hint: 'Validate coupon code');
      if (mounted) {
        setState(() {
          _validationError = AppLocalizations.of(context).errorWithDetails('$e');
        });
      }
    } finally {
      if (mounted) setState(() => _isValidating = false);
    }
  }

  void _applyCoupon() {
    final l10n = AppLocalizations.of(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l10n.couponCode), backgroundColor: AppColors.success),
    );
    context.pop();
  }
}
