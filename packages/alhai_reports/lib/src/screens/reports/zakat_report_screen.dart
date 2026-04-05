import 'package:drift/drift.dart' hide Column;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:alhai_database/alhai_database.dart';
import 'package:get_it/get_it.dart';
import 'package:alhai_auth/alhai_auth.dart';
import 'package:alhai_design_system/alhai_design_system.dart';

/// شاشة حساب الزكاة
/// وفق المعايير الشرعية للمملكة العربية السعودية
class ZakatReportScreen extends ConsumerStatefulWidget {
  const ZakatReportScreen({super.key});

  @override
  ConsumerState<ZakatReportScreen> createState() => _ZakatReportScreenState();
}

class _ZakatReportScreenState extends ConsumerState<ZakatReportScreen> {
  bool _isLoading = true;
  String? _error;

  // Zakat base components
  double _inventoryValue = 0;
  double _cashBalance = 0;
  double _accountsReceivable = 0;
  double _accountsPayable = 0;
  double _otherLiabilities = 0;

  // Nisab (as of approximate gold rate in SAR)
  static const double _nisabSar = 5950.0; // ~85g gold × ~70 SAR/g
  static const double _zakatRate = 0.025; // 2.5%

  double get _zakatableAssets =>
      _inventoryValue + _cashBalance + _accountsReceivable;
  double get _zakatableDeductions => _accountsPayable + _otherLiabilities;
  double get _netZakatBase =>
      (_zakatableAssets - _zakatableDeductions).clamp(0.0, double.infinity);
  double get _zakatDue =>
      _netZakatBase >= _nisabSar ? _netZakatBase * _zakatRate : 0;
  bool get _aboveNisab => _netZakatBase >= _nisabSar;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });
      final db = GetIt.I<AppDatabase>();
      final storeId = ref.read(currentStoreIdProvider);
      if (storeId == null) {
        setState(() {
          _error = 'لم يتم تحديد المتجر';
          _isLoading = false;
        });
        return;
      }

      // Inventory value
      final invResult = await db.customSelect(
        '''SELECT COALESCE(SUM(current_stock * COALESCE(cost_price, price * 0.7)), 0) as total
           FROM products WHERE store_id = ? AND current_stock > 0''',
        variables: [Variable.withString(storeId)],
      ).getSingle();

      // Cash balance
      final cashResult = await db.customSelect(
        '''SELECT COALESCE(SUM(CASE WHEN type IN ('sale','cash_in') THEN amount ELSE -amount END), 0) as cash
           FROM transactions WHERE store_id = ?''',
        variables: [Variable.withString(storeId)],
      ).getSingle();

      // Receivables
      final recResult = await db.customSelect(
        '''SELECT COALESCE(SUM(balance), 0) as total
           FROM accounts WHERE store_id = ? AND type = 'receivable' AND balance > 0''',
        variables: [Variable.withString(storeId)],
      ).getSingle();

      // Payables
      final payResult = await db.customSelect(
        '''SELECT COALESCE(SUM(balance), 0) as total
           FROM accounts WHERE store_id = ? AND type = 'payable' AND balance > 0''',
        variables: [Variable.withString(storeId)],
      ).getSingle();

      if (mounted) {
        setState(() {
          _inventoryValue = _toDouble(invResult.data['total']);
          _cashBalance =
              _toDouble(cashResult.data['cash']).clamp(0.0, double.infinity);
          _accountsReceivable = _toDouble(recResult.data['total']);
          _accountsPayable = _toDouble(payResult.data['total']);
          _otherLiabilities = 0;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  double _toDouble(dynamic v) {
    if (v is int) return v.toDouble();
    if (v is double) return v;
    return 0.0;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('حساب الزكاة')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }
    if (_error != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('حساب الزكاة')),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.error_outline, size: 48, color: AlhaiColors.error),
              const SizedBox(height: AlhaiSpacing.sm),
              Text(_error!),
              TextButton(
                  onPressed: _loadData, child: const Text('إعادة المحاولة')),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('حساب الزكاة'),
        actions: [
          IconButton(
              icon: const Icon(Icons.refresh_rounded), onPressed: _loadData),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(AlhaiSpacing.md),
        children: [
          // Zakat result card
          Card(
            color: _aboveNisab
                ? AlhaiColors.success.withValues(alpha: 0.08)
                : AlhaiColors.info.withValues(alpha: 0.08),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(
                color: _aboveNisab
                    ? AlhaiColors.success.withValues(alpha: 0.7)
                    : AlhaiColors.info.withValues(alpha: 0.7),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(AlhaiSpacing.lg),
              child: Column(
                children: [
                  Icon(
                    Icons.mosque_rounded,
                    size: 48,
                    color: _aboveNisab ? AlhaiColors.success : AlhaiColors.info,
                  ),
                  const SizedBox(height: AlhaiSpacing.sm),
                  Text(
                    _aboveNisab ? 'وجبت الزكاة' : 'لم يبلغ النصاب',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: _aboveNisab
                          ? AlhaiColors.successDark
                          : AlhaiColors.infoDark,
                    ),
                  ),
                  if (_aboveNisab) ...[
                    const SizedBox(height: AlhaiSpacing.xs),
                    Text('مقدار الزكاة الواجبة',
                        style: TextStyle(
                            color: theme.colorScheme.onSurfaceVariant,
                            fontSize: 13)),
                    const SizedBox(height: AlhaiSpacing.xxs),
                    Text(
                      '${_zakatDue.toStringAsFixed(2)} ر.س',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: AlhaiColors.successDark,
                      ),
                    ),
                    Text(
                      'بنسبة ${(_zakatRate * 100).toStringAsFixed(1)}% من وعاء الزكاة',
                      style: TextStyle(
                          color: theme.colorScheme.onSurfaceVariant,
                          fontSize: 12),
                    ),
                  ] else ...[
                    const SizedBox(height: AlhaiSpacing.xs),
                    Text(
                      'النصاب الشرعي: ${_nisabSar.toStringAsFixed(0)} ر.س',
                      style: TextStyle(color: AlhaiColors.infoDark),
                    ),
                    Text(
                      'وعاء الزكاة الحالي: ${_netZakatBase.toStringAsFixed(0)} ر.س',
                      style: TextStyle(
                          color: theme.colorScheme.onSurfaceVariant,
                          fontSize: 12),
                    ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: AlhaiSpacing.mdl),

          // Nisab info
          Card(
            color: isDark ? const Color(0xFF1E293B) : Colors.amber.shade50,
            child: Padding(
              padding: const EdgeInsets.all(AlhaiSpacing.sm),
              child: Row(
                children: [
                  Icon(Icons.info_outline,
                      color: Colors.amber.shade700, size: 20),
                  const SizedBox(width: AlhaiSpacing.xs),
                  Expanded(
                    child: Text(
                      'النصاب: ${_nisabSar.toStringAsFixed(0)} ر.س '
                      '(قيمة 85 جرام من الذهب تقريباً)',
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark
                            ? Colors.amber.shade200
                            : Colors.amber.shade800,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AlhaiSpacing.mdl),

          // Zakat base calculation
          const Text('أصول الزكاة (+)',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
          const SizedBox(height: AlhaiSpacing.xs),
          _ZakatLine(
            label: 'قيمة البضاعة والمخزون',
            amount: _inventoryValue,
            isAddition: true,
            isDark: isDark,
          ),
          _ZakatLine(
            label: 'النقد المتوفر',
            amount: _cashBalance,
            isAddition: true,
            isDark: isDark,
          ),
          _ZakatLine(
            label: 'الديون المتوقع تحصيلها',
            amount: _accountsReceivable,
            isAddition: true,
            isDark: isDark,
          ),

          const SizedBox(height: AlhaiSpacing.sm),
          const Text('الخصومات (-)',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
          const SizedBox(height: AlhaiSpacing.xs),
          _ZakatLine(
            label: 'الديون الواجبة للموردين',
            amount: _accountsPayable,
            isAddition: false,
            isDark: isDark,
          ),
          _ZakatLine(
            label: 'التزامات أخرى',
            amount: _otherLiabilities,
            isAddition: false,
            isDark: isDark,
          ),

          const SizedBox(height: AlhaiSpacing.md),
          const Divider(thickness: 2),
          const SizedBox(height: AlhaiSpacing.xs),

          // Net zakat base
          Container(
            padding: const EdgeInsets.all(AlhaiSpacing.md),
            decoration: BoxDecoration(
              color: AlhaiColors.info.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('وعاء الزكاة الصافي',
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                Text(
                  '${_netZakatBase.toStringAsFixed(0)} ر.س',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: AlhaiColors.info,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AlhaiSpacing.xs),

          // Zakat calculation
          if (_aboveNisab)
            Container(
              padding: const EdgeInsets.all(AlhaiSpacing.md),
              decoration: BoxDecoration(
                color: AlhaiColors.success.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                          '${_netZakatBase.toStringAsFixed(0)} × ${(_zakatRate * 100).toStringAsFixed(1)}%',
                          style: const TextStyle(fontSize: 13)),
                      Text(
                        '${_zakatDue.toStringAsFixed(2)} ر.س',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: AlhaiColors.successDark,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AlhaiSpacing.xs),
                  Text(
                    'تنبيه: هذا الحساب تقريبي. يُنصح بمراجعة مختص شرعي لتحديد الزكاة الواجبة بدقة.',
                    style: TextStyle(
                        fontSize: 11,
                        color: theme.colorScheme.onSurfaceVariant),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _ZakatLine extends StatelessWidget {
  final String label;
  final double amount;
  final bool isAddition;
  final bool isDark;

  const _ZakatLine({
    required this.label,
    required this.amount,
    required this.isAddition,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final color = isAddition ? AlhaiColors.successDark : AlhaiColors.errorDark;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AlhaiSpacing.xxs),
      child: Row(
        children: [
          Icon(
            isAddition ? Icons.add_circle_outline : Icons.remove_circle_outline,
            size: 18,
            color: color,
          ),
          const SizedBox(width: AlhaiSpacing.xs),
          Expanded(child: Text(label, style: const TextStyle(fontSize: 13))),
          Text(
            '${amount.toStringAsFixed(0)} ر.س',
            style: TextStyle(
              fontWeight: FontWeight.w500,
              color: color,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}
