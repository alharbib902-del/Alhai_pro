/// جدول بيانات المرتجعات - Returns Data Table
///
/// يعرض المرتجعات في جدول مع أعمدة:
/// رقم المرتجع، التاريخ، الفاتورة الأصلية، العميل، السبب، المبلغ، الحالة، إجراءات
/// يدعم الوضع الفاتح والداكن
library;

import 'package:flutter/material.dart';
import 'package:alhai_design_system/alhai_design_system.dart';
import 'package:alhai_l10n/alhai_l10n.dart';
import '../../screens/returns/returns_screen.dart';

class ReturnsDataTable extends StatelessWidget {
  final List<ReturnModel> returns;
  final ValueChanged<String> onCopyId;
  final ValueChanged<ReturnModel> onView;
  final ValueChanged<ReturnModel>? onApprove;
  final ValueChanged<ReturnModel>? onReject;

  const ReturnsDataTable({
    super.key,
    required this.returns,
    required this.onCopyId,
    required this.onView,
    this.onApprove,
    this.onReject,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context);

    if (returns.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: AlhaiSpacing.xxxl),
        child: Center(
          child: Column(
            children: [
              Icon(
                Icons.inbox_outlined,
                size: 48,
                color: isDark ? AppColors.textMutedDark : AppColors.textMuted,
              ),
              const SizedBox(height: AlhaiSpacing.sm),
              Text(
                l10n.noReturns,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: AlhaiSpacing.xxs),
              Text(
                l10n.noReturnsDesc,
                style: TextStyle(
                  fontSize: 13,
                  color: isDark ? AppColors.textMutedDark : AppColors.textMuted,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: ConstrainedBox(
        constraints: BoxConstraints(minWidth: context.screenWidth - 340),
        child: DataTable(
          headingRowColor: WidgetStateProperty.all(
            isDark
                ? AppColors.grey900.withValues(alpha: 0.5)
                : colorScheme.surfaceContainerLow,
          ),
          dataRowColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.hovered)) {
              return isDark
                  ? Colors.white.withValues(alpha: 0.03)
                  : colorScheme.surfaceContainerLow;
            }
            return Colors.transparent;
          }),
          headingTextStyle: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: isDark ? AppColors.textMutedDark : AppColors.textSecondary,
            letterSpacing: 0.5,
          ),
          dataTextStyle: TextStyle(
            fontSize: 13,
            color: isDark
                ? AppColors.textSecondaryDark
                : AppColors.textSecondary,
          ),
          columnSpacing: 24,
          horizontalMargin: 20,
          dividerThickness: 0.5,
          columns: [
            DataColumn(label: Text(l10n.returnNumber)),
            DataColumn(label: Text(l10n.returnDate)),
            DataColumn(label: Text(l10n.originalInvoice)),
            DataColumn(label: Text(l10n.customer)),
            DataColumn(label: Text(l10n.returnReason)),
            DataColumn(label: Text(l10n.returnAmount)),
            DataColumn(label: Text(l10n.returnStatus)),
            DataColumn(label: Center(child: Text(l10n.returnActions))),
          ],
          rows: returns
              .map((ret) => _buildRow(context, ret, isDark, colorScheme, l10n))
              .toList(),
        ),
      ),
    );
  }

  DataRow _buildRow(
    BuildContext context,
    ReturnModel ret,
    bool isDark,
    ColorScheme colorScheme,
    AppLocalizations l10n,
  ) {
    return DataRow(
      // Semantics: row describes return ID, customer, and status
      key: ValueKey('return-${ret.id}'),
      cells: [
        // Return number
        DataCell(
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '#${ret.id}',
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                  fontFamily: 'Courier',
                  fontSize: 13,
                ),
              ),
              const SizedBox(width: 6),
              Tooltip(
                message: l10n.copyToClipboard,
                child: InkWell(
                  onTap: () => onCopyId(ret.id),
                  borderRadius: BorderRadius.circular(4),
                  child: SizedBox(
                    width: 32,
                    height: 32,
                    child: Icon(
                      Icons.copy_outlined,
                      size: 14,
                      color: colorScheme.outlineVariant,
                      semanticLabel: l10n.copyToClipboard,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        // Date
        DataCell(
          Text(
            _formatDate(ret.date),
            style: TextStyle(
              color: isDark ? AppColors.textMutedDark : AppColors.textMuted,
            ),
          ),
        ),
        // Original invoice
        DataCell(
          InkWell(
            onTap: () {},
            child: Text(
              '#${ret.invoiceNo}',
              style: const TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.w500,
                fontFamily: 'Courier',
                fontSize: 13,
              ),
            ),
          ),
        ),
        // Customer
        DataCell(
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildAvatar(ret, isDark, colorScheme),
              const SizedBox(width: 10),
              Text(
                ret.customer,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
              ),
            ],
          ),
        ),
        // Reason
        DataCell(_buildReasonBadge(ret.reason, l10n, isDark, colorScheme)),
        // Amount
        DataCell(
          Text(
            '${ret.amount.toStringAsFixed(2)} ${l10n.sar}',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),
        ),
        // Status
        DataCell(_buildStatusBadge(context, ret.status, l10n, isDark)),
        // Actions
        DataCell(Center(child: _buildActions(ret, l10n, isDark, colorScheme))),
      ],
    );
  }

  Widget _buildAvatar(ReturnModel ret, bool isDark, ColorScheme colorScheme) {
    if (ret.customerAvatar != null) {
      return CircleAvatar(
        radius: 16,
        backgroundImage: NetworkImage(ret.customerAvatar!),
        backgroundColor: colorScheme.surfaceContainerHighest,
      );
    }
    final initial = ret.customer.isNotEmpty ? ret.customer[0] : '?';
    return CircleAvatar(
      radius: 16,
      backgroundColor: isDark
          ? AppColors.surfaceVariantDark
          : colorScheme.surfaceContainer,
      child: Text(
        initial,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: isDark
              ? AppColors.textMutedDark
              : colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }

  Widget _buildReasonBadge(
    String reason,
    AppLocalizations l10n,
    bool isDark,
    ColorScheme colorScheme,
  ) {
    IconData icon;
    Color bgColor;
    Color textColor;
    String text;

    switch (reason) {
      case 'defective':
        icon = Icons.broken_image_outlined;
        bgColor = isDark
            ? AppColors.error.withValues(alpha: 0.15)
            : AppColors.errorSurface;
        textColor = isDark ? const Color(0xFFF87171) : AlhaiColors.errorDark;
        text = l10n.defectiveProduct;
      case 'wrong':
        icon = Icons.warning_amber_rounded;
        bgColor = isDark
            ? colorScheme.outline.withValues(alpha: 0.15)
            : colorScheme.surfaceContainerLow;
        textColor = colorScheme.onSurfaceVariant;
        text = l10n.wrongProduct;
      case 'customer_request':
        icon = Icons.assignment_return_outlined;
        bgColor = isDark
            ? AppColors.info.withValues(alpha: 0.15)
            : AppColors.infoSurface;
        textColor = isDark ? const Color(0xFF60A5FA) : AlhaiColors.infoDark;
        text = l10n.customerRequest;
      default:
        icon = Icons.edit_note;
        bgColor = isDark
            ? colorScheme.outline.withValues(alpha: 0.15)
            : colorScheme.surfaceContainerLow;
        textColor = colorScheme.onSurfaceVariant;
        text = l10n.otherReason;
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AlhaiSpacing.xs,
        vertical: AlhaiSpacing.xxs,
      ),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: textColor),
          const SizedBox(width: AlhaiSpacing.xxs),
          Text(
            text,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(
    BuildContext context,
    String status,
    AppLocalizations l10n,
    bool isDark,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    Color bgColor;
    Color textColor;
    Color borderColor;
    String label;
    IconData? icon;
    bool animate = false;

    switch (status) {
      case 'pending':
        bgColor = isDark
            ? AppColors.warning.withValues(alpha: 0.15)
            : AppColors.warningSurface;
        textColor = isDark ? const Color(0xFFFBBF24) : const Color(0xFFB45309);
        borderColor = isDark
            ? AppColors.warning.withValues(alpha: 0.3)
            : const Color(0xFFFDE68A);
        label = l10n.pending;
        animate = true;
      case 'refunded':
        bgColor = isDark
            ? AppColors.success.withValues(alpha: 0.15)
            : AppColors.successSurface;
        textColor = isDark ? const Color(0xFF4ADE80) : AlhaiColors.successDark;
        borderColor = isDark
            ? AppColors.success.withValues(alpha: 0.3)
            : const Color(0xFFBBF7D0);
        label = l10n.returnRefunded;
        icon = Icons.check_circle;
      case 'rejected':
        bgColor = isDark
            ? AppColors.error.withValues(alpha: 0.15)
            : AppColors.errorSurface;
        textColor = isDark ? const Color(0xFFF87171) : const Color(0xFFB91C1C);
        borderColor = isDark
            ? AppColors.error.withValues(alpha: 0.3)
            : const Color(0xFFFECACA);
        label = l10n.returnRejected;
        icon = Icons.block;
      default:
        bgColor = colorScheme.surfaceContainerLow;
        textColor = colorScheme.onSurfaceVariant;
        borderColor = colorScheme.outlineVariant;
        label = status;
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: AlhaiSpacing.xxs,
      ),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (animate)
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: textColor,
              ),
            )
          else if (icon != null)
            Icon(icon, size: 13, color: textColor),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActions(
    ReturnModel ret,
    AppLocalizations l10n,
    bool isDark,
    ColorScheme colorScheme,
  ) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // View
        _actionButton(
          Icons.visibility_outlined,
          () => onView(ret),
          colorScheme,
        ),
        // Show more actions for pending
        if (ret.status == 'pending') ...[
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'approve' && onApprove != null) onApprove!(ret);
              if (value == 'reject' && onReject != null) onReject!(ret);
            },
            offset: const Offset(0, 36),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            color: isDark ? AppColors.surfaceVariantDark : AppColors.surface,
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'approve',
                child: Row(
                  children: [
                    const Icon(Icons.check, size: 16, color: AppColors.success),
                    const SizedBox(width: AlhaiSpacing.xs),
                    Text(
                      l10n.approve,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.success,
                      ),
                    ),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'reject',
                child: Row(
                  children: [
                    const Icon(Icons.close, size: 16, color: AppColors.error),
                    const SizedBox(width: AlhaiSpacing.xs),
                    Text(
                      l10n.reject,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.error,
                      ),
                    ),
                  ],
                ),
              ),
            ],
            child: Container(
              width: 30,
              height: 30,
              alignment: Alignment.center,
              child: Icon(
                Icons.more_horiz,
                size: 16,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ] else ...[
          // Print for completed
          if (ret.status == 'refunded')
            _actionButton(Icons.print_outlined, () {}, colorScheme),
        ],
      ],
    );
  }

  Widget _actionButton(
    IconData icon,
    VoidCallback onTap,
    ColorScheme colorScheme,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Container(
        width: 30,
        height: 30,
        alignment: Alignment.center,
        child: Icon(icon, size: 16, color: colorScheme.onSurfaceVariant),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.year}/${date.month.toString().padLeft(2, '0')}/${date.day.toString().padLeft(2, '0')}';
  }
}
