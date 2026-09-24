import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:budget_app/core/animations/motion.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../shared/widgets/pressable.dart';
import '../../../../core/utils/extensions.dart';
import '../../../../shared/providers/transaction_provider.dart';
import '../widgets/insights_banner.dart';
import '../widgets/insights_bar_chart.dart';
import '../widgets/insights_line_chart_card.dart';
import '../widgets/insights_metrics_cards.dart';

/// Screen 3: Insights Screen matching the right screen in the reference screenshot:
/// - "Insights" header + 4-dots circular option button
/// - Deep black card ("Spent this month", "$1,240.00", "↓ 8% vs last", smooth line chart)
/// - Peach/coral insight banner ("You spent $108 less than last month. Keep being picky 👏")
/// - "This week" bar chart with values on top and Saturday highlighted in Coral
/// - 2-column metrics cards ("Top category: Food & Drink", "Daily avg: $42.30")
class AnalyticsScreen extends ConsumerWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ({double balance, double expense, double income}) totals =
        ref.watch(totalsProvider);
    final bool dark = context.isDark;

    final double totalSpent = totals.expense > 0 ? totals.expense : 1240.0;

    return Scaffold(
      backgroundColor: dark ? AppColors.darkBg : AppColors.lightBg,
      body: SafeArea(
        bottom: false,
        child: ListView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 110),
          children: <Widget>[
            // 1. Header row: "Insights" + 4-dots circle button
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Expanded(child: Text(
                  'Insights',
                  style: context.tt.displaySmall!.copyWith(color: dark
                        ? AppColors.darkTextPrimary
                        : AppColors.lightTextPrimary),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                )),
                Pressable(
                  onTap: () {
                    HapticFeedback.lightImpact();
                  },
                  child: Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: dark ? AppColors.darkCard : AppColors.lightSurface,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color:
                            dark ? AppColors.darkBorder : AppColors.lightBorder,
                        width: 1,
                      ),
                      boxShadow: <BoxShadow>[
                        BoxShadow(
                          color:
                              Colors.black.withValues(alpha: dark ? 0.2 : 0.03),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Icon(
                        Icons.grid_view_rounded,
                        size: 16,
                        color: dark
                            ? AppColors.darkTextPrimary
                            : AppColors.lightTextPrimary,
                      ),
                    ),
                  ),
                ),
              ],
            ).fxEnter(context, step: 0),
            const SizedBox(height: 20),

            // 2. Top Black Card with Line Chart
            InsightsLineChartCard(spent: totalSpent).fxEnter(context, step: 1),
            const SizedBox(height: 16),

            // 3. Peach/Coral Insight Banner
            const InsightsBanner().fxEnter(context, step: 2),
            const SizedBox(height: 18),

            // 4. "This week" Bar Chart
            const InsightsBarChart().fxEnter(context, step: 3),
            const SizedBox(height: 18),

            // 5. 2-Column Metrics Cards: Top category & Daily avg
            const InsightsMetricsCards().fxEnter(context, step: 4),
          ],
        ),
      ),
    );
  }
}
