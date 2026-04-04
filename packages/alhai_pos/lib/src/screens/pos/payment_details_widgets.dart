/// Payment Details Widgets
///
/// Method-specific detail sections and processing/success states:
/// - [CashPaymentDetails] - cash input with quick amounts and change display
/// - [CardPaymentDetails] - card RRN input with instructions
/// - [CreditPaymentDetails] - credit sale warning
/// - [PaymentProcessingState] - processing spinner
/// - [PaymentSuccessState] - success animation
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:alhai_shared_ui/alhai_shared_ui.dart';
import 'package:alhai_l10n/alhai_l10n.dart';

import 'payment_sub_widgets.dart';

// ============================================================================
// CashPaymentDetails
// ============================================================================

/// Cash payment details: amount input, quick-select chips, and change display.
class CashPaymentDetails extends StatelessWidget {
  final double total;
  final double change;
  final double cashReceived;
  final TextEditingController cashReceivedController;
  final FocusNode focusNode;
  final ValueChanged<double> onCashReceivedChanged;
  final ValueChanged<double> onQuickAmountSelected;

  const CashPaymentDetails({
    super.key,
    required this.total,
    required this.change,
    required this.cashReceived,
    required this.cashReceivedController,
    required this.focusNode,
    required this.onCashReceivedChanged,
    required this.onQuickAmountSelected,
  });

  @override
  Widget build(BuildContext context) {
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
            controller: cashReceivedController,
            focusNode: focusNode,
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
              onCashReceivedChanged(double.tryParse(value) ?? 0);
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
            QuickAmountChip(
              label: AppLocalizations.of(context)!.requiredAmount,
              amount: total,
              color: AppColors.primary,
              onTap: () => onQuickAmountSelected(total),
            ),
            QuickAmountChip(amount: 50, onTap: () => onQuickAmountSelected(50)),
            QuickAmountChip(
                amount: 100, onTap: () => onQuickAmountSelected(100)),
            QuickAmountChip(
                amount: 200, onTap: () => onQuickAmountSelected(200)),
            QuickAmountChip(
                amount: 500, onTap: () => onQuickAmountSelected(500)),
          ],
        ),

        const SizedBox(height: AppSpacing.xxl),

        // Change Display
        AnimatedContainer(
          duration: AppDurations.normal,
          padding: const EdgeInsets.all(AppSpacing.xl),
          decoration: BoxDecoration(
            color:
                change >= 0 ? AppColors.successSurface : AppColors.errorSurface,
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
}

// ============================================================================
// CardPaymentDetails
// ============================================================================

/// Card payment details: RRN input and instructions.
class CardPaymentDetails extends StatelessWidget {
  final TextEditingController cardRrnController;
  final VoidCallback onChanged;

  const CardPaymentDetails({
    super.key,
    required this.cardRrnController,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
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
            controller: cardRrnController,
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
            onChanged: (_) => onChanged(),
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
}

// ============================================================================
// CreditPaymentDetails
// ============================================================================

/// Credit/deferred payment details with warning.
class CreditPaymentDetails extends StatelessWidget {
  const CreditPaymentDetails({super.key});

  @override
  Widget build(BuildContext context) {
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
              const Icon(Icons.warning_amber,
                  color: AppColors.warning, size: 24),
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
}

// ============================================================================
// PaymentProcessingState
// ============================================================================

/// Full-screen processing state with spinner.
class PaymentProcessingState extends StatelessWidget {
  const PaymentProcessingState({super.key});

  @override
  Widget build(BuildContext context) {
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
}

// ============================================================================
// PaymentSuccessState
// ============================================================================

/// Full-screen success state with scale animation.
class PaymentSuccessState extends StatelessWidget {
  final Animation<double> scaleAnimation;

  const PaymentSuccessState({
    super.key,
    required this.scaleAnimation,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ScaleTransition(
        scale: scaleAnimation,
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
}
