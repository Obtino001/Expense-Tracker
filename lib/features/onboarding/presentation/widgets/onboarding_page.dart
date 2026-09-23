import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/utils/extensions.dart';

class OnboardingPageData {
  const OnboardingPageData({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.gradient,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Gradient gradient;
}

class OnboardingPage extends StatelessWidget {
  const OnboardingPage({required this.data, super.key});

  final OnboardingPageData data;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.xxl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          // Floating illustration
          Center(
            child: Container(
              height: 220,
              width: 220,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: data.gradient,
                boxShadow: <BoxShadow>[
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.4),
                    blurRadius: 40,
                    spreadRadius: 4,
                  ),
                ],
              ),
              child: Icon(data.icon, size: 96, color: Colors.white),
            )
                .animate()
                .scale(
                  begin: const Offset(0.6, 0.6),
                  end: const Offset(1, 1),
                  curve: Curves.elasticOut,
                  duration: 900.ms,
                )
                .fadeIn(duration: 400.ms),
          ),
          const SizedBox(height: AppSizes.huge),
          Text(
            data.title,
            style: context.text.displayMedium,
          ).animate().fadeIn(delay: 200.ms, duration: 500.ms).slideY(
                begin: 0.2,
                end: 0,
                curve: Curves.easeOutCubic,
                duration: 500.ms,
              ),
          const SizedBox(height: AppSizes.md),
          Text(
            data.subtitle,
            style: context.text.bodyLarge?.copyWith(
              color: context.isDark
                  ? AppColors.darkTextSecondary
                  : AppColors.lightTextSecondary,
              height: 1.5,
            ),
          ).animate().fadeIn(delay: 350.ms, duration: 500.ms).slideY(
                begin: 0.2,
                end: 0,
                curve: Curves.easeOutCubic,
                duration: 500.ms,
              ),
        ],
      ),
    );
  }
}
