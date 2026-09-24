import 'package:flutter/material.dart';
import 'package:budget_app/core/animations/motion.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import '../../../../core/animations/animation_constants.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/utils/extensions.dart';
import '../../../../data/models/category_model.dart';
import '../../../../shared/providers/transaction_provider.dart';
import '../../../../shared/widgets/primary_app_bar.dart';
import '../../../../shared/widgets/pressable.dart';

class CategoriesScreen extends ConsumerStatefulWidget {
  const CategoriesScreen({super.key});

  @override
  ConsumerState<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends ConsumerState<CategoriesScreen> {
  bool _showIncome = false;

  @override
  Widget build(BuildContext context) {
    final AsyncValue<List<CategoryModel>> async = ref.watch(categoriesProvider);

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const PrimaryAppBar(title: 'Categories'),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSizes.lg,
                AppSizes.md,
                AppSizes.lg,
                AppSizes.lg,
              ),
              child: Container(
                padding: const EdgeInsets.all(AppSizes.xs),
                decoration: BoxDecoration(
                  color:
                      context.isDark ? AppColors.darkCard : AppColors.lightCard,
                  borderRadius: BorderRadius.circular(AppSizes.radiusFull),
                ),
                child: Row(
                  children: <Widget>[
                    _SegTab(
                      label: 'Expense',
                      selected: !_showIncome,
                      onTap: () => setState(() => _showIncome = false),
                    ),
                    _SegTab(
                      label: 'Income',
                      selected: _showIncome,
                      onTap: () => setState(() => _showIncome = true),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: async
                  .when(
                    loading: () => const Center(child: LoadingDots()),
                    error: (Object e, _) => Center(child: Text('Error: $e')),
                    data: (List<CategoryModel> all) {
                      final List<CategoryModel> filtered = all
                          .where((CategoryModel c) => c.isIncome == _showIncome)
                          .toList();
                      return AnimationLimiter(
                        child: GridView.builder(
                          padding: const EdgeInsets.fromLTRB(
                            AppSizes.lg,
                            0,
                            AppSizes.lg,
                            AppSizes.huge,
                          ),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            mainAxisSpacing: AppSizes.md,
                            crossAxisSpacing: AppSizes.md,
                            childAspectRatio: 0.95,
                          ),
                          itemCount: filtered.length + 1,
                          itemBuilder: (BuildContext c, int i) {
                            if (i == filtered.length) {
                              return AnimationConfiguration.staggeredGrid(
                                position: i,
                                columnCount: 3,
                                duration: Motion.of(context, Motion.slow),
                                child: ScaleAnimation(
                                  child: FadeInAnimation(
                                    child: _AddCategoryTile(onTap: () {}),
                                  ),
                                ),
                              );
                            }
                            return AnimationConfiguration.staggeredGrid(
                              position: i,
                              columnCount: 3,
                              duration: Motion.of(context, Motion.slow),
                              child: ScaleAnimation(
                                child: FadeInAnimation(
                                  child: _CategoryTile(category: filtered[i]),
                                ),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  )
                  .fxEnter(context, step: 0),
            ),
          ],
        ),
      ),
    );
  }
}

class _SegTab extends StatelessWidget {
  const _SegTab({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Pressable(
        onTap: () { selectionTick(); onTap(); },
        child: AnimatedContainer(
          duration: Motion.of(context, Motion.fast),
          padding: const EdgeInsets.symmetric(vertical: AppSizes.md),
          decoration: BoxDecoration(
            gradient: selected ? AppColors.primaryGradient : null,
            borderRadius: BorderRadius.circular(AppSizes.radiusFull),
          ),
          child: Center(
            child: Text(
              label,
              style: context.tt.labelLarge?.copyWith(
                color: selected ? Colors.white : null),
            ),
          ),
        ),
      ),
    );
  }
}

class _CategoryTile extends StatelessWidget {
  const _CategoryTile({required this.category});
  final CategoryModel category;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.isDark ? AppColors.darkCard : AppColors.lightCard,
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Container(
            height: 52,
            width: 52,
            decoration: BoxDecoration(
              color: category.color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(AppSizes.radiusLg),
            ),
            child: Icon(category.icon, color: category.color, size: 26),
          ),
          const SizedBox(height: AppSizes.sm),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSizes.sm),
            child: Text(
              category.name,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style:
                  context.text.bodySmall?.copyWith(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}

class _AddCategoryTile extends StatelessWidget {
  const _AddCategoryTile({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Pressable(
      onTap: onTap,
      child: DottedBorderBox(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Icon(Icons.add_rounded, color: AppColors.primary, size: 28),
            const SizedBox(height: AppSizes.xs),
            Text(
              'Add',
              style: context.tt.labelLarge?.copyWith(color: AppColors.primary),
            ),
          ],
        ),
      ),
    );
  }
}

/// Simple dashed border container — no extra package needed.
class DottedBorderBox extends StatelessWidget {
  const DottedBorderBox({required this.child, super.key});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.4),
          width: 1.5,
          style: BorderStyle.solid,
        ),
      ),
      child: child,
    );
  }
}
