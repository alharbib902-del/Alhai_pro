import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:alhai_shared_ui/alhai_shared_ui.dart';
import 'package:alhai_l10n/alhai_l10n.dart';
import 'package:alhai_database/alhai_database.dart';
import 'package:drift/drift.dart' hide Column;
import 'package:alhai_core/alhai_core.dart';
import 'package:alhai_design_system/alhai_design_system.dart';

/// E-commerce management screen with tabs for online orders, product sync, and settings.
class EcommerceScreen extends ConsumerStatefulWidget {
  const EcommerceScreen({super.key});

  @override
  ConsumerState<EcommerceScreen> createState() => _EcommerceScreenState();
}

class _EcommerceScreenState extends ConsumerState<EcommerceScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = true;
  String? _error;
  List<ProductsTableData> _products = [];
  Map<String, String> _ecomSettings = {};

  // Cached counts - updated when _products changes
  int _onlineCount = 0;
  int _activeCount = 0;

  // Settings tab controllers - class-level to avoid memory leak
  late final TextEditingController _minOrderController;
  late final TextEditingController _deliveryFeeController;
  late final TextEditingController _freeShippingLimitController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _minOrderController = TextEditingController(text: '50');
    _deliveryFeeController = TextEditingController(text: '15');
    _freeShippingLimitController = TextEditingController(text: '200');
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _minOrderController.dispose();
    _deliveryFeeController.dispose();
    _freeShippingLimitController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final db = getIt<AppDatabase>();
      final storeId = ref.read(currentStoreIdProvider);
      if (storeId == null) {
        setState(() {
          _isLoading = false;
          _error = 'No store selected';
        });
        return;
      }
      final products = await db.productsDao.getAllProducts(storeId);
      final settingsRows = await (db.select(
        db.settingsTable,
      )..where((s) => s.storeId.equals(storeId) & s.key.like('ecom_%'))).get();
      final settings = <String, String>{};
      for (final row in settingsRows) {
        settings[row.key] = row.value;
      }
      if (mounted) {
        setState(() {
          _products = products;
          _ecomSettings = settings;
          _onlineCount = _products.where((p) => _isProductOnline(p.id)).length;
          _activeCount = _products.where((p) => p.isActive).length;
          _minOrderController.text = settings['ecom_min_order'] ?? '50';
          _deliveryFeeController.text = settings['ecom_delivery_fee'] ?? '15';
          _freeShippingLimitController.text =
              settings['ecom_free_shipping_limit'] ?? '200';
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _error = 'Error loading data: $e';
        });
      }
    }
  }

  bool _isProductOnline(String productId) {
    final key = 'ecom_product_${productId}_online';
    return _ecomSettings[key] == 'true';
  }

  Future<void> _toggleOnlineAvailability(
    String productId,
    bool newValue,
  ) async {
    try {
      final db = getIt<AppDatabase>();
      final storeId = ref.read(currentStoreIdProvider);
      if (storeId == null) return;

      final key = 'ecom_product_${productId}_online';
      await db
          .into(db.settingsTable)
          .insertOnConflictUpdate(
            SettingsTableCompanion.insert(
              id: '${storeId}_$key',
              storeId: storeId,
              key: key,
              value: newValue.toString(),
              updatedAt: DateTime.now(),
            ),
          );
      setState(() {
        _ecomSettings[key] = newValue.toString();
        _onlineCount = _products.where((p) => _isProductOnline(p.id)).length;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.errorWithDetails('$e'))));
      }
    }
  }

  Future<void> _saveEcomSetting(String key, String value) async {
    try {
      final db = getIt<AppDatabase>();
      final storeId = ref.read(currentStoreIdProvider);
      if (storeId == null) return;

      await db
          .into(db.settingsTable)
          .insertOnConflictUpdate(
            SettingsTableCompanion.insert(
              id: '${storeId}_$key',
              storeId: storeId,
              key: key,
              value: value,
              updatedAt: DateTime.now(),
            ),
          );
      setState(() {
        _ecomSettings[key] = value;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.errorWithDetails('$e'))));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final size = MediaQuery.of(context).size;
    final isWide = size.width > 900;
    final l10n = AppLocalizations.of(context);

    return Column(
      children: [
        AppHeader(
          title: l10n.ecommerce,
          onMenuTap: isWide ? null : () => Scaffold.of(context).openDrawer(),
          onNotificationsTap: () => context.push('/notifications'),
          notificationsCount: 0,
          userName: l10n.defaultUserName,
          userRole: l10n.branchManager,
          actions: [_buildStatusChip(isDark, l10n)],
        ),
        Container(
          color: Theme.of(context).colorScheme.surface,
          child: TabBar(
            controller: _tabController,
            labelColor: AppColors.primary,
            unselectedLabelColor: Theme.of(
              context,
            ).colorScheme.onSurfaceVariant,
            indicatorColor: AppColors.primary,
            tabs: [
              Tab(
                icon: const Icon(Icons.shopping_bag_outlined),
                text: l10n.products,
              ),
              Tab(
                icon: const Icon(Icons.article_outlined),
                text: l10n.ecommerceSection,
              ),
              Tab(
                icon: const Icon(Icons.settings_outlined),
                text: l10n.settings,
              ),
            ],
          ),
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildProductsCatalogTab(isDark, l10n),
              _buildOnlineOrdersTab(isDark, l10n),
              _buildSettingsTab(isDark, l10n),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatusChip(bool isDark, AppLocalizations l10n) {
    final isEnabled = _ecomSettings['ecom_store_enabled'] == 'true';
    final chipColor = isEnabled ? AppColors.success : AppColors.textSecondary;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: chipColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: chipColor.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.circle, color: chipColor, size: 8),
          const SizedBox(width: 6),
          Text(
            isEnabled ? l10n.active : l10n.inactive,
            style: TextStyle(
              color: chipColor,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  // ─── Products Catalog Tab ──────────────────────────────────────

  Widget _buildProductsCatalogTab(bool isDark, AppLocalizations l10n) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return _buildErrorState(isDark, l10n);
    }
    if (_products.isEmpty) {
      return _buildEmptyState(
        isDark,
        Icons.inventory_2_outlined,
        l10n.noData,
        l10n.addProductsToStart,
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AlhaiSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Stats cards
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _buildStatCard(
                l10n.products,
                '${_products.length}',
                Icons.shopping_bag,
                AppColors.info,
                isDark,
              ),
              _buildStatCard(
                'Online',
                '$_onlineCount',
                Icons.cloud_done,
                AppColors.success,
                isDark,
              ),
              _buildStatCard(
                l10n.active,
                '$_activeCount',
                Icons.check_circle,
                Colors.teal, // specific status color
                isDark,
              ),
              _buildStatCard(
                l10n.inactive,
                '${_products.length - _onlineCount}',
                Icons.cloud_off,
                AppColors.warning,
                isDark,
              ),
            ],
          ),
          const SizedBox(height: AlhaiSpacing.lg),
          Text(
            l10n.products,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: AlhaiSpacing.md),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _products.length,
            separatorBuilder: (_, __) =>
                const SizedBox(height: AlhaiSpacing.xs),
            itemBuilder: (context, index) {
              final product = _products[index];
              return _buildProductCard(product, isDark);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildProductCard(ProductsTableData product, bool isDark) {
    final isOnline = _isProductOnline(product.id);
    return Container(
      padding: const EdgeInsets.all(AlhaiSpacing.sm),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: isDark
                  ? Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: 0.05)
                  : AppColors.border.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(10),
            ),
            child: product.imageThumbnail != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: CachedNetworkImage(
                      imageUrl: product.imageThumbnail!,
                      fit: BoxFit.cover,
                      placeholder: (_, __) =>
                          const Center(child: CircularProgressIndicator()),
                      errorWidget: (_, __, ___) => Icon(
                        Icons.image_not_supported_outlined,
                        color: isDark
                            ? Theme.of(
                                context,
                              ).colorScheme.onSurface.withValues(alpha: 0.24)
                            : AppColors.textTertiary,
                      ),
                    ),
                  )
                : Icon(
                    Icons.inventory_2_outlined,
                    color: isDark
                        ? Theme.of(
                            context,
                          ).colorScheme.onSurface.withValues(alpha: 0.24)
                        : AppColors.textTertiary,
                  ),
          ),
          const SizedBox(width: AlhaiSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: AlhaiSpacing.xxs),
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: [
                    Text(
                      product.price.toStringAsFixed(2),
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: product.stockQty > 0
                            ? AppColors.success.withValues(alpha: 0.1)
                            : AppColors.error.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        '${product.stockQty}',
                        style: TextStyle(
                          fontSize: 11,
                          color: product.stockQty > 0
                              ? AppColors.success
                              : AppColors.error,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    if (!product.isActive)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.warning.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          l10n.inactive,
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppColors.warning,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
          Column(
            children: [
              Text(
                'Online',
                style: TextStyle(
                  fontSize: 11,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              Switch(
                value: isOnline,
                onChanged: (val) => _toggleOnlineAvailability(product.id, val),
                activeTrackColor: AppColors.primary,
                activeThumbColor: Theme.of(context).colorScheme.onPrimary,
              ),
            ],
          ),
        ],
      ),
    );
  }

  AppLocalizations get l10n => AppLocalizations.of(context);

  // ─── Online Orders Tab ─────────────────────────────────────────

  Widget _buildOnlineOrdersTab(bool isDark, AppLocalizations l10n) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return _buildErrorState(isDark, l10n);
    }

    // Simulated online orders from product data; in production, use ordersDao
    final onlineProducts = _products
        .where((p) => _isProductOnline(p.id))
        .toList();

    if (onlineProducts.isEmpty) {
      return _buildEmptyState(
        isDark,
        Icons.shopping_cart_outlined,
        l10n.noData,
        l10n.addProductsToStart,
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AlhaiSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.ecommerceSection,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: AlhaiSpacing.md),
          _buildContentCard(
            'Banners',
            'Manage homepage banners and promotions',
            Icons.image_outlined,
            isDark,
          ),
          const SizedBox(height: AlhaiSpacing.sm),
          _buildContentCard(
            'Pages',
            'Create and edit store pages (About, Privacy, ...)',
            Icons.description_outlined,
            isDark,
          ),
          const SizedBox(height: AlhaiSpacing.sm),
          _buildContentCard(
            'Themes',
            'Customize online store appearance',
            Icons.palette_outlined,
            isDark,
          ),
          const SizedBox(height: AlhaiSpacing.sm),
          _buildContentCard(
            'Navigation',
            'Manage store navigation menus',
            Icons.menu_outlined,
            isDark,
          ),
          const SizedBox(height: AlhaiSpacing.sm),
          _buildContentCard(
            'Categories',
            'Choose categories displayed on homepage',
            Icons.category_outlined,
            isDark,
          ),
        ],
      ),
    );
  }

  // ─── Settings Tab ──────────────────────────────────────────────

  Widget _buildSettingsTab(bool isDark, AppLocalizations l10n) {
    final storeEnabled = _ecomSettings['ecom_store_enabled'] == 'true';
    final notificationsEnabled =
        _ecomSettings['ecom_notifications_enabled'] == 'true';
    final codEnabled = _ecomSettings['ecom_cod_enabled'] == 'true';
    final freeShippingEnabled =
        _ecomSettings['ecom_free_shipping_enabled'] == 'true';

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AlhaiSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.settings,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: AlhaiSpacing.md),
          _buildSettingTile(
            l10n.ecommerce,
            'Enable online purchasing',
            Icons.store_outlined,
            storeEnabled,
            isDark,
            (val) => _saveEcomSetting('ecom_store_enabled', val.toString()),
          ),
          _buildSettingTile(
            'Order Notifications',
            'Receive notifications for new orders',
            Icons.notifications_outlined,
            notificationsEnabled,
            isDark,
            (val) =>
                _saveEcomSetting('ecom_notifications_enabled', val.toString()),
          ),
          _buildSettingTile(
            'Cash on Delivery',
            'Allow cash payment on delivery',
            Icons.payments_outlined,
            codEnabled,
            isDark,
            (val) => _saveEcomSetting('ecom_cod_enabled', val.toString()),
          ),
          _buildSettingTile(
            'Free Shipping',
            'Enable free shipping above threshold',
            Icons.local_shipping_outlined,
            freeShippingEnabled,
            isDark,
            (val) =>
                _saveEcomSetting('ecom_free_shipping_enabled', val.toString()),
          ),
          const SizedBox(height: AlhaiSpacing.lg),
          Text(
            'Delivery Settings',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: AlhaiSpacing.sm),
          _buildInputField('Min Order Amount', _minOrderController, isDark),
          const SizedBox(height: AlhaiSpacing.sm),
          _buildInputField('Delivery Fee', _deliveryFeeController, isDark),
          const SizedBox(height: AlhaiSpacing.sm),
          _buildInputField(
            'Free Shipping Limit',
            _freeShippingLimitController,
            isDark,
          ),
          const SizedBox(height: AlhaiSpacing.md),
          // Delivery Zones Link
          Card(
            child: ListTile(
              leading: const Icon(Icons.map_rounded, color: AppColors.primary),
              title: Text(AppLocalizations.of(context).deliveryZones),
              subtitle: Text(
                AppLocalizations.of(context).manageDeliveryZonesAndPricing,
              ),
              trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
              onTap: () => context.push('/ecommerce/delivery-zones'),
            ),
          ),
          const SizedBox(height: AlhaiSpacing.lg),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () async {
                await _saveEcomSetting(
                  'ecom_min_order',
                  _minOrderController.text,
                );
                await _saveEcomSetting(
                  'ecom_delivery_fee',
                  _deliveryFeeController.text,
                );
                await _saveEcomSetting(
                  'ecom_free_shipping_limit',
                  _freeShippingLimitController.text,
                );
                if (mounted) {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text(l10n.settingsSaved)));
                }
              },
              icon: const Icon(Icons.save),
              label: const Text('Save Settings'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Theme.of(context).colorScheme.onPrimary,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Shared Helper Widgets ─────────────────────────────────────

  Widget _buildErrorState(bool isDark, AppLocalizations l10n) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: AppColors.error.withValues(alpha: 0.7),
          ),
          const SizedBox(height: AlhaiSpacing.md),
          Text(
            _error!,
            style: TextStyle(
              fontSize: 16,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AlhaiSpacing.md),
          FilledButton.icon(
            onPressed: _loadData,
            icon: const Icon(Icons.refresh),
            label: Text(l10n.retry),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(
    bool isDark,
    IconData icon,
    String title,
    String subtitle,
  ) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(60),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 80,
              color: isDark
                  ? Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: 0.24)
                  : AppColors.textTertiary,
            ),
            const SizedBox(height: AlhaiSpacing.md),
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: AlhaiSpacing.xs),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 13,
                color: isDark
                    ? Theme.of(
                        context,
                      ).colorScheme.onSurface.withValues(alpha: 0.38)
                    : AppColors.textTertiary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
    bool isDark,
  ) {
    return Container(
      width: 180,
      padding: const EdgeInsets.all(AlhaiSpacing.md),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: AlhaiSpacing.sm),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: AlhaiSpacing.xxs),
          Text(
            title,
            style: TextStyle(
              fontSize: 13,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContentCard(
    String title,
    String subtitle,
    IconData icon,
    bool isDark,
  ) {
    return Container(
      padding: const EdgeInsets.all(AlhaiSpacing.md),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: AppColors.primary),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            fontSize: 12,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        trailing: Icon(
          Directionality.of(context) == TextDirection.rtl
              ? Icons.chevron_left_rounded
              : Icons.chevron_right_rounded,
          size: 16,
          color: Theme.of(
            context,
          ).colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
        ),
      ),
    );
  }

  Widget _buildSettingTile(
    String title,
    String subtitle,
    IconData icon,
    bool value,
    bool isDark,
    ValueChanged<bool> onChanged,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: AlhaiSpacing.xs),
      padding: const EdgeInsets.all(AlhaiSpacing.sm),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        leading: Icon(icon, color: AppColors.primary),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.w500,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            fontSize: 12,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        trailing: Switch(
          value: value,
          onChanged: onChanged,
          activeTrackColor: AppColors.primary,
          activeThumbColor: Theme.of(context).colorScheme.onPrimary,
        ),
      ),
    );
  }

  Widget _buildInputField(
    String label,
    TextEditingController controller,
    bool isDark,
  ) {
    return TextField(
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: isDark
            ? Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.05)
            : AppColors.border.withValues(alpha: 0.2),
      ),
      controller: controller,
      keyboardType: TextInputType.number,
    );
  }
}
