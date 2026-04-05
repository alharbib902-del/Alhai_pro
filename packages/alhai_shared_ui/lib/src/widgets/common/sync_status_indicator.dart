/// Sync Status Indicator - مؤشر حالة المزامنة
///
/// أيقونة صغيرة أنيقة تعرض حالة المزامنة في الهيدر
/// تدعم: متصل/مزامنة/غير متصل مع عدد العمليات المعلقة
library;

import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:alhai_design_system/alhai_design_system.dart'
    show AppColors, AlhaiColors, AlhaiDurations, AlhaiSpacing;
import 'package:alhai_l10n/alhai_l10n.dart';
import 'package:alhai_sync/alhai_sync.dart' show SyncStatus;

import '../../providers/sync_providers.dart';

/// مؤشر حالة المزامنة - أيقونة صغيرة للهيدر
class SyncStatusIndicator extends ConsumerWidget {
  const SyncStatusIndicator({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isOnlineAsync = ref.watch(isOnlineProvider);
    final pendingCountAsync = ref.watch(pendingSyncCountProvider);
    final syncStatusAsync = ref.watch(syncStatusProvider);

    // تفعيل مدير المزامنة
    ref.watch(syncManagerProvider);

    final isDark = Theme.of(context).brightness == Brightness.dark;

    // استخراج القيم مع defaults آمنة
    final isOnline = isOnlineAsync.valueOrNull ?? true;
    final pendingCount = pendingCountAsync.valueOrNull ?? 0;
    final syncStatus = syncStatusAsync.valueOrNull ?? SyncStatus.idle;

    return _SyncIndicatorButton(
      isOnline: isOnline,
      pendingCount: pendingCount,
      syncStatus: syncStatus,
      isDark: isDark,
    );
  }
}

/// الزر الداخلي مع الحالة والرسوم المتحركة
class _SyncIndicatorButton extends StatefulWidget {
  final bool isOnline;
  final int pendingCount;
  final SyncStatus syncStatus;
  final bool isDark;

  const _SyncIndicatorButton({
    required this.isOnline,
    required this.pendingCount,
    required this.syncStatus,
    required this.isDark,
  });

  @override
  State<_SyncIndicatorButton> createState() => _SyncIndicatorButtonState();
}

class _SyncIndicatorButtonState extends State<_SyncIndicatorButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _rotationController;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _updateAnimation();
  }

  @override
  void didUpdateWidget(covariant _SyncIndicatorButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.syncStatus != widget.syncStatus) {
      _updateAnimation();
    }
  }

  void _updateAnimation() {
    if (widget.syncStatus == SyncStatus.syncing) {
      _rotationController.repeat();
    } else {
      _rotationController.stop();
      _rotationController.reset();
    }
  }

  @override
  void dispose() {
    _rotationController.dispose();
    super.dispose();
  }

  /// تحديد الأيقونة واللون بناءً على الحالة
  ({IconData icon, Color color, String tooltip}) _resolveState() {
    final l10n = AppLocalizations.of(context);
    if (!widget.isOnline) {
      return (
        icon: Icons.cloud_off_rounded,
        color: AppColors.error,
        tooltip: widget.pendingCount > 0
            ? l10n.offlineWithPending(widget.pendingCount)
            : l10n.noInternetConnection,
      );
    }

    if (widget.syncStatus == SyncStatus.syncing) {
      return (
        icon: Icons.sync_rounded,
        color: AppColors.warning,
        tooltip: widget.pendingCount > 0
            ? l10n.syncingWithCount(widget.pendingCount)
            : l10n.syncing,
      );
    }

    if (widget.syncStatus == SyncStatus.error) {
      return (
        icon: Icons.sync_problem_rounded,
        color: AppColors.error,
        tooltip: widget.pendingCount > 0
            ? l10n.syncErrorWithCount(widget.pendingCount)
            : l10n.syncErrorMessage(''),
      );
    }

    if (widget.pendingCount > 0) {
      return (
        icon: Icons.cloud_upload_rounded,
        color: AppColors.warning,
        tooltip: l10n.pendingSyncWithCount(widget.pendingCount),
      );
    }

    return (
      icon: Icons.cloud_done_rounded,
      color: AlhaiColors.success,
      tooltip: l10n.connectedAllSynced,
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = _resolveState();
    final theme = Theme.of(context);

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: Tooltip(
        message: state.tooltip,
        preferBelow: true,
        waitDuration: const Duration(milliseconds: 400),
        textStyle: TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontFamily: theme.textTheme.bodyMedium?.fontFamily,
        ),
        decoration: BoxDecoration(
          color: widget.isDark
              ? AppColors.surfaceVariantDark
              : AppColors.surfaceDark,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: widget.isDark ? 0.3 : 0.15),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => _showSyncDetails(context, state),
            borderRadius: BorderRadius.circular(8),
            child: AnimatedContainer(
              duration: AlhaiDurations.fast,
              padding: const EdgeInsets.all(AlhaiSpacing.xs),
              decoration: BoxDecoration(
                color: _isHovered
                    ? (widget.isDark
                        ? Colors.white.withValues(alpha: 0.1)
                        : AppColors.backgroundSecondary)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  // الأيقونة (مع دوران عند المزامنة)
                  AnimatedBuilder(
                    animation: _rotationController,
                    builder: (BuildContext context, Widget? child) {
                      return Transform.rotate(
                        angle: widget.syncStatus == SyncStatus.syncing
                            ? _rotationController.value * 2 * math.pi
                            : 0,
                        child: child,
                      );
                    },
                    child: AnimatedSwitcher(
                      duration: AlhaiDurations.standard,
                      transitionBuilder: (child, animation) {
                        return FadeTransition(
                          opacity: animation,
                          child: ScaleTransition(
                            scale: animation,
                            child: child,
                          ),
                        );
                      },
                      child: Icon(
                        state.icon,
                        key: ValueKey(
                            '${state.icon.codePoint}_${state.color.value}'),
                        color: state.color,
                        size: 18,
                      ),
                    ),
                  ),

                  // بادج العدد
                  if (widget.pendingCount > 0)
                    PositionedDirectional(
                      top: -6,
                      end: -6,
                      child: AnimatedScale(
                        scale: 1.0,
                        duration: AlhaiDurations.standard,
                        curve: Curves.elasticOut,
                        child: Container(
                          constraints: const BoxConstraints(
                            minWidth: 16,
                            minHeight: 16,
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: AlhaiSpacing.xxs,
                            vertical: 1,
                          ),
                          decoration: BoxDecoration(
                            color: widget.isOnline
                                ? AppColors.warning
                                : AppColors.error,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: widget.isDark
                                  ? AppColors.backgroundDark
                                  : Colors.white,
                              width: 1.5,
                            ),
                          ),
                          child: Text(
                            widget.pendingCount > 99
                                ? '99+'
                                : widget.pendingCount.toString(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                              height: 1.2,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// عرض تفاصيل المزامنة عند النقر
  void _showSyncDetails(
    BuildContext context,
    ({IconData icon, Color color, String tooltip}) state,
  ) {
    final isDark = widget.isDark;

    showDialog(
      context: context,
      barrierColor: Colors.transparent,
      builder: (context) {
        // حساب موقع الحوار بالقرب من الأيقونة
        final renderBox = this.context.findRenderObject() as RenderBox?;
        final position = renderBox?.localToGlobal(Offset.zero);
        final size = renderBox?.size;
        final theme = Theme.of(context);

        return Stack(
          children: [
            // طبقة شفافة لإغلاق الحوار
            Positioned.fill(
              child: GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                behavior: HitTestBehavior.opaque,
                child: const SizedBox.expand(),
              ),
            ),
            // البطاقة
            Positioned(
              top: (position?.dy ?? 60) + (size?.height ?? 40) + 4,
              right: 16,
              child: Material(
                color: Colors.transparent,
                child: Container(
                  width: 260,
                  padding: const EdgeInsets.all(AlhaiSpacing.md),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.surfaceDark : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.1)
                          : AppColors.border,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black
                            .withValues(alpha: isDark ? 0.24 : 0.12),
                        blurRadius: 16,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // العنوان
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(AlhaiSpacing.xs),
                            decoration: BoxDecoration(
                              color: state.color.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              state.icon,
                              color: state.color,
                              size: 20,
                            ),
                          ),
                          SizedBox(width: AlhaiSpacing.sm),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _getStatusTitle(),
                                  style: TextStyle(
                                    color: theme.colorScheme.onSurface,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                SizedBox(height: AlhaiSpacing.xxxs),
                                Text(
                                  _getStatusDescription(),
                                  style: TextStyle(
                                    color: theme.colorScheme.onSurfaceVariant,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      // الفاصل
                      if (widget.pendingCount > 0) ...[
                        SizedBox(height: AlhaiSpacing.sm),
                        Divider(
                          height: 1,
                          color: isDark
                              ? Colors.white.withValues(alpha: 0.08)
                              : theme.dividerColor,
                        ),
                        SizedBox(height: AlhaiSpacing.sm),
                        // تفاصيل العمليات المعلقة
                        Row(
                          children: [
                            Icon(
                              Icons.pending_actions_rounded,
                              color: AppColors.getTextMuted(isDark),
                              size: 16,
                            ),
                            SizedBox(width: AlhaiSpacing.xs),
                            Text(
                              '${widget.pendingCount} عمليات في الانتظار',
                              style: TextStyle(
                                color: AppColors.getTextSecondary(isDark),
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  String _getStatusTitle() {
    final l10n = AppLocalizations.of(context);
    if (!widget.isOnline) return l10n.disconnectedLabel;
    if (widget.syncStatus == SyncStatus.syncing) return l10n.syncing;
    if (widget.syncStatus == SyncStatus.error) return l10n.syncErrorMessage('');
    if (widget.pendingCount > 0) return l10n.pendingSync;
    return l10n.connectedLabel;
  }

  String _getStatusDescription() {
    final l10n = AppLocalizations.of(context);
    if (!widget.isOnline) {
      return l10n.dataSavedLocally;
    }
    if (widget.syncStatus == SyncStatus.syncing) {
      return l10n.uploadingData;
    }
    if (widget.syncStatus == SyncStatus.error) {
      return l10n.errorWillRetry;
    }
    if (widget.pendingCount > 0) {
      return l10n.syncSoon;
    }
    return l10n.allDataSynced;
  }
}
