import 'package:pos_app/widgets/common/adaptive_icon.dart';
import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import '../../widgets/layout/app_header.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../core/theme/app_colors.dart';
import '../../data/local/app_database.dart';
import '../../services/ai_invoice_service.dart';
import '../../providers/purchases_providers.dart';

/// شاشة مراجعة ومطابقة المنتجات المستخرجة بالـ AI
class AiInvoiceReviewScreen extends ConsumerStatefulWidget {
  final AiInvoiceResult invoiceData;

  const AiInvoiceReviewScreen({
    super.key,
    required this.invoiceData,
  });

  @override
  ConsumerState<AiInvoiceReviewScreen> createState() =>
      _AiInvoiceReviewScreenState();
}

class _AiInvoiceReviewScreenState
    extends ConsumerState<AiInvoiceReviewScreen> {

  late List<AiInvoiceItem> _items;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _items = List.from(widget.invoiceData.items);
  }

  int get _confirmedCount => _items.where((i) => i.isConfirmed).length;
  int get _needsReviewCount =>
      _items.where((i) => i.needsReview && !i.isConfirmed).length;
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isWideScreen = size.width > 900;
    final isMediumScreen = size.width > 600;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;

    return Column(
              children: [
                AppHeader(
                  title: l10n.reviewInvoice,
                  onMenuTap: isWideScreen
                      ? null
                      : () => Scaffold.of(context).openDrawer(),
                  onNotificationsTap: () => context.push('/notifications'),
                  notificationsCount: 3,
                  userName: '\u0623\u062D\u0645\u062F \u0645\u062D\u0645\u062F',
                  userRole: l10n.branchManager,
                ),
                Expanded(
                  child: Column(
                    children: [
                      Expanded(
                        child: SingleChildScrollView(
                          padding: EdgeInsets.all(isMediumScreen ? 24 : 16),
                          child: _buildContent(
                              isWideScreen, isMediumScreen, isDark, l10n),
                        ),
                      ),
                      _buildBottomBar(isDark),
                    ],
                  ),
                ),
              ],
            );
  }
  Widget _buildContent(
      bool isWideScreen, bool isMediumScreen, bool isDark, AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Action bar
        Row(
          children: [
            IconButton(
              onPressed: () => context.pop(),
              icon: Icon(Icons.arrow_back_rounded,
                  color: isDark ? Colors.white : AppColors.textPrimary),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                l10n.reviewInvoice,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : AppColors.textPrimary,
                ),
              ),
            ),
            FilledButton.tonalIcon(
              onPressed: _confirmAll,
              icon: const Icon(Icons.done_all, size: 18),
              label: Text(l10n.confirmAllItems),
            ),
          ],
        ),
        const SizedBox(height: 24),

        // Invoice Header
        _buildInvoiceHeader(isDark),
        const SizedBox(height: 16),

        // Progress Bar
        _buildProgressBar(isDark),
        const SizedBox(height: 16),

        // Items List
        if (isWideScreen)
          _buildWideItemsList(isDark)
        else
          _buildNarrowItemsList(isDark),
      ],
    );
  }

  Widget _buildInvoiceHeader(bool isDark) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [const Color(0xFF1E3A5F), const Color(0xFF1E293B)]
              : [const Color(0xFFEFF6FF), const Color(0xFFDBEAFE)],
          begin: AlignmentDirectional.topStart,
          end: AlignmentDirectional.bottomEnd,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark
              ? AppColors.info.withValues(alpha: 0.3)
              : const Color(0xFFBFDBFE),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.info.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.receipt_long,
                color: isDark ? Colors.blue.shade200 : AppColors.info,
                size: 32),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.invoiceData.supplierName ?? l10n.unknownSupplier,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : const Color(0xFF1E3A8A),
                    fontSize: 16,
                  ),
                ),
                if (widget.invoiceData.invoiceNumber != null)
                  Text(
                    l10n.invoiceNumberLabel(widget.invoiceData.invoiceNumber!),
                    style: TextStyle(
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.6)
                            : const Color(0xFF3B82F6),
                        fontSize: 12),
                  ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${widget.invoiceData.totalAmount.toStringAsFixed(2)} \u0631.\u0633',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : const Color(0xFF1E3A8A),
                  fontSize: 18,
                ),
              ),
              Text(
                l10n.itemCount(_items.length),
                style: TextStyle(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.6)
                        : const Color(0xFF3B82F6),
                    fontSize: 12),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProgressBar(bool isDark) {
    final l10n = AppLocalizations.of(context)!;
    final progress = _items.isEmpty ? 0.0 : _confirmedCount / _items.length;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.1)
              : AppColors.border,
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                l10n.progressLabel(_confirmedCount, _items.length),
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : AppColors.textPrimary,
                ),
              ),
              if (_needsReviewCount > 0)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.warning.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.warning,
                          size: 14, color: AppColors.warning),
                      const SizedBox(width: 4),
                      Text(
                        l10n.needsReviewCount(_needsReviewCount),
                        style: const TextStyle(
                            color: AppColors.warning, fontSize: 12),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: isDark
                  ? Colors.white.withValues(alpha: 0.1)
                  : AppColors.backgroundSecondary,
              minHeight: 8,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWideItemsList(bool isDark) {
    return Column(
      children: List.generate(
        _items.length,
        (index) => _buildItemCard(_items[index], index, isDark),
      ),
    );
  }

  Widget _buildNarrowItemsList(bool isDark) {
    return Column(
      children: List.generate(
        _items.length,
        (index) => _buildItemCard(_items[index], index, isDark),
      ),
    );
  }

  Widget _buildItemCard(AiInvoiceItem item, int index, bool isDark) {
    final l10n = AppLocalizations.of(context)!;
    final needsReview = item.needsReview && !item.isConfirmed;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: item.isConfirmed
              ? AppColors.success.withValues(alpha: 0.5)
              : needsReview
                  ? AppColors.warning.withValues(alpha: 0.5)
                  : isDark
                      ? Colors.white.withValues(alpha: 0.1)
                      : AppColors.border,
          width: 2,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              // Confidence badge
              _buildConfidenceBadge(item.confidence, isDark),
              const SizedBox(width: 12),

              // Product details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.rawName,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text(
                          '${item.quantity.toStringAsFixed(0)} \u00D7 ${item.unitPrice.toStringAsFixed(2)}',
                          style: TextStyle(
                            color: isDark
                                ? Colors.white.withValues(alpha: 0.6)
                                : AppColors.textSecondary,
                            fontSize: 13,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          '${item.total.toStringAsFixed(2)} \u0631.\u0633',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color:
                                isDark ? Colors.white : AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Divider(
            height: 1,
            color: isDark
                ? Colors.white.withValues(alpha: 0.1)
                : AppColors.border,
          ),
          const SizedBox(height: 12),

          // Matched product row
          Row(
            children: [
              Expanded(
                child: item.matchedProductId != null
                    ? Row(
                        children: [
                          const Icon(Icons.link,
                              size: 16, color: AppColors.success),
                          const SizedBox(width: 4),
                          Text(
                            item.matchedProductName ?? l10n.matchedProductLabel,
                            style:
                                const TextStyle(color: AppColors.success),
                          ),
                        ],
                      )
                    : Text(
                        l10n.notMatchedStatus,
                        style: TextStyle(
                          color: isDark
                              ? Colors.white.withValues(alpha: 0.5)
                              : AppColors.textSecondary,
                        ),
                      ),
              ),
              if (!item.isConfirmed) ...[
                TextButton(
                  onPressed: () => _showMatchDialog(item, index),
                  child: Text(l10n.matchedStatus),
                ),
                const SizedBox(width: 8),
              ],
              item.isConfirmed
                  ? const Icon(Icons.check_circle, color: AppColors.success)
                  : IconButton(
                      icon: const Icon(Icons.check),
                      onPressed: () => _confirmItem(index),
                      color: AppColors.success,
                    ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildConfidenceBadge(int confidence, bool isDark) {
    Color color;
    IconData icon;

    if (confidence >= 90) {
      color = AppColors.success;
      icon = Icons.verified;
    } else if (confidence >= 70) {
      color = AppColors.info;
      icon = Icons.thumb_up;
    } else if (confidence >= 50) {
      color = AppColors.warning;
      icon = Icons.warning;
    } else {
      color = AppColors.error;
      icon = Icons.error;
    }

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 4),
          Text(
            '$confidence%',
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar(bool isDark) {
    final l10n = AppLocalizations.of(context)!;
    final allConfirmed = _confirmedCount == _items.length;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        border: Border(
          top: BorderSide(
            color: isDark
                ? Colors.white.withValues(alpha: 0.1)
                : AppColors.border,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.total,
                    style: TextStyle(
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.6)
                          : AppColors.textSecondary,
                    ),
                  ),
                  Text(
                    '${widget.invoiceData.totalAmount.toStringAsFixed(2)} \u0631.\u0633',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: isDark ? Colors.white : AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
            FilledButton.icon(
              onPressed: allConfirmed && !_isProcessing ? _savePurchase : null,
              icon: _isProcessing
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.save),
              label: Text(_isProcessing
                  ? l10n.savingInvoice
                  : l10n.saveInvoice),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmItem(int index) {
    setState(() {
      _items[index].isConfirmed = true;
    });
  }

  void _confirmAll() {
    setState(() {
      for (var item in _items) {
        item.isConfirmed = true;
      }
    });
  }

  void _showMatchDialog(AiInvoiceItem item, int index) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) => Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Text(
                    '\u0645\u0637\u0627\u0628\u0642\u0629: ${item.rawName}',
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  const TextField(
                    decoration: InputDecoration(
                      hintText: '\u0628\u062D\u062B \u0639\u0646 \u0645\u0646\u062A\u062C...',
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                controller: scrollController,
                itemCount: 5, // TODO: Load actual products
                itemBuilder: (context, i) => ListTile(
                  leading:
                      const CircleAvatar(child: Icon(Icons.inventory_2)),
                  title: Text('\u0645\u0646\u062A\u062C \u0645\u0642\u062A\u0631\u062D ${i + 1}'),
                  subtitle: const Text('\u0628\u0627\u0631\u0643\u0648\u062F: 123456789'),
                  trailing: const AdaptiveIcon(Icons.chevron_left),
                  onTap: () {
                    setState(() {
                      _items[index].matchedProductId = 'product_$i';
                      _items[index].matchedProductName =
                          '\u0645\u0646\u062A\u062C \u0645\u0642\u062A\u0631\u062D ${i + 1}';
                      _items[index].isConfirmed = true;
                    });
                    Navigator.pop(context);
                  },
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: OutlinedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  _showCreateProductDialog(item, index);
                },
                icon: const Icon(Icons.add),
                label: const Text('\u0625\u0646\u0634\u0627\u0621 \u0645\u0646\u062A\u062C \u062C\u062F\u064A\u062F'),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 48),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showCreateProductDialog(AiInvoiceItem item, int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('\u0625\u0646\u0634\u0627\u0621 \u0645\u0646\u062A\u062C \u062C\u062F\u064A\u062F'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: InputDecoration(
                labelText: '\u0627\u0633\u0645 \u0627\u0644\u0645\u0646\u062A\u062C',
                hintText: item.rawName,
                border: const OutlineInputBorder(),
              ),
              controller: TextEditingController(text: item.rawName),
            ),
            const SizedBox(height: 16),
            TextField(
              decoration: InputDecoration(
                labelText: '\u0633\u0639\u0631 \u0627\u0644\u0634\u0631\u0627\u0621',
                hintText: item.unitPrice.toString(),
                border: const OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('\u0625\u0644\u063A\u0627\u0621'),
          ),
          FilledButton(
            onPressed: () {
              // TODO: Create product
              setState(() {
                _items[index].matchedProductId = 'new_product';
                _items[index].matchedProductName = item.rawName;
                _items[index].isConfirmed = true;
              });
              Navigator.pop(context);
            },
            child: const Text('\u0625\u0646\u0634\u0627\u0621'),
          ),
        ],
      ),
    );
  }

  Future<void> _savePurchase() async {
    setState(() => _isProcessing = true);

    try {
      const uuid = Uuid();

      // تحويل العناصر المؤكدة لـ PurchaseItemsTableCompanion
      final purchaseItems = _items
          .where((item) => item.isConfirmed)
          .map((item) => PurchaseItemsTableCompanion(
                id: Value(uuid.v4()),
                purchaseId: const Value(''), // سيتم ربطه بالمشتريات
                productId: Value(item.matchedProductId ?? ''),
                productName: Value(item.rawName),
                qty: Value(item.quantity.toInt()),
                unitCost: Value(item.unitPrice),
                total: Value(item.total),
              ))
          .toList();

      // حفظ المشتريات عبر المزود (يشمل SyncQueue)
      await createPurchase(
        ref,
        supplierId: '', // المورد غير محدد بعد - يتم تحديده لاحقاً
        supplierName: widget.invoiceData.supplierName ?? 'مورد غير معروف',
        subtotal: widget.invoiceData.totalAmount - widget.invoiceData.taxAmount,
        tax: widget.invoiceData.taxAmount,
        discount: 0,
        total: widget.invoiceData.totalAmount,
        notes: widget.invoiceData.invoiceNumber != null
            ? 'فاتورة AI: ${widget.invoiceData.invoiceNumber}'
            : 'فاتورة مستوردة بالذكاء الاصطناعي',
        items: purchaseItems,
      );

      if (mounted) {
        setState(() => _isProcessing = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تم حفظ فاتورة الشراء بنجاح'),
            backgroundColor: AppColors.success,
          ),
        );
        Navigator.popUntil(context, (route) => route.isFirst);
      }
    } catch (e) {
      setState(() => _isProcessing = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('خطأ: $e'),
              backgroundColor: AppColors.error),
        );
      }
    }
  }
}
