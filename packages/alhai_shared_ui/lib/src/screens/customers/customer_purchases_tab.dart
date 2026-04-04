import 'package:flutter/material.dart';
import 'package:alhai_design_system/alhai_design_system.dart';
import 'package:alhai_database/alhai_database.dart';
import 'package:alhai_l10n/alhai_l10n.dart';

import '../../core/theme/app_sizes.dart';
import '../../core/validators/validators.dart';

/// Purchases Tab - displays invoice transactions with search, filter,
/// pagination, and both desktop table / mobile card views.
class CustomerPurchasesTab extends StatefulWidget {
  final List<TransactionsTableData> invoiceTransactions;
  final bool isMobile;
  final bool isDesktop;
  final bool isDark;

  const CustomerPurchasesTab({
    super.key,
    required this.invoiceTransactions,
    required this.isMobile,
    required this.isDesktop,
    required this.isDark,
  });

  @override
  State<CustomerPurchasesTab> createState() => _CustomerPurchasesTabState();
}

class _CustomerPurchasesTabState extends State<CustomerPurchasesTab> {
  final TextEditingController _searchController = TextEditingController();
  int _currentPage = 0;
  static const int _pageSize = 5;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = widget.isDark;
    final isMobile = widget.isMobile;
    final invoiceTxns = widget.invoiceTransactions;

    final filteredPurchases = _searchController.text.isEmpty
        ? invoiceTxns
        : invoiceTxns
            .where((t) =>
                (t.referenceId ?? t.id)
                    .toLowerCase()
                    .contains(_searchController.text.toLowerCase()) ||
                (t.description ?? '')
                    .toLowerCase()
                    .contains(_searchController.text.toLowerCase()))
            .toList();

    final totalPages = (filteredPurchases.length / _pageSize).ceil();
    final pagedPurchases = filteredPurchases
        .skip(_currentPage * _pageSize)
        .take(_pageSize)
        .toList();

    return Container(
      decoration: BoxDecoration(
        color: AppColors.getSurface(isDark),
        borderRadius: BorderRadius.circular(AppSizes.radiusXl),
        border: Border.all(color: AppColors.getBorder(isDark)),
        boxShadow: isDark ? null : AppSizes.shadowSm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(AlhaiSpacing.md),
            child: Row(
              children: [
                const Icon(Icons.receipt_long_outlined,
                    size: 20, color: AppColors.primary),
                SizedBox(width: AlhaiSpacing.xs),
                Text(
                  l10n.recentTransactions,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.getTextPrimary(isDark),
                  ),
                ),
                const Spacer(),
                // Search
                SizedBox(
                  width: isMobile ? 160 : 240,
                  height: 36,
                  child: TextField(
                    controller: _searchController,
                    maxLength: 100,
                    onChanged: (value) {
                      final sanitized = InputSanitizer.sanitize(value);
                      setState(() => _currentPage = 0);
                      if (sanitized != value) {
                        _searchController.text = sanitized;
                        _searchController.selection =
                            TextSelection.fromPosition(
                          TextPosition(offset: sanitized.length),
                        );
                      }
                    },
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.getTextPrimary(isDark),
                    ),
                    decoration: InputDecoration(
                      hintText: '${l10n.search}...',
                      hintStyle: TextStyle(
                        fontSize: 13,
                        color: AppColors.getTextMuted(isDark),
                      ),
                      prefixIcon: Icon(Icons.search_rounded,
                          size: 18, color: AppColors.getTextMuted(isDark)),
                      filled: true,
                      fillColor: AppColors.getSurfaceVariant(isDark),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: AlhaiSpacing.sm,
                          vertical: AlhaiSpacing.zero),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                        borderSide: BorderSide.none,
                      ),
                      counterText: '',
                    ),
                  ),
                ),
                if (!isMobile) ...[
                  SizedBox(width: AlhaiSpacing.xs),
                  OutlinedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.download_outlined, size: 16),
                    label: const Text('CSV'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.getTextSecondary(isDark),
                      side: BorderSide(color: AppColors.getBorder(isDark)),
                      padding: const EdgeInsets.symmetric(
                          horizontal: AlhaiSpacing.sm,
                          vertical: AlhaiSpacing.xs),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          Divider(height: 1, color: AppColors.getBorder(isDark)),

          // Content: DataTable on desktop, cards on mobile
          if (filteredPurchases.isEmpty)
            Padding(
              padding: const EdgeInsets.all(AlhaiSpacing.xl),
              child: Center(
                child: Text(
                  l10n.noTransactions,
                  style: TextStyle(color: AppColors.getTextMuted(isDark)),
                ),
              ),
            )
          else if (isMobile)
            _buildPurchaseCards(pagedPurchases, isDark, l10n)
          else
            _buildPurchaseTable(pagedPurchases, isDark, l10n),

          // Pagination
          if (totalPages > 1)
            _buildPagination(isDark, totalPages, filteredPurchases.length),
        ],
      ),
    );
  }

  Widget _buildPurchaseTable(List<TransactionsTableData> purchases, bool isDark,
      AppLocalizations l10n) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          minWidth: context.screenWidth - 96,
        ),
        child: DataTable(
          headingRowColor: WidgetStatePropertyAll(
            AppColors.getSurfaceVariant(isDark),
          ),
          headingTextStyle: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppColors.getTextSecondary(isDark),
          ),
          dataTextStyle: TextStyle(
            fontSize: 13,
            color: AppColors.getTextPrimary(isDark),
          ),
          columnSpacing: 24,
          horizontalMargin: 16,
          columns: [
            DataColumn(label: Text(l10n.date)),
            DataColumn(label: Text(l10n.invoiceNumber)),
            DataColumn(label: Text(l10n.amount), numeric: true),
            DataColumn(label: Text(l10n.status)),
            DataColumn(label: Text(l10n.action)),
          ],
          rows: purchases.map((t) {
            final dateStr = formatDate(t.createdAt);
            final invoiceRef = t.referenceId ?? t.id;
            return DataRow(
              cells: [
                DataCell(Text(dateStr)),
                DataCell(
                  Text(
                    invoiceRef,
                    style: const TextStyle(
                      fontWeight: FontWeight.w500,
                      color: AppColors.info,
                    ),
                  ),
                ),
                DataCell(
                    Text('${t.amount.abs().toStringAsFixed(2)} ${l10n.sar}')),
                DataCell(buildStatusBadge(l10n.completed, false, isDark)),
                DataCell(Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      onPressed: () {},
                      icon: const Icon(Icons.visibility_outlined,
                          size: 18, color: AppColors.info),
                      tooltip: l10n.viewAll,
                      padding: EdgeInsets.zero,
                      constraints:
                          const BoxConstraints(minWidth: 32, minHeight: 32),
                    ),
                    IconButton(
                      onPressed: () {},
                      icon: Icon(Icons.print_outlined,
                          size: 18, color: AppColors.getTextSecondary(isDark)),
                      tooltip: l10n.printReceipt,
                      padding: EdgeInsets.zero,
                      constraints:
                          const BoxConstraints(minWidth: 32, minHeight: 32),
                    ),
                  ],
                )),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildPurchaseCards(List<TransactionsTableData> purchases, bool isDark,
      AppLocalizations l10n) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(AlhaiSpacing.sm),
      itemCount: purchases.length,
      separatorBuilder: (_, __) => SizedBox(height: AlhaiSpacing.xs),
      itemBuilder: (context, index) {
        final t = purchases[index];
        final dateStr = formatDate(t.createdAt);
        final invoiceRef = t.referenceId ?? t.id;
        return Container(
          padding: const EdgeInsets.all(AlhaiSpacing.sm),
          decoration: BoxDecoration(
            color: AppColors.getSurfaceVariant(isDark),
            borderRadius: BorderRadius.circular(AppSizes.radiusLg),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    invoiceRef,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      color: AppColors.info,
                      fontSize: 14,
                    ),
                  ),
                  buildStatusBadge(l10n.completed, false, isDark),
                ],
              ),
              SizedBox(height: AlhaiSpacing.xs),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(dateStr,
                      style: TextStyle(
                          fontSize: 12, color: AppColors.getTextMuted(isDark))),
                  Text(
                    '${t.amount.abs().toStringAsFixed(2)} ${l10n.sar}',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: AppColors.getTextPrimary(isDark),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPagination(bool isDark, int totalPages, int totalItems) {
    return Padding(
      padding: const EdgeInsets.all(AlhaiSpacing.md),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '${_currentPage * _pageSize + 1}-${((_currentPage + 1) * _pageSize).clamp(0, totalItems)} / $totalItems',
            style: TextStyle(
              fontSize: 12,
              color: AppColors.getTextMuted(isDark),
            ),
          ),
          Row(
            children: [
              PaginationButton(
                icon: Icons.chevron_left_rounded,
                enabled: _currentPage > 0,
                isDark: isDark,
                onTap: () => setState(() => _currentPage--),
              ),
              SizedBox(width: AlhaiSpacing.xxs),
              ...List.generate(totalPages, (i) {
                final isSelected = i == _currentPage;
                return Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: AlhaiSpacing.xxxs),
                  child: InkWell(
                    onTap: () => setState(() => _currentPage = i),
                    borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                    child: Container(
                      width: 32,
                      height: 32,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color:
                            isSelected ? AppColors.primary : Colors.transparent,
                        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                      ),
                      child: Text(
                        '${i + 1}',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight:
                              isSelected ? FontWeight.w600 : FontWeight.w400,
                          color: isSelected
                              ? Colors.white
                              : AppColors.getTextSecondary(isDark),
                        ),
                      ),
                    ),
                  ),
                );
              }),
              SizedBox(width: AlhaiSpacing.xxs),
              PaginationButton(
                icon: Icons.chevron_right_rounded,
                enabled: _currentPage < totalPages - 1,
                isDark: isDark,
                onTap: () => setState(() => _currentPage++),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Status badge widget for purchase status display.
Widget buildStatusBadge(String label, bool isReturned, bool isDark) {
  final color = isReturned ? AppColors.warning : AppColors.success;
  return Container(
    padding:
        const EdgeInsets.symmetric(horizontal: AlhaiSpacing.xs, vertical: 3),
    decoration: BoxDecoration(
      color: color.withValues(alpha: 0.12),
      borderRadius: BorderRadius.circular(AppSizes.radiusFull),
    ),
    child: Text(
      label,
      style: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        color: color,
      ),
    ),
  );
}

/// Formats a DateTime to 'YYYY-MM-DD' string.
String formatDate(DateTime date) {
  return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
}

/// Pagination arrow button.
class PaginationButton extends StatelessWidget {
  final IconData icon;
  final bool enabled;
  final bool isDark;
  final VoidCallback onTap;

  const PaginationButton({
    super.key,
    required this.icon,
    required this.enabled,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: enabled ? onTap : null,
      borderRadius: BorderRadius.circular(AppSizes.radiusMd),
      child: Container(
        width: 32,
        height: 32,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: AppColors.getSurfaceVariant(isDark),
          borderRadius: BorderRadius.circular(AppSizes.radiusMd),
          border: Border.all(color: AppColors.getBorder(isDark)),
        ),
        child: Icon(
          icon,
          size: 18,
          color: enabled
              ? AppColors.getTextPrimary(isDark)
              : AppColors.getTextMuted(isDark),
        ),
      ),
    );
  }
}
