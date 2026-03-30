/// Invoice Filters & Tabs Widget
library;

import 'package:flutter/material.dart';
import 'package:alhai_design_system/alhai_design_system.dart';
import 'package:alhai_l10n/alhai_l10n.dart';
import '../../core/theme/app_sizes.dart';

class InvoiceFilters extends StatelessWidget {
  final String activeTab;
  final ValueChanged<String> onTabChanged;
  final bool isGridView;
  final VoidCallback onViewToggle;
  final VoidCallback onReset;

  const InvoiceFilters({
    super.key,
    required this.activeTab,
    required this.onTabChanged,
    required this.isGridView,
    required this.onViewToggle,
    required this.onReset,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;
    final isWide = !context.isMobile;

    return Column(
      children: [
        // Filter row
        if (isWide)
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Theme.of(context).dividerColor),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: 'all',
                      isExpanded: true,
                      icon: Icon(Icons.keyboard_arrow_down, color: isDark ? AppColors.textMutedDark : AppColors.textMuted),
                      style: TextStyle(fontSize: 14, color: Theme.of(context).colorScheme.onSurface),
                      dropdownColor: Theme.of(context).colorScheme.surface,
                      items: [
                        DropdownMenuItem(value: 'all', child: Row(children: [Icon(Icons.filter_list, size: 16, color: isDark ? AppColors.textMutedDark : AppColors.textMuted), const SizedBox(width: 8), Text(l10n.statusAll)])),
                        DropdownMenuItem(value: 'paid', child: Text(l10n.statusPaid)),
                        DropdownMenuItem(value: 'pending', child: Text(l10n.statusPending)),
                      ],
                      onChanged: (v) {},
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Date range inputs
              _dateInput(context, isDark),
              const SizedBox(width: 8),
              _dateInput(context, isDark),
              const SizedBox(width: 12),
              OutlinedButton(
                onPressed: onReset,
                style: OutlinedButton.styleFrom(
                  foregroundColor: Theme.of(context).colorScheme.onSurface,
                  side: BorderSide(color: Theme.of(context).dividerColor),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
                child: Text(l10n.resetFilters),
              ),
              const Spacer(),
              // View toggle
              Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Theme.of(context).dividerColor),
                ),
                child: Row(
                  children: [
                    _viewToggleBtn(Icons.list, !isGridView, isDark, context: context),
                    _viewToggleBtn(Icons.grid_view, isGridView, isDark, context: context),
                  ],
                ),
              ),
            ],
          ),

        const SizedBox(height: 12),

        // Tabs
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _tabBtn(l10n.all, 'all', isDark),
              const SizedBox(width: 4),
              _tabBtn(l10n.statusPaid, 'paid', isDark),
              const SizedBox(width: 4),
              _tabBtn(l10n.statusPending, 'pending', isDark),
              const SizedBox(width: 4),
              _tabBtn(l10n.statusOverdue, 'overdue', isDark),
              const SizedBox(width: 4),
              _tabBtn(l10n.statusCancelled, 'cancelled', isDark),
            ],
          ),
        ),
      ],
    );
  }

  Widget _tabBtn(String label, String tab, bool isDark) {
    final isActive = activeTab == tab;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => onTabChanged(tab),
        borderRadius: BorderRadius.circular(12),
        child: AnimatedContainer(
          duration: AlhaiDurations.standard,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          decoration: BoxDecoration(
            color: isActive ? AppColors.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            boxShadow: isActive ? [BoxShadow(color: AppColors.primary.withValues(alpha: 0.2), blurRadius: 8, offset: const Offset(0, 2))] : null,
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
              color: isActive ? Colors.white : (isDark ? AppColors.textMutedDark : AppColors.textMuted),
            ),
          ),
        ),
      ),
    );
  }

  Widget _viewToggleBtn(IconData icon, bool isActive, bool isDark, {required BuildContext context}) {
    return InkWell(
      onTap: onViewToggle,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isActive ? (isDark ? AppColors.backgroundDark : AppColors.backgroundSecondary) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          boxShadow: isActive ? AppShadows.of(context, size: ShadowSize.sm) : null,
        ),
        child: Icon(icon, size: 18, color: isActive ? AppColors.primary : (isDark ? AppColors.textMutedDark : AppColors.textMuted)),
      ),
    );
  }

  Widget _dateInput(BuildContext context, bool isDark) {
    return Container(
      width: 140,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Row(
        children: [
          Icon(Icons.calendar_today, size: 14, color: isDark ? AppColors.textMutedDark : AppColors.textMuted),
          const SizedBox(width: 8),
          Text('2026-02-09', style: TextStyle(fontSize: 13, color: Theme.of(context).colorScheme.onSurface)),
        ],
      ),
    );
  }
}
