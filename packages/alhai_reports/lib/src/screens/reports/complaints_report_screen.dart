import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:alhai_design_system/alhai_design_system.dart';
import 'package:alhai_l10n/alhai_l10n.dart';

class ComplaintsReportScreen extends ConsumerStatefulWidget {
  const ComplaintsReportScreen({super.key});

  @override
  ConsumerState<ComplaintsReportScreen> createState() =>
      _ComplaintsReportScreenState();
}

class _ComplaintsReportScreenState
    extends ConsumerState<ComplaintsReportScreen> {
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      // Simulate loading complaints data
      await Future.delayed(const Duration(milliseconds: 500));
      if (mounted) setState(() => _isLoading = false);
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _error = e.toString();
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isWide = context.screenWidth >= 1200;
    final isMobile = context.isMobile;
    final padding = isMobile
        ? 12.0
        : isWide
            ? 24.0
            : 16.0;

    return Scaffold(
      body: Column(
        children: [
          Container(
            padding: EdgeInsets.all(padding),
            decoration: BoxDecoration(
              color: isDark
                  ? const Color(0xFF1E1E2E)
                  : Theme.of(context).colorScheme.surface,
              border: Border(
                  bottom: BorderSide(
                      color: isDark
                          ? Colors.white12
                          : Theme.of(context).dividerColor)),
            ),
            child: Row(
              children: [
                if (!isWide)
                  IconButton(
                      icon: const Icon(Icons.menu),
                      onPressed: () => Scaffold.of(context).openDrawer()),
                const Icon(Icons.feedback_outlined,
                    color: AppColors.primary, size: 28),
                const SizedBox(width: AlhaiSpacing.sm),
                Text(AppLocalizations.of(context).complaintsReport,
                    style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: isDark
                            ? Colors.white
                            : Theme.of(context).colorScheme.onSurface)),
              ],
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _error != null
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(AlhaiSpacing.xl),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.error_outline_rounded,
                                  size: 64,
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurfaceVariant),
                              const SizedBox(height: AlhaiSpacing.md),
                              Text(
                                AppLocalizations.of(context)
                                    .errorLoadingComplaints,
                                style: TextStyle(
                                    fontSize: 16,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurfaceVariant),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: AlhaiSpacing.md),
                              FilledButton.icon(
                                onPressed: _loadData,
                                icon: const Icon(Icons.refresh_rounded),
                                label: Text(AppLocalizations.of(context).retry),
                              ),
                            ],
                          ),
                        ),
                      )
                    : SingleChildScrollView(
                        padding: EdgeInsets.all(padding),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Stats row
                            Wrap(
                              spacing: 12,
                              runSpacing: 12,
                              children: [
                                _buildStatCard(
                                    context,
                                    AppLocalizations.of(context)
                                        .totalComplaintsLabel,
                                    '0',
                                    Icons.list_alt,
                                    Colors.blue,
                                    isDark),
                                _buildStatCard(
                                    context,
                                    AppLocalizations.of(context).openComplaints,
                                    '0',
                                    Icons.hourglass_empty,
                                    Colors.orange,
                                    isDark),
                                _buildStatCard(
                                    context,
                                    AppLocalizations.of(context)
                                        .closedComplaints,
                                    '0',
                                    Icons.check_circle,
                                    Colors.green,
                                    isDark),
                                _buildStatCard(
                                    context,
                                    AppLocalizations.of(context)
                                        .avgResolutionTime,
                                    AppLocalizations.of(context).daysUnit('0'),
                                    Icons.timer,
                                    AppColors.primary,
                                    isDark),
                              ],
                            ),
                            const SizedBox(height: AlhaiSpacing.lg),
                            // Filters
                            Wrap(
                              spacing: 12,
                              runSpacing: 12,
                              children: [
                                SizedBox(
                                    width: 180,
                                    child: TextField(
                                        decoration: InputDecoration(
                                            labelText:
                                                AppLocalizations.of(context)
                                                    .fromDate,
                                            prefixIcon: const Icon(
                                                Icons.calendar_today,
                                                size: 18),
                                            border: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(10)),
                                            isDense: true))),
                                SizedBox(
                                    width: 180,
                                    child: TextField(
                                        decoration: InputDecoration(
                                            labelText:
                                                AppLocalizations.of(context)
                                                    .toDate,
                                            prefixIcon: const Icon(
                                                Icons.calendar_today,
                                                size: 18),
                                            border: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(10)),
                                            isDense: true))),
                                SizedBox(
                                    width: 160,
                                    child: DropdownButtonFormField<String>(
                                        decoration: InputDecoration(
                                            labelText:
                                                AppLocalizations.of(context)
                                                    .statusFilter,
                                            border: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(10)),
                                            isDense: true),
                                        items: [
                                          DropdownMenuItem(
                                              value: 'all',
                                              child: Text(
                                                  AppLocalizations.of(context)
                                                      .allFilter)),
                                          DropdownMenuItem(
                                              value: 'open',
                                              child: Text(
                                                  AppLocalizations.of(context)
                                                      .openComplaints)),
                                          DropdownMenuItem(
                                              value: 'closed',
                                              child: Text(
                                                  AppLocalizations.of(context)
                                                      .closedComplaints))
                                        ],
                                        onChanged: (_) {})),
                                SizedBox(
                                    width: 160,
                                    child: DropdownButtonFormField<String>(
                                        decoration: InputDecoration(
                                            labelText:
                                                AppLocalizations.of(context)
                                                    .departmentFilter,
                                            border: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(10)),
                                            isDense: true),
                                        items: [
                                          DropdownMenuItem(
                                              value: 'all',
                                              child: Text(
                                                  AppLocalizations.of(context)
                                                      .allFilter)),
                                          DropdownMenuItem(
                                              value: 'payment',
                                              child: Text(
                                                  AppLocalizations.of(context)
                                                      .paymentDepartment)),
                                          DropdownMenuItem(
                                              value: 'technical',
                                              child: Text(
                                                  AppLocalizations.of(context)
                                                      .technicalDepartment)),
                                          DropdownMenuItem(
                                              value: 'other',
                                              child: Text(
                                                  AppLocalizations.of(context)
                                                      .otherDepartment))
                                        ],
                                        onChanged: (_) {})),
                              ],
                            ),
                            const SizedBox(height: AlhaiSpacing.lg),
                            // Empty state
                            Center(
                              child: Padding(
                                padding:
                                    const EdgeInsets.all(AlhaiSpacing.huge),
                                child: Column(
                                  children: [
                                    Icon(Icons.sentiment_satisfied_alt,
                                        size: 80,
                                        color: isDark
                                            ? Colors.white24
                                            : Theme.of(context)
                                                .colorScheme
                                                .onSurfaceVariant
                                                .withValues(alpha: 0.3)),
                                    const SizedBox(height: AlhaiSpacing.md),
                                    Text(AppLocalizations.of(context).noData,
                                        style: TextStyle(
                                            fontSize: 16,
                                            color: isDark
                                                ? Colors.white54
                                                : Theme.of(context)
                                                    .colorScheme
                                                    .onSurfaceVariant)),
                                    const SizedBox(height: AlhaiSpacing.xs),
                                    Text(
                                        AppLocalizations.of(context)
                                            .noComplaintsRecorded,
                                        style: TextStyle(
                                            fontSize: 13,
                                            color: isDark
                                                ? Colors.white38
                                                : Theme.of(context)
                                                    .colorScheme
                                                    .onSurfaceVariant
                                                    .withValues(alpha: 0.5))),
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

  Widget _buildStatCard(BuildContext context, String title, String value,
      IconData icon, Color color, bool isDark) {
    final theme = Theme.of(context);
    final screenWidth = context.screenWidth;
    final isMobile = context.isMobile;
    final cardWidth = isMobile ? (screenWidth - 36) / 2 : 180.0;
    return Container(
      width: cardWidth,
      padding: const EdgeInsets.all(AlhaiSpacing.md),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E2E) : theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isDark ? Colors.white12 : theme.dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: AlhaiSpacing.sm),
          Text(value,
              style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : theme.colorScheme.onSurface)),
          const SizedBox(height: AlhaiSpacing.xxs),
          Text(title,
              style: TextStyle(
                  fontSize: 13,
                  color: isDark
                      ? Colors.white54
                      : theme.colorScheme.onSurfaceVariant)),
        ],
      ),
    );
  }
}
