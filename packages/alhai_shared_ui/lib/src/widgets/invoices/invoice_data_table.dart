/// Invoice Data Table Widget
library;

import 'package:flutter/material.dart';
import 'package:alhai_design_system/alhai_design_system.dart';
import 'package:alhai_l10n/alhai_l10n.dart';
import '../../core/utils/currency_formatter.dart';
import '../../screens/invoices/invoices_screen.dart';

class InvoiceDataTable extends StatelessWidget {
  final List<InvoiceModel> invoices;
  final Set<String> selectedIds;
  final ValueChanged<bool> onSelectAll;
  final void Function(String id, bool selected) onSelectInvoice;
  final ValueChanged<String> onCopyId;
  final ValueChanged<InvoiceModel> onView;
  final ValueChanged<InvoiceModel> onDelete;
  final bool isMobile;

  const InvoiceDataTable({
    super.key,
    required this.invoices,
    required this.selectedIds,
    required this.onSelectAll,
    required this.onSelectInvoice,
    required this.onCopyId,
    required this.onView,
    required this.onDelete,
    this.isMobile = false,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context);

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          // Bulk actions bar
          if (selectedIds.isNotEmpty)
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AlhaiSpacing.md,
                vertical: 10,
              ),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.05),
                border: Border(
                  bottom: BorderSide(
                    color: AppColors.primary.withValues(alpha: 0.2),
                  ),
                ),
              ),
              child: Row(
                children: [
                  Checkbox(
                    value: selectedIds.length == invoices.length,
                    onChanged: (v) => onSelectAll(v ?? false),
                    activeColor: AppColors.primary,
                  ),
                  Text(
                    l10n.selected(selectedIds.length),
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                  const Spacer(),
                  OutlinedButton(
                    onPressed: () {},
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AlhaiSpacing.sm,
                        vertical: 6,
                      ),
                      side: const BorderSide(color: AppColors.border),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      l10n.bulkPrint,
                      style: TextStyle(
                        fontSize: 13,
                        color: colorScheme.onSurface,
                      ),
                    ),
                  ),
                  SizedBox(width: AlhaiSpacing.xs),
                  OutlinedButton(
                    onPressed: () {},
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AlhaiSpacing.sm,
                        vertical: 6,
                      ),
                      side: const BorderSide(color: AppColors.border),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      l10n.bulkExportPdf,
                      style: TextStyle(
                        fontSize: 13,
                        color: colorScheme.onSurface,
                      ),
                    ),
                  ),
                  SizedBox(width: AlhaiSpacing.xs),
                  OutlinedButton(
                    onPressed: () {},
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AlhaiSpacing.sm,
                        vertical: 6,
                      ),
                      side: const BorderSide(color: AppColors.error),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      l10n.delete,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.error,
                      ),
                    ),
                  ),
                ],
              ),
            ),

          // Table or cards
          if (isMobile)
            ...invoices.map(
              (inv) => _buildMobileCard(inv, colorScheme, l10n, context),
            )
          else
            _buildDesktopTable(colorScheme, l10n, context),

          // Pagination
          _buildPagination(colorScheme, l10n),
        ],
      ),
    );
  }

  Widget _buildDesktopTable(
    ColorScheme colorScheme,
    AppLocalizations l10n,
    BuildContext context,
  ) {
    return LayoutBuilder(
      builder: (context, outerConstraints) {
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: ConstrainedBox(
            constraints: BoxConstraints(minWidth: outerConstraints.maxWidth),
            child: DataTable(
              headingRowColor: WidgetStateProperty.all(
                colorScheme.surfaceContainerLowest,
              ),
              headingTextStyle: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurfaceVariant,
                letterSpacing: 0.5,
              ),
              dataTextStyle: TextStyle(
                fontSize: 14,
                color: colorScheme.onSurface,
              ),
              columnSpacing: 24,
              horizontalMargin: 16,
              columns: [
                const DataColumn(label: SizedBox(width: AlhaiSpacing.xl)),
                DataColumn(label: Text(l10n.invoiceNumberCol)),
                DataColumn(label: Text(l10n.customerNameCol)),
                DataColumn(label: Text(l10n.dateCol)),
                DataColumn(label: Text(l10n.amountCol)),
                DataColumn(label: Text(l10n.statusCol)),
                DataColumn(label: Text(l10n.paymentCol)),
                DataColumn(label: Text(l10n.actionsCol)),
              ],
              rows: invoices.map((inv) {
                final isOverdue = inv.status == 'overdue';
                final isDark = Theme.of(context).brightness == Brightness.dark;
                return DataRow(
                  color: isOverdue
                      ? WidgetStateProperty.all(
                          AppColors.error.withValues(
                            alpha: isDark ? 0.05 : 0.03,
                          ),
                        )
                      : null,
                  cells: [
                    DataCell(
                      Checkbox(
                        value: selectedIds.contains(inv.id),
                        onChanged: (v) => onSelectInvoice(inv.id, v ?? false),
                        activeColor: AppColors.primary,
                      ),
                    ),
                    DataCell(
                      Row(
                        children: [
                          InkWell(
                            onTap: () => onView(inv),
                            child: Text(
                              inv.id,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                                fontFamily: 'monospace',
                              ),
                            ),
                          ),
                          SizedBox(width: AlhaiSpacing.xxs),
                          InkWell(
                            onTap: () => onCopyId(inv.id),
                            child: Icon(
                              Icons.copy,
                              size: 14,
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                    DataCell(
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 16,
                            backgroundColor: _getAvatarColor(inv.customer),
                            child: Text(
                              inv.customer.isNotEmpty ? inv.customer[0] : '?',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            inv.customer,
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                              color: colorScheme.onSurface,
                            ),
                          ),
                        ],
                      ),
                    ),
                    DataCell(
                      Text(
                        _formatDate(inv.date),
                        style: TextStyle(color: colorScheme.onSurfaceVariant),
                      ),
                    ),
                    DataCell(
                      Text(
                        CurrencyFormatter.formatWithContext(
                          context,
                          inv.amount,
                        ),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontFamily: 'monospace',
                          color: colorScheme.onSurface,
                        ),
                      ),
                    ),
                    DataCell(_buildStatusBadge(inv.status, l10n, colorScheme)),
                    DataCell(_buildPaymentIcon(inv.paymentMethod)),
                    DataCell(
                      Row(
                        children: [
                          IconButton(
                            onPressed: () => onView(inv),
                            icon: Icon(
                              Icons.visibility_outlined,
                              size: 18,
                              color: colorScheme.onSurfaceVariant,
                            ),
                            tooltip: l10n.viewInvoice,
                          ),
                          PopupMenuButton<String>(
                            onSelected: (v) {
                              if (v == 'delete') onDelete(inv);
                            },
                            icon: Icon(
                              Icons.more_vert,
                              size: 18,
                              color: colorScheme.onSurfaceVariant,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            itemBuilder: (context) => [
                              PopupMenuItem(
                                value: 'print',
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.print_outlined,
                                      size: 16,
                                      color: AppColors.textMuted,
                                    ),
                                    SizedBox(width: AlhaiSpacing.xs),
                                    Text(l10n.printInvoice),
                                  ],
                                ),
                              ),
                              PopupMenuItem(
                                value: 'pdf',
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.picture_as_pdf,
                                      size: 16,
                                      color: AppColors.error,
                                    ),
                                    SizedBox(width: AlhaiSpacing.xs),
                                    Text(l10n.exportPdf),
                                  ],
                                ),
                              ),
                              PopupMenuItem(
                                value: 'whatsapp',
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.message,
                                      size: 16,
                                      color: AppColors.success,
                                    ),
                                    SizedBox(width: AlhaiSpacing.xs),
                                    Text(l10n.sendWhatsapp),
                                  ],
                                ),
                              ),
                              const PopupMenuDivider(),
                              PopupMenuItem(
                                value: 'delete',
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.delete_outline,
                                      size: 16,
                                      color: AppColors.error,
                                    ),
                                    SizedBox(width: AlhaiSpacing.xs),
                                    Text(
                                      l10n.deleteInvoice,
                                      style: const TextStyle(
                                        color: AppColors.error,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
        );
      },
    );
  }

  Widget _buildMobileCard(
    InvoiceModel inv,
    ColorScheme colorScheme,
    AppLocalizations l10n,
    BuildContext context,
  ) {
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: AlhaiSpacing.sm,
        vertical: 6,
      ),
      padding: const EdgeInsets.all(AlhaiSpacing.md),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(12),
        border: inv.status == 'overdue'
            ? Border.all(color: AppColors.error.withValues(alpha: 0.3))
            : null,
      ),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: _getAvatarColor(inv.customer),
                child: Text(
                  inv.customer.isNotEmpty ? inv.customer[0] : '?',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              SizedBox(width: AlhaiSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      inv.customer,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    Text(
                      inv.id,
                      style: const TextStyle(
                        fontSize: 12,
                        fontFamily: 'monospace',
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    CurrencyFormatter.formatWithContext(context, inv.amount),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  SizedBox(height: AlhaiSpacing.xxs),
                  _buildStatusBadge(inv.status, l10n, colorScheme),
                ],
              ),
            ],
          ),
          SizedBox(height: AlhaiSpacing.sm),
          Row(
            children: [
              Icon(
                Icons.calendar_today,
                size: 14,
                color: colorScheme.onSurfaceVariant,
              ),
              SizedBox(width: AlhaiSpacing.xxs),
              Text(
                _formatDate(inv.date),
                style: TextStyle(
                  fontSize: 12,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              const Spacer(),
              _buildPaymentIcon(inv.paymentMethod),
              SizedBox(width: AlhaiSpacing.xs),
              IconButton(
                onPressed: () => onView(inv),
                icon: Icon(
                  Icons.visibility_outlined,
                  size: 18,
                  color: colorScheme.onSurfaceVariant,
                ),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(
    String status,
    AppLocalizations l10n,
    ColorScheme colorScheme,
  ) {
    Color color;
    String label;
    switch (status) {
      case 'paid':
        color = AppColors.success;
        label = l10n.paid;
        break;
      case 'pending':
        color = AppColors.warning;
        label = l10n.statusPending;
        break;
      case 'overdue':
        color = AppColors.error;
        label = l10n.overdue;
        break;
      case 'cancelled':
        color = AppColors.textMuted;
        label = l10n.statusCancelled;
        break;
      default:
        color = AppColors.textMuted;
        label = status;
        break;
    }

    final isDark = colorScheme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: AlhaiSpacing.xxs,
      ),
      decoration: BoxDecoration(
        color: isDark
            ? color.withValues(alpha: 0.15)
            : color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: isDark ? color : color.withValues(alpha: 0.8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentIcon(String method) {
    IconData icon;
    Color color;
    switch (method) {
      case 'card':
        icon = Icons.credit_card;
        color = AppColors.info;
        break;
      case 'cash':
        icon = Icons.payments_outlined;
        color = AppColors.success;
        break;
      case 'wallet':
        icon = Icons.account_balance_wallet;
        color = const Color(0xFF8B5CF6);
        break;
      default:
        icon = Icons.payment;
        color = AppColors.textMuted;
        break;
    }
    return Icon(icon, color: color, size: 22);
  }

  Widget _buildPagination(ColorScheme colorScheme, AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.all(AlhaiSpacing.md),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            l10n.showingResults(1, invoices.length, 124),
            style: TextStyle(fontSize: 13, color: colorScheme.onSurfaceVariant),
          ),
          Row(
            children: [
              _pageBtn('1', true, colorScheme),
              _pageBtn('2', false, colorScheme),
              _pageBtn('3', false, colorScheme),
              Text(
                ' ... ',
                style: TextStyle(color: colorScheme.onSurfaceVariant),
              ),
              _pageBtn('12', false, colorScheme),
            ],
          ),
        ],
      ),
    );
  }

  Widget _pageBtn(String label, bool isActive, ColorScheme colorScheme) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AlhaiSpacing.xxxs),
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: isActive ? AppColors.primary : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        border: isActive ? null : Border.all(color: colorScheme.outlineVariant),
      ),
      child: Center(
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
            color: isActive ? colorScheme.onPrimary : colorScheme.onSurface,
          ),
        ),
      ),
    );
  }

  Color _getAvatarColor(String name) {
    final colors = [
      AppColors.primary,
      AppColors.info,
      AppColors.warning,
      AppColors.secondary,
      const Color(0xFF8B5CF6),
      AppColors.error,
    ];
    return colors[name.hashCode.abs() % colors.length];
  }

  String _formatDate(DateTime d) {
    final months = [
      '\u064A\u0646\u0627\u064A\u0631',
      '\u0641\u0628\u0631\u0627\u064A\u0631',
      '\u0645\u0627\u0631\u0633',
      '\u0623\u0628\u0631\u064A\u0644',
      '\u0645\u0627\u064A\u0648',
      '\u064A\u0648\u0646\u064A\u0648',
      '\u064A\u0648\u0644\u064A\u0648',
      '\u0623\u063A\u0633\u0637\u0633',
      '\u0633\u0628\u062A\u0645\u0628\u0631',
      '\u0623\u0643\u062A\u0648\u0628\u0631',
      '\u0646\u0648\u0641\u0645\u0628\u0631',
      '\u062F\u064A\u0633\u0645\u0628\u0631',
    ];
    return '${d.day.toString().padLeft(2, '0')} ${months[d.month - 1]}, ${d.year}';
  }
}
