import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:moneywise/core/utils/currency_formatter.dart';
import 'package:moneywise/core/utils/date_formatter.dart';
import 'package:moneywise/features/loans/domain/loan_model.dart';
import 'package:moneywise/features/settings/presentation/providers/settings_provider.dart';
import 'package:moneywise/features/transactions/domain/transaction_model.dart';
import 'package:moneywise/features/transactions/presentation/widgets/amount_input_widget.dart';
import 'package:moneywise/shared/enums/loan_type.dart';
import 'package:moneywise/shared/enums/recurring_type.dart';
import 'package:moneywise/shared/enums/transaction_type.dart';
import 'package:moneywise/shared/providers/repository_providers.dart';
import 'package:uuid/uuid.dart';

class AddRepaymentSheet extends ConsumerStatefulWidget {

  const AddRepaymentSheet({
    required this.loan, required this.alreadyRepaid, super.key,
  });
  final LoanEntity loan;
  final double alreadyRepaid;

  @override
  ConsumerState<AddRepaymentSheet> createState() => _AddRepaymentSheetState();
}

class _AddRepaymentSheetState extends ConsumerState<AddRepaymentSheet> {
  double _amount = 0.0;
  DateTime _date = DateTime.now();
  final _noteController = TextEditingController();

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsProvider).valueOrNull;
    final currencySymbol = CurrencyFormatter.getSymbol(settings?.currency ?? 'BDT');
    final theme = Theme.of(context);
    final remaining = widget.loan.amount - widget.alreadyRepaid - _amount;

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Add Repayment',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 24),
            AmountInputWidget(
              initialValue: 0,
              onChanged: (v) => setState(() => _amount = v),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Remaining Balance', style: TextStyle(color: theme.colorScheme.onSurfaceVariant)),
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: '$currencySymbol ',
                        style: TextStyle(
                          color: remaining < 0 ? const Color(0xFF1D9E75) : theme.colorScheme.primary,
                          fontSize: 12,
                        ),
                      ),
                      TextSpan(
                        text: remaining.toStringAsFixed(0),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: remaining < 0 ? const Color(0xFF1D9E75) : theme.colorScheme.primary,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.calendar_today_rounded),
              title: Text(DateFormatter.format(_date)),
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: _date,
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2100),
                );
                if (picked != null) setState(() => _date = picked);
              },
            ),
            TextField(
              controller: _noteController,
              decoration: const InputDecoration(
                labelText: 'Note (optional)',
                prefixIcon: Icon(Icons.notes_rounded),
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _amount <= 0 ? null : () async {
                final repayment = RepaymentEntity(
                  id: const Uuid().v4(),
                  amount: _amount,
                  date: _date,
                  note: _noteController.text,
                );
                
                try {
                  final loanRepo = ref.read(loanRepositoryProvider);
                  final transRepo = ref.read(transactionRepositoryProvider);
                  final catRepo = ref.read(categoryRepositoryProvider);

                  // 1. Add repayment to loan
                  await loanRepo.addRepayment(widget.loan.uuid, repayment);
                  
                  // 2. Add as a transaction
                  final categories = await catRepo.watchAll().first;
                  final otherCategory = categories.firstWhere(
                    (c) => c.name.toLowerCase() == 'other',
                    orElse: () => categories.first,
                  );

                  final transaction = TransactionEntity(
                    uuid: const Uuid().v4(),
                    title: 'Repayment: ${widget.loan.personName}',
                    amount: _amount,
                    type: widget.loan.type == LoanType.took 
                        ? TransactionType.expense 
                        : TransactionType.income,
                    categoryId: otherCategory.uuid,
                    date: _date,
                    isRecurring: false,
                    recurringType: RecurringType.none,
                    createdAt: DateTime.now(),
                    note: _noteController.text.isEmpty 
                        ? 'Loan repayment' 
                        : _noteController.text,
                  );
                  await transRepo.add(transaction);

                  // 3. Automatically mark as settled if fully repaid
                  if (remaining <= 0) {
                    await loanRepo.markSettled(widget.loan.uuid);
                  }

                  if (mounted) {
                    final navigator = Navigator.of(context);
                    final messenger = ScaffoldMessenger.of(context);
                    
                    navigator.pop();
                    messenger.showSnackBar(
                      SnackBar(
                        content: Text(remaining <= 0 
                          ? 'Repayment added & Loan settled ✓' 
                          : 'Repayment added & Transaction recorded ✓'),
                        backgroundColor: const Color(0xFF1D9E75),
                      ),
                    );
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error: $e')),
                    );
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 56),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: const Text('Confirm Repayment', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }
}
