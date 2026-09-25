import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import 'package:budget_app/core/animations/motion.dart';
import '../../../../core/animations/animation_constants.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/extensions.dart';
import '../../../../core/router/route_names.dart';
import '../../../../data/models/category_model.dart';
import '../../../../data/models/transaction_model.dart';
import '../../../../shared/providers/preferences_provider.dart';
import '../../../../shared/providers/transaction_provider.dart';
import '../../../../shared/widgets/primary_app_bar.dart';
import '../../../../shared/widgets/pressable.dart';
import '../../../../shared/widgets/skeleton_loader.dart';

class AddTransactionScreen extends ConsumerStatefulWidget {
  const AddTransactionScreen({this.transaction, super.key});
  final TransactionModel? transaction;

  @override
  ConsumerState<AddTransactionScreen> createState() =>
      _AddTransactionScreenState();
}

class _AddTransactionScreenState extends ConsumerState<AddTransactionScreen> {
  final _form = GlobalKey<FormState>();
  final _title = TextEditingController();
  final _amount = TextEditingController();
  final _note = TextEditingController();
  TransactionType _type = TransactionType.expense;
  CategoryModel? _category;
  DateTime _date = DateTime.now();
  bool _saving = false;
  bool _categoryMissing = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    final tx = widget.transaction;
    if (tx != null) {
      _title.text = tx.title;
      _amount.text = tx.amount.toStringAsFixed(2);
      _note.text = tx.note;
      _type = tx.type;
      _category = tx.category;
      _date = tx.date;
    }
  }

  @override
  void dispose() {
    _title.dispose();
    _amount.dispose();
    _note.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    FocusScope.of(context).unfocus();
    final valid = _form.currentState!.validate();
    setState(() {
      _categoryMissing = _category == null;
      _error = null;
    });
    if (!valid || _category == null || _saving) return;
    setState(() => _saving = true);
    try {
      final tx = TransactionModel(
        id: widget.transaction?.id ?? const Uuid().v4(),
        userId: widget.transaction?.userId ?? '',
        title: _title.text.trim(),
        amount: double.parse(_amount.text.trim()),
        date: _date,
        category: _category!,
        type: _type,
        note: _note.text.trim(),
      );
      await ref.read(transactionActionsProvider).save(tx);
      if (!mounted) return;
      if (ref.read(preferencesProvider).hapticsEnabled) {
        HapticFeedback.mediumImpact();
      }
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(
            widget.transaction == null ? 'Transaction added' : 'Changes saved'),
        behavior: SnackBarBehavior.floating,
      ));
      if (context.canPop()) {
        context.pop();
      } else {
        context.go(RouteNames.transactions);
      }
    } catch (_) {
      if (mounted) {
        setState(() =>
            _error = 'Your transaction could not be saved. Please try again.');
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  void _selectType(TransactionType type) {
    if (_saving || type == _type) return;
    if (ref.read(preferencesProvider).hapticsEnabled) {
      HapticFeedback.selectionClick();
    }
    setState(() {
      _type = type;
      _category = null;
      _categoryMissing = false;
    });
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _date.isAfter(now) ? now : _date,
      firstDate: DateTime(2000),
      lastDate: now,
    );
    if (picked != null && mounted) {
      setState(() => _date = DateTime(
          picked.year, picked.month, picked.day, _date.hour, _date.minute));
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final prefs = ref.watch(preferencesProvider);
    final categories = ref.watch(categoriesProvider);
    final editing = widget.transaction != null;
    final accent = _type == TransactionType.income
        ? AppColors.success
        : theme.colorScheme.primary;
    return Scaffold(
      body: SafeArea(
          child: Center(
              child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 760),
        child: Column(children: [
          PrimaryAppBar(
              title: editing ? 'Edit transaction' : 'New transaction'),
          Expanded(
              child: Form(
                  key: _form,
                  child: ListView(
                    keyboardDismissBehavior:
                        ScrollViewKeyboardDismissBehavior.onDrag,
                    padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
                    children: [
                      SegmentedButton<TransactionType>(
                        showSelectedIcon: false,
                        segments: const [
                          ButtonSegment(
                              value: TransactionType.expense,
                              label: Text('Expense'),
                              icon: Icon(Icons.north_east_rounded)),
                          ButtonSegment(
                              value: TransactionType.income,
                              label: Text('Income'),
                              icon: Icon(Icons.south_west_rounded)),
                        ],
                        selected: {_type},
                        onSelectionChanged: _saving
                            ? null
                            : (value) => _selectType(value.first),
                      ),
                      const SizedBox(height: 28),
                      AnimatedContainer(
                        duration: prefs.reducedMotion
                            ? Duration.zero
                            : Motion.of(context, Motion.base),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 24),
                        decoration: BoxDecoration(
                          color: accent.withValues(alpha: .07),
                          borderRadius: BorderRadius.circular(28),
                          border:
                              Border.all(color: accent.withValues(alpha: .12)),
                        ),
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(children: [
                                Text('AMOUNT',
                                    style: theme.textTheme.labelSmall?.copyWith(
                                        letterSpacing: 1.6,
                                        color: theme
                                            .colorScheme.onSurfaceVariant)),
                                const Spacer(),
                                Text(prefs.currencyCode,
                                    style: theme.textTheme.labelMedium
                                        ?.copyWith(color: accent)),
                              ]),
                              const SizedBox(height: 12),
                              TextFormField(
                                key: const ValueKey('transaction-amount'),
                                controller: _amount,
                                enabled: !_saving,
                                validator: validateTransactionAmount,
                                keyboardType:
                                    const TextInputType.numberWithOptions(
                                        decimal: true),
                                textInputAction: TextInputAction.next,
                                style: theme.textTheme.displaySmall?.copyWith(
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: -1.5,
                                    color: accent),
                                decoration: const InputDecoration(
                                  hintText: '0.00',
                                  filled: false,
                                  contentPadding: EdgeInsets.zero,
                                  border: InputBorder.none,
                                  enabledBorder: InputBorder.none,
                                  focusedBorder: InputBorder.none,
                                  errorMaxLines: 2,
                                ),
                              ),
                            ]),
                      ),
                      const SizedBox(height: 28),
                      const _Label('What was it for?'),
                      TextFormField(
                        key: const ValueKey('transaction-title'),
                        controller: _title,
                        enabled: !_saving,
                        textCapitalization: TextCapitalization.sentences,
                        maxLength: 80,
                        validator: validateTransactionTitle,
                        textInputAction: TextInputAction.next,
                        decoration: const InputDecoration(
                            hintText: 'Coffee, groceries, a little treat…',
                            prefixIcon: Icon(Icons.edit_outlined),
                            counterText: ''),
                      ),
                      const SizedBox(height: 24),
                      Row(children: [
                        const Expanded(child: _Label('Category')),
                        TextButton(
                            onPressed: _saving
                                ? null
                                : () => context.push(RouteNames.categories),
                            child: const Text('Manage')),
                      ]),
                      categories.when(
                        loading: () =>
                            const SkeletonBox(height: 16),
                        error: (_, __) => Row(children: [
                          const Expanded(
                              child: Text('Could not load categories.')),
                          TextButton(
                              onPressed: () =>
                                  ref.invalidate(categoriesProvider),
                              child: const Text('Retry')),
                        ]),
                        data: (all) {
                          final options = all
                              .where((c) =>
                                  c.isIncome ==
                                  (_type == TransactionType.income))
                              .toList();
                          // An archived category remains editable on its existing entry.
                          if (_category != null &&
                              !options.any((c) => c.id == _category!.id)) {
                            options.add(_category!);
                          }
                          if (options.isEmpty) {
                            return TextButton.icon(
                              onPressed: () =>
                                  context.push(RouteNames.categories),
                              icon: const Icon(Icons.add_rounded),
                              label: const Text('Create your first category'),
                            );
                          }
                          return Wrap(
                              spacing: 9,
                              runSpacing: 10,
                              children: options
                                  .map((category) => ChoiceChip(
                                        avatar: Icon(category.icon,
                                            size: 18,
                                            color: _category?.id == category.id
                                                ? accent
                                                : category.color),
                                        label: Text(category.name),
                                        selected: _category?.id == category.id,
                                        showCheckmark: false,
                                        onSelected: _saving
                                            ? null
                                            : (_) {
                                                if (prefs.hapticsEnabled) {
                                                  HapticFeedback
                                                      .selectionClick();
                                                }
                                                setState(() {
                                                  _category = category;
                                                  _categoryMissing = false;
                                                });
                                              },
                                      ))
                                  .toList());
                        },
                      ),
                      if (_categoryMissing)
                        Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text('Choose a category',
                                style:
                                    context.tt.bodySmall?.copyWith(color: theme.colorScheme.error))),
                      const SizedBox(height: 24),
                      const _Label('Date'),
                      Material(
                          color: theme.colorScheme.surface,
                          borderRadius: BorderRadius.circular(18),
                          child: Pressable(
                            borderRadius: BorderRadius.circular(18),
                            onTap: _saving ? null : _pickDate,
                            child: Padding(
                                padding: const EdgeInsets.all(18),
                                child: Row(children: [
                                  Icon(Icons.calendar_today_rounded,
                                      size: 20,
                                      color:
                                          theme.colorScheme.onSurfaceVariant),
                                  const SizedBox(width: 14),
                                  Expanded(
                                      child: Text(
                                          DateFormat.yMMMMd().format(_date),
                                          style: theme.textTheme.bodyLarge)),
                                  Icon(Icons.expand_more_rounded,
                                      color:
                                          theme.colorScheme.onSurfaceVariant),
                                ])),
                          )),
                      const SizedBox(height: 24),
                      const _Label('A note, if you like'),
                      TextFormField(
                        controller: _note,
                        enabled: !_saving,
                        maxLines: 3,
                        maxLength: 500,
                        textCapitalization: TextCapitalization.sentences,
                        decoration: const InputDecoration(
                            hintText: 'The little details worth remembering',
                            alignLabelWithHint: true),
                      ),
                      if (_error != null)
                        Padding(
                            padding: const EdgeInsets.only(top: 12),
                            child: Text(_error!,
                                style:
                                    context.tt.bodySmall?.copyWith(color: theme.colorScheme.error))),
                      const SizedBox(height: 16),
                      Text('A clear picture starts with the little things.',
                          textAlign: TextAlign.center,
                          style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant)),
                    ],
                  ))),
          Padding(
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 20),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: FilledButton.icon(
                  key: const ValueKey('save-transaction'),
                  onPressed: _saving ? null : _save,
                  icon: _saving
                      ? const LoadingDots()
                      : const Icon(Icons.check_rounded),
                  label: Text(_saving
                      ? 'Saving…'
                      : editing
                          ? 'Save changes'
                          : 'Add transaction'),
                ),
              )),
        ]),
      ))),
    );
  }
}

class _Label extends StatelessWidget {
  const _Label(this.text);
  final String text;
  @override
  Widget build(BuildContext context) => Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(text,
          style: Theme.of(context)
              .textTheme
              .titleSmall
              ?.copyWith(fontWeight: FontWeight.w700)));
}
