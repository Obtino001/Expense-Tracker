import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../shared/providers/preferences_provider.dart';
import '../../../../shared/providers/transaction_provider.dart';

/// One selected calendar month across budgets, home, and insights.
class MonthNavigation extends ConsumerWidget {
  const MonthNavigation({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = ref.watch(selectedMonthProvider);
    final month = DateTime(selected.year, selected.month);
    void move(int offset) {
      final target = DateTime(month.year, month.month + offset);
      ref.read(preferencesProvider.notifier).selectionFeedback();
      ref.read(selectedMonthProvider.notifier).state =
          SelectedMonth(target.year, target.month);
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        IconButton(
          tooltip: 'Previous month',
          onPressed: selected.year > 2000 || selected.month > 1 ? () => move(-1) : null,
          icon: const Icon(Icons.chevron_left_rounded, size: 20),
        ),
        Flexible(
          child: TextButton(
            onPressed: () {
              final now = DateTime.now();
              ref.read(selectedMonthProvider.notifier).state = SelectedMonth(now.year, now.month);
              ref.read(preferencesProvider.notifier).selectionFeedback();
            },
            child: Tooltip(
              message: 'Return to this month',
              child: Text(DateFormat('MMM yyyy').format(month)),
            ),
          ),
        ),
        IconButton(
          tooltip: 'Next month',
          onPressed: selected.year < 2100 || selected.month < 12 ? () => move(1) : null,
          icon: const Icon(Icons.chevron_right_rounded, size: 20),
        ),
      ],
    );
  }
}
