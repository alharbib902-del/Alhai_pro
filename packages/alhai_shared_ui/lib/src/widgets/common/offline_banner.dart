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

/// دمج الـ banners في Widget واحد
class StatusBanners extends StatelessWidget {
  const StatusBanners({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        OfflineBanner(),
        SyncPendingBanner(),
      ],
    );
  }
}
