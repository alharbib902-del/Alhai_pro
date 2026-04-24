/// قائمة تصدير التقرير (CSV / PDF)
///
/// ملاحظة: التصدير الفعلي خارج نطاق 3.2 (لا packages جديدة). هذا
/// المكوّن يوفّر واجهة موحّدة جاهزة للربط لاحقاً. يضغط المستخدم زر
/// التصدير، يظهر bottom-sheet بخيارين. كلا الخيارين يعرض رسالة
/// "قريباً" لعدم كسر السلوك الحالي.
library;

import 'package:flutter/material.dart';
import 'package:alhai_shared_ui/alhai_shared_ui.dart';
import 'package:alhai_l10n/alhai_l10n.dart';
import 'package:alhai_design_system/alhai_design_system.dart'
    show AlhaiSnackbar, AlhaiSpacing;

import '../providers/report_data_provider.dart';

class ExportMenu extends StatelessWidget {
  final ReportResult result;
  final bool isDark;

  const ExportMenu({super.key, required this.result, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    if (result.rows.isEmpty) return const SizedBox.shrink();

    return Align(
      alignment: AlignmentDirectional.centerEnd,
      child: OutlinedButton.icon(
        onPressed: () => _show(context),
        icon: const Icon(Icons.file_download_rounded, size: 18),
        label: Text(l10n.exportData),
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          side: BorderSide(
            color: AppColors.primary.withValues(alpha: 0.4),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  void _show(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.getSurface(isDark),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: AlhaiSpacing.sm),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.getBorder(isDark),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: AlhaiSpacing.md),
            ListTile(
              leading: const Icon(
                Icons.table_view_rounded,
                color: AppColors.primary,
              ),
              title: Text(l10n.exportData),
              subtitle: const Text('CSV'),
              onTap: () {
                Navigator.of(ctx).pop();
                AlhaiSnackbar.info(context, l10n.comingSoon);
              },
            ),
            ListTile(
              leading: const Icon(
                Icons.picture_as_pdf_rounded,
                color: AppColors.error,
              ),
              title: Text(l10n.exportData),
              subtitle: const Text('PDF'),
              onTap: () {
                Navigator.of(ctx).pop();
                AlhaiSnackbar.info(context, l10n.comingSoon);
              },
            ),
            const SizedBox(height: AlhaiSpacing.sm),
          ],
        ),
      ),
    );
  }
}
