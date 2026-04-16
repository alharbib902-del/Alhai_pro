/// Price Audit Log Screen
///
/// Shows a timeline of price changes with product filtering and date range.
/// Graceful 42P01 handling: shows empty state if table doesn't exist.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:alhai_design_system/alhai_design_system.dart';
import 'package:intl/intl.dart' show NumberFormat;

import '../../core/utils/date_helper.dart';
import '../../data/models.dart';
import '../../providers/distributor_providers.dart';
import '../../ui/shared_widgets.dart' show responsivePadding, kMaxContentWidth;

// ─── Provider ─────────────────────────────────────────────────

final priceAuditProvider = FutureProvider.autoDispose
    .family<List<PriceAuditEntry>, String?>((ref, productId) async {
  final ds = ref.read(distributorDatasourceProvider);
  return ds.getPriceAuditLog(productId: productId);
});

// ─── Screen ───────────────────────────────────────────────────

class PriceAuditScreen extends ConsumerStatefulWidget {
  const PriceAuditScreen({super.key});

  @override
  ConsumerState<PriceAuditScreen> createState() => _PriceAuditScreenState();
}

class _PriceAuditScreenState extends ConsumerState<PriceAuditScreen> {
  String? _selectedProductId;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final width = MediaQuery.sizeOf(context).width;
    final rPadding = responsivePadding(width);
    final auditAsync = ref.watch(priceAuditProvider(_selectedProductId));

    return Scaffold(
      backgroundColor: AppColors.getBackground(isDark),
      appBar: AppBar(
        title: const Text('سجل تغييرات الأسعار'),
        centerTitle: false,
      ),
      body: Column(
        children: [
          // Filter bar
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: rPadding,
              vertical: AlhaiSpacing.sm,
            ),
            child: Row(
              children: [
                const Icon(Icons.filter_list, size: 20),
                const SizedBox(width: AlhaiSpacing.sm),
                Text(
                  'تصفية حسب المنتج:',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.getTextSecondary(isDark),
                  ),
                ),
                const SizedBox(width: AlhaiSpacing.sm),
                if (_selectedProductId != null)
                  ActionChip(
                    label: const Text('إزالة الفلتر'),
                    onPressed: () =>
                        setState(() => _selectedProductId = null),
                    avatar: const Icon(Icons.close, size: 16),
                  ),
              ],
            ),
          ),
          const Divider(height: 1),

          // Content
          Expanded(
            child: auditAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(
                child: Text(
                  'خطأ في تحميل السجل',
                  style: TextStyle(color: AppColors.getTextSecondary(isDark)),
                ),
              ),
              data: (entries) {
                if (entries.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.history,
                          size: 64,
                          color: AppColors.getTextMuted(isDark),
                        ),
                        const SizedBox(height: AlhaiSpacing.md),
                        Text(
                          'لا توجد تغييرات مسجلة',
                          style: TextStyle(
                            fontSize: 16,
                            color: AppColors.getTextSecondary(isDark),
                          ),
                        ),
                        const SizedBox(height: AlhaiSpacing.xs),
                        Text(
                          'ستظهر هنا جميع تغييرات الأسعار',
                          style: TextStyle(
                            fontSize: 13,
                            color: AppColors.getTextMuted(isDark),
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: EdgeInsets.all(rPadding),
                  itemCount: entries.length,
                  itemBuilder: (context, index) {
                    final entry = entries[index];
                    return _AuditEntryCard(
                      entry: entry,
                      isDark: isDark,
                      onProductTap: () => setState(
                          () => _selectedProductId = entry.productId),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _AuditEntryCard extends StatelessWidget {
  final PriceAuditEntry entry;
  final bool isDark;
  final VoidCallback onProductTap;

  const _AuditEntryCard({
    required this.entry,
    required this.isDark,
    required this.onProductTap,
  });

  @override
  Widget build(BuildContext context) {
    final currFmt = NumberFormat('#,##0.00');
    final diff = entry.priceDifference;
    final isIncrease = diff != null && diff > 0;

    return Container(
      margin: const EdgeInsets.only(bottom: AlhaiSpacing.sm),
      padding: const EdgeInsets.all(AlhaiSpacing.md),
      constraints: const BoxConstraints(maxWidth: kMaxContentWidth),
      decoration: BoxDecoration(
        color: AppColors.getSurface(isDark),
        borderRadius: BorderRadius.circular(AlhaiRadius.md),
        border: Border.all(color: AppColors.getBorder(isDark)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Timeline indicator
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: (isIncrease ? AppColors.error : AppColors.success)
                  .withValues(alpha: 0.12),
            ),
            child: Icon(
              isIncrease
                  ? Icons.trending_up_rounded
                  : Icons.trending_down_rounded,
              size: 18,
              color: isIncrease ? AppColors.error : AppColors.success,
            ),
          ),
          const SizedBox(width: AlhaiSpacing.sm),
          // Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                InkWell(
                  onTap: onProductTap,
                  child: Text(
                    entry.productName,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    if (entry.oldPrice != null) ...[
                      Text(
                        '${currFmt.format(entry.oldPrice)} ر.س',
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.getTextMuted(isDark),
                          decoration: TextDecoration.lineThrough,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(Icons.arrow_forward, size: 14),
                      const SizedBox(width: 8),
                    ],
                    Text(
                      '${currFmt.format(entry.newPrice)} ر.س',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.getTextPrimary(isDark),
                      ),
                    ),
                    if (entry.percentChange != null) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: (isIncrease
                                  ? AppColors.error
                                  : AppColors.success)
                              .withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          '${isIncrease ? '+' : ''}${entry.percentChange!.toStringAsFixed(1)}%',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: isIncrease
                                ? AppColors.error
                                : AppColors.success,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  DateHelper.dualWithTime(entry.changedAt),
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.getTextMuted(isDark),
                  ),
                ),
                if (entry.reason != null && entry.reason!.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    'السبب: ${entry.reason}',
                    style: TextStyle(
                      fontSize: 12,
                      fontStyle: FontStyle.italic,
                      color: AppColors.getTextSecondary(isDark),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
