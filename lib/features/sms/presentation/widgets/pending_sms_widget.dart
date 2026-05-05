import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:moneywise/shared/enums/transaction_type.dart';
import 'package:moneywise/features/categories/presentation/providers/category_providers.dart';
import 'package:moneywise/features/transactions/presentation/widgets/category_picker_widget.dart';
import 'package:moneywise/features/sms/providers/sms_providers.dart';
import 'package:moneywise/core/services/sms_parser.dart';

class PendingSmsWidget extends ConsumerWidget {
  const PendingSmsWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pendingList = ref.watch(pendingSmsProvider);
    if (pendingList.isEmpty) return const SizedBox.shrink();

    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4.0, bottom: 12.0),
          child: Text(
            'Detected Transactions (${pendingList.length})',
            style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
        ),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: pendingList.length,
          itemBuilder: (context, index) {
            final parsed = pendingList[index];
            return _PendingSmsCard(parsed: parsed);
          },
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}

class _PendingSmsCard extends ConsumerStatefulWidget {
  final ParsedSmsTransaction parsed;
  const _PendingSmsCard({required this.parsed});

  @override
  ConsumerState<_PendingSmsCard> createState() => _PendingSmsCardState();
}

class _PendingSmsCardState extends ConsumerState<_PendingSmsCard> {
  String? _selectedCategoryId;

  @override
  Widget build(BuildContext context) {
    final t = widget.parsed;
    final theme = Theme.of(context);
    final color = t.type == TransactionType.income ? Colors.green : Colors.red;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      shape: RoundedRectangleBorder(
        side: BorderSide(color: theme.dividerColor, width: 0.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: color.withValues(alpha: 0.1),
                  child: Icon(
                    t.type == TransactionType.income ? Icons.arrow_downward : Icons.arrow_upward,
                    color: color,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${t.bankName} - ${t.type == TransactionType.income ? "Received" : "Payment"}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        '৳${t.amount.toStringAsFixed(2)}',
                        style: TextStyle(
                          color: color,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => ref.read(smsTrackingNotifierProvider.notifier).dismissTransaction(t),
                  icon: const Icon(Icons.close, size: 20),
                  color: Colors.grey,
                ),
              ],
            ),
            const Divider(height: 24),
            const Text(
              'Select Category',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Colors.grey),
            ),
            const SizedBox(height: 8),
            CategoryPickerWidget(
              selectedCategoryId: _selectedCategoryId ?? '',
              onSelected: (id) => setState(() => _selectedCategoryId = id),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => ref.read(smsTrackingNotifierProvider.notifier).dismissTransaction(t),
                    child: const Text('Dismiss'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton(
                    onPressed: _selectedCategoryId == null
                        ? null
                        : () => ref.read(smsTrackingNotifierProvider.notifier).confirmTransaction(t, _selectedCategoryId!),
                    child: const Text('Confirm'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
