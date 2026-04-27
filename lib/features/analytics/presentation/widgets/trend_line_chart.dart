import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:moneywise/features/settings/presentation/providers/settings_provider.dart';
import 'package:moneywise/core/utils/currency_formatter.dart';
import 'package:moneywise/features/analytics/presentation/providers/analytics_providers.dart';

class TrendLineChart extends ConsumerWidget {
  const TrendLineChart({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final barDataAsync = ref.watch(barChartDataProvider);
    final settings = ref.watch(settingsProvider).valueOrNull;
    final currencySymbol = CurrencyFormatter.getSymbol(settings?.currency ?? 'BDT');
    final theme = Theme.of(context);

    return barDataAsync.when(
      data: (data) {
        if (data.isEmpty) {
          return const SizedBox(
            height: 200,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.show_chart_rounded, size: 48, color: Colors.grey),
                SizedBox(height: 16),
                Text('No trend data available'),
              ],
            ),
          );
        }

        double cumulative = 0;
        final spots = <FlSpot>[];
        double totalSpend = 0;

        for (var i = 0; i < data.length; i++) {
          cumulative += data[i].expense;
          totalSpend += data[i].expense;
          spots.add(FlSpot(i.toDouble(), cumulative));
        }

        final average = data.isEmpty ? 0.0 : totalSpend / data.length;

        return SizedBox(
          height: 250,
          child: LineChart(
            LineChartData(
              gridData: const FlGridData(show: false),
              titlesData: const FlTitlesData(show: false),
              borderData: FlBorderData(show: false),
              lineBarsData: [
                LineChartBarData(
                  spots: spots,
                  isCurved: true,
                  color: const Color(0xFFE05C5C),
                  barWidth: 3,
                  isStrokeCapRound: true,
                  dotData: const FlDotData(
                    getDotPainter: _getDotPainter,
                  ),
                  belowBarData: BarAreaData(
                    show: true,
                    color: const Color(0xFFE05C5C).withValues(alpha: 0.1),
                  ),
                ),
              ],
              extraLinesData: ExtraLinesData(
                horizontalLines: [
                  HorizontalLine(
                    y: average,
                    color: theme.colorScheme.secondary.withValues(alpha: 0.3),
                    strokeWidth: 1,
                    dashArray: [5, 5],
                  ),
                ],
              ),
              lineTouchData: LineTouchData(
                touchTooltipData: LineTouchTooltipData(
                  getTooltipColor: (_) => theme.colorScheme.surfaceContainerHigh,
                  getTooltipItems: (touchedSpots) {
                    return touchedSpots.map((spot) {
                      final date = data[spot.x.toInt()].date;
                      return LineTooltipItem(
                        '$date\n$currencySymbol${spot.y.toStringAsFixed(0)}',
                        TextStyle(color: theme.colorScheme.onSurface, fontWeight: FontWeight.bold),
                      );
                    }).toList();
                  },
                ),
              ),
            ),
          ),
        );
      },
      loading: () => const SizedBox(height: 200),
      error: (e, s) => const SizedBox.shrink(),
    );
  }

  static FlDotPainter _getDotPainter(FlSpot spot, double xPercentage, LineChartBarData bar, int index) {
    return FlDotCirclePainter(
      radius: 3,
      color: Colors.white,
      strokeWidth: 2,
      strokeColor: const Color(0xFFE05C5C),
    );
  }
}
