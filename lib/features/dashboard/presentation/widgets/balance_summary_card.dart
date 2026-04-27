import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:moneywise/core/utils/currency_formatter.dart';
import 'package:moneywise/features/settings/presentation/providers/settings_provider.dart';
import 'package:moneywise/features/transactions/presentation/providers/transaction_providers.dart';
import 'package:moneywise/shared/widgets/loading_shimmer.dart';

class BalanceSummaryCard extends ConsumerWidget {
  const BalanceSummaryCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summaryAsync = ref.watch(monthlySummaryProvider);
    final settings = ref.watch(settingsProvider).valueOrNull;
    final theme = Theme.of(context);
    final currencySymbol = CurrencyFormatter.getSymbol(settings?.currency ?? 'BDT');

    return summaryAsync.when(
      data: (summary) => Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              theme.colorScheme.primary,
              theme.colorScheme.primary.withBlue(150),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: theme.colorScheme.primary.withValues(alpha: 0.3),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'This Month',
              style: theme.textTheme.labelMedium?.copyWith(
                color: Colors.white.withValues(alpha: 0.7),
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: '$currencySymbol ',
                        style: theme.textTheme.titleLarge?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                      TextSpan(
                        text: summary.netBalance.toStringAsFixed(0),
                        style: theme.textTheme.displaySmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Poppins',
                        ),
                      ),
                    ],
                  ),
                ).animate().fadeIn().slideX(begin: -0.2),
                if (summary.savingsRate > 0)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'Saved ${summary.savingsRate.toStringAsFixed(0)}%',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                _SummaryChip(
                  label: 'Income',
                  amount: summary.totalIncome,
                  symbol: currencySymbol,
                  icon: Icons.arrow_upward_rounded,
                  color: const Color(0xFF1D9E75),
                ),
                const SizedBox(width: 16),
                _SummaryChip(
                  label: 'Expense',
                  amount: summary.totalExpense,
                  symbol: currencySymbol,
                  icon: Icons.arrow_downward_rounded,
                  color: const Color(0xFFE05C5C),
                ),
              ],
            ),
          ],
        ),
      ),
      loading: () => const ShimmerCard(height: 200),
      error: (e, s) => const SizedBox.shrink(),
    );
  }
}

class _SummaryChip extends StatelessWidget {
  const _SummaryChip({
    required this.label,
    required this.amount,
    required this.symbol,
    required this.icon,
    required this.color,
  });

  final String label;
  final double amount;
  final String symbol;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 14,
              backgroundColor: color,
              child: Icon(icon, size: 16, color: Colors.white),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(color: Colors.white70, fontSize: 10),
                  ),
                  RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: symbol,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                          ),
                        ),
                        TextSpan(
                          text: amount.toStringAsFixed(0),
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
