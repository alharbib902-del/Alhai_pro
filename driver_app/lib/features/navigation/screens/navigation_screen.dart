import 'package:alhai_design_system/alhai_design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../deliveries/providers/delivery_providers.dart';
import '../../deliveries/widgets/delivery_status_badge.dart';

class NavigationScreen extends ConsumerStatefulWidget {
  final String deliveryId;

  const NavigationScreen({super.key, required this.deliveryId});

  @override
  ConsumerState<NavigationScreen> createState() => _NavigationScreenState();
}

class _NavigationScreenState extends ConsumerState<NavigationScreen> {
  GoogleMapController? _mapController;

  @override
  Widget build(BuildContext context) {
    final delivery = ref.watch(deliveryByIdProvider(widget.deliveryId));
    final theme = Theme.of(context);

    return delivery.when(
      data: (data) {
        if (data == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('الملاحة')),
            body: const Center(child: Text('لم يتم العثور على التوصيل')),
          );
        }

        final status = data['status'] as String? ?? '';
        final pickupLat = (data['pickup_lat'] as num?)?.toDouble();
        final pickupLng = (data['pickup_lng'] as num?)?.toDouble();
        final deliveryLat = (data['delivery_lat'] as num?)?.toDouble();
        final deliveryLng = (data['delivery_lng'] as num?)?.toDouble();

        // Determine destination based on status
        final bool isHeadingToCustomer =
            ['picked_up', 'heading_to_customer', 'arrived_at_customer']
                .contains(status);

        final destLat = isHeadingToCustomer ? deliveryLat : pickupLat;
        final destLng = isHeadingToCustomer ? deliveryLng : pickupLng;
        final destLabel = isHeadingToCustomer ? 'موقع العميل' : 'موقع المتجر';
        final address = data['delivery_address'] as String? ?? '';

        // Build markers
        final markers = <Marker>{};
        if (pickupLat != null && pickupLng != null) {
          markers.add(Marker(
            markerId: const MarkerId('pickup'),
            position: LatLng(pickupLat, pickupLng),
            icon: BitmapDescriptor.defaultMarkerWithHue(
                BitmapDescriptor.hueBlue),
            infoWindow: const InfoWindow(title: 'المتجر'),
          ));
        }
        if (deliveryLat != null && deliveryLng != null) {
          markers.add(Marker(
            markerId: const MarkerId('delivery'),
            position: LatLng(deliveryLat, deliveryLng),
            icon: BitmapDescriptor.defaultMarkerWithHue(
                BitmapDescriptor.hueRed),
            infoWindow: const InfoWindow(title: 'العميل'),
          ));
        }

        // Initial camera position
        final initialTarget = destLat != null && destLng != null
            ? LatLng(destLat, destLng)
            : const LatLng(24.7136, 46.6753); // Riyadh default

        return Scaffold(
          body: Stack(
            children: [
              // Map
              GoogleMap(
                initialCameraPosition: CameraPosition(
                  target: initialTarget,
                  zoom: 14,
                ),
                markers: markers,
                myLocationEnabled: true,
                myLocationButtonEnabled: true,
                zoomControlsEnabled: false,
                onMapCreated: (controller) {
                  _mapController = controller;
                  // Fit bounds to show all markers
                  if (markers.length > 1) {
                    _fitBounds(markers);
                  }
                },
              ),

              // Top bar
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(AlhaiSpacing.md),
                  child: Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: theme.colorScheme.surface,
                        child: IconButton(
                          icon: const Icon(Icons.arrow_back),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ),
                      const SizedBox(width: AlhaiSpacing.xs),
                      DeliveryStatusBadge(status: status),
                    ],
                  ),
                ),
              ),

              // Bottom sheet with destination info
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: Container(
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(20),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 10,
                        offset: const Offset(0, -2),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(AlhaiSpacing.mdl),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Handle
                      Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: theme.colorScheme.outline.withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(height: AlhaiSpacing.md),
                      Row(
                        children: [
                          Icon(Icons.location_on,
                              color: theme.colorScheme.primary),
                          const SizedBox(width: AlhaiSpacing.xs),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  destLabel,
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                if (address.isNotEmpty)
                                  Text(
                                    address,
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: theme.colorScheme.outline,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AlhaiSpacing.md),
                      // Open in Google Maps button
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton.icon(
                          onPressed: destLat != null && destLng != null
                              ? () => _openInGoogleMaps(destLat, destLng)
                              : null,
                          icon: const Icon(Icons.navigation_rounded),
                          label: const Text('فتح في خرائط قوقل'),
                          style: FilledButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
      loading: () => Scaffold(
        appBar: AppBar(title: const Text('الملاحة')),
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => Scaffold(
        appBar: AppBar(title: const Text('الملاحة')),
        body: Center(child: Text('خطأ: $e')),
      ),
    );
  }

  void _fitBounds(Set<Marker> markers) {
    if (_mapController == null || markers.length < 2) return;

    double minLat = 90, maxLat = -90, minLng = 180, maxLng = -180;
    for (final m in markers) {
      if (m.position.latitude < minLat) minLat = m.position.latitude;
      if (m.position.latitude > maxLat) maxLat = m.position.latitude;
      if (m.position.longitude < minLng) minLng = m.position.longitude;
      if (m.position.longitude > maxLng) maxLng = m.position.longitude;
    }

    _mapController!.animateCamera(
      CameraUpdate.newLatLngBounds(
        LatLngBounds(
          southwest: LatLng(minLat - 0.01, minLng - 0.01),
          northeast: LatLng(maxLat + 0.01, maxLng + 0.01),
        ),
        60,
      ),
    );
  }

  Future<void> _openInGoogleMaps(double lat, double lng) async {
    final uri = Uri.parse(
        'google.navigation:q=$lat,$lng&mode=d');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      final webUri = Uri.parse(
          'https://www.google.com/maps/dir/?api=1&destination=$lat,$lng&travelmode=driving');
      await launchUrl(webUri, mode: LaunchMode.externalApplication);
    }
  }
}
