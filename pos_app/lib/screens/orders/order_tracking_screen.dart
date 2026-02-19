import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../data/local/app_database.dart';
import '../../di/injection.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../providers/products_providers.dart';
import '../../providers/sync_providers.dart';

/// شاشة تتبع الطلبات - تعرض الطلبات النشطة (غير المكتملة) مع إمكانية تحديث حالتها
class OrderTrackingScreen extends ConsumerStatefulWidget {
  const OrderTrackingScreen({super.key});

  @override
  ConsumerState<OrderTrackingScreen> createState() => _OrderTrackingScreenState();
}

class _OrderTrackingScreenState extends ConsumerState<OrderTrackingScreen> {
  List<OrdersTableData> _orders = [];
  Map<String, List<OrderItemsTableData>> _orderItems = {};
  Map<String, CustomersTableData> _customers = {};
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  /// تحميل الطلبات النشطة (المعلقة والجاري تنفيذها) من قاعدة البيانات
  Future<void> _loadData() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final storeId = ref.read(currentStoreIdProvider);
      if (storeId == null) return;
      final db = getIt<AppDatabase>();

      // جلب الطلبات النشطة (pending, confirmed, preparing, ready, delivering)
      final orders = await db.ordersDao.getPendingOrders(storeId);

      // جلب عناصر كل طلب وبيانات العميل
      final itemsMap = <String, List<OrderItemsTableData>>{};
      final customersMap = <String, CustomersTableData>{};

      for (final order in orders) {
        try {
          itemsMap[order.id] = await db.ordersDao.getOrderItems(order.id);
        } catch (_) {
          itemsMap[order.id] = [];
        }

        // جلب بيانات العميل إذا كان موجوداً
        if (order.customerId != null && !customersMap.containsKey(order.customerId)) {
          try {
            final customer = await db.customersDao.getCustomerById(order.customerId!);
            if (customer != null) {
              customersMap[order.customerId!] = customer;
            }
          } catch (_) {
            // العميل قد لا يكون موجوداً في قاعدة البيانات المحلية
          }
        }
      }

      if (mounted) {
        setState(() {
          _orders = orders;
          _orderItems = itemsMap;
          _customers = customersMap;
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

  /// تحديث حالة الطلب مع المزامنة
  Future<void> _updateStatus(OrdersTableData order, String newStatus) async {
    try {
      final db = getIt<AppDatabase>();
      await db.ordersDao.updateOrderStatus(order.id, newStatus);

      // إضافة للمزامنة
      try {
        final syncService = ref.read(syncServiceProvider);
        await syncService.enqueueUpdate(
          tableName: 'orders',
          recordId: order.id,
          changes: {'status': newStatus, 'updatedAt': DateTime.now().toIso8601String()},
        );
      } catch (_) {
        // المزامنة اختيارية
      }

      await _loadData();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${order.orderNumber} - $newStatus')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${AppLocalizations.of(context)!.errorOccurred}: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.orders)),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    // حالة الخطأ
    if (_error != null) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.orders)),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64, color: isDark ? AppColors.error.withValues(alpha: 0.7) : AppColors.error.withValues(alpha: 0.5)),
              const SizedBox(height: 16),
              Text(l10n.errorOccurred, style: TextStyle(fontSize: 18, color: isDark ? Colors.white : AppColors.textPrimary)),
              const SizedBox(height: 8),
              TextButton.icon(
                onPressed: _loadData,
                icon: const Icon(Icons.refresh),
                label: Text(l10n.retry),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.orders),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _loadData),
          IconButton(icon: const Icon(Icons.map), onPressed: _showMap),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth > 900;
          final isMedium = constraints.maxWidth > 600;
          final horizontalPadding = isWide ? 32.0 : (isMedium ? 24.0 : 16.0);
          final subtleColor = isDark ? Colors.white.withValues(alpha: 0.5) : AppColors.textSecondary;

          return Column(
            children: [
              // إحصائيات سريعة للطلبات النشطة
              Container(
                padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: 16),
                child: Row(
                  children: [
                    _StatCard(
                      icon: Icons.pending,
                      label: l10n.pending,
                      value: '${_orders.where((o) => o.status == "pending").length}',
                      color: Colors.orange,
                    ),
                    const SizedBox(width: 12),
                    _StatCard(
                      icon: Icons.restaurant,
                      label: l10n.orderStatusPreparing,
                      value: '${_orders.where((o) => o.status == "preparing" || o.status == "confirmed").length}',
                      color: Colors.blue,
                    ),
                    const SizedBox(width: 12),
                    _StatCard(
                      icon: Icons.delivery_dining,
                      label: l10n.orderStatusDelivering,
                      value: '${_orders.where((o) => o.status == "delivering" || o.status == "ready").length}',
                      color: Colors.green,
                    ),
                  ],
                ),
              ),

              // قائمة الطلبات أو حالة فارغة
              Expanded(
                child: _orders.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.delivery_dining, size: 64, color: isDark ? Colors.white.withValues(alpha: 0.2) : AppColors.textMuted),
                            const SizedBox(height: 16),
                            Text(l10n.noOrders, style: TextStyle(fontSize: 18, color: isDark ? Colors.white.withValues(alpha: 0.6) : AppColors.textSecondary)),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _loadData,
                        child: isWide
                            ? GridView.builder(
                                padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  crossAxisSpacing: 16,
                                  mainAxisSpacing: 0,
                                  childAspectRatio: 2.2,
                                ),
                                itemCount: _orders.length,
                                itemBuilder: (context, index) {
                                  final order = _orders[index];
                                  final items = _orderItems[order.id] ?? [];
                                  final customer = order.customerId != null ? _customers[order.customerId] : null;
                                  final customerName = customer?.name ?? (order.customerId ?? l10n.guestCustomer);
                                  final customerPhone = customer?.phone ?? '';
                                  final address = order.deliveryAddress ?? '';

                                  return _buildOrderCard(context, order, items, customerName, customerPhone, address, isDark, subtleColor, l10n);
                                },
                              )
                            : ListView.builder(
                                padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                                itemCount: _orders.length,
                                itemBuilder: (context, index) {
                                  final order = _orders[index];
                                  final items = _orderItems[order.id] ?? [];
                                  final customer = order.customerId != null ? _customers[order.customerId] : null;
                                  final customerName = customer?.name ?? (order.customerId ?? l10n.guestCustomer);
                                  final customerPhone = customer?.phone ?? '';
                                  final address = order.deliveryAddress ?? '';

                                  return _buildOrderCard(context, order, items, customerName, customerPhone, address, isDark, subtleColor, l10n);
                                },
                              ),
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildOrderCard(BuildContext context, OrdersTableData order, List<OrderItemsTableData> items, String customerName, String customerPhone, String address, bool isDark, Color subtleColor, AppLocalizations l10n) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: isDark ? const Color(0xFF1E293B) : null,
      child: InkWell(
        onTap: () => _showOrderDetails(order, items, customerName, customerPhone, address),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(order.orderNumber, style: TextStyle(fontWeight: FontWeight.bold, fontFamily: 'monospace', color: isDark ? Colors.white : AppColors.textPrimary)),
                  const Spacer(),
                  _StatusChip(status: order.status),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(Icons.person, size: 16, color: subtleColor),
                  const SizedBox(width: 4),
                  Text(customerName, style: TextStyle(color: isDark ? Colors.white.withValues(alpha: 0.8) : AppColors.textPrimary)),
                  const Spacer(),
                  Text(l10n.priceWithCurrency(order.total.toStringAsFixed(0)), style: TextStyle(fontWeight: FontWeight.bold, color: isDark ? Colors.white : AppColors.textPrimary)),
                ],
              ),
              if (address.isNotEmpty) ...[
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.location_on, size: 16, color: subtleColor),
                    const SizedBox(width: 4),
                    Expanded(child: Text(address, style: TextStyle(fontSize: 12, color: subtleColor), overflow: TextOverflow.ellipsis)),
                  ],
                ),
              ],
              const Divider(height: 24),
              Row(
                children: [
                  if (order.driverId != null) ...[
                    const Icon(Icons.directions_car, size: 16, color: Colors.blue),
                    const SizedBox(width: 4),
                    Text(order.driverId!, style: TextStyle(fontSize: 12, color: isDark ? Colors.white.withValues(alpha: 0.7) : AppColors.textPrimary)),
                    const SizedBox(width: 16),
                  ],
                  const Icon(Icons.timer, size: 16, color: Colors.orange),
                  const SizedBox(width: 4),
                  Text(_formatTimeSinceOrder(order.orderDate, l10n), style: TextStyle(fontSize: 12, color: isDark ? Colors.white.withValues(alpha: 0.7) : AppColors.textPrimary)),
                  const Spacer(),
                  Text('${items.length} ${l10n.products}', style: TextStyle(fontSize: 12, color: subtleColor)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// حساب الوقت المنقضي منذ إنشاء الطلب
  String _formatTimeSinceOrder(DateTime orderDate, AppLocalizations l10n) {
    final diff = DateTime.now().difference(orderDate);
    if (diff.inMinutes < 60) {
      return l10n.minutesAgoTime(diff.inMinutes);
    } else if (diff.inHours < 24) {
      return l10n.hoursAgoTime(diff.inHours);
    } else {
      return l10n.daysAgoTime(diff.inDays);
    }
  }

  void _showMap() {
    final l10n = AppLocalizations.of(context)!;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.comingSoon)));
  }

  void _showOrderDetails(
    OrdersTableData order,
    List<OrderItemsTableData> items,
    String customerName,
    String customerPhone,
    String address,
  ) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        expand: false,
        builder: (context, scrollController) => ListView(
          controller: scrollController,
          padding: const EdgeInsets.all(24),
          children: [
            Center(
              child: Container(width: 40, height: 4, margin: const EdgeInsets.only(bottom: 24), decoration: BoxDecoration(color: isDark ? Colors.white.withValues(alpha: 0.2) : AppColors.grey300, borderRadius: BorderRadius.circular(2))),
            ),
            Row(
              children: [
                Text(order.orderNumber, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, fontFamily: 'monospace')),
                const Spacer(),
                _StatusChip(status: order.status),
              ],
            ),
            const SizedBox(height: 24),

            // خط زمني لحالة الطلب
            _buildTimeline(order),

            const Divider(height: 32),
            ListTile(leading: const Icon(Icons.person), title: Text(customerName), subtitle: customerPhone.isNotEmpty ? Text(customerPhone) : null),
            if (address.isNotEmpty)
              ListTile(leading: const Icon(Icons.location_on), title: Text(l10n.addressLabel), subtitle: Text(address)),
            if (order.driverId != null)
              ListTile(leading: const Icon(Icons.directions_car), title: Text(order.driverId!), subtitle: Text(l10n.driverName)),

            // عناصر الطلب
            if (items.isNotEmpty) ...[
              const Divider(height: 24),
              Text(l10n.products, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 8),
              ...items.map((item) => ListTile(
                dense: true,
                title: Text(item.productName),
                trailing: Text(l10n.priceWithCurrency(item.total.toStringAsFixed(0))),
                subtitle: Text('x${item.quantity.toStringAsFixed(0)}'),
              )),
              const Divider(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(l10n.total, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  Text(l10n.priceWithCurrency(order.total.toStringAsFixed(0)), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green)),
                ],
              ),
            ],

            const Divider(height: 24),

            // أزرار تقدم الحالة
            if (order.status == 'pending')
              FilledButton.icon(onPressed: () { Navigator.pop(context); _updateStatus(order, 'confirmed'); }, icon: const Icon(Icons.check), label: Text(l10n.orderStatusConfirmed))
            else if (order.status == 'confirmed')
              FilledButton.icon(onPressed: () { Navigator.pop(context); _updateStatus(order, 'preparing'); }, icon: const Icon(Icons.restaurant), label: Text(l10n.orderStatusPreparing))
            else if (order.status == 'preparing')
              FilledButton.icon(onPressed: () { Navigator.pop(context); _updateStatus(order, 'ready'); }, icon: const Icon(Icons.check_circle), label: Text(l10n.orderStatusReady))
            else if (order.status == 'ready')
              FilledButton.icon(onPressed: () { Navigator.pop(context); _updateStatus(order, 'delivering'); }, icon: const Icon(Icons.delivery_dining), label: Text(l10n.orderStatusDelivering))
            else if (order.status == 'delivering')
              FilledButton.icon(onPressed: () { Navigator.pop(context); _updateStatus(order, 'delivered'); }, icon: const Icon(Icons.done_all), label: Text(l10n.completed)),

            // زر إلغاء الطلب
            if (order.status != 'delivered' && order.status != 'cancelled') ...[
              const SizedBox(height: 8),
              OutlinedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  _updateStatus(order, 'cancelled');
                },
                icon: const Icon(Icons.cancel, color: Colors.red),
                label: Text(l10n.cancelled, style: const TextStyle(color: Colors.red)),
                style: OutlinedButton.styleFrom(side: const BorderSide(color: Colors.red)),
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// بناء الخط الزمني لحالات الطلب
  Widget _buildTimeline(OrdersTableData order) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final steps = [
      {'label': l10n.pending, 'done': true},
      {'label': l10n.orderStatusPreparing, 'done': order.status != 'pending' && order.status != 'confirmed'},
      {'label': l10n.orderStatusDelivering, 'done': order.status == 'delivering' || order.status == 'delivered'},
      {'label': l10n.completed, 'done': order.status == 'delivered'},
    ];
    return Row(
      children: steps.asMap().entries.map((e) {
        final step = e.value;
        final isLast = e.key == steps.length - 1;
        return Expanded(
          child: Row(
            children: [
              Column(
                children: [
                  Container(
                    width: 24, height: 24,
                    decoration: BoxDecoration(shape: BoxShape.circle, color: step['done'] == true ? Colors.green : (isDark ? Colors.white.withValues(alpha: 0.2) : AppColors.grey300)),
                    child: Icon(step['done'] == true ? Icons.check : Icons.circle, size: 12, color: Colors.white),
                  ),
                  const SizedBox(height: 4),
                  Text(step['label'] as String, style: TextStyle(fontSize: 10, color: step['done'] == true ? Colors.green : (isDark ? Colors.white.withValues(alpha: 0.4) : AppColors.textMuted))),
                ],
              ),
              if (!isLast) Expanded(child: Container(height: 2, color: step['done'] == true ? Colors.green : (isDark ? Colors.white.withValues(alpha: 0.2) : AppColors.grey300))),
            ],
          ),
        );
      }).toList(),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label, value;
  final Color color;
  const _StatCard({required this.icon, required this.label, required this.value, required this.color});
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
        child: Column(children: [
          Icon(icon, color: color),
          Text(value, style: TextStyle(fontWeight: FontWeight.bold, color: color, fontSize: 24)),
          Text(label, style: TextStyle(fontSize: 11, color: color)),
        ]),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final String status;
  const _StatusChip({required this.status});
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = {
      'pending': Colors.orange,
      'confirmed': Colors.blue,
      'preparing': Colors.indigo,
      'ready': Colors.teal,
      'delivering': Colors.green,
      'delivered': Colors.grey,
      'cancelled': Colors.red,
    };
    final labels = {
      'pending': l10n.pending,
      'confirmed': l10n.orderStatusConfirmed,
      'preparing': l10n.orderStatusPreparing,
      'ready': l10n.orderStatusReady,
      'delivering': l10n.orderStatusDelivering,
      'delivered': l10n.completed,
      'cancelled': l10n.cancelled,
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: (colors[status] ?? Colors.grey).withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
      child: Text(labels[status] ?? status, style: TextStyle(fontSize: 11, color: colors[status], fontWeight: FontWeight.w500)),
    );
  }
}
