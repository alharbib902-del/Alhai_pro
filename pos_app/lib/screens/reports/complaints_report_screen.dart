import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../l10n/generated/app_localizations.dart';

class ComplaintsReportScreen extends ConsumerWidget {
  const ComplaintsReportScreen({super.key});

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
              color: isDark ? const Color(0xFF1E1E2E) : Theme.of(context).colorScheme.surface,
              border: Border(bottom: BorderSide(color: isDark ? Colors.white12 : Theme.of(context).dividerColor)),
            ),
            child: Row(
              children: [
                if (!isWide) IconButton(icon: const Icon(Icons.menu), onPressed: () => Scaffold.of(context).openDrawer()),
                const Icon(Icons.feedback_outlined, color: AppColors.primary, size: 28),
                const SizedBox(width: 12),
                Text(AppLocalizations.of(context)!.complaintsReport, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Theme.of(context).colorScheme.onSurface)),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Stats row
                  Wrap(
                    spacing: 12, runSpacing: 12,
                    children: [
                      _buildStatCard(context, 'إجمالي الشكاوى', '0', Icons.list_alt, Colors.blue, isDark),
                      _buildStatCard(context, 'مفتوحة', '0', Icons.hourglass_empty, Colors.orange, isDark),
                      _buildStatCard(context, 'مغلقة', '0', Icons.check_circle, Colors.green, isDark),
                      _buildStatCard(context, 'متوسط وقت الحل', '0 يوم', Icons.timer, AppColors.primary, isDark),
                    ],
                  ),
                  const SizedBox(height: 24),
                  // Filters
                  Wrap(
                    spacing: 12, runSpacing: 12,
                    children: [
                      SizedBox(width: 180, child: TextField(decoration: InputDecoration(labelText: 'من تاريخ', prefixIcon: const Icon(Icons.calendar_today, size: 18), border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)), isDense: true))),
                      SizedBox(width: 180, child: TextField(decoration: InputDecoration(labelText: 'إلى تاريخ', prefixIcon: const Icon(Icons.calendar_today, size: 18), border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)), isDense: true))),
                      SizedBox(width: 160, child: DropdownButtonFormField<String>(decoration: InputDecoration(labelText: 'الحالة', border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)), isDense: true), items: const [DropdownMenuItem(value: 'all', child: Text('الكل')), DropdownMenuItem(value: 'open', child: Text('مفتوحة')), DropdownMenuItem(value: 'closed', child: Text('مغلقة'))], onChanged: (_) {})),
                      SizedBox(width: 160, child: DropdownButtonFormField<String>(decoration: InputDecoration(labelText: 'القسم', border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)), isDense: true), items: const [DropdownMenuItem(value: 'all', child: Text('الكل')), DropdownMenuItem(value: 'payment', child: Text('الدفع')), DropdownMenuItem(value: 'technical', child: Text('تقني')), DropdownMenuItem(value: 'other', child: Text('أخرى'))], onChanged: (_) {})),
                    ],
                  ),
                  const SizedBox(height: 24),
                  // Empty state
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.all(60),
                      child: Column(
                        children: [
                          Icon(Icons.sentiment_satisfied_alt, size: 80, color: isDark ? Colors.white24 : Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.3)),
                          const SizedBox(height: 16),
                          Text(AppLocalizations.of(context)!.noData, style: TextStyle(fontSize: 16, color: isDark ? Colors.white54 : Theme.of(context).colorScheme.onSurfaceVariant)),
                          const SizedBox(height: 8),
                          Text('لم يتم تسجيل أي شكاوى حتى الآن', style: TextStyle(fontSize: 13, color: isDark ? Colors.white38 : Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.5))),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(BuildContext context, String title, String value, IconData icon, Color color, bool isDark) {
    final theme = Theme.of(context);
    return Container(
      width: 180,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E2E) : theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isDark ? Colors.white12 : theme.dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 12),
          Text(value, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: isDark ? Colors.white : theme.colorScheme.onSurface)),
          const SizedBox(height: 4),
          Text(title, style: TextStyle(fontSize: 13, color: isDark ? Colors.white54 : theme.colorScheme.onSurfaceVariant)),
        ],
      ),
    );
  }
}
