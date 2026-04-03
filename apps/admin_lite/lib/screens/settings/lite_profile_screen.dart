/// Lite Profile Screen
///
/// User profile with personal info, store info, role display,
/// and quick settings access.
/// Supports RTL, dark mode, and responsive layouts.
library;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:alhai_l10n/alhai_l10n.dart';
import 'package:alhai_design_system/alhai_design_system.dart';
import 'package:alhai_shared_ui/alhai_shared_ui.dart';

/// Profile screen for Admin Lite
class LiteProfileScreen extends StatelessWidget {
  const LiteProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final size = MediaQuery.of(context).size;
    final isMobile = size.width < 600;
    final l10n = AppLocalizations.of(context)!;

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
            _buildProfileHeader(context, isDark, l10n),
            const SizedBox(height: AlhaiSpacing.lg),

            // Store info
            _buildSection(context, isDark, l10n.settings, Icons.store, [
              _InfoTile(Icons.store, 'Al-Hal Supermarket', 'Riyadh, Al-Olaya'),
              _InfoTile(Icons.badge, 'Admin', 'Manager'),
              _InfoTile(Icons.calendar_today, 'Member since', 'Jan 2024'),
            ]),
            const SizedBox(height: AlhaiSpacing.lg),

            // Quick settings
            _buildSection(context, isDark, l10n.quickActions, Icons.settings, [
              _ActionTile(Icons.notifications_outlined, l10n.notifications, () => context.go('/lite/settings/notification-prefs')),
              _ActionTile(Icons.language, l10n.language, () => context.go(AppRoutes.settingsLanguage)),
              _ActionTile(Icons.palette_outlined, l10n.theme, () => context.go(AppRoutes.settingsTheme)),
              _ActionTile(Icons.lock_outline, l10n.security, () {}),
            ]),

            const SizedBox(height: AlhaiSpacing.lg),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader(BuildContext context, bool isDark, AppLocalizations l10n) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AlhaiSpacing.lg),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.06) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? Colors.white12 : Theme.of(context).colorScheme.outlineVariant,
        ),
      ),
      child: Column(
        children: [
          CircleAvatar(
            radius: 40,
            backgroundColor: AlhaiColors.primary.withValues(alpha: 0.15),
            child: const Text(
              'A',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: AlhaiColors.primary,
              ),
            ),
          ),
          const SizedBox(height: AlhaiSpacing.md),
          Text(
            'Ahmed Al-Rashid',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          const SizedBox(height: AlhaiSpacing.xxs),
          Text(
            'admin@alhal.sa',
            style: TextStyle(
              fontSize: 14,
              color: isDark ? Colors.white54 : Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: AlhaiSpacing.xs),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: AlhaiSpacing.xxs),
            decoration: BoxDecoration(
              color: AlhaiColors.primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Text(
              'Admin',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: AlhaiColors.primary,
              ),
            ),
          ),
          const SizedBox(height: AlhaiSpacing.md),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildStatPill(l10n.orders, '1,248', isDark, context),
              const SizedBox(width: AlhaiSpacing.sm),
              _buildStatPill(l10n.products, '456', isDark, context),
              const SizedBox(width: AlhaiSpacing.sm),
              _buildStatPill(l10n.customers, '89', isDark, context),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatPill(String label, String value, bool isDark, BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AlhaiSpacing.sm, vertical: AlhaiSpacing.xs),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.06) : Theme.of(context).colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: isDark ? Colors.white38 : Colors.black45,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(BuildContext context, bool isDark, String title, IconData icon, List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.06) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? Colors.white12 : Theme.of(context).colorScheme.surfaceContainer,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(AlhaiSpacing.md, AlhaiSpacing.md, AlhaiSpacing.md, AlhaiSpacing.xs),
            child: Row(
              children: [
                Icon(icon, size: 18, color: AlhaiColors.primary),
                const SizedBox(width: AlhaiSpacing.xs),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white70 : Theme.of(context).colorScheme.onSurface,
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
      padding: const EdgeInsets.symmetric(horizontal: AlhaiSpacing.md, vertical: 10),
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? Colors.white38 : Theme.of(context).colorScheme.outline,
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
        padding: const EdgeInsets.symmetric(horizontal: AlhaiSpacing.md, vertical: 14),
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
