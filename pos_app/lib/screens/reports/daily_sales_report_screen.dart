import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/local/app_database.dart';
import '../../di/injection.dart';
import '../../providers/products_providers.dart';

/// شاشة تقرير المبيعات اليومي - بيانات حقيقية
class DailySalesReportScreen extends ConsumerStatefulWidget {
  const DailySalesReportScreen({super.key});

  @override
  ConsumerState<DailySalesReportScreen> createState() => _DailySalesReportScreenState();
}

class _DailySalesReportScreenState extends ConsumerState<DailySalesReportScreen> {
  DateTime _selectedDate = DateTime.now();
  bool _isLoading = true;
  
  // البيانات الفعلية
  double _totalSales = 0;
  int _totalTransactions = 0;
  int _totalItems = 0;
  double _cashSales = 0;
  double _cardSales = 0;
  double _creditSales = 0;
  double _discounts = 0;
  double _vat = 0;

  @override
  void initState() {
    super.initState();
    _loadReportData();
  }

  Future<void> _loadReportData() async {
    setState(() => _isLoading = true);
    try {
      final db = getIt<AppDatabase>();
      final storeId = ref.read(currentStoreIdProvider);

      if (storeId != null) {
        // جلب مبيعات اليوم المحدد
        final sales = await db.salesDao.getSalesByDate(storeId, _selectedDate);
        
        double total = 0;
        double cash = 0;
        double card = 0;
        double credit = 0;
        double discount = 0;
        double tax = 0;
        int items = 0;

        for (final sale in sales) {
          total += sale.total;
          discount += sale.discount;
          tax += sale.tax;
          
          switch (sale.paymentMethod) {
            case 'cash':
              cash += sale.total;
              break;
            case 'card':
              card += sale.total;
              break;
            case 'wallet':
            case 'bankTransfer':
            default:
              credit += sale.total;
              break;
          }
          
          // جلب عدد الـ items لكل فاتورة
          final saleItems = await db.saleItemsDao.getItemsBySaleId(sale.id);
          for (final item in saleItems) {
            items += item.qty.toInt();
          }
        }

        setState(() {
          _totalSales = total;
          _totalTransactions = sales.length;
          _totalItems = items;
          _cashSales = cash;
          _cardSales = card;
          _creditSales = credit;
          _discounts = discount;
          _vat = tax;
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('تقرير المبيعات اليومي'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadReportData,
          ),
          IconButton(
            icon: const Icon(Icons.share),
            tooltip: 'مشاركة',
            onPressed: _shareReport,
          ),
          IconButton(
            icon: const Icon(Icons.print),
            tooltip: 'طباعة',
            onPressed: _printReport,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Date selector
                Card(
                  child: ListTile(
                    leading: const Icon(Icons.calendar_today, color: Colors.blue),
                    title: const Text('التاريخ'),
                    subtitle: Text(_formatDate(_selectedDate)),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.chevron_left),
                          onPressed: () {
                            setState(() => _selectedDate = _selectedDate.subtract(const Duration(days: 1)));
                            _loadReportData();
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.chevron_right),
                          onPressed: _selectedDate.isBefore(DateTime.now()) 
                              ? () {
                                  setState(() => _selectedDate = _selectedDate.add(const Duration(days: 1)));
                                  _loadReportData();
                                }
                              : null,
                        ),
                      ],
                    ),
                    onTap: _selectDate,
                  ),
                ),
                const SizedBox(height: 16),
                
                // حالة عدم وجود بيانات
                if (_totalTransactions == 0)
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        children: [
                          Icon(Icons.hourglass_empty, size: 64, color: Colors.grey.shade400),
                          const SizedBox(height: 16),
                          const Text('لا توجد مبيعات لهذا اليوم', style: TextStyle(color: Colors.grey)),
                        ],
                      ),
                    ),
                  )
                else ...[
                  // Summary cards
                  Row(
                    children: [
                      Expanded(
                        child: _SummaryCard(
                          title: 'إجمالي المبيعات',
                          value: '${_totalSales.toStringAsFixed(0)} ر.س',
                          icon: Icons.attach_money,
                          color: Colors.green,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _SummaryCard(
                          title: 'عدد الفواتير',
                          value: '$_totalTransactions',
                          icon: Icons.receipt_long,
                          color: Colors.blue,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _SummaryCard(
                          title: 'المنتجات المباعة',
                          value: '$_totalItems',
                          icon: Icons.shopping_bag,
                          color: Colors.orange,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _SummaryCard(
                          title: 'متوسط الفاتورة',
                          value: _totalTransactions > 0 
                              ? '${(_totalSales / _totalTransactions).toStringAsFixed(0)} ر.س'
                              : '0 ر.س',
                          icon: Icons.analytics,
                          color: Colors.purple,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  // Payment methods
                  if (_totalSales > 0)
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('طرق الدفع', style: Theme.of(context).textTheme.titleMedium),
                            const Divider(),
                            _PaymentRow(
                              icon: Icons.money,
                              label: 'نقدي',
                              amount: _cashSales,
                              color: Colors.green,
                              percentage: _cashSales / _totalSales,
                            ),
                            const SizedBox(height: 12),
                            _PaymentRow(
                              icon: Icons.credit_card,
                              label: 'بطاقة',
                              amount: _cardSales,
                              color: Colors.blue,
                              percentage: _cardSales / _totalSales,
                            ),
                            const SizedBox(height: 12),
                            _PaymentRow(
                              icon: Icons.account_balance_wallet,
                              label: 'آجل',
                              amount: _creditSales,
                              color: Colors.orange,
                              percentage: _creditSales / _totalSales,
                            ),
                          ],
                        ),
                      ),
                    ),
                  const SizedBox(height: 16),
                  
                  // Deductions
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('الخصومات والضريبة', style: Theme.of(context).textTheme.titleMedium),
                          const Divider(),
                          ListTile(
                            leading: Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: Colors.orange.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(Icons.local_offer, color: Colors.orange),
                            ),
                            title: const Text('الخصومات'),
                            trailing: Text(
                              '-${_discounts.toStringAsFixed(0)} ر.س',
                              style: const TextStyle(color: Colors.orange, fontWeight: FontWeight.bold),
                            ),
                          ),
                          ListTile(
                            leading: Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: Colors.purple.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(Icons.receipt, color: Colors.purple),
                            ),
                            title: const Text('ضريبة القيمة المضافة 15%'),
                            trailing: Text(
                              '${_vat.toStringAsFixed(2)} ر.س',
                              style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.purple),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Net total
                  Card(
                    color: Colors.green.shade50,
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('صافي المبيعات', style: TextStyle(fontSize: 16)),
                              Text('بعد الخصومات', style: TextStyle(color: Colors.grey, fontSize: 12)),
                            ],
                          ),
                          Text(
                            '${(_totalSales - _discounts).toStringAsFixed(0)} ر.س',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.green.shade700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ),
    );
  }
  
  String _formatDate(DateTime date) {
    final days = ['الأحد', 'الإثنين', 'الثلاثاء', 'الأربعاء', 'الخميس', 'الجمعة', 'السبت'];
    return '${days[date.weekday % 7]} ${date.day}/${date.month}/${date.year}';
  }
  
  void _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
      _loadReportData();
    }
  }
  
  void _shareReport() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('جاري مشاركة التقرير...')),
    );
  }
  
  void _printReport() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('جاري طباعة التقرير...')),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  
  const _SummaryCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color),
            const SizedBox(height: 8),
            Text(title, style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
            const SizedBox(height: 4),
            Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}

class _PaymentRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final double amount;
  final Color color;
  final double percentage;
  
  const _PaymentRow({
    required this.icon,
    required this.label,
    required this.amount,
    required this.color,
    required this.percentage,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 8),
            Text(label),
            const Spacer(),
            Text('${amount.toStringAsFixed(0)} ر.س', style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(width: 8),
            Text('(${(percentage * 100).toStringAsFixed(0)}%)', style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
          ],
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: percentage.isNaN ? 0 : percentage,
            backgroundColor: color.withValues(alpha: 0.1),
            valueColor: AlwaysStoppedAnimation(color),
            minHeight: 6,
          ),
        ),
      ],
    );
  }
}
