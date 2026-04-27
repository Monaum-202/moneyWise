import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:moneywise/features/budget/presentation/providers/budget_providers.dart';
import 'package:moneywise/features/budget/presentation/widgets/budget_row_widget.dart';
import 'package:moneywise/features/settings/presentation/providers/settings_provider.dart';

class BudgetScreen extends ConsumerWidget {
  const BudgetScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final monthYear = ref.watch(currentMonthYearProvider);
    final budgets = ref.watch(categoryBudgetProvider);
    final settings = ref.watch(settingsProvider).valueOrNull;
    final currency = settings?.currency ?? '৳';
    final theme = Theme.of(context);

    // Parse monthYear "2024-10" to DateTime
    final parts = monthYear.split('-');
    final date = DateTime(int.parse(parts[0]), int.parse(parts[1]));
    final displayDate = DateFormat('MMMM yyyy').format(date);

    final totalBudget = budgets.fold(0.0, (sum, b) => sum + b.limitAmount);
    final totalSpent = budgets.fold(0.0, (sum, b) => sum + b.spentAmount);
    final remaining = totalBudget - totalSpent;
    final totalProgress = totalBudget > 0 ? (totalSpent / totalBudget).clamp(0.0, 1.0) : 0.0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Budget', style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold)),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.chevron_left_rounded),
                  onPressed: () {
                    final prev = DateTime(date.year, date.month - 1);
                    ref.read(currentMonthYearProvider.notifier).state = 
                        '${prev.year}-${prev.month.toString().padLeft(2, '0')}';
                  },
                ),
                Text(
                  displayDate,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                IconButton(
                  icon: const Icon(Icons.chevron_right_rounded),
                  onPressed: () {
                    final next = DateTime(date.year, date.month + 1);
                    ref.read(currentMonthYearProvider.notifier).state = 
                        '${next.year}-${next.month.toString().padLeft(2, '0')}';
                  },
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildOverviewCard(currency, totalBudget, totalSpent, remaining, totalProgress, theme),
                const SizedBox(height: 24),
                ...budgets.map((b) => BudgetRowWidget(data: b)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOverviewCard(String currency, double total, double spent, double remaining, double progress, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _OverviewItem(label: 'Total Budget', amount: total, currency: currency),
              _OverviewItem(label: 'Remaining', amount: remaining, currency: currency),
            ],
          ),
          const SizedBox(height: 24),
          Text(
            'Spent: $currency${spent.toStringAsFixed(0)}',
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 12,
              backgroundColor: Colors.white.withValues(alpha: 0.2),
              color: progress > 0.9 ? const Color(0xFFE05C5C) : const Color(0xFF1D9E75),
            ),
          ),
        ],
      ),
    );
  }
}

class _OverviewItem extends StatelessWidget {

  const _OverviewItem({required this.label, required this.amount, required this.currency});
  final String label;
  final double amount;
  final String currency;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 12)),
        Text(
          '$currency${amount.toStringAsFixed(0)}',
          style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold, fontFamily: 'Poppins'),
        ),
      ],
    );
  }
}
