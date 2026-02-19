import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// شاشة تقرير الديون
class DebtsReportScreen extends ConsumerStatefulWidget {
  const DebtsReportScreen({super.key});

  @override
  ConsumerState<DebtsReportScreen> createState() => _DebtsReportScreenState();
}

class _DebtsReportScreenState extends ConsumerState<DebtsReportScreen> {
  bool _isLoading = true;
  List<Map<String, dynamic>> _debts = [];
  double _totalDebts = 0;
  String _sortBy = 'amount';

  @override
  void initState() {
    super.initState();
    _loadDebts();
  }

  Future<void> _loadDebts() async {
    setState(() => _isLoading = true);
    
    // Mock data للتطوير - TODO: ربط بقاعدة البيانات
    await Future.delayed(const Duration(milliseconds: 500));
    
    setState(() {
      _debts = [
        {'id': '1', 'name': 'محمد أحمد', 'phone': '0501234567', 'balance': 1500.0, 'lastPayment': DateTime.now().subtract(const Duration(days: 5))},
        {'id': '2', 'name': 'علي خالد', 'phone': '0551234567', 'balance': 2000.0, 'lastPayment': DateTime.now().subtract(const Duration(days: 10))},
        {'id': '3', 'name': 'فهد سعد', 'phone': '0561234567', 'balance': 750.0, 'lastPayment': DateTime.now().subtract(const Duration(days: 3))},
      ];
      
      _totalDebts = _debts.fold(0.0, (sum, d) => sum + (d['balance'] as double));
      _sortDebts();
      _isLoading = false;
    });
  }

  void _sortDebts() {
    if (_sortBy == 'amount') {
      _debts.sort((a, b) => (b['balance'] as double).compareTo(a['balance'] as double));
    } else if (_sortBy == 'name') {
      _debts.sort((a, b) => (a['name'] as String).compareTo(b['name'] as String));
    } else if (_sortBy == 'date') {
      _debts.sort((a, b) => (b['lastPayment'] as DateTime).compareTo(a['lastPayment'] as DateTime));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('تقرير الديون'),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.sort),
            tooltip: 'ترتيب',
            onSelected: (value) {
              setState(() {
                _sortBy = value;
                _sortDebts();
              });
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'amount', child: Text('حسب المبلغ')),
              const PopupMenuItem(value: 'name', child: Text('حسب الاسم')),
              const PopupMenuItem(value: 'date', child: Text('حسب آخر دفعة')),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.print),
            tooltip: 'طباعة',
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('جاري طباعة التقرير...')),
              );
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Summary card
                Container(
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.red.shade400, Colors.red.shade600],
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('إجمالي الديون', style: TextStyle(color: Colors.white70)),
                          const SizedBox(height: 4),
                          Text(
                            '${_totalDebts.toStringAsFixed(0)} ر.س',
                            style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          const Text('عدد العملاء', style: TextStyle(color: Colors.white70)),
                          const SizedBox(height: 4),
                          Text(
                            '${_debts.length}',
                            style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Debts list
                Expanded(
                  child: _debts.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.check_circle, size: 64, color: Colors.green.shade400),
                              const SizedBox(height: 16),
                              Text('لا توجد ديون مستحقة', style: TextStyle(color: Colors.grey.shade600)),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: _debts.length,
                          itemBuilder: (context, index) {
                            final debt = _debts[index];
                            return Card(
                              margin: const EdgeInsets.only(bottom: 8),
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: Colors.red.shade100,
                                  child: Text(
                                    (debt['name'] as String).isNotEmpty ? (debt['name'] as String)[0] : '?',
                                    style: TextStyle(color: Colors.red.shade700, fontWeight: FontWeight.bold),
                                  ),
                                ),
                                title: Text(debt['name'] as String),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    if (debt['phone'] != null)
                                      Text(debt['phone'] as String, style: TextStyle(color: Colors.grey.shade600)),
                                    Text(
                                      'آخر تحديث: ${_formatDate(debt['lastPayment'] as DateTime)}',
                                      style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
                                    ),
                                  ],
                                ),
                                trailing: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      '${(debt['balance'] as double).toStringAsFixed(0)} ر.س',
                                      style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.red, fontSize: 16),
                                    ),
                                    TextButton(
                                      onPressed: () => _recordPayment(debt),
                                      style: TextButton.styleFrom(padding: EdgeInsets.zero, minimumSize: const Size(0, 0)),
                                      child: const Text('تسجيل دفعة', style: TextStyle(fontSize: 12)),
                                    ),
                                  ],
                                ),
                                onTap: () => _showCustomerDetails(debt),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void _recordPayment(Map<String, dynamic> debt) {
    final amountController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('تسجيل دفعة - ${debt['name']}'),
        content: TextField(
          controller: amountController,
          keyboardType: TextInputType.number,
          autofocus: true,
          decoration: InputDecoration(
            labelText: 'مبلغ الدفعة',
            suffixText: 'ر.س',
            helperText: 'الدين الحالي: ${(debt['balance'] as double).toStringAsFixed(0)} ر.س',
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('إلغاء')),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('تم تسجيل الدفعة'), backgroundColor: Colors.green),
              );
              _loadDebts();
            },
            child: const Text('تسجيل'),
          ),
        ],
      ),
    );
  }

  void _showCustomerDetails(Map<String, dynamic> debt) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('عرض تفاصيل: ${debt['name']}')),
    );
  }
}
