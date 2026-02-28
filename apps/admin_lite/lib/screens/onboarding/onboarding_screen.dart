/// Lite Onboarding Screen - Admin Lite App
///
/// Simplified onboarding for admin lite users:
/// - Welcome to Quick Manager
/// - Monitor your business on the go
/// - Approve requests & manage teams
///
/// After completion, saves `lite_onboarding_complete` flag to SharedPreferences
/// and navigates to login screen.
///
/// Uses the same pattern as cashier onboarding (M57).
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:alhai_shared_ui/alhai_shared_ui.dart';
import 'package:alhai_l10n/alhai_l10n.dart';

/// SharedPreferences key for lite onboarding completion flag
const String kLiteOnboardingSeenKey = 'lite_onboarding_complete';

/// Check if lite onboarding has been completed
Future<bool> hasSeenLiteOnboarding() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getBool(kLiteOnboardingSeenKey) ?? false;
}

/// Mark lite onboarding as completed
Future<void> setLiteOnboardingSeen() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setBool(kLiteOnboardingSeenKey, true);
}

/// Provider that tracks whether lite onboarding has been seen.
///
/// Initialized to `null` (unknown), loaded from SharedPreferences in main(),
/// then updated to `true` when onboarding is completed.
/// The router guard uses this to redirect first-time users to onboarding.
final liteOnboardingSeenProvider = StateProvider<bool?>((ref) => null);

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

/// Build lite-specific onboarding pages
List<_OnboardingPage> _buildLitePages(AppLocalizations l10n) => [
      _OnboardingPage(
        icon: Icons.speed_rounded,
        title: l10n.welcomeTitle,
        description: l10n.onboardingDesc1,
        color: AppColors.primary,
      ),
      _OnboardingPage(
        icon: Icons.analytics_rounded,
        title: l10n.onboardingTitle4,
        description: l10n.onboardingDesc4,
        color: AppColors.info,
      ),
      _OnboardingPage(
        icon: Icons.groups_rounded,
        title: l10n.onboardingTitle3,
        description: l10n.onboardingDesc3,
        color: AppColors.success,
      ),
    ];

/// Admin Lite Onboarding Screen
class LiteOnboardingScreen extends ConsumerStatefulWidget {
  const LiteOnboardingScreen({super.key});

  @override
  ConsumerState<LiteOnboardingScreen> createState() =>
      _LiteOnboardingScreenState();
}

class _LiteOnboardingScreenState extends ConsumerState<LiteOnboardingScreen> {
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

    await setLiteOnboardingSeen();

    if (mounted) {
      // Update the provider so the router guard knows onboarding is done
      ref.read(liteOnboardingSeenProvider.notifier).state = true;
      setState(() => _isCompleting = false);
      context.go(AppRoutes.login);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final pages = _buildLitePages(l10n);
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

/// Page indicator dot
class _PageIndicator extends StatelessWidget {
  final bool isActive;
  final Color color;

  const _PageIndicator({required this.isActive, required this.color});

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
