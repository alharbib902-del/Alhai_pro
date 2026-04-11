import 'package:alhai_design_system/alhai_design_system.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:alhai_core/alhai_core.dart';

class StoreCard extends StatelessWidget {
  final Store store;
  final double? distanceKm;
  final VoidCallback? onTap;

  const StoreCard({
    super.key,
    required this.store,
    this.distanceKm,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isOpen = store.isOpenNow();

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(AlhaiSpacing.md),
          child: Row(
            children: [
              // Store logo
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer,
                  borderRadius: AlhaiRadius.borderMd,
                ),
                child: store.logoUrl != null
                    ? ClipRRect(
                        borderRadius: AlhaiRadius.borderMd,
                        child: CachedNetworkImage(
                          imageUrl: store.logoUrl!,
                          fit: BoxFit.cover,
                          errorWidget: (_, __, ___) => Icon(
                            Icons.storefront,
                            color: theme.colorScheme.primary,
                          ),
                          placeholder: (_, __) => Icon(
                            Icons.image_outlined,
                            color: theme.colorScheme.outline,
                          ),
                        ),
                      )
                    : Icon(Icons.storefront, color: theme.colorScheme.primary),
              ),
              const SizedBox(width: AlhaiSpacing.sm),
              // Store info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      store.name,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: AlhaiSpacing.xxs),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AlhaiSpacing.xs,
                            vertical: AlhaiSpacing.xxxs,
                          ),
                          decoration: BoxDecoration(
                            color: isOpen
                                ? theme
                                      .extension<AlhaiStatusColors>()!
                                      .success
                                      .withValues(alpha: 0.1)
                                : theme
                                      .extension<AlhaiStatusColors>()!
                                      .error
                                      .withValues(alpha: 0.1),
                            borderRadius: AlhaiRadius.borderSm,
                          ),
                          child: Text(
                            isOpen ? 'مفتوح' : 'مغلق',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: isOpen
                                  ? theme
                                        .extension<AlhaiStatusColors>()!
                                        .success
                                  : theme.extension<AlhaiStatusColors>()!.error,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        if (distanceKm != null) ...[
                          const SizedBox(width: AlhaiSpacing.xs),
                          Icon(
                            Icons.location_on_outlined,
                            size: 14,
                            color: theme.colorScheme.outline,
                          ),
                          const SizedBox(width: AlhaiSpacing.xxxs),
                          Text(
                            '${distanceKm!.toStringAsFixed(1)} كم',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: theme.colorScheme.outline,
                            ),
                          ),
                        ],
                      ],
                    ),
                    if (store.minOrderAmount != null) ...[
                      const SizedBox(height: AlhaiSpacing.xxs),
                      Text(
                        'الحد الأدنى: ${store.minOrderAmount!.toStringAsFixed(0)} ر.س',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.outline,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              Icon(Icons.chevron_left, color: theme.colorScheme.outline),
            ],
          ),
        ),
      ),
    );
  }
}
