/// شاشة الدفع - Payment Screen
///
/// شاشة دفع احترافية للويب مع:
/// - طرق دفع متعددة (نقد، بطاقة، آجل)
/// - حساب الباقي
/// - اختصارات سريعة
/// - تأثيرات بصرية
/// - استبدال نقاط الولاء
library;

import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import 'package:alhai_core/alhai_core.dart';
import 'package:alhai_design_system/alhai_design_system.dart';
import 'package:alhai_shared_ui/alhai_shared_ui.dart';
import 'package:get_it/get_it.dart';
import 'package:alhai_database/alhai_database.dart' hide PaymentMethod;
import '../../providers/sale_providers.dart';
import '../../providers/cart_providers.dart';
import 'package:alhai_auth/alhai_auth.dart';
import '../../services/sale_service.dart';
import 'package:alhai_l10n/alhai_l10n.dart';
import 'package:alhai_zatca/alhai_zatca.dart' show VatCalculator;
import '../../widgets/pos/split_payment_dialog.dart' as split_dlg
    show SplitPaymentDialog, PaymentSplit;
import 'payment_sub_widgets.dart';
import 'payment_details_widgets.dart';
import 'payment_loyalty_widget.dart';

// ============================================================================
// PaymentScreen
// ============================================================================

/// شاشة الدفع
class PaymentScreen extends ConsumerStatefulWidget {
  const PaymentScreen({super.key});

  @override
  ConsumerState<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends ConsumerState<PaymentScreen>
    with SingleTickerProviderStateMixin {
  AppLocalizations get l10n => AppLocalizations.of(context)!;

  PaymentMethod _selectedMethod = PaymentMethod.cash;
  final _cashReceivedController = TextEditingController();
  final _cardRrnController = TextEditingController();
  final _phoneController = TextEditingController();
  final _loyaltyPointsController = TextEditingController();
  final _focusNode = FocusNode();
  bool _isProcessing = false;
  bool _showSuccess = false;
  bool _showPhoneInput = false;
  double _cashReceived = 0;
  bool _isSplitPayment = false;
  List<split_dlg.PaymentSplit> _splitPayments = [];

  // حالة نقاط الولاء
  bool _useLoyaltyPoints = false;
  int _pointsToRedeem = 0;

  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _focusNode.requestFocus();
    _animationController = AnimationController(
      vsync: this,
      duration: AlhaiDurations.extraSlow,
    );
    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: AlhaiMotion.spring),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.of(context).disableAnimations) {
      _animationController.value = 1.0; // Skip to end state
    }
  }

  @override
  void dispose() {
    _cashReceivedController.dispose();
    _cardRrnController.dispose();
    _phoneController.dispose();
    _loyaltyPointsController.dispose();
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
    final l10n = AppLocalizations.of(context)!;
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

    // Watch loyalty settings
    final loyaltySettingsAsync = ref.watch(loyaltySettingsProvider);
    final loyaltySettings = loyaltySettingsAsync.when(
      data: (s) => s,
      loading: () => const LoyaltySettings(),
      error: (_, __) => const LoyaltySettings(),
    );

    // Watch customer loyalty account (if customer selected)
    final customerId = cartState.customerId ?? '';
    final customerLoyaltyAsync = ref.watch(customerLoyaltyProvider(customerId));
    final loyaltyAccount = (loyaltySettings.isEnabled && customerId.isNotEmpty)
        ? customerLoyaltyAsync.when(
            data: (a) => a,
            loading: () => null,
            error: (_, __) => null,
          )
        : null;

    // حساب خصم الولاء
    final loyaltyDiscount = _useLoyaltyPoints && loyaltyAccount != null
        ? (_pointsToRedeem * loyaltySettings.pointValueSar)
        : 0.0;

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
    final tax = VatCalculator.vatFromNet(netAmount: subtotal);
    final discount = cartState.discount;
    final total = subtotal + tax - discount - loyaltyDiscount;
    final change = _cashReceived - total;

    return CallbackShortcuts(
      bindings: {
        const SingleActivator(LogicalKeyboardKey.escape): () => context.pop(),
        const SingleActivator(LogicalKeyboardKey.enter): () {
          if (_canConfirm(total)) {
            _confirmPayment(
              total,
              loyaltyDiscount: loyaltyDiscount,
              loyaltyAccount: loyaltyAccount,
              loyaltySettings: loyaltySettings,
              storeId: ref.read(currentStoreIdProvider) ?? '',
              cashierId: ref.read(currentUserProvider)?.id ?? '',
            );
          }
        },
        const SingleActivator(LogicalKeyboardKey.digit1): () =>
            setState(() => _selectedMethod = PaymentMethod.cash),
        const SingleActivator(LogicalKeyboardKey.digit2): () {
          if (!isOffline && cardEnabledBySettings) {
            setState(() => _selectedMethod = PaymentMethod.card);
          }
        },
        const SingleActivator(LogicalKeyboardKey.digit3): () {
          if (!isOffline)
            setState(() => _selectedMethod = PaymentMethod.wallet);
        },
      },
      child: Focus(
        autofocus: true,
        child: PopScope(
          canPop: !_isProcessing,
          onPopInvokedWithResult: (didPop, result) {
            if (!didPop && _isProcessing) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(l10n.processingPayment),
                  duration: const Duration(seconds: 2),
                ),
              );
            }
          },
          child: Scaffold(
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            body: SafeArea(
              child: _showSuccess
                  ? PaymentSuccessState(scaleAnimation: _scaleAnimation)
                  : _isProcessing
                      ? const PaymentProcessingState()
                      : Column(
                          children: [
                            const OfflineBanner(),
                            Expanded(
                              child: _buildPaymentContent(
                                total,
                                subtotal,
                                tax,
                                discount,
                                change,
                                settings,
                                loyaltySettings,
                                loyaltyAccount,
                                loyaltyDiscount,
                              ),
                            ),
                          ],
                        ),
            ),
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
    LoyaltySettings loyaltySettings = const LoyaltySettings(),
    LoyaltyPointsTableData? loyaltyAccount,
    double loyaltyDiscount = 0.0,
  ]) {
    final l10n = AppLocalizations.of(context)!;
    final isDesktop = AppBreakpoints.isDesktop(context);
    final isMobile = context.isMobile;
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
                    l10n.paymentMethodTitle,
                    style: AppTypography.titleLarge.copyWith(
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  _buildPaymentMethods(
                      isOffline: _isOffline, settings: settings),
                  const SizedBox(height: AppSpacing.xl),
                  PaymentLoyaltyWidget(
                    loyaltySettings: loyaltySettings,
                    loyaltyAccount: loyaltyAccount,
                    hasCustomer: (ref.read(cartStateProvider).customerId ?? '')
                        .isNotEmpty,
                    useLoyaltyPoints: _useLoyaltyPoints,
                    pointsToRedeem: _pointsToRedeem,
                    loyaltyPointsController: _loyaltyPointsController,
                    onToggleLoyalty: (val) {
                      setState(() {
                        _useLoyaltyPoints = val;
                        if (!val) {
                          _pointsToRedeem = 0;
                          _loyaltyPointsController.clear();
                        }
                      });
                    },
                    onPointsChanged: (points) {
                      setState(() {
                        _pointsToRedeem = points;
                      });
                    },
                  ),
                  const SizedBox(height: AppSpacing.xxl),
                  _buildPaymentDetails(total, change),
                  const SizedBox(height: AppSpacing.xxl),
                  _buildSummaryPanel(
                    total,
                    subtotal,
                    tax,
                    discount,
                    change,
                    loyaltyDiscount,
                    loyaltySettings,
                    loyaltyAccount,
                  ),
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
                  padding: EdgeInsets.all(
                      isDesktop ? AppSpacing.xxl : AppSpacing.lg),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Payment Methods
                      Text(
                        l10n.paymentMethodTitle,
                        style: AppTypography.titleLarge.copyWith(
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      _buildPaymentMethods(
                          isOffline: _isOffline, settings: settings),

                      const SizedBox(height: AppSpacing.xl),

                      // Loyalty Points Widget
                      PaymentLoyaltyWidget(
                        loyaltySettings: loyaltySettings,
                        loyaltyAccount: loyaltyAccount,
                        hasCustomer:
                            (ref.read(cartStateProvider).customerId ?? '')
                                .isNotEmpty,
                        useLoyaltyPoints: _useLoyaltyPoints,
                        pointsToRedeem: _pointsToRedeem,
                        loyaltyPointsController: _loyaltyPointsController,
                        onToggleLoyalty: (val) {
                          setState(() {
                            _useLoyaltyPoints = val;
                            if (!val) {
                              _pointsToRedeem = 0;
                              _loyaltyPointsController.clear();
                            }
                          });
                        },
                        onPointsChanged: (points) {
                          setState(() {
                            _pointsToRedeem = points;
                          });
                        },
                      ),

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
            border: BorderDirectional(
              end: BorderSide(color: theme.dividerColor),
            ),
            boxShadow: AppShadows.lg,
          ),
          child: _buildSummaryPanel(
            total,
            subtotal,
            tax,
            discount,
            change,
            loyaltyDiscount,
            loyaltySettings,
            loyaltyAccount,
          ),
        ),
      ],
    );
  }

  Widget _buildHeader() {
    final l10n = AppLocalizations.of(context)!;
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
            tooltip: l10n.backEsc,
          ),

          const SizedBox(width: AppSpacing.md),

          // Title
          Text(
            l10n.completePayment,
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
                Icon(Icons.keyboard,
                    size: 16, color: theme.colorScheme.onSurfaceVariant),
                const SizedBox(width: AppSpacing.xs),
                Text(
                  l10n.enterToConfirm,
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
    final l10n = AppLocalizations.of(context)!;
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
              color: AlhaiColors.warning.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(AppRadius.md),
              border:
                  Border.all(color: AlhaiColors.warning.withValues(alpha: 0.4)),
            ),
            child: Row(
              children: [
                Icon(Icons.wifi_off, size: 20, color: AlhaiColors.warningDark),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    l10n.cashOnlyOffline,
                    style: AppTypography.bodyMedium.copyWith(
                      color: AlhaiColors.warningDark,
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
              color: AlhaiColors.info.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(AppRadius.md),
              border:
                  Border.all(color: AlhaiColors.info.withValues(alpha: 0.4)),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, size: 20, color: AlhaiColors.infoDark),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    l10n.cardsDisabledInSettings,
                    style: AppTypography.bodyMedium.copyWith(
                      color: AlhaiColors.infoDark,
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
              child: PaymentMethodCard(
                icon: Icons.payments_outlined,
                label: l10n.cashPayment,
                shortcut: '1',
                color: AppColors.cash,
                selected:
                    _selectedMethod == PaymentMethod.cash && !_isSplitPayment,
                onTap: () => setState(() {
                  _selectedMethod = PaymentMethod.cash;
                  _isSplitPayment = false;
                  _splitPayments = [];
                }),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: PaymentMethodCard(
                icon: Icons.credit_card,
                label: l10n.cardPayment,
                shortcut: '2',
                color: AppColors.card,
                selected:
                    _selectedMethod == PaymentMethod.card && !_isSplitPayment,
                onTap: cardDisabled
                    ? null
                    : () => setState(() {
                          _selectedMethod = PaymentMethod.card;
                          _isSplitPayment = false;
                          _splitPayments = [];
                        }),
                disabled: cardDisabled,
                disabledLabel: isOffline
                    ? l10n.unavailableOffline
                    : !settings.hasCardPayment
                        ? l10n.disabledInSettings
                        : null,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: PaymentMethodCard(
                icon: Icons.access_time,
                label: l10n.creditPayment,
                shortcut: '3',
                color: AppColors.debt,
                selected:
                    _selectedMethod == PaymentMethod.wallet && !_isSplitPayment,
                onTap: isOffline
                    ? null
                    : () => setState(() {
                          _selectedMethod = PaymentMethod.wallet;
                          _isSplitPayment = false;
                          _splitPayments = [];
                        }),
                disabled: isOffline,
                disabledLabel: isOffline ? l10n.unavailableOffline : null,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        // زر الدفع المقسم
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: isOffline
                ? null
                : () async {
                    final cartState = ref.read(cartStateProvider);
                    final subtotal = cartState.subtotal;
                    final tax = VatCalculator.vatFromNet(netAmount: subtotal);
                    final total = subtotal + tax - cartState.discount;
                    final splits = await split_dlg.SplitPaymentDialog.show(
                      context: context,
                      totalAmount: total,
                      customerName: cartState.customerName,
                    );
                    if (splits != null && splits.isNotEmpty && mounted) {
                      setState(() {
                        _isSplitPayment = true;
                        _splitPayments = splits;
                      });
                    }
                  },
            icon: const Icon(Icons.call_split_rounded),
            label: _isSplitPayment
                ? Text(AppLocalizations.of(context)!
                    .splitPaymentDone(_splitPayments.length))
                : Text(AppLocalizations.of(context)!.splitPaymentLabel),
            style: OutlinedButton.styleFrom(
              foregroundColor:
                  _isSplitPayment ? AppColors.success : AppColors.primary,
              side: BorderSide(
                  color:
                      _isSplitPayment ? AppColors.success : AppColors.primary),
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
            ),
          ),
        ),
      ],
    );
  }

  // ============================================================================
  // Payment Details
  // ============================================================================

  Widget _buildPaymentDetails(double total, double change) {
    switch (_selectedMethod) {
      case PaymentMethod.cash:
        return CashPaymentDetails(
          total: total,
          change: change,
          cashReceived: _cashReceived,
          cashReceivedController: _cashReceivedController,
          focusNode: _focusNode,
          onCashReceivedChanged: (value) {
            setState(() => _cashReceived = value);
          },
          onQuickAmountSelected: _setAmount,
        );
      case PaymentMethod.card:
        return CardPaymentDetails(
          cardRrnController: _cardRrnController,
          onChanged: () => setState(() {}),
        );
      case PaymentMethod.wallet:
      case PaymentMethod.bankTransfer:
        final customerId = ref.read(cartStateProvider).customerId;
        final hasCustomer = customerId != null && customerId.isNotEmpty;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const CreditPaymentDetails(),
            if (!hasCustomer) ...[
              const SizedBox(height: AppSpacing.md),
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: AppColors.error.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  border:
                      Border.all(color: AppColors.error.withValues(alpha: 0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.person_off,
                        color: AppColors.error, size: 22),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Text(
                        l10n.selectCustomerFirstError,
                        style: AppTypography.bodyMedium.copyWith(
                          color: AppColors.error,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        );
    }
  }

  // ============================================================================
  // Summary Panel
  // ============================================================================

  Widget _buildSummaryPanel(
    double total,
    double subtotal,
    double tax,
    double discount,
    double change, [
    double loyaltyDiscount = 0.0,
    LoyaltySettings loyaltySettings = const LoyaltySettings(),
    LoyaltyPointsTableData? loyaltyAccount,
  ]) {
    final storeId = ref.read(currentStoreIdProvider) ?? '';
    final cashierId = ref.read(currentUserProvider)?.id ?? '';

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
                l10n.orderSummary,
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
                PaymentSummaryRow(label: l10n.subtotalLabel, value: subtotal),
                const SizedBox(height: AppSpacing.md),
                PaymentSummaryRow(label: l10n.taxLabel, value: tax),
                if (discount > 0) ...[
                  const SizedBox(height: AppSpacing.md),
                  PaymentSummaryRow(
                    label: l10n.discountLabel(''),
                    value: -discount,
                    valueColor: AppColors.success,
                  ),
                ],
                // صف خصم الولاء
                if (loyaltyDiscount > 0) ...[
                  const SizedBox(height: AppSpacing.md),
                  PaymentSummaryRow(
                    label: AppLocalizations.of(context)!
                        .loyaltyPointsDiscountLabel(_pointsToRedeem),
                    value: -loyaltyDiscount,
                    valueColor: AppColors.success,
                    icon: Icons.stars_rounded,
                  ),
                ],

                const Divider(height: AppSpacing.xxl),

                // Total
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      l10n.requiredAmount,
                      style: AppTypography.titleMedium.copyWith(
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      '${total.toStringAsFixed(2)} ${l10n.sar}',
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
                    label: l10n.confirmPayment,
                    icon: Icons.check_circle,
                    size: ButtonSize.large,
                    onPressed: _canConfirm(total)
                        ? () => _confirmPayment(
                              total,
                              loyaltyDiscount: loyaltyDiscount,
                              loyaltyAccount: loyaltyAccount,
                              loyaltySettings: loyaltySettings,
                              storeId: storeId,
                              cashierId: cashierId,
                            )
                        : null,
                    isLoading: _isProcessing,
                  ),
                ),

                const SizedBox(height: AppSpacing.md),

                // Cancel Button
                SizedBox(
                  width: double.infinity,
                  child: AppButton.ghost(
                    label: l10n.cancelAction,
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

  // ============================================================================
  // WhatsApp Phone Input
  // ============================================================================

  Widget _buildWhatsAppPhoneInput() {
    final theme = Theme.of(context);
    const whatsAppColor = AppColors.whatsappGreen;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: () => setState(() => _showPhoneInput = !_showPhoneInput),
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: AlhaiSpacing.xs),
            child: Row(
              children: [
                Icon(
                  _showPhoneInput
                      ? Icons.check_box
                      : Icons.check_box_outline_blank,
                  color: whatsAppColor,
                  size: 20,
                ),
                const SizedBox(width: AlhaiSpacing.xs),
                Text(l10n.whatsappReceipt,
                    style: TextStyle(
                        fontSize: 14, color: theme.colorScheme.onSurface)),
                const SizedBox(width: AlhaiSpacing.xxs),
                Icon(Icons.chat, size: 16, color: whatsAppColor),
              ],
            ),
          ),
        ),
        if (_showPhoneInput) ...[
          const SizedBox(height: AlhaiSpacing.xs),
          TextField(
            controller: _phoneController,
            keyboardType: TextInputType.phone,
            textDirection: TextDirection.ltr,
            decoration: InputDecoration(
              prefixText: '+966 ',
              hintText: '5X XXX XXXX',
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              contentPadding: const EdgeInsets.symmetric(
                  horizontal: AlhaiSpacing.sm, vertical: 10),
              isDense: true,
              suffixIcon:
                  Icon(Icons.phone_android, size: 18, color: whatsAppColor),
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
        return l10n.payCash;
      case PaymentMethod.card:
        return l10n.payCard;
      case PaymentMethod.wallet:
      case PaymentMethod.bankTransfer:
        return l10n.payCreditSale;
    }
  }

  bool _canConfirm(double total) {
    if (_isSplitPayment) return _splitPayments.isNotEmpty;
    switch (_selectedMethod) {
      case PaymentMethod.cash:
        return _cashReceived >= total;
      case PaymentMethod.card:
        return _cardRrnController.text.isNotEmpty;
      case PaymentMethod.wallet:
      case PaymentMethod.bankTransfer:
        // BUG FIX: credit/wallet payment requires a customer to track the debt
        final customerId = ref.read(cartStateProvider).customerId;
        return customerId != null && customerId.isNotEmpty;
    }
  }

  Future<void> _confirmPayment(
    double total, {
    double loyaltyDiscount = 0.0,
    LoyaltyPointsTableData? loyaltyAccount,
    LoyaltySettings loyaltySettings = const LoyaltySettings(),
    String storeId = '',
    String cashierId = '',
  }) async {
    setState(() => _isProcessing = true);

    try {
      final cartState = ref.read(cartStateProvider);
      final resolvedStoreId =
          storeId.isNotEmpty ? storeId : ref.read(currentStoreIdProvider) ?? '';
      final resolvedCashierId = cashierId.isNotEmpty
          ? cashierId
          : ref.read(currentUserProvider)?.id ?? '';

      if (resolvedStoreId.isEmpty || resolvedCashierId.isEmpty) {
        throw Exception(l10n.storeOrUserNotSet);
      }

      final saleService = GetIt.I<SaleService>();
      final subtotal = cartState.subtotal;
      final tax = VatCalculator.vatFromNet(netAmount: subtotal);

      // جلب معرف الوردية المفتوحة (nullable — لا يمنع البيع إذا لم توجد وردية)
      final openShift = await ref.read(openShiftProvider.future);

      final saleResult = await saleService.createSale(
        storeId: resolvedStoreId,
        cashierId: resolvedCashierId,
        items: cartState.items,
        subtotal: subtotal,
        discount: cartState.discount + loyaltyDiscount,
        tax: tax,
        total: total,
        paymentMethod: _isSplitPayment ? 'mixed' : _selectedMethod.name,
        customerId: cartState.customerId,
        notes: cartState.notes,
        shiftId: openShift?.id,
      );
      final saleId = saleResult.saleId;

      if (saleResult.hadPriceCorrections) {
        for (final correction in saleResult.priceCorrections) {
          debugPrint(
              '[PaymentScreen] Price corrected at sale time: $correction');
        }
      }

      // معالجة نقاط الولاء بعد إتمام البيع (غير مؤثرة على البيع إذا فشلت)
      if (cartState.customerId != null && cartState.customerId!.isNotEmpty) {
        await _processLoyaltyAfterSale(
          saleId: saleId,
          storeId: resolvedStoreId,
          cashierId: resolvedCashierId,
          customerId: cartState.customerId!,
          saleAmount: subtotal + tax,
          loyaltyAccount: loyaltyAccount,
          loyaltySettings: loyaltySettings,
        );
      }

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
            content: Text(l10n.errorWithMessage(e.toString())),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  // ============================================================================
  // معالجة نقاط الولاء بعد البيع
  // ============================================================================

  Future<void> _processLoyaltyAfterSale({
    required String saleId,
    required String storeId,
    required String cashierId,
    required String customerId,
    required double saleAmount,
    required LoyaltyPointsTableData? loyaltyAccount,
    required LoyaltySettings loyaltySettings,
  }) async {
    if (!loyaltySettings.isEnabled) return;

    try {
      final db = GetIt.I<AppDatabase>();
      const uuid = Uuid();

      // إنشاء حساب ولاء تلقائياً إن لم يكن موجوداً
      LoyaltyPointsTableData? account = loyaltyAccount;
      if (account == null) {
        final newId = uuid.v4();
        await db.loyaltyDao.createLoyalty(LoyaltyPointsTableCompanion.insert(
          id: newId,
          customerId: customerId,
          storeId: storeId,
          createdAt: DateTime.now(),
        ));
        account = await db.loyaltyDao.getCustomerLoyalty(customerId, storeId);
        if (account == null) return;
      }

      // 1. خصم نقاط الاستبدال (إن طلب العميل الاستبدال)
      if (_useLoyaltyPoints && _pointsToRedeem > 0) {
        final redeemed = await db.loyaltyDao.redeemPoints(
          customerId,
          storeId,
          _pointsToRedeem,
        );

        if (redeemed) {
          final updatedAccount =
              await db.loyaltyDao.getCustomerLoyalty(customerId, storeId);
          await db.loyaltyDao.logTransaction(
            LoyaltyTransactionsTableCompanion.insert(
              id: uuid.v4(),
              loyaltyId: account.id,
              customerId: customerId,
              storeId: storeId,
              transactionType: 'redeem',
              points: -_pointsToRedeem,
              balanceAfter: updatedAccount?.currentPoints ?? 0,
              saleId: Value(saleId),
              saleAmount: Value(saleAmount),
              description: Value('استبدال نقاط - فاتورة $saleId'),
              cashierId: Value(cashierId),
              createdAt: DateTime.now(),
            ),
          );
        }
      }

      // 2. إضافة نقاط مكتسبة من هذا البيع
      final earnedPoints =
          (saleAmount * loyaltySettings.pointsPerRiyal).floor();
      if (earnedPoints > 0) {
        await db.loyaltyDao.addPoints(customerId, storeId, earnedPoints);
        final updatedAccount =
            await db.loyaltyDao.getCustomerLoyalty(customerId, storeId);
        await db.loyaltyDao.logTransaction(
          LoyaltyTransactionsTableCompanion.insert(
            id: uuid.v4(),
            loyaltyId: account.id,
            customerId: customerId,
            storeId: storeId,
            transactionType: 'earn',
            points: earnedPoints,
            balanceAfter: updatedAccount?.currentPoints ?? 0,
            saleId: Value(saleId),
            saleAmount: Value(saleAmount),
            description: Value('نقاط مكتسبة - فاتورة $saleId'),
            cashierId: Value(cashierId),
            createdAt: DateTime.now(),
          ),
        );
      }
    } catch (_) {
      // لا تؤثر أخطاء الولاء على إتمام البيع
    }
  }
}
