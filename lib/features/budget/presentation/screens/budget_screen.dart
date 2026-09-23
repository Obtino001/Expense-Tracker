import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/utils/extensions.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../data/models/budget_model.dart';
import '../../../../shared/providers/theme_provider.dart';
import '../../../../shared/providers/transaction_provider.dart';
import '../../../../shared/widgets/skeleton_loader.dart';
import '../widgets/budget_card.dart';
import '../widgets/budget_segmented_bar.dart';

/// Screen 2: Budget Screen matching the left screen in the reference screenshot:
/// - "Budget" title with "October ˇ" selector + theme toggle icon
/// - "LEFT TO SPEND" header + huge "$760.00" + "$1,240 of $2,000 spent"
/// - Multi-color segmented capsule progress bar
/// - "Where it went" with "6 categories"
/// - Saturated full-color category cards (Blue Housing, Coral Food, Emerald Groceries, Amber Shopping, Violet Transport)
class BudgetScreen extends ConsumerWidget {
  const BudgetScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<List<BudgetModel>> budgetsAsync =
        ref.watch(budgetsProvider);
    final ({double balance, double expense, double income}) totals =
        ref.watch(totalsProvider);
    final bool dark = context.isDark;

    return Scaffold(
      backgroundColor: dark ? AppColors.darkBg : AppColors.lightBg,
      body: SafeArea(
        bottom: false,
        child: budgetsAsync.when(
          loading: () => ListView.builder(
            padding: const EdgeInsets.all(AppSizes.lg),
            itemCount: 4,
            itemBuilder: (_, __) => const Padding(
              padding: EdgeInsets.symmetric(vertical: AppSizes.sm),
              child: SkeletonBox(height: 80, radius: AppSizes.radiusXl),
            ),
          ),
          error: (Object e, _) => Center(
            child: Text(
              'Failed to load budget data',
              style: context.text.bodyMedium,
            ),
          ),
          data: (List<BudgetModel> budgets) {
            final double totalLimit = budgets.fold<double>(
              0,
              (double acc, BudgetModel b) => acc + b.limit,
            );
            final double computedLimit = totalLimit > 0 ? totalLimit : 2000.0;
            final double totalSpent = totals.expense > 0 ? totals.expense : 1240.0;
            final double leftToSpend =
                (computedLimit - totalSpent).clamp(0.0, computedLimit);

            final String leftFormatted = Formatters.currency(leftToSpend);
            final List<String> leftParts = leftFormatted.split('.');
            final String leftDollars =
                leftParts.isNotEmpty ? leftParts[0] : leftFormatted;
            final String leftCents =
                leftParts.length > 1 ? '.${leftParts[1]}' : '.00';

            final String spentDollars =
                '\$${totalSpent.toStringAsFixed(0)}';
            final String limitDollars =
                '\$${computedLimit.toStringAsFixed(0)}';

            return ListView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 110),
              children: <Widget>[
                // Header row: "Budget" + [October ˇ] + Theme Toggle
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text(
                      'Budget',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 30,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.8,
                        color: dark
                            ? AppColors.darkTextPrimary
                            : AppColors.lightTextPrimary,
                      ),
                    ),
                    Row(
                      children: <Widget>[
                        // Month Dropdown pill
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 7,
                          ),
                          decoration: BoxDecoration(
                            color: dark
                                ? AppColors.darkCard
                                : AppColors.lightSurface,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: dark
                                  ? AppColors.darkBorder
                                  : AppColors.lightBorder,
                              width: 1,
                            ),
                            boxShadow: <BoxShadow>[
                              BoxShadow(
                                color: Colors.black
                                    .withValues(alpha: dark ? 0.2 : 0.03),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              Text(
                                'October',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: dark
                                      ? AppColors.darkTextPrimary
                                      : AppColors.lightTextPrimary,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Icon(
                                Icons.keyboard_arrow_down_rounded,
                                size: 16,
                                color: dark
                                    ? AppColors.darkTextSecondary
                                    : AppColors.lightTextSecondary,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 10),

                        // Sun/Moon theme toggle circle
                        GestureDetector(
                          onTap: () {
                            HapticFeedback.lightImpact();
                            ref.read(themeModeProvider.notifier).toggle();
                          },
                          child: Container(
                            width: 38,
                            height: 38,
                            decoration: BoxDecoration(
                              color: dark
                                  ? AppColors.darkCard
                                  : AppColors.lightSurface,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: dark
                                    ? AppColors.darkBorder
                                    : AppColors.lightBorder,
                                width: 1,
                              ),
                            ),
                            child: Center(
                              child: Icon(
                                dark
                                    ? Icons.nightlight_round
                                    : Icons.wb_sunny_outlined,
                                size: 18,
                                color: dark
                                    ? AppColors.darkTextPrimary
                                    : AppColors.lightTextPrimary,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ).animate().fadeIn(duration: 250.ms),
                const SizedBox(height: 24),

                // "LEFT TO SPEND" label
                Text(
                  'L E F T   T O   S P E N D',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.2,
                    color: AppColors.lightTextSecondary,
                  ),
                ).animate().fadeIn(delay: 50.ms, duration: 250.ms),
                const SizedBox(height: 6),

                // Amount row: Large "$760.00" on left, "$1,240 of $2,000 spent" on right
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: <Widget>[
                    // Left: $760.00
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: <Widget>[
                        Text(
                          leftDollars,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 42,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -1.2,
                            color: dark
                                ? AppColors.darkTextPrimary
                                : AppColors.lightTextPrimary,
                          ),
                        ),
                        Text(
                          leftCents,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                            color: dark
                                ? AppColors.darkTextPrimary
                                : AppColors.lightTextPrimary,
                          ),
                        ),
                      ],
                    ),

                    // Right: $1,240 of $2,000 spent
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Text(
                          spentDollars,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.4,
                            color: dark
                                ? AppColors.darkTextPrimary
                                : AppColors.lightTextPrimary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'of $limitDollars spent',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: AppColors.lightTextSecondary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ).animate().fadeIn(delay: 100.ms, duration: 350.ms),
                const SizedBox(height: 18),

                // Segmented Multi-Color Progress Bar
                BudgetSegmentedBar(
                  budgets: budgets,
                  totalBudget: computedLimit,
                  totalSpent: totalSpent,
                ).animate().fadeIn(delay: 150.ms, duration: 350.ms),
                const SizedBox(height: 28),

                // "Where it went" Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text(
                      'Where it went',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.4,
                        color: dark
                            ? AppColors.darkTextPrimary
                            : AppColors.lightTextPrimary,
                      ),
                    ),
                    Text(
                      '${budgets.length} categories',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: AppColors.lightTextSecondary,
                      ),
                    ),
                  ],
                ).animate().fadeIn(delay: 180.ms, duration: 250.ms),
                const SizedBox(height: 14),

                // Colored Category Cards
                Column(
                  children: List<Widget>.generate(budgets.length, (int i) {
                    return BudgetCategoryCard(
                      budget: budgets[i],
                      totalSpent: totalSpent,
                      onTap: () {
                        HapticFeedback.selectionClick();
                      },
                    )
                        .animate()
                        .fadeIn(
                          delay: Duration(milliseconds: 200 + i * 40),
                          duration: 300.ms,
                        )
                        .slideY(begin: 0.05, end: 0);
                  }),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
