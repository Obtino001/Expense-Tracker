import 'package:budget_app/core/utils/extensions.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../../../core/animations/motion.dart';
import '../../../../core/animations/animation_constants.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/formatters.dart';

/// Top Black Card on Insights Screen matching the screenshot:
/// - "Spent this month" + "↓ 8% vs last" pill badge
/// - Large "$1,240.00"
/// - Smooth flowing white line chart with area gradient
class InsightsLineChartCard extends StatelessWidget {
  const InsightsLineChartCard({
    required this.spent,
    super.key,
  });

  final double spent;

  @override
  Widget build(BuildContext context) {
    final String formatted = Formatters.currency(spent);
    final List<String> parts = formatted.split('.');
    final String mainPart = parts.isNotEmpty ? parts[0] : formatted;
    final String decimalPart = parts.length > 1 ? '.${parts[1]}' : '.00';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(22, 20, 22, 12),
      decoration: BoxDecoration(
        color: AppColors.deepBlack,
        borderRadius: BorderRadius.circular(28),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.25),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          // Top Row: "Spent this month" + "↓ 8% vs last" pill
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            spacing: 12,
            runSpacing: 8,
            children: <Widget>[
              Text(
                'Spent this month',
                style: context.tt.bodySmall!.copyWith(color: AppColors.lightTextSecondary),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: AppColors.darkPill,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: AppColors.darkPillBorder,
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    const Icon(
                      Icons.arrow_downward_rounded,
                      size: 13,
                      color: Colors.white,
                    ),
                    const SizedBox(width: 4),
                    Flexible(child: Text(
                      '8% vs last',
                      style: context.tt.labelMedium!.copyWith(color: Colors.white),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    )),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),

          // Large amount "$1,240.00"
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: <Widget>[
              AnimatedNumber(
                mainPart,
                style: context.tt.displayMedium!.copyWith(color: Colors.white),
              ),
              Text(
                decimalPart,
                style: context.tt.headlineMedium!.copyWith(color: Colors.white.withValues(alpha: 0.9)),
              ),
            ],
          )),
          const SizedBox(height: 14),

          // Smooth white curved line chart
          SizedBox(
            height: 95,
            child: LineChart(
              LineChartData(
                minX: 0,
                maxX: 10,
                minY: 0,
                maxY: 10,
                gridData: const FlGridData(show: false),
                borderData: FlBorderData(show: false),
                titlesData: const FlTitlesData(show: false),
                lineTouchData: const LineTouchData(enabled: false),
                lineBarsData: <LineChartBarData>[
                  LineChartBarData(
                    isCurved: true,
                    curveSmoothness: 0.45,
                    color: Colors.white,
                    barWidth: 2.5,
                    isStrokeCapRound: true,
                    dotData: FlDotData(
                      show: true,
                      checkToShowDot: (FlSpot spot, LineChartBarData barData) {
                        return spot.x == 10;
                      },
                      getDotPainter: (FlSpot spot, double percent,
                          LineChartBarData bar, int index) {
                        return FlDotCirclePainter(
                          radius: 4,
                          color: Colors.white,
                          strokeWidth: 0,
                        );
                      },
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        colors: <Color>[
                          Colors.white.withValues(alpha: 0.18),
                          Colors.white.withValues(alpha: 0.0),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                    spots: const <FlSpot>[
                      FlSpot(0, 3.8),
                      FlSpot(1.5, 4.2),
                      FlSpot(2.5, 2.8),
                      FlSpot(3.8, 6.4),
                      FlSpot(5.0, 5.0),
                      FlSpot(6.2, 7.8),
                      FlSpot(7.5, 6.0),
                      FlSpot(8.5, 6.2),
                      FlSpot(10, 4.5),
                    ],
                  ),
                ],
              ),
              duration: Motion.of(context, Motion.slow),
              curve: Motion.out,
            ),
          ),
        ],
      ),
    );
  }
}
