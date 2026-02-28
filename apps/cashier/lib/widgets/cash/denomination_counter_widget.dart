/// عداد فئات العملات السعودية
///
/// يتيح للكاشير عد النقود عن طريق إدخال عدد كل فئة
/// ويحسب الإجمالي تلقائياً
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:alhai_shared_ui/alhai_shared_ui.dart';

class _Denomination {
  final double value;
  final String labelAr;
  final bool isNote;

  const _Denomination({
    required this.value,
    required this.labelAr,
    required this.isNote,
  });
}

const _denominations = [
  _Denomination(value: 500, labelAr: '500 ريال', isNote: true),
  _Denomination(value: 100, labelAr: '100 ريال', isNote: true),
  _Denomination(value: 50, labelAr: '50 ريال', isNote: true),
  _Denomination(value: 20, labelAr: '20 ريال', isNote: true),
  _Denomination(value: 10, labelAr: '10 ريال', isNote: true),
  _Denomination(value: 5, labelAr: '5 ريال', isNote: true),
  _Denomination(value: 1, labelAr: '1 ريال', isNote: false),
  _Denomination(value: 0.50, labelAr: '50 هللة', isNote: false),
  _Denomination(value: 0.25, labelAr: '25 هللة', isNote: false),
];

/// ويدجت عداد الفئات - قابل للتضمين مباشرة
class DenominationCounterWidget extends StatefulWidget {
  /// دالة تُستدعى عند تغيير الإجمالي
  final ValueChanged<double>? onTotalChanged;

  /// القيمة الابتدائية (لتعبئة الحقول تلقائياً إن أمكن)
  final double initialTotal;

  const DenominationCounterWidget({
    super.key,
    this.onTotalChanged,
    this.initialTotal = 0,
  });

  @override
  State<DenominationCounterWidget> createState() => _DenominationCounterWidgetState();
}

class _DenominationCounterWidgetState extends State<DenominationCounterWidget> {
  final Map<double, TextEditingController> _controllers = {};
  final Map<double, int> _counts = {};

  @override
  void initState() {
    super.initState();
    for (final d in _denominations) {
      _controllers[d.value] = TextEditingController(text: '0');
      _counts[d.value] = 0;
    }
  }

  @override
  void dispose() {
    for (final c in _controllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  double get _total {
    double t = 0;
    for (final d in _denominations) {
      t += d.value * (_counts[d.value] ?? 0);
    }
    return t;
  }

  void _onCountChanged(double value, String text) {
    final count = int.tryParse(text) ?? 0;
    setState(() {
      _counts[value] = count;
    });
    widget.onTotalChanged?.call(_total);
  }

  void _reset() {
    setState(() {
      for (final d in _denominations) {
        _counts[d.value] = 0;
        _controllers[d.value]!.text = '0';
      }
    });
    widget.onTotalChanged?.call(0);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      children: [
        // الإجمالي في الأعلى
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF1A8FE3), Color(0xFF0EC9C9)],
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              const Text('إجمالي المبلغ', style: TextStyle(color: Colors.white70, fontSize: 13)),
              const SizedBox(height: 4),
              Text(
                '${_total.toStringAsFixed(2)} ريال',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // قسم الأوراق
        _buildSectionHeader('أوراق نقدية', Icons.money, isDark),
        ..._denominations.where((d) => d.isNote).map((d) => _buildRow(d, isDark)),

        const SizedBox(height: 8),
        // قسم العملات المعدنية
        _buildSectionHeader('عملات معدنية', Icons.toll, isDark),
        ..._denominations.where((d) => !d.isNote).map((d) => _buildRow(d, isDark)),

        const SizedBox(height: 12),
        // زر الإعادة
        TextButton.icon(
          onPressed: _reset,
          icon: const Icon(Icons.refresh, size: 16),
          label: const Text('إعادة تعيين'),
          style: TextButton.styleFrom(foregroundColor: Colors.red),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String title, IconData icon, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, size: 16, color: AppColors.primary),
          const SizedBox(width: 6),
          Text(
            title,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const Expanded(child: Divider(indent: 8)),
        ],
      ),
    );
  }

  Widget _buildRow(_Denomination d, bool isDark) {
    final count = _counts[d.value] ?? 0;
    final subtotal = d.value * count;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          // الفئة
          SizedBox(
            width: 90,
            child: Text(
              d.labelAr,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 14,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ),
          // حقل العدد
          SizedBox(
            width: 70,
            height: 36,
            child: TextField(
              controller: _controllers[d.value],
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              decoration: InputDecoration(
                contentPadding: EdgeInsets.zero,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                filled: true,
                fillColor: Theme.of(context).colorScheme.surface,
              ),
              onChanged: (v) => _onCountChanged(d.value, v),
            ),
          ),
          // فاصل
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 8),
            child: Text('×', style: TextStyle(color: AppColors.textSecondary)),
          ),
          // الإجمالي الفرعي
          Expanded(
            child: Text(
              '= ${subtotal.toStringAsFixed(subtotal == subtotal.roundToDouble() ? 0 : 2)} ر.س',
              style: TextStyle(
                fontSize: 13,
                fontWeight: count > 0 ? FontWeight.bold : FontWeight.normal,
                color: count > 0 ? AppColors.primary : AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// دالة مساعدة لعرض عداد الفئات في BottomSheet وإعادة الإجمالي
Future<double?> showDenominationCounterSheet(
  BuildContext context, {
  double initialTotal = 0,
}) {
  double currentTotal = initialTotal;

  return showModalBottomSheet<double>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) {
      final isDark = Theme.of(ctx).brightness == Brightness.dark;
      return StatefulBuilder(
        builder: (ctx, setSheet) => DraggableScrollableSheet(
          initialChildSize: 0.85,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          expand: false,
          builder: (_, scrollCtrl) => Container(
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E1E2E) : Colors.white,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Column(
              children: [
                // Handle
                Center(
                  child: Container(
                    margin: const EdgeInsets.only(top: 10, bottom: 8),
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Theme.of(context).dividerColor,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      const Icon(Icons.calculate_rounded, color: Color(0xFF1A8FE3)),
                      const SizedBox(width: 8),
                      const Text('عد العملات', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(ctx),
                      ),
                    ],
                  ),
                ),
                const Divider(),
                Expanded(
                  child: SingleChildScrollView(
                    controller: scrollCtrl,
                    padding: const EdgeInsets.all(16),
                    child: DenominationCounterWidget(
                      initialTotal: initialTotal,
                      onTotalChanged: (t) {
                        setSheet(() => currentTotal = t);
                      },
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(
                    left: 16,
                    right: 16,
                    bottom: 16 + MediaQuery.of(ctx).viewInsets.bottom,
                    top: 8,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(ctx),
                          child: const Text('إلغاء'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 2,
                        child: FilledButton.icon(
                          onPressed: () => Navigator.pop(ctx, currentTotal),
                          icon: const Icon(Icons.check),
                          label: Text('تأكيد: ${currentTotal.toStringAsFixed(2)} ر.س'),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}
