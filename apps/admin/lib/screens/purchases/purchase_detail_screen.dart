import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:alhai_shared_ui/alhai_shared_ui.dart';
import 'package:alhai_l10n/alhai_l10n.dart';
import 'package:alhai_database/alhai_database.dart';
import '../../providers/purchases_providers.dart';
import 'package:alhai_design_system/alhai_design_system.dart';

/// Purchase Detail Screen - شاشة تفاصيل طلب الشراء
class PurchaseDetailScreen extends ConsumerStatefulWidget {
  final String purchaseId;

  const PurchaseDetailScreen({super.key, required this.purchaseId});

  @override
  ConsumerState<PurchaseDetailScreen> createState() =>
      _PurchaseDetailScreenState();
}

class _PurchaseDetailScreenState extends ConsumerState<PurchaseDetailScreen> {
  // Status flow for the timeline
  static const _statusFlow = ['draft', 'sent', 'approved', 'received'];

  /// Returns badge color per status
  Color _statusColor(String status) {
    switch (status) {
      case 'draft':
        return Theme.of(context).colorScheme.outline;
      case 'sent':
        return AppColors.info;
      case 'approved':
        return AppColors.success;
      case 'received':
        return AppColors.credit;
      case 'completed':
        return AppColors.primary;
      default:
        return Theme.of(context).colorScheme.outline;
    }
  }

  /// Returns the localized label for a status
  String _statusLabel(String status) {
    final l10n = AppLocalizations.of(context);
    switch (status) {
      case 'draft':
        return l10n.statusDraft;
      case 'sent':
        return l10n.statusSent;
      case 'approved':
        return l10n.statusApproved;
      case 'received':
        return l10n.statusReceived;
      case 'completed':
        return l10n.statusCompleted;
      default:
        return status;
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isWide = AlhaiBreakpoints.isDesktop(size.width);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context);

    final asyncDetail = ref.watch(purchaseDetailProvider(widget.purchaseId));

    return Column(
      children: [
        AppHeader(
          title: l10n.purchaseDetails,
          onMenuTap: isWide ? null : () => Scaffold.of(context).openDrawer(),
          onNotificationsTap: () =>
              context.push(AppRoutes.notificationsCenter),
          notificationsCount: 0,
          userName: l10n.cashCustomer,
          userRole: l10n.branchManager,
        ),
        Expanded(
          child: asyncDetail.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => _buildError(isDark, e.toString()),
            data: (data) {
              if (data == null) {
                return _buildError(isDark, l10n.purchaseNotFound);
              }
              return _buildContent(
                context,
                data,
                isWide,
                isDark,
                l10n,
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildError(bool isDark, String message) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error_outline, size: 48, color: AppColors.error),
          const SizedBox(height: AlhaiSpacing.md),
          Text(
            message,
            style: TextStyle(
              fontSize: 16,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: AlhaiSpacing.md),
          FilledButton.icon(
            onPressed: () => context.go(AppRoutes.purchasesList),
            icon: const Icon(Icons.arrow_back),
            label: Text(AppLocalizations.of(context).backToList),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    PurchaseDetailData data,
    bool isWide,
    bool isDark,
    AppLocalizations l10n,
  ) {
    final purchase = data.purchase;
    final items = data.items;
    final dateFormat = DateFormat('yyyy/MM/dd - HH:mm', 'ar');
    final currentStatus = purchase.status;

    return SingleChildScrollView(
      padding: EdgeInsets.all(isWide ? 24 : 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Back button row
          Row(
            children: [
              IconButton(
                onPressed: () => context.go(AppRoutes.purchasesList),
                icon: Icon(
                  Icons.arrow_back_rounded,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              const SizedBox(width: AlhaiSpacing.xs),
              Expanded(
                child: Text(
                  purchase.purchaseNumber,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AlhaiSpacing.mdl),

          // Responsive layout
          if (isWide)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Left: header info + items
                Expanded(
                  flex: 2,
                  child: Column(
                    children: [
                      _buildHeaderCard(purchase, dateFormat, currentStatus, isDark),
                      const SizedBox(height: AlhaiSpacing.md),
                      _buildItemsTable(items, isDark, isWide),
                    ],
                  ),
                ),
                const SizedBox(width: AlhaiSpacing.lg),
                // Right: timeline + actions
                Expanded(
                  flex: 1,
                  child: Column(
                    children: [
                      _buildTimeline(currentStatus, isDark),
                      const SizedBox(height: AlhaiSpacing.md),
                      _buildActions(currentStatus, isDark),
                    ],
                  ),
                ),
              ],
            )
          else
            Column(
              children: [
                _buildHeaderCard(purchase, dateFormat, currentStatus, isDark),
                const SizedBox(height: AlhaiSpacing.md),
                _buildTimeline(currentStatus, isDark),
                const SizedBox(height: AlhaiSpacing.md),
                _buildActions(currentStatus, isDark),
                const SizedBox(height: AlhaiSpacing.md),
                _buildItemsTable(items, isDark, isWide),
              ],
            ),

          const SizedBox(height: AlhaiSpacing.xl),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Header card: purchase number, supplier, status, total, date
  // ---------------------------------------------------------------------------
  Widget _buildHeaderCard(
    PurchasesTableData purchase,
    DateFormat dateFormat,
    String status,
    bool isDark,
  ) {
    final color = _statusColor(status);
    return Container(
      padding: const EdgeInsets.all(AlhaiSpacing.mdl),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).dividerColor,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Purchase number + status badge
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  purchase.purchaseNumber,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: isDark ? 0.25 : 0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  _statusLabel(status),
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: isDark ? color.withValues(alpha: 0.9) : color,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AlhaiSpacing.md),
          Divider(
            color: Theme.of(context).dividerColor,
          ),
          const SizedBox(height: AlhaiSpacing.sm),
          // Supplier
          _infoRow(
            Icons.store_rounded,
            AppLocalizations.of(context).supplierInfoLabel,
            purchase.supplierName ?? '-',
            isDark,
          ),
          const SizedBox(height: 10),
          // Date
          _infoRow(
            Icons.calendar_today_rounded,
            AppLocalizations.of(context).dateLabel,
            dateFormat.format(purchase.createdAt),
            isDark,
          ),
          const SizedBox(height: 10),
          // Total
          _infoRow(
            Icons.attach_money_rounded,
            AppLocalizations.of(context).totalLabel,
            AppLocalizations.of(context).amountSar(purchase.total.toStringAsFixed(2)),
            isDark,
            valueColor: isDark ? AppColors.primaryLight : AppColors.primaryDark,
            valueBold: true,
          ),
          // Notes
          if (purchase.notes != null && purchase.notes!.isNotEmpty) ...[
            const SizedBox(height: 10),
            _infoRow(
              Icons.notes_rounded,
              AppLocalizations.of(context).notesLabel,
              purchase.notes!,
              isDark,
            ),
          ],
        ],
      ),
    );
  }

  Widget _infoRow(
    IconData icon,
    String label,
    String value,
    bool isDark, {
    Color? valueColor,
    bool valueBold = false,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          size: 18,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
        const SizedBox(width: AlhaiSpacing.xs),
        Text(
          '$label: ',
          style: TextStyle(
            fontSize: 14,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: valueBold ? FontWeight.bold : FontWeight.w500,
              color: valueColor ??
                  (Theme.of(context).colorScheme.onSurface),
            ),
          ),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // Status timeline
  // ---------------------------------------------------------------------------
  Widget _buildTimeline(String currentStatus, bool isDark) {
    final currentIndex = _statusFlow.indexOf(currentStatus);

    return Container(
      padding: const EdgeInsets.all(AlhaiSpacing.mdl),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).dividerColor,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AlhaiSpacing.xs),
                decoration: BoxDecoration(
                  color: AppColors.info.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.timeline_rounded, color: AppColors.info, size: 20),
              ),
              const SizedBox(width: AlhaiSpacing.sm),
              Text(
                AppLocalizations.of(context).orderTimeline,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: AlhaiSpacing.mdl),
          ...List.generate(_statusFlow.length, (index) {
            final stepStatus = _statusFlow[index];
            final isCompleted = index <= currentIndex;
            final isCurrent = index == currentIndex;
            final isLast = index == _statusFlow.length - 1;
            final stepColor = isCompleted
                ? _statusColor(stepStatus)
                : (Theme.of(context).dividerColor);

            return Column(
              children: [
                Row(
                  children: [
                    // Circle indicator
                    Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: isCompleted
                            ? stepColor.withValues(alpha: 0.15)
                            : Colors.transparent,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: stepColor,
                          width: isCurrent ? 3 : 2,
                        ),
                      ),
                      child: isCompleted
                          ? Icon(Icons.check, size: 16, color: stepColor)
                          : null,
                    ),
                    const SizedBox(width: AlhaiSpacing.sm),
                    Text(
                      _statusLabel(stepStatus),
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: isCurrent ? FontWeight.bold : FontWeight.w500,
                        color: isCompleted
                            ? (Theme.of(context).colorScheme.onSurface)
                            : (Theme.of(context).colorScheme.onSurfaceVariant),
                      ),
                    ),
                  ],
                ),
                // Connecting line
                if (!isLast)
                  Padding(
                    padding: const EdgeInsetsDirectional.only(start: 13),
                    child: Container(
                      width: 2,
                      height: 24,
                      color: index < currentIndex
                          ? _statusColor(_statusFlow[index])
                          : (isDark
                              ? Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.1)
                              : AppColors.grey200),
                    ),
                  ),
              ],
            );
          }),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Action buttons based on status
  // ---------------------------------------------------------------------------
  Widget _buildActions(String currentStatus, bool isDark) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AlhaiSpacing.mdl),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).dividerColor,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AlhaiSpacing.xs),
                decoration: BoxDecoration(
                  color: AppColors.warning.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.bolt_rounded, color: AppColors.warning, size: 20),
              ),
              const SizedBox(width: AlhaiSpacing.sm),
              Text(
                AppLocalizations.of(context).actionsLabel,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: AlhaiSpacing.md),
          if (currentStatus == 'draft')
            FilledButton.icon(
              onPressed: () =>
                  context.go(AppRoutes.sendToDistributorPath(widget.purchaseId)),
              icon: const Icon(Icons.send_rounded),
              label: Text(AppLocalizations.of(context).sendToDistributor),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.info,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            )
          else if (currentStatus == 'sent')
            Container(
              padding: const EdgeInsets.all(AlhaiSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.info.withValues(alpha: isDark ? 0.15 : 0.08),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.info.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                children: [
                  const Icon(Icons.hourglass_top_rounded,
                      color: AppColors.info, size: 20),
                  const SizedBox(width: AlhaiSpacing.sm),
                  Expanded(
                    child: Text(
                      AppLocalizations.of(context).awaitingDistributorResponse,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: isDark
                            ? AppColors.info.withValues(alpha: 0.9)
                            : AppColors.info,
                      ),
                    ),
                  ),
                ],
              ),
            )
          else if (currentStatus == 'approved')
            FilledButton.icon(
              onPressed: () =>
                  context.go(AppRoutes.receivingGoodsPath(widget.purchaseId)),
              icon: const Icon(Icons.inventory_2_rounded),
              label: Text(AppLocalizations.of(context).receiveGoods),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            )
          else if (currentStatus == 'received')
            Container(
              padding: const EdgeInsets.all(AlhaiSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.success.withValues(alpha: isDark ? 0.15 : 0.08),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.success.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                children: [
                  const Icon(Icons.check_circle_rounded,
                      color: AppColors.success, size: 20),
                  const SizedBox(width: AlhaiSpacing.sm),
                  Expanded(
                    child: Text(
                      AppLocalizations.of(context).goodsReceived,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: isDark
                            ? AppColors.success.withValues(alpha: 0.9)
                            : AppColors.success,
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Items table
  // ---------------------------------------------------------------------------
  Widget _buildItemsTable(
    List<PurchaseItemsTableData> items,
    bool isDark,
    bool isWide,
  ) {
    return Container(
      padding: const EdgeInsets.all(AlhaiSpacing.mdl),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).dividerColor,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AlhaiSpacing.xs),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.list_alt_rounded,
                    color: AppColors.primary, size: 20),
              ),
              const SizedBox(width: AlhaiSpacing.sm),
              Text(
                AppLocalizations.of(context).orderItems,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  AppLocalizations.of(context).itemCountLabel(items.length),
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AlhaiSpacing.md),
          Divider(
            color: Theme.of(context).dividerColor,
          ),
          if (items.isEmpty)
            AppEmptyState.noProducts(context)
          else if (isWide)
            // M123: wrap DataTable with horizontal scroll for overflow safety
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                headingRowColor: WidgetStateProperty.all(
                  isDark ? Theme.of(context).colorScheme.surface : AppColors.grey50,
                ),
                columns: [
                  DataColumn(label: Text(AppLocalizations.of(context).productColumn)),
                  DataColumn(label: Text(AppLocalizations.of(context).quantityColumn), numeric: true),
                  DataColumn(label: Text(AppLocalizations.of(context).receivedColumn), numeric: true),
                  DataColumn(label: Text(AppLocalizations.of(context).unitPriceColumn), numeric: true),
                  DataColumn(label: Text(AppLocalizations.of(context).totalColumn), numeric: true),
                ],
                rows: items.map((item) {
                  return DataRow(cells: [
                    DataCell(Text(
                      item.productName,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    )),
                    DataCell(Text(
                      '${item.qty}',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    )),
                    DataCell(Text(
                      '${item.receivedQty}',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    )),
                    DataCell(Text(
                      AppLocalizations.of(context).amountSar(item.unitCost.toStringAsFixed(2)),
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    )),
                    DataCell(Text(
                      AppLocalizations.of(context).amountSar(item.total.toStringAsFixed(2)),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: isDark
                            ? AppColors.primaryLight
                            : AppColors.primaryDark,
                      ),
                    )),
                  ]);
                }).toList(),
              ),
            )
          else
            // Mobile: list tiles
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: items.length,
              separatorBuilder: (_, __) => Divider(
                height: 1,
                color: Theme.of(context).dividerColor,
              ),
              itemBuilder: (context, index) {
                final item = items[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: AlhaiSpacing.sm),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.productName,
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                            ),
                            const SizedBox(height: AlhaiSpacing.xxs),
                            Text(
                              AppLocalizations.of(context).quantityInfo(item.qty.toInt(), item.receivedQty.toInt(), item.unitCost.toStringAsFixed(2)),
                              style: TextStyle(
                                fontSize: 12,
                                color: Theme.of(context).colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        AppLocalizations.of(context).amountSar(item.total.toStringAsFixed(2)),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: isDark
                              ? AppColors.primaryLight
                              : AppColors.primaryDark,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}
