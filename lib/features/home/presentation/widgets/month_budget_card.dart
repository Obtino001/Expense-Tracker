import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/router/route_names.dart';
import '../../../../core/utils/extensions.dart';
import '../../../../core/utils/formatters.dart';

/// Month Budget Card on Home screen matching the screenshot:
/// - [October budget] in Coral + [On track] in green pill badge
/// - [$1,240.00 of $2,000] and [$760 left]
/// - Coral rounded progress bar
class MonthBudgetCard extends StatelessWidget {
  const MonthBudgetCard({
    required this.spent,
    required this.limit,
    this.monthName = 'October',
    super.key,
  });

  final double spent;
  final double limit;
  final String monthName;

  @override
  Widget build(BuildContext context) {
    final bool dark = context.isDark;
    final double remaining = (limit - spent).clamp(0, double.infinity);
    final double progress = limit > 0 ? (spent / limit).clamp(0.0, 1.0) : 0.0;
    final bool onTrack = progress <= 0.85;

    return GestureDetector(
      onTap: () => context.go(RouteNames.budgets),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: dark ? AppColors.darkCard : AppColors.lightSurface,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: dark ? AppColors.darkBorder : AppColors.lightBorder,
            width: 1,
          ),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: Colors.black.withValues(alpha: dark ? 0.2 : 0.04),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // Header row: "October budget" + "On track"
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(
                  '$monthName budget',
                  style: GoogleFonts.plusJakartaSans(
                    color: AppColors.coral,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: onTrack
                        ? (dark
                            ? const Color(0xFF132D1F)
                            : const Color(0xFFE8F7EE))
                        : (dark
                            ? const Color(0xFF331F1C)
                            : const Color(0xFFFFECEB)),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    onTrack ? 'On track' : 'Over limit',
                    style: GoogleFonts.plusJakartaSans(
                      color: onTrack
                          ? const Color(0xFF16A34A)
                          : AppColors.coral,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // Amounts row: "$1,240.00 of $2,000" and "$760 left"
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: <Widget>[
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: <Widget>[
                    Text(
                      Formatters.currency(spent),
                      style: GoogleFonts.plusJakartaSans(
                        color: AppColors.coral,
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'of ${Formatters.currency(limit).split('.').first}',
                      style: GoogleFonts.plusJakartaSans(
                        color: AppColors.lightTextSecondary,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                Text(
                  '${Formatters.currency(remaining).split('.').first} left',
                  style: GoogleFonts.plusJakartaSans(
                    color: dark
                        ? AppColors.darkTextSecondary
                        : AppColors.lightTextSecondary,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Coral progress bar
            LayoutBuilder(
              builder: (BuildContext context, BoxConstraints constraints) {
                final double totalWidth = constraints.maxWidth;
                final double fillWidth = totalWidth * progress;

                return Container(
                  height: 9,
                  width: totalWidth,
                  decoration: BoxDecoration(
                    color: dark
                        ? const Color(0xFF26262E)
                        : const Color(0xFFF1F2F5),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Container(
                      height: 9,
                      width: fillWidth,
                      decoration: BoxDecoration(
                        color: AppColors.coral,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
