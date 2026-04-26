import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:moneywise/features/loans/presentation/providers/loan_providers.dart';
import 'package:moneywise/features/loans/presentation/screens/add_loan_sheet.dart';
import 'package:moneywise/features/loans/presentation/widgets/loan_card_widget.dart';
import 'package:moneywise/features/settings/presentation/providers/settings_provider.dart';
import 'package:moneywise/shared/widgets/empty_state_widget.dart';
import 'package:moneywise/shared/widgets/loading_shimmer.dart';

class LoansScreen extends ConsumerWidget {
  const LoansScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loanListAsync = ref.watch(loanListProvider);
    final summaryAsync = ref.watch(loanSummaryProvider);
    final filter = ref.watch(loanFilterProvider);
    final settings = ref.watch(settingsProvider).valueOrNull;
    final currency = settings?.currency ?? '৳';
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Loans', style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold)),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: summaryAsync.when(
              data: (summary) => Row(
                children: [
                  Expanded(
                    child: _SummaryCard(
                      label: 'To Receive',
                      amount: summary.totalGave,
                      currency: currency,
                      color: const Color(0xFF1D9E75),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _SummaryCard(
                      label: 'To Pay',
                      amount: summary.totalTook,
                      currency: currency,
                      color: const Color(0xFFE05C5C),
                    ),
                  ),
                ],
              ),
              loading: () => const ShimmerCard(height: 100),
              error: (_, __) => const SizedBox.shrink(),
            ),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: LoanFilter.values.map((f) {
                final isSelected = filter == f;
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: FilterChip(
                    label: Text(f.name[0].toUpperCase() + f.name.substring(1)),
                    selected: isSelected,
                    onSelected: (_) => ref.read(loanFilterProvider.notifier).state = f,
                    selectedColor: theme.colorScheme.primary,
                    checkmarkColor: Colors.white,
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : theme.colorScheme.onSurface,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          Expanded(
            child: loanListAsync.when(
              data: (loans) {
                if (loans.isEmpty) {
                  return _buildEmptyState(filter);
                }
                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: loans.length,
                  itemBuilder: (context, index) {
                    final loan = loans[index];
                    return LoanCardWidget(
                      loan: loan,
                      onTap: () => context.push('/loans/${loan.uuid}'),
                    );
                  },
                );
              },
              loading: () => ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: 3,
                itemBuilder: (_, __) => const ShimmerCard(height: 100),
              ),
              error: (e, s) => Center(child: Text('Error: $e')),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            builder: (context) => const AddLoanSheet(),
          );
        },
        label: const Text('Add Loan'),
        icon: const Icon(Icons.add_rounded),
      ),
    );
  }

  Widget _buildEmptyState(LoanFilter filter) {
    return switch (filter) {
      LoanFilter.overdue => const EmptyStateWidget(
          title: 'No overdue loans 🎉',
          subtitle: 'All your debts are on track.',
          icon: Icons.check_circle_outline_rounded,
        ),
      _ => const EmptyStateWidget(
          title: 'No loans found',
          subtitle: 'Keep track of money you give or take.',
          icon: Icons.handshake_rounded,
        ),
    };
  }
}

class _SummaryCard extends StatelessWidget {

  const _SummaryCard({
    required this.label,
    required this.amount,
    required this.currency,
    required this.color,
  });
  final String label;
  final double amount;
  final String currency;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(
            '$currency${amount.toStringAsFixed(0)}',
            style: TextStyle(color: color, fontSize: 20, fontWeight: FontWeight.w900, fontFamily: 'Poppins'),
          ),
        ],
      ),
    );
  }
}
