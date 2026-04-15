/// Runtime permission guard widget.
///
/// Wraps a screen's content and shows an "Access Denied" message
/// when the user lacks the required permission. This provides
/// defense-in-depth on top of the GoRouter-level guards.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:alhai_design_system/alhai_design_system.dart';
import '../providers/permission_provider.dart';

/// A widget that only renders [child] when the user holds [permission].
///
/// Usage:
/// ```dart
/// PermissionGuard(
///   permission: AdminPermissions.settingsManage,
///   child: _buildContent(),
/// )
/// ```
class PermissionGuard extends ConsumerWidget {
  final String permission;
  final Widget child;

  const PermissionGuard({
    super.key,
    required this.permission,
    required this.child,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hasPermission = ref.watch(hasPermissionProvider(permission));
    if (hasPermission) return child;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AlhaiSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.lock_rounded,
              size: 64,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: AlhaiSpacing.md),
            Text(
              '\u0644\u0627 \u062a\u0645\u0644\u0643 \u0635\u0644\u0627\u062d\u064a\u0629 \u0627\u0644\u0648\u0635\u0648\u0644', // لا تملك صلاحية الوصول
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.error,
              ),
            ),
            const SizedBox(height: AlhaiSpacing.xs),
            Text(
              '\u0644\u064a\u0633 \u0644\u062f\u064a\u0643 \u0627\u0644\u0635\u0644\u0627\u062d\u064a\u0627\u062a \u0627\u0644\u0643\u0627\u0641\u064a\u0629 \u0644\u0647\u0630\u0627 \u0627\u0644\u0625\u062c\u0631\u0627\u0621', // ليس لديك الصلاحيات الكافية لهذا الإجراء
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
