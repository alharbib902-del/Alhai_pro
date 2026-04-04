/// Shared Widgets for Distributor Portal
///
/// Reusable UI components: StatusBadge, SectionCard, StatCard,
/// EmptyStateWidget, ErrorStateWidget, LoadingWidget,
/// and responsive helpers.
library;

import 'package:flutter/material.dart';
import 'package:alhai_design_system/alhai_design_system.dart';

// =============================================================================
// Responsive Helpers
// =============================================================================

/// Returns responsive padding based on screen width.
/// Mobile (<600): md (16), Tablet (600-904): lg (24), Desktop (>904): xl (32).
double responsivePadding(double width) {
  if (width < AlhaiBreakpoints.tablet) return AlhaiSpacing.md;
  if (width < AlhaiBreakpoints.desktop) return AlhaiSpacing.lg;
  return AlhaiSpacing.xl;
}

/// Returns responsive font size for screen headers.
/// Desktop: 24, Mobile/Tablet: 20.
double responsiveHeaderFontSize(double width) {
  return width >= AlhaiBreakpoints.desktop ? 24.0 : 20.0;
}

/// Returns responsive font size for section headers.
/// Desktop: 18, Mobile/Tablet: 16.
double responsiveSectionFontSize(double width) {
  return width >= AlhaiBreakpoints.desktop ? 18.0 : 16.0;
}

/// Max content width for ultra-wide monitors.
const double kMaxContentWidth = 1400.0;

// =============================================================================
// StatusBadge - Theme-aware order status chip
// =============================================================================

/// A pill-shaped badge that shows order status with theme-aware colors.
class StatusBadge extends StatelessWidget {
  final String status;
  final String label;
  final bool isDark;

  const StatusBadge({
    super.key,
    required this.status,
    required this.label,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final color = AppColors.getStatusColor(status, isDark);
    final bg = AppColors.getStatusBackground(status, isDark);

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AlhaiSpacing.xs,
        vertical: AlhaiSpacing.xxs,
      ),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AlhaiRadius.sm),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}

// =============================================================================
// SectionCard - Card with header icon + title
// =============================================================================

/// A container card with an icon+title header row, used across settings,
/// pricing, reports, etc.
class SectionCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final bool isDark;
  final List<Widget> children;
  final Widget? trailing;

  const SectionCard({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.isDark,
    required this.children,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AlhaiSpacing.mdl),
      decoration: BoxDecoration(
        color: AppColors.getSurface(isDark),
        borderRadius: BorderRadius.circular(AlhaiRadius.lg),
        border: Border.all(color: AppColors.getBorder(isDark)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AlhaiSpacing.xs),
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: isDark ? 0.2 : 0.1),
                  borderRadius: BorderRadius.circular(AlhaiRadius.sm + 2),
                ),
                child: Icon(icon, color: iconColor, size: 20),
              ),
              const SizedBox(width: AlhaiSpacing.sm),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.getTextPrimary(isDark),
                  ),
                ),
              ),
              if (trailing != null) trailing!,
            ],
          ),
          const SizedBox(height: AlhaiSpacing.mdl),
          ...children,
        ],
      ),
    );
  }
}

// =============================================================================
// StatCard - Summary stat card (icon, label, value)
// =============================================================================

/// A compact summary card showing an icon, label, and value.
class StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final String? subtitle;
  final Color color;
  final bool isDark;

  const StatCard({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    this.subtitle,
    required this.color,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AlhaiSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.getSurface(isDark),
        borderRadius: BorderRadius.circular(AlhaiRadius.lg),
        border: Border.all(color: AppColors.getBorder(isDark)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AlhaiSpacing.xs),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: isDark ? 0.2 : 0.1),
                  borderRadius: BorderRadius.circular(AlhaiRadius.sm + 2),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const Spacer(),
              if (subtitle != null && subtitle!.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AlhaiSpacing.xs,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.success.withValues(
                      alpha: isDark ? 0.2 : 0.1,
                    ),
                    borderRadius: BorderRadius.circular(AlhaiRadius.sm - 2),
                  ),
                  child: Text(
                    subtitle!,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppColors.success,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: AlhaiSpacing.sm),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: AppColors.getTextSecondary(isDark),
            ),
          ),
          const SizedBox(height: AlhaiSpacing.xxs),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.getTextPrimary(isDark),
            ),
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// EmptyStateWidget
// =============================================================================

/// A centered empty-state view with icon, message, and optional action button.
class EmptyStateWidget extends StatelessWidget {
  final IconData icon;
  final String message;
  final String? subtitle;
  final VoidCallback? onAction;
  final String? actionLabel;
  final bool isDark;

  const EmptyStateWidget({
    super.key,
    required this.icon,
    required this.message,
    required this.isDark,
    this.subtitle,
    this.onAction,
    this.actionLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 64, color: AppColors.getTextMuted(isDark)),
          const SizedBox(height: AlhaiSpacing.md),
          Text(
            message,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.getTextSecondary(isDark),
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: AlhaiSpacing.xs),
            Text(
              subtitle!,
              style: TextStyle(
                fontSize: 14,
                color: AppColors.getTextMuted(isDark),
              ),
            ),
          ],
          if (onAction != null && actionLabel != null) ...[
            const SizedBox(height: AlhaiSpacing.md),
            FilledButton.icon(
              onPressed: onAction,
              icon: const Icon(Icons.refresh, size: 18),
              label: Text(actionLabel!),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.textOnPrimary,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// =============================================================================
// ErrorStateWidget
// =============================================================================

/// A centered error view with icon, message, and retry button.
class ErrorStateWidget extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  final String retryLabel;
  final bool isDark;

  const ErrorStateWidget({
    super.key,
    required this.message,
    required this.onRetry,
    required this.isDark,
    this.retryLabel = 'Retry',
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: AlhaiSpacing.iconLg,
            color: AppColors.getTextMuted(isDark),
          ),
          const SizedBox(height: AlhaiSpacing.md),
          Text(
            message,
            style: TextStyle(
              fontSize: 16,
              color: AppColors.getTextSecondary(isDark),
            ),
          ),
          const SizedBox(height: AlhaiSpacing.md),
          FilledButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh, size: 18),
            label: Text(retryLabel),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.textOnPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// LoadingWidget
// =============================================================================

/// A centered loading indicator.
class LoadingWidget extends StatelessWidget {
  const LoadingWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(child: CircularProgressIndicator());
  }
}
