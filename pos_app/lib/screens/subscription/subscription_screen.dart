import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';

class SubscriptionScreen extends ConsumerWidget {
  const SubscriptionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final size = MediaQuery.of(context).size;
    final isWide = size.width > 900;

    return Scaffold(
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E1E2E) : Colors.white,
              border: Border(bottom: BorderSide(color: isDark ? Colors.white12 : Colors.grey.shade200)),
            ),
            child: Row(
              children: [
                if (!isWide) IconButton(icon: const Icon(Icons.menu), onPressed: () => Scaffold.of(context).openDrawer()),
                const Icon(Icons.card_membership, color: AppColors.primary, size: 28),
                const SizedBox(width: 12),
                Text('إدارة الاشتراكات', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87)),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Current plan card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(colors: [AppColors.primary, Color(0xFF5B2D8E)]),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Text('خطتك الحالية', style: TextStyle(color: Colors.white70, fontSize: 14)),
                            const Spacer(),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                              decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(20)),
                              child: const Text('المجانية', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        const Text('الباقة التجريبية', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(Icons.timer_outlined, color: Colors.white70, size: 18),
                            const SizedBox(width: 6),
                            Text('متبقي 6 أيام', style: TextStyle(color: Colors.orange.shade200, fontSize: 14, fontWeight: FontWeight.w600)),
                          ],
                        ),
                        const SizedBox(height: 16),
                        LinearProgressIndicator(value: 0.14, backgroundColor: Colors.white24, color: Colors.orange.shade300, minHeight: 6),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text('الخطط المتاحة', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87)),
                  const SizedBox(height: 16),
                  // Plans grid
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final crossCount = constraints.maxWidth > 800 ? 4 : (constraints.maxWidth > 500 ? 2 : 1);
                      return GridView.count(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisCount: crossCount,
                        crossAxisSpacing: 12, mainAxisSpacing: 12,
                        childAspectRatio: 0.75,
                        children: [
                          _buildPlanCard('مجانية', '0', ['10 منتجات', 'فرع واحد', 'موظف واحد', 'تقارير أساسية'], false, isDark),
                          _buildPlanCard('أساسية', '99', ['100 منتج', '3 فروع', '5 موظفين', 'تقارير متقدمة', 'دعم بريدي'], false, isDark),
                          _buildPlanCard('احترافية', '199', ['منتجات غير محدودة', '10 فروع', '20 موظف', 'كل التقارير', 'دعم فوري', 'AI ميزات'], true, isDark),
                          _buildPlanCard('مؤسسية', '499', ['كل شيء غير محدود', 'فروع غير محدودة', 'موظفين غير محدود', 'API متقدم', 'مدير حساب خاص', 'تخصيص كامل'], false, isDark),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlanCard(String name, String price, List<String> features, bool isPopular, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E2E) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isPopular ? AppColors.primary : (isDark ? Colors.white12 : Colors.grey.shade200), width: isPopular ? 2 : 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isPopular) Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            margin: const EdgeInsets.only(bottom: 8),
            decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(8)),
            child: const Text('الأكثر شيوعاً', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
          ),
          Text(name, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87)),
          const SizedBox(height: 4),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(price, style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: AppColors.primary)),
              const SizedBox(width: 4),
              Text('ر.س/شهر', style: TextStyle(fontSize: 12, color: isDark ? Colors.white54 : Colors.grey)),
            ],
          ),
          const SizedBox(height: 12),
          ...features.map((f) => Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.green, size: 16),
                const SizedBox(width: 6),
                Expanded(child: Text(f, style: TextStyle(fontSize: 12, color: isDark ? Colors.white70 : Colors.black54))),
              ],
            ),
          )),
          const Spacer(),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: isPopular ? AppColors.primary : (isDark ? Colors.white12 : Colors.grey.shade100),
                foregroundColor: isPopular ? Colors.white : (isDark ? Colors.white : Colors.black87),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text('اختيار'),
            ),
          ),
        ],
      ),
    );
  }
}
