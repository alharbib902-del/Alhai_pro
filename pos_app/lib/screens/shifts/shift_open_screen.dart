import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../core/router/routes.dart';
import '../../core/theme/app_colors.dart';
import '../../providers/auth_providers.dart';
import '../../providers/shifts_providers.dart';
import '../../widgets/layout/app_header.dart';

/// شاشة فتح الوردية
class ShiftOpenScreen extends ConsumerStatefulWidget {
  const ShiftOpenScreen({super.key});

  @override
  ConsumerState<ShiftOpenScreen> createState() => _ShiftOpenScreenState();
}

class _ShiftOpenScreenState extends ConsumerState<ShiftOpenScreen> {

  final _openingCashController = TextEditingController();
  bool _isLoading = false;
  @override
  void dispose() {
    _openingCashController.dispose();
    super.dispose();
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
                  title: l10n.openShift,
                  subtitle: _getDateSubtitle(l10n),
                  showSearch: false,
                  searchHint: l10n.searchPlaceholder,
                  onMenuTap: isWideScreen
                      ? null
                      : () => Scaffold.of(context).openDrawer(),
                  onNotificationsTap: () => context.push('/notifications'),
                  notificationsCount: 3,
                  userName: ref.watch(currentUserProvider)?.name ?? l10n.cashCustomer,
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
            );
  }
  String _getDateSubtitle(AppLocalizations l10n) {
    final now = DateTime.now();
    final dateStr = '${now.day}/${now.month}/${now.year}';
    return '$dateStr • ${l10n.mainBranch}';
  }

  Widget _buildContent(bool isWideScreen, bool isMediumScreen, bool isDark, AppLocalizations l10n) {
    final user = ref.watch(currentUserProvider);

    if (isWideScreen) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 3,
            child: Column(
              children: [
                _buildUserCard(user, isDark, l10n),
                const SizedBox(height: 24),
                _buildOpeningCashCard(isDark, l10n),
              ],
            ),
          ),
          const SizedBox(width: 24),
          Expanded(
            flex: 2,
            child: Column(
              children: [
                _buildInfoCard(isDark, l10n),
                const SizedBox(height: 24),
                _buildOpenButton(isDark, l10n),
              ],
            ),
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildUserCard(user, isDark, l10n),
        SizedBox(height: isMediumScreen ? 24 : 16),
        _buildOpeningCashCard(isDark, l10n),
        SizedBox(height: isMediumScreen ? 24 : 16),
        _buildInfoCard(isDark, l10n),
        const SizedBox(height: 24),
        _buildOpenButton(isDark, l10n),
      ],
    );
  }

  Widget _buildUserCard(dynamic user, bool isDark, AppLocalizations l10n) {
    final now = DateTime.now();
    final timeStr = '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? Colors.white.withValues(alpha: 0.1) : AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Center(
              child: Text(
                user?.name?.isNotEmpty == true ? user!.name[0].toUpperCase() : '?',
                style: const TextStyle(fontSize: 22, color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user?.name ?? l10n.unknownUser,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.access_time_rounded, size: 14, color: isDark ? Colors.white.withValues(alpha: 0.5) : AppColors.textMuted),
                    const SizedBox(width: 4),
                    Text(
                      timeStr,
                      style: TextStyle(
                        fontSize: 13,
                        color: isDark ? Colors.white.withValues(alpha: 0.6) : AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Icon(Icons.calendar_today_rounded, size: 14, color: isDark ? Colors.white.withValues(alpha: 0.5) : AppColors.textMuted),
                    const SizedBox(width: 4),
                    Text(
                      '${now.day}/${now.month}/${now.year}',
                      style: TextStyle(
                        fontSize: 13,
                        color: isDark ? Colors.white.withValues(alpha: 0.6) : AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOpeningCashCard(bool isDark, AppLocalizations l10n) {
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
                child: const Icon(Icons.account_balance_wallet_rounded, color: AppColors.info, size: 20),
              ),
              const SizedBox(width: 12),
              Text(
                l10n.openingCashLabel,
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
            controller: _openingCashController,
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
                child: Icon(Icons.calculate_rounded, size: 28, color: isDark ? Colors.white.withValues(alpha: 0.4) : AppColors.textMuted),
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
          const SizedBox(height: 16),
          // Quick amount chips
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [100, 200, 500, 1000].map((amount) {
              final isSelected = _openingCashController.text == amount.toString();
              return Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    _openingCashController.text = amount.toString();
                    setState(() {});
                  },
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.primary.withValues(alpha: 0.1)
                          : (isDark ? Colors.white.withValues(alpha: 0.05) : AppColors.backgroundSecondary),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: isSelected
                            ? AppColors.primary.withValues(alpha: 0.5)
                            : (isDark ? Colors.white.withValues(alpha: 0.1) : AppColors.border),
                      ),
                    ),
                    child: Text(
                      '$amount ${l10n.sar}',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: isSelected
                            ? AppColors.primary
                            : (isDark ? Colors.white.withValues(alpha: 0.7) : AppColors.textSecondary),
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

  Widget _buildInfoCard(bool isDark, AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.warning.withValues(alpha: isDark ? 0.12 : 0.06),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.warning.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.warning.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.info_outline_rounded, color: AppColors.warning, size: 20),
              ),
              const SizedBox(width: 12),
              Text(
                l10n.importantNotes,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          _InfoItem(
            text: l10n.countCashBeforeShift,
            isDark: isDark,
          ),
          const SizedBox(height: 8),
          _InfoItem(
            text: l10n.shiftTimeAutoRecorded,
            isDark: isDark,
          ),
          const SizedBox(height: 8),
          _InfoItem(
            text: l10n.oneShiftAtATime,
            isDark: isDark,
          ),
        ],
      ),
    );
  }

  Widget _buildOpenButton(bool isDark, AppLocalizations l10n) {
    return SizedBox(
      width: double.infinity,
      child: FilledButton.icon(
        onPressed: _isLoading ? null : _openShift,
        icon: _isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
              )
            : const Icon(Icons.login_rounded, size: 20),
        label: Text(l10n.openShift, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }

  Future<void> _openShift() async {
    final l10n = AppLocalizations.of(context)!;
    final openingCash = double.tryParse(_openingCashController.text);

    // Validate: opening cash is required and must be numeric > 0
    if (openingCash == null || openingCash <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.pleaseEnterOpeningCash),
          backgroundColor: AppColors.warning,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final user = ref.read(currentUserProvider);
      final openShift = ref.read(openShiftActionProvider);

      await openShift(
        openingCash: openingCash,
        cashierId: user?.id ?? 'unknown',
        cashierName: user?.name ?? l10n.unknownUser,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.shiftOpenedWithAmount(openingCash.toStringAsFixed(0), l10n.sar)),
          backgroundColor: AppColors.success,
        ),
      );

      context.go(AppRoutes.home);
    } catch (e) {
      if (!mounted) return;
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text(l10n.errorOpeningShift),
          content: Text('$e'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(l10n.close),
            ),
          ],
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
}

class _InfoItem extends StatelessWidget {
  final String text;
  final bool isDark;

  const _InfoItem({required this.text, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: AppColors.warning.withValues(alpha: 0.7),
              shape: BoxShape.circle,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 13,
              color: isDark ? Colors.white.withValues(alpha: 0.7) : AppColors.textSecondary,
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }
}
