/// Payment Loyalty Widget
///
/// Loyalty points section for the payment screen:
/// - [LoyaltySettings] - loyalty system settings model
/// - [customerLoyaltyProvider] - provider for customer loyalty data
/// - [loyaltySettingsProvider] - provider for loyalty settings
/// - [PaymentLoyaltyWidget] - the loyalty points widget
/// - [LoyaltyQuickChip] - quick-select chip for points
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:alhai_shared_ui/alhai_shared_ui.dart';
import 'package:alhai_l10n/alhai_l10n.dart';
import 'package:get_it/get_it.dart';
import 'package:alhai_database/alhai_database.dart';

// ============================================================================
// LoyaltySettings
// ============================================================================

/// Loyalty system settings model.
class LoyaltySettings {
  final bool isEnabled;
  final int pointsPerRiyal;
  final double pointValueSar;

  const LoyaltySettings({
    this.isEnabled = false,
    this.pointsPerRiyal = 1,
    this.pointValueSar = 0.05,
  });
}

// ============================================================================
// Loyalty Providers
// ============================================================================

/// Provider for customer loyalty points data.
final customerLoyaltyProvider = FutureProvider.autoDispose
    .family<LoyaltyPointsTableData?, String>((ref, customerId) async {
  if (customerId.isEmpty) return null;
  final storeId = ref.watch(currentStoreIdProvider);
  if (storeId == null) return null;
  final db = GetIt.I<AppDatabase>();
  return db.loyaltyDao.getCustomerLoyalty(customerId, storeId);
});

/// Provider for loyalty system settings.
final loyaltySettingsProvider =
    FutureProvider.autoDispose<LoyaltySettings>((ref) async {
  final storeId = ref.watch(currentStoreIdProvider);
  if (storeId == null) return const LoyaltySettings();

  final db = GetIt.I<AppDatabase>();
  try {
    final rows = await (db.select(db.settingsTable)
          ..where((s) => s.storeId.equals(storeId)))
        .get();
    final map = <String, String>{for (final r in rows) r.key: r.value};

    return LoyaltySettings(
      isEnabled: map['loyalty_enabled'] == 'true',
      pointsPerRiyal: int.tryParse(map['loyalty_points_per_rial'] ?? '') ?? 1,
      pointValueSar:
          double.tryParse(map['loyalty_point_value_sar'] ?? '') ?? 0.05,
    );
  } catch (_) {
    return const LoyaltySettings();
  }
});

// ============================================================================
// PaymentLoyaltyWidget
// ============================================================================

/// Loyalty points widget for the payment screen.
///
/// Shows available loyalty points, allows toggling redemption,
/// entering points to redeem, and quick-select chips.
class PaymentLoyaltyWidget extends StatelessWidget {
  final LoyaltySettings loyaltySettings;
  final LoyaltyPointsTableData? loyaltyAccount;
  final bool hasCustomer;
  final bool useLoyaltyPoints;
  final int pointsToRedeem;
  final TextEditingController loyaltyPointsController;
  final ValueChanged<bool> onToggleLoyalty;
  final ValueChanged<int> onPointsChanged;

  const PaymentLoyaltyWidget({
    super.key,
    required this.loyaltySettings,
    required this.loyaltyAccount,
    required this.hasCustomer,
    required this.useLoyaltyPoints,
    required this.pointsToRedeem,
    required this.loyaltyPointsController,
    required this.onToggleLoyalty,
    required this.onPointsChanged,
  });

  @override
  Widget build(BuildContext context) {
    // Don't show the widget if loyalty is not enabled, no customer, or no loyalty account
    if (!loyaltySettings.isEnabled ||
        loyaltyAccount == null ||
        !hasCustomer) {
      return const SizedBox.shrink();
    }

    final availablePoints = loyaltyAccount!.currentPoints;
    final maxSarEquivalent = availablePoints * loyaltySettings.pointValueSar;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      decoration: BoxDecoration(
        color: useLoyaltyPoints
            ? (isDark ? AppColors.success.withValues(alpha: 0.1) : AppColors.successSurface)
            : (isDark ? AppColors.warning.withValues(alpha: 0.1) : AppColors.warningSurface),
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(
          color: useLoyaltyPoints
              ? AppColors.success.withValues(alpha: 0.5)
              : AppColors.warning.withValues(alpha: 0.5),
          width: 1.5,
        ),
      ),
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Icon(
                Icons.stars_rounded,
                color: useLoyaltyPoints ? AppColors.success : AppColors.warning,
                size: 22,
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                AppLocalizations.of(context)!.availableLoyaltyPoints(availablePoints.toString(), maxSarEquivalent.toStringAsFixed(2)),
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              Switch(
                value: useLoyaltyPoints,
                activeThumbColor: AppColors.success,
                onChanged: onToggleLoyalty,
              ),
            ],
          ),

          if (useLoyaltyPoints) ...[
            const SizedBox(height: AppSpacing.md),
            Text(
              AppLocalizations.of(context)!.useLoyaltyPoints,
              style: AppTypography.labelLarge.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),

            // Points input
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: loyaltyPointsController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    decoration: InputDecoration(
                      hintText: AppLocalizations.of(context)!.pointsCountHint(availablePoints.toString()),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppRadius.md),
                        borderSide: const BorderSide(color: AppColors.border),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppRadius.md),
                        borderSide: const BorderSide(color: AppColors.success, width: 2),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md,
                        vertical: AppSpacing.sm,
                      ),
                      isDense: true,
                      suffixText: AppLocalizations.of(context)!.pointsUnitLabel,
                    ),
                    onChanged: (val) {
                      final entered = int.tryParse(val) ?? 0;
                      final clamped = entered.clamp(0, availablePoints);
                      onPointsChanged(clamped);
                      // Correct value if it exceeds maximum
                      if (entered > availablePoints) {
                        loyaltyPointsController.text = availablePoints.toString();
                        loyaltyPointsController.selection = TextSelection.fromPosition(
                          TextPosition(offset: loyaltyPointsController.text.length),
                        );
                      }
                    },
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                // Discount value display
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.sm,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.successSurface,
                    borderRadius: BorderRadius.circular(AppRadius.md),
                    border: Border.all(color: AppColors.success.withValues(alpha: 0.3)),
                  ),
                  child: Text(
                    AppLocalizations.of(context)!.discountAmountSar((pointsToRedeem * loyaltySettings.pointValueSar).toStringAsFixed(2)),
                    style: AppTypography.labelLarge.copyWith(
                      color: AppColors.success,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: AppSpacing.sm),

            // Quick select chips
            Wrap(
              spacing: AppSpacing.sm,
              children: [
                LoyaltyQuickChip(
                  label: AppLocalizations.of(context)!.allPointsLabel,
                  points: availablePoints,
                  onSelected: onPointsChanged,
                  controller: loyaltyPointsController,
                ),
                LoyaltyQuickChip(
                  label: AppLocalizations.of(context)!.pointsCountLabel((availablePoints * 0.5).floor().toString()),
                  points: (availablePoints * 0.5).floor(),
                  onSelected: onPointsChanged,
                  controller: loyaltyPointsController,
                ),
                LoyaltyQuickChip(
                  label: AppLocalizations.of(context)!.pointsCountLabel((availablePoints * 0.25).floor().toString()),
                  points: (availablePoints * 0.25).floor(),
                  onSelected: onPointsChanged,
                  controller: loyaltyPointsController,
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

// ============================================================================
// LoyaltyQuickChip
// ============================================================================

/// Quick-select chip for loyalty points.
class LoyaltyQuickChip extends StatelessWidget {
  final String label;
  final int points;
  final ValueChanged<int> onSelected;
  final TextEditingController controller;

  const LoyaltyQuickChip({
    super.key,
    required this.label,
    required this.points,
    required this.onSelected,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    if (points <= 0) return const SizedBox.shrink();
    return ActionChip(
      label: Text(label),
      avatar: const Icon(Icons.bolt, size: 14),
      backgroundColor: AppColors.successSurface,
      side: BorderSide(color: AppColors.success.withValues(alpha: 0.4)),
      labelStyle: AppTypography.labelMedium.copyWith(color: AppColors.success),
      onPressed: () {
        onSelected(points);
        controller.text = points.toString();
      },
    );
  }
}
