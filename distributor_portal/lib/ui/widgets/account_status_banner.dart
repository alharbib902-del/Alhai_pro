/// Account status banner shown in the distributor shell.
///
/// Displays contextual banners based on the distributor's onboarding status.
/// Active distributors see no banner.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:alhai_design_system/alhai_design_system.dart';

import '../../data/models.dart';
import '../../providers/distributor_onboarding_providers.dart';

class AccountStatusBanner extends ConsumerWidget {
  const AccountStatusBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statusAsync = ref.watch(distributorAccountStatusProvider);

    return statusAsync.when(
      data: (status) {
        if (status == null || status == DistributorAccountStatus.active) {
          return const SizedBox.shrink();
        }

        switch (status) {
          case DistributorAccountStatus.pendingEmailVerification:
            return _Banner(
              color: Colors.amber,
              icon: Icons.email_outlined,
              title: 'يرجى تأكيد بريدك الإلكتروني',
              subtitle: 'تحقّق من صندوق الوارد لتأكيد حسابك',
            );

          case DistributorAccountStatus.pendingReview:
            return _Banner(
              color: Colors.blue,
              icon: Icons.hourglass_top,
              title: 'حسابك قيد المراجعة',
              subtitle: 'فريق الإدارة يراجع طلبك. عادة 1-3 أيام عمل.',
            );

          case DistributorAccountStatus.rejected:
            return _Banner(
              color: AppColors.error,
              icon: Icons.cancel_outlined,
              title: 'تم رفض حسابك',
              subtitle: 'يرجى التواصل مع الدعم لمعرفة السبب',
            );

          case DistributorAccountStatus.suspended:
            return _Banner(
              color: AppColors.error,
              icon: Icons.block,
              title: 'حسابك موقوف',
              subtitle: 'تواصل مع الدعم لإعادة التفعيل',
            );

          case DistributorAccountStatus.active:
            return const SizedBox.shrink(); // Handled above
        }
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}

class _Banner extends StatelessWidget {
  final Color color;
  final IconData icon;
  final String title;
  final String subtitle;

  const _Banner({
    required this.color,
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: AlhaiSpacing.md,
        vertical: AlhaiSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        border: Border(bottom: BorderSide(color: color.withValues(alpha: 0.3))),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(width: AlhaiSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: color.withValues(alpha: 0.8),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
