import 'package:drift/drift.dart' show Variable;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:alhai_shared_ui/alhai_shared_ui.dart';
import 'package:alhai_l10n/alhai_l10n.dart';
import 'package:alhai_database/alhai_database.dart';
import 'package:get_it/get_it.dart';

/// Driver Management Screen - شاشة إدارة السائقين
class DriverManagementScreen extends ConsumerStatefulWidget {
  const DriverManagementScreen({super.key});

  @override
  ConsumerState<DriverManagementScreen> createState() => _DriverManagementScreenState();
}

class _DriverManagementScreenState extends ConsumerState<DriverManagementScreen> {
  List<_Driver> _drivers = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final storeId = ref.read(currentStoreIdProvider);
      if (storeId == null) {
        if (mounted) setState(() => _isLoading = false);
        return;
      }
      final db = GetIt.I<AppDatabase>();
      final results = await db.customSelect(
        'SELECT * FROM drivers WHERE store_id = ? AND is_active = 1 ORDER BY name',
        variables: [Variable.withString(storeId)],
      ).get();
      if (mounted) {
        setState(() {
          _drivers = results
              .map((r) => _Driver(
                    id: r.data['id'] as String,
                    name: r.data['name'] as String,
                    phone: r.data['phone'] as String? ?? '',
                    vehicle: '${r.data['vehicle_type'] ?? ''}',
                    plateNumber: r.data['vehicle_plate'] as String? ?? '',
                    status: r.data['status'] as String? ?? 'available',
                    todayDeliveries: 0,
                    totalDeliveries: 0,
                    rating: 0.0,
                  ))
              .toList();
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _error = e.toString();
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isWideScreen = size.width > 900;
    final isMediumScreen = size.width > 600;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context);

    return Column(
      children: [
        AppHeader(
          title: l10n.driversTitle,
          onMenuTap: isWideScreen ? null : () => Scaffold.of(context).openDrawer(),
          onNotificationsTap: () => context.push('/notifications'),
          notificationsCount: 3,
          userName: l10n.defaultUserName,
          userRole: l10n.branchManager,
          actions: [
            IconButton(
              icon: Icon(Icons.map, color: Theme.of(context).colorScheme.onSurfaceVariant),
              tooltip: l10n.trackingMap,
              onPressed: _showTrackingMap,
            ),
            const SizedBox(width: 8),
            FilledButton.icon(onPressed: _addDriver, icon: const Icon(Icons.person_add, size: 18), label: Text(l10n.addDriver)),
          ],
        ),
        Expanded(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _error != null
                  ? AppErrorState.general(message: _error, onRetry: _loadData)
                  : SingleChildScrollView(
                      padding: EdgeInsets.all(isMediumScreen ? 24 : 16),
                      child: _buildContent(isWideScreen, isMediumScreen, isDark, l10n),
                    ),
        ),
      ],
    );
  }

  Widget _buildContent(bool isWideScreen, bool isMediumScreen, bool isDark, AppLocalizations l10n) {
    final activeCount = _drivers.where((d) => d.status == 'active' || d.status == 'available').length;
    final deliveringCount = _drivers.where((d) => d.status == 'out_for_delivery').length;
    final todayTotal = _drivers.fold(0, (sum, d) => sum + d.todayDeliveries);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(children: [
          Expanded(child: _buildStatCard(icon: Icons.people, label: l10n.total, value: '${_drivers.length}', color: AppColors.info, isDark: isDark)),
          const SizedBox(width: 12),
          Expanded(child: _buildStatCard(icon: Icons.check_circle, label: l10n.available, value: '$activeCount', color: AppColors.success, isDark: isDark)),
          const SizedBox(width: 12),
          Expanded(child: _buildStatCard(icon: Icons.delivery_dining, label: l10n.delivering, value: '$deliveringCount', color: AppColors.warning, isDark: isDark)),
          const SizedBox(width: 12),
          Expanded(child: _buildStatCard(icon: Icons.local_shipping, label: l10n.totalDeliveries, value: '$todayTotal', color: const Color(0xFF8B5CF6), isDark: isDark)),
        ]),
        const SizedBox(height: 16),
        if (_drivers.isEmpty)
          AppEmptyState.noData(title: l10n.noDriversRegistered, description: l10n.addDriversForDelivery)
        else
          ...List.generate(_drivers.length, (index) {
            final driver = _drivers[index];
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Theme.of(context).dividerColor),
              ),
              child: InkWell(
                onTap: () => _showDriverDetails(driver),
                borderRadius: BorderRadius.circular(12),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Stack(children: [
                        CircleAvatar(
                          radius: 28,
                          backgroundColor: AppColors.info.withValues(alpha: 0.1),
                          child: Text(driver.name.isNotEmpty ? driver.name[0] : '?', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.info)),
                        ),
                        PositionedDirectional(
                          bottom: 0,
                          end: 0,
                          child: Container(
                            width: 16,
                            height: 16,
                            decoration: BoxDecoration(
                              color: _getStatusColor(driver.status),
                              shape: BoxShape.circle,
                              border: Border.all(color: Theme.of(context).colorScheme.surface, width: 2),
                            ),
                          ),
                        ),
                      ]),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(driver.name, style: TextStyle(fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface)),
                            Text(driver.vehicle.isNotEmpty ? driver.vehicle : '\u2014', style: TextStyle(fontSize: 13, color: Theme.of(context).colorScheme.onSurfaceVariant)),
                            Row(children: [
                              const Icon(Icons.star, size: 14, color: AppColors.warning),
                              const SizedBox(width: 2),
                              Text(driver.rating.toStringAsFixed(1), style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.onSurfaceVariant)),
                              const SizedBox(width: 8),
                              Text(l10n.deliveriesToday(driver.todayDeliveries), style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.onSurfaceVariant)),
                            ]),
                          ],
                        ),
                      ),
                      Column(children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(color: _getStatusColor(driver.status).withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
                          child: Text(_getStatusName(driver.status, l10n), style: TextStyle(fontSize: 11, color: _getStatusColor(driver.status), fontWeight: FontWeight.w500)),
                        ),
                        if (driver.status == 'active' || driver.status == 'available') ...[
                          const SizedBox(height: 8),
                          IconButton(icon: const Icon(Icons.add_box_outlined, color: AppColors.info), onPressed: () => _assignOrder(driver), tooltip: l10n.assignOrder),
                        ],
                      ]),
                    ],
                  ),
                ),
              ),
            );
          }),
      ],
    );
  }

  Widget _buildStatCard({required IconData icon, required String label, required String value, required Color color, required bool isDark}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? color.withValues(alpha: 0.1) : color.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 8),
        Text(value, style: TextStyle(fontWeight: FontWeight.bold, color: color, fontSize: 20)),
        Text(label, style: TextStyle(fontSize: 12, color: color.withValues(alpha: 0.8))),
      ]),
    );
  }

  void _showTrackingMap() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.trackingMap),
        content: SizedBox(
          width: 400,
          height: 300,
          child: Container(
            decoration: BoxDecoration(color: isDark ? const Color(0xFF1E293B) : AppColors.border, borderRadius: BorderRadius.circular(12)),
            child: Center(
              child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                Icon(Icons.map, size: 64, color: isDark ? Colors.white24 : AppColors.textTertiary),
                const SizedBox(height: 16),
                Text(l10n.driversTrackingMap, style: TextStyle(color: Theme.of(context).colorScheme.onSurface)),
                Text(l10n.gpsSubscriptionRequired, style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant)),
              ]),
            ),
          ),
        ),
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: Text(l10n.close))],
      ),
    );
  }

  void _addDriver() {
    final l10n = AppLocalizations.of(context);
    final nameController = TextEditingController();
    final phoneController = TextEditingController();
    final vehicleController = TextEditingController();
    final plateController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.addDriver),
        content: SingleChildScrollView(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            TextField(controller: nameController, decoration: InputDecoration(labelText: '${l10n.driverName} *', prefixIcon: const Icon(Icons.person))),
            const SizedBox(height: 12),
            TextField(controller: phoneController, keyboardType: TextInputType.phone, decoration: InputDecoration(labelText: '${l10n.phone} *', prefixIcon: const Icon(Icons.phone))),
            const SizedBox(height: 12),
            TextField(controller: vehicleController, decoration: InputDecoration(labelText: l10n.vehicleLabel, prefixIcon: const Icon(Icons.directions_car), hintText: l10n.vehicleHint)),
            const SizedBox(height: 12),
            TextField(controller: plateController, decoration: InputDecoration(labelText: l10n.plateNumberLabel, prefixIcon: const Icon(Icons.confirmation_number))),
          ]),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text(l10n.cancel)),
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
              Navigator.pop(ctx);
            },
            child: Text(l10n.add),
          ),
        ],
      ),
    ).then((_) {
      nameController.dispose();
      phoneController.dispose();
      vehicleController.dispose();
      plateController.dispose();
    });
  }

  void _showDriverDetails(_Driver driver) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.4,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) => Container(
          color: Theme.of(context).colorScheme.surface,
          child: ListView(
            controller: scrollController,
            padding: const EdgeInsets.all(24),
            children: [
              Center(child: Container(width: 40, height: 4, margin: const EdgeInsets.only(bottom: 24), decoration: BoxDecoration(color: isDark ? Colors.white24 : AppColors.textTertiary, borderRadius: BorderRadius.circular(2)))),
              Row(children: [
                CircleAvatar(radius: 32, backgroundColor: AppColors.info.withValues(alpha: 0.1), child: Text(driver.name.isNotEmpty ? driver.name[0] : '?', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.info))),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Row(children: [
                      Expanded(child: Text(driver.name, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface))),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(color: _getStatusColor(driver.status).withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
                        child: Text(_getStatusName(driver.status, l10n), style: TextStyle(color: _getStatusColor(driver.status), fontWeight: FontWeight.w500)),
                      ),
                    ]),
                    Row(children: [
                      const Icon(Icons.star, size: 16, color: AppColors.warning),
                      const SizedBox(width: 4),
                      Text(driver.rating.toStringAsFixed(1), style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant)),
                    ]),
                  ]),
                ),
              ]),
              const SizedBox(height: 24),
              _DetailTile(icon: Icons.phone, label: l10n.phone, value: driver.phone, isDark: isDark),
              _DetailTile(icon: Icons.directions_car, label: l10n.vehicleLabel, value: driver.vehicle.isNotEmpty ? driver.vehicle : '\u2014', isDark: isDark),
              _DetailTile(icon: Icons.confirmation_number, label: l10n.plateNumberLabel, value: driver.plateNumber.isNotEmpty ? driver.plateNumber : '\u2014', isDark: isDark),
              Divider(height: 32, color: Theme.of(context).dividerColor),
              Row(children: [
                Expanded(child: _buildDetailCard(icon: Icons.today, label: l10n.totalDeliveries, value: '${driver.todayDeliveries}', color: AppColors.info, isDark: isDark)),
                const SizedBox(width: 12),
                Expanded(child: _buildDetailCard(icon: Icons.all_inclusive, label: l10n.total, value: '${driver.totalDeliveries}', color: AppColors.success, isDark: isDark)),
              ]),
              const SizedBox(height: 24),
              Row(children: [
                Expanded(child: OutlinedButton.icon(onPressed: () {}, icon: const Icon(Icons.edit), label: Text(l10n.edit))),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      _assignOrder(driver);
                    },
                    icon: const Icon(Icons.add_box),
                    label: Text(l10n.assignOrder),
                  ),
                ),
              ]),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailCard({required IconData icon, required String label, required String value, required Color color, required bool isDark}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
      child: Column(children: [
        Icon(icon, color: color),
        const SizedBox(height: 8),
        Text(value, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color)),
        Text(label, style: TextStyle(fontSize: 12, color: color)),
      ]),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'active':
      case 'available':
        return AppColors.success;
      case 'out_for_delivery':
        return AppColors.warning;
      case 'offline':
        return AppColors.textSecondary;
      default:
        return AppColors.textSecondary;
    }
  }

  String _getStatusName(String status, AppLocalizations l10n) {
    switch (status) {
      case 'active':
      case 'available':
        return l10n.available;
      case 'out_for_delivery':
        return l10n.delivering;
      case 'offline':
        return l10n.offline;
      default:
        return status;
    }
  }

  void _assignOrder(_Driver driver) {
    final l10n = AppLocalizations.of(context);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.assignOrderTo(driver.name)),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          ListTile(leading: const Icon(Icons.receipt_long), title: Text('${l10n.orderLabel} #2024-003'), subtitle: const Text('Sample Customer 1'), trailing: const Icon(Icons.radio_button_checked, color: AppColors.info)),
          ListTile(leading: const Icon(Icons.receipt_long), title: Text('${l10n.orderLabel} #2024-008'), subtitle: const Text('Sample Customer 2'), trailing: const Icon(Icons.radio_button_unchecked)),
        ]),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text(l10n.cancel)),
          FilledButton(
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.orderAssignedTo(driver.name))));
            },
            child: Text(l10n.confirm),
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

  _Driver({required this.id, required this.name, required this.phone, required this.vehicle, required this.plateNumber, required this.status, required this.todayDeliveries, required this.totalDeliveries, required this.rating});
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
      child: Row(children: [
        Icon(icon, size: 20, color: Theme.of(context).colorScheme.onSurfaceVariant),
        const SizedBox(width: 12),
        Text(label, style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant)),
        const Spacer(),
        Text(value, style: TextStyle(fontWeight: FontWeight.w500, color: Theme.of(context).colorScheme.onSurface)),
      ]),
    );
  }
}
