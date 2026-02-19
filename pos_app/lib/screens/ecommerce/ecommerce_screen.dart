import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';

class EcommerceScreen extends ConsumerStatefulWidget {
  const EcommerceScreen({super.key});
  @override
  ConsumerState<EcommerceScreen> createState() => _EcommerceScreenState();
}

class _EcommerceScreenState extends ConsumerState<EcommerceScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
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
                    Tab(icon: Icon(Icons.shopping_bag_outlined), text: 'الطلبات'),
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
                _buildOrdersTab(isDark),
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
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.green.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.green.withOpacity(0.3)),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.circle, color: Colors.green, size: 8),
          SizedBox(width: 6),
          Text(
            'مفعّل',
            style: TextStyle(
              color: Colors.green,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrdersTab(bool isDark) {
    // Build stats row + orders table
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
                'إجمالي الطلبات',
                '0',
                Icons.shopping_bag,
                Colors.blue,
                isDark,
              ),
              _buildStatCard(
                'قيد التنفيذ',
                '0',
                Icons.hourglass_empty,
                Colors.orange,
                isDark,
              ),
              _buildStatCard(
                'مكتملة',
                '0',
                Icons.check_circle,
                Colors.green,
                isDark,
              ),
              _buildStatCard(
                'ملغية',
                '0',
                Icons.cancel,
                Colors.red,
                isDark,
              ),
            ],
          ),
          const SizedBox(height: 24),
          // Search bar
          TextField(
            decoration: InputDecoration(
              hintText: 'بحث عن طلب...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
              fillColor:
                  isDark ? Colors.white.withOpacity(0.05) : Colors.grey.shade50,
            ),
          ),
          const SizedBox(height: 16),
          // Empty state
          Center(
            child: Padding(
              padding: const EdgeInsets.all(60),
              child: Column(
                children: [
                  Icon(
                    Icons.inbox_outlined,
                    size: 80,
                    color: isDark ? Colors.white24 : Colors.grey.shade300,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'لا توجد طلبات حالياً',
                    style: TextStyle(
                      fontSize: 16,
                      color: isDark ? Colors.white54 : Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'ستظهر الطلبات هنا عندما يقوم العملاء بالشراء',
                    style: TextStyle(
                      fontSize: 13,
                      color:
                          isDark ? Colors.white38 : Colors.grey.shade400,
                    ),
                  ),
                ],
              ),
            ),
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
            true,
            isDark,
          ),
          _buildSettingTile(
            'إشعارات الطلبات',
            'تلقي إشعار عند وصول طلب جديد',
            Icons.notifications_outlined,
            true,
            isDark,
          ),
          _buildSettingTile(
            'الدفع عند الاستلام',
            'السماح بالدفع نقداً عند التوصيل',
            Icons.payments_outlined,
            false,
            isDark,
          ),
          _buildSettingTile(
            'التوصيل المجاني',
            'تفعيل التوصيل المجاني للطلبات فوق حد معين',
            Icons.local_shipping_outlined,
            false,
            isDark,
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
          _buildInputField('الحد الأدنى للطلب', '50', 'ر.س', isDark),
          const SizedBox(height: 12),
          _buildInputField('رسوم التوصيل', '15', 'ر.س', isDark),
          const SizedBox(height: 12),
          _buildInputField('حد التوصيل المجاني', '200', 'ر.س', isDark),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {},
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
          onChanged: (_) {},
          activeColor: AppColors.primary,
        ),
      ),
    );
  }

  Widget _buildInputField(
    String label,
    String defaultVal,
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
      controller: TextEditingController(text: defaultVal),
      keyboardType: TextInputType.number,
    );
  }
}
