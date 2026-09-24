import 'package:flutter/material.dart';
import 'package:budget_app/core/animations/motion.dart';

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
    return SingleChildScrollView(
      child: Padding(
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
            ).fxPop(context, from: .85,
                key: ValueKey('${data.title}_illustration')).fxFloat(context),
          ),
          const SizedBox(height: AppSizes.huge),
          Text(
            data.title,
            style: context.text.displayMedium,
          ).fxEnter(context, step: 3, rise: 10,
              key: ValueKey('${data.title}_title')),
          const SizedBox(height: AppSizes.md),
          Text(
            data.subtitle,
            style: context.text.bodyLarge?.copyWith(
              color: context.isDark
                  ? AppColors.darkTextSecondary
                  : AppColors.lightTextSecondary,
              height: 1.5,
            ),
          ).fxEnter(context, step: 5, rise: 0,
              key: ValueKey('${data.title}_body')),
        ],
      ),
      ),
    );
  }
}
