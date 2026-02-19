/// Invoice Data Table Widget
library;

import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../l10n/generated/app_localizations.dart';
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? Colors.white.withValues(alpha: 0.1) : AppColors.border),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          // Bulk actions bar
          if (selectedIds.isNotEmpty)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.05), border: Border(bottom: BorderSide(color: AppColors.primary.withValues(alpha: 0.2)))),
              child: Row(
                children: [
                  Checkbox(value: selectedIds.length == invoices.length, onChanged: (v) => onSelectAll(v ?? false), activeColor: AppColors.primary),
                  Text(l10n.selected(selectedIds.length), style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.primary)),
                  const Spacer(),
                  OutlinedButton(onPressed: () {}, style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6), side: const BorderSide(color: AppColors.border), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))), child: Text(l10n.bulkPrint, style: TextStyle(fontSize: 13, color: isDark ? Colors.white : AppColors.textPrimary))),
                  const SizedBox(width: 8),
                  OutlinedButton(onPressed: () {}, style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6), side: const BorderSide(color: AppColors.border), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))), child: Text(l10n.bulkExportPdf, style: TextStyle(fontSize: 13, color: isDark ? Colors.white : AppColors.textPrimary))),
                  const SizedBox(width: 8),
                  OutlinedButton(onPressed: () {}, style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6), side: const BorderSide(color: AppColors.error), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))), child: Text(l10n.delete, style: const TextStyle(fontSize: 13, color: AppColors.error))),
                ],
              ),
            ),

          // Table or cards
          if (isMobile)
            ...invoices.map((inv) => _buildMobileCard(inv, isDark, l10n, context))
          else
            _buildDesktopTable(isDark, l10n, context),

          // Pagination
          _buildPagination(isDark, l10n),
        ],
      ),
    );
  }

  Widget _buildDesktopTable(bool isDark, AppLocalizations l10n, BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: ConstrainedBox(
        constraints: BoxConstraints(minWidth: MediaQuery.of(context).size.width > 900 ? MediaQuery.of(context).size.width - 340 : MediaQuery.of(context).size.width - 80),
        child: DataTable(
          headingRowColor: WidgetStateProperty.all(isDark ? const Color(0xFF0F172A).withValues(alpha: 0.5) : AppColors.backgroundSecondary),
          headingTextStyle: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: isDark ? AppColors.textMutedDark : AppColors.textMuted, letterSpacing: 0.5),
          dataTextStyle: TextStyle(fontSize: 14, color: isDark ? Colors.white : AppColors.textPrimary),
          columnSpacing: 24,
          horizontalMargin: 16,
          columns: [
            const DataColumn(label: SizedBox(width: 32)),
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
            return DataRow(
              color: isOverdue ? WidgetStateProperty.all(AppColors.error.withValues(alpha: isDark ? 0.05 : 0.03)) : null,
              cells: [
                DataCell(Checkbox(value: selectedIds.contains(inv.id), onChanged: (v) => onSelectInvoice(inv.id, v ?? false), activeColor: AppColors.primary)),
                DataCell(Row(children: [
                  InkWell(onTap: () => onView(inv), child: Text(inv.id, style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary, fontFamily: 'monospace'))),
                  const SizedBox(width: 4),
                  InkWell(onTap: () => onCopyId(inv.id), child: Icon(Icons.copy, size: 14, color: isDark ? AppColors.textMutedDark : AppColors.textMuted)),
                ])),
                DataCell(Row(children: [
                  CircleAvatar(radius: 16, backgroundColor: _getAvatarColor(inv.customer), child: Text(inv.customer.isNotEmpty ? inv.customer[0] : '?', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white))),
                  const SizedBox(width: 10),
                  Text(inv.customer, style: TextStyle(fontWeight: FontWeight.w500, color: isDark ? Colors.white : AppColors.textPrimary)),
                ])),
                DataCell(Text(_formatDate(inv.date), style: TextStyle(color: isDark ? AppColors.textMutedDark : AppColors.textMuted))),
                DataCell(Text('${inv.amount.toStringAsFixed(2)} \u0631.\u0633', style: TextStyle(fontWeight: FontWeight.bold, fontFamily: 'monospace', color: isDark ? Colors.white : AppColors.textPrimary))),
                DataCell(_buildStatusBadge(inv.status, l10n, isDark)),
                DataCell(_buildPaymentIcon(inv.paymentMethod, isDark)),
                DataCell(Row(children: [
                  IconButton(onPressed: () => onView(inv), icon: Icon(Icons.visibility_outlined, size: 18, color: isDark ? AppColors.textMutedDark : AppColors.textMuted), tooltip: l10n.viewInvoice),
                  PopupMenuButton<String>(
                    onSelected: (v) { if (v == 'delete') onDelete(inv); },
                    icon: Icon(Icons.more_vert, size: 18, color: isDark ? AppColors.textMutedDark : AppColors.textMuted),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    itemBuilder: (context) => [
                      PopupMenuItem(value: 'print', child: Row(children: [const Icon(Icons.print_outlined, size: 16, color: AppColors.textMuted), const SizedBox(width: 8), Text(l10n.printInvoice)])),
                      PopupMenuItem(value: 'pdf', child: Row(children: [const Icon(Icons.picture_as_pdf, size: 16, color: AppColors.error), const SizedBox(width: 8), Text(l10n.exportPdf)])),
                      PopupMenuItem(value: 'whatsapp', child: Row(children: [const Icon(Icons.message, size: 16, color: AppColors.success), const SizedBox(width: 8), Text(l10n.sendWhatsapp)])),
                      const PopupMenuDivider(),
                      PopupMenuItem(value: 'delete', child: Row(children: [const Icon(Icons.delete_outline, size: 16, color: AppColors.error), const SizedBox(width: 8), Text(l10n.deleteInvoice, style: const TextStyle(color: AppColors.error))])),
                    ],
                  ),
                ])),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildMobileCard(InvoiceModel inv, bool isDark, AppLocalizations l10n, BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0F172A) : AppColors.backgroundSecondary,
        borderRadius: BorderRadius.circular(12),
        border: inv.status == 'overdue' ? Border.all(color: AppColors.error.withValues(alpha: 0.3)) : null,
      ),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(radius: 18, backgroundColor: _getAvatarColor(inv.customer), child: Text(inv.customer.isNotEmpty ? inv.customer[0] : '?', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white))),
              const SizedBox(width: 12),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(inv.customer, style: TextStyle(fontWeight: FontWeight.w600, color: isDark ? Colors.white : AppColors.textPrimary)),
                Text(inv.id, style: const TextStyle(fontSize: 12, fontFamily: 'monospace', color: AppColors.primary)),
              ])),
              Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                Text('${inv.amount.toStringAsFixed(2)} \u0631.\u0633', style: TextStyle(fontWeight: FontWeight.bold, color: isDark ? Colors.white : AppColors.textPrimary)),
                const SizedBox(height: 4),
                _buildStatusBadge(inv.status, l10n, isDark),
              ]),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(Icons.calendar_today, size: 14, color: isDark ? AppColors.textMutedDark : AppColors.textMuted),
              const SizedBox(width: 4),
              Text(_formatDate(inv.date), style: TextStyle(fontSize: 12, color: isDark ? AppColors.textMutedDark : AppColors.textMuted)),
              const Spacer(),
              _buildPaymentIcon(inv.paymentMethod, isDark),
              const SizedBox(width: 8),
              IconButton(onPressed: () => onView(inv), icon: Icon(Icons.visibility_outlined, size: 18, color: isDark ? AppColors.textMutedDark : AppColors.textMuted), padding: EdgeInsets.zero, constraints: const BoxConstraints()),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(String status, AppLocalizations l10n, bool isDark) {
    Color color;
    String label;
    switch (status) {
      case 'paid': color = AppColors.success; label = l10n.paid; break;
      case 'pending': color = AppColors.warning; label = l10n.statusPending; break;
      case 'overdue': color = AppColors.error; label = l10n.overdue; break;
      case 'cancelled': color = AppColors.textMuted; label = l10n.statusCancelled; break;
      default: color = AppColors.textMuted; label = status; break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: isDark ? color.withValues(alpha: 0.15) : color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(width: 6, height: 6, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
          const SizedBox(width: 6),
          Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: isDark ? color : color.withValues(alpha: 0.8))),
        ],
      ),
    );
  }

  Widget _buildPaymentIcon(String method, bool isDark) {
    IconData icon;
    Color color;
    switch (method) {
      case 'card': icon = Icons.credit_card; color = AppColors.info; break;
      case 'cash': icon = Icons.payments_outlined; color = AppColors.success; break;
      case 'wallet': icon = Icons.account_balance_wallet; color = const Color(0xFF8B5CF6); break;
      default: icon = Icons.payment; color = AppColors.textMuted; break;
    }
    return Icon(icon, color: color, size: 22);
  }

  Widget _buildPagination(bool isDark, AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(l10n.showingResults(1, invoices.length, 124), style: TextStyle(fontSize: 13, color: isDark ? AppColors.textMutedDark : AppColors.textMuted)),
          Row(
            children: [
              _pageBtn('1', true, isDark),
              _pageBtn('2', false, isDark),
              _pageBtn('3', false, isDark),
              Text(' ... ', style: TextStyle(color: isDark ? AppColors.textMutedDark : AppColors.textMuted)),
              _pageBtn('12', false, isDark),
            ],
          ),
        ],
      ),
    );
  }

  Widget _pageBtn(String label, bool isActive, bool isDark) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 2),
      width: 36, height: 36,
      decoration: BoxDecoration(
        color: isActive ? AppColors.primary : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        border: isActive ? null : Border.all(color: isDark ? Colors.white.withValues(alpha: 0.1) : AppColors.border),
      ),
      child: Center(child: Text(label, style: TextStyle(fontSize: 13, fontWeight: isActive ? FontWeight.bold : FontWeight.w500, color: isActive ? Colors.white : (isDark ? Colors.white : AppColors.textPrimary)))),
    );
  }

  Color _getAvatarColor(String name) {
    final colors = [AppColors.primary, AppColors.info, AppColors.warning, AppColors.secondary, const Color(0xFF8B5CF6), AppColors.error];
    return colors[name.hashCode.abs() % colors.length];
  }

  String _formatDate(DateTime d) {
    final months = ['\u064A\u0646\u0627\u064A\u0631', '\u0641\u0628\u0631\u0627\u064A\u0631', '\u0645\u0627\u0631\u0633', '\u0623\u0628\u0631\u064A\u0644', '\u0645\u0627\u064A\u0648', '\u064A\u0648\u0646\u064A\u0648', '\u064A\u0648\u0644\u064A\u0648', '\u0623\u063A\u0633\u0637\u0633', '\u0633\u0628\u062A\u0645\u0628\u0631', '\u0623\u0643\u062A\u0648\u0628\u0631', '\u0646\u0648\u0641\u0645\u0628\u0631', '\u062F\u064A\u0633\u0645\u0628\u0631'];
    return '${d.day.toString().padLeft(2, '0')} ${months[d.month - 1]}, ${d.year}';
  }
}
