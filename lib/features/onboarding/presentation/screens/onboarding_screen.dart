import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/router/route_names.dart';
import '../../../../core/utils/extensions.dart';
import '../../../../shared/widgets/gradient_background.dart';
import '../../../../shared/widgets/gradient_button.dart';
import '../widgets/onboarding_page.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();
  int _page = 0;

  static const List<OnboardingPageData> _pages = <OnboardingPageData>[
    OnboardingPageData(
      title: AppStrings.onboarding1Title,
      subtitle: AppStrings.onboarding1Subtitle,
      icon: Icons.account_balance_wallet_rounded,
      gradient: AppColors.primaryGradient,
    ),
    OnboardingPageData(
      title: AppStrings.onboarding2Title,
      subtitle: AppStrings.onboarding2Subtitle,
      icon: Icons.savings_rounded,
      gradient: AppColors.successGradient,
    ),
    OnboardingPageData(
      title: AppStrings.onboarding3Title,
      subtitle: AppStrings.onboarding3Subtitle,
      icon: Icons.auto_graph_rounded,
      gradient: AppColors.onboardingGradient,
    ),
  ];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _next() {
    if (_page < _pages.length - 1) {
      _controller.nextPage(
        duration: const Duration(milliseconds: 450),
        curve: Curves.easeInOutCubic,
      );
    } else {
      context.go(RouteNames.login);
    }
  }

  void _skip() => context.go(RouteNames.login);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GradientBackground(
        child: SafeArea(
          child: Column(
            children: <Widget>[
              // Top bar — skip button
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSizes.xl,
                  AppSizes.md,
                  AppSizes.xl,
                  0,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                    AnimatedOpacity(
                      duration: const Duration(milliseconds: 200),
                      opacity: _page == _pages.length - 1 ? 0 : 1,
                      child: TextButton(
                        onPressed: _skip,
                        child: Text(
                          AppStrings.skip,
                          style: context.text.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Pages
              Expanded(
                child: PageView.builder(
                  controller: _controller,
                  itemCount: _pages.length,
                  onPageChanged: (int i) => setState(() => _page = i),
                  itemBuilder: (BuildContext c, int i) =>
                      OnboardingPage(data: _pages[i]),
                ),
              ),

              // Page indicator
              SmoothPageIndicator(
                controller: _controller,
                count: _pages.length,
                effect: ExpandingDotsEffect(
                  activeDotColor: AppColors.primary,
                  dotColor: context.isDark
                      ? AppColors.darkDivider
                      : AppColors.lightDivider,
                  dotHeight: 8,
                  dotWidth: 8,
                  expansionFactor: 3,
                  spacing: 6,
                ),
              ),
              const SizedBox(height: AppSizes.xxl),

              // CTA
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSizes.xxl,
                  0,
                  AppSizes.xxl,
                  AppSizes.xxl,
                ),
                child: GradientButton(
                  label: _page == _pages.length - 1
                      ? AppStrings.getStarted
                      : AppStrings.next,
                  onPressed: _next,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
