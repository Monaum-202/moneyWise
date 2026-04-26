import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:moneywise/features/transactions/presentation/providers/transaction_providers.dart';
import 'package:moneywise/features/transactions/presentation/widgets/transaction_list_tile.dart';
import 'package:moneywise/shared/widgets/empty_state_widget.dart';
import 'package:moneywise/shared/widgets/loading_shimmer.dart';

class RecentTransactionsWidget extends ConsumerWidget {
  const RecentTransactionsWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transactionsAsync = ref.watch(transactionListProvider);
    final theme = Theme.of(context);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Recent Transactions',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Poppins',
                ),
              ),
              TextButton(
                onPressed: () => context.go('/transactions'),
                child: const Text('See all →'),
              ),
            ],
          ),
        ),
        transactionsAsync.when(
          data: (transactions) {
            if (transactions.isEmpty) {
              return const EmptyStateWidget(
                title: 'No transactions yet',
                subtitle: 'Add your first expense or income to see it here.',
                icon: Icons.receipt_long_rounded,
              );
            }
            return ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: transactions.length > 5 ? 5 : transactions.length,
              itemBuilder: (context, index) {
                return TransactionListTile(transaction: transactions[index]);
              },
            );
          },
          loading: () => const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                ShimmerListTile(),
                ShimmerListTile(),
                ShimmerListTile(),
              ],
            ),
          ),
          error: (e, s) => Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text('Error: $e'),
          ),
        ),
      ],
    );
  }
}
