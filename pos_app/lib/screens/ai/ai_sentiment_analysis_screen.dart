/// شاشة تحليل المشاعر - AI Sentiment Analysis Screen
///
/// مقياس في الأعلى، سحابة كلمات، رسم اتجاه، قائمة ملاحظات العملاء
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../widgets/layout/app_header.dart';
import '../../providers/ai_sentiment_analysis_providers.dart';
import '../../services/ai_sentiment_analysis_service.dart';
import '../../widgets/ai/sentiment_gauge.dart';
import '../../widgets/ai/keyword_cloud.dart';

class AiSentimentAnalysisScreen extends ConsumerStatefulWidget {
  const AiSentimentAnalysisScreen({super.key});

  @override
  ConsumerState<AiSentimentAnalysisScreen> createState() => _AiSentimentAnalysisScreenState();
}

class _AiSentimentAnalysisScreenState extends ConsumerState<AiSentimentAnalysisScreen> {

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isWideScreen = size.width > 900;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
              children: [
                AppHeader(
                  title: 'تحليل مشاعر العملاء',
                  onMenuTap: !isWideScreen ? () => Scaffold.of(context).openDrawer() : null,
                ),
                Expanded(child: _buildContent(isDark, isWideScreen)),
              ],
            );
  }

  Widget _buildContent(bool isDark, bool isWideScreen) {
    final result = ref.watch(sentimentResultProvider);
    final keywords = ref.watch(sentimentKeywordsProvider);
    final trend = ref.watch(sentimentTrendProvider);
    final feedback = ref.watch(customerFeedbackProvider);
    final filter = ref.watch(sentimentFilterProvider);

    final filteredFeedback = filter == null
        ? feedback
        : feedback.where((f) => f.sentiment == filter).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Top row: Gauge + Distribution
          isWideScreen
              ? Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 400,
                      child: SentimentGauge(
                        value: result.overallValue,
                        score: result.overallScore,
                        satisfactionRate: result.satisfactionRate,
                        nps: result.nps,
                        totalReviews: result.totalReviews,
                      ),
                    ),
                    const SizedBox(width: 20),
                    Expanded(child: _buildDistribution(result, isDark)),
                  ],
                )
              : Column(
                  children: [
                    SentimentGauge(
                      value: result.overallValue,
                      score: result.overallScore,
                      satisfactionRate: result.satisfactionRate,
                      nps: result.nps,
                      totalReviews: result.totalReviews,
                    ),
                    const SizedBox(height: 16),
                    _buildDistribution(result, isDark),
                  ],
                ),

          const SizedBox(height: 20),

          // Keyword cloud
          KeywordCloud(keywords: keywords),

          const SizedBox(height: 20),

          // Trend chart
          _buildTrendChart(trend, isDark),

          const SizedBox(height: 20),

          // Feedback filter
          _buildFeedbackFilter(filter, isDark),

          const SizedBox(height: 12),

          // Feedback list
          ...filteredFeedback.map((f) => _buildFeedbackCard(f, isDark)),
        ],
      ),
    );
  }

  Widget _buildDistribution(SentimentResult result, bool isDark) {
    final entries = [
      _DistEntry('إيجابي جداً', result.distribution[SentimentScore.veryPositive] ?? 0, AppColors.success),
      _DistEntry('إيجابي', result.distribution[SentimentScore.positive] ?? 0, AppColors.primaryLight),
      _DistEntry('محايد', result.distribution[SentimentScore.neutral] ?? 0, AppColors.warning),
      _DistEntry('سلبي', result.distribution[SentimentScore.negative] ?? 0, const Color(0xFFF97316)),
      _DistEntry('سلبي جداً', result.distribution[SentimentScore.veryNegative] ?? 0, AppColors.error),
    ];
    final total = result.totalReviews;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? Colors.white.withValues(alpha: 0.1) : AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'توزيع التقييمات',
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 15,
              color: isDark ? Colors.white : AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          ...entries.map((entry) {
            final percent = total > 0 ? entry.count / total : 0.0;
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                children: [
                  SizedBox(
                    width: 80,
                    child: Text(
                      entry.label,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: isDark ? Colors.white.withValues(alpha: 0.7) : AppColors.textSecondary,
                      ),
                    ),
                  ),
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: percent,
                        minHeight: 10,
                        backgroundColor: isDark ? Colors.white.withValues(alpha: 0.06) : AppColors.grey200,
                        valueColor: AlwaysStoppedAnimation(entry.color),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  SizedBox(
                    width: 30,
                    child: Text(
                      '${entry.count}',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                        color: isDark ? Colors.white : AppColors.textPrimary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildTrendChart(List<SentimentTrend> trend, bool isDark) {
    return Container(
      height: 220,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? Colors.white.withValues(alpha: 0.1) : AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF10B981), Color(0xFF059669)],
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.trending_up_rounded, color: Colors.white, size: 18),
              ),
              const SizedBox(width: 12),
              Text(
                'اتجاه المشاعر',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                  color: isDark ? Colors.white : AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: CustomPaint(
              size: Size.infinite,
              painter: _TrendChartPainter(trend: trend, isDark: isDark),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeedbackFilter(SentimentScore? current, bool isDark) {
    final filters = [
      const _FilterOption(null, 'الكل', AppColors.textSecondary),
      const _FilterOption(SentimentScore.veryPositive, 'إيجابي جداً', AppColors.success),
      const _FilterOption(SentimentScore.positive, 'إيجابي', AppColors.primaryLight),
      const _FilterOption(SentimentScore.neutral, 'محايد', AppColors.warning),
      const _FilterOption(SentimentScore.negative, 'سلبي', Color(0xFFF97316)),
      const _FilterOption(SentimentScore.veryNegative, 'سلبي جداً', AppColors.error),
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: filters.map((f) {
          final isSelected = f.score == current;
          return Padding(
            padding: const EdgeInsetsDirectional.only(start: 8),
            child: FilterChip(
              selected: isSelected,
              label: Text(f.label),
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : (isDark ? Colors.white.withValues(alpha: 0.6) : AppColors.textSecondary),
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              ),
              selectedColor: f.color,
              backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
              side: BorderSide(
                color: isSelected ? f.color : (isDark ? Colors.white.withValues(alpha: 0.1) : AppColors.border),
              ),
              onSelected: (_) => ref.read(sentimentFilterProvider.notifier).state = f.score,
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildFeedbackCard(CustomerFeedback feedback, bool isDark) {
    Color sentimentColor;
    IconData sentimentIcon;
    switch (feedback.sentiment) {
      case SentimentScore.veryPositive:
        sentimentColor = AppColors.success;
        sentimentIcon = Icons.sentiment_very_satisfied_rounded;
      case SentimentScore.positive:
        sentimentColor = AppColors.primaryLight;
        sentimentIcon = Icons.sentiment_satisfied_rounded;
      case SentimentScore.neutral:
        sentimentColor = AppColors.warning;
        sentimentIcon = Icons.sentiment_neutral_rounded;
      case SentimentScore.negative:
        sentimentColor = const Color(0xFFF97316);
        sentimentIcon = Icons.sentiment_dissatisfied_rounded;
      case SentimentScore.veryNegative:
        sentimentColor = AppColors.error;
        sentimentIcon = Icons.sentiment_very_dissatisfied_rounded;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark ? Colors.white.withValues(alpha: 0.08) : AppColors.border,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.15 : 0.04),
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
              // Sentiment icon
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: sentimentColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(sentimentIcon, color: sentimentColor, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      feedback.customerName,
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                        color: isDark ? Colors.white : AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      _formatTimeAgo(feedback.timestamp),
                      style: TextStyle(
                        fontSize: 11,
                        color: isDark ? Colors.white.withValues(alpha: 0.4) : AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
              // Rating stars
              if (feedback.rating != null)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(5, (i) {
                    return Icon(
                      i < feedback.rating! ? Icons.star_rounded : Icons.star_outline_rounded,
                      size: 16,
                      color: i < feedback.rating!
                          ? const Color(0xFFFBBF24)
                          : (isDark ? Colors.white.withValues(alpha: 0.2) : AppColors.grey300),
                    );
                  }),
                ),
            ],
          ),

          const SizedBox(height: 12),

          // Feedback text
          Text(
            feedback.text,
            style: TextStyle(
              fontSize: 13,
              color: isDark ? Colors.white.withValues(alpha: 0.8) : AppColors.textSecondary,
              height: 1.5,
            ),
          ),

          const SizedBox(height: 10),

          // Keywords + product
          Row(
            children: [
              Expanded(
                child: Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children: feedback.keywords.map((kw) {
                    final isPositive = AiSentimentAnalysisService.positiveWords.contains(kw) ||
                        ['تنوع', 'عروض', 'مناسب', 'أفضل', 'جودة عالية'].contains(kw);
                    final isNegative = AiSentimentAnalysisService.negativeWords.contains(kw) ||
                        ['غير متوفر', 'طويل', 'مزدحم'].contains(kw);
                    final color = isPositive ? AppColors.success : isNegative ? AppColors.error : AppColors.warning;

                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: color.withValues(alpha: 0.2)),
                      ),
                      child: Text(
                        kw,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: color,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              if (feedback.productName != null) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.info.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.inventory_2_rounded, size: 12, color: AppColors.info),
                      const SizedBox(width: 4),
                      Text(
                        feedback.productName!,
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: AppColors.info,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),

          const SizedBox(height: 8),

          // Sentiment bar
          Row(
            children: [
              Text(
                'مؤشر المشاعر',
                style: TextStyle(
                  fontSize: 10,
                  color: isDark ? Colors.white.withValues(alpha: 0.3) : AppColors.textMuted,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(3),
                  child: LinearProgressIndicator(
                    value: (feedback.sentimentValue + 1) / 2,
                    minHeight: 4,
                    backgroundColor: isDark ? Colors.white.withValues(alpha: 0.06) : AppColors.grey200,
                    valueColor: AlwaysStoppedAnimation(sentimentColor),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '${(feedback.sentimentValue * 100).toInt()}%',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: sentimentColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatTimeAgo(DateTime time) {
    final diff = DateTime.now().difference(time);
    if (diff.inMinutes < 60) return 'منذ ${diff.inMinutes} دقيقة';
    if (diff.inHours < 24) return 'منذ ${diff.inHours} ساعة';
    return 'منذ ${diff.inDays} يوم';
  }
}

class _DistEntry {
  final String label;
  final int count;
  final Color color;
  const _DistEntry(this.label, this.count, this.color);
}

class _FilterOption {
  final SentimentScore? score;
  final String label;
  final Color color;
  const _FilterOption(this.score, this.label, this.color);
}

/// رسام اتجاه المشاعر
class _TrendChartPainter extends CustomPainter {
  final List<SentimentTrend> trend;
  final bool isDark;

  _TrendChartPainter({required this.trend, required this.isDark});

  @override
  void paint(Canvas canvas, Size size) {
    if (trend.isEmpty) return;
    final stepX = size.width / (trend.length - 1);

    // Grid
    final gridPaint = Paint()
      ..color = isDark ? Colors.white.withValues(alpha: 0.06) : AppColors.grey200
      ..strokeWidth = 1;
    for (int i = 0; i <= 4; i++) {
      final y = size.height * i / 4;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    // Draw stacked area for positive, neutral, negative
    _drawLine(canvas, size, trend.map((t) => t.positivePercent).toList(), stepX, AppColors.success);
    _drawLine(canvas, size, trend.map((t) => t.neutralPercent).toList(), stepX, AppColors.warning);
    _drawLine(canvas, size, trend.map((t) => t.negativePercent).toList(), stepX, AppColors.error);

    // Labels
    for (int i = 0; i < trend.length; i++) {
      final tp = TextPainter(
        text: TextSpan(
          text: trend[i].period.replaceAll('الأسبوع ', 'ع'),
          style: TextStyle(
            color: isDark ? Colors.white.withValues(alpha: 0.4) : AppColors.textMuted,
            fontSize: 9,
          ),
        ),
        textDirection: TextDirection.rtl,
      )..layout();
      tp.paint(canvas, Offset(i * stepX - tp.width / 2, size.height + 6));
    }
  }

  void _drawLine(Canvas canvas, Size size, List<double> values, double stepX, Color color) {
    const maxVal = 100.0;
    final path = Path();
    final fillPath = Path();

    for (int i = 0; i < values.length; i++) {
      final x = i * stepX;
      final y = size.height - (values[i] / maxVal * size.height * 0.9);
      if (i == 0) {
        path.moveTo(x, y);
        fillPath.moveTo(x, y);
      } else {
        path.lineTo(x, y);
        fillPath.lineTo(x, y);
      }
    }

    // Fill
    fillPath.lineTo((values.length - 1) * stepX, size.height);
    fillPath.lineTo(0, size.height);
    fillPath.close();
    canvas.drawPath(fillPath, Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [color.withValues(alpha: 0.15), color.withValues(alpha: 0.02)],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height)));

    // Line
    canvas.drawPath(path, Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round);

    // Dots
    for (int i = 0; i < values.length; i++) {
      final x = i * stepX;
      final y = size.height - (values[i] / maxVal * size.height * 0.9);
      canvas.drawCircle(Offset(x, y), 3.5, Paint()..color = color);
      canvas.drawCircle(Offset(x, y), 1.5, Paint()..color = Colors.white);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
