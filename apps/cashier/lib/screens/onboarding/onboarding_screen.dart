/// Onboarding Screen - Cashier App
///
/// Shows first-time cashier users:
/// - Key POS features
/// - How to get started
/// - 4 slides with smooth transitions
///
/// After completion, saves `onboarding_seen` flag to SharedPreferences
/// and navigates to the login screen.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:alhai_shared_ui/alhai_shared_ui.dart';
import 'package:alhai_l10n/alhai_l10n.dart';

/// SharedPreferences key for onboarding completion flag
const String kOnboardingSeenKey = 'onboarding_seen';

/// Check if onboarding has been completed
Future<bool> hasSeenOnboarding() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getBool(kOnboardingSeenKey) ?? false;
}

/// Mark onboarding as completed
Future<void> setOnboardingSeen() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setBool(kOnboardingSeenKey, true);
}

/// Onboarding page data
class _OnboardingPage {
  final IconData icon;
  final String title;
  final String description;
  final Color color;

  const _OnboardingPage({
    required this.icon,
    required this.title,
    required this.description,
    required this.color,
  });
}

/// Build onboarding pages using l10n
List<_OnboardingPage> _buildPages(AppLocalizations l10n) => [
      _OnboardingPage(
        icon: Icons.point_of_sale_rounded,
        title: l10n.onboardingTitle1,
        description: l10n.onboardingDesc1,
        color: AppColors.primary,
      ),
      _OnboardingPage(
        icon: Icons.wifi_off_rounded,
        title: l10n.onboardingTitle2,
        description: l10n.onboardingDesc2,
        color: AppColors.info,
      ),
      _OnboardingPage(
        icon: Icons.inventory_2_rounded,
        title: l10n.onboardingTitle3,
        description: l10n.onboardingDesc3,
        color: AppColors.warning,
      ),
      _OnboardingPage(
        icon: Icons.analytics_rounded,
        title: l10n.onboardingTitle4,
        description: l10n.onboardingDesc4,
        color: AppColors.success,
      ),
    ];

/// Cashier Onboarding Screen
class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  bool _isCompleting = false;

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

    await setOnboardingSeen();

    if (mounted) {
      // Update the provider so the router guard knows onboarding is done
      ref.read(onboardingSeenProvider.notifier).state = true;
      setState(() => _isCompleting = false);
      context.go(AppRoutes.login);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final pages = _buildPages(l10n);
    final isLastPage = _currentPage == pages.length - 1;
    final isDark = Theme.of(context).brightness == Brightness.dark;

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
                      color: AppColors.getTextSecondary(isDark),
                    ),
                  ),
                ),
              ),
            ),

            // Content
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

            // Page indicators
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

            // Privacy policy link
            TextButton(
              onPressed: () => context.push(AppRoutes.settingsPrivacy),
              child: Text(
                'سياسة الخصوصية | Privacy Policy',
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.getTextSecondary(isDark),
                  decoration: TextDecoration.underline,
                ),
              ),
            ),

            // Navigation buttons
            Padding(
              padding: const EdgeInsets.all(AppSizes.xl),
              child: Row(
                children: [
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
                          padding:
                              const EdgeInsets.symmetric(vertical: AppSizes.md),
                        ),
                        child: Text(l10n.previous),
                      ),
                    )
                  else
                    const Spacer(),
                  const SizedBox(width: AppSizes.md),
                  Expanded(
                    flex: 2,
                    child: FilledButton(
                      onPressed:
                          _isCompleting ? null : () => _nextPage(pages.length),
                      style: FilledButton.styleFrom(
                        backgroundColor: pages[_currentPage].color,
                        padding:
                            const EdgeInsets.symmetric(vertical: AppSizes.md),
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

/// Widget for a single Onboarding page
class _OnboardingPageWidget extends StatelessWidget {
  final _OnboardingPage page;

  const _OnboardingPageWidget({required this.page});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.xxxl),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 160,
            height: 160,
            decoration: BoxDecoration(
              color: page.color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(page.icon, size: 80, color: page.color),
          ),
          const SizedBox(height: AppSizes.xxxl),
          Text(
            page.title,
            style: AppTypography.headlineLarge
                .copyWith(fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSizes.lg),
          Text(
            page.description,
            style: AppTypography.bodyLarge.copyWith(
              color: AppColors.getTextSecondary(isDark),
              height: 1.6,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

/// Page indicator dot
class _PageIndicator extends StatelessWidget {
  final bool isActive;
  final Color color;

  const _PageIndicator({required this.isActive, required this.color});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AnimatedContainer(
      duration: AppDurations.fast,
      margin: const EdgeInsets.symmetric(horizontal: AppSizes.xs),
      width: isActive ? 32 : 8,
      height: 8,
      decoration: BoxDecoration(
        color: isActive ? color : AppColors.getBorder(isDark),
        borderRadius: BorderRadius.circular(AppSizes.radiusFull),
      ),
    );
  }
}

/// Provider that tracks whether onboarding has been seen.
///
/// Initialized to `null` (unknown), loaded from SharedPreferences in main(),
/// then updated to `true` when onboarding is completed.
/// The router guard uses this to redirect first-time users to onboarding.
final onboardingSeenProvider = StateProvider<bool?>((ref) => null);
