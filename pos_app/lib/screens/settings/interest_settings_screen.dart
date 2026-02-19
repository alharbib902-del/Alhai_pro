import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/theme/app_colors.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../widgets/layout/app_header.dart';

/// شاشة إعدادات الفوائد الشهرية
class InterestSettingsScreen extends ConsumerStatefulWidget {
  const InterestSettingsScreen({super.key});

  @override
  ConsumerState<InterestSettingsScreen> createState() =>
      _InterestSettingsScreenState();
}

class _InterestSettingsScreenState
    extends ConsumerState<InterestSettingsScreen> {
  bool _enableInterest = true;
  double _monthlyRate = 2.0;
  int _gracePeriodDays = 30;
  bool _compoundInterest = false;
  bool _autoCalculate = true;
  bool _notifyCustomer = true;
  double _maxInterestRate = 5.0;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _enableInterest = prefs.getBool('interest_enabled') ?? true;
      _monthlyRate = prefs.getDouble('interest_monthly_rate') ?? 2.0;
      _gracePeriodDays = prefs.getInt('interest_grace_days') ?? 30;
      _compoundInterest = prefs.getBool('interest_compound') ?? false;
      _autoCalculate = prefs.getBool('interest_auto_calculate') ?? true;
      _notifyCustomer = prefs.getBool('interest_notify_customer') ?? true;
      _maxInterestRate = prefs.getDouble('interest_max_rate') ?? 5.0;
    });
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('interest_enabled', _enableInterest);
    await prefs.setDouble('interest_monthly_rate', _monthlyRate);
    await prefs.setInt('interest_grace_days', _gracePeriodDays);
    await prefs.setBool('interest_compound', _compoundInterest);
    await prefs.setBool('interest_auto_calculate', _autoCalculate);
    await prefs.setBool('interest_notify_customer', _notifyCustomer);
    await prefs.setDouble('interest_max_rate', _maxInterestRate);

    if (mounted) {
      final l10n = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.interestSettingsSaved),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
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
          title: l10n.interestSettingsTitle,
          onMenuTap: isWideScreen ? null : () => Scaffold.of(context).openDrawer(),
          onNotificationsTap: () => context.push('/notifications'),
          notificationsCount: 3,
          userName: l10n.defaultUserName,
          userRole: l10n.branchManager,
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(isMediumScreen ? 24 : 16),
            child: _buildContent(isDark, l10n),
          ),
        ),
      ],
    );
  }

  Widget _buildContent(bool isDark, AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildPageHeader(isDark, l10n),
        const SizedBox(height: 20),

        // Interest settings
        _buildSettingsGroup(l10n.monthlyInterest, Icons.trending_up_rounded,
            const Color(0xFFF97316), isDark, [
          SwitchListTile(
            title: Text(l10n.enableInterest,
                style: TextStyle(
                    color: isDark ? Colors.white : AppColors.textPrimary)),
            subtitle:
                Text(l10n.enableInterestDesc),
            value: _enableInterest,
            onChanged: (v) => setState(() => _enableInterest = v),
          ),
          if (_enableInterest) ...[
            const Divider(indent: 16, endIndent: 16),
            ListTile(
              title: Text(l10n.monthlyInterestRate,
                  style: TextStyle(
                      color: isDark ? Colors.white : AppColors.textPrimary)),
              subtitle: Text('${_monthlyRate.toStringAsFixed(1)}%'),
              trailing: SizedBox(
                width: 200,
                child: Slider(
                  value: _monthlyRate,
                  min: 0.5,
                  max: _maxInterestRate,
                  divisions: ((_maxInterestRate - 0.5) * 2).toInt(),
                  label: '${_monthlyRate.toStringAsFixed(1)}%',
                  onChanged: (v) => setState(() => _monthlyRate = v),
                ),
              ),
            ),
            ListTile(
              title: Text(l10n.maxInterestRateLabel,
                  style: TextStyle(
                      color: isDark ? Colors.white : AppColors.textPrimary)),
              subtitle: Text('${_maxInterestRate.toStringAsFixed(1)}%'),
              trailing: SizedBox(
                width: 200,
                child: Slider(
                  value: _maxInterestRate,
                  min: 2,
                  max: 10,
                  divisions: 16,
                  label: '${_maxInterestRate.toStringAsFixed(1)}%',
                  onChanged: (v) {
                    setState(() {
                      _maxInterestRate = v;
                      if (_monthlyRate > v) _monthlyRate = v;
                    });
                  },
                ),
              ),
            ),
          ],
          const SizedBox(height: 8),
        ]),

        // Grace period
        if (_enableInterest)
          _buildSettingsGroup(l10n.gracePeriod, Icons.schedule_rounded,
              AppColors.info, isDark, [
            ListTile(
              title: Text(l10n.graceDays,
                  style: TextStyle(
                      color: isDark ? Colors.white : AppColors.textPrimary)),
              subtitle: Text(l10n.graceDaysLabel(_gracePeriodDays)),
              trailing: SizedBox(
                width: 200,
                child: Slider(
                  value: _gracePeriodDays.toDouble(),
                  min: 0,
                  max: 90,
                  divisions: 9,
                  label: '$_gracePeriodDays',
                  onChanged: (v) =>
                      setState(() => _gracePeriodDays = v.toInt()),
                ),
              ),
            ),
            SwitchListTile(
              title: Text(l10n.compoundInterest,
                  style: TextStyle(
                      color: isDark ? Colors.white : AppColors.textPrimary)),
              subtitle: Text(l10n.compoundInterestDesc),
              value: _compoundInterest,
              onChanged: (v) => setState(() => _compoundInterest = v),
            ),
            const SizedBox(height: 8),
          ]),

        // Auto & Notifications
        if (_enableInterest)
          _buildSettingsGroup(l10n.calculationAndAlerts, Icons.notifications_rounded,
              AppColors.success, isDark, [
            SwitchListTile(
              title: Text(l10n.autoCalculation,
                  style: TextStyle(
                      color: isDark ? Colors.white : AppColors.textPrimary)),
              subtitle:
                  Text(l10n.autoCalculationDesc),
              value: _autoCalculate,
              onChanged: (v) => setState(() => _autoCalculate = v),
            ),
            SwitchListTile(
              title: Text(l10n.customerNotification,
                  style: TextStyle(
                      color: isDark ? Colors.white : AppColors.textPrimary)),
              subtitle: Text(l10n.customerNotificationDesc),
              value: _notifyCustomer,
              onChanged: (v) => setState(() => _notifyCustomer = v),
            ),
            const SizedBox(height: 8),
          ]),

        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            onPressed: _saveSettings,
            icon: const Icon(Icons.save_rounded),
            label: Text(l10n.saveSettings),
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPageHeader(bool isDark, AppLocalizations l10n) {
    return Row(
      children: [
        IconButton(
          onPressed: () => context.pop(),
          icon: Icon(Icons.arrow_back_rounded,
              color: isDark ? Colors.white : AppColors.textPrimary),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: const Color(0xFFF97316).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(Icons.trending_up_rounded,
              color: Color(0xFFF97316), size: 24),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.interestSettingsTitle,
                style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : AppColors.textPrimary)),
            Text(l10n.interestSettingsSubtitle,
                style: TextStyle(
                    fontSize: 13,
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.5)
                        : AppColors.textSecondary)),
          ],
        ),
      ],
    );
  }

  Widget _buildSettingsGroup(String title, IconData icon, Color color,
      bool isDark, List<Widget> children) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.1)
              : AppColors.border,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: color, size: 20),
                ),
                const SizedBox(width: 12),
                Text(title,
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color:
                            isDark ? Colors.white : AppColors.textPrimary)),
              ],
            ),
          ),
          ...children,
        ],
      ),
    );
  }
}
