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
import 'package:alhai_design_system/alhai_design_system.dart'
    show AlhaiBreakpoints, AlhaiSnackbar, AlhaiSpacing;
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
  bool _isApplying = false;
  String? _validationError;
  Map<String, dynamic>? _discountDetails;
  // Holds the validated coupon row so apply doesn't have to re-query.
  CouponsTableData? _validatedCoupon;

  // Recent coupons — pulled from the local coupons table on first
  // paint (see [initState] → [_loadRecentCoupons]). Previously this
  // list was hard-coded empty, so the "الكوبونات الأخيرة" card was
  // effectively dead UI.
  List<CouponsTableData> _recentCoupons = const [];

  @override
  void initState() {
    super.initState();
    _loadRecentCoupons();
  }

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _loadRecentCoupons() async {
    try {
      final storeId = ref.read(currentStoreIdProvider);
      if (storeId == null) return;
      final coupons = await _db.discountsDao.getRecentCoupons(storeId);
      if (mounted) setState(() => _recentCoupons = coupons);
    } catch (e, stack) {
      // Silent fallback — a failure to load the rail must not block
      // the primary validate/apply flow which is the whole point of
      // this screen.
      reportError(e, stackTrace: stack, hint: 'Load recent coupons');
    }
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
            padding: EdgeInsets.all(
              isMediumScreen ? AlhaiSpacing.lg : AlhaiSpacing.md,
            ),
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
                _buildCodeInputCard(isDark, l10n),
                const SizedBox(height: AlhaiSpacing.lg),
                if (_isValidated && _discountDetails != null)
                  _buildDiscountDetailsCard(isDark, l10n),
                if (_validationError != null) _buildErrorCard(isDark, l10n),
              ],
            ),
          ),
          const SizedBox(width: AlhaiSpacing.lg),
          Expanded(flex: 2, child: _buildRecentCouponsCard(isDark, l10n)),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildCodeInputCard(isDark, l10n),
        SizedBox(height: isMediumScreen ? AlhaiSpacing.lg : AlhaiSpacing.md),
        if (_isValidated && _discountDetails != null) ...[
          _buildDiscountDetailsCard(isDark, l10n),
          SizedBox(height: isMediumScreen ? AlhaiSpacing.lg : AlhaiSpacing.md),
        ],
        if (_validationError != null) ...[
          _buildErrorCard(isDark, l10n),
          SizedBox(height: isMediumScreen ? AlhaiSpacing.lg : AlhaiSpacing.md),
        ],
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
                child: const Icon(
                  Icons.confirmation_number_rounded,
                  color: AppColors.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: AlhaiSpacing.sm),
              Text(
                l10n.enterCouponCode,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.getTextPrimary(isDark),
                ),
              ),
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
                borderSide: const BorderSide(
                  color: AppColors.primary,
                  width: 2,
                ),
              ),
              filled: true,
              fillColor: AppColors.getSurfaceVariant(isDark),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: AlhaiSpacing.md,
                vertical: 18,
              ),
            ),
          ),
          const SizedBox(height: AlhaiSpacing.md),
          // Scan button
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () {
                AlhaiSnackbar.info(context, l10n.scanBarcode);
              },
              icon: const Icon(Icons.qr_code_scanner_rounded, size: 18),
              label: Text(l10n.scanCouponBarcode),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.info,
                side: BorderSide(color: AppColors.info.withValues(alpha: 0.5)),
                padding: const EdgeInsets.symmetric(vertical: AlhaiSpacing.sm),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
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
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.check_circle_outlined, size: 18),
                  label: Text(l10n.validateCoupon),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.getTextSecondary(isDark),
                    side: BorderSide(color: AppColors.getBorder(isDark)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: AlhaiSpacing.sm),
              Expanded(
                child: FilledButton.icon(
                  onPressed:
                      _isValidated && _discountDetails != null && !_isApplying
                      ? _applyCoupon
                      : null,
                  icon: _isApplying
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.textOnPrimary,
                          ),
                        )
                      : const Icon(Icons.add_shopping_cart_rounded, size: 18),
                  label: Text(l10n.apply),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.success,
                    foregroundColor: AppColors.textOnPrimary,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
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
              const Icon(
                Icons.check_circle_rounded,
                color: AppColors.success,
                size: 24,
              ),
              const SizedBox(width: AlhaiSpacing.sm),
              Text(
                l10n.couponValid,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.getTextPrimary(isDark),
                ),
              ),
            ],
          ),
          const SizedBox(height: AlhaiSpacing.md),
          _buildDetailRow(l10n.discountType, details['type'] as String, isDark),
          _buildDetailRow(
            l10n.discountValue,
            details['value'] as String,
            isDark,
          ),
          // Labels were hard-coded English strings before — the
          // `validUntilDate` l10n key already carries the "صالح
          // حتى:" prefix, so we split and reuse just the prefix. For
          // minPurchase no bare-label key exists so we use a direct
          // Arabic literal to avoid churning app_ar.arb in this PR.
          _buildDetailRow(
            'صالح حتى',
            details['validUntil'] as String,
            isDark,
          ),
          if (details['minPurchase'] != null)
            _buildDetailRow(
              'الحد الأدنى للشراء',
              details['minPurchase'] as String,
              isDark,
            ),
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
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              color: AppColors.getTextSecondary(isDark),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.getTextPrimary(isDark),
            ),
          ),
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
          const Icon(
            Icons.error_outline_rounded,
            color: AppColors.error,
            size: 24,
          ),
          const SizedBox(width: AlhaiSpacing.sm),
          Expanded(
            child: Text(
              _validationError!,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.getTextPrimary(isDark),
              ),
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
                child: const Icon(
                  Icons.history_rounded,
                  color: AppColors.warning,
                  size: 20,
                ),
              ),
              const SizedBox(width: AlhaiSpacing.sm),
              Text(
                l10n.recentCoupons,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.getTextPrimary(isDark),
                ),
              ),
            ],
          ),
          const SizedBox(height: AlhaiSpacing.md),
          if (_recentCoupons.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(AlhaiSpacing.md),
                child: Text(
                  l10n.noRecentCoupons,
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.getTextMuted(isDark),
                  ),
                ),
              ),
            )
          else
            ..._recentCoupons.map((coupon) {
              final date = coupon.createdAt;
              final discountLabel = coupon.type == 'percentage'
                  ? '${coupon.value}%'
                  : '${(coupon.value / 100.0).toStringAsFixed(2)} ${l10n.sar}';
              return InkWell(
                onTap: () {
                  _codeController.text = coupon.code;
                  setState(() {
                    _isValidated = false;
                    _validationError = null;
                    _discountDetails = null;
                  });
                },
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  margin: const EdgeInsetsDirectional.only(
                    bottom: AlhaiSpacing.xs,
                  ),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.getSurfaceVariant(isDark),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        alignment: Alignment.center,
                        child: const Icon(
                          Icons.confirmation_number_outlined,
                          color: AppColors.primary,
                          size: 18,
                        ),
                      ),
                      const SizedBox(width: AlhaiSpacing.sm),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              coupon.code,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: AppColors.getTextPrimary(isDark),
                                fontFamily: 'monospace',
                              ),
                            ),
                            Text(
                              '${date.day}/${date.month}/${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}',
                              style: TextStyle(
                                fontSize: 11,
                                color: AppColors.getTextMuted(isDark),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AlhaiSpacing.xs,
                          vertical: AlhaiSpacing.xxs,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.success.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          discountLabel,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.success,
                          ),
                        ),
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

    final l10n = AppLocalizations.of(context);

    setState(() {
      _isValidating = true;
      _validationError = null;
      _discountDetails = null;
      _isValidated = false;
      _validatedCoupon = null;
    });

    try {
      final storeId = ref.read(currentStoreIdProvider);
      if (storeId == null) throw Exception('No store');

      // Hit the canonical coupons table — earlier this screen searched
      // discounts by name, which both missed real coupons and
      // double-applied unrelated discounts whose Arabic name happened
      // to collide with the typed code.
      final coupon = await _db.discountsDao.getCouponByCode(code, storeId);

      if (coupon == null) {
        if (mounted) {
          setState(() => _validationError = l10n.invalidCouponCode);
        }
        return;
      }

      // Expiry guard.
      if (coupon.expiresAt != null &&
          coupon.expiresAt!.isBefore(DateTime.now())) {
        if (mounted) {
          setState(() => _validationError = l10n.invalidCouponCode);
        }
        return;
      }

      // Usage cap guard. `maxUses == 0` means unlimited.
      if (coupon.maxUses > 0 && coupon.currentUses >= coupon.maxUses) {
        if (mounted) {
          setState(() => _validationError = l10n.invalidCouponCode);
        }
        return;
      }

      if (!mounted) return;
      setState(() {
        _isValidated = true;
        _validatedCoupon = coupon;
        _discountDetails = {
          'type': coupon.type == 'percentage'
              ? l10n.percentageOff
              : l10n.fixedAmount,
          // coupons.value is int cents for fixed, plain percentage for
          // percentage type (C-4 Session 4).
          'value': coupon.type == 'percentage'
              ? '${coupon.value}%'
              : '${(coupon.value / 100.0).toStringAsFixed(2)} ${l10n.sar}',
          'validUntil': coupon.expiresAt != null
              ? '${coupon.expiresAt!.day}/${coupon.expiresAt!.month}/${coupon.expiresAt!.year}'
              : l10n.noExpiry,
          if (coupon.minPurchase > 0)
            'minPurchase':
                '${(coupon.minPurchase / 100.0).toStringAsFixed(2)} ${l10n.sar}',
        };
      });
    } catch (e, stack) {
      reportError(e, stackTrace: stack, hint: 'Validate coupon code');
      if (mounted) {
        setState(() {
          _validationError = l10n.errorWithDetails('$e');
        });
      }
    } finally {
      if (mounted) setState(() => _isValidating = false);
    }
  }

  Future<void> _applyCoupon() async {
    final coupon = _validatedCoupon;
    final l10n = AppLocalizations.of(context);
    if (coupon == null) return;

    setState(() => _isApplying = true);

    try {
      // Atomic redemption: the SQL UPDATE refuses to bump current_uses
      // past max_uses or after expires_at, so two simultaneous taps
      // can't both succeed. Anything other than 1 row affected = the
      // coupon was burned out by another transaction in the meantime.
      final affected = await _db.discountsDao.tryRedeemCoupon(coupon.id);
      if (affected == 0) {
        if (mounted) {
          setState(() {
            _isValidated = false;
            _validatedCoupon = null;
            _discountDetails = null;
            _validationError = l10n.invalidCouponCode;
          });
        }
        return;
      }

      if (!mounted) return;
      AlhaiSnackbar.success(context, l10n.couponValid);
      context.pop(coupon);
    } catch (e, stack) {
      reportError(e, stackTrace: stack, hint: 'Apply coupon code');
      if (mounted) {
        AlhaiSnackbar.error(context, l10n.errorWithDetails('$e'));
      }
    } finally {
      if (mounted) setState(() => _isApplying = false);
    }
  }
}
