import 'package:alhai_design_system/alhai_design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:alhai_core/alhai_core.dart';

import '../providers/address_providers.dart';
import '../../../di/injection.dart';
import '../data/addresses_datasource.dart';

class AddressesScreen extends ConsumerWidget {
  const AddressesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final addressesAsync = ref.watch(addressesListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('عناويني'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddAddressDialog(context, ref),
        icon: const Icon(Icons.add),
        label: const Text('إضافة عنوان'),
      ),
      body: addressesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => const Center(child: Text('فشل تحميل العناوين')),
        data: (addresses) {
          if (addresses.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.location_off_outlined,
                      size: 64, color: theme.colorScheme.outline),
                  const SizedBox(height: AlhaiSpacing.md),
                  Text('لا توجد عناوين', style: theme.textTheme.titleMedium),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(AlhaiSpacing.md),
            itemCount: addresses.length,
            itemBuilder: (context, index) {
              final address = addresses[index];
              return Card(
                margin: const EdgeInsets.only(bottom: AlhaiSpacing.xs),
                child: ListTile(
                  leading: Icon(
                    address.isDefault
                        ? Icons.location_on
                        : Icons.location_on_outlined,
                    color:
                        address.isDefault ? theme.colorScheme.primary : null,
                  ),
                  title: Row(
                    children: [
                      Text(address.label),
                      if (address.isDefault) ...[
                        const SizedBox(width: AlhaiSpacing.xs),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: AlhaiSpacing.xxxs,
                          ),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primaryContainer,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            'الافتراضي',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: theme.colorScheme.primary,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  subtitle: Text(
                    address.fullAddress,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: PopupMenuButton<String>(
                    onSelected: (value) async {
                      if (value == 'default') {
                        final ds = locator<AddressesDatasource>();
                        await ds.setDefaultAddress(address.id);
                        ref.invalidate(addressesListProvider);
                      } else if (value == 'delete') {
                        final ds = locator<AddressesDatasource>();
                        await ds.deleteAddress(address.id);
                        ref.invalidate(addressesListProvider);
                      }
                    },
                    itemBuilder: (context) => [
                      if (!address.isDefault)
                        const PopupMenuItem(
                          value: 'default',
                          child: Text('تعيين كافتراضي'),
                        ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Text('حذف'),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _showAddAddressDialog(BuildContext context, WidgetRef ref) {
    final labelCtrl = TextEditingController();
    final addressCtrl = TextEditingController();
    final cityCtrl = TextEditingController(text: 'الرياض');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Padding(
        padding: EdgeInsets.fromLTRB(
          AlhaiSpacing.md,
          AlhaiSpacing.md,
          AlhaiSpacing.md,
          MediaQuery.of(context).viewInsets.bottom + AlhaiSpacing.md,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'إضافة عنوان جديد',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: AlhaiSpacing.md),
            TextField(
              controller: labelCtrl,
              decoration: const InputDecoration(
                labelText: 'اسم العنوان',
                hintText: 'مثال: المنزل، العمل',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: AlhaiSpacing.sm),
            TextField(
              controller: addressCtrl,
              decoration: const InputDecoration(
                labelText: 'العنوان الكامل',
                hintText: 'الحي، الشارع، رقم المبنى',
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
            ),
            const SizedBox(height: AlhaiSpacing.sm),
            TextField(
              controller: cityCtrl,
              decoration: const InputDecoration(
                labelText: 'المدينة',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: AlhaiSpacing.md),
            FilledButton(
              onPressed: () async {
                if (labelCtrl.text.isEmpty || addressCtrl.text.isEmpty) return;

                final ds = locator<AddressesDatasource>();
                await ds.createAddress(CreateAddressParams(
                  label: labelCtrl.text,
                  fullAddress: addressCtrl.text,
                  city: cityCtrl.text,
                  lat: 24.7136, // Default Riyadh
                  lng: 46.6753,
                ));

                ref.invalidate(addressesListProvider);
                if (context.mounted) Navigator.pop(context);
              },
              child: const Text('حفظ'),
            ),
          ],
        ),
      ),
    );
  }
}
