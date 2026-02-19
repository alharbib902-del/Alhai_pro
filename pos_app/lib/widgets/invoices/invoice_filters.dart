/// Invoice Filters & Tabs Widget
library;

import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../l10n/generated/app_localizations.dart';

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
    final isWide = MediaQuery.of(context).size.width > 600;

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
                    color: isDark ? const Color(0xFF1E293B) : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: isDark ? Colors.white.withValues(alpha: 0.1) : AppColors.border),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: 'all',
                      isExpanded: true,
                      icon: Icon(Icons.keyboard_arrow_down, color: isDark ? AppColors.textMutedDark : AppColors.textMuted),
                      style: TextStyle(fontSize: 14, color: isDark ? Colors.white : AppColors.textPrimary),
                      dropdownColor: isDark ? const Color(0xFF1E293B) : Colors.white,
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
                  foregroundColor: isDark ? Colors.white : AppColors.textPrimary,
                  side: BorderSide(color: isDark ? Colors.white.withValues(alpha: 0.1) : AppColors.border),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
                child: Text(l10n.resetFilters),
              ),
              const Spacer(),
              // View toggle
              Container(
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E293B) : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: isDark ? Colors.white.withValues(alpha: 0.1) : AppColors.border),
                ),
                child: Row(
                  children: [
                    _viewToggleBtn(Icons.list, !isGridView, isDark),
                    _viewToggleBtn(Icons.grid_view, isGridView, isDark),
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
          duration: const Duration(milliseconds: 200),
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

  Widget _viewToggleBtn(IconData icon, bool isActive, bool isDark) {
    return InkWell(
      onTap: onViewToggle,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isActive ? (isDark ? const Color(0xFF0F172A) : AppColors.backgroundSecondary) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          boxShadow: isActive ? [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 4)] : null,
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
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isDark ? Colors.white.withValues(alpha: 0.1) : AppColors.border),
      ),
      child: Row(
        children: [
          Icon(Icons.calendar_today, size: 14, color: isDark ? AppColors.textMutedDark : AppColors.textMuted),
          const SizedBox(width: 8),
          Text('2026-02-09', style: TextStyle(fontSize: 13, color: isDark ? Colors.white : AppColors.textPrimary)),
        ],
      ),
    );
  }
}
