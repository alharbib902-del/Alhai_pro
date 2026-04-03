import 'package:alhai_design_system/alhai_design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:alhai_core/alhai_core.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import '../providers/tracking_providers.dart';
import '../widgets/delivery_timeline.dart';

class OrderTrackingScreen extends ConsumerStatefulWidget {
  final String orderId;

  const OrderTrackingScreen({super.key, required this.orderId});

  @override
  ConsumerState<OrderTrackingScreen> createState() =>
      _OrderTrackingScreenState();
}

class _OrderTrackingScreenState extends ConsumerState<OrderTrackingScreen> {
  GoogleMapController? _mapController;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final deliveryAsync = ref.watch(deliveryTrackingProvider(widget.orderId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('تتبع الطلب'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: deliveryAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => _WaitingForDriver(),
        data: (delivery) {
          // Watch driver location if available
          final driverLocationAsync = delivery.driverId.isNotEmpty
              ? ref.watch(driverLocationProvider(delivery.driverId))
              : null;

          // Build markers
          final markers = <Marker>{};

          // Delivery destination marker
          if (delivery.deliveryAddress.lat != 0) {
            markers.add(Marker(
              markerId: const MarkerId('destination'),
              position: LatLng(
                delivery.deliveryAddress.lat,
                delivery.deliveryAddress.lng,
              ),
              icon: BitmapDescriptor.defaultMarkerWithHue(
                  BitmapDescriptor.hueRed),
              infoWindow: const InfoWindow(title: 'عنوان التوصيل'),
            ));
          }

          // Driver location marker (real-time)
          double? driverLat;
          double? driverLng;

          if (driverLocationAsync != null) {
            driverLocationAsync.whenData((loc) {
              if (loc != null) {
                driverLat = (loc['lat'] as num?)?.toDouble();
                driverLng = (loc['lng'] as num?)?.toDouble();
              }
            });
          }

          // Fallback to delivery record's driver position
          driverLat ??= delivery.driverLat;
          driverLng ??= delivery.driverLng;

          if (driverLat != null && driverLng != null) {
            markers.add(Marker(
              markerId: const MarkerId('driver'),
              position: LatLng(driverLat!, driverLng!),
              icon: BitmapDescriptor.defaultMarkerWithHue(
                  BitmapDescriptor.hueBlue),
              infoWindow: InfoWindow(
                  title: delivery.driverName ?? 'السائق'),
            ));
          }

          final initialTarget = driverLat != null && driverLng != null
              ? LatLng(driverLat!, driverLng!)
              : delivery.deliveryAddress.lat != 0
                  ? LatLng(
                      delivery.deliveryAddress.lat,
                      delivery.deliveryAddress.lng,
                    )
                  : const LatLng(24.7136, 46.6753);

          return Column(
            children: [
              // Map
              Expanded(
                flex: 3,
                child: GoogleMap(
                  initialCameraPosition: CameraPosition(
                    target: initialTarget,
                    zoom: 14,
                  ),
                  markers: markers,
                  myLocationEnabled: true,
                  zoomControlsEnabled: false,
                  onMapCreated: (controller) {
                    _mapController = controller;
                  },
                ),
              ),

              // Bottom info panel
              Expanded(
                flex: 2,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(AlhaiSpacing.md),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Delivery status timeline
                      DeliveryTimeline(status: delivery.status),
                      const SizedBox(height: AlhaiSpacing.sm),

                      // Driver info card
                      Card(
                        child: Column(
                          children: [
                            ListTile(
                              leading: CircleAvatar(
                                backgroundColor:
                                    theme.colorScheme.primaryContainer,
                                child: Text(
                                  delivery.driverName?.isNotEmpty == true
                                      ? delivery.driverName![0]
                                      : '?',
                                  style: TextStyle(
                                    color: theme.colorScheme.primary,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              title: Text(delivery.driverName ?? 'السائق'),
                              subtitle: Text(delivery.status.displayNameAr),
                            ),
                            if (delivery.driverPhone != null)
                              Padding(
                                padding: const EdgeInsets.fromLTRB(
                                    AlhaiSpacing.md, 0, AlhaiSpacing.md, AlhaiSpacing.sm),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: OutlinedButton.icon(
                                        onPressed: () =>
                                            _callDriver(delivery.driverPhone!),
                                        icon: const Icon(Icons.call),
                                        label: const Text('اتصال'),
                                      ),
                                    ),
                                    const SizedBox(width: AlhaiSpacing.xs),
                                    Expanded(
                                      child: OutlinedButton.icon(
                                        onPressed: () {
                                          context.push(
                                              '/orders/${widget.orderId}/chat');
                                        },
                                        icon: const Icon(Icons.chat_bubble_outline),
                                        label: const Text('محادثة'),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _callDriver(String phone) async {
    final uri = Uri.parse('tel:$phone');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }
}

class _WaitingForDriver extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.delivery_dining,
              size: 64, color: theme.colorScheme.outline),
          const SizedBox(height: AlhaiSpacing.md),
          Text(
            'في انتظار تعيين سائق',
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.outline,
            ),
          ),
          const SizedBox(height: AlhaiSpacing.xs),
          Text(
            'سيتم إشعارك عند تعيين سائق لطلبك',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.outline,
            ),
          ),
        ],
      ),
    );
  }
}
