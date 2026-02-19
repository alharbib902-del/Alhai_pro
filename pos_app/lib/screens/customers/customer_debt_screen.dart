import 'package:flutter/material.dart';

/// شاشة إدارة ديون العملاء
class CustomerDebtScreen extends StatefulWidget {
  const CustomerDebtScreen({super.key});

  @override
  State<CustomerDebtScreen> createState() => _CustomerDebtScreenState();
}

class _CustomerDebtScreenState extends State<CustomerDebtScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _sortBy = 'amount';
  
  final List<_DebtRecord> _debts = [
    _DebtRecord(
      id: '1',
      customerName: 'أحمد محمد',
      phone: '0501234567',
      totalDebt: 2500,
      dueDate: DateTime.now().subtract(const Duration(days: 10)),
      lastPayment: DateTime.now().subtract(const Duration(days: 30)),
      status: 'overdue',
    ),
    _DebtRecord(
      id: '2',
      customerName: 'خالد عمر',
      phone: '0551234567',
      totalDebt: 1800,
      dueDate: DateTime.now().add(const Duration(days: 5)),
      lastPayment: DateTime.now().subtract(const Duration(days: 15)),
      status: 'pending',
    ),
    _DebtRecord(
      id: '3',
      customerName: 'محمد علي',
      phone: '0561234567',
      totalDebt: 3200,
      dueDate: DateTime.now().subtract(const Duration(days: 3)),
      lastPayment: null,
      status: 'overdue',
    ),
    _DebtRecord(
      id: '4',
      customerName: 'فهد سعد',
      phone: '0571234567',
      totalDebt: 950,
      dueDate: DateTime.now().add(const Duration(days: 20)),
      lastPayment: DateTime.now().subtract(const Duration(days: 7)),
      status: 'pending',
    ),
  ];

  double get _totalDebt => _debts.fold(0, (sum, d) => sum + d.totalDebt);
  int get _overdueCount => _debts.where((d) => d.status == 'overdue').length;

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

  List<_DebtRecord> _getFilteredDebts(String filter) {
    var list = _debts;
    if (filter == 'overdue') {
      list = list.where((d) => d.status == 'overdue').toList();
    } else if (filter == 'pending') {
      list = list.where((d) => d.status == 'pending').toList();
    }
    
    if (_sortBy == 'amount') {
      list.sort((a, b) => b.totalDebt.compareTo(a.totalDebt));
    } else if (_sortBy == 'date') {
      list.sort((a, b) => a.dueDate.compareTo(b.dueDate));
    } else if (_sortBy == 'name') {
      list.sort((a, b) => a.customerName.compareTo(b.customerName));
    }
    return list;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('إدارة الديون'),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.sort),
            tooltip: 'ترتيب',
            onSelected: (v) => setState(() => _sortBy = v),
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'amount', child: Text('حسب المبلغ')),
              const PopupMenuItem(value: 'date', child: Text('حسب التاريخ')),
              const PopupMenuItem(value: 'name', child: Text('حسب الاسم')),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.notifications),
            tooltip: 'إرسال تذكيرات',
            onPressed: _sendReminders,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'الكل'),
            Tab(text: 'متأخرة'),
            Tab(text: 'قادمة'),
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
                    icon: Icons.account_balance_wallet,
                    title: 'إجمالي الديون',
                    value: '${_totalDebt.toStringAsFixed(0)} ر.س',
                    color: Colors.red,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _SummaryCard(
                    icon: Icons.warning,
                    title: 'ديون متأخرة',
                    value: '$_overdueCount عميل',
                    color: Colors.orange,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _SummaryCard(
                    icon: Icons.people,
                    title: 'عملاء مدينون',
                    value: '${_debts.length}',
                    color: Colors.blue,
                  ),
                ),
              ],
            ),
          ),
          
          // Debts list
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildDebtList('all'),
                _buildDebtList('overdue'),
                _buildDebtList('pending'),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildDebtList(String filter) {
    final debts = _getFilteredDebts(filter);
    if (debts.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check_circle, size: 64, color: Colors.green.shade300),
            const SizedBox(height: 16),
            const Text('لا توجد ديون', style: TextStyle(fontSize: 18)),
          ],
        ),
      );
    }
    
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: debts.length,
      itemBuilder: (context, index) {
        final debt = debts[index];
        final isOverdue = debt.status == 'overdue';
        final daysLeft = debt.dueDate.difference(DateTime.now()).inDays;
        
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: InkWell(
            onTap: () => _showDebtDetails(debt),
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: isOverdue 
                            ? Colors.red.withValues(alpha: 0.1)
                            : Colors.blue.withValues(alpha: 0.1),
                        child: Text(
                          debt.customerName[0],
                          style: TextStyle(
                            color: isOverdue ? Colors.red : Colors.blue,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              debt.customerName,
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Text(
                              debt.phone,
                              style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                            ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '${debt.totalDebt.toStringAsFixed(0)} ر.س',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              color: isOverdue ? Colors.red : Colors.blue,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: isOverdue 
                                  ? Colors.red.withValues(alpha: 0.1)
                                  : Colors.green.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              isOverdue 
                                  ? 'متأخر ${-daysLeft} يوم'
                                  : 'متبقي $daysLeft يوم',
                              style: TextStyle(
                                fontSize: 11,
                                color: isOverdue ? Colors.red : Colors.green,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  if (debt.lastPayment != null) ...[
                    const Divider(height: 24),
                    Row(
                      children: [
                        Icon(Icons.history, size: 14, color: Colors.grey.shade600),
                        const SizedBox(width: 4),
                        Text(
                          'آخر دفعة: ${_formatDate(debt.lastPayment!)}',
                          style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                        ),
                        const Spacer(),
                        TextButton.icon(
                          onPressed: () => _recordPayment(debt),
                          icon: const Icon(Icons.payment, size: 16),
                          label: const Text('تسجيل دفعة'),
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }
  
  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
  
  void _showDebtDetails(_DebtRecord debt) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.5,
        minChildSize: 0.3,
        maxChildSize: 0.8,
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
              children: [
                CircleAvatar(
                  radius: 32,
                  child: Text(debt.customerName[0], style: const TextStyle(fontSize: 24)),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(debt.customerName, style: Theme.of(context).textTheme.titleLarge),
                      Text(debt.phone, style: TextStyle(color: Colors.grey.shade600)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: (debt.status == 'overdue' ? Colors.red : Colors.blue).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Text(
                    '${debt.totalDebt.toStringAsFixed(0)} ر.س',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: debt.status == 'overdue' ? Colors.red : Colors.blue,
                    ),
                  ),
                  const Text('المبلغ المستحق'),
                ],
              ),
            ),
            const SizedBox(height: 24),
            _DetailRow(label: 'تاريخ الاستحقاق', value: _formatDate(debt.dueDate)),
            if (debt.lastPayment != null)
              _DetailRow(label: 'آخر دفعة', value: _formatDate(debt.lastPayment!)),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.message),
                    label: const Text('إرسال تذكير'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      _recordPayment(debt);
                    },
                    icon: const Icon(Icons.payment),
                    label: const Text('تسجيل دفعة'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  void _recordPayment(_DebtRecord debt) {
    final amountController = TextEditingController();
    String paymentMethod = 'cash';
    
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text('تسجيل دفعة - ${debt.customerName}'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('الدين الحالي: ${debt.totalDebt.toStringAsFixed(0)} ر.س'),
              const SizedBox(height: 16),
              TextField(
                controller: amountController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'المبلغ المدفوع',
                  prefixIcon: Icon(Icons.attach_money),
                  suffixText: 'ر.س',
                ),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                // ignore: deprecated_member_use
                value: paymentMethod,
                decoration: const InputDecoration(
                  labelText: 'طريقة الدفع',
                  prefixIcon: Icon(Icons.payment),
                ),
                items: const [
                  DropdownMenuItem(value: 'cash', child: Text('نقدي')),
                  DropdownMenuItem(value: 'card', child: Text('بطاقة')),
                  DropdownMenuItem(value: 'transfer', child: Text('تحويل')),
                ],
                onChanged: (v) => setDialogState(() => paymentMethod = v!),
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
                  const SnackBar(content: Text('تم تسجيل الدفعة بنجاح')),
                );
              },
              child: const Text('تأكيد'),
            ),
          ],
        ),
      ),
    );
  }
  
  void _sendReminders() {
    final overdueDebts = _debts.where((d) => d.status == 'overdue').toList();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('إرسال تذكيرات'),
        content: Text('سيتم إرسال تذكير لـ ${overdueDebts.length} عميل لديهم ديون متأخرة'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('تم إرسال ${overdueDebts.length} تذكير')),
              );
            },
            child: const Text('إرسال'),
          ),
        ],
      ),
    );
  }
}

class _DebtRecord {
  final String id;
  final String customerName;
  final String phone;
  final double totalDebt;
  final DateTime dueDate;
  final DateTime? lastPayment;
  final String status;
  
  _DebtRecord({
    required this.id,
    required this.customerName,
    required this.phone,
    required this.totalDebt,
    required this.dueDate,
    this.lastPayment,
    required this.status,
  });
}

class _SummaryCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final Color color;
  
  const _SummaryCard({
    required this.icon,
    required this.title,
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
          Text(
            value,
            style: TextStyle(fontWeight: FontWeight.bold, color: color),
          ),
          Text(
            title,
            style: TextStyle(fontSize: 11, color: color.withValues(alpha: 0.8)),
            textAlign: TextAlign.center,
          ),
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
