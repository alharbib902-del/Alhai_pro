import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';

class MediaLibraryScreen extends ConsumerWidget {
  const MediaLibraryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final size = MediaQuery.of(context).size;
    final isWide = size.width > 900;

    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showUploadDialog(context, isDark),
        icon: const Icon(Icons.cloud_upload),
        label: const Text('رفع صور'),
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
            child: Row(
              children: [
                if (!isWide) IconButton(icon: const Icon(Icons.menu), onPressed: () => Scaffold.of(context).openDrawer()),
                const Icon(Icons.photo_library, color: AppColors.primary, size: 28),
                const SizedBox(width: 12),
                Text('مكتبة الصور', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87)),
                const Spacer(),
                SegmentedButton<String>(
                  segments: const [
                    ButtonSegment(value: 'all', icon: Icon(Icons.grid_view, size: 18), label: Text('الكل')),
                    ButtonSegment(value: 'images', icon: Icon(Icons.image, size: 18), label: Text('صور')),
                    ButtonSegment(value: 'docs', icon: Icon(Icons.description, size: 18), label: Text('مستندات')),
                  ],
                  selected: const {'all'},
                  onSelectionChanged: (_) {},
                ),
              ],
            ),
          ),
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 120, height: 120,
                    decoration: BoxDecoration(
                      color: isDark ? Colors.white.withOpacity(0.05) : Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Icon(Icons.cloud_upload_outlined, size: 60, color: isDark ? Colors.white24 : Colors.grey.shade300),
                  ),
                  const SizedBox(height: 20),
                  Text('مكتبة الصور فارغة', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: isDark ? Colors.white70 : Colors.black54)),
                  const SizedBox(height: 8),
                  Text('اسحب وأفلت الصور هنا أو اضغط زر رفع صور', style: TextStyle(fontSize: 13, color: isDark ? Colors.white38 : Colors.grey)),
                  const SizedBox(height: 24),
                  OutlinedButton.icon(
                    onPressed: () => _showUploadDialog(context, isDark),
                    icon: const Icon(Icons.add_photo_alternate),
                    label: const Text('رفع صور'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      side: const BorderSide(color: AppColors.primary),
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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

  void _showUploadDialog(BuildContext context, bool isDark) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Row(children: [Icon(Icons.cloud_upload, color: AppColors.primary), SizedBox(width: 8), Text('رفع صور جديدة')]),
        content: Container(
          width: 400, height: 200,
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.primary.withOpacity(0.3), style: BorderStyle.solid),
            borderRadius: BorderRadius.circular(12),
            color: AppColors.primary.withOpacity(0.03),
          ),
          child: const Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.add_photo_alternate_outlined, size: 48, color: AppColors.primary),
              SizedBox(height: 12),
              Text('اسحب وأفلت الصور هنا', style: TextStyle(fontWeight: FontWeight.w500)),
              SizedBox(height: 4),
              Text('أو اضغط لاختيار ملفات', style: TextStyle(fontSize: 12, color: Colors.grey)),
              SizedBox(height: 8),
              Text('JPG, PNG, GIF - حد أقصى 5MB', style: TextStyle(fontSize: 11, color: Colors.grey)),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('إلغاء')),
          ElevatedButton.icon(
            onPressed: () => Navigator.pop(ctx),
            icon: const Icon(Icons.folder_open, size: 18),
            label: const Text('اختر ملفات'),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white),
          ),
        ],
      ),
    );
  }
}
