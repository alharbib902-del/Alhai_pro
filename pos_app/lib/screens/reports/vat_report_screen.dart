import 'package:pos_app/widgets/common/adaptive_icon.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/local/app_database.dart';
import '../../di/injection.dart';
import '../../providers/products_providers.dart';

/// شاشة تقرير الضريبة VAT
class VatReportScreen extends ConsumerStatefulWidget {
  const VatReportScreen({super.key});

  @override
  ConsumerState<VatReportScreen> createState() => _VatReportScreenState();
}

class _VatReportScreenState extends ConsumerState<VatReportScreen> {
  DateTimeRange? _dateRange;
  bool _isLoading = true;

  double _totalSales = 0;
  double _vatCollected = 0;
  double _totalPurchases = 0;
  double _vatPaid = 0;

  double get _netVat => _vatCollected - _vatPaid;

  @override
  void initState() {
    super.initState();
    _loadVatData();
  }

  Future<void> _loadVatData() async {
    try {
      final db = getIt<AppDatabase>();
      final storeId = ref.read(currentStoreIdProvider) ?? kDemoStoreId;

      final now = DateTime.now();
      final startDate = _dateRange?.start ?? DateTime(now.year, now.month, 1);
      final endDate = _dateRange?.end ?? now;

      final salesStats = await db.salesDao.getSalesStats(storeId, startDate: startDate, endDate: endDate);
      _totalSales = salesStats.total;
      _vatCollected = _totalSales * 0.15;

      // Purchases not readily available, set to 0
      _totalPurchases = 0;
      _vatPaid = _totalPurchases * 0.15;

      setState(() => _isLoading = false);
    } catch (_) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('تقرير الضريبة (VAT)'),
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf),
            tooltip: 'تصدير PDF',
            onPressed: _exportPdf,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Date Range Selector
                Card(
                  child: ListTile(
                    leading: const Icon(Icons.date_range),
                    title: Text(_dateRange == null 
                      ? 'اختر الفترة'
                      : '${_formatDate(_dateRange!.start)} - ${_formatDate(_dateRange!.end)}'),
                    trailing: const AdaptiveIcon(Icons.chevron_right),
                    onTap: _selectDateRange,
                  ),
                ),
                const SizedBox(height: 16),
                
                // Sales VAT
                _VatCard(
                  title: 'ضريبة المبيعات',
                  icon: Icons.trending_up,
                  color: Colors.green,
                  items: [
                    _VatItem('إجمالي المبيعات (شامل الضريبة)', _totalSales),
                    _VatItem('ضريبة القيمة المضافة المحصلة', _vatCollected, isVat: true),
                  ],
                ),
                const SizedBox(height: 12),
                
                // Purchases VAT
                _VatCard(
                  title: 'ضريبة المشتريات',
                  icon: Icons.trending_down,
                  color: Colors.orange,
                  items: [
                    _VatItem('إجمالي المشتريات (شامل الضريبة)', _totalPurchases),
                    _VatItem('ضريبة القيمة المضافة المدفوعة', _vatPaid, isVat: true),
                  ],
                ),
                const SizedBox(height: 16),
                
                // Net VAT
                Card(
                  color: _netVat >= 0 ? Colors.green.shade50 : Colors.red.shade50,
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        Text(
                          'صافي الضريبة المستحقة',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${_netVat.toStringAsFixed(2)} ر.س',
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: _netVat >= 0 ? Colors.green.shade700 : Colors.red.shade700,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _netVat >= 0 ? 'مستحق للهيئة' : 'مستحق من الهيئة',
                          style: TextStyle(color: Colors.grey.shade600),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                
                // Actions
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
                      child: FilledButton.icon(
                        onPressed: () {},
                        icon: const AdaptiveIcon(Icons.send),
                        label: const Text('إرسال للهيئة'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
    );
  }
  
  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
  
  void _selectDateRange() async {
    final range = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: _dateRange,
    );
    if (range != null) {
      setState(() {
        _dateRange = range;
        _isLoading = true;
      });
      _loadVatData();
    }
  }
  
  void _exportPdf() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('جاري تصدير التقرير...')),
    );
  }
}

class _VatCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final List<_VatItem> items;
  
  const _VatCard({
    required this.title,
    required this.icon,
    required this.color,
    required this.items,
  });
  
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color),
                const SizedBox(width: 8),
                Text(title, style: Theme.of(context).textTheme.titleMedium),
              ],
            ),
            const Divider(),
            ...items.map((item) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(item.label),
                  Text(
                    '${item.amount.toStringAsFixed(2)} ر.س',
                    style: TextStyle(
                      fontWeight: item.isVat ? FontWeight.bold : FontWeight.normal,
                      color: item.isVat ? color : null,
                    ),
                  ),
                ],
              ),
            )),
          ],
        ),
      ),
    );
  }
}

class _VatItem {
  final String label;
  final double amount;
  final bool isVat;
  
  _VatItem(this.label, this.amount, {this.isVat = false});
}
