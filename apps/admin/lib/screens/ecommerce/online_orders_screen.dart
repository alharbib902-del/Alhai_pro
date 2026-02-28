import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// شاشة إدارة الطلبات الإلكترونية (Online Orders)
class OnlineOrdersScreen extends ConsumerStatefulWidget {
  const OnlineOrdersScreen({super.key});

  @override
  ConsumerState<OnlineOrdersScreen> createState() => _OnlineOrdersScreenState();
}

class _OnlineOrdersScreenState extends ConsumerState<OnlineOrdersScreen> {
  String _statusFilter = 'all';
  bool _isLoading = false;
  List<_OnlineOrder> _orders = [];
  List<_OnlineOrder> _filteredOrders = [];

  final _statusTabs = [
    ('all', 'الكل'),
    ('created', 'جديد'),
    ('preparing', 'قيد التجهيز'),
    ('ready', 'جاهز'),
    ('out_for_delivery', 'تم الشحن'),
    ('delivered', 'تم التسليم'),
    ('cancelled', 'ملغي'),
  ];

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  Future<void> _loadOrders() async {
    setState(() => _isLoading = true);
    // Mock data until ecommerce/online orders table is ready
    await Future.delayed(const Duration(milliseconds: 300));
    if (mounted) {
      setState(() {
        _orders = [
          _OnlineOrder(
            id: 'ORD-001',
            customerName: 'أحمد محمد',
            phone: '0501234567',
            items: ['كوكاكولا × 2', 'شيبس × 1'],
            total: 45.50,
            status: 'created',
            platform: 'app',
            address: 'حي العليا، الرياض',
            createdAt: DateTime.now().subtract(const Duration(minutes: 15)),
          ),
          _OnlineOrder(
            id: 'ORD-002',
            customerName: 'سارة علي',
            phone: '0559876543',
            items: ['عصير برتقال × 3', 'ماء × 6'],
            total: 78.00,
            status: 'preparing',
            platform: 'website',
            address: 'حي الملقا، الرياض',
            createdAt: DateTime.now().subtract(const Duration(hours: 1)),
          ),
          _OnlineOrder(
            id: 'ORD-003',
            customerName: 'خالد الأحمد',
            phone: '0533456789',
            items: ['قهوة سادة × 1', 'كيك × 2'],
            total: 120.00,
            status: 'ready',
            platform: 'whatsapp',
            address: 'حي النزهة، الرياض',
            createdAt: DateTime.now().subtract(const Duration(hours: 2)),
          ),
          _OnlineOrder(
            id: 'ORD-004',
            customerName: 'منى حسن',
            phone: '0501111222',
            items: ['منتجات متنوعة × 5'],
            total: 250.00,
            status: 'delivered',
            platform: 'app',
            address: 'حي الربوة، الرياض',
            createdAt: DateTime.now().subtract(const Duration(hours: 5)),
          ),
        ];
        _applyFilter();
        _isLoading = false;
      });
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
      case 'created': return Colors.orange;
      case 'preparing': return Colors.blue;
      case 'ready': return Colors.purple;
      case 'out_for_delivery': return Colors.teal;
      case 'delivered': return Colors.green;
      case 'cancelled': return Colors.red;
      default: return Theme.of(context).colorScheme.outline;
    }
  }

  String _statusLabel(String status) {
    switch (status) {
      case 'created': return 'جديد';
      case 'preparing': return 'قيد التجهيز';
      case 'ready': return 'جاهز للاستلام';
      case 'out_for_delivery': return 'تم الشحن';
      case 'delivered': return 'تم التسليم';
      case 'cancelled': return 'ملغي';
      default: return status;
    }
  }

  String _nextStatus(String status) {
    switch (status) {
      case 'created': return 'preparing';
      case 'preparing': return 'ready';
      case 'ready': return 'out_for_delivery';
      case 'out_for_delivery': return 'delivered';
      default: return status;
    }
  }

  String _nextStatusLabel(String status) {
    switch (status) {
      case 'created': return 'قبول الطلب';
      case 'preparing': return 'جاهز';
      case 'ready': return 'تم الشحن';
      case 'out_for_delivery': return 'تم التسليم';
      default: return '';
    }
  }

  String _platformIcon(String platform) {
    switch (platform) {
      case 'whatsapp': return '💬';
      case 'website': return '🌐';
      case 'app': return '📱';
      default: return '📦';
    }
  }

  String _timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 60) return 'منذ ${diff.inMinutes} دقيقة';
    if (diff.inHours < 24) return 'منذ ${diff.inHours} ساعة';
    return 'منذ ${diff.inDays} يوم';
  }

  @override
  Widget build(BuildContext context) {
    final pendingCount = _orders.where((o) => o.status == 'created').length;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Text('الطلبات الإلكترونية'),
            if (pendingCount > 0) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '$pendingCount',
                  style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ],
        ),
        actions: [
          IconButton(icon: const Icon(Icons.refresh_rounded), onPressed: _loadOrders),
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
              children: _statusTabs.map((tab) {
                final count = tab.$1 == 'all'
                    ? _orders.length
                    : _orders.where((o) => o.status == tab.$1).length;
                final isSelected = _statusFilter == tab.$1;
                return Padding(
                  padding: const EdgeInsetsDirectional.only(start: 6),
                  child: FilterChip(
                    label: Text('${tab.$2} ${count > 0 ? "($count)" : ""}',
                        style: TextStyle(
                          fontSize: 12,
                          color: isSelected ? Colors.white : null,
                        )),
                    selected: isSelected,
                    onSelected: (_) {
                      setState(() => _statusFilter = tab.$1);
                      _applyFilter();
                    },
                    selectedColor: _statusColor(tab.$1 == 'all' ? 'preparing' : tab.$1),
                    backgroundColor: _statusColor(tab.$1 == 'all' ? 'preparing' : tab.$1)
                        .withValues(alpha: 0.1),
                    showCheckmark: false,
                    padding: const EdgeInsets.symmetric(horizontal: 4),
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
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.shopping_bag_outlined, size: 64, color: Theme.of(context).hintColor),
                            const SizedBox(height: 12),
                            Text(
                              'لا توجد طلبات ${_statusFilter != 'all' ? _statusLabel(_statusFilter) : ''}',
                              style: TextStyle(color: Theme.of(context).hintColor),
                            ),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _loadOrders,
                        child: ListView.builder(
                          padding: const EdgeInsets.all(12),
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
                                        Text(_platformIcon(order.platform),
                                            style: const TextStyle(fontSize: 18)),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(order.customerName,
                                                  style: const TextStyle(
                                                      fontWeight: FontWeight.bold)),
                                              Text(order.id,
                                                  style: TextStyle(
                                                      fontSize: 11, color: Theme.of(context).hintColor)),
                                            ],
                                          ),
                                        ),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 10, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: color.withValues(alpha: 0.1),
                                            borderRadius: BorderRadius.circular(10),
                                            border: Border.all(color: color.withValues(alpha: 0.3)),
                                          ),
                                          child: Text(
                                            _statusLabel(order.status),
                                            style: TextStyle(
                                              fontSize: 11,
                                              color: color,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const Divider(height: 16),

                                    // Items
                                    ...order.items.map((item) => Padding(
                                      padding: const EdgeInsets.only(bottom: 2),
                                      child: Row(
                                        children: [
                                          Icon(Icons.circle, size: 6, color: Theme.of(context).hintColor),
                                          const SizedBox(width: 6),
                                          Text(item, style: const TextStyle(fontSize: 13)),
                                        ],
                                      ),
                                    )),

                                    const SizedBox(height: 8),

                                    // Footer
                                    Row(
                                      children: [
                                        Icon(Icons.location_on_rounded,
                                            size: 14, color: Theme.of(context).hintColor),
                                        const SizedBox(width: 4),
                                        Expanded(
                                          child: Text(
                                            order.address,
                                            style: TextStyle(fontSize: 11, color: Theme.of(context).hintColor),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        Text(
                                          '${order.total.toStringAsFixed(2)} ر.س',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 15,
                                          ),
                                        ),
                                      ],
                                    ),

                                    const SizedBox(height: 6),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          _timeAgo(order.createdAt),
                                          style: TextStyle(fontSize: 11, color: Theme.of(context).hintColor),
                                        ),
                                        if (_nextStatusLabel(order.status).isNotEmpty)
                                          SizedBox(
                                            height: 30,
                                            child: FilledButton(
                                              onPressed: () {
                                                setState(() {
                                                  final idx = _orders.indexOf(order);
                                                  if (idx >= 0) {
                                                    _orders[idx] = _OnlineOrder(
                                                      id: order.id,
                                                      customerName: order.customerName,
                                                      phone: order.phone,
                                                      items: order.items,
                                                      total: order.total,
                                                      status: _nextStatus(order.status),
                                                      platform: order.platform,
                                                      address: order.address,
                                                      createdAt: order.createdAt,
                                                    );
                                                  }
                                                });
                                                _applyFilter();
                                              },
                                              style: FilledButton.styleFrom(
                                                padding: const EdgeInsets.symmetric(horizontal: 12),
                                                backgroundColor: color,
                                              ),
                                              child: Text(
                                                _nextStatusLabel(order.status),
                                                style: const TextStyle(fontSize: 12),
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
