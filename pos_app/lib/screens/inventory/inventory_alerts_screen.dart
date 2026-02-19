import 'package:flutter/material.dart';

/// شاشة تنبيهات المخزون
class InventoryAlertsScreen extends StatefulWidget {
  const InventoryAlertsScreen({super.key});

  @override
  State<InventoryAlertsScreen> createState() => _InventoryAlertsScreenState();
}

class _InventoryAlertsScreenState extends State<InventoryAlertsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _lowStockThreshold = 10;
  bool _notifyLowStock = true;
  bool _notifyExpiry = true;
  
  final List<_AlertItem> _alerts = [
    _AlertItem(
      id: '1',
      productName: 'أرز بسمتي 5 كجم',
      barcode: '6281001234567',
      type: 'low_stock',
      currentStock: 3,
      threshold: 10,
      expiryDate: null,
      priority: 'high',
      createdAt: DateTime.now().subtract(const Duration(hours: 2)),
    ),
    _AlertItem(
      id: '2',
      productName: 'حليب طازج 1 لتر',
      barcode: '6281007654321',
      type: 'expiry',
      currentStock: 25,
      threshold: 10,
      expiryDate: DateTime.now().add(const Duration(days: 3)),
      priority: 'high',
      createdAt: DateTime.now().subtract(const Duration(hours: 5)),
    ),
    _AlertItem(
      id: '3',
      productName: 'زيت ذرة 1.5 لتر',
      barcode: '6281009876543',
      type: 'low_stock',
      currentStock: 8,
      threshold: 10,
      expiryDate: null,
      priority: 'medium',
      createdAt: DateTime.now().subtract(const Duration(hours: 8)),
    ),
    _AlertItem(
      id: '4',
      productName: 'جبن شرائح',
      barcode: '6281005432109',
      type: 'expiry',
      currentStock: 15,
      threshold: 10,
      expiryDate: DateTime.now().add(const Duration(days: 7)),
      priority: 'medium',
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
    ),
    _AlertItem(
      id: '5',
      productName: 'سكر أبيض 2 كجم',
      barcode: '6281001111111',
      type: 'low_stock',
      currentStock: 5,
      threshold: 10,
      expiryDate: null,
      priority: 'high',
      createdAt: DateTime.now().subtract(const Duration(minutes: 30)),
    ),
  ];

  List<_AlertItem> get _lowStockAlerts => _alerts.where((a) => a.type == 'low_stock').toList();
  List<_AlertItem> get _expiryAlerts => _alerts.where((a) => a.type == 'expiry').toList();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('تنبيهات المخزون'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            tooltip: 'إعدادات التنبيهات',
            onPressed: _showSettings,
          ),
          IconButton(
            icon: const Icon(Icons.check_circle),
            tooltip: 'تأكيد الكل',
            onPressed: _acknowledgeAll,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: 'الكل (${_alerts.length})'),
            Tab(text: 'نفاد مخزون (${_lowStockAlerts.length})'),
            Tab(text: 'انتهاء صلاحية (${_expiryAlerts.length})'),
          ],
        ),
      ),
      body: Column(
        children: [
          // Summary cards
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: _SummaryCard(
                    icon: Icons.warning,
                    label: 'تنبيهات عاجلة',
                    value: '${_alerts.where((a) => a.priority == "high").length}',
                    color: Colors.red,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _SummaryCard(
                    icon: Icons.inventory,
                    label: 'نفاد مخزون',
                    value: '${_lowStockAlerts.length}',
                    color: Colors.orange,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _SummaryCard(
                    icon: Icons.calendar_today,
                    label: 'قريب الانتهاء',
                    value: '${_expiryAlerts.length}',
                    color: Colors.purple,
                  ),
                ),
              ],
            ),
          ),
          
          // Alerts list
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildAlertList(_alerts),
                _buildAlertList(_lowStockAlerts),
                _buildAlertList(_expiryAlerts),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildAlertList(List<_AlertItem> alerts) {
    if (alerts.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check_circle, size: 64, color: Colors.green.shade300),
            const SizedBox(height: 16),
            const Text('لا توجد تنبيهات', style: TextStyle(fontSize: 18)),
          ],
        ),
      );
    }
    
    // Sort by priority
    final sortedAlerts = List<_AlertItem>.from(alerts)
      ..sort((a, b) {
        final priorityOrder = {'high': 0, 'medium': 1, 'low': 2};
        return priorityOrder[a.priority]!.compareTo(priorityOrder[b.priority]!);
      });
    
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: sortedAlerts.length,
      itemBuilder: (context, index) {
        final alert = sortedAlerts[index];
        return Dismissible(
          key: Key(alert.id),
          direction: DismissDirection.endToStart,
          background: Container(
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.only(left: 16),
            color: Colors.green,
            child: const Icon(Icons.check, color: Colors.white),
          ),
          onDismissed: (_) {
            setState(() => _alerts.remove(alert));
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('تم إخفاء التنبيه'),
                action: SnackBarAction(
                  label: 'تراجع',
                  onPressed: () => setState(() => _alerts.add(alert)),
                ),
              ),
            );
          },
          child: Card(
            margin: const EdgeInsets.only(bottom: 12),
            color: alert.priority == 'high' 
                ? Colors.red.shade50 
                : null,
            child: InkWell(
              onTap: () => _showAlertDetails(alert),
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: _getAlertColor(alert.type).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        _getAlertIcon(alert.type),
                        color: _getAlertColor(alert.type),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  alert.productName,
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                              if (alert.priority == 'high')
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: Colors.red,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: const Text(
                                    'عاجل',
                                    style: TextStyle(color: Colors.white, fontSize: 10),
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _getAlertMessage(alert),
                            style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _formatTimeAgo(alert.createdAt),
                            style: TextStyle(fontSize: 11, color: Colors.grey.shade400),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.shopping_cart, color: Colors.blue),
                      tooltip: 'طلب شراء',
                      onPressed: () => _createPurchaseOrder(alert),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
  
  Color _getAlertColor(String type) {
    switch (type) {
      case 'low_stock': return Colors.orange;
      case 'expiry': return Colors.purple;
      default: return Colors.grey;
    }
  }
  
  IconData _getAlertIcon(String type) {
    switch (type) {
      case 'low_stock': return Icons.inventory;
      case 'expiry': return Icons.calendar_today;
      default: return Icons.warning;
    }
  }
  
  String _getAlertMessage(_AlertItem alert) {
    if (alert.type == 'low_stock') {
      return 'الكمية: ${alert.currentStock} (الحد الأدنى: ${alert.threshold})';
    } else {
      final daysLeft = alert.expiryDate!.difference(DateTime.now()).inDays;
      return 'ينتهي خلال $daysLeft يوم';
    }
  }
  
  String _formatTimeAgo(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inMinutes < 60) {
      return 'منذ ${diff.inMinutes} دقيقة';
    } else if (diff.inHours < 24) {
      return 'منذ ${diff.inHours} ساعة';
    } else {
      return 'منذ ${diff.inDays} يوم';
    }
  }
  
  void _showAlertDetails(_AlertItem alert) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: _getAlertColor(alert.type).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(_getAlertIcon(alert.type), size: 32, color: _getAlertColor(alert.type)),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(alert.productName, style: Theme.of(context).textTheme.titleLarge),
                      Text(alert.barcode, style: TextStyle(color: Colors.grey.shade600)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            _DetailRow(label: 'الكمية الحالية', value: '${alert.currentStock}'),
            _DetailRow(label: 'الحد الأدنى', value: '${alert.threshold}'),
            if (alert.expiryDate != null)
              _DetailRow(
                label: 'تاريخ الانتهاء',
                value: '${alert.expiryDate!.day}/${alert.expiryDate!.month}/${alert.expiryDate!.year}',
              ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      setState(() => _alerts.remove(alert));
                    },
                    icon: const Icon(Icons.check),
                    label: const Text('تجاهل'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      _createPurchaseOrder(alert);
                    },
                    icon: const Icon(Icons.shopping_cart),
                    label: const Text('طلب شراء'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  void _showSettings() {
    showModalBottomSheet(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setSheetState) => Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('إعدادات التنبيهات', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              SwitchListTile(
                title: const Text('تنبيهات نفاد المخزون'),
                value: _notifyLowStock,
                onChanged: (v) {
                  setSheetState(() => _notifyLowStock = v);
                  setState(() {});
                },
              ),
              SwitchListTile(
                title: const Text('تنبيهات انتهاء الصلاحية'),
                value: _notifyExpiry,
                onChanged: (v) {
                  setSheetState(() => _notifyExpiry = v);
                  setState(() {});
                },
              ),
              ListTile(
                title: const Text('الحد الأدنى للمخزون'),
                subtitle: Text('$_lowStockThreshold وحدة'),
                trailing: SizedBox(
                  width: 150,
                  child: Slider(
                    value: _lowStockThreshold.toDouble(),
                    min: 5,
                    max: 50,
                    divisions: 9,
                    label: '$_lowStockThreshold',
                    onChanged: (v) {
                      setSheetState(() => _lowStockThreshold = v.toInt());
                      setState(() {});
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  void _acknowledgeAll() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تأكيد جميع التنبيهات'),
        content: Text('سيتم إخفاء ${_alerts.length} تنبيه'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() => _alerts.clear());
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('تم تأكيد جميع التنبيهات')),
              );
            },
            child: const Text('تأكيد'),
          ),
        ],
      ),
    );
  }
  
  void _createPurchaseOrder(_AlertItem alert) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('إنشاء طلب شراء'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('المنتج: ${alert.productName}'),
            const SizedBox(height: 16),
            TextField(
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'الكمية المطلوبة',
                hintText: '${alert.threshold * 2}',
                prefixIcon: const Icon(Icons.numbers),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('تم إنشاء طلب الشراء')),
              );
              setState(() => _alerts.remove(alert));
            },
            child: const Text('إنشاء'),
          ),
        ],
      ),
    );
  }
}

class _AlertItem {
  final String id;
  final String productName;
  final String barcode;
  final String type;
  final int currentStock;
  final int threshold;
  final DateTime? expiryDate;
  final String priority;
  final DateTime createdAt;
  
  _AlertItem({
    required this.id,
    required this.productName,
    required this.barcode,
    required this.type,
    required this.currentStock,
    required this.threshold,
    this.expiryDate,
    required this.priority,
    required this.createdAt,
  });
}

class _SummaryCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  
  const _SummaryCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color),
          const SizedBox(height: 4),
          Text(value, style: TextStyle(fontWeight: FontWeight.bold, color: color, fontSize: 24)),
          Text(label, style: TextStyle(fontSize: 11, color: color.withValues(alpha: 0.8))),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  
  const _DetailRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.grey.shade600)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}
