/// Recent Transactions Widget - المعاملات الأخيرة
///
/// جدول المعاملات الأخيرة في لوحة التحكم بتصميم HTML Table
library;

import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../l10n/generated/app_localizations.dart';

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

  String _formatAmount(double amount) {
    if (formatCurrency != null) return formatCurrency!(amount);
    return '${amount.toStringAsFixed(0)} ر.س';
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;

    return Container(
      decoration: BoxDecoration(
        color: isDarkMode ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(isMobile ? 16 : 24),
        border: Border.all(
          color: isDarkMode
              ? Colors.white.withValues(alpha:0.05)
              : AppColors.border.withValues(alpha:0.5),
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
            padding: EdgeInsets.fromLTRB(
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
                    color: isDarkMode ? Colors.white : AppColors.textPrimary,
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
            _buildEmptyState(isDarkMode)
          else
            _buildTable(context, isDarkMode, isMobile, l10n),
        ],
      ),
    );
  }

  /// حالة فارغة عند عدم وجود معاملات
  Widget _buildEmptyState(bool isDarkMode) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          children: [
            Icon(
              Icons.receipt_long_rounded,
              color: isDarkMode
                  ? Colors.white.withValues(alpha:0.2)
                  : AppColors.textTertiary,
              size: 48,
            ),
            const SizedBox(height: 12),
            Text(
              'لا توجد معاملات',
              style: TextStyle(
                color: isDarkMode
                    ? Colors.white.withValues(alpha:0.5)
                    : AppColors.textSecondary,
                fontSize: 14,
              ),
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
    final headerColor = isDarkMode
        ? Colors.white.withValues(alpha:0.4)
        : AppColors.textTertiary;

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
            color: isDarkMode
                ? Colors.white.withValues(alpha:0.06)
                : AppColors.border.withValues(alpha:0.7),
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
  final String Function(double) formatAmount;
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
              ? (isDark
                  ? Colors.white.withValues(alpha:0.03)
                  : AppColors.backgroundSecondary.withValues(alpha:0.5))
              : Colors.transparent,
          border: widget.isLast
              ? null
              : Border(
                  bottom: BorderSide(
                    color: isDark
                        ? Colors.white.withValues(alpha:0.04)
                        : AppColors.border.withValues(alpha:0.5),
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
        color: isDark ? Colors.white : AppColors.textPrimary,
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
          color: isDark
              ? Colors.white.withValues(alpha:0.4)
              : AppColors.textTertiary,
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
              color: isDark ? Colors.white.withValues(alpha:0.9) : AppColors.textPrimary,
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
        color: isDark
            ? Colors.white.withValues(alpha:0.4)
            : AppColors.textTertiary,
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
    final displayAmount = widget.formatAmount(tx.amount);
    final text = isNegative ? '-$displayAmount' : displayAmount;

    return Text(
      text,
      style: TextStyle(
        color: isDark ? Colors.white : AppColors.textPrimary,
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
            color: isDark
                ? Colors.white.withValues(alpha:0.4)
                : AppColors.textTertiary,
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
    return 'الآن';
  } else if (difference.inMinutes < 60) {
    return l10n.minutesAgo(difference.inMinutes);
  } else if (difference.inHours < 24) {
    return 'منذ ${difference.inHours} ساعة';
  } else {
    return 'منذ ${difference.inDays} يوم';
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
        isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
        isDark ? const Color(0xFF94A3B8) : const Color(0xFF475569),
        isDark ? const Color(0xFF475569) : const Color(0xFFCBD5E1),
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
