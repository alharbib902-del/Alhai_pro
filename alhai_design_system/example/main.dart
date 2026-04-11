import 'package:flutter/material.dart';
import 'package:alhai_design_system/alhai_design_system.dart';

/// Alhai Design System Showcase
/// This example demonstrates all components with RTL, dark mode, and responsive layouts
void main() {
  runApp(const AlhaiDesignShowcase());
}

class AlhaiDesignShowcase extends StatefulWidget {
  const AlhaiDesignShowcase({super.key});

  @override
  State<AlhaiDesignShowcase> createState() => _AlhaiDesignShowcaseState();
}

class _AlhaiDesignShowcaseState extends State<AlhaiDesignShowcase> {
  ThemeMode _themeMode = ThemeMode.light;
  bool _isRtl = true; // Arabic-first

  void _toggleTheme() {
    setState(() {
      _themeMode =
          _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    });
  }

  void _toggleDirection() {
    setState(() {
      _isRtl = !_isRtl;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Alhai Design System',
      debugShowCheckedModeBanner: false,
      theme: AlhaiTheme.light,
      darkTheme: AlhaiTheme.dark,
      themeMode: _themeMode,
      builder: (context, child) {
        return Directionality(
          textDirection: _isRtl ? TextDirection.rtl : TextDirection.ltr,
          child: child!,
        );
      },
      home: ShowcasePage(
        onToggleTheme: _toggleTheme,
        onToggleDirection: _toggleDirection,
        isRtl: _isRtl,
        isDarkMode: _themeMode == ThemeMode.dark,
      ),
    );
  }
}

class ShowcasePage extends StatefulWidget {
  final VoidCallback onToggleTheme;
  final VoidCallback onToggleDirection;
  final bool isRtl;
  final bool isDarkMode;

  const ShowcasePage({
    super.key,
    required this.onToggleTheme,
    required this.onToggleDirection,
    required this.isRtl,
    required this.isDarkMode,
  });

  @override
  State<ShowcasePage> createState() => _ShowcasePageState();
}

class _ShowcasePageState extends State<ShowcasePage> {
  bool _isLoading = false;
  final _phoneController = TextEditingController();
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _phoneController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('نظام تصميم الهاي'),
        actions: [
          AlhaiIconButton(
            icon: widget.isRtl
                ? Icons.format_textdirection_l_to_r
                : Icons.format_textdirection_r_to_l,
            onPressed: widget.onToggleDirection,
            tooltip: widget.isRtl ? 'English (LTR)' : 'العربية (RTL)',
          ),
          AlhaiIconButton(
            icon: widget.isDarkMode ? Icons.light_mode : Icons.dark_mode,
            onPressed: widget.onToggleTheme,
            tooltip: widget.isDarkMode ? 'الوضع الفاتح' : 'الوضع الداكن',
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth;
          final columns = AlhaiBreakpoints.isDesktop(width)
              ? 3
              : AlhaiBreakpoints.isTablet(width)
                  ? 2
                  : 1;
          return _buildContent(context, columns: columns);
        },
      ),
    );
  }

  Widget _buildContent(BuildContext context, {required int columns}) {
    return SingleChildScrollView(
      padding: context.responsivePadding(
        mobile: const EdgeInsets.all(AlhaiSpacing.md),
        tablet: const EdgeInsets.all(AlhaiSpacing.lg),
        desktop: const EdgeInsets.all(AlhaiSpacing.xl),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Theme Info
          AlhaiCard(
            child: ResponsiveRowColumn(
              rowOnTablet: true,
              spacing: AlhaiSpacing.md,
              children: [
                _InfoChip(
                  label: 'الوضع',
                  value: widget.isDarkMode ? 'داكن' : 'فاتح',
                  icon: widget.isDarkMode ? Icons.dark_mode : Icons.light_mode,
                ),
                _InfoChip(
                  label: 'الاتجاه',
                  value: widget.isRtl ? 'RTL' : 'LTR',
                  icon: Icons.swap_horiz,
                ),
                _InfoChip(
                  label: 'الشاشة',
                  value: context.isMobile
                      ? 'موبايل'
                      : context.isTablet
                          ? 'تابلت'
                          : 'سطح المكتب',
                  icon: context.isMobile
                      ? Icons.phone_android
                      : context.isTablet
                          ? Icons.tablet
                          : Icons.laptop,
                ),
              ],
            ),
          ),

          const SizedBox(height: AlhaiSpacing.sectionSpacing),

          // Buttons Section
          AlhaiSection(
            title: 'الأزرار',
            subtitle: 'أنواع مختلفة من الأزرار',
            child: Wrap(
              spacing: AlhaiSpacing.sm,
              runSpacing: AlhaiSpacing.sm,
              children: [
                AlhaiButton.filled(
                  label: 'زر أساسي',
                  onPressed: () => AlhaiSnackbar.success(context, 'تم الضغط!'),
                  leadingIcon: Icons.check,
                ),
                AlhaiButton.outlined(
                  label: 'زر ثانوي',
                  onPressed: () => AlhaiSnackbar.info(context, 'زر ثانوي'),
                ),
                AlhaiButton.text(
                  label: 'زر نصي',
                  onPressed: () {},
                ),
                AlhaiButton.filled(
                  label: 'تحميل...',
                  isLoading: _isLoading,
                  onPressed: () async {
                    setState(() => _isLoading = true);
                    await Future.delayed(const Duration(seconds: 2));
                    setState(() => _isLoading = false);
                  },
                ),
                AlhaiButton.filled(
                  label: 'معطل',
                  onPressed: null,
                ),
              ],
            ),
          ),

          const SizedBox(height: AlhaiSpacing.sectionSpacing),

          // Icon Buttons Section
          AlhaiSection(
            title: 'أزرار الأيقونات',
            child: Wrap(
              spacing: AlhaiSpacing.sm,
              runSpacing: AlhaiSpacing.sm,
              children: [
                AlhaiIconButton(
                  icon: Icons.home,
                  onPressed: () {},
                  tooltip: 'الرئيسية',
                ),
                AlhaiIconButton(
                  icon: Icons.favorite,
                  onPressed: () {},
                  color: context.statusColors.error,
                  tooltip: 'المفضلة',
                ),
                AlhaiIconButton(
                  icon: Icons.notifications,
                  onPressed: () {},
                  badgeCount: 5,
                  tooltip: 'الإشعارات',
                ),
                AlhaiIconButton(
                  icon: Icons.shopping_cart,
                  onPressed: () {},
                  badgeCount: 123,
                  tooltip: 'السلة',
                ),
                AlhaiIconButton(
                  icon: Icons.message,
                  onPressed: () {},
                  showBadge: true,
                  tooltip: 'الرسائل',
                ),
              ],
            ),
          ),

          const SizedBox(height: AlhaiSpacing.sectionSpacing),

          // Inputs Section
          AlhaiSection(
            title: 'الحقول النصية',
            child: Column(
              children: [
                AlhaiTextField.phone(
                  controller: _phoneController,
                  labelText: 'رقم الهاتف',
                  hintText: '+966 5XX XXX XXXX',
                  onChanged: (value) =>
                      print('Phone: $value'), // ignore: avoid_print
                ),
                const SizedBox(height: AlhaiSpacing.inputSpacing),
                AlhaiTextField.password(
                  labelText: 'كلمة المرور',
                  hintText: 'أدخل كلمة المرور',
                ),
                const SizedBox(height: AlhaiSpacing.inputSpacing),
                const AlhaiTextField(
                  labelText: 'حقل عادي',
                  hintText: 'أدخل نصًا...',
                  helperText: 'هذا نص مساعد',
                ),
                const SizedBox(height: AlhaiSpacing.inputSpacing),
                const AlhaiTextField(
                  labelText: 'حقل بخطأ',
                  errorText: 'هذا الحقل مطلوب',
                ),
                const SizedBox(height: AlhaiSpacing.inputSpacing),
                AlhaiSearchField(
                  controller: _searchController,
                  hintText: 'ابحث هنا...',
                  onChanged: (value) =>
                      print('Search: $value'), // ignore: avoid_print
                ),
              ],
            ),
          ),

          const SizedBox(height: AlhaiSpacing.sectionSpacing),

          // Badges Section
          AlhaiSection(
            title: 'الشارات',
            child: Wrap(
              spacing: AlhaiSpacing.lg,
              runSpacing: AlhaiSpacing.md,
              children: [
                AlhaiBadge.count(count: 5),
                AlhaiBadge.count(count: 99),
                AlhaiBadge.count(count: 150),
                AlhaiBadge.dot(),
                AlhaiBadge.count(
                  count: 3,
                  child: Container(
                    padding: const EdgeInsets.all(AlhaiSpacing.sm),
                    decoration: BoxDecoration(
                      color: context.colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(AlhaiRadius.sm),
                    ),
                    child: const Icon(Icons.notifications),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: AlhaiSpacing.sectionSpacing),

          // Snackbar Section
          AlhaiSection(
            title: 'الإشعارات',
            child: Wrap(
              spacing: AlhaiSpacing.sm,
              runSpacing: AlhaiSpacing.sm,
              children: [
                AlhaiButton.outlined(
                  label: 'نجاح',
                  leadingIcon: Icons.check,
                  onPressed: () =>
                      AlhaiSnackbar.success(context, 'تمت العملية بنجاح!'),
                ),
                AlhaiButton.outlined(
                  label: 'خطأ',
                  leadingIcon: Icons.error,
                  onPressed: () => AlhaiSnackbar.error(context, 'حدث خطأ!'),
                ),
                AlhaiButton.outlined(
                  label: 'تحذير',
                  leadingIcon: Icons.warning,
                  onPressed: () => AlhaiSnackbar.warning(context, 'انتبه!'),
                ),
                AlhaiButton.outlined(
                  label: 'معلومات',
                  leadingIcon: Icons.info,
                  onPressed: () => AlhaiSnackbar.info(context, 'معلومة مفيدة'),
                ),
              ],
            ),
          ),

          const SizedBox(height: AlhaiSpacing.sectionSpacing),

          // Empty States Section
          AlhaiSection(
            title: 'حالات فارغة',
            child: ResponsiveRowColumn(
              rowOnDesktopOnly: true,
              spacing: AlhaiSpacing.md,
              children: [
                Expanded(
                  child: AlhaiCard(
                    child: AlhaiEmptyState.noOrders(
                        title: 'لا توجد طلبات', compact: true),
                  ),
                ),
                Expanded(
                  child: AlhaiCard(
                    child: AlhaiEmptyState.noResults(
                        title: 'لا توجد نتائج', compact: true),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: AlhaiSpacing.sectionSpacing),

          // Cards Section
          AlhaiSection(
            title: 'البطاقات',
            child: ResponsiveRowColumn(
              rowOnTablet: true,
              spacing: AlhaiSpacing.md,
              children: [
                Expanded(
                  child: AlhaiCard(
                    onTap: () =>
                        AlhaiSnackbar.info(context, 'تم الضغط على البطاقة'),
                    child: const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('بطاقة عادية'),
                        SizedBox(height: AlhaiSpacing.xs),
                        Text('اضغط هنا', style: TextStyle(color: Colors.grey)),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: AlhaiCard.elevated(
                    elevation: 4,
                    child: const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('بطاقة مرتفعة'),
                        SizedBox(height: AlhaiSpacing.xs),
                        Text('مع ظل', style: TextStyle(color: Colors.grey)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: AlhaiSpacing.massive),
        ],
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _InfoChip({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AlhaiSpacing.md,
        vertical: AlhaiSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: context.colorScheme.primaryContainer.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(AlhaiRadius.sm),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: context.colorScheme.primary),
          const SizedBox(width: AlhaiSpacing.xs),
          Text(
            '$label: $value',
            style: context.textTheme.labelMedium?.copyWith(
              color: context.colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }
}
