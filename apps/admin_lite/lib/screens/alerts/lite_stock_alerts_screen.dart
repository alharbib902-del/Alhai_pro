/// Lite Stock Alerts Screen
///
/// Dedicated screen for stock-related alerts:
/// low stock, out of stock, and expiring products.
/// Supports RTL, dark mode, and responsive layouts.
library;

import 'package:flutter/material.dart';
import 'package:alhai_l10n/alhai_l10n.dart';
import 'package:alhai_design_system/alhai_design_system.dart';

/// Stock alerts screen for Admin Lite
class LiteStockAlertsScreen extends StatefulWidget {
  const LiteStockAlertsScreen({super.key});

  @override
  State<LiteStockAlertsScreen> createState() => _LiteStockAlertsScreenState();
}

class _LiteStockAlertsScreenState extends State<LiteStockAlertsScreen> {
  int _filterIndex = 0;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final size = MediaQuery.of(context).size;
    final isMobile = size.width < 600;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.lowStock),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Filter tabs
          _buildFilterTabs(isDark, l10n),

          // Alerts list
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.all(isMobile ? AlhaiSpacing.md : AlhaiSpacing.lg),
              itemCount: _getFilteredAlerts().length,
              itemBuilder: (context, index) {
                return _buildAlertTile(context, _getFilteredAlerts()[index], isDark);
              },
            ),
          ),
        ],
      ),
    );
  }

  List<_StockAlert> _getFilteredAlerts() {
    switch (_filterIndex) {
      case 1:
        return _alerts.where((a) => a.type == _AlertType.outOfStock).toList();
      case 2:
        return _alerts.where((a) => a.type == _AlertType.lowStock).toList();
      case 3:
        return _alerts.where((a) => a.type == _AlertType.expiring).toList();
      default:
        return _alerts;
    }
  }

  Widget _buildFilterTabs(bool isDark, AppLocalizations l10n) {
    final filters = [l10n.all, l10n.outOfStock, l10n.lowStock, l10n.products];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AlhaiSpacing.md, vertical: AlhaiSpacing.xs),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.03) : Theme.of(context).colorScheme.surfaceContainerLowest,
        border: Border(
          bottom: BorderSide(
            color: isDark ? Colors.white12 : Theme.of(context).colorScheme.outlineVariant,
          ),
        ),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: filters.asMap().entries.map((entry) {
            final isSelected = _filterIndex == entry.key;
            return Padding(
              padding: const EdgeInsetsDirectional.only(end: AlhaiSpacing.xs),
              child: FilterChip(
                label: Text(entry.value),
                selected: isSelected,
                onSelected: (_) => setState(() => _filterIndex = entry.key),
                selectedColor: AlhaiColors.primary.withValues(alpha: 0.15),
                checkmarkColor: AlhaiColors.primary,
                labelStyle: TextStyle(
                  color: isSelected
                      ? AlhaiColors.primary
                      : (isDark ? Colors.white70 : Theme.of(context).colorScheme.onSurface),
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  fontSize: 13,
                ),
                side: BorderSide(
                  color: isSelected ? AlhaiColors.primary : (isDark ? Colors.white24 : Theme.of(context).colorScheme.outlineVariant),
                ),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildAlertTile(BuildContext context, _StockAlert alert, bool isDark) {
    final color = switch (alert.type) {
      _AlertType.outOfStock => AlhaiColors.error,
      _AlertType.lowStock => AlhaiColors.warning,
      _AlertType.expiring => Colors.orange,
    };
    final icon = switch (alert.type) {
      _AlertType.outOfStock => Icons.error_outline,
      _AlertType.lowStock => Icons.warning_amber,
      _AlertType.expiring => Icons.calendar_today,
    };

    return Container(
      margin: const EdgeInsets.only(bottom: AlhaiSpacing.xs),
      padding: const EdgeInsets.all(AlhaiSpacing.sm),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.06) : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark ? Colors.white12 : Theme.of(context).colorScheme.outlineVariant,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: AlhaiSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  alert.productName,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                const SizedBox(height: AlhaiSpacing.xxxs),
                Text(
                  alert.description,
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? Colors.white38 : Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: AlhaiSpacing.xs, vertical: AlhaiSpacing.xxxs),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              alert.badge,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }

  static const _alerts = [
    _StockAlert('Rice 5kg', '0 units in stock', '0', _AlertType.outOfStock),
    _StockAlert('Lentils 1kg', '0 units in stock', '0', _AlertType.outOfStock),
    _StockAlert('Sugar 2kg', '2 units remaining', '2', _AlertType.lowStock),
    _StockAlert('Cheese 200g', '1 unit remaining', '1', _AlertType.lowStock),
    _StockAlert('Cooking Oil 1L', '3 units remaining', '3', _AlertType.lowStock),
    _StockAlert('Yogurt 500ml', 'Expires in 3 days', '3d', _AlertType.expiring),
    _StockAlert('Fresh Juice 1L', 'Expires in 5 days', '5d', _AlertType.expiring),
    _StockAlert('Bread Loaf', 'Expires tomorrow', '1d', _AlertType.expiring),
  ];
}

enum _AlertType { outOfStock, lowStock, expiring }

class _StockAlert {
  final String productName;
  final String description;
  final String badge;
  final _AlertType type;
  const _StockAlert(this.productName, this.description, this.badge, this.type);
}
