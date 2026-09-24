import 'package:flutter/material.dart';
import 'package:budget_app/core/animations/motion.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import '../../../../core/animations/animation_constants.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/utils/extensions.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../data/models/transaction_model.dart';
import '../../../../shared/providers/transaction_provider.dart';
import '../../../../shared/widgets/primary_app_bar.dart';
import '../../../../shared/widgets/skeleton_loader.dart';
import '../../../../shared/widgets/transaction_tile.dart';
import '../widgets/filter_chips.dart';

class TransactionsScreen extends ConsumerWidget {
  const TransactionsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<List<TransactionModel>> txAsync =
        ref.watch(transactionsProvider);
    final TxFilter filter = ref.watch(transactionFilterProvider);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: <Widget>[
            const PrimaryAppBar(title: 'Transactions'),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSizes.lg,
                AppSizes.md,
                AppSizes.lg,
                AppSizes.md,
              ),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: FilterChips(
                  current: filter,
                  onSelected: (TxFilter f) =>
                      ref.read(transactionFilterProvider.notifier).state = f,
                ),
              ),
            ),
            Expanded(
              child: txAsync.when(
                loading: () => ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: AppSizes.lg),
                  itemCount: 8,
                  itemBuilder: (_, __) => const SkeletonTransactionTile(),
                ),
                error: (Object e, _) => Center(child: Text('Error: $e')),
                data: (List<TransactionModel> all) {
                  final List<TransactionModel> txs = _applyFilter(all, filter);
                  if (txs.isEmpty) {
                    return Center(
                      child: Text(
                        'No transactions for this filter.',
                        style: context.text.bodyMedium,
                      ),
                    );
                  }
                  // Group by relative day for that "premium" structure.
                  final Map<String, List<TransactionModel>> grouped =
                      <String, List<TransactionModel>>{};
                  for (final TransactionModel t in txs) {
                    final String key = Formatters.relativeDay(t.date);
                    grouped.putIfAbsent(key, () => <TransactionModel>[]).add(t);
                  }
                  return AnimationLimiter(
                    child: ListView.builder(
                      padding: const EdgeInsets.fromLTRB(
                        AppSizes.lg,
                        AppSizes.sm,
                        AppSizes.lg,
                        AppSizes.huge,
                      ),
                      itemCount: grouped.length,
                      itemBuilder: (BuildContext c, int i) {
                        final String key = grouped.keys.elementAt(i);
                        final List<TransactionModel> list = grouped[key]!;
                        return AnimationConfiguration.staggeredList(
                          position: i,
                          duration: Motion.of(context, Motion.slow),
                          child: SlideAnimation(
                            verticalOffset: 24,
                            child: FadeInAnimation(
                              child: Padding(
                                padding:
                                    const EdgeInsets.only(bottom: AppSizes.lg),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: AppSizes.sm),
                                      child: Text(
                                        key,
                                        style:
                                            context.text.titleMedium?.copyWith(
                                          color: context.isDark
                                              ? AppColors.darkTextSecondary
                                              : AppColors.lightTextSecondary,
                                        ),
                                      ),
                                    ),
                                    Container(
                                      decoration: BoxDecoration(
                                        color: context.isDark
                                            ? AppColors.darkCard
                                            : AppColors.lightCard,
                                        borderRadius: BorderRadius.circular(
                                            AppSizes.radiusLg),
                                      ),
                                      child: Column(
                                        children: list
                                            .map((TransactionModel t) =>
                                                TransactionTile(transaction: t))
                                            .toList(),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ).fxEnter(context, step: 0);
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<TransactionModel> _applyFilter(List<TransactionModel> txs, TxFilter f) {
    switch (f) {
      case TxFilter.all:
        return txs;
      case TxFilter.income:
        return txs.where((TransactionModel t) => t.isIncome).toList();
      case TxFilter.expense:
        return txs.where((TransactionModel t) => !t.isIncome).toList();
    }
  }
}
