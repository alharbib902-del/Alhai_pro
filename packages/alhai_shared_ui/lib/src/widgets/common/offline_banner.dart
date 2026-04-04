import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:alhai_design_system/alhai_design_system.dart' show AlhaiColors, AlhaiSpacing;
import 'package:alhai_l10n/alhai_l10n.dart';
import '../../providers/sync_providers.dart';

/// Banner لإظهار حالة عدم الاتصال
class OfflineBanner extends ConsumerWidget {
  const OfflineBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isOnlineAsync = ref.watch(isOnlineProvider);
    
    return isOnlineAsync.when(
      data: (isOnline) {
        if (isOnline) return const SizedBox.shrink();
        
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: AlhaiSpacing.md, vertical: AlhaiSpacing.xs),
          color: AlhaiColors.warningDark,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.wifi_off, color: Colors.white, size: 18),
              SizedBox(width: AlhaiSpacing.xs),
              Text(
                AppLocalizations.of(context)!.noInternetConnection,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}

/// Banner للمزامنة المعلقة (مخفي - المزامنة تعمل في الخلفية بدون إزعاج المستخدم)
class SyncPendingBanner extends ConsumerWidget {
  const SyncPendingBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // تفعيل مدير المزامنة لدفع العمليات المعلقة تلقائياً
    ref.watch(syncManagerProvider);
    // البانر مخفي - المزامنة تعمل بصمت في الخلفية
    return const SizedBox.shrink();
  }
}

/// بانر تحذير عند وجود مبيعات غير مُزامنة لأكثر من 5 دقائق
///
/// يعرض عدد العمليات المعلقة والمدة منذ أقدم عملية معلقة.
/// يختلف عن dead letter banner - هذا للعناصر المعلقة التي تنتظر اتصال.
class UnsyncedSalesBanner extends ConsumerStatefulWidget {
  const UnsyncedSalesBanner({super.key});

  @override
  ConsumerState<UnsyncedSalesBanner> createState() => _UnsyncedSalesBannerState();
}

class _UnsyncedSalesBannerState extends ConsumerState<UnsyncedSalesBanner> {
  /// Timer لتحديث عرض المدة كل دقيقة
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    _refreshTimer = Timer.periodic(const Duration(minutes: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  /// تنسيق المدة بالعربية (X دقيقة / X ساعة)
  String _formatDuration(Duration duration) {
    if (duration.inHours > 0) {
      final hours = duration.inHours;
      final mins = duration.inMinutes % 60;
      if (mins > 0) {
        return '$hours ساعة و $mins دقيقة';
      }
      return '$hours ساعة';
    }
    return '${duration.inMinutes} دقيقة';
  }

  @override
  Widget build(BuildContext context) {
    final asyncInfo = ref.watch(unsyncedSalesInfoProvider);

    return asyncInfo.when(
      data: (info) {
        // لا تعرض البانر إذا لم تكن هناك عناصر معلقة
        if (info.count == 0 || info.oldestAt == null) {
          return const SizedBox.shrink();
        }

        final pendingAge = DateTime.now().difference(info.oldestAt!);

        // لا تعرض إلا إذا مرت 5 دقائق على أقدم عنصر معلق
        if (pendingAge.inMinutes < 5) {
          return const SizedBox.shrink();
        }

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(
            horizontal: AlhaiSpacing.md,
            vertical: AlhaiSpacing.xs,
          ),
          color: AlhaiColors.warning,
          child: Row(
            children: [
              const Icon(Icons.cloud_off, color: Colors.white, size: 18),
              const SizedBox(width: AlhaiSpacing.xs),
              Expanded(
                child: Text(
                  'لديك ${info.count} عملية بيع غير مُزامنة - '
                  'تأكد من الاتصال بالإنترنت '
                  '(منذ ${_formatDuration(pendingAge)})',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}

/// بانر تحذير عند وجود عناصر ميتة (فشلت نهائياً في المزامنة)
///
/// يظهر عندما توجد عناصر بحالة conflict/failed بعد استنفاد المحاولات.
/// يوفر زر إعادة المحاولة لإعادة تعيين هذه العناصر.
class DeadLetterBanner extends ConsumerWidget {
  const DeadLetterBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncCount = ref.watch(deadLetterCountProvider);

    return asyncCount.when(
      data: (count) {
        if (count == 0) return const SizedBox.shrink();

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(
            horizontal: AlhaiSpacing.md,
            vertical: AlhaiSpacing.xs,
          ),
          color: Colors.amber.shade700,
          child: Row(
            children: [
              const Icon(Icons.warning_amber_rounded, color: Colors.white, size: 18),
              const SizedBox(width: AlhaiSpacing.xs),
              Expanded(
                child: Text(
                  'يوجد $count عملية فشلت في المزامنة',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                    fontSize: 13,
                  ),
                ),
              ),
              TextButton.icon(
                onPressed: () async {
                  final syncService = ref.read(syncServiceProvider);
                  await syncService.retryDeadLetterItems();
                },
                icon: const Icon(Icons.refresh, color: Colors.white, size: 16),
                label: const Text(
                  'إعادة المحاولة',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: AlhaiSpacing.xs),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ),
            ],
          ),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}

/// دمج الـ banners في Widget واحد
class StatusBanners extends StatelessWidget {
  const StatusBanners({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        OfflineBanner(),
        UnsyncedSalesBanner(),
        DeadLetterBanner(),
        SyncPendingBanner(),
      ],
    );
  }
}
