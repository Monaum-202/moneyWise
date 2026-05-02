import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:moneywise/core/utils/date_formatter.dart';
import 'package:moneywise/features/transactions/domain/transaction_model.dart';
import 'package:moneywise/features/transactions/presentation/providers/transaction_providers.dart';
import 'package:moneywise/features/transactions/presentation/widgets/amount_input_widget.dart';
import 'package:moneywise/features/transactions/presentation/widgets/category_picker_widget.dart';
import 'package:moneywise/shared/enums/recurring_type.dart';
import 'package:moneywise/shared/enums/transaction_type.dart';
import 'package:reactive_forms/reactive_forms.dart';

class AddTransactionSheet extends ConsumerStatefulWidget {
  const AddTransactionSheet({super.key, this.initialTransaction});
  final TransactionEntity? initialTransaction;

  @override
  ConsumerState<AddTransactionSheet> createState() => _AddTransactionSheetState();
}

class _AddTransactionSheetState extends ConsumerState<AddTransactionSheet> {
  final _form = FormGroup({
    'title': FormControl<String>(validators: [Validators.required, Validators.maxLength(50)]),
    'note': FormControl<String>(),
  });

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.initialTransaction != null) {
        ref.read(transactionFormProvider.notifier).initEdit(widget.initialTransaction!);
        _form.control('title').value = widget.initialTransaction!.title;
        _form.control('note').value = widget.initialTransaction!.note;
      } else {
        ref.read(transactionFormProvider.notifier).initNew();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final transaction = ref.watch(transactionFormProvider);
    final notifier = ref.read(transactionFormProvider.notifier);
    final theme = Theme.of(context);

    if (transaction == null) {
      return const Center(child: CircularProgressIndicator());
    }

    final isExpense = transaction.type == TransactionType.expense;
    final accentColor = isExpense ? theme.colorScheme.error : theme.colorScheme.secondary;

    return DraggableScrollableSheet(
      initialChildSize: 0.9,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        ),
        child: ReactiveForm(
          formGroup: _form,
          child: ListView(
            controller: scrollController,
            children: [
              const SizedBox(height: 12),
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.outlineVariant,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              SegmentedButton<TransactionType>(
                segments: const [
                  ButtonSegment(
                    value: TransactionType.expense,
                    label: Text('Expense'),
                    icon: Icon(Icons.remove_circle_outline),
                  ),
                  ButtonSegment(
                    value: TransactionType.income,
                    label: Text('Income'),
                    icon: Icon(Icons.add_circle_outline),
                  ),
                ],
                selected: {transaction.type},
                onSelectionChanged: (set) => notifier.updateType(set.first),
                style: SegmentedButton.styleFrom(
                  selectedBackgroundColor: accentColor,
                  selectedForegroundColor: theme.colorScheme.onSecondary,
                ),
              ),
              const SizedBox(height: 32),
              AmountInputWidget(
                initialValue: transaction.amount,
                onChanged: notifier.updateAmount,
              ),
              const SizedBox(height: 32),
              ReactiveTextField<String>(
                formControlName: 'title',
                decoration: const InputDecoration(
                  labelText: 'What was this for?',
                  prefixIcon: Icon(Icons.title_rounded),
                ),
                onChanged: (control) => notifier.updateTitle(control.value ?? ''),
              ),
              const SizedBox(height: 24),
              Text('Category', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              CategoryPickerWidget(
                selectedCategoryId: transaction.categoryId,
                onSelected: notifier.updateCategory,
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: ActionChip(
                      avatar: const Icon(Icons.calendar_today_rounded, size: 16),
                      label: Text(DateFormatter.format(transaction.date)),
                      onPressed: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: transaction.date,
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2100),
                        );
                        if (picked != null) notifier.updateDate(picked);
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: SwitchListTile(
                      title: const Text('Recurring', style: TextStyle(fontSize: 14)),
                      value: transaction.isRecurring,
                      onChanged: notifier.updateRecurring,
                    ),
                  ),
                ],
              ),
              if (transaction.isRecurring) ...[
                const SizedBox(height: 12),
                DropdownButtonFormField<RecurringType>(
                  value: transaction.recurringType == RecurringType.none
                      ? RecurringType.daily
                      : transaction.recurringType,
                  decoration: const InputDecoration(labelText: 'Frequency'),
                  items: RecurringType.values.where((e) => e != RecurringType.none).map((type) {
                    return DropdownMenuItem(value: type, child: Text(type.name.toUpperCase()));
                  }).toList(),
                  onChanged: (v) => notifier.updateRecurringType(v ?? RecurringType.daily),
                ),
              ],
              const SizedBox(height: 24),
              ReactiveTextField<String>(
                formControlName: 'note',
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Notes (optional)',
                  prefixIcon: Icon(Icons.notes_rounded),
                ),
                onChanged: (control) => notifier.updateNote(control.value ?? ''),
              ),
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: () async {
                  if (_form.valid) {
                    final success = await notifier.save();
                    if (success && mounted) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          backgroundColor: theme.colorScheme.onSurface,
                          content: Text(
                            widget.initialTransaction != null ? 'Transaction updated ✓' : 'Transaction added ✓',
                            style: TextStyle(color: theme.colorScheme.surface),
                          ),
                        ),
                      );
                    }
                  } else {
                    _form.markAllAsTouched();
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 56),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: const Text('Save Transaction', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
