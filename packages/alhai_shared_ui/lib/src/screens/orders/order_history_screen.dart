import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:alhai_design_system/alhai_design_system.dart';
import 'package:alhai_database/alhai_database.dart';
import 'package:get_it/get_it.dart';
import 'package:alhai_l10n/alhai_l10n.dart';
import 'package:alhai_auth/alhai_auth.dart';
import '../../providers/sync_providers.dart';
import '../../widgets/common/shimmer_loading.dart';
import '../../widgets/common/animated_list_view.dart';

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
  final _scrollController = ScrollController();
  List<OrdersTableData> _orders = [];
  bool _isLoading = true;
  bool _isLoadingMore = false;
  bool _hasMore = true;
  int _currentPage = 0;
  static const int _pageSize = 50;
  String? _error;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _loadData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_hasMore &&
        !_isLoadingMore &&
        !_isLoading &&
        _scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 200) {
      _loadMore();
    }
  }

  Future<void> _loadMore() async {
    if (_isLoadingMore || !_hasMore || _isLoading) return;
    setState(() => _isLoadingMore = true);
    try {
      final storeId = ref.read(currentStoreIdProvider);
      if (storeId == null) return;
      final db = GetIt.I<AppDatabase>();
      final nextPage = _currentPage + 1;

      final moreOrders = await db.ordersDao.getOrdersPaginated(
        storeId,
        offset: nextPage * _pageSize,
        limit: _pageSize,
        status: _filterStatus != 'all' ? _filterStatus : null,
      );

      // Apply date filter locally if needed
      var filtered = moreOrders;
      if (_dateRange != null) {
        final start = _dateRange!.start;
        final end = _dateRange!.end.add(const Duration(days: 1));
        filtered = filtered.where((o) =>
          o.orderDate.isAfter(start.subtract(const Duration(seconds: 1))) &&
          o.orderDate.isBefore(end)
        ).toList();
      }

      if (mounted) {
        setState(() {
          _orders.addAll(filtered);
          _currentPage = nextPage;
          _hasMore = moreOrders.length >= _pageSize;
          _isLoadingMore = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() => _isLoadingMore = false);
      }
    }
  }

  /// تحميل الطلبات من قاعدة البيانات مع دعم فلترة التاريخ والحالة
  Future<void> _loadData() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _error = null;
      _currentPage = 0;
      _hasMore = true;
    });
    try {
      final storeId = ref.read(currentStoreIdProvider);
      if (storeId == null) return;
      final db = GetIt.I<AppDatabase>();

      final orders = await db.ordersDao.getOrdersPaginated(
        storeId,
        offset: 0,
        limit: _pageSize,
        status: _filterStatus != 'all' ? _filterStatus : null,
      );

      // فلترة حسب نطاق التاريخ
      var filteredOrders = orders;
      if (_dateRange != null) {
        final start = _dateRange!.start;
        final end = _dateRange!.end.add(const Duration(days: 1));
        filteredOrders = filteredOrders.where((o) =>
          o.orderDate.isAfter(start.subtract(const Duration(seconds: 1))) &&
          o.orderDate.isBefore(end)
        ).toList();
      }

      if (mounted) {
        setState(() {
          _orders = filteredOrders;
          _isLoading = false;
          _hasMore = orders.length >= _pageSize;
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

  List<OrdersTableData> get _filteredOrders {
    var list = _orders;
    // فلترة القناة محلياً (الحالة تمت فلترتها في SQL)
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.orderHistory)),
        body: const Padding(
          padding: EdgeInsets.all(AlhaiSpacing.md),
          child: ShimmerList(itemCount: 6, itemHeight: 80),
        ),
      );
    }

    // حالة الخطأ
    if (_error != null) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.orderHistory)),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64, color: isDark ? AppColors.error.withValues(alpha: 0.7) : AppColors.error.withValues(alpha: 0.5)),
              SizedBox(height: AlhaiSpacing.md),
              Text(l10n.errorOccurred, style: TextStyle(fontSize: 18, color: Theme.of(context).colorScheme.onSurface)),
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
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth > 900;
          final isMedium = constraints.maxWidth > 600;
          final horizontalPadding = isWide ? 32.0 : (isMedium ? 24.0 : 16.0);

          return Column(
            children: [
              // Search bar
              Padding(
                padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: AlhaiSpacing.md),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: l10n.orderSearchHint,
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: AlhaiSpacing.md),
                  ),
                  onChanged: (_) => setState(() {}),
                ),
              ),

              // Filter chips - عرض الفلاتر النشطة
              if (_filterStatus != 'all' || _filterChannel != 'all' || _dateRange != null)
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                  child: Wrap(
                    spacing: 8,
                    children: [
                      if (_filterStatus != 'all')
                        Chip(
                          label: Text(_getStatusName(_filterStatus, l10n)),
                          onDeleted: () {
                            setState(() => _filterStatus = 'all');
                            _loadData();
                          },
                          deleteIconColor: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      if (_filterChannel != 'all')
                        Chip(
                          label: Text(_getChannelName(_filterChannel, l10n)),
                          onDeleted: () => setState(() => _filterChannel = 'all'),
                          deleteIconColor: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      if (_dateRange != null)
                        Chip(
                          label: Text('${_dateRange!.start.day}/${_dateRange!.start.month} - ${_dateRange!.end.day}/${_dateRange!.end.month}'),
                          onDeleted: () {
                            setState(() => _dateRange = null);
                            _loadData();
                          },
                          deleteIconColor: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                    ],
                  ),
                ),

              // Stats row
              Container(
                padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: AlhaiSpacing.md),
                child: Row(
                  children: [
                    _StatBadge(
                      label: l10n.today,
                      value: '${_orders.where((o) => o.orderDate.day == now.day && o.orderDate.month == now.month && o.orderDate.year == now.year).length}',
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    SizedBox(width: AlhaiSpacing.xs),
                    _StatBadge(
                      label: l10n.completed,
                      value: '${_orders.where((o) => o.status == "delivered").length}',
                      color: AppColors.success,
                    ),
                    SizedBox(width: AlhaiSpacing.xs),
                    _StatBadge(
                      label: l10n.pending,
                      value: '${_orders.where((o) => o.status == "created").length}',
                      color: AppColors.warning,
                    ),
                    SizedBox(width: AlhaiSpacing.xs),
                    _StatBadge(
                      label: l10n.cancelled,
                      value: '${_orders.where((o) => o.status == "cancelled").length}',
                      color: AppColors.error,
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
                            Icon(Icons.receipt_long, size: 64, color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.3)),
                            SizedBox(height: AlhaiSpacing.md),
                            Text(l10n.noOrders, style: TextStyle(fontSize: 18, color: Theme.of(context).colorScheme.onSurfaceVariant)),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _loadData,
                        child: isWide
                            ? GridView.builder(
                                controller: _scrollController,
                                padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  crossAxisSpacing: 16,
                                  mainAxisSpacing: 0,
                                  childAspectRatio: 2.8,
                                ),
                                itemCount: _filteredOrders.length + (_isLoadingMore ? 2 : 0),
                                itemBuilder: (context, index) {
                                  if (index >= _filteredOrders.length) {
                                    return const Padding(
                                      padding: EdgeInsets.symmetric(vertical: AlhaiSpacing.md),
                                      child: Center(
                                        child: SizedBox(
                                          width: 24,
                                          height: 24,
                                          child: CircularProgressIndicator(strokeWidth: 2),
                                        ),
                                      ),
                                    );
                                  }
                                  final order = _filteredOrders[index];
                                  return _OrderCard(
                                    order: order,
                                    onTap: () => _showOrderDetails(order),
                                  );
                                },
                              )
                            : AnimatedListView(
                                controller: _scrollController,
                                padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                                itemCount: _filteredOrders.length + (_isLoadingMore ? 1 : 0),
                                itemBuilder: (context, index) {
                                  if (index >= _filteredOrders.length) {
                                    return const Padding(
                                      padding: EdgeInsets.symmetric(vertical: AlhaiSpacing.md),
                                      child: Center(
                                        child: SizedBox(
                                          width: 24,
                                          height: 24,
                                          child: CircularProgressIndicator(strokeWidth: 2),
                                        ),
                                      ),
                                    );
                                  }
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
          );
        },
      ),
    );
  }
  
  String _getStatusName(String status, AppLocalizations l10n) {
    switch (status) {
      case 'delivered': return l10n.completed;
      case 'created': return l10n.pending;
      case 'confirmed': return l10n.orderStatusConfirmed;
      case 'preparing': return l10n.orderStatusPreparing;
      case 'ready': return l10n.orderStatusReady;
      case 'out_for_delivery': return l10n.orderStatusDelivering;
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

  /// اختيار نطاق التاريخ وإعادة تحميل البيانات
  void _selectDateRange() async {
    final range = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2024),
      lastDate: DateTime.now(),
      initialDateRange: _dateRange,
    );
    if (range != null) {
      setState(() => _dateRange = range);
      // إعادة تحميل البيانات مع النطاق الجديد
      _loadData();
    }
  }
  
  void _showFilterSheet() {
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
              Text(l10n.filterOrders, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              SizedBox(height: AlhaiSpacing.md),
              Text(l10n.status),
              SizedBox(height: AlhaiSpacing.xs),
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
                    selected: _filterStatus == 'created',
                    onSelected: (_) {
                      setSheetState(() => _filterStatus = 'created');
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
              SizedBox(height: AlhaiSpacing.md),
              Text(l10n.channelLabel),
              SizedBox(height: AlhaiSpacing.xs),
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
              SizedBox(height: AlhaiSpacing.lg),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () {
                    Navigator.pop(context);
                    // إعادة تحميل البيانات مع الفلاتر المحدثة
                    _loadData();
                  },
                  child: Text(l10n.confirm),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  /// تحديث حالة الطلب مع المزامنة
  Future<void> _updateOrderStatus(String orderId, String newStatus) async {
    try {
      final db = GetIt.I<AppDatabase>();
      await db.ordersDao.updateOrderStatus(orderId, newStatus);

      // إضافة للمزامنة
      try {
        final syncService = ref.read(syncServiceProvider);
        await syncService.enqueueUpdate(
          tableName: 'orders',
          recordId: orderId,
          changes: {'status': newStatus, 'updatedAt': DateTime.now().toIso8601String()},
        );
      } catch (_) {
        // المزامنة اختيارية - لا نوقف العملية إذا فشلت
      }

      // إعادة تحميل البيانات
      await _loadData();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${AppLocalizations.of(context)!.status}: $newStatus')),
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

  void _showOrderDetails(OrdersTableData order) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.4,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) => FutureBuilder<List<OrderItemsTableData>>(
          future: GetIt.I<AppDatabase>().ordersDao.getOrderItems(order.id),
          builder: (context, snapshot) {
            final items = snapshot.data ?? [];
            return ListView(
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
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(order.orderNumber, style: Theme.of(context).textTheme.titleLarge),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: AlhaiSpacing.sm, vertical: AlhaiSpacing.xxs),
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
                SizedBox(height: AlhaiSpacing.md),
                _DetailRow(icon: Icons.person, label: l10n.customer, value: order.customerId ?? l10n.guestCustomer),
                _DetailRow(icon: Icons.access_time, label: l10n.date, value: _formatDateTime(order.orderDate, l10n)),
                _DetailRow(icon: Icons.shopping_bag, label: l10n.products, value: '${items.length}'),
                _DetailRow(icon: Icons.payment, label: l10n.payment, value: _getPaymentName(order.paymentMethod ?? 'cash', l10n)),
                _DetailRow(icon: Icons.storefront, label: l10n.channelLabel, value: _getChannelName(order.channel, l10n)),

                // عرض عناصر الطلب الحقيقية
                if (items.isNotEmpty) ...[
                  const Divider(height: 24),
                  Text(l10n.products, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  SizedBox(height: AlhaiSpacing.xs),
                  ...items.map((item) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: AlhaiSpacing.xxs),
                    child: Row(
                      children: [
                        Expanded(child: Text(item.productName, style: const TextStyle(fontSize: 14))),
                        Text('x${item.quantity.toStringAsFixed(0)}', style: TextStyle(fontSize: 13, color: Theme.of(context).colorScheme.onSurfaceVariant)),
                        SizedBox(width: AlhaiSpacing.sm),
                        Text(l10n.priceWithCurrency(item.total.toStringAsFixed(0)), style: const TextStyle(fontWeight: FontWeight.w500)),
                      ],
                    ),
                  )),
                ],

                const Divider(height: 32),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(l10n.total, style: const TextStyle(fontSize: 18)),
                    Text(
                      l10n.priceWithCurrency(order.total.toStringAsFixed(0)),
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.success),
                    ),
                  ],
                ),
                SizedBox(height: AlhaiSpacing.lg),

                // أزرار تحديث الحالة حسب الحالة الحالية
                if (order.status == 'created') ...[
                  FilledButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      _updateOrderStatus(order.id, 'confirmed');
                    },
                    icon: const Icon(Icons.check),
                    label: Text(l10n.orderStatusConfirmed),
                    style: FilledButton.styleFrom(
                      minimumSize: const Size(double.infinity, 48),
                    ),
                  ),
                  SizedBox(height: AlhaiSpacing.xs),
                ] else if (order.status == 'confirmed') ...[
                  FilledButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      _updateOrderStatus(order.id, 'preparing');
                    },
                    icon: const Icon(Icons.restaurant),
                    label: Text(l10n.orderStatusPreparing),
                    style: FilledButton.styleFrom(
                      minimumSize: const Size(double.infinity, 48),
                    ),
                  ),
                  SizedBox(height: AlhaiSpacing.xs),
                ] else if (order.status == 'preparing') ...[
                  FilledButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      _updateOrderStatus(order.id, 'ready');
                    },
                    icon: const Icon(Icons.check_circle),
                    label: Text(l10n.orderStatusReady),
                    style: FilledButton.styleFrom(
                      minimumSize: const Size(double.infinity, 48),
                    ),
                  ),
                  SizedBox(height: AlhaiSpacing.xs),
                ] else if (order.status == 'ready') ...[
                  FilledButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      _updateOrderStatus(order.id, 'out_for_delivery');
                    },
                    icon: const Icon(Icons.delivery_dining),
                    label: Text(l10n.orderStatusDelivering),
                    style: FilledButton.styleFrom(
                      minimumSize: const Size(double.infinity, 48),
                    ),
                  ),
                  SizedBox(height: AlhaiSpacing.xs),
                ] else if (order.status == 'out_for_delivery') ...[
                  FilledButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      _updateOrderStatus(order.id, 'delivered');
                    },
                    icon: const Icon(Icons.done_all),
                    label: Text(l10n.completed),
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.success,
                      minimumSize: const Size(double.infinity, 48),
                    ),
                  ),
                  SizedBox(height: AlhaiSpacing.xs),
                ],

                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.print),
                        label: Text(l10n.printReceipt),
                      ),
                    ),
                    SizedBox(width: AlhaiSpacing.sm),
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
                  SizedBox(height: AlhaiSpacing.sm),
                  FilledButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.replay),
                    label: Text(l10n.returnText),
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.warning,
                      minimumSize: const Size(double.infinity, 48),
                    ),
                  ),
                ],
                // زر إلغاء الطلب إذا لم يكتمل
                if (order.status != 'delivered' && order.status != 'cancelled') ...[
                  SizedBox(height: AlhaiSpacing.sm),
                  OutlinedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      _updateOrderStatus(order.id, 'cancelled');
                    },
                    icon: Icon(Icons.cancel, color: Theme.of(context).colorScheme.error),
                    label: Text(l10n.cancelled, style: TextStyle(color: Theme.of(context).colorScheme.error)),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: Theme.of(context).colorScheme.error),
                      minimumSize: const Size(double.infinity, 48),
                    ),
                  ),
                ],
              ],
            );
          },
        ),
      ),
    );
  }
  
  Color _getStatusColor(String status) {
    // Status colors used in badges/chips - semantic where possible
    switch (status) {
      case 'delivered': return AppColors.success;
      case 'created': return AppColors.warning;
      case 'confirmed': return Theme.of(context).colorScheme.primary;
      case 'preparing': return Colors.indigo; // pipeline status color
      case 'ready': return Colors.teal; // pipeline status color
      case 'out_for_delivery': return Colors.cyan; // pipeline status color
      case 'cancelled': return AppColors.error;
      default: return Theme.of(context).colorScheme.outline;
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final subtleColor = Theme.of(context).colorScheme.onSurfaceVariant;
    return Card(
      margin: const EdgeInsets.only(bottom: AlhaiSpacing.sm),
      color: isDark ? const Color(0xFF1E293B) : null,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(AlhaiSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(AlhaiSpacing.xs),
                    decoration: BoxDecoration(
                      color: _getStatusColor(order.status, context).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      _getChannelIcon(order.channel),
                      color: _getStatusColor(order.status, context),
                    ),
                  ),
                  SizedBox(width: AlhaiSpacing.sm),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(order.orderNumber, style: TextStyle(fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface)),
                        Text(
                          order.customerId ?? l10n.guestCustomer,
                          style: TextStyle(fontSize: 13, color: subtleColor),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        l10n.priceWithCurrency(order.total.toStringAsFixed(0)),
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Theme.of(context).colorScheme.onSurface),
                      ),
                      Text(
                        _getChannelName(order.channel, l10n),
                        style: TextStyle(fontSize: 12, color: subtleColor),
                      ),
                    ],
                  ),
                ],
              ),
              const Divider(height: 24),
              Row(
                children: [
                  Icon(Icons.access_time, size: 14, color: subtleColor),
                  SizedBox(width: AlhaiSpacing.xxs),
                  Text(
                    _formatTime(order.orderDate, l10n),
                    style: TextStyle(fontSize: 12, color: subtleColor),
                  ),
                  SizedBox(width: AlhaiSpacing.md),
                  Icon(Icons.payment, size: 14, color: subtleColor),
                  SizedBox(width: AlhaiSpacing.xxs),
                  Text(
                    _getPaymentName(order.paymentMethod ?? 'cash', l10n),
                    style: TextStyle(fontSize: 12, color: subtleColor),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: AlhaiSpacing.xs, vertical: AlhaiSpacing.xxxs),
                    decoration: BoxDecoration(
                      color: _getStatusColor(order.status, context).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      _getStatusName(order.status, l10n),
                      style: TextStyle(
                        fontSize: 11,
                        color: _getStatusColor(order.status, context),
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

  Color _getStatusColor(String status, BuildContext context) {
    // Status colors used in badges/chips - semantic where possible
    switch (status) {
      case 'delivered': return AppColors.success;
      case 'created': return AppColors.warning;
      case 'confirmed': return Theme.of(context).colorScheme.primary;
      case 'preparing': return Colors.indigo; // pipeline status color
      case 'ready': return Colors.teal; // pipeline status color
      case 'out_for_delivery': return Colors.cyan; // pipeline status color
      case 'cancelled': return AppColors.error;
      default: return Theme.of(context).colorScheme.outline;
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
      case 'created': return l10n.pending;
      case 'confirmed': return l10n.orderStatusConfirmed;
      case 'preparing': return l10n.orderStatusPreparing;
      case 'ready': return l10n.orderStatusReady;
      case 'out_for_delivery': return l10n.orderStatusDelivering;
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
      padding: const EdgeInsets.symmetric(horizontal: AlhaiSpacing.sm, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(value, style: TextStyle(fontWeight: FontWeight.bold, color: color)),
          SizedBox(width: AlhaiSpacing.xxs),
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final subtleColor = Theme.of(context).colorScheme.onSurfaceVariant;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AlhaiSpacing.xs),
      child: Row(
        children: [
          Icon(icon, size: 20, color: subtleColor),
          SizedBox(width: AlhaiSpacing.sm),
          Text(label, style: TextStyle(color: subtleColor)),
          const Spacer(),
          Text(value, style: TextStyle(fontWeight: FontWeight.w500, color: Theme.of(context).colorScheme.onSurface)),
        ],
      ),
    );
  }
}
