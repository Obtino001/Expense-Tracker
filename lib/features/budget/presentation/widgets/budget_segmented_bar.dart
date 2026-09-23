import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../../data/models/budget_model.dart';

class BudgetSegmentedBar extends StatelessWidget {
  const BudgetSegmentedBar({required this.budgets, required this.totalBudget, required this.totalSpent, super.key});
  final List<BudgetModel> budgets;
  final double totalBudget;
  final double totalSpent;

  @override
  Widget build(BuildContext context) {
    final denominator = math.max(totalBudget, totalSpent);
    final positive = budgets.where((b) => b.spent > 0).toList();
    final remaining = math.max(0.0, totalBudget - totalSpent);
    return Semantics(
      label: 'Budget allocation',
      value: totalBudget > 0 ? '${(totalSpent / totalBudget * 100).round()} percent spent' : 'No budget set',
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: SizedBox(
          height: 10,
          child: denominator <= 0
              ? ColoredBox(color: Colors.white.withValues(alpha: .15))
              : Row(
                  children: <Widget>[
                    for (final budget in positive)
                      Expanded(
                        flex: math.max(1, (budget.spent / denominator * 10000).round()),
                        child: Container(color: budget.category.color),
                      ),
                    if (remaining > 0)
                      Expanded(
                        flex: math.max(1, (remaining / denominator * 10000).round()),
                        child: ColoredBox(color: Colors.white.withValues(alpha: .15)),
                      ),
                  ],
                ),
        ),
      ),
    );
  }
}
