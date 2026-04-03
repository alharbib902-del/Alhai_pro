import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:alhai_database/alhai_database.dart';
import 'package:alhai_design_system/alhai_design_system.dart' show AlhaiColors, AlhaiSpacing;
import 'package:get_it/get_it.dart';
import 'package:alhai_l10n/alhai_l10n.dart';
import 'package:alhai_auth/alhai_auth.dart';

/// شاشة تنبيهات المخزون
class InventoryAlertsScreen extends ConsumerStatefulWidget {
  const InventoryAlertsScreen({super.key});

  @override
  ConsumerState<InventoryAlertsScreen> createState() => _InventoryAlertsScreenState();
}

class _InventoryAlertsScreenState extends ConsumerState<InventoryAlertsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _lowStockThreshold = 10;
  bool _notifyLowStock = true;
  bool _notifyExpiry = true;
  bool _isLoading = true;
  String? _loadError;

  List<_AlertItem> _alerts = [];

  List<_AlertItem> get _lowStockAlerts => _alerts.where((a) => a.type == 'low_stock').toList();
  List<_AlertItem> get _expiryAlerts => _alerts.where((a) => a.type == 'expiry').toList();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final storeId = ref.read(currentStoreIdProvider);
      if (storeId == null) {
        if (mounted) setState(() => _isLoading = false);
        return;
      }
      final db = GetIt.I<AppDatabase>();
      final lowStock = await db.productsDao.getLowStockProducts(storeId);
      final alerts = lowStock.map((p) => _AlertItem(
        id: p.id,
        productName: p.name,
        barcode: p.barcode ?? '',
        type: 'low_stock',
        currentStock: p.stockQty,
        threshold: p.minQty,
        priority: p.stockQty <= 0 ? 'critical' : (p.stockQty <= p.minQty ~/ 2 ? 'high' : 'medium'),
        createdAt: p.updatedAt ?? p.createdAt,
      )).toList();
      if (mounted) setState(() { _alerts = alerts; _isLoading = false; });
    } catch (e) {
      if (mounted) setState(() {
        _isLoading = false;
        _loadError = e.toString();
      });
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;

    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.inventoryAlerts)),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_loadError != null) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.inventoryAlerts)),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64, color: colorScheme.error),
              SizedBox(height: AlhaiSpacing.md),
              Text(l10n.errorOccurred),
              SizedBox(height: AlhaiSpacing.xs),
              TextButton.icon(
                onPressed: () {
                  setState(() { _isLoading = true; _loadError = null; });
                  _loadData();
                },
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
        title: Text(l10n.inventoryAlerts),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            tooltip: l10n.alertSettings,
            onPressed: _showSettings,
          ),
          IconButton(
            icon: const Icon(Icons.check_circle),
            tooltip: l10n.acknowledgeAll,
            onPressed: _acknowledgeAll,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: l10n.allWithCount(_alerts.length)),
            Tab(text: l10n.lowStockWithCount(_lowStockAlerts.length)),
            Tab(text: l10n.expiryWithCount(_expiryAlerts.length)),
          ],
        ),
      ),
      body: Column(
        children: [
          // Summary cards
          Container(
            padding: const EdgeInsets.all(AlhaiSpacing.md),
            child: Row(
              children: [
                Expanded(
                  child: _SummaryCard(
                    icon: Icons.warning,
                    label: l10n.urgentAlerts,
                    value: '${_alerts.where((a) => a.priority == "high" || a.priority == "critical").length}',
                    color: colorScheme.error,
                  ),
                ),
                SizedBox(width: AlhaiSpacing.sm),
                Expanded(
                  child: _SummaryCard(
                    icon: Icons.inventory,
                    label: l10n.lowStock,
                    value: '${_lowStockAlerts.length}',
                    color: AlhaiColors.warning,
                  ),
                ),
                SizedBox(width: AlhaiSpacing.sm),
                Expanded(
                  child: _SummaryCard(
                    icon: Icons.calendar_today,
                    label: l10n.nearExpiry,
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
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;
    if (alerts.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.check_circle, size: 64, color: AlhaiColors.success),
            SizedBox(height: AlhaiSpacing.md),
            Text(l10n.noAlerts, style: const TextStyle(fontSize: 18)),
          ],
        ),
      );
    }

    // Sort by priority
    final sortedAlerts = List<_AlertItem>.from(alerts)
      ..sort((a, b) {
        final priorityOrder = {'critical': 0, 'high': 1, 'medium': 2, 'low': 3};
        return (priorityOrder[a.priority] ?? 3).compareTo(priorityOrder[b.priority] ?? 3);
      });

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: AlhaiSpacing.md),
      itemCount: sortedAlerts.length,
      itemBuilder: (context, index) {
        final alert = sortedAlerts[index];
        return Dismissible(
          key: Key(alert.id),
          direction: DismissDirection.endToStart,
          background: Container(
            alignment: AlignmentDirectional.centerStart,
            padding: const EdgeInsetsDirectional.only(start: 16),
            color: AlhaiColors.success,
            child: Icon(Icons.check, color: colorScheme.surface),
          ),
          onDismissed: (_) {
            setState(() => _alerts.remove(alert));
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(l10n.alertDismissed),
                action: SnackBarAction(
                  label: l10n.undo,
                  onPressed: () => setState(() => _alerts.add(alert)),
                ),
              ),
            );
          },
          child: Card(
            margin: const EdgeInsets.only(bottom: AlhaiSpacing.sm),
            color: (alert.priority == 'high' || alert.priority == 'critical')
                ? colorScheme.errorContainer
                : null,
            child: InkWell(
              onTap: () => _showAlertDetails(alert),
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: const EdgeInsets.all(AlhaiSpacing.md),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(AlhaiSpacing.sm),
                      decoration: BoxDecoration(
                        color: _getAlertColor(alert.type).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        _getAlertIcon(alert.type),
                        color: _getAlertColor(alert.type),
                      ),
                    ),
                    SizedBox(width: AlhaiSpacing.md),
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
                              if (alert.priority == 'high' || alert.priority == 'critical')
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: AlhaiSpacing.xxxs),
                                  decoration: BoxDecoration(
                                    color: colorScheme.error,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    alert.priority == 'critical' ? l10n.criticalPriority : l10n.highPriority,
                                    style: TextStyle(color: colorScheme.surface, fontSize: 10),
                                  ),
                                ),
                            ],
                          ),
                          SizedBox(height: AlhaiSpacing.xxs),
                          Text(
                            _getAlertMessage(alert),
                            style: TextStyle(fontSize: 13, color: colorScheme.onSurfaceVariant),
                          ),
                          SizedBox(height: AlhaiSpacing.xxs),
                          Text(
                            _formatTimeAgo(alert.createdAt),
                            style: TextStyle(fontSize: 11, color: colorScheme.onSurfaceVariant),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.shopping_cart, color: colorScheme.primary),
                      tooltip: l10n.createPurchaseOrder,
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
      case 'low_stock': return AlhaiColors.warning;
      case 'expiry': return Colors.purple;
      default: return Theme.of(context).colorScheme.outline;
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
    final l10n = AppLocalizations.of(context)!;
    if (alert.type == 'low_stock') {
      return l10n.stockAlertMessage(alert.currentStock.toInt(), alert.threshold.toInt());
    } else {
      return l10n.expiryAlertLabel;
    }
  }

  String _formatTimeAgo(DateTime date) {
    final l10n = AppLocalizations.of(context)!;
    final diff = DateTime.now().difference(date);
    if (diff.inMinutes < 60) {
      return l10n.minutesAgoTime(diff.inMinutes);
    } else if (diff.inHours < 24) {
      return l10n.hoursAgoTime(diff.inHours);
    } else {
      return l10n.daysAgoTime(diff.inDays);
    }
  }

  void _showAlertDetails(_AlertItem alert) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;
    showModalBottomSheet(
      context: context,
      builder: (context) => Padding(
        padding: const EdgeInsets.all(AlhaiSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(AlhaiSpacing.md),
                  decoration: BoxDecoration(
                    color: _getAlertColor(alert.type).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(_getAlertIcon(alert.type), size: 32, color: _getAlertColor(alert.type)),
                ),
                SizedBox(width: AlhaiSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(alert.productName, style: Theme.of(context).textTheme.titleLarge),
                      Text(alert.barcode, style: TextStyle(color: colorScheme.onSurfaceVariant)),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: AlhaiSpacing.lg),
            _DetailRow(label: l10n.currentQuantity, value: '${alert.currentStock}'),
            _DetailRow(label: l10n.minimumThreshold, value: '${alert.threshold}'),
            SizedBox(height: AlhaiSpacing.lg),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      setState(() => _alerts.remove(alert));
                    },
                    icon: const Icon(Icons.check),
                    label: Text(l10n.dismissAction),
                  ),
                ),
                SizedBox(width: AlhaiSpacing.sm),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      _createPurchaseOrder(alert);
                    },
                    icon: const Icon(Icons.shopping_cart),
                    label: Text(l10n.createPurchaseOrder),
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
    final l10n = AppLocalizations.of(context)!;
    showModalBottomSheet(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setSheetState) => Padding(
          padding: const EdgeInsets.all(AlhaiSpacing.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(l10n.alertSettings, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              SizedBox(height: AlhaiSpacing.md),
              SwitchListTile(
                title: Text(l10n.lowStockNotifications),
                value: _notifyLowStock,
                onChanged: (v) {
                  setSheetState(() => _notifyLowStock = v);
                  setState(() {});
                },
              ),
              SwitchListTile(
                title: Text(l10n.expiryNotifications),
                value: _notifyExpiry,
                onChanged: (v) {
                  setSheetState(() => _notifyExpiry = v);
                  setState(() {});
                },
              ),
              ListTile(
                title: Text(l10n.minimumStockLevel),
                subtitle: Text(l10n.thresholdUnits(_lowStockThreshold)),
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
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.acknowledgeAllAlerts),
        content: Text(l10n.willDismissAlerts(_alerts.length)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() => _alerts.clear());
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(l10n.allAlertsAcknowledged)),
              );
            },
            child: Text(l10n.confirm),
          ),
        ],
      ),
    );
  }

  void _createPurchaseOrder(_AlertItem alert) {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.createPurchaseOrder),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(l10n.productLabelName(alert.productName)),
            SizedBox(height: AlhaiSpacing.md),
            TextField(
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: l10n.requiredQuantity,
                hintText: '${alert.threshold * 2}',
                prefixIcon: const Icon(Icons.numbers),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(l10n.purchaseOrderCreated)),
              );
              setState(() => _alerts.remove(alert));
            },
            child: Text(l10n.createAction),
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
  final double currentStock;
  final double threshold;
  final String priority;
  final DateTime createdAt;

  _AlertItem({
    required this.id,
    required this.productName,
    required this.barcode,
    required this.type,
    required this.currentStock,
    required this.threshold,
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
      padding: const EdgeInsets.all(AlhaiSpacing.sm),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color),
          SizedBox(height: AlhaiSpacing.xxs),
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
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AlhaiSpacing.xs),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: colorScheme.onSurfaceVariant)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}
