/// شاشة الدفع - Payment Screen
///
/// شاشة دفع احترافية للويب مع:
/// - طرق دفع متعددة (نقد، بطاقة، آجل)
/// - حساب الباقي
/// - اختصارات سريعة
/// - تأثيرات بصرية
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:alhai_core/alhai_core.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_sizes.dart';
import '../../core/theme/app_typography.dart';
import '../../core/router/routes.dart';
import '../../providers/cart_providers.dart';
import '../../providers/auth_providers.dart';
import '../../providers/products_providers.dart';
import '../../providers/settings_providers.dart';
import '../../providers/sync_providers.dart';
import '../../services/sale_service.dart';
import '../../widgets/common/app_button.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../widgets/common/offline_banner.dart';
import '../../providers/whatsapp_queue_providers.dart';

/// شاشة الدفع
class PaymentScreen extends ConsumerStatefulWidget {
  const PaymentScreen({super.key});

  @override
  ConsumerState<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends ConsumerState<PaymentScreen>
    with SingleTickerProviderStateMixin {
  PaymentMethod _selectedMethod = PaymentMethod.cash;
  final _cashReceivedController = TextEditingController();
  final _cardRrnController = TextEditingController();
  final _phoneController = TextEditingController();
  final _focusNode = FocusNode();
  bool _isProcessing = false;
  bool _showSuccess = false;
  bool _showPhoneInput = false;
  double _cashReceived = 0;

  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _focusNode.requestFocus();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.elasticOut),
    );
  }

  @override
  void dispose() {
    _cashReceivedController.dispose();
    _cardRrnController.dispose();
    _phoneController.dispose();
    _focusNode.dispose();
    _animationController.dispose();
    super.dispose();
  }

  /// Whether the device is currently offline
  bool get _isOffline {
    final isOnlineAsync = ref.read(isOnlineProvider);
    return isOnlineAsync.when(
      data: (isOnline) => !isOnline,
      loading: () => false,
      error: (_, __) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final cartState = ref.watch(cartStateProvider);
    // Watch online status to trigger rebuilds on connectivity changes
    final isOnlineAsync = ref.watch(isOnlineProvider);
    final isOffline = isOnlineAsync.when(
      data: (isOnline) => !isOnline,
      loading: () => false,
      error: (_, __) => false,
    );

    // Watch payment device settings
    final paymentSettings = ref.watch(paymentDeviceSettingsProvider);
    final settings = paymentSettings.when(
      data: (s) => s,
      loading: () => const PaymentDeviceSettings(),
      error: (_, __) => const PaymentDeviceSettings(),
    );

    // Determine if card payment is allowed by settings
    final cardEnabledBySettings = settings.hasCardPayment;

    // Force cash payment when offline or card not enabled
    if ((isOffline || !cardEnabledBySettings) &&
        _selectedMethod == PaymentMethod.card) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          setState(() => _selectedMethod = PaymentMethod.cash);
        }
      });
    }
    if (isOffline && _selectedMethod != PaymentMethod.cash) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          setState(() => _selectedMethod = PaymentMethod.cash);
        }
      });
    }

    final subtotal = cartState.subtotal;
    final tax = subtotal * 0.15;
    final discount = cartState.discount;
    final total = subtotal + tax - discount;
    final change = _cashReceived - total;

    return CallbackShortcuts(
      bindings: {
        const SingleActivator(LogicalKeyboardKey.escape): () => context.pop(),
        const SingleActivator(LogicalKeyboardKey.enter): () {
          if (_canConfirm(total)) _confirmPayment(total);
        },
        const SingleActivator(LogicalKeyboardKey.digit1): () =>
            setState(() => _selectedMethod = PaymentMethod.cash),
        const SingleActivator(LogicalKeyboardKey.digit2): () {
          if (!isOffline && cardEnabledBySettings) {
            setState(() => _selectedMethod = PaymentMethod.card);
          }
        },
        const SingleActivator(LogicalKeyboardKey.digit3): () {
          if (!isOffline) setState(() => _selectedMethod = PaymentMethod.wallet);
        },
      },
      child: Focus(
        autofocus: true,
        child: Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          body: _showSuccess
              ? _buildSuccessState()
              : _isProcessing
                  ? _buildProcessingState()
                  : Column(
                      children: [
                        const OfflineBanner(),
                        Expanded(
                          child: _buildPaymentContent(total, subtotal, tax, discount, change, settings),
                        ),
                      ],
                    ),
        ),
      ),
    );
  }

  Widget _buildPaymentContent(
    double total,
    double subtotal,
    double tax,
    double discount,
    double change, [
    PaymentDeviceSettings settings = const PaymentDeviceSettings(),
  ]) {
    final isDesktop = AppBreakpoints.isDesktop(context);
    final isMobile = MediaQuery.of(context).size.width < 600;
    final theme = Theme.of(context);

    if (isMobile) {
      // Mobile: stacked layout
      return Column(
        children: [
          _buildHeader(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppLocalizations.of(context)!.paymentMethodTitle,
                    style: AppTypography.titleLarge.copyWith(
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  _buildPaymentMethods(isOffline: _isOffline, settings: settings),
                  const SizedBox(height: AppSpacing.xxl),
                  _buildPaymentDetails(total, change),
                  const SizedBox(height: AppSpacing.xxl),
                  _buildSummaryPanel(total, subtotal, tax, discount, change),
                ],
              ),
            ),
          ),
        ],
      );
    }

    return Row(
      children: [
        // Main Content
        Expanded(
          flex: 3,
          child: Column(
            children: [
              // Header
              _buildHeader(),

              // Content
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(isDesktop ? AppSpacing.xxl : AppSpacing.lg),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Payment Methods
                      Text(
                        AppLocalizations.of(context)!.paymentMethodTitle,
                        style: AppTypography.titleLarge.copyWith(
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      _buildPaymentMethods(isOffline: _isOffline, settings: settings),

                      const SizedBox(height: AppSpacing.xxl),

                      // Payment Details
                      _buildPaymentDetails(total, change),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),

        // Summary Sidebar
        Container(
          width: isDesktop ? 400 : 350,
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            border: const BorderDirectional(
              end: BorderSide(color: AppColors.border),
            ),
            boxShadow: AppShadows.lg,
          ),
          child: _buildSummaryPanel(total, subtotal, tax, discount, change),
        ),
      ],
    );
  }

  Widget _buildHeader() {
    final theme = Theme.of(context);
    return Container(
      height: AppTopBarSize.height,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(
          bottom: BorderSide(color: theme.dividerColor),
        ),
      ),
      child: Row(
        children: [
          // Back Button
          AppIconButton(
            icon: Icons.arrow_forward,
            onPressed: () => context.pop(),
            tooltip: AppLocalizations.of(context)!.backEsc,
          ),

          const SizedBox(width: AppSpacing.md),

          // Title
          Text(
            AppLocalizations.of(context)!.completePayment,
            style: AppTypography.titleLarge.copyWith(
              color: theme.colorScheme.onSurface,
            ),
          ),

          const Spacer(),

          // Keyboard Shortcuts Hint
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.xs,
            ),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: Row(
              children: [
                Icon(Icons.keyboard, size: 16, color: theme.colorScheme.onSurfaceVariant),
                const SizedBox(width: AppSpacing.xs),
                Text(
                  AppLocalizations.of(context)!.enterToConfirm,
                  style: AppTypography.labelSmall.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentMethods({
    bool isOffline = false,
    PaymentDeviceSettings settings = const PaymentDeviceSettings(),
  }) {
    final cardDisabled = isOffline || !settings.hasCardPayment;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Offline warning message
        if (isOffline)
          Container(
            width: double.infinity,
            margin: const EdgeInsets.only(bottom: AppSpacing.md),
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.md,
            ),
            decoration: BoxDecoration(
              color: Colors.orange.shade50,
              borderRadius: BorderRadius.circular(AppRadius.md),
              border: Border.all(color: Colors.orange.shade300),
            ),
            child: Row(
              children: [
                Icon(Icons.wifi_off, size: 20, color: Colors.orange.shade800),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    AppLocalizations.of(context)!.cashOnlyOffline,
                    style: AppTypography.bodyMedium.copyWith(
                      color: Colors.orange.shade800,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),

        // Card payment disabled by settings warning
        if (!isOffline && !settings.hasCardPayment)
          Container(
            width: double.infinity,
            margin: const EdgeInsets.only(bottom: AppSpacing.md),
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.md,
            ),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(AppRadius.md),
              border: Border.all(color: Colors.blue.shade300),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, size: 20, color: Colors.blue.shade800),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    AppLocalizations.of(context)!.cardsDisabledInSettings,
                    style: AppTypography.bodyMedium.copyWith(
                      color: Colors.blue.shade800,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),

        Row(
          children: [
            Expanded(
              child: _PaymentMethodCard(
                icon: Icons.payments_outlined,
                label: AppLocalizations.of(context)!.cashPayment,
                shortcut: '1',
                color: AppColors.cash,
                selected: _selectedMethod == PaymentMethod.cash,
                onTap: () => setState(() => _selectedMethod = PaymentMethod.cash),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: _PaymentMethodCard(
                icon: Icons.credit_card,
                label: AppLocalizations.of(context)!.cardPayment,
                shortcut: '2',
                color: AppColors.card,
                selected: _selectedMethod == PaymentMethod.card,
                onTap: cardDisabled
                    ? null
                    : () => setState(() => _selectedMethod = PaymentMethod.card),
                disabled: cardDisabled,
                disabledLabel: isOffline
                    ? AppLocalizations.of(context)!.unavailableOffline
                    : !settings.hasCardPayment
                        ? AppLocalizations.of(context)!.disabledInSettings
                        : null,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: _PaymentMethodCard(
                icon: Icons.access_time,
                label: AppLocalizations.of(context)!.creditPayment,
                shortcut: '3',
                color: AppColors.debt,
                selected: _selectedMethod == PaymentMethod.wallet,
                onTap: isOffline
                    ? null
                    : () => setState(() => _selectedMethod = PaymentMethod.wallet),
                disabled: isOffline,
                disabledLabel: isOffline ? AppLocalizations.of(context)!.unavailableOffline : null,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPaymentDetails(double total, double change) {
    switch (_selectedMethod) {
      case PaymentMethod.cash:
        return _buildCashDetails(total, change);
      case PaymentMethod.card:
        return _buildCardDetails();
      case PaymentMethod.wallet:
      case PaymentMethod.bankTransfer:
        return _buildCreditDetails();
    }
  }

  Widget _buildCashDetails(double total, double change) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppLocalizations.of(context)!.amountReceived,
          style: AppTypography.titleMedium.copyWith(
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: AppSpacing.md),

        // Cash Input
        Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppRadius.lg),
            border: Border.all(color: AppColors.primaryBorder, width: 2),
            boxShadow: AppShadows.sm,
          ),
          child: TextField(
            controller: _cashReceivedController,
            focusNode: _focusNode,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[\d.]')),
            ],
            textAlign: TextAlign.center,
            style: AppTypography.displayMedium.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w700,
            ),
            decoration: InputDecoration(
              border: InputBorder.none,
              hintText: '0.00',
              hintStyle: AppTypography.displayMedium.copyWith(
                color: AppColors.textMuted,
              ),
              suffixText: AppLocalizations.of(context)!.sar,
              suffixStyle: AppTypography.titleLarge.copyWith(
                color: AppColors.textMuted,
              ),
              contentPadding: const EdgeInsets.all(AppSpacing.xl),
            ),
            onChanged: (value) {
              setState(() {
                _cashReceived = double.tryParse(value) ?? 0;
              });
            },
          ),
        ),

        const SizedBox(height: AppSpacing.xl),

        // Quick Amount Buttons
        Text(
          AppLocalizations.of(context)!.quickAmounts,
          style: AppTypography.labelLarge.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: AppSpacing.md),

        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: [
            _QuickAmountChip(
              label: AppLocalizations.of(context)!.requiredAmount,
              amount: total,
              color: AppColors.primary,
              onTap: () => _setAmount(total),
            ),
            _QuickAmountChip(amount: 50, onTap: () => _setAmount(50)),
            _QuickAmountChip(amount: 100, onTap: () => _setAmount(100)),
            _QuickAmountChip(amount: 200, onTap: () => _setAmount(200)),
            _QuickAmountChip(amount: 500, onTap: () => _setAmount(500)),
          ],
        ),

        const SizedBox(height: AppSpacing.xxl),

        // Change Display
        AnimatedContainer(
          duration: AppDurations.normal,
          padding: const EdgeInsets.all(AppSpacing.xl),
          decoration: BoxDecoration(
            color: change >= 0 ? AppColors.successSurface : AppColors.errorSurface,
            borderRadius: BorderRadius.circular(AppRadius.lg),
            border: Border.all(
              color: change >= 0 ? AppColors.success : AppColors.error,
              width: 2,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    change >= 0 ? Icons.check_circle : Icons.error,
                    color: change >= 0 ? AppColors.success : AppColors.error,
                    size: 28,
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Text(
                    AppLocalizations.of(context)!.changeLabel,
                    style: AppTypography.titleLarge.copyWith(
                      color: change >= 0 ? AppColors.success : AppColors.error,
                    ),
                  ),
                ],
              ),
              Text(
                change >= 0
                    ? '${change.toStringAsFixed(2)} ${AppLocalizations.of(context)!.sar}'
                    : AppLocalizations.of(context)!.insufficientAmount,
                style: AppTypography.displaySmall.copyWith(
                  color: change >= 0 ? AppColors.success : AppColors.error,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCardDetails() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppLocalizations.of(context)!.rrnLabel,
          style: AppTypography.titleMedium.copyWith(
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: AppSpacing.md),

        // RRN Input
        Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppRadius.lg),
            border: Border.all(color: AppColors.border),
            boxShadow: AppShadows.sm,
          ),
          child: TextField(
            controller: _cardRrnController,
            textAlign: TextAlign.center,
            style: AppTypography.headlineMedium.copyWith(
              color: AppColors.textPrimary,
              letterSpacing: 2,
            ),
            decoration: InputDecoration(
              border: InputBorder.none,
              hintText: AppLocalizations.of(context)!.enterRrnFromDevice,
              hintStyle: AppTypography.bodyLarge.copyWith(
                color: AppColors.textMuted,
              ),
              contentPadding: const EdgeInsets.all(AppSpacing.xl),
            ),
            onChanged: (_) => setState(() {}),
          ),
        ),

        const SizedBox(height: AppSpacing.xl),

        // Info Box
        Container(
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            color: AppColors.infoSurface,
            borderRadius: BorderRadius.circular(AppRadius.md),
            border: Border.all(color: AppColors.info.withValues(alpha: 0.3)),
          ),
          child: Row(
            children: [
              const Icon(Icons.info_outline, color: AppColors.info, size: 24),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Text(
                  AppLocalizations.of(context)!.cardPaymentInstructions,
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.info,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCreditDetails() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppLocalizations.of(context)!.creditSale,
          style: AppTypography.titleMedium.copyWith(
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: AppSpacing.md),

        // Warning Box
        Container(
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            color: AppColors.warningSurface,
            borderRadius: BorderRadius.circular(AppRadius.md),
            border: Border.all(color: AppColors.warning.withValues(alpha: 0.3)),
          ),
          child: Row(
            children: [
              const Icon(Icons.warning_amber, color: AppColors.warning, size: 24),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Text(
                  AppLocalizations.of(context)!.creditSaleWarning,
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.warning,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryPanel(
    double total,
    double subtotal,
    double tax,
    double discount,
    double change,
  ) {
    return Column(
      children: [
        // Summary Header
        Container(
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: const BoxDecoration(
            color: AppColors.primarySurface,
          ),
          child: Row(
            children: [
              const Icon(Icons.receipt_long, color: AppColors.primary),
              const SizedBox(width: AppSpacing.sm),
              Text(
                AppLocalizations.of(context)!.orderSummary,
                style: AppTypography.titleMedium.copyWith(
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ),

        // Summary Content
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              children: [
                _SummaryRow(label: AppLocalizations.of(context)!.subtotalLabel, value: subtotal),
                const SizedBox(height: AppSpacing.md),
                _SummaryRow(label: AppLocalizations.of(context)!.taxLabel, value: tax),
                if (discount > 0) ...[
                  const SizedBox(height: AppSpacing.md),
                  _SummaryRow(
                    label: AppLocalizations.of(context)!.discountLabel,
                    value: -discount,
                    valueColor: AppColors.success,
                  ),
                ],

                const Divider(height: AppSpacing.xxl),

                // Total
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      AppLocalizations.of(context)!.requiredAmount,
                      style: AppTypography.titleMedium.copyWith(
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      '${total.toStringAsFixed(2)} ${AppLocalizations.of(context)!.sar}',
                      style: AppTypography.displaySmall.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),

                const Spacer(),

                // Payment Method Badge
                Container(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: _getMethodColor().withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        _getMethodIcon(),
                        color: _getMethodColor(),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Text(
                        _getMethodLabel(),
                        style: AppTypography.titleMedium.copyWith(
                          color: _getMethodColor(),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: AppSpacing.md),
                _buildWhatsAppPhoneInput(),

                const SizedBox(height: AppSpacing.xl),

                // Confirm Button
                SizedBox(
                  width: double.infinity,
                  child: AppButton.primary(
                    label: AppLocalizations.of(context)!.confirmPayment,
                    icon: Icons.check_circle,
                    size: ButtonSize.large,
                    onPressed: _canConfirm(total) ? () => _confirmPayment(total) : null,
                    isLoading: _isProcessing,
                  ),
                ),

                const SizedBox(height: AppSpacing.md),

                // Cancel Button
                SizedBox(
                  width: double.infinity,
                  child: AppButton.ghost(
                    label: AppLocalizations.of(context)!.cancelAction,
                    onPressed: () => context.pop(),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProcessingState() {
    final theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(
            width: 80,
            height: 80,
            child: CircularProgressIndicator(
              strokeWidth: 4,
              valueColor: AlwaysStoppedAnimation(AppColors.primary),
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          Text(
            AppLocalizations.of(context)!.processingPayment,
            style: AppTypography.titleLarge.copyWith(
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            AppLocalizations.of(context)!.pleaseWait,
            style: AppTypography.bodyMedium.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessState() {
    return Center(
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: const BoxDecoration(
                color: AppColors.successSurface,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_circle,
                size: 80,
                color: AppColors.success,
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            Text(
              AppLocalizations.of(context)!.paymentSuccessful,
              style: AppTypography.displaySmall.copyWith(
                color: AppColors.success,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              AppLocalizations.of(context)!.printingReceipt,
              style: AppTypography.bodyLarge.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================================
  // WhatsApp Phone Input
  // ============================================================================

  Widget _buildWhatsAppPhoneInput() {
    final theme = Theme.of(context);
    final whatsAppColor = const Color(0xFF25D366);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: () => setState(() => _showPhoneInput = !_showPhoneInput),
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              children: [
                Icon(
                  _showPhoneInput
                      ? Icons.check_box
                      : Icons.check_box_outline_blank,
                  color: whatsAppColor,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(AppLocalizations.of(context)!.whatsappReceipt,
                    style: TextStyle(fontSize: 14, color: theme.colorScheme.onSurface)),
                const SizedBox(width: 4),
                Icon(Icons.chat, size: 16, color: whatsAppColor),
              ],
            ),
          ),
        ),
        if (_showPhoneInput) ...[
          const SizedBox(height: 8),
          TextField(
            controller: _phoneController,
            keyboardType: TextInputType.phone,
            textDirection: TextDirection.ltr,
            decoration: InputDecoration(
              prefixText: '+966 ',
              hintText: '5X XXX XXXX',
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              isDense: true,
              suffixIcon: Icon(Icons.phone_android,
                  size: 18, color: whatsAppColor),
            ),
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(9),
            ],
          ),
        ],
      ],
    );
  }

  // ============================================================================
  // Helpers
  // ============================================================================

  void _setAmount(double amount) {
    _cashReceivedController.text = amount.toStringAsFixed(2);
    setState(() => _cashReceived = amount);
  }

  Color _getMethodColor() {
    switch (_selectedMethod) {
      case PaymentMethod.cash:
        return AppColors.cash;
      case PaymentMethod.card:
        return AppColors.card;
      case PaymentMethod.wallet:
      case PaymentMethod.bankTransfer:
        return AppColors.debt;
    }
  }

  IconData _getMethodIcon() {
    switch (_selectedMethod) {
      case PaymentMethod.cash:
        return Icons.payments;
      case PaymentMethod.card:
        return Icons.credit_card;
      case PaymentMethod.wallet:
      case PaymentMethod.bankTransfer:
        return Icons.access_time;
    }
  }

  String _getMethodLabel() {
    switch (_selectedMethod) {
      case PaymentMethod.cash:
        return AppLocalizations.of(context)!.payCash;
      case PaymentMethod.card:
        return AppLocalizations.of(context)!.payCard;
      case PaymentMethod.wallet:
      case PaymentMethod.bankTransfer:
        return AppLocalizations.of(context)!.payCreditSale;
    }
  }

  bool _canConfirm(double total) {
    switch (_selectedMethod) {
      case PaymentMethod.cash:
        return _cashReceived >= total;
      case PaymentMethod.card:
        return _cardRrnController.text.isNotEmpty;
      case PaymentMethod.wallet:
      case PaymentMethod.bankTransfer:
        return true;
    }
  }

  Future<void> _confirmPayment(double total) async {
    setState(() => _isProcessing = true);

    try {
      final cartState = ref.read(cartStateProvider);
      final storeId = ref.read(currentStoreIdProvider);
      final userId = ref.read(currentUserProvider)?.id;

      if (storeId == null || userId == null) {
        throw Exception(AppLocalizations.of(context)!.storeOrUserNotSet);
      }

      final saleService = getIt<SaleService>();
      final subtotal = cartState.subtotal;
      final tax = subtotal * 0.15;

      final saleId = await saleService.createSale(
        storeId: storeId,
        cashierId: userId,
        items: cartState.items,
        subtotal: subtotal,
        discount: cartState.discount,
        tax: tax,
        total: total,
        paymentMethod: _selectedMethod.name,
        customerId: cartState.customerId,
        notes: cartState.notes,
      );

      // Show success animation
      setState(() {
        _isProcessing = false;
        _showSuccess = true;
      });
      _animationController.forward();

      // Wait and navigate
      await Future.delayed(const Duration(seconds: 2));

      // مسح السلة بعد البيع الناجح
      ref.read(cartStateProvider.notifier).clear();

      // حفظ رقم الهاتف لشاشة الإيصال
      if (_showPhoneInput && _phoneController.text.trim().isNotEmpty) {
        final rawDigits = _phoneController.text.replaceAll(' ', '').trim();
        if (rawDigits.length >= 8) {
          ref.read(receiptPhoneProvider.notifier).state = '0$rawDigits';
        }
      }

      // الانتقال لشاشة الإيصال
      if (mounted) {
        context.go('${AppRoutes.posReceipt}?saleId=$saleId');
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isProcessing = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.errorWithMessage(e.toString())),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }
}

// ============================================================================
// Sub Widgets
// ============================================================================

class _PaymentMethodCard extends StatefulWidget {
  final IconData icon;
  final String label;
  final String shortcut;
  final Color color;
  final bool selected;
  final VoidCallback? onTap;
  final bool disabled;
  final String? disabledLabel;

  const _PaymentMethodCard({
    required this.icon,
    required this.label,
    required this.shortcut,
    required this.color,
    required this.selected,
    required this.onTap,
    this.disabled = false,
    this.disabledLabel,
  });

  @override
  State<_PaymentMethodCard> createState() => _PaymentMethodCardState();
}

class _PaymentMethodCardState extends State<_PaymentMethodCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final isDisabled = widget.disabled;
    final effectiveColor = isDisabled ? AppColors.grey400 : widget.color;

    return Opacity(
      opacity: isDisabled ? 0.5 : 1.0,
      child: MouseRegion(
        onEnter: isDisabled ? null : (_) => setState(() => _isHovered = true),
        onExit: isDisabled ? null : (_) => setState(() => _isHovered = false),
        cursor: isDisabled ? SystemMouseCursors.forbidden : SystemMouseCursors.click,
        child: AnimatedContainer(
          duration: AppDurations.fast,
          decoration: BoxDecoration(
            color: isDisabled
                ? AppColors.grey100
                : widget.selected
                    ? widget.color.withValues(alpha: 0.1)
                    : _isHovered
                        ? AppColors.grey50
                        : AppColors.surface,
            borderRadius: BorderRadius.circular(AppRadius.lg),
            border: Border.all(
              color: isDisabled
                  ? AppColors.grey300
                  : widget.selected
                      ? widget.color
                      : AppColors.border,
              width: widget.selected ? 2 : 1,
            ),
            boxShadow: isDisabled
                ? null
                : widget.selected || _isHovered
                    ? AppShadows.md
                    : AppShadows.sm,
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: isDisabled ? null : widget.onTap,
              borderRadius: BorderRadius.circular(AppRadius.lg),
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.xl),
                child: Column(
                  children: [
                    // Icon
                    AnimatedContainer(
                      duration: AppDurations.fast,
                      width: widget.selected ? 72 : 64,
                      height: widget.selected ? 72 : 64,
                      decoration: BoxDecoration(
                        color: effectiveColor.withValues(alpha: widget.selected ? 0.2 : 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        widget.icon,
                        size: widget.selected ? 36 : 32,
                        color: effectiveColor,
                      ),
                    ),

                    const SizedBox(height: AppSpacing.md),

                    // Label
                    Text(
                      widget.label,
                      style: AppTypography.titleMedium.copyWith(
                        color: isDisabled
                            ? AppColors.textMuted
                            : widget.selected
                                ? widget.color
                                : AppColors.textPrimary,
                        fontWeight: widget.selected ? FontWeight.w700 : FontWeight.w500,
                      ),
                    ),

                    const SizedBox(height: AppSpacing.xs),

                    // Shortcut or disabled label
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm,
                        vertical: AppSpacing.xxs,
                      ),
                      decoration: BoxDecoration(
                        color: isDisabled ? Colors.orange.shade50 : AppColors.grey100,
                        borderRadius: BorderRadius.circular(AppRadius.xs),
                      ),
                      child: Text(
                        isDisabled
                            ? (widget.disabledLabel ?? '')
                            : widget.shortcut,
                        style: AppTypography.labelSmall.copyWith(
                          color: isDisabled ? Colors.orange.shade700 : AppColors.textMuted,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _QuickAmountChip extends StatefulWidget {
  final double amount;
  final String? label;
  final Color? color;
  final VoidCallback onTap;

  const _QuickAmountChip({
    required this.amount,
    this.label,
    this.color,
    required this.onTap,
  });

  @override
  State<_QuickAmountChip> createState() => _QuickAmountChipState();
}

class _QuickAmountChipState extends State<_QuickAmountChip> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final color = widget.color ?? AppColors.grey500;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: AppDurations.fast,
        child: Material(
          color: _isHovered ? color.withValues(alpha: 0.1) : AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.full),
          child: InkWell(
            onTap: widget.onTap,
            borderRadius: BorderRadius.circular(AppRadius.full),
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
                vertical: AppSpacing.md,
              ),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppRadius.full),
                border: Border.all(
                  color: _isHovered ? color : AppColors.border,
                ),
              ),
              child: Text(
                widget.label ?? '${widget.amount.toInt()}',
                style: AppTypography.labelLarge.copyWith(
                  color: _isHovered ? color : AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final double value;
  final Color? valueColor;

  const _SummaryRow({
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: AppTypography.bodyMedium.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        Text(
          '${value < 0 ? '-' : ''}${value.abs().toStringAsFixed(2)} ${AppLocalizations.of(context)!.sar}',
          style: AppTypography.bodyMedium.copyWith(
            color: valueColor ?? AppColors.textPrimary,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
