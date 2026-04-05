/// Lite Profile Screen
///
/// User profile with personal info, store info, role display,
/// and quick settings access. Reads from currentUserProvider.
/// Supports RTL, dark mode, and responsive layouts.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:alhai_l10n/alhai_l10n.dart';
import 'package:alhai_design_system/alhai_design_system.dart';
import 'package:alhai_shared_ui/alhai_shared_ui.dart';
import 'package:alhai_auth/alhai_auth.dart';

/// Profile screen for Admin Lite
class LiteProfileScreen extends ConsumerWidget {
  const LiteProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final size = MediaQuery.of(context).size;
    final isMobile = size.width < 600;
    final l10n = AppLocalizations.of(context);
    final user = ref.watch(currentUserProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.profileTitle),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(
          horizontal: isMobile ? AlhaiSpacing.md : AlhaiSpacing.xl,
          vertical: AlhaiSpacing.md,
        ),
        child: Column(
          children: [
            // Profile header
            _buildProfileHeader(context, isDark, l10n, user),
            const SizedBox(height: AlhaiSpacing.lg),

            // Store info
            _buildSection(context, isDark, l10n.settings, Icons.store, [
              _InfoTile(
                  Icons.badge, user?.role.name ?? 'Admin', l10n.profileTitle),
              if (user?.phone != null)
                _InfoTile(Icons.phone, user!.phone, l10n.profileTitle),
              if (user?.email != null)
                _InfoTile(Icons.email, user!.email!, l10n.profileTitle),
            ]),
            const SizedBox(height: AlhaiSpacing.lg),

            // Quick settings
            _buildSection(context, isDark, l10n.quickActions, Icons.settings, [
              _ActionTile(Icons.notifications_outlined, l10n.notifications,
                  () => context.go('/lite/settings/notification-prefs')),
              _ActionTile(Icons.language, l10n.language,
                  () => context.go(AppRoutes.settingsLanguage)),
              _ActionTile(Icons.palette_outlined, l10n.theme,
                  () => context.go(AppRoutes.settingsTheme)),
            ]),

            const SizedBox(height: AlhaiSpacing.lg),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader(
      BuildContext context, bool isDark, AppLocalizations l10n, dynamic user) {
    final name = user?.name ?? '?';
    final email = user?.email ?? '';
    final initial = name.isNotEmpty ? name[0].toUpperCase() : '?';
    final roleName = user?.role?.name ?? 'Admin';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AlhaiSpacing.lg),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.06) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark
              ? Colors.white12
              : Theme.of(context).colorScheme.outlineVariant,
        ),
      ),
      child: Column(
        children: [
          CircleAvatar(
            radius: 40,
            backgroundColor: AlhaiColors.primary.withValues(alpha: 0.15),
            child: Text(
              initial,
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: AlhaiColors.primary,
              ),
            ),
          ),
          const SizedBox(height: AlhaiSpacing.md),
          Text(
            name,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          if (email.isNotEmpty) ...[
            const SizedBox(height: AlhaiSpacing.xxs),
            Text(
              email,
              style: TextStyle(
                fontSize: 14,
                color: isDark
                    ? Colors.white54
                    : Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
          const SizedBox(height: AlhaiSpacing.xs),
          Container(
            padding: const EdgeInsets.symmetric(
                horizontal: 12, vertical: AlhaiSpacing.xxs),
            decoration: BoxDecoration(
              color: AlhaiColors.primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              roleName,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: AlhaiColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(BuildContext context, bool isDark, String title,
      IconData icon, List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.06) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark
              ? Colors.white12
              : Theme.of(context).colorScheme.surfaceContainer,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(AlhaiSpacing.md,
                AlhaiSpacing.md, AlhaiSpacing.md, AlhaiSpacing.xs),
            child: Row(
              children: [
                Icon(icon, size: 18, color: AlhaiColors.primary),
                const SizedBox(width: AlhaiSpacing.xs),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: isDark
                        ? Colors.white70
                        : Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ),
          ...children,
        ],
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _InfoTile(this.icon, this.title, this.subtitle);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding:
          const EdgeInsets.symmetric(horizontal: AlhaiSpacing.md, vertical: 10),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AlhaiColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 18, color: AlhaiColors.primary),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const _ActionTile(this.icon, this.title, this.onTap);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(
            horizontal: AlhaiSpacing.md, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AlhaiColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, size: 18, color: AlhaiColors.primary),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
            ),
            Icon(
              Icons.chevron_right,
              size: 20,
              color: isDark ? Colors.white24 : Theme.of(context).dividerColor,
            ),
          ],
        ),
      ),
    );
  }
}
