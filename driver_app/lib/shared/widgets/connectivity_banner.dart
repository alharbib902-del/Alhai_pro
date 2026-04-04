import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers/app_providers.dart';

/// Animated banner that appears when the device is offline.
class ConnectivityBanner extends ConsumerWidget {
  const ConnectivityBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final connectivityAsync = ref.watch(connectivityProvider);
    final theme = Theme.of(context);

    // Default to online while loading to avoid a flash on startup.
    final isOnline = connectivityAsync.maybeWhen(
      data: (online) => online,
      orElse: () => true,
    );

    return AnimatedSize(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeInOut,
      child: isOnline
          ? const SizedBox.shrink()
          : Container(
              width: double.infinity,
              color: theme.colorScheme.error,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.wifi_off_rounded,
                    size: 18,
                    color: theme.colorScheme.onError,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'لا يوجد اتصال بالإنترنت',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onError,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
