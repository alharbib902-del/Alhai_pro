import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:drift/drift.dart' show Value;
import 'package:uuid/uuid.dart';
import '../../widgets/layout/app_header.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../core/theme/app_colors.dart';
import '../../data/local/app_database.dart';
import '../../di/injection.dart';
import '../../providers/products_providers.dart';

/// Special Offers Screen
class SpecialOffersScreen extends ConsumerStatefulWidget {
  const SpecialOffersScreen({super.key});

  @override
  ConsumerState<SpecialOffersScreen> createState() => _SpecialOffersScreenState();
}

class _SpecialOffersScreenState extends ConsumerState<SpecialOffersScreen> {

  List<PromotionsTableData> _promotions = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final storeId = ref.read(currentStoreIdProvider) ?? 'store_demo_001';
      final db = getIt<AppDatabase>();
      final results = await db.discountsDao.getAllPromotions(storeId);
      if (mounted) {
        setState(() {
          _promotions = results;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
      debugPrint('Error loading promotions: $e');
    }
  }
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
                  title: l10n.specialOffersTitle,
                  onMenuTap: isWideScreen
                      ? null
                      : () => Scaffold.of(context).openDrawer(),
                  onNotificationsTap: () => context.push('/notifications'),
                  notificationsCount: 3,
                  userName: l10n.cashCustomer,
                  userRole: l10n.branchManager,
                ),
                Expanded(
                  child: _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : SingleChildScrollView(
                          padding: EdgeInsets.all(isMediumScreen ? 24 : 16),
                          child: _buildContent(isWideScreen, isMediumScreen, isDark, l10n),
                        ),
                ),
              ],
            );
  }
  Widget _buildContent(bool isWideScreen, bool isMediumScreen, bool isDark, AppLocalizations l10n) {
    final cardColor = isDark ? const Color(0xFF1E293B) : Colors.white;
    final textColor = isDark ? Colors.white : AppColors.textPrimary;
    final subtextColor = isDark ? Colors.white70 : AppColors.textSecondary;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(l10n.manageSpecialOffers, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: textColor)),
            FilledButton.icon(
              onPressed: _addPromotion,
              icon: const Icon(Icons.add, size: 18),
              label: Text(l10n.newOffer),
              style: FilledButton.styleFrom(backgroundColor: AppColors.primary),
            ),
          ],
        ),
        const SizedBox(height: 20),

        // Stats
        Row(
          children: [
            Expanded(child: _buildStatCard(Icons.local_offer, l10n.totalLabel, '${_promotions.length}', AppColors.info, isDark)),
            SizedBox(width: isMediumScreen ? 16 : 12),
            Expanded(child: _buildStatCard(Icons.check_circle, l10n.active, '${_promotions.where((p) => p.isActive).length}', AppColors.success, isDark)),
            SizedBox(width: isMediumScreen ? 16 : 12),
            Expanded(child: _buildStatCard(Icons.timer, l10n.expiringSoon, '${_promotions.where((p) => p.isActive && p.endDate.difference(DateTime.now()).inDays <= 7).length}', AppColors.secondary, isDark)),
          ],
        ),
        const SizedBox(height: 20),

        // Promotions list
        ..._promotions.map((promotion) {
          final isExpired = promotion.endDate.isBefore(DateTime.now());
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: isExpired ? (isDark ? const Color(0xFF1E293B).withValues(alpha: 0.5) : Colors.grey.shade100) : cardColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: isDark ? Colors.white.withValues(alpha: 0.1) : AppColors.border),
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _getTypeColor(promotion.type).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(_getTypeIcon(promotion.type), color: _getTypeColor(promotion.type)),
              ),
              title: Row(
                children: [
                  Expanded(child: Text(promotion.name, style: TextStyle(fontWeight: FontWeight.bold, color: textColor))),
                  if (isExpired) Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(color: AppColors.textSecondary, borderRadius: BorderRadius.circular(4)),
                    child: Text(l10n.offerExpired, style: const TextStyle(color: Colors.white, fontSize: 10)),
                  ),
                ],
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(_getTypeLabel(promotion, l10n), style: TextStyle(color: subtextColor, fontSize: 12)),
                  Text('${promotion.endDate.day}/${promotion.endDate.month}/${promotion.endDate.year}', style: TextStyle(fontSize: 11, color: subtextColor)),
                ],
              ),
              trailing: Switch(
                value: promotion.isActive && !isExpired,
                onChanged: isExpired ? null : (v) => _toggleActive(promotion, v),
                activeThumbColor: AppColors.primary,
              ),
              onTap: () => _showPromotionDetails(promotion),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildStatCard(IconData icon, String label, String value, Color color, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isDark ? Colors.white.withValues(alpha: 0.1) : AppColors.border),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(value, style: TextStyle(fontWeight: FontWeight.bold, color: color, fontSize: 20)),
          Text(label, style: TextStyle(fontSize: 11, color: isDark ? Colors.white70 : AppColors.textSecondary)),
        ],
      ),
    );
  }

  Color _getTypeColor(String type) => {
    'bundle': const Color(0xFF8B5CF6),
    'buy_x_get_y': AppColors.info,
    'flash_sale': AppColors.success,
  }[type] ?? AppColors.textSecondary;

  IconData _getTypeIcon(String type) => {
    'bundle': Icons.inventory_2,
    'buy_x_get_y': Icons.card_giftcard,
    'flash_sale': Icons.flash_on,
  }[type] ?? Icons.local_offer;

  String _getTypeLabel(PromotionsTableData p, AppLocalizations l10n) {
    switch (p.type) {
      case 'bundle': return l10n.bundleDiscount('0');
      case 'buy_x_get_y': return l10n.buyAndGetFree;
      case 'flash_sale': return l10n.offerDiscountPercent('0');
      default: return '';
    }
  }

  Future<void> _toggleActive(PromotionsTableData promotion, bool value) async {
    try {
      final db = getIt<AppDatabase>();
      final updated = PromotionsTableData(
        id: promotion.id,
        storeId: promotion.storeId,
        name: promotion.name,
        nameEn: promotion.nameEn,
        description: promotion.description,
        type: promotion.type,
        rules: promotion.rules,
        startDate: promotion.startDate,
        endDate: promotion.endDate,
        isActive: value,
        createdAt: promotion.createdAt,
        updatedAt: DateTime.now(),
        syncedAt: promotion.syncedAt,
      );
      await db.discountsDao.updatePromotion(updated);
      await _loadData();
    } catch (e) {
      debugPrint('Error toggling promotion: $e');
    }
  }

  Future<void> _deletePromotion(PromotionsTableData promotion) async {
    try {
      final db = getIt<AppDatabase>();
      await db.discountsDao.deletePromotion(promotion.id);
      await _loadData();
    } catch (e) {
      debugPrint('Error deleting promotion: $e');
    }
  }

  void _addPromotion() {
    final nameController = TextEditingController();
    String type = 'flash_sale';
    final l10n = AppLocalizations.of(context)!;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(l10n.newOffer),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(controller: nameController, decoration: InputDecoration(labelText: l10n.offerName, prefixIcon: const Icon(Icons.local_offer))),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: type,
                  decoration: InputDecoration(labelText: l10n.offerType, prefixIcon: const Icon(Icons.category)),
                  items: [
                    DropdownMenuItem(value: 'flash_sale', child: Text(l10n.percentageDiscount)),
                    DropdownMenuItem(value: 'bundle', child: Text(l10n.bundleLabel)),
                    DropdownMenuItem(value: 'buy_x_get_y', child: Text(l10n.buyAndGet)),
                  ],
                  onChanged: (v) => setDialogState(() => type = v!),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: Text(l10n.cancel)),
            FilledButton(
              onPressed: () async {
                if (nameController.text.isNotEmpty) {
                  try {
                    final storeId = ref.read(currentStoreIdProvider) ?? 'store_demo_001';
                    final db = getIt<AppDatabase>();
                    final now = DateTime.now();
                    final companion = PromotionsTableCompanion(
                      id: Value(const Uuid().v4()),
                      storeId: Value(storeId),
                      name: Value(nameController.text),
                      nameEn: Value(nameController.text),
                      description: const Value(null),
                      type: Value(type),
                      rules: const Value('{}'),
                      startDate: Value(now),
                      endDate: Value(now.add(const Duration(days: 30))),
                      isActive: const Value(true),
                      createdAt: Value(now),
                      updatedAt: Value(now),
                    );
                    await db.discountsDao.insertPromotion(companion);
                    await _loadData();
                  } catch (e) {
                    debugPrint('Error adding promotion: $e');
                  }
                }
                if (!context.mounted) return;
                Navigator.pop(context);
              },
              child: Text(l10n.add),
            ),
          ],
        ),
      ),
    );
  }

  void _showPromotionDetails(PromotionsTableData p) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;
    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Icon(_getTypeIcon(p.type), size: 32, color: _getTypeColor(p.type)),
              const SizedBox(width: 12),
              Expanded(child: Text(p.name, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: isDark ? Colors.white : AppColors.textPrimary))),
            ]),
            const SizedBox(height: 16),
            _DetailRow(label: l10n.offerType, value: _getTypeLabel(p, l10n), isDark: isDark),
            _DetailRow(label: l10n.startDateLabel, value: '${p.startDate.day}/${p.startDate.month}/${p.startDate.year}', isDark: isDark),
            _DetailRow(label: l10n.endDateLabel, value: '${p.endDate.day}/${p.endDate.month}/${p.endDate.year}', isDark: isDark),
            _DetailRow(label: l10n.productsLabel, value: '0', isDark: isDark),
            const SizedBox(height: 16),
            Row(children: [
              Expanded(child: OutlinedButton.icon(onPressed: () { Navigator.pop(context); _deletePromotion(p); }, icon: const Icon(Icons.delete, color: AppColors.error), label: Text(l10n.delete, style: const TextStyle(color: AppColors.error)))),
              const SizedBox(width: 12),
              Expanded(child: FilledButton.icon(onPressed: () {}, icon: const Icon(Icons.edit), label: Text(l10n.edit), style: FilledButton.styleFrom(backgroundColor: AppColors.primary))),
            ]),
          ],
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label, value;
  final bool isDark;
  const _DetailRow({required this.label, required this.value, this.isDark = false});
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 8),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(color: isDark ? Colors.white60 : AppColors.textSecondary)),
        Text(value, style: TextStyle(fontWeight: FontWeight.w500, color: isDark ? Colors.white : AppColors.textPrimary)),
      ],
    ),
  );
}
