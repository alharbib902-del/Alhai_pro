/// شاشة التقارير المخصصة — الحاوية (container)
///
/// هذا الملف هو الـ container فقط: يركّب الـ AppHeader ويوزّع المساحة
/// على widgets الفرعية، ويدير "زرّ توليد التقرير" (trigger واحد، setState
/// محلي بسيط للحالة: idle/loading/result). بقيّة الـ state (النوع،
/// التجميع، المدى الزمني) عبر [reportConfigProvider].
///
/// - يدعم RTL/العربية، داكن/فاتح، تصميم responsive (mobile/tablet/desktop).
/// - الاسم `CustomReportScreen` محفوظ للـ router.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:alhai_shared_ui/alhai_shared_ui.dart';
import 'package:alhai_l10n/alhai_l10n.dart';
import 'package:alhai_design_system/alhai_design_system.dart'
    show AlhaiContextExtensions, AlhaiSnackbar, AlhaiSpacing;
// alhai_design_system is re-exported via alhai_shared_ui

import '../../../core/services/sentry_service.dart';
import 'providers/report_config_notifier.dart';
import 'providers/report_data_provider.dart';
import 'widgets/chart_renderer.dart';
import 'widgets/export_menu.dart';
import 'widgets/report_builder.dart';
import 'widgets/report_filters.dart';
import 'widgets/report_preview.dart';

/// شاشة التقارير المخصصة
class CustomReportScreen extends ConsumerStatefulWidget {
  const CustomReportScreen({super.key});

  @override
  ConsumerState<CustomReportScreen> createState() => _CustomReportScreenState();
}

/// حالة عرض النتيجة
enum _ResultState { idle, loading, ready }

class _CustomReportScreenState extends ConsumerState<CustomReportScreen> {
  _ResultState _status = _ResultState.idle;
  ReportResult _result = ReportResult.empty;

  Future<void> _generate() async {
    final storeId = ref.read(currentStoreIdProvider);
    final config = ref.read(reportConfigProvider);
    if (storeId == null || config.dateRange == null) return;

    setState(() => _status = _ResultState.loading);

    try {
      final repo = ref.read(reportDataRepositoryProvider);
      final result = await repo.generate(storeId: storeId, config: config);
      if (!mounted) return;
      setState(() {
        _result = result;
        _status = _ResultState.ready;
      });
    } catch (e, stack) {
      reportError(e, stackTrace: stack, hint: 'Generate custom report');
      if (!mounted) return;
      setState(() {
        _result = ReportResult.empty;
        _status = _ResultState.ready;
      });
      AlhaiSnackbar.error(
        context,
        AppLocalizations.of(context).errorOccurred,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isWideScreen = context.isDesktop;
    final isMediumScreen = !context.isMobile;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context);

    return Column(
      children: [
        AppHeader(
          title: l10n.customReport,
          subtitle: '${l10n.reportBuilder} \u2022 ${l10n.mainBranch}',
          showSearch: false,
          searchHint: l10n.searchPlaceholder,
          onMenuTap: isWideScreen
              ? null
              : () => Scaffold.of(context).openDrawer(),
          onNotificationsTap: () => context.push('/notifications'),
          notificationsCount: 3,
          userName: l10n.cashCustomer,
          userRole: l10n.branchManager,
          onUserTap: () {},
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(
              isMediumScreen ? AlhaiSpacing.lg : AlhaiSpacing.md,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Config + filters
                if (isWideScreen)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 3,
                        child: ReportBuilderCard(isDark: isDark),
                      ),
                      const SizedBox(width: AlhaiSpacing.lg),
                      Expanded(
                        flex: 2,
                        child: ReportFiltersCard(
                          isDark: isDark,
                          isMediumScreen: isMediumScreen,
                        ),
                      ),
                    ],
                  )
                else ...[
                  ReportBuilderCard(isDark: isDark),
                  SizedBox(
                    height: isMediumScreen ? AlhaiSpacing.lg : AlhaiSpacing.md,
                  ),
                  ReportFiltersCard(
                    isDark: isDark,
                    isMediumScreen: isMediumScreen,
                  ),
                ],
                SizedBox(
                  height: isMediumScreen ? AlhaiSpacing.lg : AlhaiSpacing.md,
                ),
                _GenerateButton(
                  isLoading: _status == _ResultState.loading,
                  onPressed: _generate,
                ),
                SizedBox(
                  height: isMediumScreen ? AlhaiSpacing.lg : AlhaiSpacing.md,
                ),
                if (_status == _ResultState.loading)
                  const Padding(
                    padding: EdgeInsets.all(AlhaiSpacing.xxxl),
                    child: AppLoadingState(),
                  )
                else if (_status == _ResultState.ready) ...[
                  ExportMenu(result: _result, isDark: isDark),
                  SizedBox(
                    height: isMediumScreen ? AlhaiSpacing.md : AlhaiSpacing.sm,
                  ),
                  ReportPreview(
                    result: _result,
                    isWideScreen: isWideScreen,
                    isMediumScreen: isMediumScreen,
                    isDark: isDark,
                  ),
                  if (_result.rows.isNotEmpty) ...[
                    SizedBox(
                      height:
                          isMediumScreen ? AlhaiSpacing.lg : AlhaiSpacing.md,
                    ),
                    ChartRenderer(result: _result, isDark: isDark),
                  ],
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _GenerateButton extends StatelessWidget {
  final bool isLoading;
  final VoidCallback onPressed;

  const _GenerateButton({required this.isLoading, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return SizedBox(
      height: 52,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.textOnPrimary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          elevation: 0,
        ),
        child: isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColors.textOnPrimary,
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.analytics_rounded, size: 20),
                  const SizedBox(width: 10),
                  Text(
                    l10n.generateReport,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
