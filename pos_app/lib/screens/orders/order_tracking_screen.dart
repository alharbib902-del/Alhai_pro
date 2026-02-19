import 'package:flutter/material.dart';
import '../../l10n/generated/app_localizations.dart';

/// شاشة تتبع الطلبات
class OrderTrackingScreen extends StatefulWidget {
  const OrderTrackingScreen({super.key});

  @override
  State<OrderTrackingScreen> createState() => _OrderTrackingScreenState();
}

class _OrderTrackingScreenState extends State<OrderTrackingScreen> {
  late List<_TrackedOrder> _orders;
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      final l10n = AppLocalizations.of(context)!;
      _orders = [
        _TrackedOrder(
          id: 'ORD-2024-001',
          customerName: l10n.defaultUserName,
          customerPhone: '0501234567',
          address: 'حي النزهة، شارع الملك فهد',
          status: 'preparing',
          driverName: 'سعد محمد',
          estimatedTime: 25,
          items: 5,
          total: 245.50,
          createdAt: DateTime.now().subtract(const Duration(minutes: 15)),
        ),
        _TrackedOrder(
          id: 'ORD-2024-002',
          customerName: 'خالد عمر',
          customerPhone: '0551234567',
          address: 'حي الروضة، شارع الأمير سلطان',
          status: 'delivering',
          driverName: 'فهد عبدالله',
          estimatedTime: 10,
          items: 3,
          total: 180.00,
          createdAt: DateTime.now().subtract(const Duration(minutes: 30)),
        ),
        _TrackedOrder(
          id: 'ORD-2024-003',
          customerName: 'محمد علي',
          customerPhone: '0561234567',
          address: 'حي السلامة، شارع التحلية',
          status: 'pending',
          driverName: null,
          estimatedTime: 45,
          items: 8,
          total: 520.00,
          createdAt: DateTime.now().subtract(const Duration(minutes: 5)),
        ),
      ];
      _initialized = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('تتبع الطلبات'),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: () => setState(() {})),
          IconButton(icon: const Icon(Icons.map), onPressed: _showMap),
        ],
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                _StatCard(icon: Icons.pending, label: 'معلق', value: '${_orders.where((o) => o.status == "pending").length}', color: Colors.orange),
                const SizedBox(width: 12),
                _StatCard(icon: Icons.restaurant, label: 'تحضير', value: '${_orders.where((o) => o.status == "preparing").length}', color: Colors.blue),
                const SizedBox(width: 12),
                _StatCard(icon: Icons.delivery_dining, label: 'توصيل', value: '${_orders.where((o) => o.status == "delivering").length}', color: Colors.green),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _orders.length,
              itemBuilder: (context, index) {
                final order = _orders[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: InkWell(
                    onTap: () => _showOrderDetails(order),
                    borderRadius: BorderRadius.circular(12),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(order.id, style: const TextStyle(fontWeight: FontWeight.bold, fontFamily: 'monospace')),
                              const Spacer(),
                              _StatusChip(status: order.status),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              const Icon(Icons.person, size: 16, color: Colors.grey),
                              const SizedBox(width: 4),
                              Text(order.customerName),
                              const Spacer(),
                              Text('${order.total.toStringAsFixed(0)} ر.س', style: const TextStyle(fontWeight: FontWeight.bold)),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(Icons.location_on, size: 16, color: Colors.grey),
                              const SizedBox(width: 4),
                              Expanded(child: Text(order.address, style: TextStyle(fontSize: 12, color: Colors.grey.shade600), overflow: TextOverflow.ellipsis)),
                            ],
                          ),
                          const Divider(height: 24),
                          Row(
                            children: [
                              if (order.driverName != null) ...[
                                const Icon(Icons.directions_car, size: 16, color: Colors.blue),
                                const SizedBox(width: 4),
                                Text(order.driverName!, style: const TextStyle(fontSize: 12)),
                                const SizedBox(width: 16),
                              ],
                              const Icon(Icons.timer, size: 16, color: Colors.orange),
                              const SizedBox(width: 4),
                              Text('${order.estimatedTime} دقيقة', style: const TextStyle(fontSize: 12)),
                              const Spacer(),
                              Text('${order.items} منتجات', style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showMap() {
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('عرض الخريطة يتطلب اشتراك GPS')));
  }

  void _showOrderDetails(_TrackedOrder order) {
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
              child: Container(width: 40, height: 4, margin: const EdgeInsets.only(bottom: 24), decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2))),
            ),
            Row(
              children: [
                Text(order.id, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, fontFamily: 'monospace')),
                const Spacer(),
                _StatusChip(status: order.status),
              ],
            ),
            const SizedBox(height: 24),
            _buildTimeline(order),
            const Divider(height: 32),
            ListTile(leading: const Icon(Icons.person), title: Text(order.customerName), subtitle: Text(order.customerPhone)),
            ListTile(leading: const Icon(Icons.location_on), title: const Text('العنوان'), subtitle: Text(order.address)),
            if (order.driverName != null) ListTile(leading: const Icon(Icons.directions_car), title: Text(order.driverName!), subtitle: const Text('السائق')),
            const Divider(height: 24),
            if (order.status == 'pending')
              FilledButton.icon(onPressed: () { Navigator.pop(context); _updateStatus(order, 'preparing'); }, icon: const Icon(Icons.restaurant), label: const Text('بدء التحضير'))
            else if (order.status == 'preparing')
              FilledButton.icon(onPressed: () { Navigator.pop(context); _updateStatus(order, 'delivering'); }, icon: const Icon(Icons.delivery_dining), label: const Text('بدء التوصيل'))
            else if (order.status == 'delivering')
              FilledButton.icon(onPressed: () { Navigator.pop(context); _updateStatus(order, 'delivered'); }, icon: const Icon(Icons.check_circle), label: const Text('تم التوصيل')),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeline(_TrackedOrder order) {
    final steps = [
      {'label': 'تم الطلب', 'done': true},
      {'label': 'تحضير', 'done': order.status != 'pending'},
      {'label': 'في الطريق', 'done': order.status == 'delivering' || order.status == 'delivered'},
      {'label': 'تم التوصيل', 'done': order.status == 'delivered'},
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
                    decoration: BoxDecoration(shape: BoxShape.circle, color: step['done'] == true ? Colors.green : Colors.grey.shade300),
                    child: Icon(step['done'] == true ? Icons.check : Icons.circle, size: 12, color: Colors.white),
                  ),
                  const SizedBox(height: 4),
                  Text(step['label'] as String, style: TextStyle(fontSize: 10, color: step['done'] == true ? Colors.green : Colors.grey)),
                ],
              ),
              if (!isLast) Expanded(child: Container(height: 2, color: step['done'] == true ? Colors.green : Colors.grey.shade300)),
            ],
          ),
        );
      }).toList(),
    );
  }

  void _updateStatus(_TrackedOrder order, String newStatus) {
    setState(() {
      final index = _orders.indexOf(order);
      if (index != -1) {
        _orders[index] = _TrackedOrder(
          id: order.id, customerName: order.customerName, customerPhone: order.customerPhone,
          address: order.address, status: newStatus, driverName: order.driverName,
          estimatedTime: order.estimatedTime, items: order.items, total: order.total, createdAt: order.createdAt,
        );
      }
    });
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('تم تحديث حالة الطلب ${order.id}')));
  }
}

class _TrackedOrder {
  final String id, customerName, customerPhone, address, status;
  final String? driverName;
  final int estimatedTime, items;
  final double total;
  final DateTime createdAt;
  _TrackedOrder({required this.id, required this.customerName, required this.customerPhone, required this.address, required this.status, this.driverName, required this.estimatedTime, required this.items, required this.total, required this.createdAt});
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
    final colors = {'pending': Colors.orange, 'preparing': Colors.blue, 'delivering': Colors.green, 'delivered': Colors.grey};
    final labels = {'pending': 'معلق', 'preparing': 'تحضير', 'delivering': 'توصيل', 'delivered': 'تم'};
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: (colors[status] ?? Colors.grey).withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
      child: Text(labels[status] ?? status, style: TextStyle(fontSize: 11, color: colors[status], fontWeight: FontWeight.w500)),
    );
  }
}
