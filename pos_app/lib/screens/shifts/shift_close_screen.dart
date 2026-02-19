import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../core/router/routes.dart';
import '../../core/theme/app_colors.dart';
import '../../providers/auth_providers.dart';
import '../../widgets/layout/app_sidebar.dart';
import '../../widgets/layout/app_header.dart';

/// شاشة إغلاق الوردية
class ShiftCloseScreen extends ConsumerStatefulWidget {
  const ShiftCloseScreen({super.key});

  @override
  ConsumerState<ShiftCloseScreen> createState() => _ShiftCloseScreenState();
}

class _ShiftCloseScreenState extends ConsumerState<ShiftCloseScreen> {
  bool _sidebarCollapsed = false;
  String _selectedNavId = 'pos';

  final _actualCashController = TextEditingController();
  bool _isLoading = false;

  // بيانات الوردية (mock)
  final double _openingCash = 500;
  final double _cashSales = 2350;
  final double _cardSales = 1850;
  final double _refunds = 150;
  final double _cashIn = 200;
  final double _cashOut = 100;

  double get _expectedCash => _openingCash + _cashSales - _refunds + _cashIn - _cashOut;

  void _handleNavigation(AppSidebarItem item) {
    setState(() => _selectedNavId = item.id);
    switch (item.id) {
      case 'dashboard': context.go(AppRoutes.dashboard); break;
      case 'pos': context.go(AppRoutes.pos); break;
      case 'products': context.push(AppRoutes.products); break;
      case 'categories': context.push(AppRoutes.categories); break;
      case 'inventory': context.push(AppRoutes.inventory); break;
      case 'customers': context.push(AppRoutes.customers); break;
      case 'invoices': context.push(AppRoutes.invoices); break;
      case 'orders': context.push(AppRoutes.orders); break;
      case 'sales': context.push(AppRoutes.invoices); break;
      case 'returns': context.push(AppRoutes.returns); break;
      case 'reports': context.push(AppRoutes.reports); break;
    }
  }

  @override
  void dispose() {
    _actualCashController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isWideScreen = size.width > 900;
    final isMediumScreen = size.width > 600;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F172A) : AppColors.backgroundSecondary,
      drawer: isWideScreen ? null : _buildDrawer(l10n),
      body: Row(
        children: [
          if (isWideScreen)
            AppSidebar(
              storeName: l10n.brandName,
              groups: DefaultSidebarItems.getGroups(context),
              selectedId: _selectedNavId,
              onItemTap: _handleNavigation,
              onSettingsTap: () => context.push(AppRoutes.settings),
              onSupportTap: () {},
              onLogoutTap: () => context.go('/login'),
              collapsed: _sidebarCollapsed,
              userName: 'أحمد محمد',
              userRole: l10n.branchManager,
              onUserTap: () {},
            ),
          Expanded(
            child: Column(
              children: [
                AppHeader(
                  title: l10n.closeShift,
                  subtitle: _getDateSubtitle(l10n),
                  showSearch: false,
                  searchHint: l10n.searchPlaceholder,
                  onMenuTap: isWideScreen
                      ? () => setState(() => _sidebarCollapsed = !_sidebarCollapsed)
                      : () => Scaffold.of(context).openDrawer(),
                  onNotificationsTap: () => context.push('/notifications'),
                  notificationsCount: 3,
                  userName: 'أحمد محمد',
                  userRole: l10n.branchManager,
                  onUserTap: () {},
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.all(isMediumScreen ? 24 : 16),
                    child: _buildContent(isWideScreen, isMediumScreen, isDark, l10n),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawer(AppLocalizations l10n) {
    return Drawer(
      child: AppSidebar(
        storeName: l10n.brandName,
        groups: DefaultSidebarItems.getGroups(context),
        selectedId: _selectedNavId,
        onItemTap: (item) {
          Navigator.pop(context);
          _handleNavigation(item);
        },
        onSettingsTap: () {
          Navigator.pop(context);
          context.push(AppRoutes.settings);
        },
        onSupportTap: () => Navigator.pop(context),
        onLogoutTap: () {
          Navigator.pop(context);
          context.go('/login');
        },
        userName: 'أحمد محمد',
        userRole: l10n.branchManager,
        onUserTap: () {},
      ),
    );
  }

  String _getDateSubtitle(AppLocalizations l10n) {
    final now = DateTime.now();
    final dateStr = '${now.day}/${now.month}/${now.year}';
    return '$dateStr • ${l10n.mainBranch}';
  }

  Widget _buildContent(bool isWideScreen, bool isMediumScreen, bool isDark, AppLocalizations l10n) {
    final user = ref.watch(currentUserProvider);
    final actualCash = double.tryParse(_actualCashController.text) ?? 0;
    final difference = actualCash - _expectedCash;

    if (isWideScreen) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 3,
            child: Column(
              children: [
                _buildShiftInfoCard(user, isDark, l10n),
                const SizedBox(height: 24),
                _buildSalesSummaryCard(isDark, l10n),
              ],
            ),
          ),
          const SizedBox(width: 24),
          Expanded(
            flex: 2,
            child: Column(
              children: [
                _buildActualCashCard(actualCash, difference, isDark, l10n),
                const SizedBox(height: 24),
                _buildCloseButton(isDark, l10n),
              ],
            ),
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildShiftInfoCard(user, isDark, l10n),
        SizedBox(height: isMediumScreen ? 24 : 16),
        _buildSalesSummaryCard(isDark, l10n),
        SizedBox(height: isMediumScreen ? 24 : 16),
        _buildActualCashCard(actualCash, difference, isDark, l10n),
        const SizedBox(height: 24),
        _buildCloseButton(isDark, l10n),
      ],
    );
  }

  Widget _buildShiftInfoCard(dynamic user, bool isDark, AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? Colors.white.withValues(alpha: 0.1) : AppColors.border),
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
                child: const Icon(Icons.info_outline_rounded, color: AppColors.info, size: 20),
              ),
              const SizedBox(width: 12),
              Text(
                'معلومات الوردية', // TODO: l10n.shiftInfo
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _InfoRow(
            label: 'الكاشير',
            value: user?.name ?? 'غير معروف',
            icon: Icons.person_rounded,
            isDark: isDark,
          ),
          Divider(height: 20, color: isDark ? Colors.white.withValues(alpha: 0.1) : AppColors.border),
          _InfoRow(
            label: 'وقت الفتح',
            value: '09:00 ص',
            icon: Icons.login_rounded,
            isDark: isDark,
          ),
          Divider(height: 20, color: isDark ? Colors.white.withValues(alpha: 0.1) : AppColors.border),
          _InfoRow(
            label: 'المدة',
            value: '8 ساعات 30 دقيقة',
            icon: Icons.timer_rounded,
            isDark: isDark,
          ),
        ],
      ),
    );
  }

  Widget _buildSalesSummaryCard(bool isDark, AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? Colors.white.withValues(alpha: 0.1) : AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.success.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.receipt_long_rounded, color: AppColors.success, size: 20),
              ),
              const SizedBox(width: 12),
              Text(
                'ملخص المبيعات', // TODO: l10n.salesSummary
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _SummaryRow(label: l10n.openingBalance, value: _openingCash, color: AppColors.info, isDark: isDark),
          _SummaryRow(label: 'مبيعات نقدية', value: _cashSales, color: AppColors.success, prefix: '+', isDark: isDark),
          _SummaryRow(label: 'مبيعات بطاقة', value: _cardSales, color: AppColors.card, isDark: isDark),
          _SummaryRow(label: 'مرتجعات نقدية', value: _refunds, color: AppColors.error, prefix: '-', isDark: isDark),
          _SummaryRow(label: 'إدخال نقدي', value: _cashIn, color: AppColors.success, prefix: '+', isDark: isDark),
          _SummaryRow(label: 'سحب نقدي', value: _cashOut, color: AppColors.secondary, prefix: '-', isDark: isDark),
          Divider(height: 24, color: isDark ? Colors.white.withValues(alpha: 0.1) : AppColors.border),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.account_balance_wallet_rounded, color: AppColors.primary, size: 16),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      'المتوقع في الصندوق', // TODO: l10n.expectedInDrawer
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: isDark ? Colors.white : AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
                Text(
                  '${_expectedCash.toStringAsFixed(0)} ${l10n.sar}',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: AppColors.primary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActualCashCard(double actualCash, double difference, bool isDark, AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? Colors.white.withValues(alpha: 0.1) : AppColors.border),
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
                child: const Icon(Icons.calculate_rounded, color: AppColors.warning, size: 20),
              ),
              const SizedBox(width: 12),
              Text(
                'النقدية الفعلية في الصندوق', // TODO: l10n.actualCashInDrawer
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _actualCashController,
            keyboardType: TextInputType.number,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : AppColors.textPrimary,
            ),
            onChanged: (_) => setState(() {}),
            decoration: InputDecoration(
              hintText: '0.00',
              hintStyle: TextStyle(
                color: isDark ? Colors.white.withValues(alpha: 0.3) : AppColors.textMuted,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
              suffixText: l10n.sar,
              suffixStyle: TextStyle(
                fontSize: 16,
                color: isDark ? Colors.white.withValues(alpha: 0.5) : AppColors.textSecondary,
              ),
              prefixIcon: Padding(
                padding: const EdgeInsets.all(12),
                child: Icon(Icons.money_rounded, size: 28, color: isDark ? Colors.white.withValues(alpha: 0.4) : AppColors.textMuted),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: isDark ? Colors.white.withValues(alpha: 0.1) : AppColors.border),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: isDark ? Colors.white.withValues(alpha: 0.1) : AppColors.border),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.primary, width: 2),
              ),
              filled: true,
              fillColor: isDark ? Colors.white.withValues(alpha: 0.05) : AppColors.backgroundSecondary,
            ),
          ),
          if (_actualCashController.text.isNotEmpty) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: difference == 0
                    ? AppColors.success.withValues(alpha: isDark ? 0.15 : 0.08)
                    : (difference > 0
                        ? AppColors.warning.withValues(alpha: isDark ? 0.15 : 0.08)
                        : AppColors.error.withValues(alpha: isDark ? 0.15 : 0.08)),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: difference == 0
                      ? AppColors.success.withValues(alpha: 0.3)
                      : (difference > 0
                          ? AppColors.warning.withValues(alpha: 0.3)
                          : AppColors.error.withValues(alpha: 0.3)),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        difference == 0
                            ? Icons.check_circle_rounded
                            : (difference > 0 ? Icons.arrow_upward_rounded : Icons.arrow_downward_rounded),
                        color: difference == 0
                            ? AppColors.success
                            : (difference > 0 ? AppColors.warning : AppColors.error),
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        difference == 0
                            ? 'متطابق'
                            : (difference > 0 ? 'فائض' : 'عجز'),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: difference == 0
                              ? AppColors.success
                              : (difference > 0 ? AppColors.warning : AppColors.error),
                        ),
                      ),
                    ],
                  ),
                  Text(
                    '${difference >= 0 ? '+' : ''}${difference.toStringAsFixed(0)} ${l10n.sar}',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: difference == 0
                          ? AppColors.success
                          : (difference > 0 ? AppColors.warning : AppColors.error),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCloseButton(bool isDark, AppLocalizations l10n) {
    return SizedBox(
      width: double.infinity,
      child: FilledButton.icon(
        onPressed: _isLoading || _actualCashController.text.isEmpty ? null : _closeShift,
        icon: _isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
              )
            : const Icon(Icons.lock_rounded, size: 20),
        label: Text(l10n.closeShift, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.error,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }

  Future<void> _closeShift() async {
    setState(() => _isLoading = true);

    try {
      // TODO: Save shift closing to database
      await Future.delayed(const Duration(seconds: 1));

      if (!mounted) return;
      context.push(AppRoutes.shiftSummary);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('خطأ: $e'), backgroundColor: AppColors.error),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final bool isDark;

  const _InfoRow({required this.label, required this.value, required this.icon, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 18, color: isDark ? Colors.white.withValues(alpha: 0.4) : AppColors.textMuted),
          const SizedBox(width: 10),
          Text(
            '$label:',
            style: TextStyle(color: isDark ? Colors.white.withValues(alpha: 0.6) : AppColors.textSecondary),
          ),
          const Spacer(),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white : AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final double value;
  final Color color;
  final String prefix;
  final bool isDark;

  const _SummaryRow({
    required this.label,
    required this.value,
    required this.color,
    this.prefix = '',
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              label,
              style: TextStyle(color: isDark ? Colors.white.withValues(alpha: 0.7) : AppColors.textSecondary),
            ),
          ),
          Text(
            '$prefix${value.toStringAsFixed(0)} ر.س',
            style: TextStyle(color: color, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}
