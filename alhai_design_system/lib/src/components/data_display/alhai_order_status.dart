import 'package:flutter/material.dart';

import '../../tokens/alhai_colors.dart';
import '../../tokens/alhai_order_status_tokens.dart';
import '../../tokens/alhai_radius.dart';
import '../../tokens/alhai_spacing.dart';

/// Re-export tokens for convenience
export '../../tokens/alhai_order_status_tokens.dart' 
    show AlhaiOrderStatus, AlhaiOrderStatusExtension;

/// AlhaiOrderStatusBadge - Compact inline badge for order status
/// 
/// Features:
/// - Status label with optional icon
/// - Color-coded by status tokens
/// - RTL-safe layout
/// - Dark mode support
class AlhaiOrderStatusBadge extends StatelessWidget {
  /// Current order status
  final AlhaiOrderStatus status;

  /// Label text for status
  final String label;

  /// Optional custom icon
  final IconData? icon;

  /// Show icon before label
  final bool showIcon;

  /// Whether the badge is enabled
  final bool enabled;

  /// Semantic label for accessibility
  final String? semanticsLabel;

  const AlhaiOrderStatusBadge({
    super.key,
    required this.status,
    required this.label,
    this.icon,
    this.showIcon = true,
    this.enabled = true,
    this.semanticsLabel,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textDirection = Directionality.of(context);
    final statusColors = AlhaiOrderStatusTokens.of(context);

    final backgroundColor = statusColors.backgroundFor(status);
    final foregroundColor = statusColors.foregroundFor(status);

    return Semantics(
      label: semanticsLabel ?? label,
      enabled: enabled,
      child: Opacity(
        opacity: enabled ? 1.0 : AlhaiColors.disabledOpacity,
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AlhaiSpacing.sm,
            vertical: AlhaiSpacing.xxs,
          ),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(AlhaiRadius.full),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            textDirection: textDirection,
            children: [
              if (showIcon) ...[
                Icon(
                  icon ?? status.defaultIcon,
                  size: AlhaiSpacing.md,
                  color: foregroundColor,
                ),
                const SizedBox(width: AlhaiSpacing.xxs),
              ],
              Text(
                label,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: foregroundColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// AlhaiOrderStatusTimeline - Vertical timeline for order progress
/// 
/// Features:
/// - Ordered steps based on status progression
/// - Current status highlighted
/// - Past/upcoming visual distinction
/// - RTL-safe layout
class AlhaiOrderStatusTimeline extends StatelessWidget {
  /// Current order status
  final AlhaiOrderStatus currentStatus;

  /// Labels for each status step (required)
  final Map<AlhaiOrderStatus, String> labels;

  /// Optional descriptions for each step
  final Map<AlhaiOrderStatus, String>? descriptions;

  /// Optional timestamps for each step
  final Map<AlhaiOrderStatus, String>? timestamps;

  /// Statuses to show in timeline (defaults to all except cancelled)
  final List<AlhaiOrderStatus>? steps;

  /// Show icons in timeline steps
  final bool showIcons;

  /// Semantic label for accessibility
  final String? semanticsLabel;

  const AlhaiOrderStatusTimeline({
    super.key,
    required this.currentStatus,
    required this.labels,
    this.descriptions,
    this.timestamps,
    this.steps,
    this.showIcons = true,
    this.semanticsLabel,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textDirection = Directionality.of(context);
    final statusColors = AlhaiOrderStatusTokens.of(context);

    // Default steps - sanitize based on currentStatus
    List<AlhaiOrderStatus> effectiveSteps;
    if (steps != null) {
      // Sanitize user-provided steps
      if (currentStatus == AlhaiOrderStatus.cancelled) {
        effectiveSteps = steps!.where((s) => s == AlhaiOrderStatus.cancelled).toList();
        if (effectiveSteps.isEmpty) {
          effectiveSteps = [AlhaiOrderStatus.cancelled];
        }
      } else {
        effectiveSteps = steps!.where((s) => s != AlhaiOrderStatus.cancelled).toList();
      }
    } else {
      effectiveSteps = currentStatus == AlhaiOrderStatus.cancelled
          ? [AlhaiOrderStatus.cancelled]
          : [
              AlhaiOrderStatus.created,
              AlhaiOrderStatus.confirmed,
              AlhaiOrderStatus.preparing,
              AlhaiOrderStatus.outForDelivery,
              AlhaiOrderStatus.delivered,
            ];
    }

    // Ensure currentStatus is in effectiveSteps for proper semantics
    if (!effectiveSteps.contains(currentStatus)) {
      effectiveSteps = [...effectiveSteps, currentStatus];
    }

    final currentIndex = currentStatus.progressIndex;

    // Debug assert: ensure all steps have labels
    assert(() {
      for (final s in effectiveSteps) {
        if (!labels.containsKey(s) || (labels[s]?.isEmpty ?? true)) {
          throw FlutterError(
            'AlhaiOrderStatusTimeline: labels must include a non-empty value for status: $s',
          );
        }
      }
      return true;
    }());

    return Semantics(
      label: semanticsLabel ?? labels[currentStatus],
      container: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          for (int i = 0; i < effectiveSteps.length; i++)
            _TimelineStep(
              status: effectiveSteps[i],
              label: labels[effectiveSteps[i]]!,
              description: descriptions?[effectiveSteps[i]],
              timestamp: timestamps?[effectiveSteps[i]],
              isCompleted: effectiveSteps[i].progressIndex >= 0 &&
                  effectiveSteps[i].progressIndex < currentIndex,
              isCurrent: effectiveSteps[i] == currentStatus,
              isLast: i == effectiveSteps.length - 1,
              showIcon: showIcons,
              theme: theme,
              statusColors: statusColors,
              textDirection: textDirection,
            ),
        ],
      ),
    );
  }
}

/// Internal timeline step widget
class _TimelineStep extends StatelessWidget {
  final AlhaiOrderStatus status;
  final String label;
  final String? description;
  final String? timestamp;
  final bool isCompleted;
  final bool isCurrent;
  final bool isLast;
  final bool showIcon;
  final ThemeData theme;
  final AlhaiOrderStatusColors statusColors;
  final TextDirection textDirection;

  const _TimelineStep({
    required this.status,
    required this.label,
    required this.description,
    required this.timestamp,
    required this.isCompleted,
    required this.isCurrent,
    required this.isLast,
    required this.showIcon,
    required this.theme,
    required this.statusColors,
    required this.textDirection,
  });

  @override
  Widget build(BuildContext context) {
    final bool isActive = isCompleted || isCurrent;
    final Color dotColor = _getDotColor();
    final Color lineColor = isCompleted
        ? statusColors.activeIndicator
        : statusColors.inactiveIndicator;

    return IntrinsicHeight(
      child: Row(
        textDirection: textDirection,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Timeline indicator
          SizedBox(
            width: AlhaiSpacing.xl,
            child: Column(
              children: [
                // Dot
                Container(
                  width: isCurrent ? AlhaiSpacing.lg : AlhaiSpacing.md,
                  height: isCurrent ? AlhaiSpacing.lg : AlhaiSpacing.md,
                  decoration: BoxDecoration(
                    color: (isCurrent || isCompleted) ? dotColor : null,
                    border: (isCurrent || isCompleted)
                        ? null
                        : Border.all(
                            color: dotColor,
                            width: AlhaiSpacing.xxxs,
                          ),
                    shape: BoxShape.circle,
                  ),
                  child: showIcon && (isCompleted || isCurrent)
                      ? Icon(
                          isCompleted ? Icons.check_rounded : status.defaultIcon,
                          size: AlhaiSpacing.sm,
                          color: statusColors.activeOnIndicator,
                        )
                      : null,
                ),

                // Line
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: AlhaiSpacing.xxxs,
                      margin: const EdgeInsets.symmetric(
                        vertical: AlhaiSpacing.xxs,
                      ),
                      color: lineColor,
                    ),
                  ),
              ],
            ),
          ),

          const SizedBox(width: AlhaiSpacing.sm),

          // Content
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(
                bottom: isLast ? 0 : AlhaiSpacing.md,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Label
                  Text(
                    label,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: isActive
                          ? statusColors.textActive
                          : statusColors.textInactive,
                      fontWeight: isCurrent ? FontWeight.w600 : null,
                    ),
                    textDirection: textDirection,
                  ),

                  // Description
                  if (description != null) ...[
                    const SizedBox(height: AlhaiSpacing.xxxs),
                    Text(
                      description!,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: statusColors.textMeta,
                      ),
                      textDirection: textDirection,
                    ),
                  ],

                  // Timestamp
                  if (timestamp != null && isActive) ...[
                    const SizedBox(height: AlhaiSpacing.xxxs),
                    Text(
                      timestamp!,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: statusColors.textMeta,
                      ),
                      textDirection: textDirection,
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getDotColor() {
    if (status == AlhaiOrderStatus.cancelled) {
      return statusColors.cancelledForeground;
    }
    if (isCompleted || isCurrent) {
      return statusColors.activeIndicator;
    }
    return statusColors.inactiveIndicator;
  }
}
