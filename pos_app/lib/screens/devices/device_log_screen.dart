import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';

class DeviceLogScreen extends ConsumerWidget {
  const DeviceLogScreen({super.key});

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
                const Icon(Icons.devices, color: AppColors.primary, size: 28),
                const SizedBox(width: 12),
                Text('سجل الأجهزة', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87)),
              ],
            ),
          ),
          // Info banner
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.08),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.blue.withOpacity(0.2)),
            ),
            child: const Row(
              children: [
                Icon(Icons.info_outline, color: Colors.blue, size: 20),
                SizedBox(width: 10),
                Expanded(child: Text('يتم تسجيل جميع الأجهزة التي تم تسجيل الدخول منها تلقائياً', style: TextStyle(fontSize: 13, color: Colors.blue))),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                _buildDeviceItem('الجهاز الحالي', 'Windows PC', 'Chrome 120', '192.168.1.100', DateTime.now(), true, isDark),
                _buildDeviceItem('جوال أندرويد', 'Samsung Galaxy S23', 'Al-HAI POS App', '192.168.1.105', DateTime.now().subtract(const Duration(hours: 2)), true, isDark),
                _buildDeviceItem('تابلت', 'iPad Pro', 'Safari', '192.168.1.108', DateTime.now().subtract(const Duration(days: 3)), false, isDark),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDeviceItem(String name, String device, String browser, String ip, DateTime lastSeen, bool isActive, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E2E) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isDark ? Colors.white12 : Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Container(
            width: 48, height: 48,
            decoration: BoxDecoration(
              color: (isActive ? Colors.green : Colors.grey).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              device.contains('iPad') || device.contains('Tab') ? Icons.tablet_mac : (device.contains('Samsung') || device.contains('Phone') ? Icons.phone_android : Icons.computer),
              color: isActive ? Colors.green : Colors.grey,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(name, style: TextStyle(fontWeight: FontWeight.w600, color: isDark ? Colors.white : Colors.black87)),
                    if (name == 'الجهاز الحالي') ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(color: Colors.green.withOpacity(0.1), borderRadius: BorderRadius.circular(6)),
                        child: const Text('الحالي', style: TextStyle(color: Colors.green, fontSize: 10, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 4),
                Text('$device • $browser', style: TextStyle(fontSize: 12, color: isDark ? Colors.white54 : Colors.grey)),
                Text('IP: $ip', style: TextStyle(fontSize: 11, color: isDark ? Colors.white38 : Colors.grey.shade400)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                width: 8, height: 8,
                decoration: BoxDecoration(shape: BoxShape.circle, color: isActive ? Colors.green : Colors.grey),
              ),
              const SizedBox(height: 6),
              Text(isActive ? 'متصل الآن' : 'غير متصل', style: TextStyle(fontSize: 11, color: isActive ? Colors.green : Colors.grey)),
            ],
          ),
        ],
      ),
    );
  }
}
