import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:moneywise/core/utils/date_formatter.dart';
import 'package:moneywise/features/transactions/presentation/providers/transaction_providers.dart';
import 'package:moneywise/features/transactions/presentation/screens/add_transaction_sheet.dart';
import 'package:moneywise/features/transactions/presentation/widgets/transaction_list_tile.dart';
import 'package:moneywise/shared/widgets/empty_state_widget.dart';
import 'package:moneywise/shared/widgets/loading_shimmer.dart';

class TransactionsScreen extends ConsumerWidget {
  const TransactionsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transactionsAsync = ref.watch(transactionListProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Transactions',
          style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: SearchBar(
              hintText: 'Search transactions...',
              leading: const Icon(Icons.search_rounded),
              onChanged: (value) {
                final current = ref.read(transactionFilterProvider);
                ref.read(transactionFilterProvider.notifier).state =
                    current.copyWith(searchQuery: value);
              },
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {
                ref.invalidate(transactionListProvider);
                ref.invalidate(monthlySummaryProvider);
              },
              child: transactionsAsync.when(
                data: (transactions) {
                  if (transactions.isEmpty) {
                    return const EmptyStateWidget(
                      title: 'No transactions found',
                      subtitle: 'Try adjusting your filters or search.',
                      icon: Icons.receipt_long_rounded,
                    );
                  }

                  // Group by date
                  final grouped = <String, List<dynamic>>{};
                  for (final t in transactions) {
                    final dateKey = DateFormatter.format(t.date);
                    grouped[dateKey] ??= [];
                    grouped[dateKey]!.add(t);
                  }

                  final keys = grouped.keys.toList();

                  return ListView.builder(
                    itemCount: keys.length,
                    itemBuilder: (context, index) {
                      final date = keys[index];
                      final items = grouped[date]!;

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                            child: Text(
                              date,
                              style: theme.textTheme.labelLarge?.copyWith(
                                color: theme.colorScheme.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          ...items.map((t) => Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 16),
                                child: TransactionListTile(transaction: t),
                              )),
                        ],
                      );
                    },
                  );
                },
                loading: () => const ShimmerDashboard(),
                error: (e, s) => Center(child: Text('Error: $e')),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            useSafeArea: true,
            builder: (context) => const AddTransactionSheet(),
          );
        },
        child: const Icon(Icons.add_rounded),
      ),
    );
  }
}
