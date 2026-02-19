import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/local/app_database.dart';
import '../../di/injection.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../providers/products_providers.dart';

/// شاشة سجل الطلبات
class OrderHistoryScreen extends ConsumerStatefulWidget {
  const OrderHistoryScreen({super.key});

  @override
  ConsumerState<OrderHistoryScreen> createState() => _OrderHistoryScreenState();
}

class _OrderHistoryScreenState extends ConsumerState<OrderHistoryScreen> {
  String _filterStatus = 'all';
  String _filterChannel = 'all';
  DateTimeRange? _dateRange;
  final _searchController = TextEditingController();
  List<OrdersTableData> _orders = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final storeId = ref.read(currentStoreIdProvider);
      if (storeId == null) return;
      final db = getIt<AppDatabase>();
      final orders = await db.ordersDao.getOrders(storeId);
      if (mounted) {
        setState(() {
          _orders = orders;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  List<OrdersTableData> get _filteredOrders {
    var list = _orders;
    if (_filterStatus != 'all') {
      list = list.where((o) => o.status == _filterStatus).toList();
    }
    if (_filterChannel != 'all') {
      list = list.where((o) => o.channel == _filterChannel).toList();
    }
    if (_searchController.text.isNotEmpty) {
      final query = _searchController.text.toLowerCase();
      list = list.where((o) =>
        o.orderNumber.toLowerCase().contains(query) ||
        (o.customerId ?? '').toLowerCase().contains(query)
      ).toList();
    }
    return list;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.orderHistory)),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final now = DateTime.now();
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.orderHistory),
        actions: [
          IconButton(
            icon: const Icon(Icons.date_range),
            tooltip: l10n.selectDateRange,
            onPressed: _selectDateRange,
          ),
          IconButton(
            icon: const Icon(Icons.filter_list),
            tooltip: l10n.filter,
            onPressed: _showFilterSheet,
          ),
          IconButton(
            icon: const Icon(Icons.file_download),
            tooltip: l10n.exportOrders,
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
                hintText: l10n.orderSearchHint,
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
                      label: Text(_getStatusName(_filterStatus, l10n)),
                      onDeleted: () => setState(() => _filterStatus = 'all'),
                      deleteIconColor: Colors.grey,
                    ),
                  if (_filterChannel != 'all') ...[
                    const SizedBox(width: 8),
                    Chip(
                      label: Text(_getChannelName(_filterChannel, l10n)),
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
                  label: l10n.today,
                  value: '${_orders.where((o) => o.orderDate.day == now.day && o.orderDate.month == now.month && o.orderDate.year == now.year).length}',
                  color: Colors.blue,
                ),
                const SizedBox(width: 8),
                _StatBadge(
                  label: l10n.completed,
                  value: '${_orders.where((o) => o.status == "delivered").length}',
                  color: Colors.green,
                ),
                const SizedBox(width: 8),
                _StatBadge(
                  label: l10n.pending,
                  value: '${_orders.where((o) => o.status == "pending").length}',
                  color: Colors.orange,
                ),
                const SizedBox(width: 8),
                _StatBadge(
                  label: l10n.cancelled,
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
                        Text(l10n.noOrders, style: const TextStyle(fontSize: 18)),
                      ],
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: _loadData,
                    child: ListView.builder(
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
          ),
        ],
      ),
    );
  }
  
  String _getStatusName(String status, AppLocalizations l10n) {
    switch (status) {
      case 'delivered': return l10n.completed;
      case 'pending': return l10n.pending;
      case 'confirmed': return l10n.orderStatusConfirmed;
      case 'preparing': return l10n.orderStatusPreparing;
      case 'ready': return l10n.orderStatusReady;
      case 'delivering': return l10n.orderStatusDelivering;
      case 'cancelled': return l10n.cancelled;
      default: return status;
    }
  }

  String _getChannelName(String channel, AppLocalizations l10n) {
    switch (channel) {
      case 'pos': return l10n.channelPos;
      case 'app': return l10n.channelApp;
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
    final l10n = AppLocalizations.of(context)!;
    showModalBottomSheet(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setSheetState) => Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(l10n.filterOrders, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              Text(l10n.status),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: [
                  ChoiceChip(
                    label: Text(l10n.all),
                    selected: _filterStatus == 'all',
                    onSelected: (_) {
                      setSheetState(() => _filterStatus = 'all');
                      setState(() {});
                    },
                  ),
                  ChoiceChip(
                    label: Text(l10n.completed),
                    selected: _filterStatus == 'delivered',
                    onSelected: (_) {
                      setSheetState(() => _filterStatus = 'delivered');
                      setState(() {});
                    },
                  ),
                  ChoiceChip(
                    label: Text(l10n.pending),
                    selected: _filterStatus == 'pending',
                    onSelected: (_) {
                      setSheetState(() => _filterStatus = 'pending');
                      setState(() {});
                    },
                  ),
                  ChoiceChip(
                    label: Text(l10n.cancelled),
                    selected: _filterStatus == 'cancelled',
                    onSelected: (_) {
                      setSheetState(() => _filterStatus = 'cancelled');
                      setState(() {});
                    },
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(l10n.channelLabel),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: [
                  ChoiceChip(
                    label: Text(l10n.all),
                    selected: _filterChannel == 'all',
                    onSelected: (_) {
                      setSheetState(() => _filterChannel = 'all');
                      setState(() {});
                    },
                  ),
                  ChoiceChip(
                    label: Text(l10n.channelPos),
                    selected: _filterChannel == 'pos',
                    onSelected: (_) {
                      setSheetState(() => _filterChannel = 'pos');
                      setState(() {});
                    },
                  ),
                  ChoiceChip(
                    label: Text(l10n.channelWhatsapp),
                    selected: _filterChannel == 'whatsapp',
                    onSelected: (_) {
                      setSheetState(() => _filterChannel = 'whatsapp');
                      setState(() {});
                    },
                  ),
                  ChoiceChip(
                    label: Text(l10n.channelApp),
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
                  child: Text(l10n.confirm),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  void _showOrderDetails(OrdersTableData order) {
    final l10n = AppLocalizations.of(context)!;
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
                Text(order.orderNumber, style: Theme.of(context).textTheme.titleLarge),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getStatusColor(order.status).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    _getStatusName(order.status, l10n),
                    style: TextStyle(color: _getStatusColor(order.status), fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _DetailRow(icon: Icons.person, label: l10n.customer, value: order.customerId ?? l10n.guestCustomer),
            _DetailRow(icon: Icons.access_time, label: l10n.date, value: _formatDateTime(order.orderDate, l10n)),
            _DetailRow(icon: Icons.shopping_bag, label: l10n.products, value: '—'),
            _DetailRow(icon: Icons.payment, label: l10n.payment, value: _getPaymentName(order.paymentMethod ?? 'cash', l10n)),
            _DetailRow(icon: Icons.storefront, label: l10n.channelLabel, value: _getChannelName(order.channel, l10n)),
            const Divider(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(l10n.total, style: const TextStyle(fontSize: 18)),
                Text(
                  l10n.priceWithCurrency(order.total.toStringAsFixed(0)),
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
                    label: Text(l10n.printReceipt),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.share),
                    label: Text(l10n.shareAction),
                  ),
                ),
              ],
            ),
            if (order.status == 'delivered') ...[
              const SizedBox(height: 12),
              FilledButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.replay),
                label: Text(l10n.returnText),
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
      case 'delivered': return Colors.green;
      case 'pending': return Colors.orange;
      case 'confirmed': return Colors.blue;
      case 'preparing': return Colors.indigo;
      case 'ready': return Colors.teal;
      case 'delivering': return Colors.cyan;
      case 'cancelled': return Colors.red;
      default: return Colors.grey;
    }
  }

  String _getPaymentName(String method, AppLocalizations l10n) {
    switch (method) {
      case 'cash': return l10n.paymentCashType;
      case 'card': return l10n.card;
      case 'credit': return l10n.credit;
      case 'mixed': return l10n.paymentMixed;
      default: return method;
    }
  }

  String _formatDateTime(DateTime date, AppLocalizations l10n) {
    final now = DateTime.now();
    final diff = now.difference(date);
    if (diff.inHours < 24) {
      return l10n.hoursAgo(diff.inHours);
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
  
  void _exportOrders() {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.exportOrders),
        content: Text(l10n.selectExportFormat),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(l10n.exportedAsExcel)),
              );
            },
            child: const Text('Excel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(l10n.exportedAsPdf)),
              );
            },
            child: const Text('PDF'),
          ),
        ],
      ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  final OrdersTableData order;
  final VoidCallback onTap;

  const _OrderCard({required this.order, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
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
                        Text(order.orderNumber, style: const TextStyle(fontWeight: FontWeight.bold)),
                        Text(
                          order.customerId ?? l10n.guestCustomer,
                          style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        l10n.priceWithCurrency(order.total.toStringAsFixed(0)),
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      Text(
                        _getChannelName(order.channel, l10n),
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
                    _formatTime(order.orderDate, l10n),
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),
                  const SizedBox(width: 16),
                  Icon(Icons.payment, size: 14, color: Colors.grey.shade600),
                  const SizedBox(width: 4),
                  Text(
                    _getPaymentName(order.paymentMethod ?? 'cash', l10n),
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
                      _getStatusName(order.status, l10n),
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
      case 'delivered': return Colors.green;
      case 'pending': return Colors.orange;
      case 'confirmed': return Colors.blue;
      case 'preparing': return Colors.indigo;
      case 'ready': return Colors.teal;
      case 'delivering': return Colors.cyan;
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

  String _getStatusName(String status, AppLocalizations l10n) {
    switch (status) {
      case 'delivered': return l10n.completed;
      case 'pending': return l10n.pending;
      case 'confirmed': return l10n.orderStatusConfirmed;
      case 'preparing': return l10n.orderStatusPreparing;
      case 'ready': return l10n.orderStatusReady;
      case 'delivering': return l10n.orderStatusDelivering;
      case 'cancelled': return l10n.cancelled;
      default: return status;
    }
  }

  String _getPaymentName(String method, AppLocalizations l10n) {
    switch (method) {
      case 'cash': return l10n.paymentCashType;
      case 'card': return l10n.card;
      case 'online': return l10n.paymentOnline;
      case 'credit': return l10n.credit;
      case 'mixed': return l10n.paymentMixed;
      default: return method;
    }
  }

  String _getChannelName(String channel, AppLocalizations l10n) {
    switch (channel) {
      case 'pos': return l10n.channelPos;
      case 'app': return l10n.channelApp;
      default: return channel;
    }
  }

  String _formatTime(DateTime date, AppLocalizations l10n) {
    final now = DateTime.now();
    final diff = now.difference(date);
    if (diff.inMinutes < 60) {
      return l10n.minutesAgoTime(diff.inMinutes);
    } else if (diff.inHours < 24) {
      return l10n.hoursAgoTime(diff.inHours);
    } else {
      return l10n.daysAgoTime(diff.inDays);
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
