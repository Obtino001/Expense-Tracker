import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../data/models/budget_model.dart';

/// Full-color category budget card from the reference Picky screenshot:
/// - Saturated category background (Blue, Coral, Emerald, Amber, Violet)
/// - Left squircle with category icon
/// - Category name + optional "MAXED" badge
/// - Spending share + limit share subtitle
/// - High-contrast bold figures ("$380" and "of $380")
class BudgetCategoryCard extends StatelessWidget {
  const BudgetCategoryCard({
    required this.budget,
    required this.totalSpent,
    this.onTap,
    super.key,
  });

  final BudgetModel budget;
  final double totalSpent;
  final VoidCallback? onTap;

  Color _cardColor() {
    final String name = budget.category.name.toLowerCase();
    if (name.contains('housing') || budget.category.id == 'c1') {
      return AppColors.catHousing;
    }
    if (name.contains('food') || budget.category.id == 'c2') {
      return AppColors.catFood;
    }
    if (name.contains('grocer') || budget.category.id == 'c3') {
      return AppColors.catGroceries;
    }
    if (name.contains('shopping') || budget.category.id == 'c4') {
      return AppColors.catShopping;
    }
    if (name.contains('transport') || budget.category.id == 'c5') {
      return AppColors.catTransport;
    }
    return budget.category.color;
  }

  @override
  Widget build(BuildContext context) {
    final Color bgColor = _cardColor();
    final double spendPercent = totalSpent > 0
        ? ((budget.spent / totalSpent) * 100).roundToDouble()
        : 0.0;
    final double limitPercent = budget.limit > 0
        ? ((budget.spent / budget.limit) * 100).roundToDouble()
        : 0.0;
    final bool isMaxed = limitPercent >= 100.0;

    final String spentFormatted =
        '\$${budget.spent.toStringAsFixed(0)}';
    final String limitFormatted =
        'of \$${budget.limit.toStringAsFixed(0)}';

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(22),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: bgColor.withValues(alpha: 0.32),
              blurRadius: 14,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: <Widget>[
            // Translucent rounded square icon container
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.22),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Center(
                child: Icon(
                  budget.category.icon,
                  color: Colors.white,
                  size: 22,
                ),
              ),
            ),
            const SizedBox(width: 14),

            // Middle Column: Title + Badge + Subtitle
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Flexible(
                        child: Text(
                          budget.category.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.plusJakartaSans(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.2,
                          ),
                        ),
                      ),
                      if (isMaxed) ...<Widget>[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.26),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            'MAXED',
                            style: GoogleFonts.plusJakartaSans(
                              color: Colors.white,
                              fontSize: 9,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    '${spendPercent.toInt()}% of spend · ${limitPercent.toInt()}% of limit',
                    style: GoogleFonts.plusJakartaSans(
                      color: Colors.white.withValues(alpha: 0.8),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),

            // Right Column: Spending and Limit
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(
                  spentFormatted,
                  style: GoogleFonts.plusJakartaSans(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.4,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  limitFormatted,
                  style: GoogleFonts.plusJakartaSans(
                    color: Colors.white.withValues(alpha: 0.75),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
