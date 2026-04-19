import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:alhai_design_system/alhai_design_system.dart';
import 'package:alhai_l10n/alhai_l10n.dart';
import '../../core/services/audit_log_service.dart';
import '../../core/services/sentry_service.dart';
import '../../providers/sa_providers.dart';

/// Create new store form -- submits to Supabase.
class SACreateStoreScreen extends ConsumerStatefulWidget {
  const SACreateStoreScreen({super.key});

  @override
  ConsumerState<SACreateStoreScreen> createState() =>
      _SACreateStoreScreenState();
}

class _SACreateStoreScreenState extends ConsumerState<SACreateStoreScreen> {
  final _formKey = GlobalKey<FormState>();
  int _currentStep = 0;
  String _selectedPlan = 'basic';
  String _selectedBusiness = 'grocery';
  bool _submitting = false;

  final _nameController = TextEditingController();
  final _branchCountController = TextEditingController(text: '1');
  final _ownerNameController = TextEditingController();
  final _ownerPhoneController = TextEditingController();
  final _ownerEmailController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _branchCountController.dispose();
    _ownerNameController.dispose();
    _ownerPhoneController.dispose();
    _ownerEmailController.dispose();
    super.dispose();
  }

  /// Validates that a name field is not empty and has a reasonable length.
  String? _validateName(String? value, AppLocalizations l10n) {
    if (value == null || value.trim().isEmpty) {
      return l10n.fieldRequired;
    }
    if (value.trim().length < 2) {
      return l10n.fieldRequired; // too short
    }
    if (value.trim().length > 100) {
      return l10n.fieldRequired; // too long
    }
    return null;
  }

  /// Validates an email address format.
  String? _validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) return null; // optional field
    final emailRegex = RegExp(r'^[\w.+-]+@[\w-]+\.[\w.]+$');
    if (!emailRegex.hasMatch(value.trim())) {
      return 'Invalid email format';
    }
    return null;
  }

  /// Validates a phone number format (digits, optional leading +, 7-15 chars).
  String? _validatePhone(String? value) {
    if (value == null || value.trim().isEmpty) return null; // optional field
    final phoneRegex = RegExp(r'^\+?[\d\s\-]{7,15}$');
    if (!phoneRegex.hasMatch(value.trim())) {
      return 'Invalid phone number';
    }
    return null;
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _submitting = true);

    try {
      final ds = ref.read(saStoresDatasourceProvider);
      final created = await ds.createStore(
        name: _nameController.text.trim(),
        businessType: _selectedBusiness,
        ownerName: _ownerNameController.text.trim(),
        ownerPhone: _ownerPhoneController.text.trim(),
        ownerEmail: _ownerEmailController.text.trim(),
        planSlug: _selectedPlan,
        branchCount: int.tryParse(_branchCountController.text) ?? 1,
      );

      // P0 audit trail: record the privileged mutation. Fire-and-forget
      // (AuditLogService.log swallows errors internally) so a Sentry-level
      // audit glitch never blocks the user flow.
      //
      // Owner PII (name/phone/email) is intentionally NOT included — it lives
      // on the stores row (retrievable via target_id) and duplicating it into
      // the append-only audit log would block GDPR right-to-erasure requests.
      await ref
          .read(auditLogServiceProvider)
          .log(
            action: 'store.create',
            targetType: 'store',
            targetId: created.id,
            after: {
              'name': created.name,
              'business_type': _selectedBusiness,
              'plan': _selectedPlan,
              'branch_count': int.tryParse(_branchCountController.text) ?? 1,
            },
          );

      // Invalidate stores list so it refreshes
      ref.invalidate(saStoresListProvider);
      ref.invalidate(saDashboardKPIsProvider);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context).storeCreatedSuccess),
          ),
        );
        context.go('/stores');
      }
    } catch (e, st) {
      reportError(e, stackTrace: st, hint: 'createStore submit failed');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context).errorOccurred),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final width = MediaQuery.sizeOf(context).width;
    final isWide = width >= AlhaiBreakpoints.desktop;

    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AlhaiSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back_rounded),
                  onPressed: () => context.go('/stores'),
                ),
                const SizedBox(width: AlhaiSpacing.xs),
                Text(
                  l10n.createStore,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AlhaiSpacing.lg),
            Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: isWide ? 800 : double.infinity,
                ),
                child: Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AlhaiRadius.card),
                    side: BorderSide(
                      color: theme.colorScheme.outlineVariant,
                      width: AlhaiSpacing.strokeXs,
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(AlhaiSpacing.xl),
                    child: Form(
                      key: _formKey,
                      child: Stepper(
                        currentStep: _currentStep,
                        type: isWide
                            ? StepperType.horizontal
                            : StepperType.vertical,
                        onStepContinue: () {
                          if (_currentStep < 2) {
                            setState(() => _currentStep++);
                          } else {
                            _submit();
                          }
                        },
                        onStepCancel: () {
                          if (_currentStep > 0) {
                            setState(() => _currentStep--);
                          }
                        },
                        controlsBuilder: (context, details) {
                          return Padding(
                            padding: const EdgeInsets.only(
                              top: AlhaiSpacing.md,
                            ),
                            child: Row(
                              children: [
                                if (_currentStep > 0)
                                  TextButton(
                                    onPressed: details.onStepCancel,
                                    child: Text(l10n.cancel),
                                  ),
                                const Spacer(),
                                FilledButton(
                                  onPressed: _submitting
                                      ? null
                                      : details.onStepContinue,
                                  child: _submitting
                                      ? const SizedBox(
                                          width: 20,
                                          height: 20,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                          ),
                                        )
                                      : Text(
                                          _currentStep < 2
                                              ? 'Next'
                                              : l10n.createStore,
                                        ),
                                ),
                              ],
                            ),
                          );
                        },
                        steps: [
                          // Step 1: Store info
                          Step(
                            title: Text(l10n.storeName),
                            isActive: _currentStep >= 0,
                            state: _currentStep > 0
                                ? StepState.complete
                                : StepState.indexed,
                            content: Column(
                              children: [
                                TextFormField(
                                  controller: _nameController,
                                  decoration: InputDecoration(
                                    labelText: l10n.storeName,
                                    prefixIcon: const Icon(Icons.store_rounded),
                                  ),
                                  validator: (v) => _validateName(v, l10n),
                                ),
                                const SizedBox(height: AlhaiSpacing.md),
                                DropdownButtonFormField<String>(
                                  initialValue: _selectedBusiness,
                                  decoration: InputDecoration(
                                    labelText: l10n.businessType,
                                    prefixIcon: const Icon(
                                      Icons.business_rounded,
                                    ),
                                  ),
                                  items: const [
                                    DropdownMenuItem(
                                      value: 'grocery',
                                      child: Text('Grocery'),
                                    ),
                                    DropdownMenuItem(
                                      value: 'restaurant',
                                      child: Text('Restaurant'),
                                    ),
                                    DropdownMenuItem(
                                      value: 'retail',
                                      child: Text('Retail'),
                                    ),
                                    DropdownMenuItem(
                                      value: 'services',
                                      child: Text('Services'),
                                    ),
                                  ],
                                  onChanged: (v) =>
                                      setState(() => _selectedBusiness = v!),
                                ),
                                const SizedBox(height: AlhaiSpacing.md),
                                TextFormField(
                                  controller: _branchCountController,
                                  decoration: InputDecoration(
                                    labelText: l10n.branchCountLabel,
                                    prefixIcon: const Icon(
                                      Icons.account_tree_rounded,
                                    ),
                                  ),
                                  keyboardType: TextInputType.number,
                                ),
                              ],
                            ),
                          ),

                          // Step 2: Owner info
                          Step(
                            title: Text(l10n.storeOwner),
                            isActive: _currentStep >= 1,
                            state: _currentStep > 1
                                ? StepState.complete
                                : StepState.indexed,
                            content: Column(
                              children: [
                                TextFormField(
                                  controller: _ownerNameController,
                                  decoration: InputDecoration(
                                    labelText: l10n.ownerName,
                                    prefixIcon: const Icon(
                                      Icons.person_rounded,
                                    ),
                                  ),
                                  validator: (v) => _validateName(v, l10n),
                                ),
                                const SizedBox(height: AlhaiSpacing.md),
                                TextFormField(
                                  controller: _ownerPhoneController,
                                  decoration: InputDecoration(
                                    labelText: l10n.ownerPhone,
                                    prefixIcon: const Icon(Icons.phone_rounded),
                                  ),
                                  keyboardType: TextInputType.phone,
                                  validator: _validatePhone,
                                ),
                                const SizedBox(height: AlhaiSpacing.md),
                                TextFormField(
                                  controller: _ownerEmailController,
                                  decoration: InputDecoration(
                                    labelText: l10n.ownerEmail,
                                    prefixIcon: const Icon(Icons.email_rounded),
                                  ),
                                  keyboardType: TextInputType.emailAddress,
                                  validator: _validateEmail,
                                ),
                              ],
                            ),
                          ),

                          // Step 3: Plan selection
                          Step(
                            title: Text(l10n.storePlan),
                            isActive: _currentStep >= 2,
                            content: Column(
                              children: [
                                _PlanOption(
                                  title: l10n.basicPlan,
                                  price: '99',
                                  features: '1 branch, 500 products, 3 users',
                                  isSelected: _selectedPlan == 'basic',
                                  onTap: () =>
                                      setState(() => _selectedPlan = 'basic'),
                                ),
                                const SizedBox(height: AlhaiSpacing.sm),
                                _PlanOption(
                                  title: l10n.advancedPlan,
                                  price: '249',
                                  features:
                                      '3 branches, 2000 products, 10 users',
                                  isSelected: _selectedPlan == 'advanced',
                                  onTap: () => setState(
                                    () => _selectedPlan = 'advanced',
                                  ),
                                ),
                                const SizedBox(height: AlhaiSpacing.sm),
                                _PlanOption(
                                  title: l10n.professionalPlan,
                                  price: '499',
                                  features:
                                      'Unlimited branches, products, users',
                                  isSelected: _selectedPlan == 'professional',
                                  onTap: () => setState(
                                    () => _selectedPlan = 'professional',
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PlanOption extends StatelessWidget {
  final String title;
  final String price;
  final String features;
  final bool isSelected;
  final VoidCallback onTap;

  const _PlanOption({
    required this.title,
    required this.price,
    required this.features,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AlhaiRadius.sm),
      child: Container(
        padding: const EdgeInsets.all(AlhaiSpacing.md),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AlhaiRadius.sm),
          border: Border.all(
            color: isSelected
                ? theme.colorScheme.primary
                : theme.colorScheme.outlineVariant,
            width: isSelected ? 2 : 1,
          ),
          color: isSelected
              ? theme.colorScheme.primaryContainer.withValues(alpha: 0.3)
              : null,
        ),
        child: Row(
          children: [
            RadioGroup<bool>(
              groupValue: isSelected,
              onChanged: (_) => onTap(),
              child: const Radio<bool>(value: true),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    features,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.outline,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              '$price ${l10n.sar}${l10n.perMonth}',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
