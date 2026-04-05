import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:alhai_design_system/alhai_design_system.dart';
import 'package:alhai_database/alhai_database.dart';
import 'package:get_it/get_it.dart';
import 'package:alhai_l10n/alhai_l10n.dart';
import 'package:alhai_auth/alhai_auth.dart';
import '../../providers/sync_providers.dart';

/// شاشة تتبع الطلبات - تعرض الطلبات النشطة (غير المكتملة) مع إمكانية تحديث حالتها
class OrderTrackingScreen extends ConsumerStatefulWidget {
  const OrderTrackingScreen({super.key});

  @override
  ConsumerState<OrderTrackingScreen> createState() =>
      _OrderTrackingScreenState();
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
      final db = GetIt.I<AppDatabase>();

      // جلب الطلبات النشطة (created, confirmed, preparing, ready, out_for_delivery)
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
        if (order.customerId != null &&
            !customersMap.containsKey(order.customerId)) {
          try {
            final customer =
                await db.customersDao.getCustomerById(order.customerId!);
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
      final db = GetIt.I<AppDatabase>();
      await db.ordersDao.updateOrderStatus(order.id, newStatus);

      // إضافة للمزامنة
      try {
        final syncService = ref.read(syncServiceProvider);
        await syncService.enqueueUpdate(
          tableName: 'orders',
          recordId: order.id,
          changes: {
            'status': newStatus,
            'updatedAt': DateTime.now().toIso8601String()
          },
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
          SnackBar(
              content:
                  Text('${AppLocalizations.of(context).errorOccurred}: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
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
              Icon(Icons.error_outline,
                  size: 64,
                  color: isDark
                      ? AppColors.error.withValues(alpha: 0.7)
                      : AppColors.error.withValues(alpha: 0.5)),
              SizedBox(height: AlhaiSpacing.md),
              Text(l10n.errorOccurred,
                  style: TextStyle(
                      fontSize: 18,
                      color: Theme.of(context).colorScheme.onSurface)),
              SizedBox(height: AlhaiSpacing.xs),
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
          IconButton(icon: const Icon(Icons.map), onPressed: null),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth > 900;
          final isMedium = constraints.maxWidth > 600;
          final horizontalPadding = isWide ? 32.0 : (isMedium ? 24.0 : 16.0);
          final subtleColor = Theme.of(context).colorScheme.onSurfaceVariant;

          return Column(
            children: [
              // إحصائيات سريعة للطلبات النشطة
              Container(
                padding: EdgeInsets.symmetric(
                    horizontal: horizontalPadding, vertical: AlhaiSpacing.md),
                child: Row(
                  children: [
                    _StatCard(
                      icon: Icons.pending,
                      label: l10n.pending,
                      value:
                          '${_orders.where((o) => o.status == "created").length}',
                      color: AlhaiColors.warning,
                    ),
                    SizedBox(width: AlhaiSpacing.sm),
                    _StatCard(
                      icon: Icons.restaurant,
                      label: l10n.orderStatusPreparing,
                      value:
                          '${_orders.where((o) => o.status == "preparing" || o.status == "confirmed").length}',
                      color: AlhaiColors.info,
                    ),
                    SizedBox(width: AlhaiSpacing.sm),
                    _StatCard(
                      icon: Icons.delivery_dining,
                      label: l10n.orderStatusDelivering,
                      value:
                          '${_orders.where((o) => o.status == "out_for_delivery" || o.status == "ready").length}',
                      color: AlhaiColors.success,
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
                            Icon(Icons.delivery_dining,
                                size: 64,
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurfaceVariant
                                    .withValues(alpha: 0.3)),
                            SizedBox(height: AlhaiSpacing.md),
                            Text(l10n.noOrders,
                                style: TextStyle(
                                    fontSize: 18,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurfaceVariant)),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _loadData,
                        child: isWide
                            ? GridView.builder(
                                padding: EdgeInsets.symmetric(
                                    horizontal: horizontalPadding),
                                gridDelegate:
                                    const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  crossAxisSpacing: 16,
                                  mainAxisSpacing: 0,
                                  childAspectRatio: 2.2,
                                ),
                                itemCount: _orders.length,
                                itemBuilder: (context, index) {
                                  final order = _orders[index];
                                  final items = _orderItems[order.id] ?? [];
                                  final customer = order.customerId != null
                                      ? _customers[order.customerId]
                                      : null;
                                  final customerName = customer?.name ??
                                      (order.customerId ?? l10n.guestCustomer);
                                  final customerPhone = customer?.phone ?? '';
                                  final address = order.deliveryAddress ?? '';

                                  return _buildOrderCard(
                                      context,
                                      order,
                                      items,
                                      customerName,
                                      customerPhone,
                                      address,
                                      isDark,
                                      subtleColor,
                                      l10n);
                                },
                              )
                            : ListView.builder(
                                padding: EdgeInsets.symmetric(
                                    horizontal: horizontalPadding),
                                itemCount: _orders.length,
                                itemBuilder: (context, index) {
                                  final order = _orders[index];
                                  final items = _orderItems[order.id] ?? [];
                                  final customer = order.customerId != null
                                      ? _customers[order.customerId]
                                      : null;
                                  final customerName = customer?.name ??
                                      (order.customerId ?? l10n.guestCustomer);
                                  final customerPhone = customer?.phone ?? '';
                                  final address = order.deliveryAddress ?? '';

                                  return _buildOrderCard(
                                      context,
                                      order,
                                      items,
                                      customerName,
                                      customerPhone,
                                      address,
                                      isDark,
                                      subtleColor,
                                      l10n);
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

  Widget _buildOrderCard(
      BuildContext context,
      OrdersTableData order,
      List<OrderItemsTableData> items,
      String customerName,
      String customerPhone,
      String address,
      bool isDark,
      Color subtleColor,
      AppLocalizations l10n) {
    return Card(
      margin: const EdgeInsets.only(bottom: AlhaiSpacing.sm),
      color: Theme.of(context).colorScheme.surface,
      child: InkWell(
        onTap: () => _showOrderDetails(
            order, items, customerName, customerPhone, address),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(AlhaiSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(order.orderNumber,
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontFamily: 'monospace',
                          color: Theme.of(context).colorScheme.onSurface)),
                  const Spacer(),
                  _StatusChip(status: order.status),
                ],
              ),
              SizedBox(height: AlhaiSpacing.sm),
              Row(
                children: [
                  Icon(Icons.person, size: 16, color: subtleColor),
                  SizedBox(width: AlhaiSpacing.xxs),
                  Text(customerName,
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurface)),
                  const Spacer(),
                  Text(l10n.priceWithCurrency(order.total.toStringAsFixed(0)),
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.onSurface)),
                ],
              ),
              if (address.isNotEmpty) ...[
                SizedBox(height: AlhaiSpacing.xxs),
                Row(
                  children: [
                    Icon(Icons.location_on, size: 16, color: subtleColor),
                    SizedBox(width: AlhaiSpacing.xxs),
                    Expanded(
                        child: Text(address,
                            style: TextStyle(fontSize: 12, color: subtleColor),
                            overflow: TextOverflow.ellipsis)),
                  ],
                ),
              ],
              const Divider(height: 24),
              Row(
                children: [
                  if (order.driverId != null) ...[
                    Icon(Icons.directions_car,
                        size: 16, color: AlhaiColors.info),
                    SizedBox(width: AlhaiSpacing.xxs),
                    Text(order.driverId!,
                        style: TextStyle(
                            fontSize: 12,
                            color: Theme.of(context).colorScheme.onSurface)),
                    SizedBox(width: AlhaiSpacing.md),
                  ],
                  Icon(Icons.timer,
                      size: 16,
                      color: Theme.of(context).colorScheme.onSurfaceVariant),
                  SizedBox(width: AlhaiSpacing.xxs),
                  Text(_formatTimeSinceOrder(order.orderDate, l10n),
                      style: TextStyle(
                          fontSize: 12,
                          color: Theme.of(context).colorScheme.onSurface)),
                  const Spacer(),
                  Text('${items.length} ${l10n.products}',
                      style: TextStyle(fontSize: 12, color: subtleColor)),
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

  void _showOrderDetails(
    OrdersTableData order,
    List<OrderItemsTableData> items,
    String customerName,
    String customerPhone,
    String address,
  ) {
    final l10n = AppLocalizations.of(context);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        expand: false,
        builder: (context, scrollController) => ListView(
          controller: scrollController,
          padding: const EdgeInsets.all(AlhaiSpacing.lg),
          children: [
            Center(
              child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: AlhaiSpacing.lg),
                  decoration: BoxDecoration(
                      color: Theme.of(context).dividerColor,
                      borderRadius: BorderRadius.circular(2))),
            ),
            Row(
              children: [
                Text(order.orderNumber,
                    style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'monospace')),
                const Spacer(),
                _StatusChip(status: order.status),
              ],
            ),
            SizedBox(height: AlhaiSpacing.lg),

            // خط زمني لحالة الطلب
            _buildTimeline(order),

            const Divider(height: 32),
            ListTile(
                leading: const Icon(Icons.person),
                title: Text(customerName),
                subtitle:
                    customerPhone.isNotEmpty ? Text(customerPhone) : null),
            if (address.isNotEmpty)
              ListTile(
                  leading: const Icon(Icons.location_on),
                  title: Text(l10n.addressLabel),
                  subtitle: Text(address)),
            if (order.driverId != null)
              ListTile(
                  leading: const Icon(Icons.directions_car),
                  title: Text(order.driverId!),
                  subtitle: Text(l10n.driverName)),

            // عناصر الطلب
            if (items.isNotEmpty) ...[
              const Divider(height: 24),
              Text(l10n.products,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 16)),
              SizedBox(height: AlhaiSpacing.xs),
              ...items.map((item) => ListTile(
                    dense: true,
                    title: Text(item.productName),
                    trailing: Text(
                        l10n.priceWithCurrency(item.total.toStringAsFixed(0))),
                    subtitle: Text('x${item.quantity.toStringAsFixed(0)}'),
                  )),
              const Divider(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(l10n.total,
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold)),
                  Text(l10n.priceWithCurrency(order.total.toStringAsFixed(0)),
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.success)),
                ],
              ),
            ],

            const Divider(height: 24),

            // أزرار تقدم الحالة
            if (order.status == 'created')
              FilledButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    _updateStatus(order, 'confirmed');
                  },
                  icon: const Icon(Icons.check),
                  label: Text(l10n.orderStatusConfirmed))
            else if (order.status == 'confirmed')
              FilledButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    _updateStatus(order, 'preparing');
                  },
                  icon: const Icon(Icons.restaurant),
                  label: Text(l10n.orderStatusPreparing))
            else if (order.status == 'preparing')
              FilledButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    _updateStatus(order, 'ready');
                  },
                  icon: const Icon(Icons.check_circle),
                  label: Text(l10n.orderStatusReady))
            else if (order.status == 'ready')
              FilledButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    _updateStatus(order, 'out_for_delivery');
                  },
                  icon: const Icon(Icons.delivery_dining),
                  label: Text(l10n.orderStatusDelivering))
            else if (order.status == 'out_for_delivery')
              FilledButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    _updateStatus(order, 'delivered');
                  },
                  icon: const Icon(Icons.done_all),
                  label: Text(l10n.completed)),

            // زر إلغاء الطلب
            if (order.status != 'delivered' && order.status != 'cancelled') ...[
              SizedBox(height: AlhaiSpacing.xs),
              OutlinedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  _updateStatus(order, 'cancelled');
                },
                icon: Icon(Icons.cancel,
                    color: Theme.of(context).colorScheme.error),
                label: Text(l10n.cancelled,
                    style:
                        TextStyle(color: Theme.of(context).colorScheme.error)),
                style: OutlinedButton.styleFrom(
                    side:
                        BorderSide(color: Theme.of(context).colorScheme.error)),
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// بناء الخط الزمني لحالات الطلب
  Widget _buildTimeline(OrdersTableData order) {
    final l10n = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final steps = [
      {'label': l10n.pending, 'done': true},
      {
        'label': l10n.orderStatusPreparing,
        'done': order.status != 'created' && order.status != 'confirmed'
      },
      {
        'label': l10n.orderStatusDelivering,
        'done':
            order.status == 'out_for_delivery' || order.status == 'delivered'
      },
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
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: step['done'] == true
                            ? AppColors.success
                            : (isDark
                                ? Theme.of(context)
                                    .colorScheme
                                    .surfaceContainerHighest
                                : AppColors.grey300)),
                    child: Icon(
                        step['done'] == true ? Icons.check : Icons.circle,
                        size: 12,
                        color: Theme.of(context).colorScheme.onPrimary),
                  ),
                  SizedBox(height: AlhaiSpacing.xxs),
                  Text(step['label'] as String,
                      style: TextStyle(
                          fontSize: 10,
                          color: step['done'] == true
                              ? AppColors.success
                              : Theme.of(context)
                                  .colorScheme
                                  .onSurfaceVariant)),
                ],
              ),
              if (!isLast)
                Expanded(
                    child: Container(
                        height: 2,
                        color: step['done'] == true
                            ? AppColors.success
                            : (isDark
                                ? Theme.of(context)
                                    .colorScheme
                                    .surfaceContainerHighest
                                : AppColors.grey300))),
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
  const _StatCard(
      {required this.icon,
      required this.label,
      required this.value,
      required this.color});
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(AlhaiSpacing.sm),
        decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12)),
        child: Column(children: [
          Icon(icon, color: color),
          Text(value,
              style: TextStyle(
                  fontWeight: FontWeight.bold, color: color, fontSize: 24)),
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
    final l10n = AppLocalizations.of(context);
    final colors = {
      'created': AlhaiColors.warning,
      'confirmed': AlhaiColors.info,
      'preparing': Colors.indigo,
      'ready': Colors.teal,
      'out_for_delivery': AlhaiColors.success,
      'delivered': Theme.of(context).colorScheme.outline,
      'cancelled': AlhaiColors.error,
    };
    final labels = {
      'created': l10n.pending,
      'confirmed': l10n.orderStatusConfirmed,
      'preparing': l10n.orderStatusPreparing,
      'ready': l10n.orderStatusReady,
      'out_for_delivery': l10n.orderStatusDelivering,
      'delivered': l10n.completed,
      'cancelled': l10n.cancelled,
    };
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: AlhaiSpacing.xs, vertical: AlhaiSpacing.xxs),
      decoration: BoxDecoration(
          color: (colors[status] ?? Theme.of(context).colorScheme.outline)
              .withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8)),
      child: Text(labels[status] ?? status,
          style: TextStyle(
              fontSize: 11,
              color: colors[status] ?? Theme.of(context).colorScheme.outline,
              fontWeight: FontWeight.w500)),
    );
  }
}
