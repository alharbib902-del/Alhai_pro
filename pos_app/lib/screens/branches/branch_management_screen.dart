import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../widgets/layout/app_sidebar.dart';
import '../../widgets/layout/app_header.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../core/theme/app_colors.dart';
import '../../core/router/routes.dart';

/// شاشة إدارة الفروع
class BranchManagementScreen extends ConsumerStatefulWidget {
  const BranchManagementScreen({super.key});

  @override
  ConsumerState<BranchManagementScreen> createState() => _BranchManagementScreenState();
}

class _BranchManagementScreenState extends ConsumerState<BranchManagementScreen> {
  bool _sidebarCollapsed = false;
  String _selectedNavId = 'dashboard';

  final List<_Branch> _branches = [
    _Branch(id: '1', name: 'الفرع الرئيسي', address: 'حي النزهة، شارع الملك فهد', phone: '0112345678', manager: 'أحمد محمد', employees: 8, isActive: true, todaySales: 15000),
    _Branch(id: '2', name: 'فرع الروضة', address: 'حي الروضة، شارع الأمير سلطان', phone: '0112345679', manager: 'خالد عمر', employees: 5, isActive: true, todaySales: 8500),
    _Branch(id: '3', name: 'فرع السلامة', address: 'حي السلامة، شارع التحلية', phone: '0112345680', manager: 'محمد علي', employees: 4, isActive: false, todaySales: 0),
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
                  title: 'إدارة الفروع', // TODO: localize
                  onMenuTap: isWideScreen
                      ? () => setState(() => _sidebarCollapsed = !_sidebarCollapsed)
                      : () => Scaffold.of(context).openDrawer(),
                  onNotificationsTap: () => context.push('/notifications'),
                  notificationsCount: 3,
                  userName: 'أحمد محمد', // TODO: localize
                  userRole: l10n.branchManager,
                  actions: [
                    FilledButton.icon(
                      onPressed: _addBranch,
                      icon: const Icon(Icons.add, size: 18),
                      label: const Text('فرع جديد'), // TODO: localize
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
    final activeCount = _branches.where((b) => b.isActive).length;
    final totalSales = _branches.fold(0.0, (sum, b) => sum + b.todaySales);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Stats row
        Row(
          children: [
            Expanded(child: _buildStatCard(icon: Icons.store, label: 'الفروع', value: '${_branches.length}', color: AppColors.info, isDark: isDark)), // TODO: localize
            const SizedBox(width: 12),
            Expanded(child: _buildStatCard(icon: Icons.check_circle, label: 'نشط', value: '$activeCount', color: AppColors.success, isDark: isDark)), // TODO: localize
            const SizedBox(width: 12),
            Expanded(child: _buildStatCard(icon: Icons.attach_money, label: 'مبيعات اليوم', value: totalSales.toStringAsFixed(0), color: AppColors.warning, isDark: isDark)), // TODO: localize
          ],
        ),
        const SizedBox(height: 16),

        // Branch list
        ...List.generate(_branches.length, (index) {
          final branch = _branches[index];
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: isDark
                  ? (branch.isActive ? const Color(0xFF1E293B) : const Color(0xFF1E293B).withValues(alpha: 0.5))
                  : (branch.isActive ? Colors.white : Colors.grey.shade100),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: isDark ? Colors.white.withValues(alpha: 0.1) : AppColors.border),
            ),
            child: InkWell(
              onTap: () => _showBranchDetails(branch),
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.info.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(Icons.store, color: AppColors.info),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    branch.name,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color: isDark ? Colors.white : AppColors.textPrimary,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  if (!branch.isActive)
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: AppColors.textSecondary,
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: const Text('مغلق', style: TextStyle(color: Colors.white, fontSize: 10)), // TODO: localize
                                    ),
                                ],
                              ),
                              Text(
                                branch.address,
                                style: TextStyle(fontSize: 12, color: isDark ? Colors.white54 : AppColors.textSecondary),
                              ),
                            ],
                          ),
                        ),
                        Switch(
                          value: branch.isActive,
                          onChanged: (v) => setState(() => branch.isActive = v),
                          activeColor: AppColors.primary,
                        ),
                      ],
                    ),
                    Divider(height: 24, color: isDark ? Colors.white.withValues(alpha: 0.1) : AppColors.border),
                    Row(
                      children: [
                        Icon(Icons.person, size: 16, color: isDark ? Colors.white38 : AppColors.textTertiary),
                        const SizedBox(width: 4),
                        Text(
                          branch.manager,
                          style: TextStyle(fontSize: 12, color: isDark ? Colors.white54 : AppColors.textSecondary),
                        ),
                        const Spacer(),
                        Icon(Icons.people, size: 16, color: isDark ? Colors.white38 : AppColors.textTertiary),
                        const SizedBox(width: 4),
                        Text(
                          '${branch.employees} موظفين', // TODO: localize
                          style: TextStyle(fontSize: 12, color: isDark ? Colors.white54 : AppColors.textSecondary),
                        ),
                        const SizedBox(width: 16),
                        Text(
                          '${branch.todaySales.toStringAsFixed(0)} ر.س',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: branch.isActive ? AppColors.success : AppColors.textSecondary,
                          ),
                        ),
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

  void _addBranch() {
    final nameController = TextEditingController();
    final addressController = TextEditingController();
    final phoneController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('فرع جديد'), // TODO: localize
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: nameController, decoration: const InputDecoration(labelText: 'اسم الفرع', prefixIcon: Icon(Icons.store))), // TODO: localize
              const SizedBox(height: 12),
              TextField(controller: addressController, decoration: const InputDecoration(labelText: 'العنوان', prefixIcon: Icon(Icons.location_on))), // TODO: localize
              const SizedBox(height: 12),
              TextField(controller: phoneController, keyboardType: TextInputType.phone, decoration: const InputDecoration(labelText: 'الهاتف', prefixIcon: Icon(Icons.phone))), // TODO: localize
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('إلغاء')), // TODO: localize
          FilledButton(
            onPressed: () {
              if (nameController.text.isNotEmpty) {
                setState(() => _branches.add(_Branch(
                  id: 'new_${_branches.length}',
                  name: nameController.text,
                  address: addressController.text,
                  phone: phoneController.text,
                  manager: '-',
                  employees: 0,
                  isActive: true,
                  todaySales: 0,
                )));
              }
              Navigator.pop(context);
            },
            child: const Text('إضافة'), // TODO: localize
          ),
        ],
      ),
    );
  }

  void _showBranchDetails(_Branch branch) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        expand: false,
        builder: (context, scrollController) => Container(
          color: isDark ? const Color(0xFF1E293B) : Colors.white,
          child: ListView(
            controller: scrollController,
            padding: const EdgeInsets.all(24),
            children: [
              Center(child: Container(width: 40, height: 4, margin: const EdgeInsets.only(bottom: 24), decoration: BoxDecoration(color: isDark ? Colors.white24 : Colors.grey.shade300, borderRadius: BorderRadius.circular(2)))),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(color: AppColors.info.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
                    child: Icon(Icons.store, size: 32, color: AppColors.info),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(branch.name, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: isDark ? Colors.white : AppColors.textPrimary)),
                        Text(
                          branch.isActive ? 'مفتوح' : 'مغلق', // TODO: localize
                          style: TextStyle(color: branch.isActive ? AppColors.success : AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              _DetailTile(icon: Icons.location_on, label: 'العنوان', value: branch.address, isDark: isDark), // TODO: localize
              _DetailTile(icon: Icons.phone, label: 'الهاتف', value: branch.phone, isDark: isDark), // TODO: localize
              _DetailTile(icon: Icons.person, label: 'المدير', value: branch.manager, isDark: isDark), // TODO: localize
              _DetailTile(icon: Icons.people, label: 'الموظفين', value: '${branch.employees}', isDark: isDark), // TODO: localize
              Divider(height: 32, color: isDark ? Colors.white.withValues(alpha: 0.1) : AppColors.border),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.success.withValues(alpha: 0.1) : AppColors.successSurface,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(Icons.attach_money, color: AppColors.success),
                    const SizedBox(width: 12),
                    Text('مبيعات اليوم', style: TextStyle(color: isDark ? Colors.white : AppColors.textPrimary)), // TODO: localize
                    const Spacer(),
                    Text(
                      '${branch.todaySales.toStringAsFixed(0)} ر.س',
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.success),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(child: OutlinedButton.icon(onPressed: () {}, icon: const Icon(Icons.edit), label: const Text('تعديل'))), // TODO: localize
                  const SizedBox(width: 12),
                  Expanded(child: FilledButton.icon(onPressed: () {}, icon: const Icon(Icons.analytics), label: const Text('التقارير'))), // TODO: localize
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Branch {
  final String id, name, address, phone, manager;
  final int employees;
  bool isActive;
  final double todaySales;
  _Branch({required this.id, required this.name, required this.address, required this.phone, required this.manager, required this.employees, required this.isActive, required this.todaySales});
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
