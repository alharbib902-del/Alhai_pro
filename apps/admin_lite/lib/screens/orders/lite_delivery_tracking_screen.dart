/// Lite Delivery Tracking Screen
///
/// Shows active deliveries with driver info, ETA,
/// and status updates. Placeholder for map integration.
/// Supports RTL, dark mode, and responsive layouts.
library;

import 'package:flutter/material.dart';
import 'package:alhai_l10n/alhai_l10n.dart';
import 'package:alhai_design_system/alhai_design_system.dart';

/// Delivery tracking screen for Admin Lite
class LiteDeliveryTrackingScreen extends StatelessWidget {
  const LiteDeliveryTrackingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final size = MediaQuery.of(context).size;
    final isMobile = size.width < 600;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.delivery),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Map placeholder
          _buildMapPlaceholder(context, isDark, l10n),

          // Active deliveries
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.all(isMobile ? AlhaiSpacing.md : AlhaiSpacing.lg),
              itemCount: _deliveries.length,
              itemBuilder: (context, index) {
                return _buildDeliveryCard(context, _deliveries[index], isDark);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMapPlaceholder(BuildContext context, bool isDark, AppLocalizations l10n) {
    return Container(
      height: 180,
      width: double.infinity,
      color: isDark ? Colors.white.withValues(alpha: 0.04) : Colors.grey.shade100,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.map_outlined,
              size: 48,
              color: isDark ? Colors.white24 : Colors.grey.shade400,
            ),
            const SizedBox(height: AlhaiSpacing.xs),
            Text(
              l10n.trackingMap,
              style: TextStyle(
                fontSize: 14,
                color: isDark ? Colors.white38 : Colors.grey.shade500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDeliveryCard(BuildContext context, _DeliveryData delivery, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: AlhaiSpacing.sm),
      padding: const EdgeInsets.all(AlhaiSpacing.md),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.06) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? Colors.white12 : Theme.of(context).colorScheme.outlineVariant,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: AlhaiColors.primary.withValues(alpha: 0.15),
                child: Text(
                  delivery.driverName.substring(0, 1),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AlhaiColors.primary,
                  ),
                ),
              ),
              const SizedBox(width: AlhaiSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      delivery.driverName,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                    Text(
                      delivery.orderNumber,
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? Colors.white38 : Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: AlhaiSpacing.xxxs),
                decoration: BoxDecoration(
                  color: delivery.statusColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  delivery.status,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: delivery.statusColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AlhaiSpacing.md),

          // Delivery details
          Row(
            children: [
              _DetailChip(Icons.person, delivery.customerName, isDark, context),
              const SizedBox(width: AlhaiSpacing.xs),
              _DetailChip(Icons.access_time, delivery.eta, isDark, context),
            ],
          ),
          const SizedBox(height: AlhaiSpacing.xs),
          Row(
            children: [
              Icon(Icons.location_on, size: 14, color: isDark ? Colors.white24 : Colors.black38),
              const SizedBox(width: AlhaiSpacing.xxs),
              Expanded(
                child: Text(
                  delivery.address,
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? Colors.white38 : Colors.black45,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  static const _deliveries = [
    _DeliveryData(
      driverName: 'Mohammed Ali',
      orderNumber: '#ORD-1049',
      customerName: 'Fatima Nasser',
      address: 'Riyadh, Al-Malaz, Building 12',
      eta: 'ETA 15 min',
      status: 'On Route',
      statusColor: AlhaiColors.primary,
    ),
    _DeliveryData(
      driverName: 'Khalid Salem',
      orderNumber: '#ORD-1048',
      customerName: 'Khalid Ibrahim',
      address: 'Riyadh, Al-Olaya, Tower 5',
      eta: 'ETA 25 min',
      status: 'Picked Up',
      statusColor: AlhaiColors.info,
    ),
    _DeliveryData(
      driverName: 'Ahmed Omar',
      orderNumber: '#ORD-1046',
      customerName: 'Sara Al-Hassan',
      address: 'Riyadh, Al-Nakheel, Villa 8',
      eta: 'Delivered',
      status: 'Completed',
      statusColor: AlhaiColors.success,
    ),
  ];
}

class _DetailChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isDark;
  final BuildContext parentContext;

  const _DetailChip(this.icon, this.label, this.isDark, this.parentContext);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AlhaiSpacing.xs, vertical: AlhaiSpacing.xxxs),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.06) : Theme.of(parentContext).colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: isDark ? Colors.white38 : Theme.of(parentContext).colorScheme.onSurfaceVariant),
          const SizedBox(width: AlhaiSpacing.xxs),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: isDark ? Colors.white54 : Theme.of(parentContext).colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}

class _DeliveryData {
  final String driverName;
  final String orderNumber;
  final String customerName;
  final String address;
  final String eta;
  final String status;
  final Color statusColor;

  const _DeliveryData({
    required this.driverName,
    required this.orderNumber,
    required this.customerName,
    required this.address,
    required this.eta,
    required this.status,
    required this.statusColor,
  });
}
