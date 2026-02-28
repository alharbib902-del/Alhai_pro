import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:math';

/// شاشة إدارة بطاقات الهدايا والقسائم
class GiftCardsScreen extends ConsumerStatefulWidget {
  const GiftCardsScreen({super.key});

  @override
  ConsumerState<GiftCardsScreen> createState() => _GiftCardsScreenState();
}

class _GiftCardsScreenState extends ConsumerState<GiftCardsScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  bool _isLoading = false;
  List<_GiftCard> _cards = [];
  List<_GiftCard> _filteredCards = [];
  String _filter = 'all';

  final _searchController = TextEditingController();
  Timer? _searchDebounce;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadCards();
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadCards() async {
    setState(() => _isLoading = true);
    // Since gift_cards table may not exist yet, use mock data structure
    // In production, this would query the gift_cards table
    await Future.delayed(const Duration(milliseconds: 300));
    if (mounted) {
      setState(() {
        _cards = [
          _GiftCard(
            code: 'GC-2025-001',
            amount: 100,
            balance: 100,
            status: 'active',
            createdAt: DateTime.now().subtract(const Duration(days: 5)),
            expiresAt: DateTime.now().add(const Duration(days: 360)),
          ),
          _GiftCard(
            code: 'GC-2025-002',
            amount: 200,
            balance: 150,
            status: 'partially_used',
            createdAt: DateTime.now().subtract(const Duration(days: 10)),
            expiresAt: DateTime.now().add(const Duration(days: 355)),
          ),
          _GiftCard(
            code: 'GC-2025-003',
            amount: 50,
            balance: 0,
            status: 'used',
            createdAt: DateTime.now().subtract(const Duration(days: 30)),
            expiresAt: DateTime.now().add(const Duration(days: 335)),
          ),
        ];
        _applyFilter();
        _isLoading = false;
      });
    }
  }

  void _applyFilter() {
    setState(() {
      _filteredCards = _cards.where((c) {
        final matchFilter = _filter == 'all' ||
            (_filter == 'active' && (c.status == 'active' || c.status == 'partially_used')) ||
            (_filter == 'used' && c.status == 'used') ||
            (_filter == 'expired' && c.status == 'expired');
        final search = _searchController.text.toLowerCase();
        final matchSearch = search.isEmpty || c.code.toLowerCase().contains(search);
        return matchFilter && matchSearch;
      }).toList();
    });
  }

  String _generateCode() {
    final rng = Random();
    final chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final code = List.generate(8, (_) => chars[rng.nextInt(chars.length)]).join();
    return 'GC-$code';
  }

  void _showIssueDialog() {
    double amount = 100;
    int validityDays = 365;
    final code = _generateCode();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('إصدار بطاقة هدية'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Generated code
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.purple.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.purple.shade200),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      code,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2,
                        fontFamily: 'monospace',
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.copy_rounded, size: 18),
                      onPressed: () => Clipboard.setData(ClipboardData(text: code)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                decoration: const InputDecoration(
                  labelText: 'قيمة البطاقة (ر.س)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.attach_money_rounded),
                ),
                keyboardType: TextInputType.number,
                controller: TextEditingController(text: '100'),
                onChanged: (v) => amount = double.tryParse(v) ?? 100,
              ),
              const SizedBox(height: 12),
              TextField(
                decoration: const InputDecoration(
                  labelText: 'صلاحية (أيام)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.calendar_today_rounded),
                ),
                keyboardType: TextInputType.number,
                controller: TextEditingController(text: '365'),
                onChanged: (v) => validityDays = int.tryParse(v) ?? 365,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('إلغاء')),
          FilledButton.icon(
            onPressed: () {
              final newCard = _GiftCard(
                code: code,
                amount: amount,
                balance: amount,
                status: 'active',
                createdAt: DateTime.now(),
                expiresAt: DateTime.now().add(Duration(days: validityDays)),
              );
              setState(() {
                _cards.insert(0, newCard);
                _applyFilter();
              });
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('تم إصدار بطاقة هدية بقيمة ${amount.toStringAsFixed(0)} ر.س'),
                  backgroundColor: AppColors.success,
                ),
              );
            },
            icon: const Icon(Icons.card_giftcard_rounded),
            label: const Text('إصدار البطاقة'),
          ),
        ],
      ),
    );
  }

  void _showRedeemDialog() {
    final codeController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('صرف بطاقة هدية'),
        content: TextField(
          controller: codeController,
          decoration: const InputDecoration(
            labelText: 'كود البطاقة',
            hintText: 'GC-XXXXXXXX',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.qr_code_scanner_rounded),
          ),
          textCapitalization: TextCapitalization.characters,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('إلغاء')),
          FilledButton(
            onPressed: () {
              final code = codeController.text.trim().toUpperCase();
              final card = _cards.where((c) => c.code == code).firstOrNull;
              Navigator.pop(ctx);
              if (card == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('لا توجد بطاقة بهذا الكود'),
                    backgroundColor: Theme.of(context).colorScheme.error,
                  ),
                );
              } else if (card.balance <= 0) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('رصيد البطاقة صفر'),
                    backgroundColor: Colors.orange,
                  ),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('رصيد البطاقة: ${card.balance.toStringAsFixed(2)} ر.س'),
                    backgroundColor: AppColors.success,
                  ),
                );
              }
            },
            child: const Text('تحقق'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final totalActive = _cards
        .where((c) => c.status == 'active' || c.status == 'partially_used')
        .fold(0.0, (sum, c) => sum + c.balance);
    final totalIssued = _cards.fold(0.0, (sum, c) => sum + c.amount);

    return Scaffold(
      appBar: AppBar(
        title: const Text('بطاقات الهدايا'),
        actions: [
          IconButton(
            icon: const Icon(Icons.card_giftcard_rounded),
            tooltip: 'صرف بطاقة',
            onPressed: _showRedeemDialog,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'البطاقات'),
            Tab(text: 'الإحصائيات'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Tab 1: Cards list
          Column(
            children: [
              // Search and filter
              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  children: [
                    TextField(
                      controller: _searchController,
                      decoration: const InputDecoration(
                        hintText: 'بحث بالكود...',
                        prefixIcon: Icon(Icons.search_rounded),
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(horizontal: 12),
                        isDense: true,
                      ),
                      onChanged: (_) {
                        _searchDebounce?.cancel();
                        _searchDebounce = Timer(const Duration(milliseconds: 300), () {
                          _applyFilter();
                        });
                      },
                    ),
                    const SizedBox(height: 8),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          for (final f in [
                            ('all', 'الكل'),
                            ('active', 'نشطة'),
                            ('used', 'مستخدمة'),
                            ('expired', 'منتهية'),
                          ])
                            Padding(
                              padding: const EdgeInsetsDirectional.only(start: 8),
                              child: FilterChip(
                                label: Text(f.$2),
                                selected: _filter == f.$1,
                                onSelected: (_) {
                                  setState(() => _filter = f.$1);
                                  _applyFilter();
                                },
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _filteredCards.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.card_giftcard_outlined, size: 64, color: Theme.of(context).hintColor),
                                SizedBox(height: 12),
                                Text('لا توجد بطاقات هدايا', style: TextStyle(color: Theme.of(context).hintColor)),
                              ],
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            itemCount: _filteredCards.length,
                            itemBuilder: (ctx, i) {
                              final card = _filteredCards[i];
                              return _GiftCardTile(card: card);
                            },
                          ),
              ),
            ],
          ),

          // Tab 2: Statistics
          ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Row(children: [
                Expanded(child: _StatCard(
                  label: 'إجمالي الرصيد النشط',
                  value: '${totalActive.toStringAsFixed(0)} ر.س',
                  icon: Icons.account_balance_wallet_rounded,
                  color: Colors.green,
                )),
                const SizedBox(width: 12),
                Expanded(child: _StatCard(
                  label: 'إجمالي القيمة المصدرة',
                  value: '${totalIssued.toStringAsFixed(0)} ر.س',
                  icon: Icons.card_giftcard_rounded,
                  color: Colors.purple,
                )),
              ]),
              const SizedBox(height: 12),
              Row(children: [
                Expanded(child: _StatCard(
                  label: 'البطاقات النشطة',
                  value: _cards
                      .where((c) => c.status == 'active' || c.status == 'partially_used')
                      .length
                      .toString(),
                  icon: Icons.check_circle_rounded,
                  color: Colors.blue,
                )),
                const SizedBox(width: 12),
                Expanded(child: _StatCard(
                  label: 'البطاقات المستخدمة',
                  value: _cards.where((c) => c.status == 'used').length.toString(),
                  icon: Icons.done_all_rounded,
                  color: Theme.of(context).hintColor,
                )),
              ]),
            ],
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showIssueDialog,
        icon: const Icon(Icons.add_rounded),
        label: const Text('إصدار بطاقة هدية'),
      ),
    );
  }
}

class _GiftCardTile extends StatelessWidget {
  final _GiftCard card;
  const _GiftCardTile({required this.card});

  Color _statusColorOf(BuildContext context) {
    switch (card.status) {
      case 'active': return Colors.green;
      case 'partially_used': return Colors.orange;
      case 'used': return Theme.of(context).colorScheme.outline;
      case 'expired': return Colors.red;
      default: return Theme.of(context).colorScheme.outline;
    }
  }

  String get _statusLabel {
    switch (card.status) {
      case 'active': return 'نشطة';
      case 'partially_used': return 'مستخدمة جزئياً';
      case 'used': return 'مستخدمة بالكامل';
      case 'expired': return 'منتهية الصلاحية';
      default: return card.status;
    }
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _statusColorOf(context);
    final pctUsed = card.amount > 0 ? 1 - (card.balance / card.amount) : 1.0;
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.card_giftcard_rounded, color: statusColor, size: 20),
                const SizedBox(width: 8),
                Text(
                  card.code,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontFamily: 'monospace',
                    fontSize: 15,
                    letterSpacing: 1,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    _statusLabel,
                    style: TextStyle(fontSize: 11, color: statusColor, fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: pctUsed,
              backgroundColor: Theme.of(context).colorScheme.surfaceContainerLow,
              valueColor: AlwaysStoppedAnimation<Color>(statusColor),
              minHeight: 4,
              borderRadius: BorderRadius.circular(2),
            ),
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'الرصيد: ${card.balance.toStringAsFixed(0)}/${card.amount.toStringAsFixed(0)} ر.س',
                  style: TextStyle(
                    fontSize: 12,
                    color: statusColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  'ينتهي: ${card.expiresAt.day}/${card.expiresAt.month}/${card.expiresAt.year}',
                  style: TextStyle(fontSize: 11, color: Theme.of(context).hintColor),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color)),
            const SizedBox(height: 4),
            Text(label, style: TextStyle(fontSize: 12, color: Theme.of(context).hintColor)),
          ],
        ),
      ),
    );
  }
}

class _GiftCard {
  final String code;
  final double amount;
  final double balance;
  final String status;
  final DateTime createdAt;
  final DateTime expiresAt;

  const _GiftCard({
    required this.code,
    required this.amount,
    required this.balance,
    required this.status,
    required this.createdAt,
    required this.expiresAt,
  });
}
