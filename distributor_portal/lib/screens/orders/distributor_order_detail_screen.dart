/// Distributor Order Detail Screen
///
/// Shows purchase order details sent by a store. Distributor can:
/// - View order items and suggested prices
/// - Set their own prices for each item
/// - Accept and send quote or reject the order
/// Supports: RTL Arabic, dark/light theme, responsive layout.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:alhai_design_system/alhai_design_system.dart';
import 'package:intl/intl.dart' show NumberFormat, DateFormat;

// ─── Mock Data Models ────────────────────────────────────────────

class _MockOrderItem {
  final String id;
  final String productName;
  final int quantity;
  final double suggestedPrice;
  double? distributorPrice;

  _MockOrderItem({
    required this.id,
    required this.productName,
    required this.quantity,
    required this.suggestedPrice,
    this.distributorPrice,
  });

  double get suggestedTotal => quantity * suggestedPrice;
  double get distributorTotal =>
      distributorPrice != null ? quantity * distributorPrice! : 0;
}

class _MockOrder {
  final String id;
  final String purchaseNumber;
  final String storeName;
  final String status;
  final DateTime createdAt;
  final double proposedTotal;
  final List<_MockOrderItem> items;

  _MockOrder({
    required this.id,
    required this.purchaseNumber,
    required this.storeName,
    required this.status,
    required this.createdAt,
    required this.proposedTotal,
    required this.items,
  });
}

// ─── Screen ──────────────────────────────────────────────────────

/// شاشة تفاصيل طلب الشراء للموزع
class DistributorOrderDetailScreen extends ConsumerStatefulWidget {
  final String orderId;

  const DistributorOrderDetailScreen({super.key, required this.orderId});

  @override
  ConsumerState<DistributorOrderDetailScreen> createState() =>
      _DistributorOrderDetailScreenState();
}

class _DistributorOrderDetailScreenState
    extends ConsumerState<DistributorOrderDetailScreen> {
  late _MockOrder _order;
  final _notesController = TextEditingController();
  final Map<String, TextEditingController> _priceControllers = {};
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _loadMockOrder();
  }

  void _loadMockOrder() {
    final items = [
      _MockOrderItem(
        id: 'item-1',
        productName: 'أرز بسمتي ١٠ كيلو',
        quantity: 50,
        suggestedPrice: 100,
      ),
      _MockOrderItem(
        id: 'item-2',
        productName: 'زيت زيتون بكر ١ لتر',
        quantity: 30,
        suggestedPrice: 150,
      ),
      _MockOrderItem(
        id: 'item-3',
        productName: 'سكر أبيض ٥ كيلو',
        quantity: 100,
        suggestedPrice: 20,
      ),
      _MockOrderItem(
        id: 'item-4',
        productName: 'شاي أحمر ٢٠٠ جرام',
        quantity: 80,
        suggestedPrice: 15,
      ),
    ];

    _order = _MockOrder(
      id: widget.orderId,
      purchaseNumber: 'PO-${widget.orderId.substring(0, 10)}',
      storeName: 'متجر الرياض - الفرع الرئيسي',
      status: 'pending',
      createdAt: DateTime.now().subtract(const Duration(hours: 3)),
      proposedTotal: items.fold(0, (sum, item) => sum + item.suggestedTotal),
      items: items,
    );

    for (final item in _order.items) {
      _priceControllers[item.id] = TextEditingController();
    }
  }

  @override
  void dispose() {
    _notesController.dispose();
    for (final controller in _priceControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  double get _calculatedTotal {
    double total = 0;
    for (final item in _order.items) {
      final controller = _priceControllers[item.id];
      final price = double.tryParse(controller?.text ?? '') ?? 0;
      total += price * item.quantity;
    }
    return total;
  }

  String _getStatusLabel(String status) {
    switch (status) {
      case 'pending':
        return 'منتظر';
      case 'approved':
        return 'مقبول';
      case 'rejected':
        return 'مرفوض';
      default:
        return status;
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending':
        return AppColors.warning;
      case 'approved':
        return AppColors.success;
      case 'rejected':
        return AppColors.error;
      default:
        return AppColors.textMuted;
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isWide = size.width > 900;
    final isMedium = size.width > 600;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
        backgroundColor: AppColors.getBackground(isDark),
        appBar: AppBar(
          title: Text(
            'طلب شراء #${_order.purchaseNumber}',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: cs.onSurface,
            ),
          ),
          centerTitle: false,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_rounded),
            onPressed: () => context.canPop() ? context.pop() : null,
          ),
          actions: [
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: _getStatusColor(_order.status).withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _getStatusColor(_order.status),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    _getStatusLabel(_order.status),
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: _getStatusColor(_order.status),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        body: SingleChildScrollView(
          padding: EdgeInsets.all(isMedium ? 24 : 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── Order Header Info ──
              _buildOrderHeader(isDark, isMedium),
              SizedBox(height: isMedium ? 24 : 16),

              // ── Items Section ──
              if (isWide)
                _buildItemsTable(isDark)
              else
                _buildItemsCards(isDark),
              SizedBox(height: isMedium ? 24 : 16),

              // ── Total & Notes ──
              if (isWide)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(flex: 3, child: _buildNotesSection(isDark)),
                    const SizedBox(width: 24),
                    Expanded(flex: 2, child: _buildTotalSection(isDark)),
                  ],
                )
              else ...[
                _buildTotalSection(isDark),
                const SizedBox(height: 16),
                _buildNotesSection(isDark),
              ],
              const SizedBox(height: 24),

              // ── Action Buttons ──
              _buildActionButtons(isDark, isMedium),
              const SizedBox(height: 32),
            ],
          ),
        ),
    );
  }

  Widget _buildOrderHeader(bool isDark, bool isMedium) {
    final dateFormatted = DateFormat('yyyy/MM/dd - HH:mm', 'ar').format(_order.createdAt);

    return Container(
      padding: EdgeInsets.all(isMedium ? 24 : 16),
      decoration: BoxDecoration(
        color: AppColors.getSurface(isDark),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.getBorder(isDark)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.store_rounded,
                    color: AppColors.primary, size: 24),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _order.storeName,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.getTextPrimary(isDark),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      dateFormatted,
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.getTextSecondary(isDark),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.info.withValues(alpha: isDark ? 0.1 : 0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                  color: AppColors.info.withValues(alpha: 0.2)),
            ),
            child: Row(
              children: [
                const Icon(Icons.receipt_long_rounded,
                    color: AppColors.info, size: 20),
                const SizedBox(width: 10),
                Text(
                  'المبلغ المقترح:',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.getTextSecondary(isDark),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '${NumberFormat('#,##0.00').format(_order.proposedTotal)} ريال',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.info,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─── Wide Screen: Data Table ───────────────────────────────────

  Widget _buildItemsTable(bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.getSurface(isDark),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.getBorder(isDark)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.secondary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.list_alt_rounded,
                      color: AppColors.secondary, size: 20),
                ),
                const SizedBox(width: 12),
                Text(
                  'بنود الطلب',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.getTextPrimary(isDark),
                  ),
                ),
                const Spacer(),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${_order.items.length} منتجات',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          // Table header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            color: AppColors.getSurfaceVariant(isDark),
            child: Row(
              children: [
                Expanded(
                  flex: 3,
                  child: Text('المنتج',
                      style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.getTextSecondary(isDark))),
                ),
                Expanded(
                  flex: 1,
                  child: Text('الكمية',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.getTextSecondary(isDark))),
                ),
                Expanded(
                  flex: 2,
                  child: Text('السعر المقترح',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.getTextSecondary(isDark))),
                ),
                Expanded(
                  flex: 2,
                  child: Text('سعرك',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.getTextSecondary(isDark))),
                ),
                Expanded(
                  flex: 2,
                  child: Text('الإجمالي',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.getTextSecondary(isDark))),
                ),
              ],
            ),
          ),
          // Table rows
          ...List.generate(_order.items.length, (index) {
            final item = _order.items[index];
            final controller = _priceControllers[item.id]!;
            final price = double.tryParse(controller.text) ?? 0;
            final rowTotal = price * item.quantity;

            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              decoration: BoxDecoration(
                border: index < _order.items.length - 1
                    ? Border(
                        bottom: BorderSide(
                          color: AppColors.getBorder(isDark).withValues(alpha: 0.5),
                        ),
                      )
                    : null,
              ),
              child: Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: Row(
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            '${index + 1}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            item.productName,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppColors.getTextPrimary(isDark),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: Text(
                      '${item.quantity}',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.getTextPrimary(isDark),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(
                      '${NumberFormat('#,##0').format(item.suggestedPrice)} ريال',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.getTextSecondary(isDark),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: TextField(
                        controller: controller,
                        keyboardType: TextInputType.number,
                        textAlign: TextAlign.center,
                        onChanged: (_) => setState(() {}),
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AppColors.getTextPrimary(isDark),
                        ),
                        decoration: InputDecoration(
                          hintText: '0.00',
                          hintStyle: TextStyle(
                              color: AppColors.getTextMuted(isDark)),
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 10),
                          suffixText: 'ريال',
                          suffixStyle: TextStyle(
                            fontSize: 11,
                            color: AppColors.getTextMuted(isDark),
                          ),
                          filled: true,
                          fillColor: AppColors.getSurfaceVariant(isDark),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide:
                                BorderSide(color: AppColors.getBorder(isDark)),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide:
                                BorderSide(color: AppColors.getBorder(isDark)),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(
                                color: AppColors.primary, width: 2),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(
                      rowTotal > 0
                          ? '${NumberFormat('#,##0.00').format(rowTotal)} ريال'
                          : '-',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: rowTotal > 0
                            ? AppColors.primary
                            : AppColors.getTextMuted(isDark),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  // ─── Mobile: Card View ─────────────────────────────────────────

  Widget _buildItemsCards(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.secondary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.list_alt_rounded,
                  color: AppColors.secondary, size: 20),
            ),
            const SizedBox(width: 12),
            Text(
              'بنود الطلب',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.getTextPrimary(isDark),
              ),
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '${_order.items.length} منتجات',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...List.generate(_order.items.length, (index) {
          final item = _order.items[index];
          final controller = _priceControllers[item.id]!;
          final price = double.tryParse(controller.text) ?? 0;
          final rowTotal = price * item.quantity;

          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.getSurface(isDark),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.getBorder(isDark)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        '${index + 1}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                          fontSize: 13,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        item.productName,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: AppColors.getTextPrimary(isDark),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _infoChip(
                      'الكمية',
                      '${item.quantity}',
                      AppColors.info,
                      isDark,
                    ),
                    const SizedBox(width: 10),
                    _infoChip(
                      'السعر المقترح',
                      '${NumberFormat('#,##0').format(item.suggestedPrice)} ر.س',
                      AppColors.secondary,
                      isDark,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: controller,
                        keyboardType: TextInputType.number,
                        onChanged: (_) => setState(() {}),
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.getTextPrimary(isDark),
                        ),
                        decoration: InputDecoration(
                          labelText: 'سعرك',
                          labelStyle: TextStyle(
                              color: AppColors.getTextSecondary(isDark)),
                          hintText: '0.00',
                          hintStyle: TextStyle(
                              color: AppColors.getTextMuted(isDark)),
                          suffixText: 'ريال',
                          suffixStyle: TextStyle(
                            fontSize: 12,
                            color: AppColors.getTextMuted(isDark),
                          ),
                          filled: true,
                          fillColor: AppColors.getSurfaceVariant(isDark),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(
                                color: AppColors.getBorder(isDark)),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(
                                color: AppColors.getBorder(isDark)),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(
                                color: AppColors.primary, width: 2),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 12),
                        ),
                      ),
                    ),
                    if (rowTotal > 0) ...[
                      const SizedBox(width: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 10),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          '${NumberFormat('#,##0.00').format(rowTotal)} ر.س',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _infoChip(String label, String value, Color color, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: isDark ? 0.12 : 0.06),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '$label: ',
            style: TextStyle(
              fontSize: 12,
              color: AppColors.getTextSecondary(isDark),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  // ─── Total Section ─────────────────────────────────────────────

  Widget _buildTotalSection(bool isDark) {
    final total = _calculatedTotal;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: total > 0
            ? LinearGradient(
                colors: [
                  AppColors.primary.withValues(alpha: isDark ? 0.15 : 0.06),
                  AppColors.primary.withValues(alpha: isDark ? 0.08 : 0.02),
                ],
                begin: AlignmentDirectional.topStart,
                end: AlignmentDirectional.bottomEnd,
              )
            : null,
        color: total > 0 ? null : AppColors.getSurface(isDark),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: total > 0
              ? AppColors.primary.withValues(alpha: 0.3)
              : AppColors.getBorder(isDark),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.calculate_rounded,
                    color: AppColors.primary, size: 20),
              ),
              const SizedBox(width: 12),
              Text(
                'إجمالي سعرك',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppColors.getTextPrimary(isDark),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            '${NumberFormat('#,##0.00').format(total)} ريال',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: total > 0
                  ? AppColors.primary
                  : AppColors.getTextMuted(isDark),
            ),
          ),
          if (total > 0 && _order.proposedTotal > 0) ...[
            const SizedBox(height: 8),
            Builder(
              builder: (_) {
                final diff = total - _order.proposedTotal;
                final percent = (diff / _order.proposedTotal * 100);
                final isLower = diff < 0;
                return Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: (isLower ? AppColors.success : AppColors.warning)
                        .withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${isLower ? '' : '+'}${percent.toStringAsFixed(1)}% ${isLower ? 'أقل' : 'أعلى'} من المقترح',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: isLower ? AppColors.success : AppColors.warning,
                    ),
                  ),
                );
              },
            ),
          ],
        ],
      ),
    );
  }

  // ─── Notes Section ─────────────────────────────────────────────

  Widget _buildNotesSection(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.getSurface(isDark),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.getBorder(isDark)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.info.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.note_alt_rounded,
                    color: AppColors.info, size: 20),
              ),
              const SizedBox(width: 12),
              Text(
                'ملاحظات للمتجر',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppColors.getTextPrimary(isDark),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _notesController,
            maxLines: 4,
            style: TextStyle(color: AppColors.getTextPrimary(isDark)),
            decoration: InputDecoration(
              hintText: 'أضف ملاحظات حول العرض (اختياري)...',
              hintStyle: TextStyle(color: AppColors.getTextMuted(isDark)),
              filled: true,
              fillColor: AppColors.getSurfaceVariant(isDark),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: AppColors.getBorder(isDark)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: AppColors.getBorder(isDark)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide:
                    const BorderSide(color: AppColors.primary, width: 2),
              ),
              contentPadding: const EdgeInsets.all(16),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Action Buttons ────────────────────────────────────────────

  Widget _buildActionButtons(bool isDark, bool isMedium) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: _isProcessing ? null : _rejectOrder,
            icon: _isProcessing
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.close_rounded, size: 20),
            label: const Text('رفض الطلب',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.error,
              side: const BorderSide(color: AppColors.error),
              padding: EdgeInsets.symmetric(
                  vertical: isMedium ? 16 : 14),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          flex: 2,
          child: FilledButton.icon(
            onPressed:
                _isProcessing || _calculatedTotal <= 0 ? null : _acceptOrder,
            icon: _isProcessing
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: Colors.white),
                  )
                : const Icon(Icons.check_circle_rounded, size: 20),
            label: const Text('قبول وإرسال العرض',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.success,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(
                  vertical: isMedium ? 16 : 14),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ),
      ],
    );
  }

  // ─── Actions ───────────────────────────────────────────────────

  Future<void> _rejectOrder() async {
    setState(() => _isProcessing = true);

    // Simulate API call
    await Future.delayed(const Duration(seconds: 1));

    if (!mounted) return;

    setState(() {
      _order = _MockOrder(
        id: _order.id,
        purchaseNumber: _order.purchaseNumber,
        storeName: _order.storeName,
        status: 'rejected',
        createdAt: _order.createdAt,
        proposedTotal: _order.proposedTotal,
        items: _order.items,
      );
      _isProcessing = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('تم رفض الطلب بنجاح'),
        backgroundColor: AppColors.error,
      ),
    );
  }

  Future<void> _acceptOrder() async {
    setState(() => _isProcessing = true);

    // Simulate API call
    await Future.delayed(const Duration(seconds: 1));

    if (!mounted) return;

    setState(() {
      _order = _MockOrder(
        id: _order.id,
        purchaseNumber: _order.purchaseNumber,
        storeName: _order.storeName,
        status: 'approved',
        createdAt: _order.createdAt,
        proposedTotal: _order.proposedTotal,
        items: _order.items,
      );
      _isProcessing = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
            'تم قبول الطلب وإرسال العرض بمبلغ ${NumberFormat('#,##0.00').format(_calculatedTotal)} ريال'),
        backgroundColor: AppColors.success,
      ),
    );
  }
}
