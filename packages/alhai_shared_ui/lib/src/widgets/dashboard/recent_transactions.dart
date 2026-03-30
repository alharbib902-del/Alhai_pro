/// Recent Transactions Widget - المعاملات الأخيرة
///
/// جدول المعاملات الأخيرة في لوحة التحكم بتصميم HTML Table
library;

import 'package:flutter/material.dart';
import 'package:alhai_design_system/alhai_design_system.dart';
import 'package:alhai_l10n/alhai_l10n.dart';
import '../../core/utils/currency_formatter.dart';

// =============================================================================
// DATA MODEL
// =============================================================================

/// نوع المعاملة
enum TransactionType {
  /// بيع
  sale,

  /// استرجاع
  refund,

  /// إلغاء
  cancelled,
}

/// بيانات معاملة
class Transaction {
  final String id;
  final String customerName;
  final double amount;
  final TransactionType type;
  final DateTime timestamp;
  final String? paymentMethod;

  const Transaction({
    required this.id,
    required this.customerName,
    required this.amount,
    required this.type,
    required this.timestamp,
    this.paymentMethod,
  });
}

// =============================================================================
// CONSTANTS
// =============================================================================

/// ألوان الأفاتار للعملاء - تدور بالترتيب
const List<Color> _avatarColors = [
  Color(0xFF3B82F6), // blue
  Color(0xFF8B5CF6), // purple
  Color(0xFFEC4899), // pink
  Color(0xFF06B6D4), // cyan
  Color(0xFFF59E0B), // amber
];

// =============================================================================
// MAIN WIDGET
// =============================================================================

/// قائمة المعاملات الأخيرة - بتصميم جدول
class RecentTransactionsList extends StatelessWidget {
  final List<Transaction> transactions;
  final VoidCallback? onViewAll;
  final void Function(String orderId)? onViewDetails;
  final String Function(double)? formatCurrency;

  const RecentTransactionsList({
    super.key,
    required this.transactions,
    this.onViewAll,
    this.onViewDetails,
    this.formatCurrency,
  });

  String _formatAmount(BuildContext context, double amount) {
    if (formatCurrency != null) return formatCurrency!(amount);
    return CurrencyFormatter.formatCompactWithContext(context, amount);
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;
    final isMobile = context.isMobile;

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(isMobile ? 16 : 24),
        border: Border.all(
          color: Theme.of(context).dividerColor,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha:isDarkMode ? 0.2 : 0.04),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // =================================================================
          // HEADER ROW
          // =================================================================
          Padding(
            padding: EdgeInsetsDirectional.fromSTEB(
              isMobile ? 16 : 24,
              isMobile ? 16 : 24,
              isMobile ? 16 : 24,
              0,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  l10n.recentTransactions,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface,
                    fontSize: isMobile ? 16 : 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (onViewAll != null)
                  GestureDetector(
                    onTap: onViewAll,
                    child: Text(
                      l10n.viewAll,
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // =================================================================
          // TABLE CONTENT
          // =================================================================
          if (transactions.isEmpty)
            _buildEmptyState(context, isDarkMode)
          else
            _buildTable(context, isDarkMode, isMobile, l10n),
        ],
      ),
    );
  }

  /// حالة فارغة عند عدم وجود معاملات
  Widget _buildEmptyState(BuildContext context, bool isDarkMode) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          children: [
            Icon(
              Icons.receipt_long_rounded,
              color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
              size: 48,
            ),
            const SizedBox(height: 12),
            Builder(
              builder: (context) {
                final l10n = AppLocalizations.of(context)!;
                return Text(
                  l10n.noTransactionsToday,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    fontSize: 14,
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  /// بناء الجدول الكامل
  Widget _buildTable(
    BuildContext context,
    bool isDarkMode,
    bool isMobile,
    AppLocalizations l10n,
  ) {
    return Column(
      children: [
        // TABLE HEADER
        _TableHeader(isDarkMode: isDarkMode, isMobile: isMobile, l10n: l10n),

        // TABLE ROWS
        ...transactions.take(5).toList().asMap().entries.map((entry) {
          final index = entry.key;
          final transaction = entry.value;
          final isLast = index == (transactions.length.clamp(0, 5) - 1);
          return _TransactionRow(
            transaction: transaction,
            index: index,
            isLast: isLast,
            isDarkMode: isDarkMode,
            isMobile: isMobile,
            l10n: l10n,
            formatAmount: _formatAmount,
            onViewDetails: onViewDetails,
          );
        }),

        // Bottom padding
        SizedBox(height: isMobile ? 8 : 12),
      ],
    );
  }
}

// =============================================================================
// TABLE HEADER
// =============================================================================

class _TableHeader extends StatelessWidget {
  final bool isDarkMode;
  final bool isMobile;
  final AppLocalizations l10n;

  const _TableHeader({
    required this.isDarkMode,
    required this.isMobile,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    final headerColor = Theme.of(context).colorScheme.onSurfaceVariant;

    final headerStyle = TextStyle(
      color: headerColor,
      fontSize: 12,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.5,
    );

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 16 : 24,
        vertical: 12,
      ),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).dividerColor,
          ),
        ),
      ),
      child: Row(
        children: [
          // رقم الطلب
          Expanded(
            flex: isMobile ? 3 : 2,
            child: Text(l10n.orderNumber, style: headerStyle),
          ),

          // العميل
          Expanded(
            flex: 3,
            child: Text(l10n.customer, style: headerStyle),
          ),

          // الوقت - مخفي على الموبايل
          if (!isMobile)
            Expanded(
              flex: 2,
              child: Text(l10n.time, style: headerStyle),
            ),

          // الحالة
          Expanded(
            flex: 2,
            child: Text(l10n.status, style: headerStyle),
          ),

          // المبلغ
          Expanded(
            flex: 2,
            child: Text(
              l10n.amount,
              style: headerStyle,
              textAlign: TextAlign.end,
            ),
          ),

          // إجراء
          SizedBox(
            width: isMobile ? 36 : 48,
            child: Text(
              l10n.action,
              style: headerStyle,
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// TRANSACTION ROW
// =============================================================================

class _TransactionRow extends StatefulWidget {
  final Transaction transaction;
  final int index;
  final bool isLast;
  final bool isDarkMode;
  final bool isMobile;
  final AppLocalizations l10n;
  final String Function(BuildContext, double) formatAmount;
  final void Function(String orderId)? onViewDetails;

  const _TransactionRow({
    required this.transaction,
    required this.index,
    required this.isLast,
    required this.isDarkMode,
    required this.isMobile,
    required this.l10n,
    required this.formatAmount,
    this.onViewDetails,
  });

  @override
  State<_TransactionRow> createState() => _TransactionRowState();
}

class _TransactionRowState extends State<_TransactionRow> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final tx = widget.transaction;
    final isDark = widget.isDarkMode;
    final isMobile = widget.isMobile;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: isMobile ? 16 : 24,
          vertical: isMobile ? 12 : 14,
        ),
        decoration: BoxDecoration(
          color: _isHovered
              ? (Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.5))
              : Colors.transparent,
          border: widget.isLast
              ? null
              : Border(
                  bottom: BorderSide(
                    color: Theme.of(context).dividerColor,
                  ),
                ),
        ),
        child: Row(
          children: [
            // رقم الطلب
            Expanded(
              flex: isMobile ? 3 : 2,
              child: _buildOrderNumber(tx, isDark),
            ),

            // العميل
            Expanded(
              flex: 3,
              child: _buildCustomerCell(tx, isDark, isMobile),
            ),

            // الوقت - مخفي على الموبايل
            if (!isMobile)
              Expanded(
                flex: 2,
                child: _buildTimeCell(tx, isDark),
              ),

            // الحالة
            Expanded(
              flex: 2,
              child: _buildStatusBadge(tx, isDark),
            ),

            // المبلغ
            Expanded(
              flex: 2,
              child: _buildAmountCell(tx, isDark),
            ),

            // إجراء
            SizedBox(
              width: isMobile ? 36 : 48,
              child: _buildActionButton(tx, isDark),
            ),
          ],
        ),
      ),
    );
  }

  /// خلية رقم الطلب
  Widget _buildOrderNumber(Transaction tx, bool isDark) {
    return Text(
      '#${tx.id}',
      style: TextStyle(
        color: Theme.of(context).colorScheme.onSurface,
        fontSize: 13,
        fontWeight: FontWeight.w700,
        fontFamily: 'monospace',
        letterSpacing: -0.2,
      ),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }

  /// خلية العميل (أفاتار + اسم)
  Widget _buildCustomerCell(Transaction tx, bool isDark, bool isMobile) {
    final isGuest = tx.customerName.isEmpty ||
        tx.customerName.toLowerCase() == 'guest' ||
        tx.customerName == 'عميل زائر';

    if (isGuest) {
      return Text(
        widget.l10n.guestCustomer,
        style: TextStyle(
          color: Theme.of(context).colorScheme.onSurfaceVariant,
          fontSize: 13,
          fontStyle: FontStyle.italic,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      );
    }

    final avatarColor = _avatarColors[widget.index % _avatarColors.length];
    final initial = tx.customerName.isNotEmpty
        ? tx.customerName.characters.first.toUpperCase()
        : '?';

    return Row(
      children: [
        Container(
          width: isMobile ? 28 : 32,
          height: isMobile ? 28 : 32,
          decoration: BoxDecoration(
            color: avatarColor.withValues(alpha:0.15),
            borderRadius: BorderRadius.circular(isMobile ? 8 : 10),
          ),
          alignment: Alignment.center,
          child: Text(
            initial,
            style: TextStyle(
              color: avatarColor,
              fontSize: isMobile ? 12 : 13,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            tx.customerName,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  /// خلية الوقت
  Widget _buildTimeCell(Transaction tx, bool isDark) {
    final timeText = _formatTimeAgo(tx.timestamp, widget.l10n);

    return Text(
      timeText,
      style: TextStyle(
        color: Theme.of(context).colorScheme.onSurfaceVariant,
        fontSize: 13,
      ),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }

  /// شارة الحالة
  Widget _buildStatusBadge(Transaction tx, bool isDark) {
    final (String label, Color bgColor, Color textColor, Color borderColor) =
        _getStatusStyle(tx.type, isDark, widget.l10n);

    return Align(
      alignment: AlignmentDirectional.centerStart,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: borderColor, width: 1),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: textColor,
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  /// خلية المبلغ
  Widget _buildAmountCell(Transaction tx, bool isDark) {
    final isNegative =
        tx.type == TransactionType.refund || tx.type == TransactionType.cancelled;
    final displayAmount = widget.formatAmount(context, tx.amount);
    final text = isNegative ? '-$displayAmount' : displayAmount;

    return Text(
      text,
      style: TextStyle(
        color: Theme.of(context).colorScheme.onSurface,
        fontSize: 13,
        fontWeight: FontWeight.w700,
      ),
      textAlign: TextAlign.end,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }

  /// زر الإجراء (عين)
  Widget _buildActionButton(Transaction tx, bool isDark) {
    return Center(
      child: SizedBox(
        width: 32,
        height: 32,
        child: IconButton(
          onPressed: widget.onViewDetails != null
              ? () => widget.onViewDetails!(tx.id)
              : null,
          padding: EdgeInsets.zero,
          iconSize: 18,
          splashRadius: 16,
          icon: Icon(
            Icons.visibility_outlined,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
            size: 18,
          ),
          tooltip: widget.l10n.action,
        ),
      ),
    );
  }
}

// =============================================================================
// HELPER FUNCTIONS
// =============================================================================

/// تنسيق الوقت النسبي
String _formatTimeAgo(DateTime timestamp, AppLocalizations l10n) {
  final now = DateTime.now();
  final difference = now.difference(timestamp);

  if (difference.inMinutes < 1) {
    return l10n.justNowTime;
  } else if (difference.inMinutes < 60) {
    return l10n.minutesAgo(difference.inMinutes);
  } else if (difference.inHours < 24) {
    return l10n.hoursAgo(difference.inHours);
  } else {
    return l10n.daysAgo(difference.inDays);
  }
}

/// الحصول على نمط شارة الحالة
/// يرجع: (label, backgroundColor, textColor, borderColor)
(String, Color, Color, Color) _getStatusStyle(
  TransactionType type,
  bool isDark,
  AppLocalizations l10n,
) {
  switch (type) {
    case TransactionType.sale:
      return (
        l10n.completed,
        AppColors.success.withValues(alpha:0.12),
        AppColors.success,
        AppColors.success.withValues(alpha:0.3),
      );

    case TransactionType.refund:
      return (
        l10n.returned,
        isDark ? AppColors.borderDark : AppColors.border,
        isDark ? AppColors.textSecondaryDark : AppColors.grey600,
        isDark ? AppColors.grey600 : AppColors.grey300,
      );

    case TransactionType.cancelled:
      return (
        l10n.cancelled,
        AppColors.error.withValues(alpha:0.12),
        AppColors.error,
        AppColors.error.withValues(alpha:0.3),
      );
  }
}
