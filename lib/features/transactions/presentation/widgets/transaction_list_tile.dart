import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:moneywise/core/utils/date_formatter.dart';
import 'package:moneywise/core/utils/icon_helper.dart';
import 'package:moneywise/features/categories/presentation/providers/category_providers.dart';
import 'package:moneywise/features/settings/presentation/providers/settings_provider.dart';
import 'package:moneywise/features/transactions/domain/transaction_model.dart';
import 'package:moneywise/features/transactions/presentation/providers/transaction_providers.dart';
import 'package:moneywise/shared/enums/transaction_type.dart';
import 'package:moneywise/shared/providers/repository_providers.dart';

class TransactionListTile extends ConsumerWidget {

  const TransactionListTile({
    required this.transaction, super.key,
    this.onTap,
  });
  final TransactionEntity transaction;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoryMap = ref.watch(categoryMapProvider);
    final settings = ref.watch(settingsProvider).valueOrNull;
    final category = categoryMap[transaction.categoryId];
    final currency = settings?.currency ?? '৳';
    final theme = Theme.of(context);

    final isExpense = transaction.type == TransactionType.expense;

    return Dismissible(
      key: Key(transaction.uuid),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          color: theme.colorScheme.error,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(Icons.delete_rounded, color: Colors.white),
      ),
      onDismissed: (direction) {
        ref.read(transactionFormProvider.notifier).delete(transaction.uuid);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Transaction deleted'),
            action: SnackBarAction(
              label: 'Undo',
              onPressed: () {
                ref.read(transactionRepositoryProvider).add(transaction);
              },
            ),
          ),
        );
      },
      child: Card(
        elevation: 0,
        margin: const EdgeInsets.symmetric(vertical: 4),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        color: theme.colorScheme.surfaceContainerLow,
        child: ListTile(
          onTap: onTap,
          leading: CircleAvatar(
            backgroundColor: Color(category?.colorValue ?? 0xFFE0E0E0).withValues(alpha: 0.2),
            child: Icon(
              IconHelper.getIcon(category?.iconCodePoint ?? 0xe13d),
              color: Color(category?.colorValue ?? 0xFF757575),
            ),
          ),
          title: Text(
            transaction.title,
            style: const TextStyle(fontWeight: FontWeight.w600, fontFamily: 'Poppins'),
          ),
          subtitle: Text(
            '${DateFormatter.formatDayMonth(transaction.date)}${transaction.note != null && transaction.note!.isNotEmpty ? " • ${transaction.note}" : ""}',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          trailing: Text(
            '${isExpense ? "-" : "+"}$currency${transaction.amount.toStringAsFixed(0)}',
            style: TextStyle(
              color: isExpense ? const Color(0xFFE05C5C) : const Color(0xFF1D9E75),
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),
      ),
    );
  }
}
