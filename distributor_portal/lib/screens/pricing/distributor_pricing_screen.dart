/// Distributor Pricing Management Screen
///
/// Manage product prices with editable fields, last updated dates,
/// and a save button. Mock data for now.
/// Supports: RTL Arabic, dark/light theme, responsive layout.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:alhai_design_system/alhai_design_system.dart';
import 'package:intl/intl.dart' show NumberFormat, DateFormat;

// ─── Mock Data ───────────────────────────────────────────────────

class _MockPricingItem {
  final String id;
  final String productName;
  final double currentPrice;
  final DateTime lastUpdated;
  String newPriceText;

  _MockPricingItem({
    required this.id,
    required this.productName,
    required this.currentPrice,
    required this.lastUpdated,
    this.newPriceText = '',
  });
}

// ─── Screen ──────────────────────────────────────────────────────

/// شاشة إدارة الأسعار للموزع
class DistributorPricingScreen extends ConsumerStatefulWidget {
  const DistributorPricingScreen({super.key});

  @override
  ConsumerState<DistributorPricingScreen> createState() =>
      _DistributorPricingScreenState();
}

class _DistributorPricingScreenState
    extends ConsumerState<DistributorPricingScreen> {
  late List<_MockPricingItem> _items;
  final Map<String, TextEditingController> _controllers = {};
  bool _isSaving = false;
  bool _hasChanges = false;

  @override
  void initState() {
    super.initState();
    _loadMockData();
  }

  void _loadMockData() {
    final now = DateTime.now();
    _items = [
      _MockPricingItem(id: '1', productName: 'أرز بسمتي ١٠ كيلو', currentPrice: 95, lastUpdated: now.subtract(const Duration(days: 2))),
      _MockPricingItem(id: '2', productName: 'زيت زيتون بكر ١ لتر', currentPrice: 140, lastUpdated: now.subtract(const Duration(days: 5))),
      _MockPricingItem(id: '3', productName: 'سكر أبيض ٥ كيلو', currentPrice: 18, lastUpdated: now.subtract(const Duration(days: 1))),
      _MockPricingItem(id: '4', productName: 'دقيق أبيض ١٠ كيلو', currentPrice: 22, lastUpdated: now.subtract(const Duration(days: 7))),
      _MockPricingItem(id: '5', productName: 'شاي أحمر ٢٠٠ جرام', currentPrice: 12, lastUpdated: now.subtract(const Duration(days: 3))),
      _MockPricingItem(id: '6', productName: 'قهوة عربية ٥٠٠ جرام', currentPrice: 45, lastUpdated: now.subtract(const Duration(hours: 12))),
      _MockPricingItem(id: '7', productName: 'حليب بودرة ٢.٥ كيلو', currentPrice: 55, lastUpdated: now.subtract(const Duration(days: 4))),
      _MockPricingItem(id: '8', productName: 'معكرونة إسباغيتي ٥٠٠ جرام', currentPrice: 5, lastUpdated: now.subtract(const Duration(days: 10))),
      _MockPricingItem(id: '9', productName: 'تونة خفيفة ١٧٠ جرام', currentPrice: 8, lastUpdated: now.subtract(const Duration(days: 6))),
      _MockPricingItem(id: '10', productName: 'صابون غسيل ٣ كيلو', currentPrice: 25, lastUpdated: now.subtract(const Duration(days: 8))),
    ];

    for (final item in _items) {
      _controllers[item.id] = TextEditingController();
    }
  }

  @override
  void dispose() {
    for (final c in _controllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  int get _changedCount {
    int count = 0;
    for (final item in _items) {
      final text = _controllers[item.id]?.text ?? '';
      if (text.isNotEmpty && double.tryParse(text) != null) {
        count++;
      }
    }
    return count;
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
            'إدارة الأسعار',
            style: TextStyle(fontWeight: FontWeight.bold, color: cs.onSurface),
          ),
          centerTitle: false,
          actions: [
            if (_changedCount > 0)
              Container(
                margin: const EdgeInsets.symmetric(vertical: 12),
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.warning.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    '$_changedCount تغيير',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.warning,
                    ),
                  ),
                ),
              ),
            const SizedBox(width: 12),
          ],
        ),
        body: Column(
          children: [
            // ── Summary Header ──
            _buildSummaryHeader(isDark, isMedium),

            // ── Pricing List ──
            Expanded(
              child: isWide
                  ? _buildPricingTable(isDark)
                  : _buildPricingCards(isDark, isMedium),
            ),

            // ── Save Button ──
            _buildSaveBar(isDark, isMedium),
          ],
        ),
    );
  }

  Widget _buildSummaryHeader(bool isDark, bool isMedium) {
    return Container(
      padding: EdgeInsets.all(isMedium ? 20 : 16),
      decoration: BoxDecoration(
        color: AppColors.getSurface(isDark),
        border: Border(
          bottom: BorderSide(color: AppColors.getBorder(isDark)),
        ),
      ),
      child: Row(
        children: [
          _summaryCard(
            Icons.inventory_2_rounded,
            '${_items.length}',
            'إجمالي المنتجات',
            AppColors.primary,
            isDark,
          ),
          const SizedBox(width: 12),
          _summaryCard(
            Icons.edit_rounded,
            '$_changedCount',
            'تغييرات معلقة',
            AppColors.warning,
            isDark,
          ),
          if (isMedium) ...[
            const SizedBox(width: 12),
            _summaryCard(
              Icons.update_rounded,
              DateFormat('dd/MM', 'ar').format(DateTime.now()),
              'آخر تحديث',
              AppColors.info,
              isDark,
            ),
          ],
        ],
      ),
    );
  }

  Widget _summaryCard(
      IconData icon, String value, String label, Color color, bool isDark) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: isDark ? 0.1 : 0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 11,
                      color: AppColors.getTextSecondary(isDark),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Wide Screen: Table ────────────────────────────────────────

  Widget _buildPricingTable(bool isDark) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.getSurface(isDark),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.getBorder(isDark)),
        ),
        child: Column(
          children: [
            // Header
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              decoration: BoxDecoration(
                color: AppColors.getSurfaceVariant(isDark),
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(16)),
              ),
              child: Row(
                children: [
                  _tHeader('المنتج', 4, isDark),
                  _tHeader('السعر الحالي', 2, isDark),
                  _tHeader('السعر الجديد', 3, isDark),
                  _tHeader('آخر تحديث', 2, isDark),
                  _tHeader('الفرق', 2, isDark),
                ],
              ),
            ),
            // Rows
            ...List.generate(_items.length, (index) {
              final item = _items[index];
              final controller = _controllers[item.id]!;
              final newPrice = double.tryParse(controller.text);
              final hasDiff = newPrice != null && newPrice != item.currentPrice;
              final diff = hasDiff ? newPrice - item.currentPrice : 0.0;

              return Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 20, vertical: 12),
                decoration: BoxDecoration(
                  color: hasDiff
                      ? AppColors.warning.withValues(alpha: isDark ? 0.05 : 0.02)
                      : null,
                  border: index < _items.length - 1
                      ? Border(
                          bottom: BorderSide(
                            color: AppColors.getBorder(isDark)
                                .withValues(alpha: 0.5),
                          ),
                        )
                      : null,
                ),
                child: Row(
                  children: [
                    Expanded(
                      flex: 4,
                      child: Text(
                        item.productName,
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
                        '${NumberFormat('#,##0.00').format(item.currentPrice)} ر.س',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.getTextSecondary(isDark),
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 3,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: TextField(
                          controller: controller,
                          keyboardType: TextInputType.number,
                          textAlign: TextAlign.center,
                          onChanged: (_) =>
                              setState(() => _hasChanges = true),
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: AppColors.getTextPrimary(isDark),
                          ),
                          decoration: InputDecoration(
                            hintText: item.currentPrice.toStringAsFixed(2),
                            hintStyle: TextStyle(
                                color: AppColors.getTextMuted(isDark)),
                            suffixText: 'ر.س',
                            suffixStyle: TextStyle(
                              fontSize: 11,
                              color: AppColors.getTextMuted(isDark),
                            ),
                            filled: true,
                            fillColor: AppColors.getSurfaceVariant(isDark),
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 10),
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
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Text(
                        DateFormat('dd/MM/yyyy', 'ar').format(item.lastUpdated),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.getTextMuted(isDark),
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: hasDiff
                          ? Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: (diff > 0
                                        ? AppColors.error
                                        : AppColors.success)
                                    .withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                '${diff > 0 ? '+' : ''}${NumberFormat('#,##0.00').format(diff)}',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: diff > 0
                                      ? AppColors.error
                                      : AppColors.success,
                                ),
                              ),
                            )
                          : Text(
                              '-',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  color: AppColors.getTextMuted(isDark)),
                            ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _tHeader(String text, int flex, bool isDark) {
    return Expanded(
      flex: flex,
      child: Text(
        text,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: AppColors.getTextSecondary(isDark),
        ),
      ),
    );
  }

  // ─── Mobile: Card View ─────────────────────────────────────────

  Widget _buildPricingCards(bool isDark, bool isMedium) {
    return ListView.separated(
      padding: EdgeInsets.all(isMedium ? 20 : 16),
      itemCount: _items.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (_, index) {
        final item = _items[index];
        final controller = _controllers[item.id]!;
        final newPrice = double.tryParse(controller.text);
        final hasDiff = newPrice != null && newPrice != item.currentPrice;

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.getSurface(isDark),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: hasDiff
                  ? AppColors.warning.withValues(alpha: 0.4)
                  : AppColors.getBorder(isDark),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
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
                  Text(
                    DateFormat('dd/MM', 'ar').format(item.lastUpdated),
                    style: TextStyle(
                      fontSize: 11,
                      color: AppColors.getTextMuted(isDark),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  // Current price
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'السعر الحالي',
                          style: TextStyle(
                            fontSize: 11,
                            color: AppColors.getTextMuted(isDark),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${NumberFormat('#,##0.00').format(item.currentPrice)} ر.س',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: AppColors.getTextSecondary(isDark),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.arrow_forward_rounded,
                      color: AppColors.textMuted, size: 18),
                  const SizedBox(width: 12),
                  // New price
                  Expanded(
                    child: TextField(
                      controller: controller,
                      keyboardType: TextInputType.number,
                      onChanged: (_) =>
                          setState(() => _hasChanges = true),
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: AppColors.getTextPrimary(isDark),
                      ),
                      decoration: InputDecoration(
                        labelText: 'السعر الجديد',
                        labelStyle: TextStyle(
                            fontSize: 12,
                            color: AppColors.getTextMuted(isDark)),
                        hintText: item.currentPrice.toStringAsFixed(2),
                        hintStyle:
                            TextStyle(color: AppColors.getTextMuted(isDark)),
                        suffixText: 'ر.س',
                        suffixStyle: TextStyle(
                          fontSize: 11,
                          color: AppColors.getTextMuted(isDark),
                        ),
                        filled: true,
                        fillColor: AppColors.getSurfaceVariant(isDark),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 12),
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
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  // ─── Save Bar ──────────────────────────────────────────────────

  Widget _buildSaveBar(bool isDark, bool isMedium) {
    final changed = _changedCount;
    if (changed == 0 && !_hasChanges) return const SizedBox.shrink();

    return Container(
      padding: EdgeInsets.all(isMedium ? 20 : 16),
      decoration: BoxDecoration(
        color: AppColors.getSurface(isDark),
        border: Border(
          top: BorderSide(color: AppColors.getBorder(isDark)),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            if (changed > 0)
              Expanded(
                child: Text(
                  '$changed منتج سيتم تحديث سعره',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.getTextSecondary(isDark),
                  ),
                ),
              ),
            SizedBox(
              width: isMedium ? 200 : 160,
              child: FilledButton.icon(
                onPressed:
                    _isSaving || changed == 0 ? null : _savePrices,
                icon: _isSaving
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white),
                      )
                    : const Icon(Icons.save_rounded, size: 18),
                label: const Text('حفظ التغييرات',
                    style:
                        TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _savePrices() async {
    setState(() => _isSaving = true);

    // Simulate API call
    await Future.delayed(const Duration(seconds: 1));

    if (!mounted) return;

    // Update prices in mock data
    for (final item in _items) {
      final controller = _controllers[item.id];
      final newPrice = double.tryParse(controller?.text ?? '');
      if (newPrice != null) {
        // In real implementation, update via API
        controller?.clear();
      }
    }

    setState(() {
      _isSaving = false;
      _hasChanges = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('تم حفظ التغييرات بنجاح'),
        backgroundColor: AppColors.success,
      ),
    );
  }
}
