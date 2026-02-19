import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/local/app_database.dart';
import '../../di/injection.dart';
import '../../providers/products_providers.dart';

/// شاشة تقرير أداء الموظفين
class StaffPerformanceScreen extends ConsumerStatefulWidget {
  const StaffPerformanceScreen({super.key});

  @override
  ConsumerState<StaffPerformanceScreen> createState() => _StaffPerformanceScreenState();
}

class _StaffPerformanceScreenState extends ConsumerState<StaffPerformanceScreen> {
  String _period = 'today';
  bool _isLoading = true;

  List<_StaffData> _staff = [];

  @override
  void initState() {
    super.initState();
    _loadStaff();
  }

  Future<void> _loadStaff() async {
    try {
      final db = getIt<AppDatabase>();
      final storeId = ref.read(currentStoreIdProvider) ?? kDemoStoreId;
      final users = await db.usersDao.getAllUsers(storeId);

      _staff = users.map((u) => _StaffData(
        name: u.name,
        role: u.role,
        sales: 0,
        transactions: 0,
        avgTicket: 0,
      )).toList();

      setState(() => _isLoading = false);
    } catch (_) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('أداء الموظفين')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text('أداء الموظفين'),
        actions: [
          PopupMenuButton<String>(
            onSelected: (v) => setState(() => _period = v),
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'today', child: Text('اليوم')),
              const PopupMenuItem(value: 'week', child: Text('الأسبوع')),
              const PopupMenuItem(value: 'month', child: Text('الشهر')),
            ],
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Text(_getPeriodName()),
                  const Icon(Icons.arrow_drop_down),
                ],
              ),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Leader board
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.emoji_events, color: Colors.amber),
                      const SizedBox(width: 8),
                      Text('المتصدرون', style: Theme.of(context).textTheme.titleMedium),
                    ],
                  ),
                  const SizedBox(height: 16),
                  ...List.generate(_staff.length.clamp(0, 3), (index) {
                    final staff = _staff[index];
                    final colors = [Colors.amber, Colors.grey, Colors.brown];
                    return _LeaderItem(
                      rank: index + 1,
                      name: staff.name,
                      sales: staff.sales,
                      color: colors[index],
                    );
                  }),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          
          // Detailed stats
          ...List.generate(_staff.length, (index) {
            final staff = _staff[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: ExpansionTile(
                leading: CircleAvatar(
                  child: Text(staff.name[0]),
                ),
                title: Text(staff.name),
                subtitle: Text(staff.role),
                trailing: Text(
                  '${staff.sales.toStringAsFixed(0)} ر.س',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        _StatRow(
                          icon: Icons.receipt_long,
                          label: 'عدد الفواتير',
                          value: '${staff.transactions}',
                          color: Colors.blue,
                        ),
                        const SizedBox(height: 12),
                        _StatRow(
                          icon: Icons.trending_up,
                          label: 'متوسط الفاتورة',
                          value: '${staff.avgTicket} ر.س',
                          color: Colors.green,
                        ),
                        const SizedBox(height: 12),
                        const _StatRow(
                          icon: Icons.schedule,
                          label: 'ساعات العمل',
                          value: '8 ساعات',
                          color: Colors.orange,
                        ),
                        const SizedBox(height: 12),
                        _StatRow(
                          icon: Icons.speed,
                          label: 'المبيعات/ساعة',
                          value: '${(staff.sales / 8).toStringAsFixed(0)} ر.س',
                          color: Colors.purple,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }),
          
          // Comparison chart
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('مقارنة المبيعات', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 16),
                  ...List.generate(_staff.length, (index) {
                    final staff = _staff[index];
                    final rawMax = _staff.isEmpty ? 0.0 : _staff.map((s) => s.sales).reduce((a, b) => a > b ? a : b);
                    final maxSales = rawMax > 0 ? rawMax : 1.0;
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              SizedBox(width: 80, child: Text(staff.name.split(' ')[0])),
                              Expanded(
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(4),
                                  child: LinearProgressIndicator(
                                    value: staff.sales / maxSales,
                                    backgroundColor: Colors.grey.withValues(alpha: 0.2),
                                    minHeight: 20,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              SizedBox(
                                width: 70,
                                child: Text(
                                  staff.sales.toStringAsFixed(0),
                                  textAlign: TextAlign.end,
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  String _getPeriodName() {
    switch (_period) {
      case 'today': return 'اليوم';
      case 'week': return 'الأسبوع';
      case 'month': return 'الشهر';
      default: return 'اليوم';
    }
  }
}

class _StaffData {
  final String name;
  final String role;
  final double sales;
  final int transactions;
  final int avgTicket;
  
  _StaffData({
    required this.name,
    required this.role,
    required this.sales,
    required this.transactions,
    required this.avgTicket,
  });
}

class _LeaderItem extends StatelessWidget {
  final int rank;
  final String name;
  final double sales;
  final Color color;
  
  const _LeaderItem({
    required this.rank,
    required this.name,
    required this.sales,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '$rank',
                style: TextStyle(fontWeight: FontWeight.bold, color: color),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(child: Text(name)),
          Text(
            '${sales.toStringAsFixed(0)} ر.س',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}

class _StatRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  
  const _StatRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 18),
        ),
        const SizedBox(width: 12),
        Expanded(child: Text(label)),
        Text(value, style: const TextStyle(fontWeight: FontWeight.w500)),
      ],
    );
  }
}
