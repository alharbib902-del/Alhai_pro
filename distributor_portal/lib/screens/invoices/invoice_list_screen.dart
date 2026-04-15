/// Invoice list screen for the Distributor Portal.
///
/// Displays all invoices with status-based filter tabs, search,
/// and responsive layout (table on desktop, cards on mobile).
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:alhai_design_system/alhai_design_system.dart';
import '../../data/models.dart';
import '../../providers/distributor_providers.dart';
import '../../ui/shared_widgets.dart';
import '../../ui/skeleton_loading.dart';

// ─── Status filter tabs ─────────────────────────────────────────

/// Filter tabs mapping: null = all, else specific status.
const _statusFilters = <String?>[
  null, // All
  'draft',
  'issued',
  'paid',
  'cancelled',
];

String _filterLabel(String? status) {
  switch (status) {
    case null:
      return 'الكل';
    case 'draft':
      return 'مسودة';
    case 'issued':
      return 'صادرة';
    case 'paid':
      return 'مدفوعة';
    case 'cancelled':
      return 'ملغاة';
    default:
      return status;
  }
}

Color _statusColor(String status) {
  switch (status) {
    case 'draft':
      return Colors.grey;
    case 'issued':
    case 'sent':
      return AppColors.info;
    case 'paid':
      return AppColors.success;
    case 'partially_paid':
      return AppColors.warning;
    case 'overdue':
    case 'cancelled':
      return AppColors.error;
    default:
      return Colors.grey;
  }
}

String _statusLabel(String status) {
  switch (status) {
    case 'draft':
      return 'مسودة';
    case 'issued':
      return 'صادرة';
    case 'sent':
      return 'مُرسلة';
    case 'paid':
      return 'مدفوعة';
    case 'partially_paid':
      return 'مدفوعة جزئياً';
    case 'overdue':
      return 'متأخرة';
    case 'cancelled':
      return 'ملغاة';
    case 'archived':
      return 'مؤرشفة';
    default:
      return status;
  }
}

// ─── Screen ─────────────────────────────────────────────────────

class InvoiceListScreen extends ConsumerStatefulWidget {
  const InvoiceListScreen({super.key});

  @override
  ConsumerState<InvoiceListScreen> createState() => _InvoiceListScreenState();
}

class _InvoiceListScreenState extends ConsumerState<InvoiceListScreen> {
  int _selectedTabIndex = 0;
  String _searchQuery = '';
  final _searchController = TextEditingController();

  String? get _selectedStatus => _statusFilters[_selectedTabIndex];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<DistributorInvoice> _applySearch(List<DistributorInvoice> invoices) {
    if (_searchQuery.isEmpty) return invoices;
    final q = _searchQuery.toLowerCase();
    return invoices.where((inv) {
      return inv.invoiceNumber.toLowerCase().contains(q) ||
          (inv.customerName?.toLowerCase().contains(q) ?? false);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final isWide = size.width >= AlhaiBreakpoints.desktop;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final padding = responsivePadding(size.width);
    final invoicesAsync = ref.watch(invoicesProvider(_selectedStatus));

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SingleChildScrollView(
        padding: EdgeInsets.all(padding),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: kMaxContentWidth),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Header ──
                _buildHeader(isDark, isWide),
                const SizedBox(height: AlhaiSpacing.md),

                // ── Filter tabs ──
                _buildFilterTabs(isDark),
                const SizedBox(height: AlhaiSpacing.md),

                // ── Search ──
                _buildSearchBar(isDark),
                const SizedBox(height: AlhaiSpacing.md),

                // ── Content ──
                invoicesAsync.when(
                  loading: () =>
                      const TableSkeleton(rows: 6, columns: 5),
                  error: (err, _) => ErrorStateWidget(
                    message: 'حدث خطأ أثناء تحميل الفواتير',
                    onRetry: () =>
                        ref.invalidate(invoicesProvider(_selectedStatus)),
                    isDark: isDark,
                  ),
                  data: (invoices) {
                    final filtered = _applySearch(invoices);
                    if (filtered.isEmpty) {
                      return EmptyStateWidget(
                        icon: Icons.receipt_long_outlined,
                        message: _searchQuery.isNotEmpty
                            ? 'لا توجد نتائج للبحث'
                            : 'لا توجد فواتير بعد',
                        isDark: isDark,
                      );
                    }
                    return isWide
                        ? _buildTable(filtered, isDark)
                        : _buildCards(filtered, isDark);
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── Header ──────────────────────────────────────────────────────

  Widget _buildHeader(bool isDark, bool isWide) {
    final headerSize = responsiveHeaderFontSize(
      MediaQuery.sizeOf(context).width,
    );
    return Row(
      children: [
        Icon(
          Icons.receipt_long,
          size: 28,
          color: AppColors.primary,
        ),
        const SizedBox(width: AlhaiSpacing.sm),
        Expanded(
          child: Text(
            'الفواتير',
            style: TextStyle(
              fontSize: headerSize,
              fontWeight: FontWeight.bold,
              color: AppColors.getTextPrimary(isDark),
            ),
          ),
        ),
      ],
    );
  }

  // ── Filter tabs ─────────────────────────────────────────────────

  Widget _buildFilterTabs(bool isDark) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: List.generate(_statusFilters.length, (index) {
          final isSelected = index == _selectedTabIndex;
          return Padding(
            padding: const EdgeInsetsDirectional.only(end: AlhaiSpacing.xs),
            child: FilterChip(
              selected: isSelected,
              label: Text(_filterLabel(_statusFilters[index])),
              onSelected: (_) {
                setState(() => _selectedTabIndex = index);
              },
              selectedColor: AppColors.primary.withValues(alpha: 0.15),
              checkmarkColor: AppColors.primary,
              labelStyle: TextStyle(
                color: isSelected
                    ? AppColors.primary
                    : AppColors.getTextSecondary(isDark),
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              ),
              side: BorderSide(
                color: isSelected
                    ? AppColors.primary
                    : AppColors.getBorder(isDark),
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AlhaiRadius.md),
              ),
            ),
          );
        }),
      ),
    );
  }

  // ── Search bar ──────────────────────────────────────────────────

  Widget _buildSearchBar(bool isDark) {
    return SizedBox(
      height: 44,
      child: TextField(
        controller: _searchController,
        onChanged: (v) => setState(() => _searchQuery = v),
        decoration: InputDecoration(
          hintText: 'بحث برقم الفاتورة أو اسم العميل...',
          hintStyle: TextStyle(color: AppColors.getTextMuted(isDark)),
          prefixIcon: Icon(
            Icons.search,
            color: AppColors.getTextMuted(isDark),
          ),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear, size: 18),
                  onPressed: () {
                    _searchController.clear();
                    setState(() => _searchQuery = '');
                  },
                )
              : null,
          filled: true,
          fillColor: AppColors.getSurface(isDark),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AlhaiRadius.md),
            borderSide: BorderSide(color: AppColors.getBorder(isDark)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AlhaiRadius.md),
            borderSide: BorderSide(color: AppColors.getBorder(isDark)),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: AlhaiSpacing.md,
          ),
        ),
      ),
    );
  }

  // ── Desktop table ───────────────────────────────────────────────

  Widget _buildTable(List<DistributorInvoice> invoices, bool isDark) {
    final currencyFmt = NumberFormat('#,##0.00');

    return Container(
      decoration: BoxDecoration(
        color: AppColors.getSurface(isDark),
        borderRadius: BorderRadius.circular(AlhaiRadius.lg),
        border: Border.all(color: AppColors.getBorder(isDark)),
      ),
      child: Column(
        children: [
          // Header row
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AlhaiSpacing.md,
              vertical: AlhaiSpacing.sm,
            ),
            decoration: BoxDecoration(
              color: AppColors.getSurfaceVariant(isDark),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(AlhaiRadius.lg),
              ),
            ),
            child: Row(
              children: [
                _tableHeader('رقم الفاتورة', flex: 2),
                _tableHeader('العميل', flex: 2),
                _tableHeader('التاريخ', flex: 2),
                _tableHeader('الإجمالي', flex: 1),
                _tableHeader('الحالة', flex: 1),
                _tableHeader('', flex: 1), // Actions
              ],
            ),
          ),
          const Divider(height: 1),
          // Data rows
          ...invoices.map((inv) => _tableRow(inv, isDark, currencyFmt)),
        ],
      ),
    );
  }

  Widget _tableHeader(String label, {int flex = 1}) {
    return Expanded(
      flex: flex,
      child: Text(
        label,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: AppColors.getTextSecondary(
            Theme.of(context).brightness == Brightness.dark,
          ),
        ),
      ),
    );
  }

  Widget _tableRow(
    DistributorInvoice inv,
    bool isDark,
    NumberFormat currencyFmt,
  ) {
    return InkWell(
      onTap: () => context.go('/invoices/${inv.id}'),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AlhaiSpacing.md,
          vertical: AlhaiSpacing.sm,
        ),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: AppColors.getBorder(isDark).withValues(alpha: 0.5),
            ),
          ),
        ),
        child: Row(
          children: [
            Expanded(
              flex: 2,
              child: Text(
                inv.invoiceNumber,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                  fontSize: 13,
                ),
              ),
            ),
            Expanded(
              flex: 2,
              child: Text(
                inv.customerName ?? '-',
                style: TextStyle(
                  color: AppColors.getTextPrimary(isDark),
                  fontSize: 13,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Expanded(
              flex: 2,
              child: Text(
                inv.issuedAt != null
                    ? DateFormat('yyyy/MM/dd', 'ar').format(inv.issuedAt!)
                    : DateFormat('yyyy/MM/dd', 'ar').format(inv.createdAt),
                style: TextStyle(
                  color: AppColors.getTextSecondary(isDark),
                  fontSize: 13,
                ),
              ),
            ),
            Expanded(
              flex: 1,
              child: Text(
                '${currencyFmt.format(inv.total)} ر.س',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: AppColors.getTextPrimary(isDark),
                  fontSize: 13,
                ),
              ),
            ),
            Expanded(
              flex: 1,
              child: _statusBadge(inv.status, isDark),
            ),
            Expanded(
              flex: 1,
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.visibility_outlined, size: 18),
                    tooltip: 'عرض',
                    onPressed: () => context.go('/invoices/${inv.id}'),
                    color: AppColors.getTextSecondary(isDark),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Mobile cards ────────────────────────────────────────────────

  Widget _buildCards(List<DistributorInvoice> invoices, bool isDark) {
    final currencyFmt = NumberFormat('#,##0.00');

    return Column(
      children: invoices.map((inv) {
        return Padding(
          padding: const EdgeInsets.only(bottom: AlhaiSpacing.sm),
          child: InkWell(
            onTap: () => context.go('/invoices/${inv.id}'),
            borderRadius: BorderRadius.circular(AlhaiRadius.lg),
            child: Container(
              padding: const EdgeInsets.all(AlhaiSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.getSurface(isDark),
                borderRadius: BorderRadius.circular(AlhaiRadius.lg),
                border: Border.all(color: AppColors.getBorder(isDark)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        inv.invoiceNumber,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                        ),
                      ),
                      _statusBadge(inv.status, isDark),
                    ],
                  ),
                  const SizedBox(height: AlhaiSpacing.xs),
                  Text(
                    inv.customerName ?? '-',
                    style: TextStyle(
                      color: AppColors.getTextPrimary(isDark),
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: AlhaiSpacing.xs),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        inv.issuedAt != null
                            ? DateFormat(
                                'yyyy/MM/dd',
                                'ar',
                              ).format(inv.issuedAt!)
                            : DateFormat(
                                'yyyy/MM/dd',
                                'ar',
                              ).format(inv.createdAt),
                        style: TextStyle(
                          color: AppColors.getTextSecondary(isDark),
                          fontSize: 13,
                        ),
                      ),
                      Text(
                        '${currencyFmt.format(inv.total)} ر.س',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: AppColors.getTextPrimary(isDark),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  // ── Status badge ────────────────────────────────────────────────

  Widget _statusBadge(String status, bool isDark) {
    final color = _statusColor(status);
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AlhaiSpacing.xs,
        vertical: AlhaiSpacing.xxs,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: isDark ? 0.2 : 0.1),
        borderRadius: BorderRadius.circular(AlhaiRadius.sm),
      ),
      child: Text(
        _statusLabel(status),
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}
