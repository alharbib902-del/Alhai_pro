import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:alhai_shared_ui/alhai_shared_ui.dart';
import 'package:uuid/uuid.dart';

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

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(isEdit ? 'تعديل منطقة التوصيل' : 'إضافة منطقة توصيل'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'اسم المنطقة',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.place_rounded),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: minKmController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'من (كم)',
                        border: OutlineInputBorder(),
                        suffixText: 'كم',
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: maxKmController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'إلى (كم)',
                        border: OutlineInputBorder(),
                        suffixText: 'كم',
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: feeController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'رسوم التوصيل',
                        border: OutlineInputBorder(),
                        suffixText: 'ر.س',
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: minOrderController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'حد أدنى للطلب',
                        border: OutlineInputBorder(),
                        suffixText: 'ر.س',
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextField(
                controller: etaController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'وقت التوصيل التقديري',
                  border: OutlineInputBorder(),
                  suffixText: 'دقيقة',
                  prefixIcon: Icon(Icons.timer_outlined),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('إلغاء')),
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
                  content: Text(isEdit ? 'تم تحديث المنطقة' : 'تمت إضافة المنطقة'),
                  backgroundColor: AppColors.success,
                ),
              );
            },
            child: Text(isEdit ? 'حفظ' : 'إضافة'),
          ),
        ],
      ),
    );
  }

  void _deleteZone(String id) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('حذف المنطقة'),
        content: const Text('هل تريد حذف هذه المنطقة؟'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('إلغاء')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.error),
            onPressed: () {
              setState(() => _zones.removeWhere((z) => z.id == id));
              Navigator.pop(ctx);
            },
            child: const Text('حذف'),
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
        title: const Text('مناطق التوصيل'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_location_alt_rounded),
            onPressed: _showAddZoneDialog,
            tooltip: 'إضافة منطقة',
          ),
        ],
      ),
      body: Column(
        children: [
          // Summary cards
          Container(
            padding: const EdgeInsets.all(16),
            color: Theme.of(context).colorScheme.primaryContainer,
            child: Row(
              children: [
                Expanded(child: _SummaryCard(
                  label: 'مناطق نشطة',
                  value: '${sorted.where((z) => z.isActive).length}',
                  icon: Icons.check_circle_outline,
                  color: AppColors.success,
                )),
                const SizedBox(width: 8),
                Expanded(child: _SummaryCard(
                  label: 'أقل رسوم',
                  value: sorted.isNotEmpty
                      ? '${sorted.map((z) => z.fee).reduce((a, b) => a < b ? a : b).toStringAsFixed(0)} ر.س'
                      : '-',
                  icon: Icons.local_shipping_outlined,
                  color: AppColors.info,
                )),
                const SizedBox(width: 8),
                Expanded(child: _SummaryCard(
                  label: 'أعلى رسوم',
                  value: sorted.isNotEmpty
                      ? '${sorted.map((z) => z.fee).reduce((a, b) => a > b ? a : b).toStringAsFixed(0)} ر.س'
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
                ? Center(
                    child: Column(mainAxisSize: MainAxisSize.min, children: [
                      Icon(Icons.map_outlined, size: 64, color: Theme.of(context).hintColor),
                      SizedBox(height: 12),
                      Text('لا توجد مناطق توصيل', style: TextStyle(color: Theme.of(context).hintColor)),
                    ]),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: sorted.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (ctx, i) {
                      final zone = sorted[i];
                      return Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
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
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(zone.name,
                                            style: const TextStyle(
                                                fontSize: 15, fontWeight: FontWeight.bold)),
                                        Text(
                                          '${zone.minKm.toStringAsFixed(0)} - ${zone.maxKm.toStringAsFixed(0)} كم',
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
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  _InfoChip(
                                    icon: Icons.local_shipping_outlined,
                                    label: 'رسوم التوصيل',
                                    value: '${zone.fee.toStringAsFixed(0)} ر.س',
                                    color: AppColors.info,
                                  ),
                                  const SizedBox(width: 8),
                                  _InfoChip(
                                    icon: Icons.shopping_bag_outlined,
                                    label: 'حد أدنى',
                                    value: '${zone.minOrder.toStringAsFixed(0)} ر.س',
                                    color: Colors.purple, // zone detail color
                                  ),
                                  const SizedBox(width: 8),
                                  _InfoChip(
                                    icon: Icons.timer_outlined,
                                    label: 'وقت التوصيل',
                                    value: '${zone.estimatedMinutes} د',
                                    color: AppColors.warning,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  TextButton.icon(
                                    onPressed: () => _showAddZoneDialog(existing: zone),
                                    icon: const Icon(Icons.edit_outlined, size: 16),
                                    label: const Text('تعديل'),
                                  ),
                                  TextButton.icon(
                                    onPressed: () => _deleteZone(zone.id),
                                    icon: Icon(Icons.delete_outline, size: 16, color: AppColors.error),
                                    label: Text('حذف', style: TextStyle(color: AppColors.error)),
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
        label: const Text('إضافة منطقة'),
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
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 4),
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
          const SizedBox(width: 4),
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
