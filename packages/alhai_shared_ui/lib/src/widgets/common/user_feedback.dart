import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:alhai_design_system/alhai_design_system.dart' show AlhaiColors;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

/// نظام جمع تقييم المستخدم بعد كل عملية
/// 
/// "هل كانت العملية سريعة؟"
/// يخزن النتائج للتحليل

/// تقييم واحد
class UserFeedback {
  final String saleId;
  final DateTime timestamp;
  final int rating; // 1-5 أو thumbs up/down
  final bool wasQuick;
  final String? comment;

  const UserFeedback({
    required this.saleId,
    required this.timestamp,
    required this.rating,
    required this.wasQuick,
    this.comment,
  });

  Map<String, dynamic> toJson() => {
    'saleId': saleId,
    'timestamp': timestamp.toIso8601String(),
    'rating': rating,
    'wasQuick': wasQuick,
    'comment': comment,
  };

  factory UserFeedback.fromJson(Map<String, dynamic> json) {
    return UserFeedback(
      saleId: json['saleId'],
      timestamp: DateTime.tryParse(json['timestamp'] as String) ?? DateTime.now(),
      rating: json['rating'],
      wasQuick: json['wasQuick'],
      comment: json['comment'],
    );
  }
}

/// مدير التقييمات
class FeedbackNotifier extends StateNotifier<List<UserFeedback>> {
  FeedbackNotifier() : super([]) {
    _loadFromPrefs();
  }

  static const _prefKey = 'user_feedbacks';

  Future<void> _loadFromPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonStr = prefs.getString(_prefKey);
      if (jsonStr != null) {
        final list = jsonDecode(jsonStr) as List;
        state = list.map((e) => UserFeedback.fromJson(e)).toList();
      }
    } catch (_) {
      // تجاهل الأخطاء
    }
  }

  Future<void> _saveToPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonStr = jsonEncode(state.map((e) => e.toJson()).toList());
      await prefs.setString(_prefKey, jsonStr);
    } catch (_) {
      // تجاهل الأخطاء
    }
  }

  /// إضافة تقييم جديد
  Future<void> addFeedback({
    required String saleId,
    required int rating,
    required bool wasQuick,
    String? comment,
  }) async {
    final feedback = UserFeedback(
      saleId: saleId,
      timestamp: DateTime.now(),
      rating: rating,
      wasQuick: wasQuick,
      comment: comment,
    );
    
    state = [...state, feedback];
    await _saveToPrefs();
  }

  /// نسبة الـ "سريع"
  double get quickPercentage {
    if (state.isEmpty) return 0;
    final quickCount = state.where((f) => f.wasQuick).length;
    return quickCount / state.length * 100;
  }

  /// متوسط التقييم
  double get avgRating {
    if (state.isEmpty) return 0;
    final total = state.fold<int>(0, (sum, f) => sum + f.rating);
    return total / state.length;
  }

  /// مسح كل التقييمات
  Future<void> clear() async {
    state = [];
    await _saveToPrefs();
  }
}

/// مزود التقييمات
final feedbackProvider = StateNotifierProvider<FeedbackNotifier, List<UserFeedback>>(
  (ref) => FeedbackNotifier(),
);

/// نسبة "سريع"
final quickPercentageProvider = Provider<double>((ref) {
  return ref.watch(feedbackProvider.notifier).quickPercentage;
});

/// Widget لجمع التقييم بعد العملية
class QuickFeedbackWidget extends ConsumerWidget {
  final String saleId;
  final VoidCallback? onFeedbackSubmitted;

  const QuickFeedbackWidget({
    super.key,
    required this.saleId,
    this.onFeedbackSubmitted,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return Card(
      color: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'كيف كانت هذه العملية؟',
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _FeedbackButton(
                  icon: Icons.thumb_up,
                  label: 'سريعة ✓',
                  color: AlhaiColors.success,
                  onTap: () {
                    ref.read(feedbackProvider.notifier).addFeedback(
                      saleId: saleId,
                      rating: 5,
                      wasQuick: true,
                    );
                    onFeedbackSubmitted?.call();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('شكراً لتقييمك! 👍'),
                        duration: Duration(seconds: 1),
                      ),
                    );
                  },
                ),
                _FeedbackButton(
                  icon: Icons.thumb_down,
                  label: 'بطيئة',
                  color: AlhaiColors.warning,
                  onTap: () {
                    ref.read(feedbackProvider.notifier).addFeedback(
                      saleId: saleId,
                      rating: 2,
                      wasQuick: false,
                    );
                    onFeedbackSubmitted?.call();
                    _showDetailedFeedback(context, ref, saleId);
                  },
                ),
                TextButton(
                  onPressed: onFeedbackSubmitted,
                  child: const Text('تخطي'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showDetailedFeedback(BuildContext context, WidgetRef ref, String saleId) {
    final controller = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('ما الذي يمكن تحسينه؟'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('مساعدتك تفيدنا في تحسين التطبيق'),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: 'اكتب ملاحظتك (اختياري)...',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          FilledButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                ref.read(feedbackProvider.notifier).addFeedback(
                  saleId: saleId,
                  rating: 2,
                  wasQuick: false,
                  comment: controller.text,
                );
              }
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('شكراً! سنعمل على التحسين 🙏'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
            child: const Text('إرسال'),
          ),
        ],
      ),
    ).then((_) {
      controller.dispose();
    });
  }
}

class _FeedbackButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _FeedbackButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color.withValues(alpha: 0.1),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Column(
            children: [
              Icon(icon, color: color, size: 32),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Widget لعرض إحصائيات التقييم
class FeedbackStatsWidget extends ConsumerWidget {
  const FeedbackStatsWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final feedbacks = ref.watch(feedbackProvider);
    final notifier = ref.watch(feedbackProvider.notifier);
    final theme = Theme.of(context);

    if (feedbacks.isEmpty) {
      return const Center(child: Text('لا توجد تقييمات بعد'));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'تقييمات العملاء',
          style: theme.textTheme.titleMedium,
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _StatCard(
                label: 'عمليات سريعة',
                value: '${notifier.quickPercentage.toStringAsFixed(0)}%',
                icon: Icons.flash_on,
                color: AlhaiColors.success,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _StatCard(
                label: 'متوسط التقييم',
                value: notifier.avgRating.toStringAsFixed(1),
                icon: Icons.star,
                color: Colors.amber,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _StatCard(
                label: 'إجمالي التقييمات',
                value: '${feedbacks.length}',
                icon: Icons.thumb_up,
                color: AlhaiColors.info,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, color: color),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
