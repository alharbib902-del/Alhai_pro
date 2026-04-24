/// Customer Picker — بطاقة اختيار عميل الفاتورة
///
/// تعرض العميل المحدد كـ chip أو حقل بحث debounced يستدعي
/// `customersDao.searchCustomers`. يحدّث [invoiceDraftProvider] عند الاختيار.
///
/// قيود:
/// - `setState` داخلي واحد فقط لإدارة نتائج البحث والتبديل
///   بين عرض chip وعرض حقل البحث (حالة UI بحتة).
library;

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_it/get_it.dart';
import 'package:alhai_database/alhai_database.dart';
import 'package:alhai_l10n/alhai_l10n.dart';
import 'package:alhai_shared_ui/alhai_shared_ui.dart';
import 'package:alhai_design_system/alhai_design_system.dart'
    show AlhaiSnackbar, AlhaiSpacing;

import '../../../../core/services/sentry_service.dart';
import '../providers/invoice_draft_notifier.dart';

/// بطاقة العميل: إمّا chip للعميل المختار أو حقل بحث
class CustomerPicker extends ConsumerStatefulWidget {
  const CustomerPicker({super.key});

  @override
  ConsumerState<CustomerPicker> createState() => _CustomerPickerState();
}

class _CustomerPickerState extends ConsumerState<CustomerPicker> {
  final _db = GetIt.I<AppDatabase>();
  final _searchController = TextEditingController();

  List<CustomersTableData> _results = [];
  bool _showSearch = false;
  Timer? _debounce;

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _onChanged(String query) {
    _debounce?.cancel();
    if (query.trim().isEmpty) {
      setState(() => _results = []);
      return;
    }
    _debounce = Timer(const Duration(milliseconds: 300), () {
      _search(query);
    });
  }

  Future<void> _search(String query) async {
    if (query.trim().isEmpty) {
      setState(() => _results = []);
      return;
    }
    try {
      final storeId = ref.read(currentStoreIdProvider);
      if (storeId == null) return;
      final results = await _db.customersDao.searchCustomers(query, storeId);
      if (mounted) {
        setState(() => _results = results.take(5).toList());
      }
    } catch (e, stack) {
      reportError(e, stackTrace: stack, hint: 'Customer search');
      if (mounted) {
        AlhaiSnackbar.error(
          context,
          AppLocalizations.of(context).customerSearchFailed('$e'),
        );
      }
    }
  }

  void _select(CustomersTableData customer) {
    ref.read(invoiceDraftProvider.notifier).selectCustomer(customer);
    setState(() {
      _showSearch = false;
      _searchController.clear();
      _results = [];
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context);
    final selected =
        ref.watch(invoiceDraftProvider.select((s) => s.selectedCustomer));

    return Container(
      padding: const EdgeInsets.all(AlhaiSpacing.mdl),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _CardHeader(
            icon: Icons.person_rounded,
            iconColor: AppColors.info,
            label: l10n.customerName,
          ),
          const SizedBox(height: AlhaiSpacing.md),
          if (selected != null && !_showSearch)
            _SelectedCustomerChip(
              customer: selected,
              onEdit: () => setState(() => _showSearch = true),
            )
          else
            _SearchField(
              controller: _searchController,
              onChanged: _onChanged,
              hint: l10n.searchPlaceholder,
              results: _results,
              onPick: _select,
            ),
        ],
      ),
    );
  }
}

class _CardHeader extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;

  const _CardHeader({
    required this.icon,
    required this.iconColor,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(AlhaiSpacing.xs),
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: iconColor, size: 20),
        ),
        const SizedBox(width: AlhaiSpacing.sm),
        Text(
          label,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: colorScheme.onSurface,
          ),
        ),
      ],
    );
  }
}

class _SelectedCustomerChip extends StatelessWidget {
  final CustomersTableData customer;
  final VoidCallback onEdit;

  const _SelectedCustomerChip({required this.customer, required this.onEdit});

  String _initials(String name) {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.isNotEmpty ? name[0].toUpperCase() : '?';
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return InkWell(
      onTap: onEdit,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: isDark ? 0.12 : 0.06),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppColors.primary.withValues(alpha: 0.4),
            width: 2,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                gradient: AppColors.avatarGradient,
                borderRadius: BorderRadius.circular(10),
              ),
              alignment: Alignment.center,
              child: Text(
                _initials(customer.name),
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: colorScheme.onPrimary,
                ),
              ),
            ),
            const SizedBox(width: AlhaiSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    customer.name,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  Directionality(
                    textDirection: TextDirection.ltr,
                    child: Text(
                      customer.phone ?? '',
                      style: TextStyle(
                        fontSize: 12,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.edit_rounded, size: 18, color: AppColors.primary),
          ],
        ),
      ),
    );
  }
}

class _SearchField extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final String hint;
  final List<CustomersTableData> results;
  final ValueChanged<CustomersTableData> onPick;

  const _SearchField({
    required this.controller,
    required this.onChanged,
    required this.hint,
    required this.results,
    required this.onPick,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      children: [
        TextField(
          controller: controller,
          style: TextStyle(color: colorScheme.onSurface),
          onChanged: onChanged,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: colorScheme.outline),
            prefixIcon: Icon(Icons.search_rounded, color: colorScheme.outline),
            filled: true,
            fillColor: colorScheme.surfaceContainerHighest,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: colorScheme.outlineVariant),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: colorScheme.outlineVariant),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.primary, width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: AlhaiSpacing.md,
              vertical: 14,
            ),
          ),
        ),
        if (results.isNotEmpty)
          Container(
            margin: const EdgeInsetsDirectional.only(top: AlhaiSpacing.xs),
            decoration: BoxDecoration(
              color: colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: colorScheme.outlineVariant),
              boxShadow: [
                BoxShadow(
                  color: colorScheme.shadow,
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: results.map((customer) {
                return InkWell(
                  onTap: () => onPick(customer),
                  borderRadius: BorderRadius.circular(12),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AlhaiSpacing.md,
                      vertical: AlhaiSpacing.sm,
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.person_outline_rounded,
                          size: 18,
                          color: colorScheme.outline,
                        ),
                        const SizedBox(width: AlhaiSpacing.sm),
                        Expanded(
                          child: Text(
                            customer.name,
                            style: TextStyle(
                              fontSize: 14,
                              color: colorScheme.onSurface,
                            ),
                          ),
                        ),
                        Directionality(
                          textDirection: TextDirection.ltr,
                          child: Text(
                            customer.phone ?? '',
                            style: TextStyle(
                              fontSize: 12,
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
      ],
    );
  }
}
