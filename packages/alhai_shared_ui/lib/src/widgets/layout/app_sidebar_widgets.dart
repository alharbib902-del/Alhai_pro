/// Sidebar sub-widgets extracted from app_sidebar.dart
part of 'app_sidebar.dart';

/// عنصر مسطح للقائمة الجانبية (عنوان مجموعة أو عنصر)
class _SidebarFlatEntry {
  final String? title;
  final AppSidebarItem? sidebarItem;

  const _SidebarFlatEntry._({this.title, this.sidebarItem});

  factory _SidebarFlatEntry.title(String title) =>
      _SidebarFlatEntry._(title: title);

  factory _SidebarFlatEntry.item(AppSidebarItem item) =>
      _SidebarFlatEntry._(sidebarItem: item);

  bool get isTitle => title != null;
}

/// هيدر القائمة الجانبية
class _SidebarHeader extends StatelessWidget {
  final String? storeName;
  final String? storeLogoUrl;
  final bool collapsed;

  const _SidebarHeader({
    this.storeName,
    this.storeLogoUrl,
    required this.collapsed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Container(
      height: 96,
      padding: EdgeInsets.all(collapsed ? 4 : 20),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).dividerColor,
          ),
        ),
      ),
      child: collapsed
          ? Center(
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: AlignmentDirectional.topStart,
                    end: AlignmentDirectional.bottomEnd,
                    colors: [AppColors.primary, Color(0xFF047857)],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha:0.3),
                      blurRadius: 15,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: storeLogoUrl != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: CachedNetworkImage(
                          imageUrl: storeLogoUrl!,
                          fit: BoxFit.cover,
                          placeholder: (_, __) => const Center(
                            child: CircularProgressIndicator(),
                          ),
                          errorWidget: (_, __, ___) => const Icon(
                            Icons.broken_image,
                            size: 40,
                          ),
                        ),
                      )
                    : const Icon(
                        Icons.point_of_sale_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
              ),
            )
          : Row(
              children: [
                // الشعار مع تدرج لوني
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: AlignmentDirectional.topStart,
                      end: AlignmentDirectional.bottomEnd,
                      colors: [AppColors.primary, Color(0xFF047857)],
                    ),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha:0.3),
                        blurRadius: 15,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: storeLogoUrl != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: CachedNetworkImage(
                            imageUrl: storeLogoUrl!,
                            fit: BoxFit.cover,
                            placeholder: (_, __) => const Center(
                              child: CircularProgressIndicator(),
                            ),
                            errorWidget: (_, __, ___) => const Icon(
                              Icons.broken_image,
                              size: 40,
                            ),
                          ),
                        )
                      : const Icon(
                          Icons.point_of_sale_rounded,
                          color: Colors.white,
                          size: 20,
                        ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        storeName ?? 'Al-Hal POS',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurface,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          height: 1.2,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Builder(builder: (ctx) {
                        final l10n = AppLocalizations.of(ctx)!;
                        return Text(
                          l10n.posSystem,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                            fontSize: 12,
                          ),
                        );
                      }),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}


/// عنصر في القائمة
class _SidebarItemWidget extends StatefulWidget {
  final AppSidebarItem item;
  final bool isSelected;
  final bool collapsed;
  final VoidCallback? onTap;

  const _SidebarItemWidget({
    required this.item,
    required this.isSelected,
    required this.collapsed,
    this.onTap,
  });

  @override
  State<_SidebarItemWidget> createState() => _SidebarItemWidgetState();
}

class _SidebarItemWidgetState extends State<_SidebarItemWidget> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: widget.collapsed ? 4 : 12,
          vertical: 2,
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: widget.onTap,
            borderRadius: BorderRadius.circular(12),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              padding: EdgeInsets.symmetric(
                horizontal: widget.collapsed ? 0 : 16,
                vertical: 14,
              ),
              decoration: BoxDecoration(
                color: widget.isSelected
                    ? AppColors.primary.withValues(alpha:0.1)
                    : _isHovered
                        ? (Theme.of(context).colorScheme.surfaceContainerHighest)
                        : Colors.transparent,
                borderRadius: BorderRadius.circular(12),
                border: widget.isSelected
                    ? const Border(
                        right: BorderSide(
                          color: AppColors.primary,
                          width: 3,
                        ),
                      )
                    : null,
              ),
              child: widget.collapsed
                  ? Center(
                      child: Icon(
                        widget.isSelected
                            ? (widget.item.activeIcon ?? widget.item.icon)
                            : widget.item.icon,
                        color: widget.isSelected
                            ? AppColors.primary
                            : (Theme.of(context).colorScheme.onSurfaceVariant),
                        size: 20,
                      ),
                    )
                  : Row(
                      children: [
                        // الأيقونة
                        Icon(
                          widget.isSelected
                              ? (widget.item.activeIcon ?? widget.item.icon)
                              : widget.item.icon,
                          color: widget.isSelected
                              ? AppColors.primary
                              : (Theme.of(context).colorScheme.onSurfaceVariant),
                          size: 20,
                        ),
                        const SizedBox(width: 16),

                        // العنوان
                        Expanded(
                          child: Text(
                            widget.item.title,
                            style: TextStyle(
                              color: widget.isSelected
                                  ? AppColors.primary
                                  : (Theme.of(context).colorScheme.onSurface),
                              fontSize: 14,
                              fontWeight: widget.isSelected
                                  ? FontWeight.w600
                                  : FontWeight.w500,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),

                        // الشارة (Badge)
                        if (widget.item.badge != null)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.error.withValues(alpha:0.1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              widget.item.badge!,
                              style: const TextStyle(
                                color: AppColors.error,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),

                        // علامة جديد
                        if (widget.item.isNew)
                          Builder(builder: (ctx) {
                            final l10n = AppLocalizations.of(ctx)!;
                            return Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.primary,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                l10n.newBadge,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            );
                          }),
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }
}

/// بطاقة المستخدم في القائمة الجانبية
class _UserProfileCard extends StatefulWidget {
  final String name;
  final String? role;
  final String? avatarUrl;
  final bool collapsed;
  final VoidCallback? onTap;

  const _UserProfileCard({
    required this.name,
    this.role,
    this.avatarUrl,
    required this.collapsed,
    this.onTap,
  });

  @override
  State<_UserProfileCard> createState() => _UserProfileCardState();
}

class _UserProfileCardState extends State<_UserProfileCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: widget.onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            padding: EdgeInsets.all(widget.collapsed ? 4 : 16),
            decoration: BoxDecoration(
              color: _isHovered
                  ? (Theme.of(context).colorScheme.surfaceContainerHighest)
                  : Colors.transparent,
            ),
            child: widget.collapsed
                ? Center(
                    child: Stack(
                      children: [
                        CircleAvatar(
                          radius: 18,
                          backgroundColor: AppColors.primary.withValues(alpha:0.15),
                          backgroundImage: widget.avatarUrl != null
                              ? CachedNetworkImageProvider(widget.avatarUrl!)
                              : null,
                          child: widget.avatarUrl == null
                              ? Text(
                                  widget.name.isNotEmpty
                                      ? widget.name[0].toUpperCase()
                                      : '?',
                                  style: const TextStyle(
                                    color: AppColors.primary,
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                )
                              : null,
                        ),
                        // نقطة الحالة (متصل)
                        PositionedDirectional(
                          bottom: 0,
                          end: 0,
                          child: Container(
                            width: 10,
                            height: 10,
                            decoration: BoxDecoration(
                              color: AppColors.success,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Theme.of(context).colorScheme.surface,
                                width: 2,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                : Row(
                    children: [
                      // الصورة الشخصية مع نقطة الحالة
                      Stack(
                        children: [
                          CircleAvatar(
                            radius: 18,
                            backgroundColor: AppColors.primary.withValues(alpha:0.15),
                            backgroundImage: widget.avatarUrl != null
                                ? CachedNetworkImageProvider(widget.avatarUrl!)
                                : null,
                            child: widget.avatarUrl == null
                                ? Text(
                                    widget.name.isNotEmpty
                                        ? widget.name[0].toUpperCase()
                                        : '?',
                                    style: const TextStyle(
                                      color: AppColors.primary,
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  )
                                : null,
                          ),
                          // نقطة الحالة (متصل)
                          PositionedDirectional(
                            bottom: 0,
                            end: 0,
                            child: Container(
                              width: 12,
                              height: 12,
                              decoration: BoxDecoration(
                                color: AppColors.success,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Theme.of(context).colorScheme.surface,
                                  width: 2,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 12),

                      // الاسم والدور
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              widget.name,
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.onSurface,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            if (widget.role != null) ...[
                              const SizedBox(height: 2),
                              Text(
                                widget.role!,
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                                  fontSize: 11,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ],
                        ),
                      ),

                      // سهم
                      Icon(
                        Icons.chevron_left_rounded,
                        color: isDark
                            ? Colors.white.withValues(alpha:0.3)
                            : AppColors.textTertiary,
                        size: 18,
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}

/// فوتر القائمة الجانبية
class _SidebarFooter extends StatelessWidget {
  final bool collapsed;
  final VoidCallback? onSettingsTap;
  final VoidCallback? onSupportTap;
  final VoidCallback? onLogoutTap;

  const _SidebarFooter({
    required this.collapsed,
    this.onSettingsTap,
    this.onSupportTap,
    this.onLogoutTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(collapsed ? 4 : 16),
      child: Builder(builder: (ctx) {
        final l10n = AppLocalizations.of(ctx)!;
        return Column(
          children: [
            _FooterButton(
              icon: Icons.settings_outlined,
              title: l10n.settings,
              collapsed: collapsed,
              onTap: onSettingsTap,
            ),
            const SizedBox(height: 4),
            _FooterButton(
              icon: Icons.help_outline_rounded,
              title: l10n.technicalSupportShort,
              collapsed: collapsed,
              onTap: onSupportTap,
            ),
            const SizedBox(height: 4),
            _FooterButton(
              icon: Icons.logout_rounded,
              title: l10n.logout,
              collapsed: collapsed,
              onTap: onLogoutTap,
              isDestructive: true,
            ),
          ],
        );
      }),
    );
  }
}

/// زر في فوتر القائمة
class _FooterButton extends StatefulWidget {
  final IconData icon;
  final String title;
  final bool collapsed;
  final VoidCallback? onTap;
  final bool isDestructive;

  const _FooterButton({
    required this.icon,
    required this.title,
    required this.collapsed,
    this.onTap,
    this.isDestructive = false,
  });

  @override
  State<_FooterButton> createState() => _FooterButtonState();
}

class _FooterButtonState extends State<_FooterButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final color = widget.isDestructive
        ? AppColors.error
        : AppColors.textSecondary;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: widget.onTap,
          borderRadius: BorderRadius.circular(8),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            padding: EdgeInsets.symmetric(
              horizontal: widget.collapsed ? 0 : 12,
              vertical: 10,
            ),
            decoration: BoxDecoration(
              color: _isHovered
                  ? (widget.isDestructive
                      ? AppColors.error.withValues(alpha:0.05)
                      : AppColors.backgroundSecondary)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(8),
            ),
            child: widget.collapsed
                ? Center(
                    child: Icon(
                      widget.icon,
                      color: color,
                      size: 20,
                    ),
                  )
                : Row(
                    children: [
                      Icon(
                        widget.icon,
                        color: color,
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          widget.title,
                          style: TextStyle(
                            color: color,
                            fontSize: 14,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}

/// القائمة الجانبية الافتراضية - مع دعم الترجمة
class DefaultSidebarItems {
  /// إنشاء القائمة الافتراضية مع الترجمة
  static List<SidebarGroup> getGroups(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    final dashboard = AppSidebarItem(
      id: 'dashboard',
      title: l10n.dashboard,
      icon: Icons.dashboard_outlined,
      activeIcon: Icons.dashboard_rounded,
    );

    final pos = AppSidebarItem(
      id: 'pos',
      title: l10n.pos,
      icon: Icons.point_of_sale_outlined,
      activeIcon: Icons.point_of_sale_rounded,
    );

    final products = AppSidebarItem(
      id: 'products',
      title: l10n.products,
      icon: Icons.inventory_2_outlined,
      activeIcon: Icons.inventory_2_rounded,
    );

    final categories = AppSidebarItem(
      id: 'categories',
      title: l10n.categories,
      icon: Icons.category_outlined,
      activeIcon: Icons.category_rounded,
    );

    final inventory = AppSidebarItem(
      id: 'inventory',
      title: l10n.inventory,
      icon: Icons.warehouse_outlined,
      activeIcon: Icons.warehouse_rounded,
      badge: '5',
      badgeColor: const Color(0xFFF59E0B),
    );

    final customers = AppSidebarItem(
      id: 'customers',
      title: l10n.customers,
      icon: Icons.people_outline_rounded,
      activeIcon: Icons.people_rounded,
    );

    final invoices = AppSidebarItem(
      id: 'invoices',
      title: l10n.invoices,
      icon: Icons.receipt_outlined,
      activeIcon: Icons.receipt_rounded,
    );

    final orders = AppSidebarItem(
      id: 'orders',
      title: l10n.ordersHistory,
      icon: Icons.history_rounded,
      activeIcon: Icons.history_rounded,
    );

    final sales = AppSidebarItem(
      id: 'sales',
      title: l10n.sales,
      icon: Icons.receipt_long_outlined,
      activeIcon: Icons.receipt_long_rounded,
    );

    final returns = AppSidebarItem(
      id: 'returns',
      title: l10n.returns,
      icon: Icons.assignment_return_outlined,
      activeIcon: Icons.assignment_return_rounded,
    );

    final voidTransaction = AppSidebarItem(
      id: 'void-transaction',
      title: l10n.voidTransaction,
      icon: Icons.block_outlined,
      activeIcon: Icons.block_rounded,
    );

    final reports = AppSidebarItem(
      id: 'reports',
      title: l10n.reports,
      icon: Icons.analytics_outlined,
      activeIcon: Icons.analytics_rounded,
    );

    final employees = AppSidebarItem(
      id: 'employees',
      title: l10n.employees,
      icon: Icons.badge_outlined,
      activeIcon: Icons.badge_rounded,
    );

    final loyalty = AppSidebarItem(
      id: 'loyalty',
      title: l10n.loyaltyProgram,
      icon: Icons.card_giftcard_outlined,
      activeIcon: Icons.card_giftcard_rounded,
      isNew: true,
    );

    final expenses = AppSidebarItem(
      id: 'expenses',
      title: l10n.expenses,
      icon: Icons.account_balance_wallet_outlined,
      activeIcon: Icons.account_balance_wallet_rounded,
    );

    final shifts = AppSidebarItem(
      id: 'shifts',
      title: l10n.shift,
      icon: Icons.schedule_outlined,
      activeIcon: Icons.schedule_rounded,
    );

    final suppliers2 = AppSidebarItem(
      id: 'suppliers',
      title: l10n.supplier,
      icon: Icons.local_shipping_outlined,
      activeIcon: Icons.local_shipping_rounded,
    );

    final purchases = AppSidebarItem(
      id: 'purchases',
      title: l10n.purchase,
      icon: Icons.shopping_bag_outlined,
      activeIcon: Icons.shopping_bag_rounded,
    );

    // TODO: Add dynamic badge to print-queue showing pending print jobs count
    final printQueue = AppSidebarItem(
      id: 'print-queue',
      title: l10n.printQueueTitle,
      icon: Icons.print_outlined,
      activeIcon: Icons.print_rounded,
    );

    final ecommerce = AppSidebarItem(
      id: 'ecommerce',
      title: l10n.ecommerce,
      icon: Icons.storefront_outlined,
      activeIcon: Icons.storefront_rounded,
      isNew: true,
    );

    final wallet = AppSidebarItem(
      id: 'wallet',
      title: l10n.wallet,
      icon: Icons.account_balance_wallet_outlined,
      activeIcon: Icons.account_balance_wallet_rounded,
      isNew: true,
    );

    final subscription = AppSidebarItem(
      id: 'subscription',
      title: l10n.subscription,
      icon: Icons.card_membership_outlined,
      activeIcon: Icons.card_membership_rounded,
      isNew: true,
    );

    final complaintsReport = AppSidebarItem(
      id: 'complaints-report',
      title: l10n.complaintsReport,
      icon: Icons.report_problem_outlined,
      activeIcon: Icons.report_problem_rounded,
      isNew: true,
    );

    final mediaLibrary = AppSidebarItem(
      id: 'media-library',
      title: l10n.mediaLibrary,
      icon: Icons.photo_library_outlined,
      activeIcon: Icons.photo_library_rounded,
      isNew: true,
    );

    final deviceLog = AppSidebarItem(
      id: 'device-log',
      title: l10n.deviceLog,
      icon: Icons.devices_outlined,
      activeIcon: Icons.devices_rounded,
      isNew: true,
    );

    final shippingGateways = AppSidebarItem(
      id: 'shipping-gateways',
      title: l10n.shippingGateways,
      icon: Icons.local_shipping_outlined,
      activeIcon: Icons.local_shipping_rounded,
      isNew: true,
    );

    final aiAssistant = AppSidebarItem(
      id: 'ai-assistant',
      title: l10n.aiAssistantTitle,
      icon: Icons.smart_toy_outlined,
      activeIcon: Icons.smart_toy_rounded,
      isNew: true,
    );

    final aiSalesForecasting = AppSidebarItem(
      id: 'ai-sales-forecasting',
      title: l10n.aiSalesForecastingTitle,
      icon: Icons.trending_up_outlined,
      activeIcon: Icons.trending_up_rounded,
    );

    final aiSmartPricing = AppSidebarItem(
      id: 'ai-smart-pricing',
      title: l10n.aiSmartPricingTitle,
      icon: Icons.price_change_outlined,
      activeIcon: Icons.price_change_rounded,
    );

    final aiFraudDetection = AppSidebarItem(
      id: 'ai-fraud-detection',
      title: l10n.aiFraudDetectionTitle,
      icon: Icons.security_outlined,
      activeIcon: Icons.security_rounded,
    );

    final aiBasketAnalysis = AppSidebarItem(
      id: 'ai-basket-analysis',
      title: l10n.aiBasketAnalysisTitle,
      icon: Icons.shopping_basket_outlined,
      activeIcon: Icons.shopping_basket_rounded,
    );

    final aiCustomerRecommendations = AppSidebarItem(
      id: 'ai-customer-recommendations',
      title: l10n.aiCustomerRecommendationsTitle,
      icon: Icons.recommend_outlined,
      activeIcon: Icons.recommend_rounded,
    );

    final aiSmartInventory = AppSidebarItem(
      id: 'ai-smart-inventory',
      title: l10n.aiSmartInventoryTitle,
      icon: Icons.inventory_outlined,
      activeIcon: Icons.inventory_rounded,
    );

    final aiCompetitorAnalysis = AppSidebarItem(
      id: 'ai-competitor-analysis',
      title: l10n.aiCompetitorAnalysisTitle,
      icon: Icons.compare_arrows_outlined,
      activeIcon: Icons.compare_arrows_rounded,
    );

    final aiSmartReports = AppSidebarItem(
      id: 'ai-smart-reports',
      title: l10n.aiSmartReportsTitle,
      icon: Icons.auto_awesome_outlined,
      activeIcon: Icons.auto_awesome_rounded,
    );

    final aiStaffAnalytics = AppSidebarItem(
      id: 'ai-staff-analytics',
      title: l10n.aiStaffAnalyticsTitle,
      icon: Icons.people_alt_outlined,
      activeIcon: Icons.people_alt_rounded,
    );

    final aiProductRecognition = AppSidebarItem(
      id: 'ai-product-recognition',
      title: l10n.aiProductRecognitionTitle,
      icon: Icons.camera_alt_outlined,
      activeIcon: Icons.camera_alt_rounded,
    );

    final aiSentimentAnalysis = AppSidebarItem(
      id: 'ai-sentiment-analysis',
      title: l10n.aiSentimentAnalysisTitle,
      icon: Icons.sentiment_satisfied_alt_outlined,
      activeIcon: Icons.sentiment_satisfied_alt_rounded,
    );

    final aiReturnPrediction = AppSidebarItem(
      id: 'ai-return-prediction',
      title: l10n.aiReturnPredictionTitle,
      icon: Icons.assignment_return_outlined,
      activeIcon: Icons.assignment_return_rounded,
    );

    final aiPromotionDesigner = AppSidebarItem(
      id: 'ai-promotion-designer',
      title: l10n.aiPromotionDesignerTitle,
      icon: Icons.campaign_outlined,
      activeIcon: Icons.campaign_rounded,
    );

    final aiChatWithData = AppSidebarItem(
      id: 'ai-chat-with-data',
      title: l10n.aiChatWithDataTitle,
      icon: Icons.chat_outlined,
      activeIcon: Icons.chat_rounded,
    );

    return [
      SidebarGroup(
        items: [dashboard, pos],
      ),
      SidebarGroup(
        title: l10n.storeManagement,
        items: [products, categories, inventory, customers, suppliers2, mediaLibrary],
      ),
      SidebarGroup(
        title: l10n.ecommerceSection,
        items: [ecommerce, shippingGateways],
      ),
      SidebarGroup(
        title: l10n.finance,
        items: [invoices, orders, sales, returns, voidTransaction, expenses, wallet, reports, complaintsReport, printQueue],
      ),
      SidebarGroup(
        title: l10n.teamSection,
        items: [employees, loyalty, shifts, purchases],
      ),
      SidebarGroup(
        title: l10n.systemSection,
        items: [subscription, deviceLog],
      ),
      SidebarGroup(
        title: l10n.aiSection,
        items: [
          aiAssistant,
          aiSalesForecasting,
          aiSmartPricing,
          aiFraudDetection,
          aiBasketAnalysis,
          aiCustomerRecommendations,
          aiSmartInventory,
          aiCompetitorAnalysis,
          aiSmartReports,
          aiStaffAnalytics,
          aiProductRecognition,
          aiSentimentAnalysis,
          aiReturnPrediction,
          aiPromotionDesigner,
          aiChatWithData,
        ],
      ),
    ];
  }

  /// للتوافق مع الاستخدام القديم (fallback بالعربي)
  static const List<SidebarGroup> defaultGroups = [
    SidebarGroup(
      items: [
        AppSidebarItem(id: 'dashboard', title: 'Dashboard', icon: Icons.dashboard_outlined, activeIcon: Icons.dashboard_rounded),
        AppSidebarItem(id: 'pos', title: 'POS', icon: Icons.point_of_sale_outlined, activeIcon: Icons.point_of_sale_rounded),
      ],
    ),
    SidebarGroup(
      title: 'Store',
      items: [
        AppSidebarItem(id: 'products', title: 'Products', icon: Icons.inventory_2_outlined, activeIcon: Icons.inventory_2_rounded),
        AppSidebarItem(id: 'categories', title: 'Categories', icon: Icons.category_outlined, activeIcon: Icons.category_rounded),
        AppSidebarItem(id: 'inventory', title: 'Inventory', icon: Icons.warehouse_outlined, activeIcon: Icons.warehouse_rounded, badge: '5', badgeColor: Color(0xFFF59E0B)),
        AppSidebarItem(id: 'customers', title: 'Customers', icon: Icons.people_outline_rounded, activeIcon: Icons.people_rounded),
      ],
    ),
    SidebarGroup(
      title: 'Finance',
      items: [
        AppSidebarItem(id: 'sales', title: 'Sales', icon: Icons.receipt_long_outlined, activeIcon: Icons.receipt_long_rounded),
        AppSidebarItem(id: 'reports', title: 'Reports', icon: Icons.analytics_outlined, activeIcon: Icons.analytics_rounded),
      ],
    ),
    SidebarGroup(
      title: 'Team',
      items: [
        AppSidebarItem(id: 'employees', title: 'Employees', icon: Icons.badge_outlined, activeIcon: Icons.badge_rounded),
        AppSidebarItem(id: 'loyalty', title: 'Loyalty', icon: Icons.card_giftcard_outlined, activeIcon: Icons.card_giftcard_rounded, isNew: true),
      ],
    ),
  ];
}
