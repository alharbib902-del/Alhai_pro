import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:alhai_shared_ui/alhai_shared_ui.dart';
import 'package:alhai_database/alhai_database.dart';
import 'package:alhai_core/alhai_core.dart';
import 'package:alhai_l10n/alhai_l10n.dart';
import '../../../providers/settings_db_providers.dart';
import 'package:alhai_design_system/alhai_design_system.dart';
import '../../../core/services/sentry_service.dart';

// مفاتيح إعدادات بوابات الشحن
const String _kShippingAramex = 'shipping_aramex_enabled';
const String _kShippingSmsa = 'shipping_smsa_enabled';
const String _kShippingFastlo = 'shipping_fastlo_enabled';
const String _kShippingDhl = 'shipping_dhl_enabled';
const String _kShippingJt = 'shipping_jt_enabled';
const String _kShippingCustom = 'shipping_custom_enabled';

class ShippingGatewaysScreen extends ConsumerStatefulWidget {
  const ShippingGatewaysScreen({super.key});

  @override
  ConsumerState<ShippingGatewaysScreen> createState() =>
      _ShippingGatewaysScreenState();
}

class _ShippingGatewaysScreenState
    extends ConsumerState<ShippingGatewaysScreen> {
  bool _aramexActive = true;
  bool _smsaActive = false;
  bool _fastloActive = false;
  bool _dhlActive = false;
  bool _jtActive = false;
  bool _customActive = true;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  /// تحميل الإعدادات من قاعدة البيانات
  Future<void> _loadSettings() async {
    try {
      final storeId = ref.read(currentStoreIdProvider);
      if (storeId == null) {
        if (mounted) setState(() => _isLoading = false);
        return;
      }

      final db = getIt<AppDatabase>();
      final settings = await getSettingsByPrefix(db, storeId, 'shipping_');

      if (mounted) {
        setState(() {
          _aramexActive = settings[_kShippingAramex] != 'false';
          _smsaActive = settings[_kShippingSmsa] == 'true';
          _fastloActive = settings[_kShippingFastlo] == 'true';
          _dhlActive = settings[_kShippingDhl] == 'true';
          _jtActive = settings[_kShippingJt] == 'true';
          _customActive = settings[_kShippingCustom] != 'false';
          _isLoading = false;
        });
      }
    } catch (e, st) {
      await reportError(
        e,
        stackTrace: st,
        hint: 'shipping_gateways: load settings failed',
      );
      if (mounted) setState(() => _isLoading = false);
    }
  }

  /// حفظ إعداد فردي في قاعدة البيانات مع المزامنة
  Future<void> _saveSingleSetting(String key, String value) async {
    final storeId = ref.read(currentStoreIdProvider);
    if (storeId == null) return;

    final db = getIt<AppDatabase>();
    try {
      await saveSettingWithSync(
        db: db,
        storeId: storeId,
        key: key,
        value: value,
        ref: ref,
      );
    } catch (e, st) {
      await reportError(
        e,
        stackTrace: st,
        hint: 'shipping_gateways: save setting failed for $key',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final size = MediaQuery.of(context).size;
    final isWide = size.width > 900;

    if (_isLoading) {
      return Scaffold(
        body: SafeArea(
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(AlhaiSpacing.md),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  border: Border(
                    bottom: BorderSide(color: Theme.of(context).dividerColor),
                  ),
                ),
                child: Row(
                  children: [
                    if (!isWide)
                      IconButton(
                        icon: const Icon(Icons.menu),
                        onPressed: () => Scaffold.of(context).openDrawer(),
                      ),
                    const Icon(
                      Icons.local_shipping,
                      color: AppColors.primary,
                      size: 28,
                    ),
                    const SizedBox(width: AlhaiSpacing.sm),
                    Text(
                      AppLocalizations.of(context).shippingGatewaysTitle,
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
              ),
              const Expanded(child: Center(child: CircularProgressIndicator())),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(AlhaiSpacing.md),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                border: Border(
                  bottom: BorderSide(color: Theme.of(context).dividerColor),
                ),
              ),
              child: Row(
                children: [
                  if (!isWide)
                    IconButton(
                      icon: const Icon(Icons.menu),
                      onPressed: () => Scaffold.of(context).openDrawer(),
                    ),
                  const Icon(
                    Icons.local_shipping,
                    color: AppColors.primary,
                    size: 28,
                  ),
                  const SizedBox(width: AlhaiSpacing.sm),
                  Text(
                    '\u0628\u0648\u0627\u0628\u0627\u062a \u0627\u0644\u0634\u062d\u0646',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AlhaiSpacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppLocalizations.of(context).availableShippingGateways,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: AlhaiSpacing.xxs),
                    Text(
                      AppLocalizations.of(context).activateShippingGateways,
                      style: TextStyle(
                        fontSize: 13,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: AlhaiSpacing.mdl),
                    _buildGatewayCard(
                      AppLocalizations.of(context).aramexName,
                      'Aramex',
                      AppLocalizations.of(context).aramexDesc,
                      Icons.flight,
                      _aramexActive,
                      const Color(0xFFE44D26),
                      isDark,
                      onToggle: (v) {
                        setState(() => _aramexActive = v);
                        _saveSingleSetting(_kShippingAramex, v.toString());
                      },
                    ),
                    const SizedBox(height: AlhaiSpacing.sm),
                    _buildGatewayCard(
                      'SMSA Express',
                      'SMSA',
                      AppLocalizations.of(context).smsaDesc,
                      Icons.speed,
                      _smsaActive,
                      const Color(0xFF00539F),
                      isDark,
                      onToggle: (v) {
                        setState(() => _smsaActive = v);
                        _saveSingleSetting(_kShippingSmsa, v.toString());
                      },
                    ),
                    const SizedBox(height: AlhaiSpacing.sm),
                    _buildGatewayCard(
                      AppLocalizations.of(context).fastloName,
                      'Fastlo',
                      AppLocalizations.of(context).fastloDesc,
                      Icons.electric_moped,
                      _fastloActive,
                      const Color(0xFF6C63FF),
                      isDark,
                      onToggle: (v) {
                        setState(() => _fastloActive = v);
                        _saveSingleSetting(_kShippingFastlo, v.toString());
                      },
                    ),
                    const SizedBox(height: AlhaiSpacing.sm),
                    _buildGatewayCard(
                      'DHL',
                      'DHL Express',
                      AppLocalizations.of(context).dhlDesc,
                      Icons.public,
                      _dhlActive,
                      isDark
                          ? const Color(0xFFFFCC00).withValues(alpha: 0.8)
                          : const Color(0xFFFFCC00),
                      isDark,
                      onToggle: (v) {
                        setState(() => _dhlActive = v);
                        _saveSingleSetting(_kShippingDhl, v.toString());
                      },
                    ),
                    const SizedBox(height: AlhaiSpacing.sm),
                    _buildGatewayCard(
                      'J&T Express',
                      'J&T Express',
                      AppLocalizations.of(context).jtDesc,
                      Icons.local_shipping,
                      _jtActive,
                      const Color(0xFFE60012),
                      isDark,
                      onToggle: (v) {
                        setState(() => _jtActive = v);
                        _saveSingleSetting(_kShippingJt, v.toString());
                      },
                    ),
                    const SizedBox(height: AlhaiSpacing.sm),
                    _buildGatewayCard(
                      AppLocalizations.of(context).customDeliveryName,
                      'Custom Delivery',
                      AppLocalizations.of(context).customDeliveryDesc,
                      Icons.person_pin_circle,
                      _customActive,
                      Colors.teal,
                      isDark,
                      onToggle: (v) {
                        setState(() => _customActive = v);
                        _saveSingleSetting(_kShippingCustom, v.toString());
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGatewayCard(
    String name,
    String nameEn,
    String description,
    IconData icon,
    bool isActive,
    Color brandColor,
    bool isDark, {
    required ValueChanged<bool> onToggle,
  }) {
    return Container(
      padding: const EdgeInsets.all(AlhaiSpacing.md),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isActive
              ? AppColors.primary.withValues(alpha: 0.3)
              : (Theme.of(context).dividerColor),
        ),
        boxShadow: isActive
            ? [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.05),
                  blurRadius: 10,
                ),
              ]
            : null,
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: brandColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: brandColor, size: 28),
          ),
          const SizedBox(width: AlhaiSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      name,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(width: AlhaiSpacing.xs),
                    Text(
                      nameEn,
                      style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AlhaiSpacing.xxs),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 13,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          Column(
            children: [
              Switch(
                value: isActive,
                onChanged: onToggle,
                activeTrackColor: AppColors.primary.withValues(alpha: 0.5),
                thumbColor: WidgetStateProperty.resolveWith(
                  (states) => states.contains(WidgetState.selected)
                      ? AppColors.primary
                      : null,
                ),
              ),
              if (isActive)
                TextButton(
                  onPressed: () {
                    final apiKeyController = TextEditingController();
                    final accountController = TextEditingController();
                    showDialog(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: Text(
                          AppLocalizations.of(ctx).settingsForName(name),
                        ),
                        content: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            TextField(
                              controller: apiKeyController,
                              obscureText: true,
                              decoration: InputDecoration(
                                labelText: 'API Key',
                                hintText: AppLocalizations.of(ctx).enterApiKey,
                              ),
                            ),
                            const SizedBox(height: AlhaiSpacing.sm),
                            TextField(
                              controller: accountController,
                              decoration: InputDecoration(
                                labelText: AppLocalizations.of(
                                  ctx,
                                ).accountNumber,
                                hintText: AppLocalizations.of(
                                  ctx,
                                ).accountNumber,
                              ),
                            ),
                          ],
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(ctx),
                            child: Text(AppLocalizations.of(ctx).cancel),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              Navigator.pop(ctx);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    AppLocalizations.of(
                                      context,
                                    ).settingsSavedForName(name),
                                  ),
                                ),
                              );
                            },
                            child: Text(AppLocalizations.of(ctx).save),
                          ),
                        ],
                      ),
                    );
                  },
                  child: Text(
                    AppLocalizations.of(context).settingsAction,
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
