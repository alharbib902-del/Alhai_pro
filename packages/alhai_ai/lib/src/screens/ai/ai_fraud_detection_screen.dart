/// شاشة كشف الاحتيال بالذكاء الاصطناعي - AI Fraud Detection Screen
///
/// لوحة تحكم لكشف الاحتيال مع مقياس المخاطر وقائمة التنبيهات
/// ودرجات السلوك ولوحة التحقيق
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:alhai_shared_ui/alhai_shared_ui.dart';
import '../../widgets/ai/fraud_alert_card.dart';
import '../../widgets/ai/behavior_score_widget.dart';
import '../../widgets/ai/fraud_investigation_panel.dart';
import '../../providers/ai_fraud_detection_providers.dart';
import '../../services/ai_fraud_detection_service.dart';
import 'package:alhai_l10n/alhai_l10n.dart';
import 'dart:math' as math;
import 'package:alhai_design_system/alhai_design_system.dart';

class AiFraudDetectionScreen extends ConsumerStatefulWidget {
  const AiFraudDetectionScreen({super.key});

  @override
  ConsumerState<AiFraudDetectionScreen> createState() =>
      _AiFraudDetectionScreenState();
}

class _AiFraudDetectionScreenState extends ConsumerState<AiFraudDetectionScreen>
    with SingleTickerProviderStateMixin {
  FraudAlert? _selectedAlert;
  Investigation? _selectedInvestigation;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _selectAlert(FraudAlert alert) async {
    final service = ref.read(aiFraudDetectionServiceProvider);
    final investigation = await service.getInvestigation(alert.id);
    setState(() {
      _selectedAlert = alert;
      _selectedInvestigation = investigation;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isWideScreen = context.isDesktop;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context);

    return Column(
      children: [
        AppHeader(
          title: l10n.aiFraudDetection,
          onMenuTap:
              !isWideScreen ? () => Scaffold.of(context).openDrawer() : null,
        ),
        Expanded(
          child: _buildContent(isDark, isWideScreen),
        ),
      ],
    );
  }

  Widget _buildContent(bool isDark, bool isWideScreen) {
    final l10n = AppLocalizations.of(context);
    final alertsAsync = ref.watch(fraudAlertsProvider);
    final scoresAsync = ref.watch(behaviorScoresProvider);
    final summaryAsync = ref.watch(fraudSummaryProvider);

    return alertsAsync.when(
      loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.primary)),
      error: (e, _) => Center(
          child: Text(
              AppLocalizations.of(context).aiErrorWithMessage(e.toString()))),
      data: (alerts) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(AlhaiSpacing.mdl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Summary cards row
              summaryAsync.when(
                data: (summary) =>
                    _buildSummaryCards(isDark, summary, isWideScreen),
                loading: () => const SizedBox.shrink(),
                error: (_, __) => const SizedBox.shrink(),
              ),

              const SizedBox(height: AlhaiSpacing.lg),

              // Risk meter
              summaryAsync.when(
                data: (summary) => _buildRiskMeter(isDark, summary),
                loading: () => const SizedBox.shrink(),
                error: (_, __) => const SizedBox.shrink(),
              ),

              const SizedBox(height: AlhaiSpacing.lg),

              // Tabs
              Container(
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E293B) : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.1)
                        : AppColors.border,
                  ),
                ),
                child: TabBar(
                  controller: _tabController,
                  labelColor: AppColors.primary,
                  unselectedLabelColor: isDark
                      ? Colors.white.withValues(alpha: 0.5)
                      : AppColors.textSecondary,
                  indicatorColor: AppColors.primary,
                  indicatorSize: TabBarIndicatorSize.label,
                  dividerColor: Colors.transparent,
                  tabs: [
                    Tab(text: l10n.aiAlertsWithCount(alerts.length)),
                    Tab(text: l10n.aiBehaviorScores),
                    Tab(text: l10n.aiInvestigation),
                  ],
                ),
              ),

              const SizedBox(height: AlhaiSpacing.md),

              // Tab content
              SizedBox(
                height: isWideScreen ? 600 : 500,
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildAlertsTab(isDark, alerts),
                    scoresAsync.when(
                      data: (scores) =>
                          _buildBehaviorTab(isDark, scores, isWideScreen),
                      loading: () =>
                          const Center(child: CircularProgressIndicator()),
                      error: (e, _) => Center(child: Text('$e')),
                    ),
                    _buildInvestigationTab(isDark),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSummaryCards(
      bool isDark, FraudDetectionSummary summary, bool isWideScreen) {
    final l10n = AppLocalizations.of(context);
    final cards = [
      _SummaryCardData(
        title: l10n.aiTotalAlerts,
        value: '${summary.totalAlerts}',
        icon: Icons.warning_amber_rounded,
        color: AppColors.warning,
      ),
      _SummaryCardData(
        title: l10n.aiCriticalAlerts,
        value: '${summary.criticalAlerts}',
        icon: Icons.error_rounded,
        color: AppColors.error,
      ),
      _SummaryCardData(
        title: l10n.aiNeedsReview,
        value: '${summary.unreviewedAlerts}',
        icon: Icons.visibility_rounded,
        color: AppColors.info,
      ),
      _SummaryCardData(
        title: l10n.aiRiskLevel,
        value: '${summary.overallRiskScore.toInt()}%',
        icon: Icons.shield_rounded,
        color:
            summary.overallRiskScore > 60 ? AppColors.error : AppColors.success,
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        return Wrap(
          spacing: 16,
          runSpacing: 16,
          children: cards.map((card) {
            return SizedBox(
              width: isWideScreen
                  ? constraints.maxWidth / 4 - 16
                  : double.infinity,
              child: Container(
                padding: const EdgeInsets.all(AlhaiSpacing.md),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E293B) : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.1)
                        : AppColors.border,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color:
                          Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: card.color.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(card.icon, color: card.color, size: 22),
                    ),
                    const SizedBox(width: AlhaiSpacing.sm),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            card.title,
                            style: TextStyle(
                              color: isDark
                                  ? Colors.white.withValues(alpha: 0.6)
                                  : AppColors.textSecondary,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: AlhaiSpacing.xxs),
                          Text(
                            card.value,
                            style: TextStyle(
                              color:
                                  isDark ? Colors.white : AppColors.textPrimary,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }

  Widget _buildRiskMeter(bool isDark, FraudDetectionSummary summary) {
    final l10n = AppLocalizations.of(context);
    return Container(
      padding: const EdgeInsets.all(AlhaiSpacing.mdl),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color:
              isDark ? Colors.white.withValues(alpha: 0.1) : AppColors.border,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.speed_rounded,
                  color: AppColors.primary, size: 22),
              const SizedBox(width: AlhaiSpacing.xs),
              Text(
                l10n.aiRiskMeter,
                style: TextStyle(
                  color: isDark ? Colors.white : AppColors.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: AlhaiSpacing.mdl),
          Center(
            child: SizedBox(
              width: 200,
              height: 120,
              child: CustomPaint(
                painter: _RiskMeterPainter(
                  value: summary.overallRiskScore / 100,
                  isDark: isDark,
                ),
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '${summary.overallRiskScore.toInt()}',
                        style: TextStyle(
                          color: isDark ? Colors.white : AppColors.textPrimary,
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        summary.overallRiskScore > 60
                            ? l10n.aiHighRisk
                            : l10n.aiLowRisk,
                        style: TextStyle(
                          color: summary.overallRiskScore > 60
                              ? AppColors.error
                              : AppColors.success,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: AlhaiSpacing.md),
          // Pattern breakdown
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: summary.patternCounts.entries.map((entry) {
              return Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.05)
                      : AppColors.grey50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${_patternName(entry.key)}: ${entry.value}',
                  style: TextStyle(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.7)
                        : AppColors.textSecondary,
                    fontSize: 11,
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  String _patternName(FraudPattern pattern) {
    final l10n = AppLocalizations.of(context);
    switch (pattern) {
      case FraudPattern.unusualRefund:
        return l10n.aiPatternRefund;
      case FraudPattern.afterHoursTransaction:
        return l10n.aiPatternAfterHours;
      case FraudPattern.repeatedVoid:
        return l10n.aiPatternVoid;
      case FraudPattern.largeDiscount:
        return l10n.aiPatternDiscount;
      case FraudPattern.splitTransaction:
        return l10n.aiPatternSplit;
      case FraudPattern.cashDrawerAnomaly:
        return l10n.aiPatternCashDrawer;
    }
  }

  Widget _buildAlertsTab(bool isDark, List<FraudAlert> alerts) {
    if (alerts.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check_circle_outline_rounded,
                size: 64, color: AppColors.success),
            const SizedBox(height: AlhaiSpacing.md),
            Text(
              AppLocalizations.of(context).aiNoFraudAlerts,
              style: TextStyle(
                color: isDark ? Colors.white : AppColors.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(AlhaiSpacing.xxs),
      itemCount: alerts.length,
      separatorBuilder: (_, __) => const SizedBox(height: AlhaiSpacing.sm),
      itemBuilder: (context, index) {
        final alert = alerts[index];
        return FraudAlertCard(
          alert: alert,
          isSelected: _selectedAlert?.id == alert.id,
          onTap: () => _selectAlert(alert),
          onReview: () {
            _selectAlert(alert);
            _tabController.animateTo(2);
          },
        );
      },
    );
  }

  Widget _buildBehaviorTab(
      bool isDark, List<BehaviorScore> scores, bool isWideScreen) {
    if (isWideScreen) {
      return GridView.builder(
        padding: const EdgeInsets.all(AlhaiSpacing.xxs),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount:
              getResponsiveGridColumns(context, mobile: 2, desktop: 4),
          childAspectRatio: 0.75,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        itemCount: scores.length,
        itemBuilder: (context, index) {
          return BehaviorScoreWidget(score: scores[index]);
        },
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(AlhaiSpacing.xxs),
      itemCount: scores.length,
      separatorBuilder: (_, __) => const SizedBox(height: AlhaiSpacing.sm),
      itemBuilder: (context, index) {
        return BehaviorScoreWidget(
          score: scores[index],
          compact: true,
        );
      },
    );
  }

  Widget _buildInvestigationTab(bool isDark) {
    if (_selectedAlert == null || _selectedInvestigation == null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.touch_app_rounded,
              size: 64,
              color: isDark
                  ? Colors.white.withValues(alpha: 0.3)
                  : AppColors.textMuted,
            ),
            const SizedBox(height: AlhaiSpacing.md),
            Text(
              AppLocalizations.of(context).aiSelectAlertToInvestigate,
              style: TextStyle(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.5)
                    : AppColors.textSecondary,
                fontSize: 14,
              ),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AlhaiSpacing.xxs),
      child: FraudInvestigationPanel(
        alert: _selectedAlert!,
        investigation: _selectedInvestigation!,
        onStatusChanged: (status) {
          // Handle status change
        },
        onNoteAdded: (note) {
          // Handle note added
        },
      ),
    );
  }
}

/// بيانات بطاقة الملخص - Summary Card Data
class _SummaryCardData {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _SummaryCardData({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });
}

/// رسام مقياس المخاطر - Risk Meter Painter
class _RiskMeterPainter extends CustomPainter {
  final double value; // 0.0 - 1.0
  final bool isDark;

  _RiskMeterPainter({required this.value, required this.isDark});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height);
    final radius = size.width / 2 - 10;

    // Background arc
    final bgPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 12
      ..strokeCap = StrokeCap.round
      ..color = isDark
          ? Colors.white.withValues(alpha: 0.1)
          : const Color(0xFFE5E7EB);

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      math.pi,
      math.pi,
      false,
      bgPaint,
    );

    // Color gradient segments
    final colors = [
      const Color(0xFF22C55E), // Green
      const Color(0xFFF59E0B), // Yellow
      const Color(0xFFEF4444), // Red
    ];

    final progressPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 12
      ..strokeCap = StrokeCap.round
      ..shader = SweepGradient(
        startAngle: math.pi,
        endAngle: 2 * math.pi,
        colors: colors,
      ).createShader(Rect.fromCircle(center: center, radius: radius));

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      math.pi,
      math.pi * value,
      false,
      progressPaint,
    );

    // Needle
    final needleAngle = math.pi + (math.pi * value);
    final needleEnd = Offset(
      center.dx + radius * 0.7 * math.cos(needleAngle),
      center.dy + radius * 0.7 * math.sin(needleAngle),
    );

    final needlePaint = Paint()
      ..color = isDark ? Colors.white : const Color(0xFF374151)
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(center, needleEnd, needlePaint);

    // Center dot
    final dotPaint = Paint()
      ..color = isDark ? Colors.white : const Color(0xFF374151);
    canvas.drawCircle(center, 5, dotPaint);
  }

  @override
  bool shouldRepaint(covariant _RiskMeterPainter oldDelegate) {
    return oldDelegate.value != value || oldDelegate.isDark != isDark;
  }
}
