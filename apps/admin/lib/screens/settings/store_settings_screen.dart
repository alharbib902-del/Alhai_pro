import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:alhai_shared_ui/alhai_shared_ui.dart';
import 'package:alhai_l10n/alhai_l10n.dart';
import 'package:alhai_database/alhai_database.dart';
import 'package:alhai_core/alhai_core.dart';
import 'package:alhai_design_system/alhai_design_system.dart';

/// شاشة إعدادات المتجر - بتصميم Sidebar + Header
class StoreSettingsScreen extends ConsumerStatefulWidget {
  const StoreSettingsScreen({super.key});

  @override
  ConsumerState<StoreSettingsScreen> createState() =>
      _StoreSettingsScreenState();
}

class _StoreSettingsScreenState extends ConsumerState<StoreSettingsScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  final _phoneController = TextEditingController();
  final _vatController = TextEditingController();
  final _crController = TextEditingController();

  String _currency = 'SAR';
  String _language = 'ar';
  bool _enableVat = true;
  double _vatRate = 15.0;
  bool _isLoading = true;
  bool _isSaving = false;

  String? _currentStoreId;

  @override
  void initState() {
    super.initState();
    _loadStoreData();
  }

  Future<void> _loadStoreData() async {
    final storeId = ref.read(currentStoreIdProvider);
    if (storeId == null) {
      if (mounted) setState(() => _isLoading = false);
      return;
    }
    _currentStoreId = storeId;
    final db = getIt<AppDatabase>();
    final store = await db.storesDao.getStoreById(storeId);
    if (store != null && mounted) {
      setState(() {
        _nameController.text = store.name;
        _addressController.text = store.address ?? '';
        _phoneController.text = store.phone ?? '';
        _vatController.text = store.taxNumber ?? '';
        _crController.text = store.commercialReg ?? '';
        _currency = store.currency;
        _isLoading = false;
      });
    } else if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    _vatController.dispose();
    _crController.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isWideScreen = size.width >= 1200;
    final isMediumScreen = size.width >= 600;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context);
    final padding = size.width < 600 ? 12.0 : isWideScreen ? 24.0 : 16.0;

    return Column(
              children: [
                AppHeader(
                  title: l10n.storeSettings,
                  onMenuTap: isWideScreen
                      ? null
                      : () => Scaffold.of(context).openDrawer(),
                  onNotificationsTap: () => context.push('/notifications'),
                  notificationsCount: 3,
                  userName: l10n.defaultUserName,
                  userRole: l10n.branchManager,
                ),
                Expanded(
                  child: _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : SingleChildScrollView(
                          padding: EdgeInsets.all(padding),
                          child: Center(
                            child: ConstrainedBox(
                              constraints: BoxConstraints(maxWidth: isWideScreen ? 800 : double.infinity),
                              child: Form(
                                key: _formKey,
                                child: _buildContent(
                                    isWideScreen, isMediumScreen, isDark, l10n),
                              ),
                            ),
                          ),
                        ),
                ),
              ],
            );
  }
  Widget _buildContent(
      bool isWideScreen, bool isMediumScreen, bool isDark, AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildPageHeader(isDark, l10n),
        const SizedBox(height: AlhaiSpacing.mdl),

        _buildSettingsGroup(l10n.storeInfo, Icons.store_rounded,
            AppColors.primary, isDark, [
          Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(AlhaiSpacing.mdl, AlhaiSpacing.xs, AlhaiSpacing.mdl, AlhaiSpacing.xs),
            child: TextFormField(
              controller: _nameController,
              maxLength: 100,
              validator: FormValidators.requiredField(maxLength: 100),
              decoration: InputDecoration(
                labelText: l10n.storeNameField,
                prefixIcon: const Icon(Icons.badge),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(AlhaiSpacing.mdl, AlhaiSpacing.xs, AlhaiSpacing.mdl, AlhaiSpacing.xs),
            child: TextFormField(
              controller: _addressController,
              maxLength: 200,
              validator: FormValidators.requiredField(maxLength: 200),
              decoration: InputDecoration(
                labelText: l10n.addressLabel,
                prefixIcon: const Icon(Icons.location_on),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(AlhaiSpacing.mdl, AlhaiSpacing.xs, AlhaiSpacing.mdl, AlhaiSpacing.md),
            child: TextFormField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              maxLength: 13,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[\d+]')),
              ],
              validator: FormValidators.phone(),
              decoration: InputDecoration(
                labelText: l10n.phoneNumber,
                prefixIcon: const Icon(Icons.phone),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
        ]),

        _buildSettingsGroup(l10n.taxInfo, Icons.receipt_long_rounded,
            AppColors.success, isDark, [
          Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(AlhaiSpacing.mdl, AlhaiSpacing.xs, AlhaiSpacing.mdl, AlhaiSpacing.xs),
            child: TextFormField(
              controller: _vatController,
              keyboardType: TextInputType.number,
              maxLength: 15,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
              ],
              validator: FormValidators.vatNumber(),
              decoration: InputDecoration(
                labelText: l10n.vatNumberFieldLabel,
                prefixIcon: const Icon(Icons.numbers),
                helperText: l10n.vatNumberHintText,
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(AlhaiSpacing.mdl, AlhaiSpacing.xs, AlhaiSpacing.mdl, AlhaiSpacing.xs),
            child: TextFormField(
              controller: _crController,
              keyboardType: TextInputType.number,
              maxLength: 10,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
              ],
              validator: FormValidators.crNumber(),
              decoration: InputDecoration(
                labelText: l10n.commercialRegister,
                prefixIcon: const Icon(Icons.business),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
          SwitchListTile(
            title: Text(l10n.enableVatOption,
                style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface)),
            value: _enableVat,
            onChanged: (v) => setState(() => _enableVat = v),
          ),
          if (_enableVat)
            ListTile(
              title: Text(l10n.taxRateField,
                  style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface)),
              subtitle: Text('${_vatRate.toInt()}%'),
              trailing: SizedBox(
                width: 150,
                child: Slider(
                  value: _vatRate,
                  min: 5,
                  max: 20,
                  divisions: 3,
                  label: '${_vatRate.toInt()}%',
                  onChanged: (v) => setState(() => _vatRate = v),
                ),
              ),
            ),
          const SizedBox(height: AlhaiSpacing.xs),
        ]),

        _buildSettingsGroup(l10n.languageAndCurrency, Icons.language_rounded,
            const Color(0xFFF97316), isDark, [
          Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(AlhaiSpacing.mdl, AlhaiSpacing.xs, AlhaiSpacing.mdl, AlhaiSpacing.xs),
            child: DropdownButtonFormField<String>(
              initialValue: _language,
              decoration: InputDecoration(
                labelText: l10n.language,
                prefixIcon: const Icon(Icons.translate),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              items: const [
                DropdownMenuItem(value: 'ar', child: Text('\u0627\u0644\u0639\u0631\u0628\u064A\u0629')),
                DropdownMenuItem(value: 'en', child: Text('English')),
              ],
              onChanged: (v) => setState(() => _language = v!),
            ),
          ),
          Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(AlhaiSpacing.mdl, AlhaiSpacing.xs, AlhaiSpacing.mdl, AlhaiSpacing.md),
            child: DropdownButtonFormField<String>(
              initialValue: _currency,
              decoration: InputDecoration(
                labelText: l10n.currencyFieldLabel,
                prefixIcon: const Icon(Icons.attach_money),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              items: [
                DropdownMenuItem(
                    value: 'SAR', child: Text(l10n.saudiRiyal)),
                const DropdownMenuItem(
                    value: 'AED', child: Text('\u062F\u0631\u0647\u0645 \u0625\u0645\u0627\u0631\u0627\u062A\u064A (AED)')),
                const DropdownMenuItem(
                    value: 'KWD', child: Text('\u062F\u064A\u0646\u0627\u0631 \u0643\u0648\u064A\u062A\u064A (KWD)')),
                DropdownMenuItem(
                    value: 'USD', child: Text(l10n.usDollar)),
              ],
              onChanged: (v) => setState(() => _currency = v!),
            ),
          ),
        ]),

        _buildSettingsGroup(l10n.storeLogoSection, Icons.image_rounded,
            const Color(0xFFEC4899), isDark, [
          ListTile(
            leading: CircleAvatar(
              backgroundColor: Theme.of(context).dividerColor,
              child: Icon(Icons.image,
                  color: Theme.of(context).colorScheme.onSurfaceVariant),
            ),
            title: Text(l10n.storeLogoSection,
                style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface)),
            subtitle: Text(l10n.storeLogoDesc,
                style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurfaceVariant)),
            trailing: TextButton(
              onPressed: () {},
              child: Text(l10n.changeButton),
            ),
          ),
        ]),

        const SizedBox(height: AlhaiSpacing.lg),
        SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            onPressed: _isSaving ? null : _saveSettings,
            icon: _isSaving
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: Colors.white))
                : const Icon(Icons.save_rounded),
            label: Text(l10n.saveSettings),
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: AlhaiSpacing.md),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPageHeader(bool isDark, AppLocalizations l10n) {
    return Row(
      children: [
        IconButton(
          onPressed: () => context.pop(),
          icon: Icon(Icons.arrow_back_rounded,
              color: Theme.of(context).colorScheme.onSurface),
        ),
        const SizedBox(width: AlhaiSpacing.xs),
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(Icons.store_rounded,
              color: AppColors.primary, size: 24),
        ),
        const SizedBox(width: AlhaiSpacing.sm),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.storeSettings,
                style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface)),
            Text(l10n.storeInfo,
                style: TextStyle(
                    fontSize: 13,
                    color: Theme.of(context).colorScheme.onSurfaceVariant)),
          ],
        ),
      ],
    );
  }

  Widget _buildSettingsGroup(String title, IconData icon, Color color,
      bool isDark, List<Widget> children) {
    return Container(
      margin: const EdgeInsets.only(bottom: AlhaiSpacing.md),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).dividerColor,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(AlhaiSpacing.mdl, AlhaiSpacing.md, AlhaiSpacing.mdl, AlhaiSpacing.xs),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(AlhaiSpacing.xs),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: color, size: 20),
                ),
                const SizedBox(width: AlhaiSpacing.sm),
                Text(title,
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color:
                            Theme.of(context).colorScheme.onSurface)),
              ],
            ),
          ),
          ...children,
        ],
      ),
    );
  }

  Future<void> _saveSettings() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    final name = _nameController.text.sanitized;
    final address = _addressController.text.sanitized;
    final phone = _phoneController.text.sanitizedPhone;
    final vat = _vatController.text.sanitized;
    final cr = _crController.text.sanitized;

    _nameController.text = name;
    _addressController.text = address;
    _phoneController.text = phone;
    _vatController.text = vat;
    _crController.text = cr;

    final l10n = AppLocalizations.of(context);

    if (_currentStoreId != null) {
      try {
        final db = getIt<AppDatabase>();
        final currentStore = await db.storesDao.getStoreById(_currentStoreId!);
        if (currentStore != null) {
          final updatedStore = StoresTableData(
            id: currentStore.id,
            orgId: currentStore.orgId,
            name: name,
            nameEn: currentStore.nameEn,
            phone: phone,
            email: currentStore.email,
            address: address,
            city: currentStore.city,
            logo: currentStore.logo,
            taxNumber: vat,
            commercialReg: cr,
            currency: _currency,
            timezone: currentStore.timezone,
            isActive: currentStore.isActive,
            createdAt: currentStore.createdAt,
            updatedAt: DateTime.now(),
            syncedAt: currentStore.syncedAt,
          );
          await db.storesDao.updateStore(updatedStore);

          final syncService = ref.read(syncServiceProvider);
          await syncService.enqueueUpdate(
            tableName: 'stores',
            recordId: _currentStoreId!,
            changes: {
              'id': _currentStoreId,
              'name': name,
              'phone': phone,
              'address': address,
              'tax_number': vat,
              'commercial_reg': cr,
              'currency': _currency,
              'updated_at': DateTime.now().toIso8601String(),
            },
          );
        }
      } catch (e) {
        if (mounted) {
          setState(() => _isSaving = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${l10n.error}: $e'),
              backgroundColor: AppColors.error,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
        return;
      }
    }

    if (mounted) {
      setState(() => _isSaving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.storeSettingsSaved),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }
}
