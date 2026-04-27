import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:moneywise/core/utils/date_formatter.dart';
import 'package:moneywise/features/loans/domain/loan_model.dart';
import 'package:moneywise/features/loans/presentation/providers/loan_providers.dart';
import 'package:moneywise/features/transactions/presentation/widgets/amount_input_widget.dart';
import 'package:moneywise/shared/enums/loan_type.dart';
import 'package:reactive_forms/reactive_forms.dart';

class AddLoanSheet extends ConsumerStatefulWidget {
  const AddLoanSheet({super.key, this.initialLoan});
  final LoanEntity? initialLoan;

  @override
  ConsumerState<AddLoanSheet> createState() => _AddLoanSheetState();
}

class _AddLoanSheetState extends ConsumerState<AddLoanSheet> {
  final _form = FormGroup({
    'personName': FormControl<String>(validators: [Validators.required]),
    'purpose': FormControl<String>(),
  });

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.initialLoan != null) {
        ref.read(loanFormProvider.notifier).initEdit(widget.initialLoan!);
        _form.control('personName').value = widget.initialLoan!.personName;
        _form.control('purpose').value = widget.initialLoan!.purpose;
      } else {
        ref.read(loanFormProvider.notifier).initNew();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final loan = ref.watch(loanFormProvider);
    final notifier = ref.read(loanFormProvider.notifier);
    final theme = Theme.of(context);

    if (loan == null) return const Center(child: CircularProgressIndicator());

    final accentColor = loan.type == LoanType.gave ? const Color(0xFF1D9E75) : const Color(0xFFE05C5C);

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
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              SegmentedButton<LoanType>(
                segments: const [
                  ButtonSegment(value: LoanType.gave, label: Text('I Gave'), icon: Icon(Icons.upload_rounded)),
                  ButtonSegment(value: LoanType.took, label: Text('I Took'), icon: Icon(Icons.download_rounded)),
                ],
                selected: {loan.type},
                onSelectionChanged: (set) => notifier.updateType(set.first),
                style: SegmentedButton.styleFrom(
                  selectedBackgroundColor: accentColor,
                  selectedForegroundColor: Colors.white,
                ),
              ),
              const SizedBox(height: 32),
              ReactiveTextField<String>(
                formControlName: 'personName',
                decoration: const InputDecoration(
                  labelText: "Person's Name",
                  prefixIcon: Icon(Icons.person_rounded),
                ),
                onChanged: (control) => notifier.updateName(control.value ?? ''),
              ),
              const SizedBox(height: 24),
              AmountInputWidget(
                initialValue: loan.amount,
                onChanged: notifier.updateAmount,
              ),
              const SizedBox(height: 32),
              ReactiveTextField<String>(
                formControlName: 'purpose',
                decoration: const InputDecoration(
                  labelText: 'Purpose (optional)',
                  prefixIcon: Icon(Icons.info_outline_rounded),
                ),
                onChanged: (control) => notifier.updatePurpose(control.value ?? ''),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Loan Date', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        ActionChip(
                          avatar: const Icon(Icons.calendar_today_rounded, size: 14),
                          label: Text(DateFormatter.format(loan.date)),
                          onPressed: () async {
                            final picked = await showDatePicker(
                              context: context,
                              initialDate: loan.date,
                              firstDate: DateTime(2000),
                              lastDate: DateTime(2100),
                            );
                            if (picked != null) {
                              notifier.updateDate(picked);
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Due Date', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        ActionChip(
                          avatar: const Icon(Icons.event_note_rounded, size: 14),
                          label: Text(loan.dueDate == null ? 'No due date' : DateFormatter.format(loan.dueDate!)),
                          onPressed: () async {
                            final picked = await showDatePicker(
                              context: context,
                              initialDate: loan.dueDate ?? DateTime.now(),
                              firstDate: DateTime(2000),
                              lastDate: DateTime(2100),
                            );
                            notifier.updateDueDate(picked);
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: () async {
                  if (_form.valid) {
                    final success = await notifier.save();
                    if (success && mounted) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(widget.initialLoan != null ? 'Loan updated ✓' : 'Loan recorded ✓')),
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
                child: const Text('Save Loan', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
