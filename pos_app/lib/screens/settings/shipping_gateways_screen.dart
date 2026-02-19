import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';

class ShippingGatewaysScreen extends ConsumerWidget {
  const ShippingGatewaysScreen({super.key});

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
                const Icon(Icons.local_shipping, color: AppColors.primary, size: 28),
                const SizedBox(width: 12),
                Text('بوابات الشحن', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87)),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('بوابات الشحن المتاحة', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: isDark ? Colors.white70 : Colors.black54)),
                  const SizedBox(height: 4),
                  Text('قم بتفعيل وإعداد بوابات الشحن لتوصيل الطلبات', style: TextStyle(fontSize: 13, color: isDark ? Colors.white38 : Colors.grey)),
                  const SizedBox(height: 20),
                  _buildGatewayCard('أرامكس', 'Aramex', 'شركة شحن عالمية بخدمات متعددة', Icons.flight, true, const Color(0xFFE44D26), isDark),
                  const SizedBox(height: 12),
                  _buildGatewayCard('SMSA Express', 'SMSA', 'شحن سريع داخل المملكة', Icons.speed, false, const Color(0xFF00539F), isDark),
                  const SizedBox(height: 12),
                  _buildGatewayCard('فاستلو', 'Fastlo', 'توصيل سريع في نفس اليوم', Icons.electric_moped, false, const Color(0xFF6C63FF), isDark),
                  const SizedBox(height: 12),
                  _buildGatewayCard('DHL', 'DHL Express', 'شحن دولي سريع وموثوق', Icons.public, false, const Color(0xFFFFCC00), isDark),
                  const SizedBox(height: 12),
                  _buildGatewayCard('سمسا', 'J&T Express', 'شحن اقتصادي', Icons.local_shipping, false, const Color(0xFFE60012), isDark),
                  const SizedBox(height: 12),
                  _buildGatewayCard('توصيل خاص', 'Custom Delivery', 'إدارة التوصيل بسائقيك الخاصين', Icons.person_pin_circle, true, Colors.teal, isDark),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGatewayCard(String name, String nameEn, String description, IconData icon, bool isActive, Color brandColor, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E2E) : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: isActive ? AppColors.primary.withOpacity(0.3) : (isDark ? Colors.white12 : Colors.grey.shade200)),
        boxShadow: isActive ? [BoxShadow(color: AppColors.primary.withOpacity(0.05), blurRadius: 10)] : null,
      ),
      child: Row(
        children: [
          Container(
            width: 56, height: 56,
            decoration: BoxDecoration(color: brandColor.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: brandColor, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(name, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: isDark ? Colors.white : Colors.black87)),
                    const SizedBox(width: 8),
                    Text(nameEn, style: TextStyle(fontSize: 12, color: isDark ? Colors.white38 : Colors.grey)),
                  ],
                ),
                const SizedBox(height: 4),
                Text(description, style: TextStyle(fontSize: 13, color: isDark ? Colors.white54 : Colors.grey)),
              ],
            ),
          ),
          Column(
            children: [
              Switch(value: isActive, onChanged: (_) {}, activeColor: AppColors.primary),
              if (isActive) TextButton(
                onPressed: () {},
                child: const Text('إعدادات', style: TextStyle(fontSize: 12)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
