import 'package:flutter/material.dart';

/// شاشة سجل الطلبات
class OrderHistoryScreen extends StatefulWidget {
  const OrderHistoryScreen({super.key});

  @override
  State<OrderHistoryScreen> createState() => _OrderHistoryScreenState();
}

class _OrderHistoryScreenState extends State<OrderHistoryScreen> {
  String _filterStatus = 'all';
  String _filterChannel = 'all';
  DateTimeRange? _dateRange;
  final _searchController = TextEditingController();
  
  final List<_Order> _orders = [
    _Order(
      id: 'ORD-2024-001',
      customerName: 'أحمد محمد',
      date: DateTime.now().subtract(const Duration(hours: 2)),
      total: 350,
      items: 5,
      status: 'completed',
      paymentMethod: 'cash',
      channel: 'pos',
    ),
    _Order(
      id: 'ORD-2024-002',
      customerName: 'عميل زائر',
      date: DateTime.now().subtract(const Duration(hours: 4)),
      total: 125,
      items: 2,
      status: 'completed',
      paymentMethod: 'card',
      channel: 'pos',
    ),
    _Order(
      id: 'ORD-2024-003',
      customerName: 'خالد عمر',
      date: DateTime.now().subtract(const Duration(hours: 6)),
      total: 890,
      items: 8,
      status: 'pending',
      paymentMethod: 'credit',
      channel: 'whatsapp',
    ),
    _Order(
      id: 'ORD-2024-004',
      customerName: 'محمد علي',
      date: DateTime.now().subtract(const Duration(days: 1)),
      total: 450,
      items: 4,
      status: 'cancelled',
      paymentMethod: 'cash',
      channel: 'pos',
    ),
    _Order(
      id: 'ORD-2024-005',
      customerName: 'فهد سعد',
      date: DateTime.now().subtract(const Duration(days: 1, hours: 3)),
      total: 1200,
      items: 12,
      status: 'completed',
      paymentMethod: 'mixed',
      channel: 'app',
    ),
  ];

  List<_Order> get _filteredOrders {
    var list = _orders;
    if (_filterStatus != 'all') {
      list = list.where((o) => o.status == _filterStatus).toList();
    }
    if (_filterChannel != 'all') {
      list = list.where((o) => o.channel == _filterChannel).toList();
    }
    if (_searchController.text.isNotEmpty) {
      list = list.where((o) => 
        o.id.contains(_searchController.text) ||
        o.customerName.contains(_searchController.text)
      ).toList();
    }
    return list;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('سجل الطلبات'),
        actions: [
          IconButton(
            icon: const Icon(Icons.date_range),
            tooltip: 'تحديد فترة',
            onPressed: _selectDateRange,
          ),
          IconButton(
            icon: const Icon(Icons.filter_list),
            tooltip: 'فلترة',
            onPressed: _showFilterSheet,
          ),
          IconButton(
            icon: const Icon(Icons.file_download),
            tooltip: 'تصدير',
            onPressed: _exportOrders,
          ),
        ],
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'بحث برقم الطلب أو اسم العميل...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              ),
              onChanged: (_) => setState(() {}),
            ),
          ),
          
          // Filter chips
          if (_filterStatus != 'all' || _filterChannel != 'all')
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  if (_filterStatus != 'all')
                    Chip(
                      label: Text(_getStatusName(_filterStatus)),
                      onDeleted: () => setState(() => _filterStatus = 'all'),
                      deleteIconColor: Colors.grey,
                    ),
                  if (_filterChannel != 'all') ...[
                    const SizedBox(width: 8),
                    Chip(
                      label: Text(_getChannelName(_filterChannel)),
                      onDeleted: () => setState(() => _filterChannel = 'all'),
                      deleteIconColor: Colors.grey,
                    ),
                  ],
                ],
              ),
            ),
          
          // Stats row
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                _StatBadge(
                  label: 'اليوم',
                  value: '${_orders.where((o) => o.date.day == DateTime.now().day).length}',
                  color: Colors.blue,
                ),
                const SizedBox(width: 8),
                _StatBadge(
                  label: 'مكتمل',
                  value: '${_orders.where((o) => o.status == "completed").length}',
                  color: Colors.green,
                ),
                const SizedBox(width: 8),
                _StatBadge(
                  label: 'قيد الانتظار',
                  value: '${_orders.where((o) => o.status == "pending").length}',
                  color: Colors.orange,
                ),
                const SizedBox(width: 8),
                _StatBadge(
                  label: 'ملغي',
                  value: '${_orders.where((o) => o.status == "cancelled").length}',
                  color: Colors.red,
                ),
              ],
            ),
          ),
          
          // Orders list
          Expanded(
            child: _filteredOrders.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.receipt_long, size: 64, color: Colors.grey.shade300),
                        const SizedBox(height: 16),
                        const Text('لا توجد طلبات', style: TextStyle(fontSize: 18)),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _filteredOrders.length,
                    itemBuilder: (context, index) {
                      final order = _filteredOrders[index];
                      return _OrderCard(
                        order: order,
                        onTap: () => _showOrderDetails(order),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
  
  String _getStatusName(String status) {
    switch (status) {
      case 'completed': return 'مكتمل';
      case 'pending': return 'قيد الانتظار';
      case 'cancelled': return 'ملغي';
      default: return status;
    }
  }
  
  String _getChannelName(String channel) {
    switch (channel) {
      case 'pos': return 'نقطة البيع';
      case 'whatsapp': return 'واتساب';
      case 'app': return 'التطبيق';
      default: return channel;
    }
  }
  
  void _selectDateRange() async {
    final range = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2024),
      lastDate: DateTime.now(),
      initialDateRange: _dateRange,
    );
    if (range != null) {
      setState(() => _dateRange = range);
    }
  }
  
  void _showFilterSheet() {
    showModalBottomSheet(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setSheetState) => Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('فلترة الطلبات', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              const Text('الحالة'),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: [
                  ChoiceChip(
                    label: const Text('الكل'),
                    selected: _filterStatus == 'all',
                    onSelected: (_) {
                      setSheetState(() => _filterStatus = 'all');
                      setState(() {});
                    },
                  ),
                  ChoiceChip(
                    label: const Text('مكتمل'),
                    selected: _filterStatus == 'completed',
                    onSelected: (_) {
                      setSheetState(() => _filterStatus = 'completed');
                      setState(() {});
                    },
                  ),
                  ChoiceChip(
                    label: const Text('قيد الانتظار'),
                    selected: _filterStatus == 'pending',
                    onSelected: (_) {
                      setSheetState(() => _filterStatus = 'pending');
                      setState(() {});
                    },
                  ),
                  ChoiceChip(
                    label: const Text('ملغي'),
                    selected: _filterStatus == 'cancelled',
                    onSelected: (_) {
                      setSheetState(() => _filterStatus = 'cancelled');
                      setState(() {});
                    },
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Text('القناة'),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: [
                  ChoiceChip(
                    label: const Text('الكل'),
                    selected: _filterChannel == 'all',
                    onSelected: (_) {
                      setSheetState(() => _filterChannel = 'all');
                      setState(() {});
                    },
                  ),
                  ChoiceChip(
                    label: const Text('نقطة البيع'),
                    selected: _filterChannel == 'pos',
                    onSelected: (_) {
                      setSheetState(() => _filterChannel = 'pos');
                      setState(() {});
                    },
                  ),
                  ChoiceChip(
                    label: const Text('واتساب'),
                    selected: _filterChannel == 'whatsapp',
                    onSelected: (_) {
                      setSheetState(() => _filterChannel = 'whatsapp');
                      setState(() {});
                    },
                  ),
                  ChoiceChip(
                    label: const Text('التطبيق'),
                    selected: _filterChannel == 'app',
                    onSelected: (_) {
                      setSheetState(() => _filterChannel = 'app');
                      setState(() {});
                    },
                  ),
                ],
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('تطبيق'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  void _showOrderDetails(_Order order) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.4,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) => ListView(
          controller: scrollController,
          padding: const EdgeInsets.all(24),
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 24),
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(order.id, style: Theme.of(context).textTheme.titleLarge),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getStatusColor(order.status).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    _getStatusName(order.status),
                    style: TextStyle(color: _getStatusColor(order.status), fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _DetailRow(icon: Icons.person, label: 'العميل', value: order.customerName),
            _DetailRow(icon: Icons.access_time, label: 'التاريخ', value: _formatDateTime(order.date)),
            _DetailRow(icon: Icons.shopping_bag, label: 'المنتجات', value: '${order.items} منتج'),
            _DetailRow(icon: Icons.payment, label: 'الدفع', value: _getPaymentName(order.paymentMethod)),
            _DetailRow(icon: Icons.storefront, label: 'القناة', value: _getChannelName(order.channel)),
            const Divider(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('الإجمالي', style: TextStyle(fontSize: 18)),
                Text(
                  '${order.total.toStringAsFixed(0)} ر.س',
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.green),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.print),
                    label: const Text('طباعة'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.share),
                    label: const Text('مشاركة'),
                  ),
                ),
              ],
            ),
            if (order.status == 'completed') ...[
              const SizedBox(height: 12),
              FilledButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.replay),
                label: const Text('إرجاع'),
                style: FilledButton.styleFrom(
                  backgroundColor: Colors.orange,
                  minimumSize: const Size(double.infinity, 48),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
  
  Color _getStatusColor(String status) {
    switch (status) {
      case 'completed': return Colors.green;
      case 'pending': return Colors.orange;
      case 'cancelled': return Colors.red;
      default: return Colors.grey;
    }
  }
  
  String _getPaymentName(String method) {
    switch (method) {
      case 'cash': return 'نقدي';
      case 'card': return 'بطاقة';
      case 'credit': return 'آجل';
      case 'mixed': return 'مختلط';
      default: return method;
    }
  }
  
  String _formatDateTime(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);
    if (diff.inHours < 24) {
      return 'منذ ${diff.inHours} ساعة';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
  
  void _exportOrders() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تصدير الطلبات'),
        content: const Text('اختر صيغة التصدير'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('تم التصدير كـ Excel')),
              );
            },
            child: const Text('Excel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('تم التصدير كـ PDF')),
              );
            },
            child: const Text('PDF'),
          ),
        ],
      ),
    );
  }
}

class _Order {
  final String id;
  final String customerName;
  final DateTime date;
  final double total;
  final int items;
  final String status;
  final String paymentMethod;
  final String channel;
  
  _Order({
    required this.id,
    required this.customerName,
    required this.date,
    required this.total,
    required this.items,
    required this.status,
    required this.paymentMethod,
    required this.channel,
  });
}

class _OrderCard extends StatelessWidget {
  final _Order order;
  final VoidCallback onTap;
  
  const _OrderCard({required this.order, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: _getStatusColor(order.status).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      _getChannelIcon(order.channel),
                      color: _getStatusColor(order.status),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(order.id, style: const TextStyle(fontWeight: FontWeight.bold)),
                        Text(
                          order.customerName,
                          style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '${order.total.toStringAsFixed(0)} ر.س',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      Text(
                        '${order.items} منتج',
                        style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                      ),
                    ],
                  ),
                ],
              ),
              const Divider(height: 24),
              Row(
                children: [
                  Icon(Icons.access_time, size: 14, color: Colors.grey.shade600),
                  const SizedBox(width: 4),
                  Text(
                    _formatTime(order.date),
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),
                  const SizedBox(width: 16),
                  Icon(Icons.payment, size: 14, color: Colors.grey.shade600),
                  const SizedBox(width: 4),
                  Text(
                    _getPaymentName(order.paymentMethod),
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: _getStatusColor(order.status).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      _getStatusName(order.status),
                      style: TextStyle(
                        fontSize: 11,
                        color: _getStatusColor(order.status),
                        fontWeight: FontWeight.w500,
                      ),
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
  
  Color _getStatusColor(String status) {
    switch (status) {
      case 'completed': return Colors.green;
      case 'pending': return Colors.orange;
      case 'cancelled': return Colors.red;
      default: return Colors.grey;
    }
  }
  
  IconData _getChannelIcon(String channel) {
    switch (channel) {
      case 'pos': return Icons.point_of_sale;
      case 'whatsapp': return Icons.chat;
      case 'app': return Icons.phone_android;
      default: return Icons.shopping_cart;
    }
  }
  
  String _getStatusName(String status) {
    switch (status) {
      case 'completed': return 'مكتمل';
      case 'pending': return 'قيد الانتظار';
      case 'cancelled': return 'ملغي';
      default: return status;
    }
  }
  
  String _getPaymentName(String method) {
    switch (method) {
      case 'cash': return 'نقدي';
      case 'card': return 'بطاقة';
      case 'credit': return 'آجل';
      case 'mixed': return 'مختلط';
      default: return method;
    }
  }
  
  String _formatTime(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);
    if (diff.inMinutes < 60) {
      return 'منذ ${diff.inMinutes} دقيقة';
    } else if (diff.inHours < 24) {
      return 'منذ ${diff.inHours} ساعة';
    } else {
      return 'منذ ${diff.inDays} يوم';
    }
  }
}

class _StatBadge extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  
  const _StatBadge({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(value, style: TextStyle(fontWeight: FontWeight.bold, color: color)),
          const SizedBox(width: 4),
          Text(label, style: TextStyle(fontSize: 12, color: color)),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  
  const _DetailRow({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey.shade600),
          const SizedBox(width: 12),
          Text(label, style: TextStyle(color: Colors.grey.shade600)),
          const Spacer(),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}
