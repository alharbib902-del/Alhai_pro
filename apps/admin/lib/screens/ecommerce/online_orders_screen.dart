import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_it/get_it.dart';
import 'package:alhai_shared_ui/alhai_shared_ui.dart';
import 'package:alhai_database/alhai_database.dart';
import 'package:alhai_design_system/alhai_design_system.dart';
import 'package:alhai_l10n/alhai_l10n.dart';
import '../../core/services/sentry_service.dart';

/// شاشة إدارة الطلبات الإلكترونية (Online Orders)
/// Reads from [OrdersDao] with channel='app' (customer app orders, excludes POS).
class OnlineOrdersScreen extends ConsumerStatefulWidget {
  const OnlineOrdersScreen({super.key});

  @override
  ConsumerState<OnlineOrdersScreen> createState() => _OnlineOrdersScreenState();
}

class _OnlineOrdersScreenState extends ConsumerState<OnlineOrdersScreen> {
  final _db = GetIt.I<AppDatabase>();
  String _statusFilter = 'all';
  bool _isLoading = false;
  List<_OnlineOrder> _orders = [];
  List<_OnlineOrder> _filteredOrders = [];

  List<(String, String)> _statusTabs(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return [
      ('all', l10n.statusAll),
      ('created', l10n.statusNew),
      ('preparing', l10n.statusPreparing),
      ('ready', l10n.statusReady),
      ('out_for_delivery', l10n.statusShipped),
      ('delivered', l10n.statusDelivered),
      ('cancelled', l10n.statusCancelled),
    ];
  }

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  Future<void> _loadOrders() async {
    setState(() => _isLoading = true);
    try {
      final storeId = ref.read(currentStoreIdProvider)!;
      final dbOrders = await _db.ordersDao.getOrders(storeId, channel: 'app');

      // Map DB rows to UI model. Empty DB results in empty list,
      // which the UI handles via AppEmptyState.noOrders.
      _orders = dbOrders
          .map(
            (o) => _OnlineOrder(
              id: o.orderNumber,
              customerName: o.customerId ?? '',
              phone: '',
              items: [o.notes ?? ''],
              total: o.total,
              status: o.status,
              platform: o.channel,
              address: o.deliveryAddress ?? '',
              createdAt: o.orderDate,
            ),
          )
          .toList();
    } catch (e, st) {
      await reportError(
        e,
        stackTrace: st,
        hint: 'online_orders_screen: load orders failed',
      );
      // On error keep whatever we had
    } finally {
      if (mounted) {
        setState(() {
          _applyFilter();
          _isLoading = false;
        });
      }
    }
  }

  void _applyFilter() {
    setState(() {
      _filteredOrders = _orders.where((o) {
        return _statusFilter == 'all' || o.status == _statusFilter;
      }).toList();
    });
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'created':
        return Colors.orange;
      case 'preparing':
        return Colors.blue;
      case 'ready':
        return Colors.purple;
      case 'out_for_delivery':
        return Colors.teal;
      case 'delivered':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      default:
        return Theme.of(context).colorScheme.outline;
    }
  }

  IconData _statusIcon(String status) {
    switch (status) {
      case 'created':
        return Icons.fiber_new;
      case 'preparing':
        return Icons.restaurant;
      case 'ready':
        return Icons.check_circle_outline;
      case 'out_for_delivery':
        return Icons.local_shipping;
      case 'delivered':
        return Icons.done_all;
      case 'cancelled':
        return Icons.cancel;
      default:
        return Icons.info_outline;
    }
  }

  String _statusLabel(String status, BuildContext context) {
    final l10n = AppLocalizations.of(context);
    switch (status) {
      case 'created':
        return l10n.statusNew;
      case 'preparing':
        return l10n.statusPreparing;
      case 'ready':
        return l10n.statusReadyForPickup;
      case 'out_for_delivery':
        return l10n.statusShipped;
      case 'delivered':
        return l10n.statusDelivered;
      case 'cancelled':
        return l10n.statusCancelled;
      default:
        return status;
    }
  }

  String _nextStatus(String status) {
    switch (status) {
      case 'created':
        return 'preparing';
      case 'preparing':
        return 'ready';
      case 'ready':
        return 'out_for_delivery';
      case 'out_for_delivery':
        return 'delivered';
      default:
        return status;
    }
  }

  String _nextStatusLabel(String status, BuildContext context) {
    final l10n = AppLocalizations.of(context);
    switch (status) {
      case 'created':
        return l10n.nextStatusAcceptOrder;
      case 'preparing':
        return l10n.nextStatusReady;
      case 'ready':
        return l10n.nextStatusShipped;
      case 'out_for_delivery':
        return l10n.nextStatusDelivered;
      default:
        return '';
    }
  }

  String _platformIcon(String platform) {
    switch (platform) {
      case 'whatsapp':
        return '💬';
      case 'website':
        return '🌐';
      case 'app':
        return '📱';
      default:
        return '📦';
    }
  }

  String _timeAgo(DateTime dt, BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 60) return l10n.timeAgoMinutes(diff.inMinutes);
    if (diff.inHours < 24) return l10n.timeAgoHours(diff.inHours);
    return l10n.timeAgoDays(diff.inDays);
  }

  @override
  Widget build(BuildContext context) {
    final pendingCount = _orders.where((o) => o.status == 'created').length;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Text(AppLocalizations.of(context).onlineOrders),
            if (pendingCount > 0) ...[
              const SizedBox(width: AlhaiSpacing.xs),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '$pendingCount',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onError,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: _loadOrders,
            tooltip: AppLocalizations.of(context).retry,
          ),
        ],
      ),
      body: Column(
        children: [
          // Status filter tabs
          Container(
            height: 44,
            color: Theme.of(context).colorScheme.surface,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              children: _statusTabs(context).map((tab) {
                final count = tab.$1 == 'all'
                    ? _orders.length
                    : _orders.where((o) => o.status == tab.$1).length;
                final isSelected = _statusFilter == tab.$1;
                return Padding(
                  padding: const EdgeInsetsDirectional.only(start: 6),
                  child: FilterChip(
                    label: Text(
                      '${tab.$2} ${count > 0 ? "($count)" : ""}',
                      style: TextStyle(
                        fontSize: 12,
                        color: isSelected
                            ? Theme.of(context).colorScheme.onPrimary
                            : null,
                      ),
                    ),
                    selected: isSelected,
                    onSelected: (_) {
                      setState(() => _statusFilter = tab.$1);
                      _applyFilter();
                    },
                    selectedColor: _statusColor(
                      tab.$1 == 'all' ? 'preparing' : tab.$1,
                    ),
                    backgroundColor: _statusColor(
                      tab.$1 == 'all' ? 'preparing' : tab.$1,
                    ).withValues(alpha: 0.1),
                    showCheckmark: false,
                    padding: const EdgeInsets.symmetric(
                      horizontal: AlhaiSpacing.xxs,
                    ),
                  ),
                );
              }).toList(),
            ),
          ),

          // Orders list
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredOrders.isEmpty
                ? AppEmptyState.noOrders(context)
                : RefreshIndicator(
                    onRefresh: _loadOrders,
                    child: ListView.builder(
                      padding: const EdgeInsets.all(AlhaiSpacing.sm),
                      itemCount: _filteredOrders.length,
                      itemBuilder: (ctx, i) {
                        final order = _filteredOrders[i];
                        final color = _statusColor(order.status);
                        return Card(
                          margin: const EdgeInsets.only(bottom: 10),
                          child: Padding(
                            padding: const EdgeInsets.all(14),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Header
                                Row(
                                  children: [
                                    Text(
                                      _platformIcon(order.platform),
                                      style: const TextStyle(fontSize: 18),
                                    ),
                                    const SizedBox(width: AlhaiSpacing.xs),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            order.customerName,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          Text(
                                            order.id,
                                            style: TextStyle(
                                              fontSize: 11,
                                              color: Theme.of(
                                                context,
                                              ).hintColor,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: color.withValues(alpha: 0.1),
                                        borderRadius: BorderRadius.circular(10),
                                        border: Border.all(
                                          color: color.withValues(alpha: 0.3),
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            _statusIcon(order.status),
                                            size: 12,
                                            color: color,
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            _statusLabel(order.status, context),
                                            style: TextStyle(
                                              fontSize: 11,
                                              color: color,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const Divider(height: 16),

                                // Items
                                ...order.items.map(
                                  (item) => Padding(
                                    padding: const EdgeInsets.only(bottom: 2),
                                    child: Row(
                                      children: [
                                        ExcludeSemantics(
                                          child: Icon(
                                            Icons.circle,
                                            size: 6,
                                            color: Theme.of(context).hintColor,
                                          ),
                                        ),
                                        const SizedBox(width: 6),
                                        Text(
                                          item,
                                          style: const TextStyle(fontSize: 13),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),

                                const SizedBox(height: AlhaiSpacing.xs),

                                // Footer
                                Row(
                                  children: [
                                    ExcludeSemantics(
                                      child: Icon(
                                        Icons.location_on_rounded,
                                        size: 14,
                                        color: Theme.of(context).hintColor,
                                      ),
                                    ),
                                    const SizedBox(width: AlhaiSpacing.xxs),
                                    Expanded(
                                      child: Text(
                                        order.address,
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: Theme.of(context).hintColor,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    Text(
                                      AppLocalizations.of(context).amountSar(
                                        order.total.toStringAsFixed(2),
                                      ),
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15,
                                      ),
                                    ),
                                  ],
                                ),

                                const SizedBox(height: 6),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      _timeAgo(order.createdAt, context),
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: Theme.of(context).hintColor,
                                      ),
                                    ),
                                    if (_nextStatusLabel(
                                      order.status,
                                      context,
                                    ).isNotEmpty)
                                      SizedBox(
                                        height: 30,
                                        child: FilledButton(
                                          onPressed: () {
                                            setState(() {
                                              final idx = _orders.indexOf(
                                                order,
                                              );
                                              if (idx >= 0) {
                                                _orders[idx] = _OnlineOrder(
                                                  id: order.id,
                                                  customerName:
                                                      order.customerName,
                                                  phone: order.phone,
                                                  items: order.items,
                                                  total: order.total,
                                                  status: _nextStatus(
                                                    order.status,
                                                  ),
                                                  platform: order.platform,
                                                  address: order.address,
                                                  createdAt: order.createdAt,
                                                );
                                              }
                                            });
                                            _applyFilter();
                                          },
                                          style: FilledButton.styleFrom(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: AlhaiSpacing.sm,
                                            ),
                                            backgroundColor: color,
                                          ),
                                          child: Text(
                                            _nextStatusLabel(
                                              order.status,
                                              context,
                                            ),
                                            style: const TextStyle(
                                              fontSize: 12,
                                            ),
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

class _OnlineOrder {
  final String id;
  final String customerName;
  final String phone;
  final List<String> items;
  final double total;
  final String status;
  final String platform;
  final String address;
  final DateTime createdAt;

  const _OnlineOrder({
    required this.id,
    required this.customerName,
    required this.phone,
    required this.items,
    required this.total,
    required this.status,
    required this.platform,
    required this.address,
    required this.createdAt,
  });
}
