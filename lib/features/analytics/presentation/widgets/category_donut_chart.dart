import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:moneywise/core/utils/currency_formatter.dart';
import 'package:moneywise/features/analytics/presentation/providers/analytics_providers.dart';
import 'package:moneywise/features/settings/presentation/providers/settings_provider.dart';
import 'package:moneywise/features/transactions/presentation/providers/transaction_providers.dart';

class CategoryDonutChart extends ConsumerWidget {
  const CategoryDonutChart({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pieData = ref.watch(pieChartDataProvider);
    final settings = ref.watch(settingsProvider).valueOrNull;
    final currencySymbol = CurrencyFormatter.getSymbol(settings?.currency ?? 'BDT');
    final theme = Theme.of(context);

    final totalExpense = pieData.fold(0.0, (sum, item) => sum + item.value);

    if (totalExpense == 0) {
      return const SizedBox(
        height: 300,
        child: Center(child: Text('No expenses this period')),
      );
    }

    return Column(
      children: [
        SizedBox(
          height: 250,
          child: Stack(
            alignment: Alignment.center,
            children: [
              PieChart(
                PieChartData(
                  centerSpaceRadius: 60,
                  sectionsSpace: 4,
                  sections: pieData.map((item) {
                    return PieChartSectionData(
                      color: item.color,
                      value: item.value,
                      title: '',
                      radius: 20,
                    );
                  }).toList(),
                  pieTouchData: PieTouchData(
                    touchCallback: (event, response) {
                      if (event is FlTapUpEvent && response != null && response.touchedSection != null) {
                        final index = response.touchedSection!.touchedSectionIndex;
                        if (index >= 0 && index < pieData.length) {
                          final categoryId = pieData[index].categoryId;
                          ref.read(transactionFilterProvider.notifier).state = 
                              ref.read(transactionFilterProvider).copyWith(categoryId: categoryId);
                          context.push('/transactions');
                        }
                      }
                    },
                  ),
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Total',
                    style: theme.textTheme.labelMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                  ),
                  RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: '$currencySymbol ',
                          style: theme.textTheme.titleSmall?.copyWith(
                            color: theme.colorScheme.onSurface,
                            fontWeight: FontWeight.normal,
                          ),
                        ),
                        TextSpan(
                          text: totalExpense.toStringAsFixed(0),
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        Wrap(
          spacing: 16,
          runSpacing: 8,
          children: pieData.map((item) => _LegendItem(
            color: item.color,
            label: item.label,
            amount: item.value,
            symbol: currencySymbol,
            percentage: totalExpense > 0 ? (item.value / totalExpense * 100) : 0,
          )).toList(),
        ),
      ],
    );
  }
}

class _LegendItem extends StatelessWidget {

  const _LegendItem({
    required this.color,
    required this.label,
    required this.amount,
    required this.symbol,
    required this.percentage,
  });
  final Color color;
  final String label;
  final double amount;
  final String symbol;
  final double percentage;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: 10, height: 10, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 8),
        RichText(
          text: TextSpan(
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Colors.black),
            children: [
              TextSpan(text: '$label • '),
              TextSpan(text: '$symbol ', style: const TextStyle(fontSize: 10, color: Colors.grey)),
              TextSpan(text: amount.toStringAsFixed(0)),
              TextSpan(text: ' (${percentage.toStringAsFixed(0)}%)', style: const TextStyle(color: Colors.grey, fontSize: 10)),
            ],
          ),
        ),
      ],
    );
  }
}
