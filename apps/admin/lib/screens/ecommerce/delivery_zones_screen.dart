import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:alhai_shared_ui/alhai_shared_ui.dart';
import 'package:uuid/uuid.dart';
import 'package:alhai_design_system/alhai_design_system.dart';
import 'package:alhai_l10n/alhai_l10n.dart';

/// شاشة إدارة مناطق التوصيل وأسعارها
class DeliveryZonesScreen extends ConsumerStatefulWidget {
  const DeliveryZonesScreen({super.key});

  @override
  ConsumerState<DeliveryZonesScreen> createState() => _DeliveryZonesScreenState();
}

class _DeliveryZonesScreenState extends ConsumerState<DeliveryZonesScreen> {
  final List<_DeliveryZone> _zones = [
    _DeliveryZone(id: '1', name: 'داخل المدينة', minKm: 0, maxKm: 5, fee: 10, minOrder: 50, estimatedMinutes: 30),
    _DeliveryZone(id: '2', name: 'ضواحي المدينة', minKm: 5, maxKm: 15, fee: 20, minOrder: 80, estimatedMinutes: 45),
    _DeliveryZone(id: '3', name: 'خارج المدينة', minKm: 15, maxKm: 30, fee: 35, minOrder: 120, estimatedMinutes: 60),
    _DeliveryZone(id: '4', name: 'مناطق بعيدة', minKm: 30, maxKm: 100, fee: 60, minOrder: 200, estimatedMinutes: 90),
  ];

  void _showAddZoneDialog({_DeliveryZone? existing}) {
    final isEdit = existing != null;
    final nameController = TextEditingController(text: existing?.name ?? '');
    final feeController = TextEditingController(text: existing?.fee.toStringAsFixed(0) ?? '');
    final minOrderController = TextEditingController(text: existing?.minOrder.toStringAsFixed(0) ?? '');
    final minKmController = TextEditingController(text: existing?.minKm.toStringAsFixed(0) ?? '');
    final maxKmController = TextEditingController(text: existing?.maxKm.toStringAsFixed(0) ?? '');
    final etaController = TextEditingController(text: existing?.estimatedMinutes.toString() ?? '30');

    final l10n = AppLocalizations.of(context);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(isEdit ? l10n.editDeliveryZone : l10n.addDeliveryZoneTitle),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: l10n.zoneName,
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.place_rounded),
                ),
              ),
              const SizedBox(height: AlhaiSpacing.sm),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: minKmController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: l10n.fromKm,
                        border: const OutlineInputBorder(),
                        suffixText: l10n.kmUnit,
                      ),
                    ),
                  ),
                  const SizedBox(width: AlhaiSpacing.xs),
                  Expanded(
                    child: TextField(
                      controller: maxKmController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: l10n.toKm,
                        border: const OutlineInputBorder(),
                        suffixText: l10n.kmUnit,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AlhaiSpacing.sm),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: feeController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: l10n.deliveryFee,
                        border: const OutlineInputBorder(),
                        suffixText: l10n.sarSuffix,
                      ),
                    ),
                  ),
                  const SizedBox(width: AlhaiSpacing.xs),
                  Expanded(
                    child: TextField(
                      controller: minOrderController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: l10n.minOrderAmount,
                        border: const OutlineInputBorder(),
                        suffixText: l10n.sarSuffix,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AlhaiSpacing.sm),
              TextField(
                controller: etaController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: l10n.estimatedDeliveryTime,
                  border: const OutlineInputBorder(),
                  suffixText: l10n.minuteUnit,
                  prefixIcon: const Icon(Icons.timer_outlined),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text(l10n.cancel)),
          FilledButton(
            onPressed: () {
              final name = nameController.text.trim();
              final fee = double.tryParse(feeController.text) ?? 0;
              final minOrder = double.tryParse(minOrderController.text) ?? 0;
              final minKm = double.tryParse(minKmController.text) ?? 0;
              final maxKm = double.tryParse(maxKmController.text) ?? 0;
              final eta = int.tryParse(etaController.text) ?? 30;

              if (name.isEmpty) return;

              final zone = _DeliveryZone(
                id: existing?.id ?? const Uuid().v4(),
                name: name,
                minKm: minKm,
                maxKm: maxKm,
                fee: fee,
                minOrder: minOrder,
                estimatedMinutes: eta,
                isActive: existing?.isActive ?? true,
              );

              setState(() {
                if (isEdit) {
                  final idx = _zones.indexWhere((z) => z.id == existing.id);
                  if (idx >= 0) _zones[idx] = zone;
                } else {
                  _zones.add(zone);
                }
              });

              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(isEdit ? l10n.zoneUpdated : l10n.zoneAdded),
                  backgroundColor: AppColors.success,
                ),
              );
            },
            child: Text(isEdit ? l10n.save : l10n.add),
          ),
        ],
      ),
    );
  }

  void _deleteZone(String id) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(AppLocalizations.of(context).deleteZone),
        content: Text(AppLocalizations.of(context).deleteZoneConfirm),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text(AppLocalizations.of(context).cancel)),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.error),
            onPressed: () {
              setState(() => _zones.removeWhere((z) => z.id == id));
              Navigator.pop(ctx);
            },
            child: Text(AppLocalizations.of(context).delete),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Sort zones by minKm
    final sorted = List.of(_zones)..sort((a, b) => a.minKm.compareTo(b.minKm));

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context).deliveryZones),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_location_alt_rounded),
            onPressed: _showAddZoneDialog,
            tooltip: AppLocalizations.of(context).addDeliveryZone,
          ),
        ],
      ),
      body: Column(
        children: [
          // Summary cards
          Container(
            padding: const EdgeInsets.all(AlhaiSpacing.md),
            color: Theme.of(context).colorScheme.primaryContainer,
            child: Row(
              children: [
                Expanded(child: _SummaryCard(
                  label: AppLocalizations.of(context).activeZones,
                  value: '${sorted.where((z) => z.isActive).length}',
                  icon: Icons.check_circle_outline,
                  color: AppColors.success,
                )),
                const SizedBox(width: AlhaiSpacing.xs),
                Expanded(child: _SummaryCard(
                  label: AppLocalizations.of(context).lowestFee,
                  value: sorted.isNotEmpty
                      ? '${sorted.map((z) => z.fee).reduce((a, b) => a < b ? a : b).toStringAsFixed(0)} ${AppLocalizations.of(context).sarSuffix}'
                      : '-',
                  icon: Icons.local_shipping_outlined,
                  color: AppColors.info,
                )),
                const SizedBox(width: AlhaiSpacing.xs),
                Expanded(child: _SummaryCard(
                  label: AppLocalizations.of(context).highestFee,
                  value: sorted.isNotEmpty
                      ? '${sorted.map((z) => z.fee).reduce((a, b) => a > b ? a : b).toStringAsFixed(0)} ${AppLocalizations.of(context).sarSuffix}'
                      : '-',
                  icon: Icons.arrow_upward_rounded,
                  color: AppColors.warning,
                )),
              ],
            ),
          ),

          // Zone list
          Expanded(
            child: sorted.isEmpty
                ? AppEmptyState(
                    icon: Icons.map_outlined,
                    title: AppLocalizations.of(context).noDeliveryZones,
                    description: AppLocalizations.of(context).addDeliveryZonesDescription,
                    actionText: AppLocalizations.of(context).addDeliveryZone,
                    onAction: _showAddZoneDialog,
                    actionIcon: Icons.add_location_alt_rounded,
                  )
                : ListView.separated(
                    padding: const EdgeInsets.all(AlhaiSpacing.md),
                    itemCount: sorted.length,
                    separatorBuilder: (_, __) => const SizedBox(height: AlhaiSpacing.xs),
                    itemBuilder: (ctx, i) {
                      final zone = sorted[i];
                      return Card(
                        child: Padding(
                          padding: const EdgeInsets.all(AlhaiSpacing.md),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(AlhaiSpacing.xs),
                                    decoration: BoxDecoration(
                                      color: zone.isActive
                                          ? AppColors.success.withValues(alpha: 0.1)
                                          : Theme.of(context).colorScheme.surfaceContainerLowest,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Icon(
                                      Icons.place_rounded,
                                      color: zone.isActive ? AppColors.success : Theme.of(context).colorScheme.outline,
                                      size: 20,
                                    ),
                                  ),
                                  const SizedBox(width: AlhaiSpacing.sm),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(zone.name,
                                            style: const TextStyle(
                                                fontSize: 15, fontWeight: FontWeight.bold)),
                                        Text(
                                          '${zone.minKm.toStringAsFixed(0)} - ${zone.maxKm.toStringAsFixed(0)} ${AppLocalizations.of(context).kmUnit}',
                                          style: TextStyle(color: Theme.of(context).hintColor, fontSize: 12),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Switch(
                                    value: zone.isActive,
                                    onChanged: (v) {
                                      setState(() {
                                        final idx = _zones.indexWhere((z) => z.id == zone.id);
                                        if (idx >= 0) {
                                          _zones[idx] = _zones[idx].copyWith(isActive: v);
                                        }
                                      });
                                    },
                                  ),
                                ],
                              ),
                              const SizedBox(height: AlhaiSpacing.sm),
                              Row(
                                children: [
                                  _InfoChip(
                                    icon: Icons.local_shipping_outlined,
                                    label: AppLocalizations.of(context).deliveryFee,
                                    value: '${zone.fee.toStringAsFixed(0)} ${AppLocalizations.of(context).sarSuffix}',
                                    color: AppColors.info,
                                  ),
                                  const SizedBox(width: AlhaiSpacing.xs),
                                  _InfoChip(
                                    icon: Icons.shopping_bag_outlined,
                                    label: AppLocalizations.of(context).minOrderAmount,
                                    value: '${zone.minOrder.toStringAsFixed(0)} ${AppLocalizations.of(context).sarSuffix}',
                                    color: Colors.purple, // zone detail color
                                  ),
                                  const SizedBox(width: AlhaiSpacing.xs),
                                  _InfoChip(
                                    icon: Icons.timer_outlined,
                                    label: AppLocalizations.of(context).deliveryTime,
                                    value: '${zone.estimatedMinutes} ${AppLocalizations.of(context).minuteAbbr}',
                                    color: AppColors.warning,
                                  ),
                                ],
                              ),
                              const SizedBox(height: AlhaiSpacing.xs),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  TextButton.icon(
                                    onPressed: () => _showAddZoneDialog(existing: zone),
                                    icon: const Icon(Icons.edit_outlined, size: 16),
                                    label: Text(AppLocalizations.of(context).edit),
                                  ),
                                  TextButton.icon(
                                    onPressed: () => _deleteZone(zone.id),
                                    icon: Icon(Icons.delete_outline, size: 16, color: AppColors.error),
                                    label: Text(AppLocalizations.of(context).delete, style: TextStyle(color: AppColors.error)),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddZoneDialog,
        icon: const Icon(Icons.add_location_alt_rounded),
        label: Text(AppLocalizations.of(context).addDeliveryZone),
      ),
    );
  }
}

// ─── Reusable widgets ──────────────────────────────────────────────────────────

class _SummaryCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  const _SummaryCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AlhaiSpacing.sm),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: AlhaiSpacing.xxs),
          Text(value, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 15)),
          Text(label, style: TextStyle(color: Theme.of(context).hintColor, fontSize: 10)),
        ],
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  const _InfoChip({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: AlhaiSpacing.xxs),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: TextStyle(fontSize: 9, color: Theme.of(context).hintColor)),
              Text(value, style: TextStyle(fontSize: 12, color: color, fontWeight: FontWeight.bold)),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── Data classes ──────────────────────────────────────────────────────────────

class _DeliveryZone {
  final String id;
  final String name;
  final double minKm;
  final double maxKm;
  final double fee;
  final double minOrder;
  final int estimatedMinutes;
  final bool isActive;

  const _DeliveryZone({
    required this.id,
    required this.name,
    required this.minKm,
    required this.maxKm,
    required this.fee,
    required this.minOrder,
    required this.estimatedMinutes,
    this.isActive = true,
  });

  _DeliveryZone copyWith({bool? isActive}) => _DeliveryZone(
    id: id,
    name: name,
    minKm: minKm,
    maxKm: maxKm,
    fee: fee,
    minOrder: minOrder,
    estimatedMinutes: estimatedMinutes,
    isActive: isActive ?? this.isActive,
  );
}
