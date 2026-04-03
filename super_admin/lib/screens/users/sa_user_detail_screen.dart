import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:alhai_design_system/alhai_design_system.dart';
import 'package:alhai_l10n/alhai_l10n.dart';

/// User detail / role management.
class SAUserDetailScreen extends StatefulWidget {
  final String userId;
  const SAUserDetailScreen({super.key, required this.userId});

  @override
  State<SAUserDetailScreen> createState() => _SAUserDetailScreenState();
}

class _SAUserDetailScreenState extends State<SAUserDetailScreen> {
  String _selectedRole = 'super_admin';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final width = MediaQuery.sizeOf(context).width;
    final isWide = width >= AlhaiBreakpoints.desktop;

    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AlhaiSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back_rounded),
                  onPressed: () => context.go('/users'),
                ),
                const SizedBox(width: AlhaiSpacing.xs),
                Text(
                  '${l10n.userDetail} - ${widget.userId}',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AlhaiSpacing.lg),

            Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: isWide ? 800 : double.infinity,
                ),
                child: Column(
                  children: [
                    // User profile card
                    Card(
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(AlhaiRadius.card),
                        side: BorderSide(
                          color: theme.colorScheme.outlineVariant,
                          width: AlhaiSpacing.strokeXs,
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(AlhaiSpacing.xl),
                        child: Column(
                          children: [
                            CircleAvatar(
                              radius: 40,
                              backgroundColor:
                                  theme.colorScheme.primaryContainer,
                              child: Text(
                                'A',
                                style: theme.textTheme.headlineMedium
                                    ?.copyWith(
                                  color: theme.colorScheme.primary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(height: AlhaiSpacing.md),
                            Text(
                              'Ahmed Al-Rashid',
                              style:
                                  theme.textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'ahmed@alhai.sa',
                              style:
                                  theme.textTheme.bodyMedium?.copyWith(
                                color: theme.colorScheme.outline,
                              ),
                            ),
                            const SizedBox(height: AlhaiSpacing.sm),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: AlhaiSpacing.sm,
                                vertical: AlhaiSpacing.xxs,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.green.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(
                                    AlhaiRadius.full),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    width: 8,
                                    height: 8,
                                    decoration: const BoxDecoration(
                                      color: Colors.green,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(
                                      width: AlhaiSpacing.xxs),
                                  const Text(
                                    'Online',
                                    style: TextStyle(
                                      color: Colors.green,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Divider(height: AlhaiSpacing.xl),
                            _InfoRow(
                              label: l10n.userLastActive,
                              value: '2 min ago',
                            ),
                            _InfoRow(
                              label: 'Joined',
                              value: '2023-06-15',
                            ),
                            _InfoRow(
                              label: '2FA',
                              value: 'Enabled',
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: AlhaiSpacing.md),

                    // Role management card
                    Card(
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(AlhaiRadius.card),
                        side: BorderSide(
                          color: theme.colorScheme.outlineVariant,
                          width: AlhaiSpacing.strokeXs,
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(AlhaiSpacing.lg),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.admin_panel_settings_rounded,
                                    size: 20,
                                    color: theme.colorScheme.primary),
                                const SizedBox(
                                    width: AlhaiSpacing.xs),
                                Text(
                                  l10n.roleManagement,
                                  style: theme.textTheme.titleMedium
                                      ?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                            const Divider(height: AlhaiSpacing.xl),
                            _RoleOption(
                              title: l10n.superAdminRole,
                              description:
                                  'Full access to all platform features',
                              icon: Icons.shield_rounded,
                              color: Colors.red,
                              value: 'super_admin',
                              groupValue: _selectedRole,
                              onChanged: (v) =>
                                  setState(() => _selectedRole = v!),
                            ),
                            _RoleOption(
                              title: l10n.supportRole,
                              description:
                                  'View stores, manage tickets, limited settings',
                              icon: Icons.support_agent_rounded,
                              color: Colors.blue,
                              value: 'support',
                              groupValue: _selectedRole,
                              onChanged: (v) =>
                                  setState(() => _selectedRole = v!),
                            ),
                            _RoleOption(
                              title: l10n.viewerRole,
                              description:
                                  'Read-only access to dashboard and analytics',
                              icon: Icons.visibility_rounded,
                              color: Colors.grey,
                              value: 'viewer',
                              groupValue: _selectedRole,
                              onChanged: (v) =>
                                  setState(() => _selectedRole = v!),
                            ),
                            const SizedBox(height: AlhaiSpacing.md),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                FilledButton(
                                  onPressed: () {
                                    ScaffoldMessenger.of(context)
                                        .showSnackBar(
                                      const SnackBar(
                                        content: Text('Role updated'),
                                      ),
                                    );
                                  },
                                  child: Text(l10n.assignRole),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: AlhaiSpacing.sm),
      child: Row(
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.outline,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RoleOption extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final String value;
  final String groupValue;
  final ValueChanged<String?> onChanged;

  const _RoleOption({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.value,
    required this.groupValue,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = value == groupValue;
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: AlhaiSpacing.xs),
      child: InkWell(
        onTap: () => onChanged(value),
        borderRadius: BorderRadius.circular(AlhaiRadius.sm),
        child: Container(
          padding: const EdgeInsets.all(AlhaiSpacing.sm),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AlhaiRadius.sm),
            border: Border.all(
              color: isSelected
                  ? color
                  : theme.colorScheme.outlineVariant,
              width: isSelected ? 2 : 1,
            ),
            color: isSelected
                ? color.withValues(alpha: 0.05)
                : null,
          ),
          child: Row(
            children: [
              Radio<String>(
                value: value,
                groupValue: groupValue,
                onChanged: onChanged,
                activeColor: color,
              ),
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius:
                      BorderRadius.circular(AlhaiRadius.xs),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: AlhaiSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      description,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.outline,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
