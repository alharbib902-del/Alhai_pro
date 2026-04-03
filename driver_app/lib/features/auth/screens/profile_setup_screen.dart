import 'package:alhai_design_system/alhai_design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';

import '../../../core/providers/app_providers.dart';
import '../data/driver_auth_datasource.dart';

class ProfileSetupScreen extends ConsumerStatefulWidget {
  const ProfileSetupScreen({super.key});

  @override
  ConsumerState<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends ConsumerState<ProfileSetupScreen> {
  final _nameController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  String _vehicleType = 'car';
  bool _isLoading = false;

  static const _vehicleTypes = [
    ('car', 'سيارة', Icons.directions_car_rounded),
    ('motorcycle', 'دراجة نارية', Icons.two_wheeler_rounded),
    ('bicycle', 'دراجة هوائية', Icons.pedal_bike_rounded),
    ('van', 'فان', Icons.airport_shuttle_rounded),
  ];

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final datasource = GetIt.instance<DriverAuthDatasource>();
      await datasource.updateProfile(
        name: _nameController.text.trim(),
        vehicleType: _vehicleType,
      );

      // Reload profile
      final user = await datasource.getCurrentUser();
      ref.read(currentDriverProvider.notifier).state = user;

      if (mounted) context.go('/home');
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('فشل الحفظ: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('إعداد الملف الشخصي'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AlhaiSpacing.lg),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Avatar
              Center(
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.person_rounded,
                    size: 52,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ),
              const SizedBox(height: AlhaiSpacing.xl),

              // Name
              TextFormField(
                controller: _nameController,
                textCapitalization: TextCapitalization.words,
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'أدخل اسمك' : null,
                decoration: InputDecoration(
                  labelText: 'الاسم الكامل',
                  prefixIcon: const Icon(Icons.person_outline),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: AlhaiSpacing.lg),

              // Vehicle type
              Text(
                'نوع المركبة',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: AlhaiSpacing.sm),
              Wrap(
                spacing: AlhaiSpacing.sm,
                runSpacing: AlhaiSpacing.sm,
                children: _vehicleTypes.map((type) {
                  final isSelected = _vehicleType == type.$1;
                  return ChoiceChip(
                    selected: isSelected,
                    onSelected: (_) =>
                        setState(() => _vehicleType = type.$1),
                    avatar: Icon(
                      type.$3,
                      size: 20,
                      color: isSelected
                          ? theme.colorScheme.onPrimaryContainer
                          : theme.colorScheme.outline,
                    ),
                    label: Text(type.$2),
                    selectedColor: theme.colorScheme.primaryContainer,
                  );
                }).toList(),
              ),

              const SizedBox(height: AlhaiSpacing.xxl),

              FilledButton(
                onPressed: _isLoading ? null : _saveProfile,
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: AlhaiSpacing.md),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('ابدأ العمل', style: TextStyle(fontSize: 16)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
