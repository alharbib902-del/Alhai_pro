/// Quick Actions Panel - لوحة الإجراءات السريعة
///
/// لوحة الإجراءات السريعة مع خلفية متدرجة للداشبورد
library;

import 'package:flutter/material.dart';
import 'package:alhai_design_system/alhai_design_system.dart';
import 'package:alhai_l10n/alhai_l10n.dart';

/// لوحة الإجراءات السريعة بتدرج لوني
class QuickActionsPanel extends StatelessWidget {
  final VoidCallback? onNewSale;
  final VoidCallback? onAddProduct;
  final VoidCallback? onRefund;
  final VoidCallback? onDailyReport;
  final VoidCallback? onInventory;
  final VoidCallback? onCustomers;
  final VoidCallback? onSettings;
  final VoidCallback? onCloseDay;
  final String? inventoryBadge;
  final int crossAxisCount;

  const QuickActionsPanel({
    super.key,
    this.onNewSale,
    this.onAddProduct,
    this.onRefund,
    this.onDailyReport,
    this.onInventory,
    this.onCustomers,
    this.onSettings,
    this.onCloseDay,
    this.inventoryBadge,
    this.crossAxisCount = 4,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Container(
      padding: const EdgeInsets.all(AlhaiSpacing.lg),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: AlignmentDirectional.topStart,
          end: AlignmentDirectional.bottomEnd,
          colors: [
            AppColors.primary,
            Color(0xFF047857), // primary-dark
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withAlpha(77),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        children: [
          // الدائرة الضبابية في الخلفية
          PositionedDirectional(
            end: -40,
            top: -60,
            child: Container(
              width: 160,
              height: 160,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withAlpha(26),
              ),
            ),
          ),

          // المحتوى
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // العنوان
              Text(
                l10n.quickAction,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),

              SizedBox(height: AlhaiSpacing.md),

              // أزرار الإجراءات
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 1.0,
                ),
                itemCount: 8,
                itemBuilder: (context, index) {
                  final actions = [
                    (
                      Icons.shopping_cart_checkout_rounded,
                      l10n.newSale,
                      onNewSale,
                      true,
                      null,
                    ),
                    (
                      Icons.add_box_rounded,
                      l10n.addProduct,
                      onAddProduct,
                      false,
                      null,
                    ),
                    (Icons.replay_rounded, l10n.refund, onRefund, false, null),
                    (
                      Icons.description_rounded,
                      l10n.dailyReport,
                      onDailyReport,
                      false,
                      null,
                    ),
                    (
                      Icons.inventory_2_rounded,
                      l10n.inventory,
                      onInventory,
                      false,
                      inventoryBadge,
                    ),
                    (
                      Icons.people_rounded,
                      l10n.customers,
                      onCustomers,
                      false,
                      null,
                    ),
                    (
                      Icons.settings_rounded,
                      l10n.settings,
                      onSettings,
                      false,
                      null,
                    ),
                    (
                      Icons.nightlight_round,
                      l10n.closeDay,
                      onCloseDay,
                      false,
                      null,
                    ),
                  ];
                  final action = actions[index];
                  return _QuickActionItem(
                    icon: action.$1,
                    label: action.$2,
                    onTap: action.$3,
                    isPrimary: action.$4,
                    badge: action.$5,
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// عنصر إجراء سريع
class _QuickActionItem extends StatefulWidget {
  final IconData icon;
  final String label;
  final bool isPrimary;
  final VoidCallback? onTap;
  final String? badge;

  const _QuickActionItem({
    required this.icon,
    required this.label,
    this.isPrimary = false,
    this.onTap,
    this.badge,
  });

  @override
  State<_QuickActionItem> createState() => _QuickActionItemState();
}

class _QuickActionItemState extends State<_QuickActionItem> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: AlhaiDurations.standard,
          padding: const EdgeInsets.all(AlhaiSpacing.md),
          decoration: BoxDecoration(
            color: widget.isPrimary
                ? Colors.white.withAlpha(_isHovered ? 64 : 51)
                : Colors.white.withAlpha(_isHovered ? 38 : 26),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: widget.isPrimary
                  ? Colors.white.withAlpha(38)
                  : Colors.white.withAlpha(13),
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // الأيقونة
              AnimatedScale(
                scale: _isHovered ? 1.1 : 1.0,
                duration: AlhaiDurations.standard,
                child: Icon(
                  widget.icon,
                  color: Colors.white,
                  size: widget.isPrimary ? 32 : 24,
                ),
              ),

              SizedBox(height: AlhaiSpacing.xs),

              // النص
              Text(
                widget.label,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: widget.isPrimary ? 14 : 12,
                  fontWeight: FontWeight.w500,
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
