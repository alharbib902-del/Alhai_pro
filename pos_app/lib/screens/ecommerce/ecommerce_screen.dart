import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../data/local/app_database.dart';
import '../../di/injection.dart';
import '../../providers/products_providers.dart';
import '../../providers/settings_db_providers.dart';

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

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
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
          _error = 'لم يتم تحديد المتجر';
        });
        return;
      }
      final products = await db.productsDao.getAllProducts(storeId);
      final settings = await getSettingsByPrefix(db, storeId, 'ecom_');
      if (mounted) {
        setState(() {
          _products = products;
          _ecomSettings = settings;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _error = 'حدث خطأ أثناء تحميل البيانات: $e';
        });
      }
    }
  }

  Future<void> _toggleOnlineAvailability(String productId, bool newValue) async {
    try {
      final db = getIt<AppDatabase>();
      final storeId = ref.read(currentStoreIdProvider);
      if (storeId == null) return;

      final key = 'ecom_product_${productId}_online';
      await saveSettingWithSync(
        db: db,
        storeId: storeId,
        key: key,
        value: newValue.toString(),
        ref: ref,
      );
      setState(() {
        _ecomSettings[key] = newValue.toString();
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('حدث خطأ أثناء تحديث الإعداد: $e')),
        );
      }
    }
  }

  Future<void> _saveEcomSetting(String key, String value) async {
    try {
      final db = getIt<AppDatabase>();
      final storeId = ref.read(currentStoreIdProvider);
      if (storeId == null) return;

      await saveSettingWithSync(
        db: db,
        storeId: storeId,
        key: key,
        value: value,
        ref: ref,
      );
      setState(() {
        _ecomSettings[key] = value;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تم حفظ الإعدادات بنجاح')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('حدث خطأ أثناء حفظ الإعدادات: $e')),
        );
      }
    }
  }

  bool _isProductOnline(String productId) {
    final key = 'ecom_product_${productId}_online';
    return _ecomSettings[key] == 'true';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final size = MediaQuery.of(context).size;
    final isWide = size.width > 900;

    return Scaffold(
      body: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E1E2E) : Colors.white,
              border: Border(
                bottom: BorderSide(
                  color: isDark ? Colors.white12 : Colors.grey.shade200,
                ),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    if (!isWide)
                      IconButton(
                        icon: const Icon(Icons.menu),
                        onPressed: () => Scaffold.of(context).openDrawer(),
                      ),
                    const Icon(Icons.store, color: AppColors.primary, size: 28),
                    const SizedBox(width: 12),
                    Text(
                      'المتجر الإلكتروني',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                    const Spacer(),
                    _buildStatusChip(isDark),
                  ],
                ),
                const SizedBox(height: 16),
                TabBar(
                  controller: _tabController,
                  labelColor: AppColors.primary,
                  unselectedLabelColor: isDark ? Colors.white54 : Colors.grey,
                  indicatorColor: AppColors.primary,
                  tabs: const [
                    Tab(icon: Icon(Icons.shopping_bag_outlined), text: 'المنتجات'),
                    Tab(icon: Icon(Icons.article_outlined), text: 'المحتوى'),
                    Tab(
                      icon: Icon(Icons.settings_outlined),
                      text: 'الإعدادات',
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Body
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildProductsCatalogTab(isDark),
                _buildContentTab(isDark),
                _buildSettingsTab(isDark),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(bool isDark) {
    final isEnabled = _ecomSettings['ecom_store_enabled'] == 'true';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: (isEnabled ? Colors.green : Colors.grey).withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: (isEnabled ? Colors.green : Colors.grey).withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.circle, color: isEnabled ? Colors.green : Colors.grey, size: 8),
          const SizedBox(width: 6),
          Text(
            isEnabled ? 'مفعّل' : 'معطّل',
            style: TextStyle(
              color: isEnabled ? Colors.green : Colors.grey,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductsCatalogTab(bool isDark) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red.shade300),
            const SizedBox(height: 16),
            Text(
              _error!,
              style: TextStyle(fontSize: 16, color: isDark ? Colors.white54 : Colors.grey),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _loadData,
              icon: const Icon(Icons.refresh),
              label: const Text('إعادة المحاولة'),
            ),
          ],
        ),
      );
    }

    if (_products.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(60),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.inventory_2_outlined,
                size: 80,
                color: isDark ? Colors.white24 : Colors.grey.shade300,
              ),
              const SizedBox(height: 16),
              Text(
                'لا توجد منتجات حالياً',
                style: TextStyle(
                  fontSize: 16,
                  color: isDark ? Colors.white54 : Colors.grey,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'أضف منتجات من شاشة المنتجات لعرضها في المتجر الإلكتروني',
                style: TextStyle(
                  fontSize: 13,
                  color: isDark ? Colors.white38 : Colors.grey.shade400,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    final onlineCount = _products.where((p) => _isProductOnline(p.id)).length;
    final activeCount = _products.where((p) => p.isActive).length;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Stats cards
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _buildStatCard(
                'إجمالي المنتجات',
                '${_products.length}',
                Icons.shopping_bag,
                Colors.blue,
                isDark,
              ),
              _buildStatCard(
                'معروضة أونلاين',
                '$onlineCount',
                Icons.cloud_done,
                Colors.green,
                isDark,
              ),
              _buildStatCard(
                'نشطة',
                '$activeCount',
                Icons.check_circle,
                Colors.teal,
                isDark,
              ),
              _buildStatCard(
                'غير متاحة',
                '${_products.length - onlineCount}',
                Icons.cloud_off,
                Colors.orange,
                isDark,
              ),
            ],
          ),
          const SizedBox(height: 24),
          // Products grid
          Text(
            'كتالوج المنتجات',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _products.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
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
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E2E) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? Colors.white12 : Colors.grey.shade200,
        ),
      ),
      child: Row(
        children: [
          // Product image
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: isDark ? Colors.white.withOpacity(0.05) : Colors.grey.shade100,
              borderRadius: BorderRadius.circular(10),
            ),
            child: product.imageThumbnail != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.network(
                      product.imageThumbnail!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Icon(
                        Icons.image_not_supported_outlined,
                        color: isDark ? Colors.white24 : Colors.grey.shade400,
                      ),
                    ),
                  )
                : Icon(
                    Icons.inventory_2_outlined,
                    color: isDark ? Colors.white24 : Colors.grey.shade400,
                  ),
          ),
          const SizedBox(width: 12),
          // Product info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      '${product.price.toStringAsFixed(2)} ر.س',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: product.stockQty > 0
                            ? Colors.green.withOpacity(0.1)
                            : Colors.red.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        'المخزون: ${product.stockQty}',
                        style: TextStyle(
                          fontSize: 11,
                          color: product.stockQty > 0 ? Colors.green : Colors.red,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    if (!product.isActive)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.orange.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text(
                          'غير نشط',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.orange,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
          // Online toggle
          Column(
            children: [
              Text(
                'أونلاين',
                style: TextStyle(
                  fontSize: 11,
                  color: isDark ? Colors.white54 : Colors.grey,
                ),
              ),
              Switch(
                value: isOnline,
                onChanged: (val) => _toggleOnlineAvailability(product.id, val),
                activeColor: AppColors.primary,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildContentTab(bool isDark) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'إدارة المحتوى',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          // Content management cards
          _buildContentCard(
            'البانرات الإعلانية',
            'إدارة الصور والإعلانات في الصفحة الرئيسية',
            Icons.image_outlined,
            isDark,
          ),
          const SizedBox(height: 12),
          _buildContentCard(
            'الصفحات',
            'إنشاء وتعديل صفحات المتجر (من نحن، سياسة الخصوصية...)',
            Icons.description_outlined,
            isDark,
          ),
          const SizedBox(height: 12),
          _buildContentCard(
            'الثيمات',
            'تخصيص مظهر المتجر الإلكتروني',
            Icons.palette_outlined,
            isDark,
          ),
          const SizedBox(height: 12),
          _buildContentCard(
            'القوائم',
            'إدارة قوائم التنقل في المتجر',
            Icons.menu_outlined,
            isDark,
          ),
          const SizedBox(height: 12),
          _buildContentCard(
            'التصنيفات المعروضة',
            'اختيار التصنيفات التي تظهر في الصفحة الرئيسية',
            Icons.category_outlined,
            isDark,
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsTab(bool isDark) {
    final storeEnabled = _ecomSettings['ecom_store_enabled'] == 'true';
    final notificationsEnabled = _ecomSettings['ecom_notifications_enabled'] == 'true';
    final codEnabled = _ecomSettings['ecom_cod_enabled'] == 'true';
    final freeShippingEnabled = _ecomSettings['ecom_free_shipping_enabled'] == 'true';

    final minOrderController = TextEditingController(
      text: _ecomSettings['ecom_min_order'] ?? '50',
    );
    final deliveryFeeController = TextEditingController(
      text: _ecomSettings['ecom_delivery_fee'] ?? '15',
    );
    final freeShippingLimitController = TextEditingController(
      text: _ecomSettings['ecom_free_shipping_limit'] ?? '200',
    );

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'إعدادات المتجر الإلكتروني',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          _buildSettingTile(
            'تفعيل المتجر الإلكتروني',
            'السماح للعملاء بالشراء أونلاين',
            Icons.store_outlined,
            storeEnabled,
            isDark,
            (val) => _saveEcomSetting('ecom_store_enabled', val.toString()),
          ),
          _buildSettingTile(
            'إشعارات الطلبات',
            'تلقي إشعار عند وصول طلب جديد',
            Icons.notifications_outlined,
            notificationsEnabled,
            isDark,
            (val) => _saveEcomSetting('ecom_notifications_enabled', val.toString()),
          ),
          _buildSettingTile(
            'الدفع عند الاستلام',
            'السماح بالدفع نقداً عند التوصيل',
            Icons.payments_outlined,
            codEnabled,
            isDark,
            (val) => _saveEcomSetting('ecom_cod_enabled', val.toString()),
          ),
          _buildSettingTile(
            'التوصيل المجاني',
            'تفعيل التوصيل المجاني للطلبات فوق حد معين',
            Icons.local_shipping_outlined,
            freeShippingEnabled,
            isDark,
            (val) => _saveEcomSetting('ecom_free_shipping_enabled', val.toString()),
          ),
          const SizedBox(height: 24),
          Text(
            'إعدادات التوصيل',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          _buildInputField('الحد الأدنى للطلب', minOrderController, 'ر.س', isDark),
          const SizedBox(height: 12),
          _buildInputField('رسوم التوصيل', deliveryFeeController, 'ر.س', isDark),
          const SizedBox(height: 12),
          _buildInputField('حد التوصيل المجاني', freeShippingLimitController, 'ر.س', isDark),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () async {
                await _saveEcomSetting('ecom_min_order', minOrderController.text);
                await _saveEcomSetting('ecom_delivery_fee', deliveryFeeController.text);
                await _saveEcomSetting('ecom_free_shipping_limit', freeShippingLimitController.text);
              },
              icon: const Icon(Icons.save),
              label: const Text('حفظ الإعدادات'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
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

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
    bool isDark,
  ) {
    return Container(
      width: 180,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E2E) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? Colors.white12 : Colors.grey.shade200,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 13,
              color: isDark ? Colors.white54 : Colors.grey,
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
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E2E) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? Colors.white12 : Colors.grey.shade200,
        ),
      ),
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: AppColors.primary),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            fontSize: 12,
            color: isDark ? Colors.white54 : Colors.grey,
          ),
        ),
        trailing: Icon(
          Icons.arrow_forward_ios,
          size: 16,
          color: isDark ? Colors.white38 : Colors.grey,
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
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E2E) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? Colors.white12 : Colors.grey.shade200,
        ),
      ),
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        leading: Icon(icon, color: AppColors.primary),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.w500,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            fontSize: 12,
            color: isDark ? Colors.white54 : Colors.grey,
          ),
        ),
        trailing: Switch(
          value: value,
          onChanged: onChanged,
          activeColor: AppColors.primary,
        ),
      ),
    );
  }

  Widget _buildInputField(
    String label,
    TextEditingController controller,
    String suffix,
    bool isDark,
  ) {
    return TextField(
      decoration: InputDecoration(
        labelText: label,
        suffixText: suffix,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        filled: true,
        fillColor:
            isDark ? Colors.white.withOpacity(0.05) : Colors.grey.shade50,
      ),
      controller: controller,
      keyboardType: TextInputType.number,
    );
  }
}
