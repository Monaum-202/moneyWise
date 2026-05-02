import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:moneywise/core/utils/currency_formatter.dart';
import 'package:moneywise/features/analytics/presentation/providers/analytics_providers.dart';
import 'package:moneywise/features/settings/presentation/providers/settings_provider.dart';

class CashFlowSummaryRow extends ConsumerWidget {
  const CashFlowSummaryRow({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summaryAsync = ref.watch(analyticsSummaryProvider);
    final settings = ref.watch(settingsProvider).valueOrNull;
    final currencySymbol = CurrencyFormatter.getSymbol(settings?.currency ?? 'BDT');
    final theme = Theme.of(context);

    return summaryAsync.when(
      data: (summary) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Row(
          children: [
            _SummaryChip(
              label: 'Total In',
              amount: summary.totalIncome,
              symbol: currencySymbol,
              color: const Color(0xFF1D9E75),
            ),
            const SizedBox(width: 8),
            _SummaryChip(
              label: 'Total Out',
              amount: summary.totalExpense,
              symbol: currencySymbol,
              color: theme.colorScheme.error,
            ),
            const SizedBox(width: 8),
            _SummaryChip(
              label: 'Net',
              amount: summary.netBalance,
              symbol: currencySymbol,
              color: theme.colorScheme.primary,
            ),
          ],
        ),
      ),
      loading: () => const SizedBox(height: 80),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}

class _SummaryChip extends StatelessWidget {
  const _SummaryChip({
    required this.label,
    required this.amount,
    required this.symbol,
    required this.color,
  });

  final String label;
  final double amount;
  final String symbol;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Column(
          children: [
            Text(
              label,
              style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            FittedBox(
              child: RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: '$symbol ',
                      style: TextStyle(color: color, fontSize: 10),
                    ),
                    TextSpan(
                      text: amount.abs().toStringAsFixed(0),
                      style: TextStyle(
                        color: color,
                        fontWeight: FontWeight.w900,
                        fontFamily: 'Poppins',
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
