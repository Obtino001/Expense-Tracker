import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../data/models/budget_model.dart';

class BudgetCategoryCard extends StatelessWidget {
  const BudgetCategoryCard({
    required this.budget,
    required this.totalSpent,
    this.onTap,
    this.onDelete,
    super.key,
  });

  final BudgetModel budget;
  final double totalSpent;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dark = theme.brightness == Brightness.dark;
    final color = budget.isOver ? AppColors.danger : budget.category.color;
    final status = budget.isOver
        ? '${Formatters.currency(budget.spent - budget.limit)} over limit'
        : '${Formatters.currency(budget.remaining)} left';
    return Material(
      color: dark ? AppColors.darkCard : AppColors.lightCard,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: BorderSide(color: dark ? AppColors.darkBorder : AppColors.lightBorder),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: <Widget>[
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: budget.category.color.withValues(alpha: dark ? .18 : .10),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(budget.category.icon, color: budget.category.color, size: 22),
                  ),
                  const SizedBox(width: 14),
                  Expanded(child: Text(budget.category.name, style: theme.textTheme.titleMedium)),
                  PopupMenuButton<String>(
                    tooltip: '${budget.category.name} options',
                    onSelected: (value) => value == 'edit' ? onTap?.call() : onDelete?.call(),
                    itemBuilder: (_) => const <PopupMenuEntry<String>>[
                      PopupMenuItem(value: 'edit', child: Text('Edit budget')),
                      PopupMenuItem(value: 'delete', child: Text('Remove budget')),
                    ],
                    icon: const Icon(Icons.more_horiz_rounded),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Wrap(
                spacing: 8,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: <Widget>[
                  Text(Formatters.currency(budget.spent), style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
                  Text('of ${Formatters.currency(budget.limit)}', style: theme.textTheme.bodySmall),
                ],
              ),
              const SizedBox(height: 12),
              Semantics(
                label: '${budget.category.name} budget',
                value: '${(budget.progress * 100).round()} percent used, $status',
                child: TweenAnimationBuilder<double>(
                  tween: Tween<double>(begin: 0, end: budget.progress.clamp(0, 1)),
                  duration: MediaQuery.disableAnimationsOf(context) ? Duration.zero : const Duration(milliseconds: 650),
                  curve: Curves.easeOutCubic,
                  builder: (_, value, __) => LinearProgressIndicator(
                    value: value,
                    minHeight: 6,
                    borderRadius: BorderRadius.circular(4),
                    color: color,
                    backgroundColor: color.withValues(alpha: .12),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Text(status, style: theme.textTheme.bodySmall?.copyWith(color: budget.isOver ? AppColors.danger : null)),
            ],
          ),
        ),
      ),
    );
  }
}
