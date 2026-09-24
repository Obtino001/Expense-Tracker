import 'package:flutter/material.dart';
import '../../../../core/animations/animation_constants.dart';
import '../../../../core/animations/motion.dart';
import '../../../../shared/widgets/pressable.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/utils/extensions.dart';
import '../../../../shared/providers/transaction_provider.dart';

/// Filter pill row — keeps animation smooth via [AnimatedContainer].
class FilterChips extends StatelessWidget {
  const FilterChips({
    required this.current,
    required this.onSelected,
    super.key,
  });

  final TxFilter current;
  final ValueChanged<TxFilter> onSelected;

  static const Map<TxFilter, String> _labels = <TxFilter, String>{
    TxFilter.all: 'All',
    TxFilter.income: 'Income',
    TxFilter.expense: 'Expense',
  };

  @override
  Widget build(BuildContext context) {
    return Row(
      children: TxFilter.values.map((TxFilter f) {
        final bool selected = f == current;
        return Padding(
          padding: const EdgeInsets.only(right: AppSizes.sm),
          child: Pressable(
            onTap: () {
              selectionTick();
              onSelected(f);
            },
            child: AnimatedContainer(
              duration: Motion.of(context, Motion.fast),
              curve: Motion.out,
              padding: const EdgeInsets.symmetric(
                horizontal: AppSizes.lg,
                vertical: AppSizes.sm,
              ),
              decoration: BoxDecoration(
                gradient: selected ? AppColors.primaryGradient : null,
                color: selected
                    ? null
                    : (context.isDark
                        ? AppColors.darkCard
                        : AppColors.lightCard),
                borderRadius: BorderRadius.circular(AppSizes.radiusFull),
              ),
              child: Text(
                _labels[f]!,
                style: context.tt.labelLarge?.copyWith(
                  color: selected ? Colors.white : null),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
