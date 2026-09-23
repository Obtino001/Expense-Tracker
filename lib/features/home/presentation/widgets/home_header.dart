import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/router/route_names.dart';
import '../../../../core/utils/extensions.dart';

/// Top header on the Home screen matching the reference Picky design:
/// [Coral Logo + "Picky"] on the left, [Bell Icon + MR Avatar] on the right.
class HomeHeader extends ConsumerWidget {
  const HomeHeader({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bool dark = context.isDark;

    return Row(
      children: <Widget>[
        // Picky Brand Logo
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: AppColors.coral,
            borderRadius: BorderRadius.circular(10),
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: AppColors.coral.withValues(alpha: 0.35),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: const Center(
            child: Icon(
              Icons.check_rounded,
              color: Colors.white,
              size: 22,
            ),
          ),
        ),
        const SizedBox(width: AppSizes.sm + 2),
        Text(
          'Picky',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.6,
            color: dark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
          ),
        ),
        const Spacer(),

        // Notification Bell Icon Bubble
        GestureDetector(
          onTap: () {
            HapticFeedback.lightImpact();
            context.push(RouteNames.notifications);
          },
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: dark ? AppColors.darkCard : AppColors.lightSurface,
              shape: BoxShape.circle,
              border: Border.all(
                color: dark ? AppColors.darkBorder : AppColors.lightBorder,
                width: 1,
              ),
              boxShadow: <BoxShadow>[
                BoxShadow(
                  color: Colors.black.withValues(alpha: dark ? 0.2 : 0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Center(
              child: Icon(
                Icons.notifications_none_rounded,
                size: 20,
                color: dark
                    ? AppColors.darkTextPrimary
                    : AppColors.lightTextPrimary,
              ),
            ),
          ),
        ),
        const SizedBox(width: AppSizes.sm + 2),

        // User Avatar Circle ("MR")
        GestureDetector(
          onTap: () {
            HapticFeedback.lightImpact();
            context.push(RouteNames.settings);
          },
          child: Container(
            width: 40,
            height: 40,
            decoration: const BoxDecoration(
              color: Color(0xFFF4D5C8), // Peach nude background from reference
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                'MR',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF3E2319),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
