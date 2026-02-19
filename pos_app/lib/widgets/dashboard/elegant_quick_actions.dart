import 'package:flutter/material.dart';
import '../../core/responsive/responsive_utils.dart';
import '../../core/theme/app_colors.dart';
import '../../l10n/generated/app_localizations.dart';

/// Compact green gradient quick actions card with 2x2 button grid
class ElegantQuickActions extends StatelessWidget {
  final VoidCallback? onNewSale;
  final VoidCallback? onAddProduct;
  final VoidCallback? onRefund;
  final VoidCallback? onDailyReport;

  const ElegantQuickActions({
    super.key,
    this.onNewSale,
    this.onAddProduct,
    this.onRefund,
    this.onDailyReport,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    final actions = [
      _QuickAction(
        icon: Icons.shopping_cart_checkout_rounded,
        label: l10n.newSale,
        isPrimary: true,
        onTap: onNewSale,
      ),
      _QuickAction(
        icon: Icons.add_box_rounded,
        label: l10n.addProduct,
        onTap: onAddProduct,
      ),
      _QuickAction(
        icon: Icons.replay_rounded,
        label: l10n.refund,
        onTap: onRefund,
      ),
      _QuickAction(
        icon: Icons.description_rounded,
        label: l10n.dailyReport,
        onTap: onDailyReport,
      ),
    ];

    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: AlignmentDirectional.topStart,
          end: AlignmentDirectional.bottomEnd,
          colors: [
            AppColors.primary, // #10B981
            Color(0xFF047857), // primary-dark
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.3),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          children: [
            // Main content — MUST be first (non-Positioned) to give Stack its size
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title inside the gradient card
                  Text(
                    l10n.quickAction,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 16),

                  // 2x2 Grid of action buttons
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: actions.length,
                    gridDelegate:
                        SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: getResponsiveGridColumns(context, mobile: 2, desktop: 3),
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      childAspectRatio: 1.3,
                    ),
                    itemBuilder: (context, index) => _QuickActionButton(
                      action: actions[index],
                    ),
                  ),
                ],
              ),
            ),

            // Decorative blur circle in top-right corner (Positioned — after non-Positioned)
            Positioned(
              top: -30,
              right: -30,
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.1),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Data model for a quick action button
class _QuickAction {
  final IconData icon;
  final String label;
  final bool isPrimary;
  final VoidCallback? onTap;

  const _QuickAction({
    required this.icon,
    required this.label,
    this.isPrimary = false,
    this.onTap,
  });
}

/// White semi-transparent button for quick actions
class _QuickActionButton extends StatelessWidget {
  final _QuickAction action;

  const _QuickActionButton({
    required this.action,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: action.onTap,
        borderRadius: BorderRadius.circular(16),
        splashColor: Colors.white.withValues(alpha: 0.1),
        highlightColor: Colors.white.withValues(alpha: 0.05),
        child: Container(
          decoration: BoxDecoration(
            color: action.isPrimary
                ? Colors.white.withValues(alpha: 0.2)
                : Colors.white.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: action.isPrimary
                  ? Colors.white.withValues(alpha: 0.1)
                  : Colors.white.withValues(alpha: 0.05),
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                action.icon,
                color: Colors.white,
                size: 28,
              ),
              const SizedBox(height: 8),
              Text(
                action.label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
