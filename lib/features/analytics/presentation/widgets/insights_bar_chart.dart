import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/extensions.dart';
import '../../../../shared/widgets/pressable.dart';

/// Weekly spending bar chart matching the Insights screen screenshot:
/// - "This week" + [W | M | Y] segmented toggle
/// - 7 bars for M, T, W, T, F, S, S
/// - Value on top of each bar ($42, $68, $30, $88, $51, $120, $35)
/// - Saturday bar highlighted in vibrant Coral (#FF5B4D)
/// - Smooth rounded capsules
class InsightsBarChart extends StatefulWidget {
  const InsightsBarChart({super.key});

  @override
  State<InsightsBarChart> createState() => _InsightsBarChartState();
}

class _InsightsBarChartState extends State<InsightsBarChart> {
  int _selectedPeriod = 0; // 0: W, 1: M, 2: Y

  static const List<double> values = <double>[
    42,
    68,
    30,
    88,
    51,
    120,
    35,
  ];

  static const List<String> days = <String>[
    'M',
    'T',
    'W',
    'T',
    'F',
    'S',
    'S',
  ];

  @override
  Widget build(BuildContext context) {
    final bool dark = context.isDark;
    const double maxVal = 140.0;
    final scale = MediaQuery.textScalerOf(context).scale(1);
    final chartHeight = 140.0 * scale;
    final chartWidth = math.max(MediaQuery.sizeOf(context).width - 76,
        values.length * 40.0 * scale);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
      decoration: BoxDecoration(
        color: dark ? AppColors.darkCard : AppColors.lightSurface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: dark ? AppColors.darkBorder : AppColors.lightBorder,
          width: 1,
        ),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.black.withValues(alpha: dark ? 0.2 : 0.03),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          // Header row: "This week" in Coral + [W M Y] segmented control
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            spacing: 12,
            runSpacing: 8,
            children: <Widget>[
              Text(
                'This week',
                style: context.tt.titleMedium!.copyWith(color: AppColors.coral),
              ),
              // [W | M | Y] Pill Toggle
              Container(
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  color:
                      dark ? const Color(0xFF22222A) : const Color(0xFFF1F2F5),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: List<Widget>.generate(3, (int i) {
                    final String label = i == 0 ? 'W' : (i == 1 ? 'M' : 'Y');
                    final bool active = _selectedPeriod == i;
                    return Pressable(
                      onTap: () {
                        setState(() {
                          _selectedPeriod = i;
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: active
                              ? (dark ? AppColors.darkCard : Colors.white)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: active
                              ? <BoxShadow>[
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.06),
                                    blurRadius: 4,
                                    offset: const Offset(0, 1),
                                  ),
                                ]
                              : null,
                        ),
                        child: Text(
                          label,
                          style: context.tt.bodySmall!.copyWith(fontWeight:
                                active ? FontWeight.w700 : FontWeight.w500, color: active
                                ? (dark
                                    ? Colors.white
                                    : AppColors.lightTextPrimary)
                                : AppColors.lightTextSecondary),
                        ),
                      ),
                    );
                  }),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),

          // Bar Chart with Numbers Above and Days Below
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SizedBox(
            width: chartWidth,
            height: chartHeight,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: List<Widget>.generate(values.length, (int i) {
                final double val = values[i];
                final bool isPeak =
                    i == 5; // Saturday ($120) highlighted in Coral
                final double barH = (val / maxVal) * (chartHeight - 50 * scale);

                final Color barColor = isPeak
                    ? AppColors.coral
                    : (dark
                        ? const Color(0xFF2A2B35)
                        : const Color(0xFFECEEF2));

                final Color numColor =
                    isPeak ? AppColors.coral : AppColors.lightTextSecondary;

                return Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: <Widget>[
                      // Number above bar: "$120", "$42", etc.
                      Text(
                        '\$${val.toInt()}',
                        style: context.tt.labelSmall!.copyWith(fontWeight:
                              isPeak ? FontWeight.w800 : FontWeight.w600, color: numColor),
                      ),
                      const SizedBox(height: 6),

                      // Bar capsule
                      Container(
                        width: 18,
                        height: barH.clamp(12.0, chartHeight - 50 * scale),
                        decoration: BoxDecoration(
                          color: barColor,
                          borderRadius: BorderRadius.circular(9),
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Day label: M, T, W, T, F, S, S
                      Text(
                        days[i],
                        style: context.tt.bodySmall!.copyWith(fontWeight:
                              isPeak ? FontWeight.w800 : FontWeight.w600, color: isPeak
                              ? (dark
                                  ? Colors.white
                                  : AppColors.lightTextPrimary)
                              : AppColors.lightTextSecondary),
                      ),
                    ],
                  ),
                );
              }),
            ),
          )),
        ],
      ),
    );
  }
}
