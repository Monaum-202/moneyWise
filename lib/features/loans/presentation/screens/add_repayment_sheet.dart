import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:moneywise/core/utils/date_formatter.dart';
import 'package:moneywise/features/loans/domain/loan_model.dart';
import 'package:moneywise/features/loans/presentation/providers/loan_providers.dart';
import 'package:moneywise/features/settings/presentation/providers/settings_provider.dart';
import 'package:moneywise/features/transactions/presentation/widgets/amount_input_widget.dart';

class AddRepaymentSheet extends ConsumerStatefulWidget {

  const AddRepaymentSheet({
    required this.loanUuid, required this.totalLoan, required this.alreadyRepaid, super.key,
  });
  final String loanUuid;
  final double totalLoan;
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
    final currency = settings?.currency ?? '৳';
    final theme = Theme.of(context);
    final remaining = widget.totalLoan - widget.alreadyRepaid - _amount;

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
            const Text('Add Repayment', style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold, fontSize: 18)),
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
                Text(
                  '$currency${remaining.toStringAsFixed(0)}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: remaining < 0 ? const Color(0xFF1D9E75) : theme.colorScheme.primary,
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
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  amount: _amount,
                  date: _date,
                  note: _noteController.text,
                );
                
                final success = await ref.read(loanFormProvider.notifier).addRepayment(repayment);
                if (success && mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Repayment added ✓')),
                  );
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
