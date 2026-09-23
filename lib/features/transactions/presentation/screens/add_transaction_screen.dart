import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/utils/extensions.dart';
import '../../../../data/models/category_model.dart';
import '../../../../data/models/transaction_model.dart';
import '../../../../shared/providers/repository_providers.dart';
import '../../../../shared/providers/transaction_provider.dart';
import '../../../../shared/widgets/custom_text_field.dart';
import '../../../../shared/widgets/gradient_button.dart';
import '../../../../shared/widgets/primary_app_bar.dart';

class AddTransactionScreen extends ConsumerStatefulWidget {
  const AddTransactionScreen({super.key});

  @override
  ConsumerState<AddTransactionScreen> createState() =>
      _AddTransactionScreenState();
}

class _AddTransactionScreenState extends ConsumerState<AddTransactionScreen> {
  final TextEditingController _title = TextEditingController();
  final TextEditingController _amount = TextEditingController();
  final TextEditingController _note = TextEditingController();
  TransactionType _type = TransactionType.expense;
  CategoryModel? _category;
  DateTime _date = DateTime.now();
  bool _saving = false;

  @override
  void dispose() {
    _title.dispose();
    _amount.dispose();
    _note.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_title.text.isEmpty || _amount.text.isEmpty || _category == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all required fields')),
      );
      return;
    }
    setState(() => _saving = true);
    HapticFeedback.mediumImpact();
    final double? parsedAmount = double.tryParse(_amount.text.trim());
    if (parsedAmount == null) {
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid amount')),
      );
      return;
    }

    final repo = ref.read(transactionRepositoryProvider);
    if (repo == null) {
      final TransactionModel newTx = TransactionModel(
        id: 'tx_${DateTime.now().millisecondsSinceEpoch}',
        title: _title.text.trim(),
        amount: parsedAmount,
        date: _date,
        category: _category!,
        type: _type,
        note: _note.text.trim(),
      );
      ref.read(localTransactionsProvider.notifier).add(newTx);
      setState(() => _saving = false);
      if (mounted) context.pop();
      return;
    }
    await repo.add(
      title: _title.text.trim(),
      amount: parsedAmount,
      date: _date,
      category: _category!,
      type: _type,
      note: _note.text.trim(),
    );
    if (mounted) context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final AsyncValue<List<CategoryModel>> categoriesAsync =
        ref.watch(categoriesProvider);

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const PrimaryAppBar(title: 'Add transaction'),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(AppSizes.lg),
                children: <Widget>[
                  _SegmentedType(
                    value: _type,
                    onChanged: (TransactionType t) =>
                        setState(() => _type = t),
                  ),
                  const SizedBox(height: AppSizes.xl),

                  Text('Title', style: context.text.titleMedium),
                  const SizedBox(height: AppSizes.sm),
                  CustomTextField(
                    hint: 'e.g. Coffee with friends',
                    controller: _title,
                    icon: Icons.edit_outlined,
                  ),
                  const SizedBox(height: AppSizes.lg),

                  Text('Amount', style: context.text.titleMedium),
                  const SizedBox(height: AppSizes.sm),
                  CustomTextField(
                    hint: '0.00',
                    controller: _amount,
                    icon: Icons.attach_money_rounded,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                  ),
                  const SizedBox(height: AppSizes.lg),

                  Text('Category', style: context.text.titleMedium),
                  const SizedBox(height: AppSizes.sm),
                  categoriesAsync.when(
                    loading: () =>
                        const Center(child: CircularProgressIndicator()),
                    error: (_, __) => const Text('Failed to load'),
                    data: (List<CategoryModel> all) {
                      final List<CategoryModel> filtered = all
                          .where((CategoryModel c) =>
                              c.isIncome ==
                              (_type == TransactionType.income))
                          .toList();
                      return Wrap(
                        spacing: AppSizes.sm,
                        runSpacing: AppSizes.sm,
                        children: filtered
                            .map((CategoryModel c) => _CategoryChip(
                                  category: c,
                                  selected: _category?.id == c.id,
                                  onTap: () =>
                                      setState(() => _category = c),
                                ))
                            .toList(),
                      );
                    },
                  ),
                  const SizedBox(height: AppSizes.lg),

                  Text('Date', style: context.text.titleMedium),
                  const SizedBox(height: AppSizes.sm),
                  GestureDetector(
                    onTap: () async {
                      final DateTime? picked = await showDatePicker(
                        context: context,
                        initialDate: _date,
                        firstDate: DateTime(2020),
                        lastDate: DateTime.now(),
                      );
                      if (picked != null) setState(() => _date = picked);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSizes.lg,
                        vertical: AppSizes.lg,
                      ),
                      decoration: BoxDecoration(
                        color: context.isDark
                            ? AppColors.darkCard
                            : AppColors.lightCard,
                        borderRadius:
                            BorderRadius.circular(AppSizes.radiusLg),
                      ),
                      child: Row(
                        children: <Widget>[
                          const Icon(Icons.calendar_today_rounded, size: 18),
                          const SizedBox(width: AppSizes.md),
                          Text(
                            '${_date.day}/${_date.month}/${_date.year}',
                            style: context.text.bodyLarge,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSizes.lg),

                  Text('Note', style: context.text.titleMedium),
                  const SizedBox(height: AppSizes.sm),
                  CustomTextField(
                    hint: 'Add a note (optional)',
                    controller: _note,
                    maxLines: 3,
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(AppSizes.lg),
              child: GradientButton(
                label: _saving ? 'Saving…' : 'Save transaction',
                onPressed: _saving ? null : _save,
              ).animate().fadeIn(duration: 300.ms),
            ),
          ],
        ),
      ),
    );
  }
}

class _SegmentedType extends StatelessWidget {
  const _SegmentedType({required this.value, required this.onChanged});
  final TransactionType value;
  final ValueChanged<TransactionType> onChanged;

  @override
  Widget build(BuildContext context) {
    final bool isExpense = value == TransactionType.expense;
    return Container(
      padding: const EdgeInsets.all(AppSizes.xs),
      decoration: BoxDecoration(
        color: context.isDark ? AppColors.darkCard : AppColors.lightCard,
        borderRadius: BorderRadius.circular(AppSizes.radiusFull),
      ),
      child: Row(
        children: <Widget>[
          _Segment(
            label: 'Expense',
            icon: Icons.arrow_upward_rounded,
            selected: isExpense,
            color: AppColors.danger,
            onTap: () => onChanged(TransactionType.expense),
          ),
          _Segment(
            label: 'Income',
            icon: Icons.arrow_downward_rounded,
            selected: !isExpense,
            color: AppColors.success,
            onTap: () => onChanged(TransactionType.income),
          ),
        ],
      ),
    );
  }
}

class _Segment extends StatelessWidget {
  const _Segment({
    required this.label,
    required this.icon,
    required this.selected,
    required this.color,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutCubic,
          padding: const EdgeInsets.symmetric(vertical: AppSizes.md),
          decoration: BoxDecoration(
            color: selected ? color : Colors.transparent,
            borderRadius: BorderRadius.circular(AppSizes.radiusFull),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Icon(icon,
                  color: selected ? Colors.white : color, size: 18),
              const SizedBox(width: AppSizes.sm),
              Text(
                label,
                style: TextStyle(
                  color: selected ? Colors.white : null,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  const _CategoryChip({
    required this.category,
    required this.selected,
    required this.onTap,
  });

  final CategoryModel category;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSizes.md,
          vertical: AppSizes.sm,
        ),
        decoration: BoxDecoration(
          color: selected
              ? category.color
              : category.color.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(AppSizes.radiusFull),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(
              category.icon,
              size: 16,
              color: selected ? Colors.white : category.color,
            ),
            const SizedBox(width: AppSizes.sm),
            Text(
              category.name,
              style: TextStyle(
                color: selected ? Colors.white : category.color,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
