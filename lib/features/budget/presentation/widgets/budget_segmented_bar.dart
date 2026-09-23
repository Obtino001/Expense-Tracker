import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/extensions.dart';
import '../../../../data/models/budget_model.dart';

/// Segmented multi-colored progress bar matching the Budget screen screenshot:
/// Proportional capsules for each category:
/// Blue, Coral, Emerald, Amber, Violet, Pink, and remaining Gray.
class BudgetSegmentedBar extends StatelessWidget {
  const BudgetSegmentedBar({
    required this.budgets,
    required this.totalBudget,
    required this.totalSpent,
    super.key,
  });

  final List<BudgetModel> budgets;
  final double totalBudget;
  final double totalSpent;

  Color _categoryColor(BudgetModel b) {
    final String name = b.category.name.toLowerCase();
    if (name.contains('housing') || b.category.id == 'c1') {
      return AppColors.catHousing;
    }
    if (name.contains('food') || b.category.id == 'c2') {
      return AppColors.catFood;
    }
    if (name.contains('grocer') || b.category.id == 'c3') {
      return AppColors.catGroceries;
    }
    if (name.contains('shopping') || b.category.id == 'c4') {
      return AppColors.catShopping;
    }
    if (name.contains('transport') || b.category.id == 'c5') {
      return AppColors.catTransport;
    }
    return b.category.color;
  }

  @override
  Widget build(BuildContext context) {
    final bool dark = context.isDark;
    final double safeTotal = totalBudget > 0 ? totalBudget : 2000.0;
    final double remaining = (safeTotal - totalSpent).clamp(0.0, safeTotal);

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final double barWidth = constraints.maxWidth;
        final int segmentsCount = budgets.length + (remaining > 0 ? 1 : 0);
        const double gap = 4.0;
        final double availableWidth =
            barWidth - (segmentsCount > 1 ? (segmentsCount - 1) * gap : 0.0);

        final List<Widget> segments = <Widget>[];

        for (final BudgetModel b in budgets) {
          if (b.spent <= 0) continue;
          final double fraction = (b.spent / safeTotal).clamp(0.02, 1.0);
          final double segWidth = (availableWidth * fraction).clamp(6.0, availableWidth);

          segments.add(
            Container(
              width: segWidth,
              height: 10,
              decoration: BoxDecoration(
                color: _categoryColor(b),
                borderRadius: BorderRadius.circular(5),
              ),
            ),
          );
        }

        // Remaining budget segment (light gray / subtle surface)
        if (remaining > 0) {
          final double remainingFraction = (remaining / safeTotal).clamp(0.04, 1.0);
          final double remainingWidth =
              (availableWidth * remainingFraction).clamp(10.0, availableWidth);

          segments.add(
            Container(
              width: remainingWidth,
              height: 10,
              decoration: BoxDecoration(
                color: dark
                    ? const Color(0xFF26262E)
                    : const Color(0xFFE8E9EC),
                borderRadius: BorderRadius.circular(5),
              ),
            ),
          );
        }

        return SizedBox(
          width: barWidth,
          height: 10,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              for (int i = 0; i < segments.length; i++) ...<Widget>[
                if (i > 0) const SizedBox(width: gap),
                segments[i],
              ],
            ],
          ),
        );
      },
    );
  }
}
