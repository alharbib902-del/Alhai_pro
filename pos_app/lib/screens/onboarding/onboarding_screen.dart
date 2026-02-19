/// شاشة الترحيب - Onboarding Screen
///
/// تعرض للمستخدم الجديد:
/// - ميزات التطبيق الرئيسية
/// - كيفية البدء
/// - 4 slides مع animations
library;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_sizes.dart';
import '../../core/theme/app_typography.dart';
import '../../data/local/app_database.dart';
import '../../di/injection.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../providers/products_providers.dart';
import '../../providers/settings_db_providers.dart';

/// مفتاح تخزين حالة عرض Onboarding
const String _kOnboardingSeenKey = 'onboarding_seen';
const String _kOnboardingDbKey = 'onboarding_completed';

/// التحقق من عرض Onboarding سابقاً
Future<bool> hasSeenOnboarding() async {
  // تحقق من قاعدة البيانات أولاً
  try {
    final db = getIt<AppDatabase>();
    final completed = await getSettingValue(db, kDemoStoreId, _kOnboardingDbKey);
    if (completed == 'true') return true;
  } catch (e) {
    if (kDebugMode) {
      debugPrint('خطأ في قراءة حالة Onboarding من DB: $e');
    }
  }
  // احتياطي: SharedPreferences
  final prefs = await SharedPreferences.getInstance();
  return prefs.getBool(_kOnboardingSeenKey) ?? false;
}

/// تعيين Onboarding كمشاهد
Future<void> setOnboardingSeen() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setBool(_kOnboardingSeenKey, true);
}

/// بيانات صفحة Onboarding
class OnboardingPage {
  final IconData icon;
  final String title;
  final String description;
  final Color color;

  const OnboardingPage({
    required this.icon,
    required this.title,
    required this.description,
    required this.color,
  });
}

/// صفحات Onboarding - تُبنى ديناميكياً باستخدام l10n
List<OnboardingPage> _buildPages(AppLocalizations l10n) => [
  OnboardingPage(
    icon: Icons.point_of_sale_rounded,
    title: l10n.onboardingTitle1,
    description: l10n.onboardingDesc1,
    color: AppColors.primary,
  ),
  OnboardingPage(
    icon: Icons.wifi_off_rounded,
    title: l10n.onboardingTitle2,
    description: l10n.onboardingDesc2,
    color: AppColors.info,
  ),
  OnboardingPage(
    icon: Icons.inventory_2_rounded,
    title: l10n.onboardingTitle3,
    description: l10n.onboardingDesc3,
    color: AppColors.warning,
  ),
  OnboardingPage(
    icon: Icons.analytics_rounded,
    title: l10n.onboardingTitle4,
    description: l10n.onboardingDesc4,
    color: AppColors.success,
  ),
];

/// شاشة الترحيب
class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _checkIfAlreadyCompleted();
  }

  /// التحقق من إتمام Onboarding مسبقاً - إذا تم الإكمال يتم التخطي مباشرة
  Future<void> _checkIfAlreadyCompleted() async {
    try {
      final db = getIt<AppDatabase>();
      final storeId = ref.read(currentStoreIdProvider) ?? 'default';
      final completed = await getSettingValue(db, storeId, _kOnboardingDbKey);
      if (completed == 'true' && mounted) {
        context.go('/login');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('خطأ في التحقق من حالة Onboarding: $e');
      }
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int page) {
    setState(() {
      _currentPage = page;
    });
  }

  bool _isCompleting = false;

  void _nextPage(int pageCount) {
    if (_currentPage < pageCount - 1) {
      _pageController.nextPage(
        duration: AppDurations.normal,
        curve: AppCurves.defaultCurve,
      );
    } else {
      _completeOnboarding();
    }
  }

  void _skipOnboarding() {
    _completeOnboarding();
  }

  Future<void> _completeOnboarding() async {
    if (_isCompleting) return;
    setState(() => _isCompleting = true);

    // حفظ في SharedPreferences (احتياطي)
    await setOnboardingSeen();

    // حفظ في قاعدة البيانات مع المزامنة
    try {
      final db = getIt<AppDatabase>();
      final storeId = ref.read(currentStoreIdProvider) ?? 'default';
      await saveSettingWithSync(
        db: db,
        storeId: storeId,
        key: _kOnboardingDbKey,
        value: 'true',
        ref: ref,
      );
    } catch (e) {
      if (kDebugMode) {
        debugPrint('\u062E\u0637\u0623 \u0641\u064A \u062D\u0641\u0638 \u062D\u0627\u0644\u0629 Onboarding \u0641\u064A DB: $e');
      }
    }

    if (mounted) {
      setState(() => _isCompleting = false);
      context.go('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final pages = _buildPages(l10n);
    final isLastPage = _currentPage == pages.length - 1;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Skip button
            Align(
              alignment: AlignmentDirectional.topEnd,
              child: Padding(
                padding: const EdgeInsets.all(AppSizes.lg),
                child: TextButton(
                  onPressed: _skipOnboarding,
                  child: Text(
                    l10n.skip,
                    style: AppTypography.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ),
            ),

            // المحتوى
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: _onPageChanged,
                itemCount: pages.length,
                itemBuilder: (context, index) {
                  return _OnboardingPageWidget(page: pages[index]);
                },
              ),
            ),

            // مؤشر الصفحات
            Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSizes.xl),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  pages.length,
                  (index) => _PageIndicator(
                    isActive: index == _currentPage,
                    color: pages[index].color,
                  ),
                ),
              ),
            ),

            // أزرار التنقل
            Padding(
              padding: const EdgeInsets.all(AppSizes.xl),
              child: Row(
                children: [
                  // زر السابق
                  if (_currentPage > 0)
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          _pageController.previousPage(
                            duration: AppDurations.normal,
                            curve: AppCurves.defaultCurve,
                          );
                        },
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            vertical: AppSizes.md,
                          ),
                        ),
                        child: Text(l10n.previous),
                      ),
                    )
                  else
                    const Spacer(),

                  const SizedBox(width: AppSizes.md),

                  // زر التالي / البدء
                  Expanded(
                    flex: 2,
                    child: FilledButton(
                      onPressed: _isCompleting ? null : () => _nextPage(pages.length),
                      style: FilledButton.styleFrom(
                        backgroundColor: pages[_currentPage].color,
                        padding: const EdgeInsets.symmetric(
                          vertical: AppSizes.md,
                        ),
                      ),
                      child: _isCompleting
                          ? SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Theme.of(context).colorScheme.surface,
                              ),
                            )
                          : Text(
                              isLastPage ? l10n.startNow : l10n.next,
                              style: AppTypography.buttonMedium.copyWith(
                                color: Theme.of(context).colorScheme.surface,
                              ),
                            ),
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
}

/// Widget لصفحة Onboarding
class _OnboardingPageWidget extends StatelessWidget {
  final OnboardingPage page;

  const _OnboardingPageWidget({required this.page});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.xxxl),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // الأيقونة
          Container(
            width: 160,
            height: 160,
            decoration: BoxDecoration(
              color: page.color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              page.icon,
              size: 80,
              color: page.color,
            ),
          ),

          const SizedBox(height: AppSizes.xxxl),

          // العنوان
          Text(
            page.title,
            style: AppTypography.headlineLarge.copyWith(
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: AppSizes.lg),

          // الوصف
          Text(
            page.description,
            style: AppTypography.bodyLarge.copyWith(
              color: AppColors.textSecondary,
              height: 1.6,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

/// مؤشر الصفحة
class _PageIndicator extends StatelessWidget {
  final bool isActive;
  final Color color;

  const _PageIndicator({
    required this.isActive,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: AppDurations.fast,
      margin: const EdgeInsets.symmetric(horizontal: AppSizes.xs),
      width: isActive ? 32 : 8,
      height: 8,
      decoration: BoxDecoration(
        color: isActive ? color : AppColors.border,
        borderRadius: BorderRadius.circular(AppSizes.radiusFull),
      ),
    );
  }
}
