/// Store Info Screen - Read-only store information display
///
/// Displays store name, address, phone, logo, CR number.
/// Cashier view only, no edit capability.
/// Supports: RTL Arabic, dark/light theme, responsive layout.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:get_it/get_it.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:alhai_shared_ui/alhai_shared_ui.dart';
import 'package:alhai_l10n/alhai_l10n.dart';
import 'package:alhai_database/alhai_database.dart';
import 'package:alhai_auth/alhai_auth.dart';
import 'package:alhai_design_system/alhai_design_system.dart'
    show AlhaiBreakpoints, AlhaiSpacing;
// alhai_design_system is re-exported via alhai_shared_ui
import '../../../core/services/sentry_service.dart';

/// Read-only store information screen
class StoreInfoScreen extends ConsumerStatefulWidget {
  const StoreInfoScreen({super.key});

  @override
  ConsumerState<StoreInfoScreen> createState() => _StoreInfoScreenState();
}

class _StoreInfoScreenState extends ConsumerState<StoreInfoScreen> {
  final _db = GetIt.I<AppDatabase>();
  bool _isLoading = true;
  String? _error;

  String _storeName = '';
  String _storeAddress = '';
  String _storePhone = '';
  String _storeLogo = '';
  String _crNumber = '';
  String _taxNumber = '';
  String _storeEmail = '';
  String _storeCity = '';

  @override
  void initState() {
    super.initState();
    _loadStoreData();
  }

  Future<void> _loadStoreData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final user = ref.read(currentUserProvider);
      final storeId = user?.storeId ?? '';
      if (storeId.isNotEmpty) {
        final store = await _db.storesDao.getStoreById(storeId);
        if (store != null && mounted) {
          setState(() {
            _storeName = store.name;
            _storeAddress = store.address ?? '';
            _storePhone = store.phone ?? '';
            _storeLogo = store.logo ?? '';
            _crNumber = store.commercialReg ?? '';
            _taxNumber = store.taxNumber ?? '';
            _storeEmail = store.email ?? '';
            _storeCity = store.city ?? '';
          });
        }
      }
    } catch (e, stack) {
      reportError(e, stackTrace: stack, hint: 'Load store info');
      if (mounted) setState(() => _error = '$e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isWideScreen = size.width >= AlhaiBreakpoints.desktop;
    final isMediumScreen = size.width >= AlhaiBreakpoints.tablet;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context);

    return Column(
      children: [
        AppHeader(
          title: l10n.storeInfo,
          subtitle: 'عرض تفاصيل المتجر',
          showSearch: false,
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back_rounded,
              color: AppColors.getTextPrimary(isDark),
            ),
            onPressed: () => context.pop(),
            tooltip: l10n.back,
          ),
          onNotificationsTap: () => context.push(AppRoutes.notificationsCenter),
          userName: ref.watch(currentUserProvider)?.name ?? l10n.cashCustomer,
          userRole: l10n.cashier,
          onUserTap: () => context.push(AppRoutes.profile),
        ),
        Expanded(
          child: _isLoading
              ? const AppLoadingState()
              : _error != null
              ? AppErrorState.general(
                  context,
                  message: _error!,
                  onRetry: _loadStoreData,
                )
              : SingleChildScrollView(
                  padding: EdgeInsets.all(
                    isMediumScreen ? AlhaiSpacing.lg : AlhaiSpacing.md,
                  ),
                  child: _buildContent(
                    isWideScreen,
                    isMediumScreen,
                    isDark,
                    l10n,
                  ),
                ),
        ),
      ],
    );
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
          Expanded(flex: 2, child: _buildStoreCard(isDark, l10n)),
          const SizedBox(width: AlhaiSpacing.lg),
          Expanded(flex: 3, child: _buildDetailsCard(isDark, l10n)),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildStoreCard(isDark, l10n),
        SizedBox(height: isMediumScreen ? AlhaiSpacing.lg : AlhaiSpacing.md),
        _buildDetailsCard(isDark, l10n),
      ],
    );
  }

  Widget _buildStoreCard(bool isDark, AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(AlhaiSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.getSurface(isDark),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.getBorder(isDark)),
      ),
      child: Column(
        children: [
          Container(
            width: 96,
            height: 96,
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.3),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: _storeLogo.isNotEmpty
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: CachedNetworkImage(
                      imageUrl: _storeLogo,
                      fit: BoxFit.cover,
                      placeholder: (_, __) =>
                          const Center(child: CircularProgressIndicator()),
                      errorWidget: (_, __, ___) => const Icon(
                        Icons.store_rounded,
                        size: 44,
                        color: AppColors.textOnPrimary,
                      ),
                    ),
                  )
                : const Icon(
                    Icons.store_rounded,
                    size: 44,
                    color: AppColors.textOnPrimary,
                  ),
          ),
          const SizedBox(height: AlhaiSpacing.mdl),
          Text(
            _storeName.isNotEmpty ? _storeName : l10n.storeName,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.getTextPrimary(isDark),
            ),
            textAlign: TextAlign.center,
          ),
          if (_storeCity.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              _storeCity,
              style: TextStyle(
                fontSize: 14,
                color: AppColors.getTextSecondary(isDark),
              ),
            ),
          ],
          const SizedBox(height: AlhaiSpacing.md),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AlhaiSpacing.md,
              vertical: AlhaiSpacing.xs,
            ),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: isDark ? 0.15 : 0.08),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text(
              'Read Only',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailsCard(bool isDark, AppLocalizations l10n) {
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
                  color: AppColors.info.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.info_outline_rounded,
                  color: AppColors.info,
                  size: 20,
                ),
              ),
              const SizedBox(width: AlhaiSpacing.sm),
              Text(
                'Store Details',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.getTextPrimary(isDark),
                ),
              ),
            ],
          ),
          const SizedBox(height: AlhaiSpacing.mdl),
          _InfoRow(
            icon: Icons.store_rounded,
            label: l10n.storeName,
            value: _storeName,
            isDark: isDark,
          ),
          _divider(isDark),
          _InfoRow(
            icon: Icons.location_on_rounded,
            label: l10n.address,
            value: _storeAddress,
            isDark: isDark,
          ),
          _divider(isDark),
          _InfoRow(
            icon: Icons.phone_rounded,
            label: l10n.phone,
            value: _storePhone,
            isDark: isDark,
          ),
          _divider(isDark),
          _InfoRow(
            icon: Icons.email_rounded,
            label: l10n.email,
            value: _storeEmail,
            isDark: isDark,
          ),
          _divider(isDark),
          _InfoRow(
            icon: Icons.business_rounded,
            label: l10n.crNumber,
            value: _crNumber,
            isDark: isDark,
          ),
          _divider(isDark),
          _InfoRow(
            icon: Icons.receipt_long_rounded,
            label: l10n.taxNumber,
            value: _taxNumber,
            isDark: isDark,
          ),
          _divider(isDark),
          _InfoRow(
            icon: Icons.location_city_rounded,
            label: l10n.city,
            value: _storeCity,
            isDark: isDark,
          ),
        ],
      ),
    );
  }

  Widget _divider(bool isDark) {
    return Divider(color: AppColors.getBorder(isDark), height: 1);
  }
}

/// Single read-only information row
class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool isDark;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppColors.getTextMuted(isDark)),
          const SizedBox(width: AlhaiSpacing.sm),
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13,
                color: AppColors.getTextSecondary(isDark),
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value.isNotEmpty ? value : '-',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.getTextPrimary(isDark),
              ),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }
}
