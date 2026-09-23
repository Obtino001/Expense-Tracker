import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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
          child: GestureDetector(
            onTap: () {
              HapticFeedback.selectionClick();
              onSelected(f);
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOutCubic,
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
                style: TextStyle(
                  color: selected ? Colors.white : null,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
