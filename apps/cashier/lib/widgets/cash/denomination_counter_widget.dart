/// عداد فئات العملات السعودية
///
/// يتيح للكاشير عد النقود عن طريق إدخال عدد كل فئة
/// ويحسب الإجمالي تلقائياً
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:alhai_design_system/alhai_design_system.dart'
    show AlhaiSpacing, AppColors;
import 'package:alhai_l10n/alhai_l10n.dart';

class _Denomination {
  final double value;
  final bool isNote;

  const _Denomination({required this.value, required this.isNote});

  String label(AppLocalizations l10n) {
    if (value >= 1) {
      return l10n.denominationRiyal(value.toInt().toString());
    }
    return l10n.denominationHalala((value * 100).toInt().toString());
  }
}

const _denominations = [
  _Denomination(value: 500, isNote: true),
  _Denomination(value: 100, isNote: true),
  _Denomination(value: 50, isNote: true),
  _Denomination(value: 20, isNote: true),
  _Denomination(value: 10, isNote: true),
  _Denomination(value: 5, isNote: true),
  _Denomination(value: 1, isNote: false),
  _Denomination(value: 0.50, isNote: false),
  _Denomination(value: 0.25, isNote: false),
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
  State<DenominationCounterWidget> createState() =>
      _DenominationCounterWidgetState();
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
    final l10n = AppLocalizations.of(context);

    return Column(
      children: [
        // الإجمالي في الأعلى
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(AlhaiSpacing.md),
          decoration: BoxDecoration(
            gradient: AppColors.denominationGradient,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              Text(
                l10n.totalAmountLabel,
                style: const TextStyle(color: Colors.white70, fontSize: 13),
              ),
              const SizedBox(height: AlhaiSpacing.xxs),
              Text(
                l10n.amountRiyal(_total.toStringAsFixed(2)),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AlhaiSpacing.sm),

        // قسم الأوراق
        _buildSectionHeader(l10n.banknotes, Icons.money, isDark),
        ..._denominations
            .where((d) => d.isNote)
            .map((d) => _buildRow(d, isDark, l10n)),

        const SizedBox(height: AlhaiSpacing.xs),
        // قسم العملات المعدنية
        _buildSectionHeader(l10n.coins, Icons.toll, isDark),
        ..._denominations
            .where((d) => !d.isNote)
            .map((d) => _buildRow(d, isDark, l10n)),

        const SizedBox(height: AlhaiSpacing.sm),
        // زر الإعادة
        TextButton.icon(
          onPressed: _reset,
          icon: const Icon(Icons.refresh, size: 16),
          label: Text(l10n.resetAction),
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

  Widget _buildRow(_Denomination d, bool isDark, AppLocalizations l10n) {
    final count = _counts[d.value] ?? 0;
    final subtotal = d.value * count;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AlhaiSpacing.xxs),
      child: Row(
        children: [
          // الفئة
          SizedBox(
            width: 90,
            child: Text(
              d.label(l10n),
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
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                filled: true,
                fillColor: Theme.of(context).colorScheme.surface,
              ),
              onChanged: (v) => _onCountChanged(d.value, v),
            ),
          ),
          // فاصل
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: AlhaiSpacing.xs),
            child: Text('×', style: TextStyle(color: AppColors.textSecondary)),
          ),
          // الإجمالي الفرعي
          Expanded(
            child: Text(
              '= ${subtotal.toStringAsFixed(subtotal == subtotal.roundToDouble() ? 0 : 2)} ${l10n.sar}',
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
              color: isDark ? AppColors.backgroundDark : AppColors.surface,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(20),
              ),
            ),
            child: Column(
              children: [
                // Handle
                Center(
                  child: Container(
                    margin: const EdgeInsetsDirectional.only(
                      top: 10,
                      bottom: AlhaiSpacing.xs,
                    ),
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Theme.of(context).dividerColor,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AlhaiSpacing.md,
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.calculate_rounded,
                        color: AppColors.denominationAccent,
                      ),
                      const SizedBox(width: AlhaiSpacing.xs),
                      Text(
                        AppLocalizations.of(ctx).countCurrencyBtn,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Icons.close),
                        tooltip: AppLocalizations.of(ctx).close,
                        onPressed: () => Navigator.pop(ctx),
                      ),
                    ],
                  ),
                ),
                const Divider(),
                Expanded(
                  child: SingleChildScrollView(
                    controller: scrollCtrl,
                    padding: const EdgeInsets.all(AlhaiSpacing.md),
                    child: DenominationCounterWidget(
                      initialTotal: initialTotal,
                      onTotalChanged: (t) {
                        setSheet(() => currentTotal = t);
                      },
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsetsDirectional.only(
                    start: AlhaiSpacing.md,
                    end: AlhaiSpacing.md,
                    bottom:
                        AlhaiSpacing.md + MediaQuery.of(ctx).viewInsets.bottom,
                    top: AlhaiSpacing.xs,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(ctx),
                          child: Text(AppLocalizations.of(ctx).cancel),
                        ),
                      ),
                      const SizedBox(width: AlhaiSpacing.sm),
                      Expanded(
                        flex: 2,
                        child: FilledButton.icon(
                          onPressed: () => Navigator.pop(ctx, currentTotal),
                          icon: const Icon(Icons.check),
                          label: Text(
                            AppLocalizations.of(
                              ctx,
                            ).confirmAmountSar(currentTotal.toStringAsFixed(2)),
                          ),
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
