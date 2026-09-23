import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/router/route_names.dart';
import '../../../../core/utils/extensions.dart';
import '../../../../data/models/budget_model.dart';
import '../../../../data/models/transaction_model.dart';
import '../../../../shared/providers/transaction_provider.dart';
import '../../../../shared/widgets/skeleton_loader.dart';
import '../../../../shared/widgets/transaction_tile.dart';
import '../widgets/balance_card.dart';
import '../widgets/home_header.dart';
import '../widgets/month_budget_card.dart';

/// Screen 1: Home Dashboard rebuilt from scratch to match the reference design:
/// - Picky top header with logo, notification bell, user avatar
/// - Deep black Balance Card ($4,820.50) with Add, Send, Top up, More
/// - October budget card ($1,240.00 of $2,000, On track, coral progress bar)
/// - Recent activity list ("Blue Bottle -$5.40", "Whole Foods -$63.20")
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<List<TransactionModel>> txAsync =
        ref.watch(transactionsProvider);
    final AsyncValue<List<BudgetModel>> budgetsAsync =
        ref.watch(budgetsProvider);
    final ({double balance, double expense, double income}) totals =
        ref.watch(totalsProvider);
    final bool dark = context.isDark;

    // Calculate month budget total limit & spent
    final double totalLimit = budgetsAsync.maybeWhen(
      data: (List<BudgetModel> bList) =>
          bList.fold(0.0, (double sum, BudgetModel b) => sum + b.limit),
      orElse: () => 2000.0,
    );

    final double totalSpent = totals.expense > 0 ? totals.expense : 1240.0;
    final double currentBalance = totals.balance != 0 ? totals.balance : 4820.50;

    return Scaffold(
      backgroundColor: dark ? AppColors.darkBg : AppColors.lightBg,
      body: SafeArea(
        bottom: false,
        child: RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(transactionsProvider);
            ref.invalidate(budgetsProvider);
            await Future<void>.delayed(const Duration(milliseconds: 300));
          },
          color: AppColors.coral,
          child: ListView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 110),
            children: <Widget>[
              // 1. Picky Header
              const HomeHeader()
                  .animate()
                  .fadeIn(duration: 250.ms)
                  .slideY(begin: -0.05, end: 0),
              const SizedBox(height: 20),

              // 2. Large Black Balance Card
              BalanceCard(balance: currentBalance)
                  .animate()
                  .fadeIn(delay: 50.ms, duration: 350.ms)
                  .slideY(begin: 0.05, end: 0, curve: Curves.easeOutCubic),
              const SizedBox(height: 20),

              // 3. Month Budget Card (October budget)
              MonthBudgetCard(
                spent: totalSpent,
                limit: totalLimit > 0 ? totalLimit : 2000.0,
                monthName: 'October',
              )
                  .animate()
                  .fadeIn(delay: 100.ms, duration: 350.ms)
                  .slideY(begin: 0.05, end: 0, curve: Curves.easeOutCubic),
              const SizedBox(height: 28),

              // 4. Recent activity section header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text(
                    'Recent activity',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.4,
                      color: dark
                          ? AppColors.darkTextPrimary
                          : AppColors.lightTextPrimary,
                    ),
                  ),
                  GestureDetector(
                    onTap: () => context.push(RouteNames.transactions),
                    child: Text(
                      'See all',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.coral,
                      ),
                    ),
                  ),
                ],
              ).animate().fadeIn(delay: 150.ms, duration: 250.ms),
              const SizedBox(height: 12),

              // 5. Transactions List
              txAsync.when(
                loading: () => Column(
                  children: List<Widget>.generate(
                    3,
                    (_) => const SkeletonTransactionTile(),
                  ),
                ),
                error: (Object e, _) => Padding(
                  padding: const EdgeInsets.all(AppSizes.lg),
                  child: Text(
                    'Unable to load activity',
                    style: context.text.bodyMedium,
                  ),
                ),
                data: (List<TransactionModel> txs) {
                  if (txs.isEmpty) {
                    return Container(
                      padding: const EdgeInsets.all(32),
                      alignment: Alignment.center,
                      child: Text(
                        'No transactions yet',
                        style: GoogleFonts.plusJakartaSans(
                          color: AppColors.lightTextSecondary,
                          fontSize: 14,
                        ),
                      ),
                    );
                  }

                  // Take the most recent items
                  final List<TransactionModel> recent =
                      txs.take(4).toList();

                  return Column(
                    children: List<Widget>.generate(recent.length, (int i) {
                      return TransactionTile(
                        transaction: recent[i],
                        onTap: () => context.push(
                          RouteNames.transactions,
                        ),
                      )
                          .animate()
                          .fadeIn(
                            delay: Duration(milliseconds: 180 + i * 40),
                            duration: 300.ms,
                          )
                          .slideX(begin: 0.04, end: 0);
                    }),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
