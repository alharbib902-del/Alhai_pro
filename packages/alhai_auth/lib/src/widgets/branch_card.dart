/// Branch Card Widget - كارت الفرع
///
/// كارت يعرض معلومات الفرع مع حالته ونوعه
library;

import 'package:flutter/material.dart';
import 'package:alhai_design_system/alhai_design_system.dart';
import 'package:alhai_l10n/alhai_l10n.dart';

/// نوع الفرع
enum BranchType {
  /// متجر
  store,

  /// مستودع
  warehouse,

  /// كشك
  kiosk,

  /// مطعم
  restaurant,

  /// صالون
  salon,
}

/// حالة الفرع
enum BranchStatus {
  /// مفتوح الآن
  open,

  /// مغلق
  closed,

  /// قريباً
  comingSoon,
}

/// بيانات الفرع
class BranchData {
  final String id;
  final String name;
  final String? address;
  final BranchType type;
  final BranchStatus status;
  final String? imageUrl;
  final bool isDefault;
  final String? closedUntil; // وقت فتح الفرع المغلق

  const BranchData({
    required this.id,
    required this.name,
    this.address,
    this.type = BranchType.store,
    this.status = BranchStatus.open,
    this.imageUrl,
    this.isDefault = false,
    this.closedUntil,
  });
}

/// أيقونة نوع الفرع
class _BranchTypeIcon extends StatelessWidget {
  final BranchType type;
  final double size;

  const _BranchTypeIcon({
    required this.type,
    this.size = 24,
  });

  IconData get _icon {
    switch (type) {
      case BranchType.store:
        return Icons.store_rounded;
      case BranchType.warehouse:
        return Icons.warehouse_rounded;
      case BranchType.kiosk:
        return Icons.storefront_rounded;
      case BranchType.restaurant:
        return Icons.restaurant_rounded;
      case BranchType.salon:
        return Icons.content_cut_rounded;
    }
  }

  Color get _defaultColor {
    switch (type) {
      case BranchType.store:
        return AppColors.primary;
      case BranchType.warehouse:
        return const Color(0xFF8B5CF6); // Purple
      case BranchType.kiosk:
        return const Color(0xFFF59E0B); // Amber
      case BranchType.restaurant:
        return const Color(0xFFEF4444); // Red
      case BranchType.salon:
        return const Color(0xFFEC4899); // Pink
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(size * 0.4),
      decoration: BoxDecoration(
        color: _defaultColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(size * 0.4),
      ),
      child: Icon(
        _icon,
        size: size,
        color: _defaultColor,
      ),
    );
  }
}

/// شارة حالة الفرع
class BranchStatusBadge extends StatelessWidget {
  final BranchStatus status;
  final bool compact;

  const BranchStatusBadge({
    super.key,
    required this.status,
    this.compact = false,
  });

  String _text(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    switch (status) {
      case BranchStatus.open:
        return 'مفتوح الآن';
      case BranchStatus.closed:
        return l10n.closed;
      case BranchStatus.comingSoon:
        return l10n.comingSoon;
    }
  }

  Color get _color {
    switch (status) {
      case BranchStatus.open:
        return AppColors.success;
      case BranchStatus.closed:
        return AppColors.error;
      case BranchStatus.comingSoon:
        return AppColors.warning;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? AlhaiSpacing.xs : AlhaiSpacing.sm,
        vertical: compact ? AlhaiSpacing.xxs : 6,
      ),
      decoration: BoxDecoration(
        color: _color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: _color.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: AlhaiSpacing.xs,
            height: AlhaiSpacing.xs,
            decoration: BoxDecoration(
              color: _color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            _text(context),
            style: TextStyle(
              color: _color,
              fontSize: compact ? 11 : 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

/// كارت الفرع
class BranchCard extends StatelessWidget {
  final BranchData branch;
  final VoidCallback? onTap;
  final bool isSelected;
  final bool showStatus;
  final bool compact;

  const BranchCard({
    super.key,
    required this.branch,
    this.onTap,
    this.isSelected = false,
    this.showStatus = true,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin:
          EdgeInsets.only(bottom: compact ? AlhaiSpacing.xs : AlhaiSpacing.sm),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding:
                EdgeInsets.all(compact ? AlhaiSpacing.sm : AlhaiSpacing.md),
            decoration: BoxDecoration(
              color: isSelected
                  ? AppColors.primary.withValues(alpha: 0.05)
                  : Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isSelected ? AppColors.primary : AppColors.border,
                width: isSelected ? 2 : 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                // أيقونة نوع الفرع
                _BranchTypeIcon(
                  type: branch.type,
                  size: compact ? 20 : 24,
                ),

                SizedBox(width: compact ? AlhaiSpacing.sm : AlhaiSpacing.md),

                // معلومات الفرع
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // الاسم
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              branch.name,
                              style: TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: compact ? 14 : 16,
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (branch.isDefault) ...[
                            const SizedBox(width: AlhaiSpacing.xs),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: AlhaiSpacing.xs,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                l10n.defaultLabel,
                                style: const TextStyle(
                                  color: AppColors.primary,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),

                      // العنوان
                      if (branch.address != null) ...[
                        const SizedBox(height: AlhaiSpacing.xxs),
                        Row(
                          children: [
                            const Icon(
                              Icons.location_on_outlined,
                              size: 14,
                              color: AppColors.textTertiary,
                            ),
                            const SizedBox(width: AlhaiSpacing.xxs),
                            Expanded(
                              child: Text(
                                branch.address!,
                                style: TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: compact ? 12 : 13,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],

                      // الحالة
                      if (showStatus && !compact) ...[
                        const SizedBox(height: AlhaiSpacing.xs),
                        BranchStatusBadge(
                          status: branch.status,
                          compact: true,
                        ),
                      ],
                    ],
                  ),
                ),

                SizedBox(width: compact ? AlhaiSpacing.xs : AlhaiSpacing.sm),

                // الحالة (في الوضع المختصر) أو السهم
                if (showStatus && compact)
                  BranchStatusBadge(
                    status: branch.status,
                    compact: true,
                  )
                else
                  Icon(
                    Icons.chevron_left_rounded,
                    color:
                        isSelected ? AppColors.primary : AppColors.textTertiary,
                    size: 24,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// قائمة الفروع
class BranchList extends StatelessWidget {
  final List<BranchData> branches;
  final String? selectedId;
  final ValueChanged<BranchData>? onSelect;
  final bool showStatus;
  final bool compact;
  final EdgeInsetsGeometry? padding;

  const BranchList({
    super.key,
    required this.branches,
    this.selectedId,
    this.onSelect,
    this.showStatus = true,
    this.compact = false,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: padding ?? const EdgeInsets.all(AlhaiSpacing.md),
      itemCount: branches.length,
      itemBuilder: (context, index) {
        final branch = branches[index];
        return BranchCard(
          branch: branch,
          isSelected: branch.id == selectedId,
          onTap: () => onSelect?.call(branch),
          showStatus: showStatus,
          compact: compact,
        );
      },
    );
  }
}

/// حقل البحث عن الفروع
class BranchSearchField extends StatelessWidget {
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final String? hintText;

  const BranchSearchField({
    super.key,
    this.controller,
    this.onChanged,
    this.hintText,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        style: const TextStyle(
          color: AppColors.textPrimary,
          fontSize: 15,
        ),
        decoration: InputDecoration(
          hintText: hintText ?? 'ابحث عن فرع...',
          hintStyle: const TextStyle(
            color: AppColors.textTertiary,
          ),
          prefixIcon: const Icon(
            Icons.search_rounded,
            color: AppColors.textTertiary,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: AlhaiSpacing.md,
            vertical: 14,
          ),
        ),
      ),
    );
  }
}

/// زر إضافة فرع جديد
class AddBranchButton extends StatelessWidget {
  final VoidCallback? onPressed;

  const AddBranchButton({
    super.key,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(AlhaiSpacing.md),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppColors.border,
              style: BorderStyle.solid,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(AlhaiSpacing.xs),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.add_rounded,
                  color: AppColors.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: AlhaiSpacing.sm),
              const Text(
                'إضافة فرع جديد',
                style: TextStyle(
                  color: AppColors.primary,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// معلومات المستخدم في هيدر اختيار الفرع
class UserInfoHeader extends StatelessWidget {
  final String userName;
  final String? userRole;
  final String? avatarUrl;
  final VoidCallback? onLogout;

  const UserInfoHeader({
    super.key,
    required this.userName,
    this.userRole,
    this.avatarUrl,
    this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // الصورة الشخصية
        CircleAvatar(
          radius: 24,
          backgroundColor: AppColors.primary.withValues(alpha: 0.1),
          backgroundImage: avatarUrl != null ? NetworkImage(avatarUrl!) : null,
          child: avatarUrl == null
              ? Text(
                  userName.isNotEmpty ? userName[0].toUpperCase() : '?',
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                )
              : null,
        ),

        const SizedBox(width: AlhaiSpacing.sm),

        // الاسم والدور
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                userName,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (userRole != null)
                Text(
                  userRole!,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                  ),
                ),
            ],
          ),
        ),

        // زر تسجيل الخروج
        if (onLogout != null)
          IconButton(
            onPressed: onLogout,
            icon: const Icon(
              Icons.logout_rounded,
              color: AppColors.textSecondary,
            ),
            tooltip: 'تسجيل الخروج',
          ),
      ],
    );
  }
}
