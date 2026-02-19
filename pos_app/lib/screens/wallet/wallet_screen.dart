import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';

class WalletScreen extends ConsumerStatefulWidget {
  const WalletScreen({super.key});
  @override
  ConsumerState<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends ConsumerState<WalletScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final size = MediaQuery.of(context).size;
    final isWide = size.width > 900;

    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showDepositDialog(context, isDark),
        icon: const Icon(Icons.add),
        label: const Text('إيداع'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E1E2E) : Colors.white,
              border: Border(bottom: BorderSide(color: isDark ? Colors.white12 : Colors.grey.shade200)),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    if (!isWide) IconButton(icon: const Icon(Icons.menu), onPressed: () => Scaffold.of(context).openDrawer()),
                    const Icon(Icons.account_balance_wallet, color: AppColors.primary, size: 28),
                    const SizedBox(width: 12),
                    Text('المحفظة الإلكترونية', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87)),
                  ],
                ),
                const SizedBox(height: 16),
                // Balance card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(colors: [AppColors.primary, Color(0xFF5B2D8E)]),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('الرصيد الحالي', style: TextStyle(color: Colors.white70, fontSize: 14)),
                      SizedBox(height: 8),
                      Text('0.00 ر.س', style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold)),
                      SizedBox(height: 12),
                      Row(
                        children: [
                          _WalletInfoChip(icon: Icons.arrow_downward, label: 'إيداعات', value: '0.00'),
                          SizedBox(width: 16),
                          _WalletInfoChip(icon: Icons.arrow_upward, label: 'سحوبات', value: '0.00'),
                          SizedBox(width: 16),
                          _WalletInfoChip(icon: Icons.swap_horiz, label: 'تحويلات', value: '0.00'),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                TabBar(
                  controller: _tabController,
                  labelColor: AppColors.primary,
                  unselectedLabelColor: isDark ? Colors.white54 : Colors.grey,
                  indicatorColor: AppColors.primary,
                  tabs: const [
                    Tab(text: 'المعاملات'),
                    Tab(text: 'الإيداعات'),
                    Tab(text: 'التحويلات'),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildTransactionsTab(isDark),
                _buildDepositsTab(isDark),
                _buildTransfersTab(isDark),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionsTab(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.receipt_long_outlined, size: 80, color: isDark ? Colors.white24 : Colors.grey.shade300),
          const SizedBox(height: 16),
          Text('لا توجد معاملات', style: TextStyle(fontSize: 16, color: isDark ? Colors.white54 : Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildDepositsTab(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.savings_outlined, size: 80, color: isDark ? Colors.white24 : Colors.grey.shade300),
          const SizedBox(height: 16),
          Text('لا توجد إيداعات', style: TextStyle(fontSize: 16, color: isDark ? Colors.white54 : Colors.grey)),
          const SizedBox(height: 8),
          Text('اضغط + لإضافة إيداع جديد', style: TextStyle(fontSize: 13, color: isDark ? Colors.white38 : Colors.grey.shade400)),
        ],
      ),
    );
  }

  Widget _buildTransfersTab(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.swap_horiz, size: 80, color: isDark ? Colors.white24 : Colors.grey.shade300),
          const SizedBox(height: 16),
          Text('لا توجد تحويلات', style: TextStyle(fontSize: 16, color: isDark ? Colors.white54 : Colors.grey)),
        ],
      ),
    );
  }

  void _showDepositDialog(BuildContext context, bool isDark) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('إيداع جديد'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(decoration: InputDecoration(labelText: 'المبلغ', suffixText: 'ر.س', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))), keyboardType: TextInputType.number),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              decoration: InputDecoration(labelText: 'طريقة الدفع', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
              items: const [
                DropdownMenuItem(value: 'bank', child: Text('تحويل بنكي')),
                DropdownMenuItem(value: 'card', child: Text('بطاقة ائتمان')),
                DropdownMenuItem(value: 'cash', child: Text('نقدي')),
              ],
              onChanged: (_) {},
            ),
            const SizedBox(height: 12),
            TextField(decoration: InputDecoration(labelText: 'ملاحظة', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))), maxLines: 2),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('إلغاء')),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white),
            child: const Text('إيداع'),
          ),
        ],
      ),
    );
  }
}

class _WalletInfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _WalletInfoChip({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: Colors.white70, size: 16),
        const SizedBox(width: 4),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(color: Colors.white54, fontSize: 10)),
            Text(value, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600)),
          ],
        ),
      ],
    );
  }
}
