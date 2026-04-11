import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:alhai_shared_ui/alhai_shared_ui.dart';
import 'package:alhai_l10n/alhai_l10n.dart';
import 'package:alhai_database/alhai_database.dart';
import 'package:alhai_core/alhai_core.dart';
import '../../../providers/settings_db_providers.dart';
import 'package:alhai_design_system/alhai_design_system.dart';

// مفاتيح إعدادات الفوائد الشهرية
const String _kInterestEnabled = 'interest_enabled';
const String _kInterestRate = 'interest_rate';
const String _kInterestGracePeriod = 'interest_grace_period';
const String _kInterestCompound = 'interest_compound';
const String _kInterestAutoCalculate = 'interest_auto_calculate';
const String _kInterestNotifyCustomer = 'interest_notify_customer';
const String _kInterestMaxRate = 'interest_max_rate';

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
  bool _isLoading = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    try {
      final storeId = ref.read(currentStoreIdProvider);
      if (storeId == null) {
        if (mounted) setState(() => _isLoading = false);
        return;
      }

      final db = getIt<AppDatabase>();
      final settings = await getSettingsByPrefix(db, storeId, 'interest_');

      if (mounted) {
        setState(() {
          _enableInterest = settings[_kInterestEnabled] != 'false';
          _monthlyRate = double.tryParse(settings[_kInterestRate] ?? '') ?? 2.0;
          _gracePeriodDays =
              int.tryParse(settings[_kInterestGracePeriod] ?? '') ?? 30;
          _compoundInterest = settings[_kInterestCompound] == 'true';
          _autoCalculate = settings[_kInterestAutoCalculate] != 'false';
          _notifyCustomer = settings[_kInterestNotifyCustomer] != 'false';
          _maxInterestRate =
              double.tryParse(settings[_kInterestMaxRate] ?? '') ?? 5.0;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _saveSettings() async {
    setState(() => _isSaving = true);
    try {
      final storeId = ref.read(currentStoreIdProvider);
      if (storeId == null) return;

      final db = getIt<AppDatabase>();

      await saveSettingsBatch(
        db: db,
        storeId: storeId,
        settings: {
          _kInterestEnabled: _enableInterest.toString(),
          _kInterestRate: _monthlyRate.toString(),
          _kInterestGracePeriod: _gracePeriodDays.toString(),
          _kInterestCompound: _compoundInterest.toString(),
          _kInterestAutoCalculate: _autoCalculate.toString(),
          _kInterestNotifyCustomer: _notifyCustomer.toString(),
          _kInterestMaxRate: _maxInterestRate.toString(),
        },
        ref: ref,
      );

      if (mounted) {
        final l10n = AppLocalizations.of(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.interestSettingsSaved),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        final l10n = AppLocalizations.of(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${l10n.errorSaving}: $e'),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isWideScreen = size.width > 900;
    final isMediumScreen = size.width > 600;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context);

    if (_isLoading) {
      return SafeArea(
        child: Column(
          children: [
            AppHeader(
              title: l10n.interestSettingsTitle,
              onMenuTap: isWideScreen
                  ? null
                  : () => Scaffold.of(context).openDrawer(),
              onNotificationsTap: () => context.push('/notifications'),
              notificationsCount: 3,
              userName: l10n.defaultUserName,
              userRole: l10n.branchManager,
            ),
            const Expanded(child: Center(child: CircularProgressIndicator())),
          ],
        ),
      );
    }

    return SafeArea(
      child: Column(
        children: [
          AppHeader(
            title: l10n.interestSettingsTitle,
            onMenuTap: isWideScreen
                ? null
                : () => Scaffold.of(context).openDrawer(),
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
      ),
    );
  }

  Widget _buildContent(bool isDark, AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildPageHeader(isDark, l10n),
        const SizedBox(height: AlhaiSpacing.mdl),
        _buildSettingsGroup(
          l10n.monthlyInterest,
          Icons.trending_up_rounded,
          const Color(0xFFF97316),
          isDark,
          [
            SwitchListTile(
              title: Text(
                l10n.enableInterest,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              subtitle: Text(l10n.enableInterestDesc),
              value: _enableInterest,
              onChanged: (v) => setState(() => _enableInterest = v),
            ),
            if (_enableInterest) ...[
              const Divider(indent: 16, endIndent: 16),
              ListTile(
                title: Text(
                  l10n.monthlyInterestRate,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                subtitle: Text('${_monthlyRate.toStringAsFixed(1)}%'),
                trailing: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width > 600
                        ? 200
                        : 120,
                  ),
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
                title: Text(
                  l10n.maxInterestRateLabel,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                subtitle: Text('${_maxInterestRate.toStringAsFixed(1)}%'),
                trailing: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width > 600
                        ? 200
                        : 120,
                  ),
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
            const SizedBox(height: AlhaiSpacing.xs),
          ],
        ),
        if (_enableInterest)
          _buildSettingsGroup(
            l10n.gracePeriod,
            Icons.schedule_rounded,
            AppColors.info,
            isDark,
            [
              ListTile(
                title: Text(
                  l10n.graceDays,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                subtitle: Text(l10n.graceDaysLabel(_gracePeriodDays)),
                trailing: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width > 600
                        ? 200
                        : 120,
                  ),
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
                title: Text(
                  l10n.compoundInterest,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                subtitle: Text(l10n.compoundInterestDesc),
                value: _compoundInterest,
                onChanged: (v) => setState(() => _compoundInterest = v),
              ),
              const SizedBox(height: AlhaiSpacing.xs),
            ],
          ),
        if (_enableInterest)
          _buildSettingsGroup(
            l10n.calculationAndAlerts,
            Icons.notifications_rounded,
            AppColors.success,
            isDark,
            [
              SwitchListTile(
                title: Text(
                  l10n.autoCalculation,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                subtitle: Text(l10n.autoCalculationDesc),
                value: _autoCalculate,
                onChanged: (v) => setState(() => _autoCalculate = v),
              ),
              SwitchListTile(
                title: Text(
                  l10n.customerNotification,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                subtitle: Text(l10n.customerNotificationDesc),
                value: _notifyCustomer,
                onChanged: (v) => setState(() => _notifyCustomer = v),
              ),
              const SizedBox(height: AlhaiSpacing.xs),
            ],
          ),
        const SizedBox(height: AlhaiSpacing.md),
        SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            onPressed: _isSaving ? null : _saveSettings,
            icon: _isSaving
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Icon(Icons.save_rounded),
            label: Text(l10n.saveSettings),
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: AlhaiSpacing.md),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
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
          icon: Icon(
            Directionality.of(context) == TextDirection.rtl
                ? Icons.arrow_forward_rounded
                : Icons.arrow_back_rounded,
            color: Theme.of(context).colorScheme.onSurface,
          ),
          tooltip: l10n.back,
        ),
        const SizedBox(width: AlhaiSpacing.xs),
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: const Color(0xFFF97316).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(
            Icons.trending_up_rounded,
            color: Color(0xFFF97316),
            size: 24,
          ),
        ),
        const SizedBox(width: AlhaiSpacing.sm),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.interestSettingsTitle,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            Text(
              l10n.interestSettingsSubtitle,
              style: TextStyle(
                fontSize: 13,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSettingsGroup(
    String title,
    IconData icon,
    Color color,
    bool isDark,
    List<Widget> children,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: AlhaiSpacing.md),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(
              AlhaiSpacing.mdl,
              AlhaiSpacing.md,
              AlhaiSpacing.mdl,
              AlhaiSpacing.xs,
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(AlhaiSpacing.xs),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: color, size: 20),
                ),
                const SizedBox(width: AlhaiSpacing.sm),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ),
          ...children,
        ],
      ),
    );
  }
}
