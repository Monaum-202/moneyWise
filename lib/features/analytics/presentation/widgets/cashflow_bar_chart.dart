import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:moneywise/core/utils/currency_formatter.dart';
import 'package:moneywise/features/analytics/presentation/providers/analytics_providers.dart';
import 'package:moneywise/features/settings/presentation/providers/settings_provider.dart';
import 'package:moneywise/shared/widgets/loading_shimmer.dart';

class CashflowBarChart extends ConsumerWidget {
  const CashflowBarChart({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final barDataAsync = ref.watch(barChartDataProvider);
    final settings = ref.watch(settingsProvider).valueOrNull;
    final currencySymbol = CurrencyFormatter.getSymbol(settings?.currency ?? 'BDT');
    final theme = Theme.of(context);

    return barDataAsync.when(
      data: (data) {
        if (data.isEmpty) {
          return SizedBox(
            height: 200,
            child: Center(
              child: Text(
                'No data for this period',
                style: TextStyle(color: theme.colorScheme.outline),
              ),
            ),
          );
        }

        final showLabels = data.length <= 10;

        return SizedBox(
          height: 300,
          child: BarChart(
            BarChartData(
              alignment: BarChartAlignment.spaceAround,
              maxY: _getMaxY(data) * 1.2,
              barTouchData: BarTouchData(
                touchTooltipData: BarTouchTooltipData(
                  getTooltipColor: (_) => theme.colorScheme.surfaceContainerHigh,
                  getTooltipItem: (group, groupIndex, rod, rodIndex) {
                    final income = data[groupIndex].income;
                    final expense = data[groupIndex].expense;
                    return BarTooltipItem(
                      'Income: $currencySymbol${income.toStringAsFixed(0)}\nExpense: $currencySymbol${expense.toStringAsFixed(0)}',
                      TextStyle(color: theme.colorScheme.onSurface, fontWeight: FontWeight.bold),
                    );
                  },
                ),
              ),
              titlesData: FlTitlesData(
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) {
                      final index = value.toInt();
                      if (index < 0 || index >= data.length) return const SizedBox();
                      if (!showLabels && index % 3 != 0) return const SizedBox();
                      
                      final dateStr = data[index].date;
                      final parts = dateStr.split('-');
                      return Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text(
                          '${parts[2]}/${parts[1]}',
                          style: TextStyle(fontSize: 10, color: theme.colorScheme.outline),
                        ),
                      );
                    },
                  ),
                ),
                leftTitles: const AxisTitles(),
                topTitles: const AxisTitles(),
                rightTitles: const AxisTitles(),
              ),
              gridData: const FlGridData(show: false),
              borderData: FlBorderData(show: false),
              barGroups: data.asMap().entries.map((e) {
                final index = e.key;
                final income = e.value.income;
                final expense = e.value.expense;

                return BarChartGroupData(
                  x: index,
                  barRods: [
                    BarChartRodData(
                      toY: income,
                      color: const Color(0xFF1D9E75),
                      width: 8,
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                    ),
                    BarChartRodData(
                      toY: expense,
                      color: theme.colorScheme.error,
                      width: 8,
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                    ),
                  ],
                );
              }).toList(),
            ),
          ).animate().fadeIn(duration: 600.ms).scaleY(begin: 0.8),
        );
      },
      loading: () => const ShimmerCard(height: 200),
      error: (e, s) => Center(child: Text('Error: $e', style: TextStyle(color: theme.colorScheme.error))),
    );
  }

  double _getMaxY(List<AnalyticsBarItem> data) {
    double max = 0;
    for (final e in data) {
      if (e.income > max) max = e.income;
      if (e.expense > max) max = e.expense;
    }
    return max == 0 ? 100 : max;
  }
}
