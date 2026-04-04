/// Lite Notification Preferences Screen
///
/// Allows configuring which notifications are enabled,
/// their delivery channels, and quiet hours.
/// Supports RTL, dark mode, and responsive layouts.
library;

import 'package:flutter/material.dart';
import 'package:alhai_l10n/alhai_l10n.dart';
import 'package:alhai_design_system/alhai_design_system.dart';

/// Notification preferences screen for Admin Lite
class LiteNotificationPrefsScreen extends StatefulWidget {
  const LiteNotificationPrefsScreen({super.key});

  @override
  State<LiteNotificationPrefsScreen> createState() =>
      _LiteNotificationPrefsScreenState();
}

class _LiteNotificationPrefsScreenState
    extends State<LiteNotificationPrefsScreen> {
  bool _pushEnabled = true;
  bool _lowStockAlerts = true;
  bool _orderAlerts = true;
  bool _shiftReminders = true;
  bool _refundNotifications = true;
  bool _expiryAlerts = true;
  bool _syncAlerts = false;
  bool _quietHours = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final size = MediaQuery.of(context).size;
    final isMobile = size.width < 600;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.notificationSettings),
        centerTitle: true,
      ),
      body: ListView(
        padding: EdgeInsets.symmetric(
          horizontal: isMobile ? AlhaiSpacing.md : AlhaiSpacing.xl,
          vertical: AlhaiSpacing.md,
        ),
        children: [
          // Master toggle
          _buildSectionHeader(
              l10n.notifications, Icons.notifications_outlined, isDark),
          const SizedBox(height: AlhaiSpacing.xs),
          _buildCard(isDark, [
            _buildToggle(
              icon: Icons.notifications_active,
              title: l10n.notifications,
              subtitle: 'Enable all push notifications',
              value: _pushEnabled,
              onChanged: (v) => setState(() => _pushEnabled = v),
              isDark: isDark,
            ),
          ]),

          const SizedBox(height: AlhaiSpacing.lg),

          // Alert types
          _buildSectionHeader(l10n.alertTypes, Icons.tune, isDark),
          const SizedBox(height: AlhaiSpacing.xs),
          _buildCard(isDark, [
            _buildToggle(
              icon: Icons.inventory_2_outlined,
              title: l10n.lowStock,
              subtitle: 'When products go below threshold',
              value: _lowStockAlerts,
              onChanged: _pushEnabled
                  ? (v) => setState(() => _lowStockAlerts = v)
                  : null,
              isDark: isDark,
            ),
            _divider(isDark),
            _buildToggle(
              icon: Icons.receipt_long,
              title: l10n.orders,
              subtitle: 'New orders and status changes',
              value: _orderAlerts,
              onChanged:
                  _pushEnabled ? (v) => setState(() => _orderAlerts = v) : null,
              isDark: isDark,
            ),
            _divider(isDark),
            _buildToggle(
              icon: Icons.access_time,
              title: l10n.shiftsTitle,
              subtitle: 'Shift open/close reminders',
              value: _shiftReminders,
              onChanged: _pushEnabled
                  ? (v) => setState(() => _shiftReminders = v)
                  : null,
              isDark: isDark,
            ),
            _divider(isDark),
            _buildToggle(
              icon: Icons.undo,
              title: l10n.returns,
              subtitle: 'New refund requests',
              value: _refundNotifications,
              onChanged: _pushEnabled
                  ? (v) => setState(() => _refundNotifications = v)
                  : null,
              isDark: isDark,
            ),
            _divider(isDark),
            _buildToggle(
              icon: Icons.calendar_today,
              title: l10n.products,
              subtitle: 'Products nearing expiration',
              value: _expiryAlerts,
              onChanged: _pushEnabled
                  ? (v) => setState(() => _expiryAlerts = v)
                  : null,
              isDark: isDark,
            ),
            _divider(isDark),
            _buildToggle(
              icon: Icons.sync,
              title: l10n.sync,
              subtitle: 'Sync errors and completions',
              value: _syncAlerts,
              onChanged:
                  _pushEnabled ? (v) => setState(() => _syncAlerts = v) : null,
              isDark: isDark,
            ),
          ]),

          const SizedBox(height: AlhaiSpacing.lg),

          // Quiet hours
          _buildSectionHeader(l10n.settings, Icons.do_not_disturb, isDark),
          const SizedBox(height: AlhaiSpacing.xs),
          _buildCard(isDark, [
            _buildToggle(
              icon: Icons.nights_stay,
              title: 'Quiet Hours',
              subtitle: '10:00 PM - 7:00 AM',
              value: _quietHours,
              onChanged: (v) => setState(() => _quietHours = v),
              isDark: isDark,
            ),
          ]),

          const SizedBox(height: AlhaiSpacing.lg),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon, bool isDark) {
    return Row(
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
    );
  }

  Widget _buildCard(bool isDark, List<Widget> children) {
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
      child: Column(children: children),
    );
  }

  Widget _buildToggle({
    required IconData icon,
    required String title,
    String? subtitle,
    required bool value,
    required ValueChanged<bool>? onChanged,
    required bool isDark,
  }) {
    final isDisabled = onChanged == null;
    return Padding(
      padding:
          const EdgeInsets.symmetric(horizontal: AlhaiSpacing.md, vertical: 10),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AlhaiColors.primary
                  .withValues(alpha: isDisabled ? 0.05 : 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon,
                size: 18,
                color: isDisabled ? Colors.grey : AlhaiColors.primary),
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
                    color: isDisabled
                        ? (isDark ? Colors.white24 : Colors.black26)
                        : (isDark ? Colors.white : Colors.black87),
                  ),
                ),
                if (subtitle != null)
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: isDisabled
                          ? (isDark ? Colors.white12 : Colors.black12)
                          : (isDark
                              ? Colors.white38
                              : Theme.of(context).colorScheme.outline),
                    ),
                  ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeTrackColor: AlhaiColors.primary,
            activeThumbColor: isDark ? Colors.black : Colors.white,
          ),
        ],
      ),
    );
  }

  Widget _divider(bool isDark) {
    return Divider(
      height: 1,
      indent: 66,
      color: isDark
          ? Colors.white.withValues(alpha: 0.06)
          : Theme.of(context).colorScheme.surfaceContainerLow,
    );
  }
}
