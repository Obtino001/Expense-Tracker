import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/animations/animation_constants.dart';
import '../../../../core/utils/extensions.dart';

/// Weekly spending bar chart using fl_chart.
class SpendingChart extends StatelessWidget {
  const SpendingChart({required this.data, super.key});
  final List<double> data;

  static const List<String> _labels = <String>[
    'Mon',
    'Tue',
    'Wed',
    'Thu',
    'Fri',
    'Sat',
    'Sun',
  ];

  @override
  Widget build(BuildContext context) {
    final double maxY =
        (data.reduce((double a, double b) => a > b ? a : b)) * 1.25;
    return AspectRatio(
      aspectRatio: 1.6,
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: maxY,
          gridData: const FlGridData(show: false),
          borderData: FlBorderData(show: false),
          titlesData: FlTitlesData(
            leftTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 28,
                getTitlesWidget: (double value, _) {
                  final int i = value.toInt();
                  if (i < 0 || i >= _labels.length) {
                    return const SizedBox.shrink();
                  }
                  return Padding(
                    padding: const EdgeInsets.only(top: AppSizes.sm),
                    child: Text(
                      _labels[i],
                      style: context.text.bodySmall?.copyWith(
                        color: context.isDark
                            ? AppColors.darkTextSecondary
                            : AppColors.lightTextSecondary,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          barTouchData: BarTouchData(
            touchTooltipData: BarTouchTooltipData(
              getTooltipColor: (_) => AppColors.primary,
              tooltipBorderRadius: BorderRadius.circular(AppSizes.radiusMd),
              getTooltipItem:
                  (BarChartGroupData g, int i, BarChartRodData r, int ri) {
                return BarTooltipItem(
                  r.toY.toStringAsFixed(0),
                  Theme.of(context).textTheme.labelMedium!.copyWith(color: Colors.white),
                );
              },
            ),
          ),
          barGroups: List<BarChartGroupData>.generate(data.length, (int i) {
            return BarChartGroupData(
              x: i,
              barRods: <BarChartRodData>[
                BarChartRodData(
                  toY: data[i],
                  width: 16,
                  borderRadius: BorderRadius.circular(AppSizes.radiusSm),
                  gradient: AppColors.primaryGradient,
                ),
              ],
            );
          }),
        ),
        duration: Motion.of(context, Motion.slow),
        curve: Motion.out,
      ),
    );
  }
}
