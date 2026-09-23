import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../../core/constants/app_sizes.dart';
import '../../../../core/utils/extensions.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../data/models/transaction_model.dart';

/// Donut chart + category list for the analytics screen.
class CategoryBreakdown extends StatelessWidget {
  const CategoryBreakdown({required this.transactions, super.key});

  final List<TransactionModel> transactions;

  @override
  Widget build(BuildContext context) {
    final Map<String, double> totals = <String, double>{};
    final Map<String, Color> colors = <String, Color>{};
    final Map<String, IconData> icons = <String, IconData>{};

    for (final TransactionModel t
        in transactions.where((TransactionModel t) => !t.isIncome)) {
      totals[t.category.name] =
          (totals[t.category.name] ?? 0) + t.amount;
      colors[t.category.name] = t.category.color;
      icons[t.category.name] = t.category.icon;
    }

    final double total =
        totals.values.fold<double>(0, (double a, double b) => a + b);
    final List<MapEntry<String, double>> entries = totals.entries.toList()
      ..sort((MapEntry<String, double> a, MapEntry<String, double> b) =>
          b.value.compareTo(a.value));

    if (entries.isEmpty) {
      return Center(
        child: Text('No expenses yet', style: context.text.bodyMedium),
      );
    }

    return Column(
      children: <Widget>[
        SizedBox(
          height: 200,
          child: Stack(
            alignment: Alignment.center,
            children: <Widget>[
              PieChart(
                PieChartData(
                  sectionsSpace: 4,
                  centerSpaceRadius: 60,
                  startDegreeOffset: -90,
                  sections: entries.map((MapEntry<String, double> e) {
                    return PieChartSectionData(
                      value: e.value,
                      color: colors[e.key],
                      title: '',
                      radius: 28,
                    );
                  }).toList(),
                ),
              ),
              Column(
                children: <Widget>[
                  Text(
                    Formatters.currency(total),
                    style: context.text.titleLarge,
                  ),
                  Text(
                    'Total spent',
                    style: context.text.bodySmall,
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSizes.xl),
        ...entries.map((MapEntry<String, double> e) {
          final double pct = total == 0 ? 0 : (e.value / total);
          return Padding(
            padding: const EdgeInsets.only(bottom: AppSizes.md),
            child: Row(
              children: <Widget>[
                Container(
                  height: 36,
                  width: 36,
                  decoration: BoxDecoration(
                    color: colors[e.key]!.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                  ),
                  child: Icon(icons[e.key], color: colors[e.key], size: 18),
                ),
                const SizedBox(width: AppSizes.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Text(e.key,
                              style: context.text.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.w600)),
                          Text(
                            Formatters.currency(e.value),
                            style: context.text.bodyMedium
                                ?.copyWith(fontWeight: FontWeight.w700),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSizes.xs),
                      ClipRRect(
                        borderRadius:
                            BorderRadius.circular(AppSizes.radiusFull),
                        child: LinearProgressIndicator(
                          value: pct,
                          minHeight: 6,
                          backgroundColor:
                              colors[e.key]!.withValues(alpha: 0.15),
                          valueColor:
                              AlwaysStoppedAnimation<Color>(colors[e.key]!),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }
}
