import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:alhai_design_system/alhai_design_system.dart';
import 'package:alhai_l10n/alhai_l10n.dart';
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
  // Default plan is 'free' -- one of the 4 values whitelisted by the
  // live subscriptions_plan_check ('free','starter','professional',
  // 'enterprise'). The pre-U4 default of 'basic' was a production bug:
  // 'basic' is not in the whitelist and every submission raised 23514.
  String _selectedPlan = 'free';
  String _selectedBusiness = 'grocery';
  bool _submitting = false;

  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _taxNumberController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _taxNumberController.dispose();
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
      // The v49 `create_store` RPC writes the sa_audit_log row itself
      // inside the same transaction. The former screen-side
      // auditLogService.log('store.create') call was a pre-v49 duplicate
      // and has been removed.
      await ds.createStore(
        name: _nameController.text.trim(),
        phone: _phoneController.text.trim(),
        email: _emailController.text.trim(),
        taxNumber: _taxNumberController.text.trim(),
        plan: _selectedPlan,
        businessType: _selectedBusiness,
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
                              ],
                            ),
                          ),

                          // Step 2: Contact info
                          Step(
                            title: Text(l10n.contactInfo),
                            isActive: _currentStep >= 1,
                            state: _currentStep > 1
                                ? StepState.complete
                                : StepState.indexed,
                            content: Column(
                              children: [
                                TextFormField(
                                  controller: _phoneController,
                                  decoration: InputDecoration(
                                    labelText: l10n.phone,
                                    prefixIcon: const Icon(Icons.phone_rounded),
                                  ),
                                  keyboardType: TextInputType.phone,
                                  validator: _validatePhone,
                                ),
                                const SizedBox(height: AlhaiSpacing.md),
                                TextFormField(
                                  controller: _emailController,
                                  decoration: InputDecoration(
                                    labelText: l10n.email,
                                    prefixIcon: const Icon(Icons.email_rounded),
                                  ),
                                  keyboardType: TextInputType.emailAddress,
                                  validator: _validateEmail,
                                ),
                                const SizedBox(height: AlhaiSpacing.md),
                                TextFormField(
                                  controller: _taxNumberController,
                                  decoration: InputDecoration(
                                    labelText: l10n.taxNumber,
                                    hintText: l10n.taxNumberHint,
                                    prefixIcon: const Icon(
                                      Icons.receipt_long_rounded,
                                    ),
                                  ),
                                  keyboardType: TextInputType.number,
                                ),
                              ],
                            ),
                          ),

                          // Step 3: Plan selection.
                          //
                          // Slugs ('free','starter','professional',
                          // 'enterprise') are authoritative: they must match
                          // the subscriptions_plan_check CHECK constraint
                          // exactly or the v49 RPC raises 23514. Labels are
                          // hardcoded English (SaaS tier names are
                          // industry-standard proper nouns; no l10n keys
                          // needed per U4 Part 3 decision).
                          Step(
                            title: Text(l10n.storePlan),
                            isActive: _currentStep >= 2,
                            content: Column(
                              children: [
                                _PlanOption(
                                  title: 'Free',
                                  price: '0',
                                  features: 'Single branch, limited catalog',
                                  isSelected: _selectedPlan == 'free',
                                  onTap: () =>
                                      setState(() => _selectedPlan = 'free'),
                                ),
                                const SizedBox(height: AlhaiSpacing.sm),
                                _PlanOption(
                                  title: 'Starter',
                                  price: '99',
                                  features: '1 branch, 500 products, 3 users',
                                  isSelected: _selectedPlan == 'starter',
                                  onTap: () =>
                                      setState(() => _selectedPlan = 'starter'),
                                ),
                                const SizedBox(height: AlhaiSpacing.sm),
                                _PlanOption(
                                  title: 'Professional',
                                  price: '249',
                                  features:
                                      '3 branches, 2000 products, 10 users',
                                  isSelected: _selectedPlan == 'professional',
                                  onTap: () => setState(
                                    () => _selectedPlan = 'professional',
                                  ),
                                ),
                                const SizedBox(height: AlhaiSpacing.sm),
                                _PlanOption(
                                  title: 'Enterprise',
                                  price: '499',
                                  features:
                                      'Unlimited branches, products, users',
                                  isSelected: _selectedPlan == 'enterprise',
                                  onTap: () => setState(
                                    () => _selectedPlan = 'enterprise',
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
