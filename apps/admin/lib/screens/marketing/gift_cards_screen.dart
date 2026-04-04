import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart' show Value;
import 'package:get_it/get_it.dart';
import 'package:alhai_database/alhai_database.dart';
import 'package:alhai_design_system/alhai_design_system.dart';
import 'package:alhai_l10n/alhai_l10n.dart';
import 'package:alhai_shared_ui/alhai_shared_ui.dart';
import 'dart:math';

/// شاشة إدارة بطاقات الهدايا والقسائم
/// Uses [CouponsTable] with type='gift_card' for persistence.
class GiftCardsScreen extends ConsumerStatefulWidget {
  const GiftCardsScreen({super.key});

  @override
  ConsumerState<GiftCardsScreen> createState() => _GiftCardsScreenState();
}

class _GiftCardsScreenState extends ConsumerState<GiftCardsScreen>
    with SingleTickerProviderStateMixin {
  final _db = GetIt.I<AppDatabase>();
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
    try {
      final storeId = ref.read(currentStoreIdProvider)!;
      final coupons = await _db.discountsDao.getAllCoupons(storeId);

      // Filter to gift-card type coupons (type == 'gift_card')
      final giftCoupons = coupons.where((c) => c.type == 'gift_card').toList();

      if (giftCoupons.isNotEmpty) {
        _cards = giftCoupons.map((c) {
          final balance = c.value -
              (c.currentUses * c.value / (c.maxUses == 0 ? 1 : c.maxUses));
          final now = DateTime.now();
          String status;
          if (c.expiresAt != null && c.expiresAt!.isBefore(now)) {
            status = 'expired';
          } else if (balance <= 0) {
            status = 'used';
          } else if (c.currentUses > 0) {
            status = 'partially_used';
          } else {
            status = 'active';
          }
          return _GiftCard(
            code: c.code,
            amount: c.value,
            balance: balance.clamp(0, c.value),
            status: status,
            createdAt: c.createdAt,
            expiresAt: c.expiresAt ?? now.add(const Duration(days: 365)),
          );
        }).toList();
      } else {
        // Placeholder data when no gift cards exist
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
        ];
      }
    } catch (_) {
      // Keep existing data on error
    } finally {
      if (mounted) {
        setState(() {
          _applyFilter();
          _isLoading = false;
        });
      }
    }
  }

  void _applyFilter() {
    setState(() {
      _filteredCards = _cards.where((c) {
        final matchFilter = _filter == 'all' ||
            (_filter == 'active' &&
                (c.status == 'active' || c.status == 'partially_used')) ||
            (_filter == 'used' && c.status == 'used') ||
            (_filter == 'expired' && c.status == 'expired');
        final search = _searchController.text.toLowerCase();
        final matchSearch =
            search.isEmpty || c.code.toLowerCase().contains(search);
        return matchFilter && matchSearch;
      }).toList();
    });
  }

  String _generateCode() {
    final rng = Random();
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final code =
        List.generate(8, (_) => chars[rng.nextInt(chars.length)]).join();
    return 'GC-$code';
  }

  void _showIssueDialog() {
    double amount = 100;
    int validityDays = 365;
    final code = _generateCode();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(AppLocalizations.of(context).issueGiftCard),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Generated code
              Container(
                padding: const EdgeInsets.all(AlhaiSpacing.sm),
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
                      onPressed: () =>
                          Clipboard.setData(ClipboardData(text: code)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AlhaiSpacing.md),
              TextField(
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(context).cardValue,
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.attach_money_rounded),
                ),
                keyboardType: TextInputType.number,
                controller: TextEditingController(text: '100'),
                onChanged: (v) => amount = double.tryParse(v) ?? 100,
              ),
              const SizedBox(height: AlhaiSpacing.sm),
              TextField(
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(context).validityDays(365),
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.calendar_today_rounded),
                ),
                keyboardType: TextInputType.number,
                controller: TextEditingController(text: '365'),
                onChanged: (v) => validityDays = int.tryParse(v) ?? 365,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(AppLocalizations.of(context).cancel)),
          FilledButton.icon(
            onPressed: () async {
              final storeId = ref.read(currentStoreIdProvider)!;
              final id = 'gc_${DateTime.now().millisecondsSinceEpoch}';
              try {
                await _db.discountsDao.insertCoupon(
                  CouponsTableCompanion.insert(
                    id: id,
                    storeId: storeId,
                    code: code,
                    type: 'gift_card',
                    value: amount,
                    isActive: const Value(true),
                    expiresAt:
                        Value(DateTime.now().add(Duration(days: validityDays))),
                    createdAt: DateTime.now(),
                  ),
                );
              } catch (_) {
                // Best-effort persist
              }
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
              if (ctx.mounted) Navigator.pop(ctx);
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(AppLocalizations.of(context)
                        .giftCardIssued(amount.toStringAsFixed(0))),
                    backgroundColor: AppColors.success,
                  ),
                );
              }
            },
            icon: const Icon(Icons.card_giftcard_rounded),
            label: Text(AppLocalizations.of(context).issueCard),
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
        title: Text(AppLocalizations.of(context).redeemGiftCard),
        content: TextField(
          controller: codeController,
          decoration: InputDecoration(
            labelText: AppLocalizations.of(context).cardCode,
            hintText: 'GC-XXXXXXXX',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.qr_code_scanner_rounded),
          ),
          textCapitalization: TextCapitalization.characters,
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(AppLocalizations.of(context).cancel)),
          FilledButton(
            onPressed: () {
              final code = codeController.text.trim().toUpperCase();
              final card = _cards.where((c) => c.code == code).firstOrNull;
              Navigator.pop(ctx);
              if (card == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(AppLocalizations.of(context).noCardWithCode),
                    backgroundColor: Theme.of(context).colorScheme.error,
                  ),
                );
              } else if (card.balance <= 0) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(AppLocalizations.of(context).cardBalanceZero),
                    backgroundColor: Colors.orange,
                  ),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(AppLocalizations.of(context)
                        .cardBalance(card.balance.toStringAsFixed(2))),
                    backgroundColor: AppColors.success,
                  ),
                );
              }
            },
            child: Text(AppLocalizations.of(context).verify),
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
        title: Text(AppLocalizations.of(context).giftCards),
        actions: [
          IconButton(
            icon: const Icon(Icons.card_giftcard_rounded),
            tooltip: AppLocalizations.of(context).redeemCard,
            onPressed: _showRedeemDialog,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: AppLocalizations.of(context).cardsTab),
            Tab(text: AppLocalizations.of(context).statisticsTab),
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
                padding: const EdgeInsets.all(AlhaiSpacing.sm),
                child: Column(
                  children: [
                    TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: AppLocalizations.of(context).searchByCode,
                        prefixIcon: const Icon(Icons.search_rounded),
                        border: const OutlineInputBorder(),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: AlhaiSpacing.sm),
                        isDense: true,
                      ),
                      onChanged: (_) {
                        _searchDebounce?.cancel();
                        _searchDebounce =
                            Timer(const Duration(milliseconds: 300), () {
                          _applyFilter();
                        });
                      },
                    ),
                    const SizedBox(height: AlhaiSpacing.xs),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          for (final f in [
                            ('all', AppLocalizations.of(context).all),
                            (
                              'active',
                              AppLocalizations.of(context).activeFilter
                            ),
                            ('used', AppLocalizations.of(context).usedFilter),
                            (
                              'expired',
                              AppLocalizations.of(context).expiredFilter
                            ),
                          ])
                            Padding(
                              padding: const EdgeInsetsDirectional.only(
                                  start: AlhaiSpacing.xs),
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
                        ? AppEmptyState(
                            icon: Icons.card_giftcard_outlined,
                            title: AppLocalizations.of(context).noGiftCards,
                            description: AppLocalizations.of(context)
                                .issueGiftCardsDescription,
                            actionText:
                                AppLocalizations.of(context).issueGiftCard,
                            onAction: _showIssueDialog,
                            actionIcon: Icons.add_rounded,
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.symmetric(
                                horizontal: AlhaiSpacing.sm),
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
            padding: const EdgeInsets.all(AlhaiSpacing.md),
            children: [
              Row(children: [
                Expanded(
                    child: _StatCard(
                  label: AppLocalizations.of(context).totalActiveBalance,
                  value:
                      '${totalActive.toStringAsFixed(0)} ${AppLocalizations.of(context).sarSuffix}',
                  icon: Icons.account_balance_wallet_rounded,
                  color: Colors.green,
                )),
                const SizedBox(width: AlhaiSpacing.sm),
                Expanded(
                    child: _StatCard(
                  label: AppLocalizations.of(context).totalIssuedValue,
                  value:
                      '${totalIssued.toStringAsFixed(0)} ${AppLocalizations.of(context).sarSuffix}',
                  icon: Icons.card_giftcard_rounded,
                  color: Colors.purple,
                )),
              ]),
              const SizedBox(height: AlhaiSpacing.sm),
              Row(children: [
                Expanded(
                    child: _StatCard(
                  label: AppLocalizations.of(context).activeCards,
                  value: _cards
                      .where((c) =>
                          c.status == 'active' || c.status == 'partially_used')
                      .length
                      .toString(),
                  icon: Icons.check_circle_rounded,
                  color: Colors.blue,
                )),
                const SizedBox(width: AlhaiSpacing.sm),
                Expanded(
                    child: _StatCard(
                  label: AppLocalizations.of(context).usedCards,
                  value:
                      _cards.where((c) => c.status == 'used').length.toString(),
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
        label: Text(AppLocalizations.of(context).issueGiftCard),
      ),
    );
  }
}

class _GiftCardTile extends StatelessWidget {
  final _GiftCard card;
  const _GiftCardTile({required this.card});

  Color _statusColorOf(BuildContext context) {
    switch (card.status) {
      case 'active':
        return Colors.green;
      case 'partially_used':
        return Colors.orange;
      case 'used':
        return Theme.of(context).colorScheme.outline;
      case 'expired':
        return Colors.red;
      default:
        return Theme.of(context).colorScheme.outline;
    }
  }

  String _statusLabel(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    switch (card.status) {
      case 'active':
        return l10n.giftCardStatusActive;
      case 'partially_used':
        return l10n.giftCardStatusPartiallyUsed;
      case 'used':
        return l10n.giftCardStatusFullyUsed;
      case 'expired':
        return l10n.giftCardStatusExpired;
      default:
        return card.status;
    }
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _statusColorOf(context);
    final pctUsed = card.amount > 0 ? 1 - (card.balance / card.amount) : 1.0;
    return Card(
      margin: const EdgeInsets.only(bottom: AlhaiSpacing.xs),
      child: Padding(
        padding: const EdgeInsets.all(AlhaiSpacing.sm),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.card_giftcard_rounded, color: statusColor, size: 20),
                const SizedBox(width: AlhaiSpacing.xs),
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
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    _statusLabel(context),
                    style: TextStyle(
                        fontSize: 11,
                        color: statusColor,
                        fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AlhaiSpacing.xs),
            LinearProgressIndicator(
              value: pctUsed,
              backgroundColor:
                  Theme.of(context).colorScheme.surfaceContainerLow,
              valueColor: AlwaysStoppedAnimation<Color>(statusColor),
              minHeight: 4,
              borderRadius: BorderRadius.circular(2),
            ),
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  AppLocalizations.of(context).balanceDisplay(
                      card.balance.toStringAsFixed(0),
                      card.amount.toStringAsFixed(0)),
                  style: TextStyle(
                    fontSize: 12,
                    color: statusColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  AppLocalizations.of(context).expiresOn(
                      '${card.expiresAt.day}/${card.expiresAt.month}/${card.expiresAt.year}'),
                  style: TextStyle(
                      fontSize: 11, color: Theme.of(context).hintColor),
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
        padding: const EdgeInsets.all(AlhaiSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: AlhaiSpacing.xs),
            Text(value,
                style: TextStyle(
                    fontSize: 20, fontWeight: FontWeight.bold, color: color)),
            const SizedBox(height: AlhaiSpacing.xxs),
            Text(label,
                style: TextStyle(
                    fontSize: 12, color: Theme.of(context).hintColor)),
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
