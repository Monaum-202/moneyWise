import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:moneywise/features/analytics/presentation/providers/analytics_providers.dart';
import 'package:moneywise/features/transactions/presentation/providers/transaction_providers.dart';

class CategoryDonutChart extends ConsumerWidget {
  const CategoryDonutChart({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pieData = ref.watch(pieChartDataProvider);
    final theme = Theme.of(context);

    final totalExpense = pieData.fold(0.0, (sum, item) => sum + (item['value'] as double));

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
                  sections: pieData.map((data) {
                    final double value = data['value'];
                    return PieChartSectionData(
                      color: data['color'],
                      value: value,
                      title: '',
                      radius: 20,
                    );
                  }).toList(),
                  pieTouchData: PieTouchData(
                    touchCallback: (event, response) {
                      if (event is FlTapUpEvent && response != null && response.touchedSection != null) {
                        final index = response.touchedSection!.touchedSectionIndex;
                        if (index >= 0 && index < pieData.length) {
                          final categoryId = pieData[index]['categoryId'];
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
                  Text(
                    '৳${totalExpense.toStringAsFixed(0)}',
                    style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
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
          children: pieData.map((data) => _LegendItem(
            color: data['color'],
            label: data['label'],
            amount: data['value'],
            percentage: totalExpense > 0 ? (data['value'] / totalExpense * 100) : 0,
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
    required this.percentage,
  });
  final Color color;
  final String label;
  final double amount;
  final double percentage;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: 10, height: 10, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 8),
        Text(
          '$label • ${percentage.toStringAsFixed(0)}%',
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }
}
