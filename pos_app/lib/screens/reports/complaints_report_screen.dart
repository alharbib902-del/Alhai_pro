import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../l10n/generated/app_localizations.dart';

class ComplaintsReportScreen extends ConsumerStatefulWidget {
  const ComplaintsReportScreen({super.key});

  @override
  ConsumerState<ComplaintsReportScreen> createState() => _ComplaintsReportScreenState();
}

class _ComplaintsReportScreenState extends ConsumerState<ComplaintsReportScreen> {
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
    final size = MediaQuery.of(context).size;
    final isWide = size.width >= 1200;
    final isMobile = size.width < 600;
    final padding = isMobile ? 12.0 : isWide ? 24.0 : 16.0;

    return Scaffold(
      body: Column(
        children: [
          Container(
            padding: EdgeInsets.all(padding),
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
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _error != null
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(32),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.error_outline_rounded, size: 64, color: isDark ? Colors.white38 : Colors.grey),
                              const SizedBox(height: 16),
                              Text(
                                AppLocalizations.of(context)!.errorLoadingComplaints,
                                style: TextStyle(fontSize: 16, color: isDark ? Colors.white70 : Colors.grey.shade700),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 16),
                              FilledButton.icon(
                                onPressed: _loadData,
                                icon: const Icon(Icons.refresh_rounded),
                                label: Text(AppLocalizations.of(context)!.retry),
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
                              spacing: 12, runSpacing: 12,
                              children: [
                                _buildStatCard(context, AppLocalizations.of(context)!.totalComplaintsLabel, '0', Icons.list_alt, Colors.blue, isDark),
                                _buildStatCard(context, AppLocalizations.of(context)!.openComplaints, '0', Icons.hourglass_empty, Colors.orange, isDark),
                                _buildStatCard(context, AppLocalizations.of(context)!.closedComplaints, '0', Icons.check_circle, Colors.green, isDark),
                                _buildStatCard(context, AppLocalizations.of(context)!.avgResolutionTime, AppLocalizations.of(context)!.daysUnit('0'), Icons.timer, AppColors.primary, isDark),
                              ],
                            ),
                            const SizedBox(height: 24),
                            // Filters
                            Wrap(
                              spacing: 12, runSpacing: 12,
                              children: [
                                SizedBox(width: 180, child: TextField(decoration: InputDecoration(labelText: AppLocalizations.of(context)!.fromDate, prefixIcon: const Icon(Icons.calendar_today, size: 18), border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)), isDense: true))),
                                SizedBox(width: 180, child: TextField(decoration: InputDecoration(labelText: AppLocalizations.of(context)!.toDate, prefixIcon: const Icon(Icons.calendar_today, size: 18), border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)), isDense: true))),
                                SizedBox(width: 160, child: DropdownButtonFormField<String>(decoration: InputDecoration(labelText: AppLocalizations.of(context)!.statusFilter, border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)), isDense: true), items: [DropdownMenuItem(value: 'all', child: Text(AppLocalizations.of(context)!.allFilter)), DropdownMenuItem(value: 'open', child: Text(AppLocalizations.of(context)!.openComplaints)), DropdownMenuItem(value: 'closed', child: Text(AppLocalizations.of(context)!.closedComplaints))], onChanged: (_) {})),
                                SizedBox(width: 160, child: DropdownButtonFormField<String>(decoration: InputDecoration(labelText: AppLocalizations.of(context)!.departmentFilter, border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)), isDense: true), items: [DropdownMenuItem(value: 'all', child: Text(AppLocalizations.of(context)!.allFilter)), DropdownMenuItem(value: 'payment', child: Text(AppLocalizations.of(context)!.paymentDepartment)), DropdownMenuItem(value: 'technical', child: Text(AppLocalizations.of(context)!.technicalDepartment)), DropdownMenuItem(value: 'other', child: Text(AppLocalizations.of(context)!.otherDepartment))], onChanged: (_) {})),
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
                                    Text(AppLocalizations.of(context)!.noComplaintsRecorded, style: TextStyle(fontSize: 13, color: isDark ? Colors.white38 : Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.5))),
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
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;
    final cardWidth = isMobile ? (screenWidth - 36) / 2 : 180.0;
    return Container(
      width: cardWidth,
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
