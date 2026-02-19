/// Quick Actions Panel - لوحة الإجراءات السريعة
///
/// لوحة الإجراءات السريعة مع خلفية متدرجة للداشبورد
library;

import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../l10n/generated/app_localizations.dart';

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
    final l10n = AppLocalizations.of(context)!;
    
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
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
          Positioned(
            right: -40,
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
              
              const SizedBox(height: 16),
              
              // أزرار الإجراءات
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: crossAxisCount,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 1.0,
                children: [
                  // بيع جديد (زر أساسي)
                  _QuickActionItem(
                    icon: Icons.shopping_cart_checkout_rounded,
                    label: l10n.newSale,
                    isPrimary: true,
                    onTap: onNewSale,
                  ),
                  
                  // إضافة منتج
                  _QuickActionItem(
                    icon: Icons.add_box_rounded,
                    label: l10n.addProduct,
                    onTap: onAddProduct,
                  ),
                  
                  // استرجاع
                  _QuickActionItem(
                    icon: Icons.replay_rounded,
                    label: l10n.refund,
                    onTap: onRefund,
                  ),
                  
                  // تقرير يومي
                  _QuickActionItem(
                    icon: Icons.description_rounded,
                    label: l10n.dailyReport,
                    onTap: onDailyReport,
                  ),
                  
                  // المخزون
                  _QuickActionItem(
                    icon: Icons.inventory_2_rounded,
                    label: l10n.inventory,
                    badge: inventoryBadge,
                    onTap: onInventory,
                  ),
                  
                  // العملاء
                  _QuickActionItem(
                    icon: Icons.people_rounded,
                    label: l10n.customers,
                    onTap: onCustomers,
                  ),
                  
                  // الإعدادات
                  _QuickActionItem(
                    icon: Icons.settings_rounded,
                    label: l10n.settings,
                    onTap: onSettings,
                  ),
                  
                  // إغلاق اليوم
                  _QuickActionItem(
                    icon: Icons.nightlight_round,
                    label: l10n.closeDay,
                    onTap: onCloseDay,
                  ),
                ],
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
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(16),
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
                duration: const Duration(milliseconds: 200),
                child: Icon(
                  widget.icon,
                  color: Colors.white,
                  size: widget.isPrimary ? 32 : 24,
                ),
              ),
              
              const SizedBox(height: 8),
              
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
