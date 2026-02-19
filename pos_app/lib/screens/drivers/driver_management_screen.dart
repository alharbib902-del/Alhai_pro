import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../widgets/layout/app_sidebar.dart';
import '../../widgets/layout/app_header.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../core/theme/app_colors.dart';
import '../../core/router/routes.dart';

/// شاشة إدارة السائقين
class DriverManagementScreen extends ConsumerStatefulWidget {
  const DriverManagementScreen({super.key});

  @override
  ConsumerState<DriverManagementScreen> createState() => _DriverManagementScreenState();
}

class _DriverManagementScreenState extends ConsumerState<DriverManagementScreen> {
  bool _sidebarCollapsed = false;
  String _selectedNavId = 'employees';

  final List<_Driver> _drivers = [
    _Driver(id: '1', name: 'سعد محمد', phone: '0501234567', vehicle: 'هايلكس - أبيض', plateNumber: 'أ ب ج 1234', status: 'active', todayDeliveries: 12, totalDeliveries: 450, rating: 4.8),
    _Driver(id: '2', name: 'فهد عبدالله', phone: '0551234567', vehicle: 'دباب - أزرق', plateNumber: 'س ع د 5678', status: 'delivering', todayDeliveries: 8, totalDeliveries: 320, rating: 4.6),
    _Driver(id: '3', name: 'خالد عمر', phone: '0561234567', vehicle: 'ستارا - رمادي', plateNumber: 'م ن و 9012', status: 'offline', todayDeliveries: 0, totalDeliveries: 185, rating: 4.5),
  ];

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
              userName: 'أحمد محمد', // TODO: localize
              userRole: l10n.branchManager,
              onUserTap: () {},
            ),
          Expanded(
            child: Column(
              children: [
                AppHeader(
                  title: 'إدارة السائقين', // TODO: localize
                  onMenuTap: isWideScreen
                      ? () => setState(() => _sidebarCollapsed = !_sidebarCollapsed)
                      : () => Scaffold.of(context).openDrawer(),
                  onNotificationsTap: () => context.push('/notifications'),
                  notificationsCount: 3,
                  userName: 'أحمد محمد', // TODO: localize
                  userRole: l10n.branchManager,
                  actions: [
                    IconButton(
                      icon: Icon(Icons.map, color: isDark ? Colors.white70 : AppColors.textSecondary),
                      tooltip: 'خريطة التتبع', // TODO: localize
                      onPressed: _showTrackingMap,
                    ),
                    const SizedBox(width: 8),
                    FilledButton.icon(
                      onPressed: _addDriver,
                      icon: const Icon(Icons.person_add, size: 18),
                      label: const Text('إضافة سائق'), // TODO: localize
                    ),
                  ],
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

  Widget _buildContent(bool isWideScreen, bool isMediumScreen, bool isDark, AppLocalizations l10n) {
    final activeCount = _drivers.where((d) => d.status == 'active').length;
    final deliveringCount = _drivers.where((d) => d.status == 'delivering').length;
    final todayTotal = _drivers.fold(0, (sum, d) => sum + d.todayDeliveries);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Stats row
        Row(
          children: [
            Expanded(child: _buildStatCard(icon: Icons.people, label: 'إجمالي', value: '${_drivers.length}', color: AppColors.info, isDark: isDark)), // TODO: localize
            const SizedBox(width: 12),
            Expanded(child: _buildStatCard(icon: Icons.check_circle, label: 'متاح', value: '$activeCount', color: AppColors.success, isDark: isDark)), // TODO: localize
            const SizedBox(width: 12),
            Expanded(child: _buildStatCard(icon: Icons.delivery_dining, label: 'في توصيل', value: '$deliveringCount', color: AppColors.warning, isDark: isDark)), // TODO: localize
            const SizedBox(width: 12),
            Expanded(child: _buildStatCard(icon: Icons.local_shipping, label: 'توصيلات اليوم', value: '$todayTotal', color: const Color(0xFF8B5CF6), isDark: isDark)), // TODO: localize
          ],
        ),
        const SizedBox(height: 16),

        // Drivers list
        ...List.generate(_drivers.length, (index) {
          final driver = _drivers[index];
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E293B) : Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: isDark ? Colors.white.withValues(alpha: 0.1) : AppColors.border),
            ),
            child: InkWell(
              onTap: () => _showDriverDetails(driver),
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Stack(
                      children: [
                        CircleAvatar(
                          radius: 28,
                          backgroundColor: AppColors.info.withValues(alpha: 0.1),
                          child: Text(
                            driver.name[0],
                            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.info),
                          ),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            width: 16,
                            height: 16,
                            decoration: BoxDecoration(
                              color: _getStatusColor(driver.status),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: isDark ? const Color(0xFF1E293B) : Colors.white,
                                width: 2,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            driver.name,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: isDark ? Colors.white : AppColors.textPrimary,
                            ),
                          ),
                          Text(
                            driver.vehicle,
                            style: TextStyle(fontSize: 13, color: isDark ? Colors.white54 : AppColors.textSecondary),
                          ),
                          Row(
                            children: [
                              Icon(Icons.star, size: 14, color: AppColors.warning),
                              const SizedBox(width: 2),
                              Text(
                                driver.rating.toStringAsFixed(1),
                                style: TextStyle(fontSize: 12, color: isDark ? Colors.white54 : AppColors.textSecondary),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '${driver.todayDeliveries} توصيلة اليوم', // TODO: localize
                                style: TextStyle(fontSize: 12, color: isDark ? Colors.white54 : AppColors.textSecondary),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: _getStatusColor(driver.status).withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            _getStatusName(driver.status),
                            style: TextStyle(fontSize: 11, color: _getStatusColor(driver.status), fontWeight: FontWeight.w500),
                          ),
                        ),
                        if (driver.status == 'active') ...[
                          const SizedBox(height: 8),
                          IconButton(
                            icon: Icon(Icons.add_box_outlined, color: AppColors.info),
                            onPressed: () => _assignOrder(driver),
                            tooltip: 'تعيين طلب', // TODO: localize
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? color.withValues(alpha: 0.1) : color.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(value, style: TextStyle(fontWeight: FontWeight.bold, color: color, fontSize: 20)),
          Text(label, style: TextStyle(fontSize: 12, color: color.withValues(alpha: 0.8))),
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
        userName: 'أحمد محمد', // TODO: localize
        userRole: l10n.branchManager,
        onUserTap: () => Navigator.pop(context),
      ),
    );
  }

  void _showTrackingMap() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('خريطة التتبع'), // TODO: localize
        content: SizedBox(
          width: 400,
          height: 300,
          child: Container(
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E293B) : Colors.grey.shade200,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.map, size: 64, color: isDark ? Colors.white24 : Colors.grey),
                  const SizedBox(height: 16),
                  Text('خريطة تتبع السائقين', style: TextStyle(color: isDark ? Colors.white : AppColors.textPrimary)), // TODO: localize
                  Text('(يتطلب اشتراك GPS)', style: TextStyle(color: isDark ? Colors.white54 : AppColors.textSecondary)), // TODO: localize
                ],
              ),
            ),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('إغلاق')), // TODO: localize
        ],
      ),
    );
  }

  void _addDriver() {
    final nameController = TextEditingController();
    final phoneController = TextEditingController();
    final vehicleController = TextEditingController();
    final plateController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('إضافة سائق'), // TODO: localize
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: nameController, decoration: const InputDecoration(labelText: 'الاسم *', prefixIcon: Icon(Icons.person))), // TODO: localize
              const SizedBox(height: 12),
              TextField(controller: phoneController, keyboardType: TextInputType.phone, decoration: const InputDecoration(labelText: 'الهاتف *', prefixIcon: Icon(Icons.phone))), // TODO: localize
              const SizedBox(height: 12),
              TextField(controller: vehicleController, decoration: const InputDecoration(labelText: 'المركبة', prefixIcon: Icon(Icons.directions_car), hintText: 'مثال: هايلكس - أبيض')), // TODO: localize
              const SizedBox(height: 12),
              TextField(controller: plateController, decoration: const InputDecoration(labelText: 'رقم اللوحة', prefixIcon: Icon(Icons.confirmation_number))), // TODO: localize
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('إلغاء')), // TODO: localize
          FilledButton(
            onPressed: () {
              if (nameController.text.isNotEmpty && phoneController.text.isNotEmpty) {
                setState(() {
                  _drivers.add(_Driver(
                    id: 'new_${_drivers.length}',
                    name: nameController.text,
                    phone: phoneController.text,
                    vehicle: vehicleController.text,
                    plateNumber: plateController.text,
                    status: 'offline',
                    todayDeliveries: 0,
                    totalDeliveries: 0,
                    rating: 0,
                  ));
                });
              }
              Navigator.pop(context);
            },
            child: const Text('إضافة'), // TODO: localize
          ),
        ],
      ),
    );
  }

  void _showDriverDetails(_Driver driver) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.4,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) => Container(
          color: isDark ? const Color(0xFF1E293B) : Colors.white,
          child: ListView(
            controller: scrollController,
            padding: const EdgeInsets.all(24),
            children: [
              Center(
                child: Container(
                  width: 40, height: 4,
                  margin: const EdgeInsets.only(bottom: 24),
                  decoration: BoxDecoration(
                    color: isDark ? Colors.white24 : Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Row(
                children: [
                  CircleAvatar(
                    radius: 32,
                    backgroundColor: AppColors.info.withValues(alpha: 0.1),
                    child: Text(driver.name[0], style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.info)),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(child: Text(driver.name, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: isDark ? Colors.white : AppColors.textPrimary))),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: _getStatusColor(driver.status).withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(_getStatusName(driver.status), style: TextStyle(color: _getStatusColor(driver.status), fontWeight: FontWeight.w500)),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Icon(Icons.star, size: 16, color: AppColors.warning),
                            const SizedBox(width: 4),
                            Text(driver.rating.toStringAsFixed(1), style: TextStyle(color: isDark ? Colors.white54 : AppColors.textSecondary)),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              _DetailTile(icon: Icons.phone, label: 'الهاتف', value: driver.phone, isDark: isDark), // TODO: localize
              _DetailTile(icon: Icons.directions_car, label: 'المركبة', value: driver.vehicle, isDark: isDark), // TODO: localize
              _DetailTile(icon: Icons.confirmation_number, label: 'اللوحة', value: driver.plateNumber, isDark: isDark), // TODO: localize
              Divider(height: 32, color: isDark ? Colors.white.withValues(alpha: 0.1) : AppColors.border),
              Row(
                children: [
                  Expanded(child: _buildDetailCard(icon: Icons.today, label: 'توصيلات اليوم', value: '${driver.todayDeliveries}', color: AppColors.info, isDark: isDark)), // TODO: localize
                  const SizedBox(width: 12),
                  Expanded(child: _buildDetailCard(icon: Icons.all_inclusive, label: 'الإجمالي', value: '${driver.totalDeliveries}', color: AppColors.success, isDark: isDark)), // TODO: localize
                ],
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(child: OutlinedButton.icon(onPressed: () {}, icon: const Icon(Icons.edit), label: const Text('تعديل'))), // TODO: localize
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        _assignOrder(driver);
                      },
                      icon: const Icon(Icons.add_box),
                      label: const Text('تعيين طلب'), // TODO: localize
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, color: color),
          const SizedBox(height: 8),
          Text(value, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color)),
          Text(label, style: TextStyle(fontSize: 12, color: color)),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'active': return AppColors.success;
      case 'delivering': return AppColors.warning;
      case 'offline': return AppColors.textSecondary;
      default: return AppColors.textSecondary;
    }
  }

  String _getStatusName(String status) {
    switch (status) {
      case 'active': return 'متاح'; // TODO: localize
      case 'delivering': return 'في توصيل'; // TODO: localize
      case 'offline': return 'غير متصل'; // TODO: localize
      default: return status;
    }
  }

  void _assignOrder(_Driver driver) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('تعيين طلب - ${driver.name}'), // TODO: localize
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(leading: Icon(Icons.receipt_long), title: Text('طلب #2024-003'), subtitle: Text('خالد عمر - حي النزهة'), trailing: Icon(Icons.radio_button_checked, color: AppColors.info)),
            ListTile(leading: Icon(Icons.receipt_long), title: Text('طلب #2024-008'), subtitle: Text('محمد علي - حي الروضة'), trailing: Icon(Icons.radio_button_unchecked)),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('إلغاء')), // TODO: localize
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('تم تعيين الطلب لـ ${driver.name}')), // TODO: localize
              );
            },
            child: const Text('تعيين'), // TODO: localize
          ),
        ],
      ),
    );
  }
}

class _Driver {
  final String id;
  final String name;
  final String phone;
  final String vehicle;
  final String plateNumber;
  final String status;
  final int todayDeliveries;
  final int totalDeliveries;
  final double rating;

  _Driver({
    required this.id,
    required this.name,
    required this.phone,
    required this.vehicle,
    required this.plateNumber,
    required this.status,
    required this.todayDeliveries,
    required this.totalDeliveries,
    required this.rating,
  });
}

class _DetailTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool isDark;

  const _DetailTile({required this.icon, required this.label, required this.value, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: isDark ? Colors.white54 : AppColors.textSecondary),
          const SizedBox(width: 12),
          Text(label, style: TextStyle(color: isDark ? Colors.white54 : AppColors.textSecondary)),
          const Spacer(),
          Text(value, style: TextStyle(fontWeight: FontWeight.w500, color: isDark ? Colors.white : AppColors.textPrimary)),
        ],
      ),
    );
  }
}
