import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/locale/locale_provider.dart';
import '../../providers/products_providers.dart';
import '../../providers/theme_provider.dart';
import '../../widgets/auth/branch_card.dart';
import '../../l10n/generated/app_localizations.dart';

/// شاشة اختيار المتجر - تصميم جديد 2026
class StoreSelectScreen extends ConsumerStatefulWidget {
  const StoreSelectScreen({super.key});

  @override
  ConsumerState<StoreSelectScreen> createState() => _StoreSelectScreenState();
}

class _StoreSelectScreenState extends ConsumerState<StoreSelectScreen>
    with SingleTickerProviderStateMixin {
  final _searchController = TextEditingController();
  String _searchQuery = '';
  String? _selectedStoreId;
  late AnimationController _floatController;
  late Animation<double> _floatAnimation;

  // بيانات تجريبية للفروع
  final List<BranchData> _stores = [
    const BranchData(
      id: 'store_demo_001',
      name: 'الفرع الرئيسي - الرياض',
      address: 'طريق الملك فهد، حي العليا',
      type: BranchType.store,
      status: BranchStatus.open,
      isDefault: true,
    ),
    const BranchData(
      id: 'store_2',
      name: 'فرع جدة - التحلية',
      address: 'شارع التحلية، مركز البساتين',
      type: BranchType.store,
      status: BranchStatus.open,
    ),
    const BranchData(
      id: 'store_3',
      name: 'مستودع الدمام',
      address: 'المنطقة الصناعية الثانية',
      type: BranchType.warehouse,
      status: BranchStatus.closed,
      closedUntil: '8:00 ص',
    ),
    const BranchData(
      id: 'store_4',
      name: 'كشك المطار',
      address: 'صالة المغادرة الدولية، بوابة 4',
      type: BranchType.kiosk,
      status: BranchStatus.open,
    ),
  ];

  List<BranchData> get _filteredStores {
    if (_searchQuery.isEmpty) return _stores;
    return _stores.where((store) {
      return store.name.contains(_searchQuery) ||
          (store.address?.contains(_searchQuery) ?? false);
    }).toList();
  }

  @override
  void initState() {
    super.initState();
    // Animation للـ floating
    _floatController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat(reverse: true);

    _floatAnimation = Tween<double>(begin: 0, end: 15).animate(
      CurvedAnimation(parent: _floatController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    _floatController.dispose();
    super.dispose();
  }

  void _selectStore(BranchData store) {
    setState(() => _selectedStoreId = store.id);
    ref.read(currentStoreIdProvider.notifier).state = store.id;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_rounded, color: Colors.white),
            const SizedBox(width: 12),
            Text('تم اختيار ${store.name}'),
          ],
        ),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 1),
      ),
    );

    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) context.go('/dashboard');
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isWideScreen = size.width > 900;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDarkMode ? const Color(0xFF0F172A) : Colors.white,
      body: isWideScreen
          ? _buildWideLayout(isDarkMode)
          : _buildNarrowLayout(isDarkMode),
    );
  }

  // ============================================================================
  // تخطيط الشاشات العريضة (Desktop/Tablet)
  // ============================================================================
  Widget _buildWideLayout(bool isDarkMode) {
    return Row(
      children: [
        // اللوحة اليسرى - Brand Panel
        Expanded(
          flex: 4,
          child: _buildBrandPanel(),
        ),
        // اللوحة اليمنى - Content Panel
        Expanded(
          flex: 5,
          child: _buildContentPanel(isDarkMode, isMobile: false),
        ),
      ],
    );
  }

  // ============================================================================
  // تخطيط الجوال (Mobile)
  // ============================================================================
  Widget _buildNarrowLayout(bool isDarkMode) {
    return Column(
      children: [
        // Brand Header مصغر
        _buildMobileBrandHeader(),
        // Content
        Expanded(
          child: _buildContentPanel(isDarkMode, isMobile: true),
        ),
      ],
    );
  }

  // ============================================================================
  // اللوحة اليسرى - Brand Panel
  // ============================================================================
  Widget _buildBrandPanel() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.primary,
            AppColors.primaryDark,
          ],
        ),
      ),
      child: Stack(
        children: [
          // الأنماط الزخرفية في الخلفية
          _buildDecorativePatterns(),

          // المحتوى الرئيسي
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return SingleChildScrollView(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: constraints.maxHeight,
                      ),
                      child: IntrinsicHeight(
                        child: Column(
                          children: [
                            // شعار Al-HAI POS في الأعلى
                            _buildBrandLogo(),

                            const Spacer(),

                            // صورة الروبوت مع الحركة
                            _buildRobotMascot(),

                            const SizedBox(height: 24),

                            // العنوان والوصف
                            _buildBrandText(),

                            const Spacer(),

                            // الإحصائيات
                            _buildGlassStats(),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDecorativePatterns() {
    return Positioned.fill(
      child: IgnorePointer(
        child: Stack(
          children: [
            // دائرة كبيرة في الأعلى
            Positioned(
              top: -100,
              right: -100,
              child: Container(
                width: 400,
                height: 400,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.1),
                    width: 40,
                  ),
                ),
              ),
            ),
            // دائرة ضبابية في الأسفل
            Positioned(
              bottom: -50,
              left: -50,
              child: Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.05),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBrandLogo() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(
            Icons.point_of_sale_rounded,
            color: Colors.white,
            size: 24,
          ),
        ),
        const SizedBox(width: 12),
        const Text(
          'Al-HAI POS',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
            letterSpacing: 1,
          ),
        ),
      ],
    );
  }

  Widget _buildRobotMascot() {
    return AnimatedBuilder(
      animation: _floatAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, -_floatAnimation.value),
          child: child,
        );
      },
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Glow effect
          Container(
            width: 180,
            height: 180,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.primaryLight.withValues(alpha: 0.4),
                  blurRadius: 60,
                  spreadRadius: 15,
                ),
              ],
            ),
          ),
          // صورة الروبوت
          Image.asset(
            'assets/images/mascot_robot.png',
            width: 220,
            height: 220,
            fit: BoxFit.contain,
          ),
        ],
      ),
    );
  }

  Widget _buildBrandText() {
    final l10n = AppLocalizations.of(context);
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.language_rounded,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              l10n?.centralManagement ?? 'إدارة مركزية شاملة',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          l10n?.centralManagementDesc ??
              'تحكم في جميع فروعك ومستودعاتك من مكان واحد. احصل على تقارير فورية ومزامنة للمخزون بين جميع نقاط البيع.',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.9),
            fontSize: 14,
            height: 1.6,
          ),
        ),
      ],
    );
  }

  Widget _buildGlassStats() {
    final l10n = AppLocalizations.of(context);
    return Row(
      children: [
        Expanded(child: _buildStatItem('24/7', l10n?.support247 ?? 'دعم فني')),
        const SizedBox(width: 16),
        Expanded(child: _buildStatItem('50+', l10n?.analyticsTools ?? 'أدوات تحليل')),
        const SizedBox(width: 16),
        Expanded(child: _buildStatItem('99.9%', l10n?.uptime ?? 'وقت التشغيل')),
      ],
    );
  }

  Widget _buildStatItem(String value, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.8),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================================
  // Header للجوال
  // ============================================================================
  Widget _buildMobileBrandHeader() {
    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 16,
        left: 20,
        right: 20,
        bottom: 24,
      ),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.primaryDark],
        ),
      ),
      child: Row(
        children: [
          // صورة الروبوت مصغرة
          Image.asset(
            'assets/images/mascot_robot.png',
            width: 60,
            height: 60,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Al-HAI POS',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'اختر فرعك للمتابعة',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.9),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================================
  // اللوحة اليمنى - Content Panel
  // ============================================================================
  Widget _buildContentPanel(bool isDarkMode, {required bool isMobile}) {
    return Container(
      color: isDarkMode ? const Color(0xFF1E293B) : Colors.white,
      child: Column(
        children: [
          // Header
          _buildContentHeader(isDarkMode, isMobile: isMobile),

          // الفاصل
          Divider(
            height: 1,
            color: isDarkMode ? Colors.white12 : Colors.grey.shade200,
          ),

          // قائمة الفروع
          Expanded(
            child: _buildStoresList(isDarkMode),
          ),

          // Footer
          _buildFooter(isDarkMode),
        ],
      ),
    );
  }

  Widget _buildContentHeader(bool isDarkMode, {required bool isMobile}) {
    final localeState = ref.watch(localeProvider);
    final l10n = AppLocalizations.of(context);
    final iconSize = isMobile ? 36.0 : 44.0;
    
    return Container(
      padding: EdgeInsets.all(isMobile ? 12 : 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // صف الأدوات - ترتيب: خروج | معلومات المستخدم | ... | اللغة | Dark Mode
          Row(
            children: [
              // === اليسار: زر الخروج ===
              _buildIconButton(
                icon: Icons.logout_rounded,
                onTap: () => context.go('/login'),
                isDarkMode: isDarkMode,
                size: iconSize,
              ),
              
              SizedBox(width: isMobile ? 8 : 12),
              
              // === معلومات المستخدم ===
              Expanded(
                child: _buildUserInfo(isDarkMode, isMobile: isMobile),
              ),
              
              // === اليمين: اللغة + Dark Mode ===
              _buildLanguageSelector(isDarkMode, localeState, isMobile: isMobile),
              
              SizedBox(width: isMobile ? 6 : 8),
              
              _buildIconButton(
                icon: isDarkMode ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
                onTap: () {
                  ref.read(themeProvider.notifier).toggleDarkMode();
                },
                isDarkMode: isDarkMode,
                size: iconSize,
              ),
            ],
          ),

          SizedBox(height: isMobile ? 20 : 32),

          // العنوان
          Text(
            l10n?.selectBranchToContinue ?? 'اختر الفرع للمتابعة',
            style: TextStyle(
              color: isDarkMode ? Colors.white : AppColors.textPrimary,
              fontSize: isMobile ? 22 : 28,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 8),

          Text(
            l10n?.youHaveAccessToBranches ?? 'لديك صلاحية الوصول إلى الفروع التالية. اختر فرعاً للبدء.',
            style: TextStyle(
              color: isDarkMode ? Colors.white60 : AppColors.textSecondary,
              fontSize: 14,
            ),
          ),

          SizedBox(height: isMobile ? 16 : 24),

          // حقل البحث
          _buildSearchField(isDarkMode),
        ],
      ),
    );
  }

  Widget _buildIconButton({
    required IconData icon,
    required VoidCallback onTap,
    required bool isDarkMode,
    double size = 44,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(size * 0.27),
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: isDarkMode ? Colors.white.withValues(alpha: 0.1) : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(size * 0.27),
        ),
        child: Icon(
          icon,
          color: isDarkMode ? Colors.white70 : Colors.grey.shade600,
          size: size * 0.45,
        ),
      ),
    );
  }

  Widget _buildLanguageSelector(bool isDarkMode, LocaleState localeState, {bool isMobile = false}) {
    return PopupMenuButton<Locale>(
      offset: const Offset(0, 48),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: isDarkMode ? const Color(0xFF1E293B) : Colors.white,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: isMobile ? 8 : 12,
          vertical: isMobile ? 8 : 10,
        ),
        decoration: BoxDecoration(
          color: isDarkMode ? Colors.white.withValues(alpha: 0.1) : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(isMobile ? 10 : 12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _getLanguageFlag(localeState.locale.languageCode),
              style: TextStyle(fontSize: isMobile ? 14 : 16),
            ),
            if (!isMobile) ...[
              const SizedBox(width: 8),
              Text(
                _getLanguageName(localeState.locale.languageCode),
                style: TextStyle(
                  color: isDarkMode ? Colors.white : AppColors.textPrimary,
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                ),
              ),
            ],
            SizedBox(width: isMobile ? 2 : 4),
            Icon(
              Icons.keyboard_arrow_down,
              size: isMobile ? 16 : 18,
              color: isDarkMode ? Colors.white54 : Colors.grey,
            ),
          ],
        ),
      ),
      itemBuilder: (context) => SupportedLocales.all.map((locale) {
        return PopupMenuItem<Locale>(
          value: locale,
          child: Row(
            children: [
              Text(_getLanguageFlag(locale.languageCode)),
              const SizedBox(width: 12),
              Text(
                _getLanguageName(locale.languageCode),
                style: TextStyle(
                  color: isDarkMode ? Colors.white : AppColors.textPrimary,
                ),
              ),
            ],
          ),
        );
      }).toList(),
      onSelected: (locale) {
        ref.read(localeProvider.notifier).setLocale(locale);
      },
    );
  }

  String _getLanguageFlag(String code) {
    switch (code) {
      case 'ar': return '🇸🇦';
      case 'en': return '🇺🇸';
      case 'hi': return '🇮🇳';
      case 'bn': return '🇧🇩';
      case 'id': return '🇮🇩';
      case 'tl': return '🇵🇭';
      case 'ur': return '🇵🇰';
      default: return '🌍';
    }
  }

  String _getLanguageName(String code) {
    switch (code) {
      case 'ar': return 'العربية';
      case 'en': return 'English';
      case 'hi': return 'हिंदी';
      case 'bn': return 'বাংলা';
      case 'id': return 'Indonesia';
      case 'tl': return 'Filipino';
      case 'ur': return 'اردو';
      default: return code;
    }
  }

  Widget _buildUserInfo(bool isDarkMode, {bool isMobile = false}) {
    final avatarSize = isMobile ? 32.0 : 40.0;
    final l10n = AppLocalizations.of(context);
    
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // معلومات النص
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!isMobile)
              Text(
                l10n?.loggedInAs ?? 'مسجل الدخول كـ',
                style: TextStyle(
                  color: isDarkMode ? Colors.white54 : AppColors.textTertiary,
                  fontSize: 10,
                ),
              ),
            Directionality(
              textDirection: TextDirection.ltr,
              child: Text(
                isMobile ? '+966 55 123' : '+966 55 123 4567',
                style: TextStyle(
                  color: isDarkMode ? Colors.white : AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                  fontSize: isMobile ? 11 : 13,
                ),
              ),
            ),
          ],
        ),
        SizedBox(width: isMobile ? 8 : 12),
        // الأفاتار
        Container(
          width: avatarSize,
          height: avatarSize,
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(avatarSize * 0.25),
          ),
          child: Center(
            child: Text(
              'MA',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: isMobile ? 11 : 14,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSearchField(bool isDarkMode) {
    final l10n = AppLocalizations.of(context);
    return TextField(
      controller: _searchController,
      onChanged: (value) => setState(() => _searchQuery = value),
      style: TextStyle(
        color: isDarkMode ? Colors.white : AppColors.textPrimary,
      ),
      decoration: InputDecoration(
        hintText: l10n?.searchForBranch ?? 'بحث عن فرع...',
        hintStyle: TextStyle(
          color: isDarkMode ? Colors.white38 : AppColors.textTertiary,
        ),
        prefixIcon: Icon(
          Icons.search,
          color: isDarkMode ? Colors.white38 : AppColors.textTertiary,
        ),
        filled: true,
        fillColor: isDarkMode
            ? Colors.white.withValues(alpha: 0.05)
            : Colors.grey.shade50,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: isDarkMode ? Colors.white12 : Colors.grey.shade200,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: isDarkMode ? Colors.white12 : Colors.grey.shade200,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      ),
    );
  }

  Widget _buildStoresList(bool isDarkMode) {
    if (_filteredStores.isEmpty) {
      return _buildEmptyState(isDarkMode);
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      itemCount: _filteredStores.length + 1,
      itemBuilder: (context, index) {
        if (index == _filteredStores.length) {
          return _buildAddBranchButton(isDarkMode);
        }

        final store = _filteredStores[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _buildStoreCard(store, isDarkMode),
        );
      },
    );
  }

  Widget _buildStoreCard(BranchData store, bool isDarkMode) {
    final isSelected = store.id == _selectedStoreId;
    final isOpen = store.status == BranchStatus.open;
    final l10n = AppLocalizations.of(context);

    // ألوان الأيقونة حسب النوع
    Color iconBgColor;
    Color iconColor;
    IconData icon;

    switch (store.type) {
      case BranchType.store:
        iconBgColor = AppColors.primary.withValues(alpha: 0.1);
        iconColor = AppColors.primary;
        icon = Icons.storefront_rounded;
        break;
      case BranchType.warehouse:
        iconBgColor = Colors.orange.withValues(alpha: 0.1);
        iconColor = Colors.orange;
        icon = Icons.warehouse_rounded;
        break;
      case BranchType.kiosk:
        iconBgColor = Colors.purple.withValues(alpha: 0.1);
        iconColor = Colors.purple;
        icon = Icons.point_of_sale_rounded;
        break;
      case BranchType.restaurant:
        iconBgColor = Colors.red.withValues(alpha: 0.1);
        iconColor = Colors.red;
        icon = Icons.restaurant_rounded;
        break;
      case BranchType.salon:
        iconBgColor = Colors.pink.withValues(alpha: 0.1);
        iconColor = Colors.pink;
        icon = Icons.content_cut_rounded;
        break;
    }

    return InkWell(
      onTap: () => _selectStore(store),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDarkMode
              ? (isSelected ? AppColors.primary.withValues(alpha: 0.1) : Colors.white.withValues(alpha: 0.05))
              : (isSelected ? AppColors.primary.withValues(alpha: 0.05) : Colors.grey.shade50),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? AppColors.primary
                : (isDarkMode ? Colors.white12 : Colors.grey.shade200),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            // سهم الاختيار
            Icon(
              Icons.chevron_left,
              color: isDarkMode ? Colors.white38 : Colors.grey.shade400,
            ),

            const SizedBox(width: 12),

            // حالة الفرع
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: isOpen
                    ? AppColors.success.withValues(alpha: 0.1)
                    : Colors.grey.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: isOpen ? AppColors.success : Colors.grey,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    isOpen
                        ? (l10n?.openNow ?? 'مفتوح الآن')
                        : (store.closedUntil != null 
                            ? (l10n?.closedOpensAt(store.closedUntil!) ?? 'مغلق (يفتح ${store.closedUntil})')
                            : 'مغلق'),
                    style: TextStyle(
                      color: isOpen ? AppColors.success : Colors.grey,
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),

            const Spacer(),

            // معلومات الفرع
            Expanded(
              flex: 3,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    store.name,
                    style: TextStyle(
                      color: isDarkMode ? Colors.white : AppColors.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.end,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Flexible(
                        child: Text(
                          store.address ?? '',
                          style: TextStyle(
                            color: isDarkMode ? Colors.white54 : AppColors.textSecondary,
                            fontSize: 13,
                          ),
                          textAlign: TextAlign.end,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(
                        Icons.location_on_outlined,
                        size: 14,
                        color: isDarkMode ? Colors.white38 : AppColors.textTertiary,
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(width: 16),

            // الأيقونة
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: iconBgColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: iconColor, size: 24),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddBranchButton(bool isDarkMode) {
    final l10n = AppLocalizations.of(context);
    return Container(
      margin: const EdgeInsets.only(top: 8),
      child: OutlinedButton(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n?.comingSoon ?? 'سيتم إضافة هذه الميزة قريباً'),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          );
        },
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 20),
          side: BorderSide(
            color: isDarkMode ? Colors.white24 : Colors.grey.shade300,
            style: BorderStyle.solid,
          ),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.add_rounded,
              color: isDarkMode ? Colors.white54 : AppColors.textSecondary,
            ),
            const SizedBox(width: 8),
            Text(
              l10n?.addBranch ?? 'إضافة فرع جديد',
              style: TextStyle(
                color: isDarkMode ? Colors.white54 : AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(bool isDarkMode) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off_rounded,
            size: 64,
            color: isDarkMode ? Colors.white24 : AppColors.textTertiary,
          ),
          const SizedBox(height: 16),
          Text(
            'لا توجد نتائج',
            style: TextStyle(
              color: isDarkMode ? Colors.white54 : AppColors.textSecondary,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter(bool isDarkMode) {
    final l10n = AppLocalizations.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: isDarkMode ? Colors.white12 : Colors.grey.shade200,
          ),
        ),
      ),
      child: Wrap(
        alignment: WrapAlignment.spaceBetween,
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: 8,
        runSpacing: 8,
        children: [
          // روابط
          Wrap(
            spacing: 12,
            children: [
              _buildFooterLink(l10n?.technicalSupport ?? 'الدعم الفني', Icons.headset_mic_outlined, isDarkMode),
              _buildFooterLink(l10n?.privacyPolicy ?? 'سياسة الخصوصية', Icons.shield_outlined, isDarkMode),
            ],
          ),
          // حقوق النشر
          Text(
            '© Al-HAI POS v2.4.0 2026',
            style: TextStyle(
              color: isDarkMode ? Colors.white38 : AppColors.textTertiary,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooterLink(String text, IconData icon, bool isDarkMode) {
    return InkWell(
      onTap: () {},
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 14,
              color: isDarkMode ? Colors.white38 : AppColors.textTertiary,
            ),
            const SizedBox(width: 6),
            Text(
              text,
              style: TextStyle(
                color: isDarkMode ? Colors.white38 : AppColors.textTertiary,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
