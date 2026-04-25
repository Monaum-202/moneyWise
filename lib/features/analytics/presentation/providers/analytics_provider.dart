import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:moneywise/shared/providers/repository_providers.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'analytics_provider.g.dart';

@riverpod
Future<List<PieChartSectionData>> categoryPieData(CategoryPieDataRef ref, String monthYear) async {
  final repository = ref.watch(transactionRepositoryProvider);
  final totals = await repository.getCategoryTotals(monthYear);
  
  final totalExpense = totals.fold(0.0, (sum, item) => sum + item.total);

  if (totalExpense == 0) return [];

  return totals.map((entry) {
    return PieChartSectionData(
      value: entry.total,
      title: '${(entry.total / totalExpense * 100).toStringAsFixed(0)}%',
      color: Color(entry.colorValue),
      radius: 50,
      showTitle: true,
    );
  }).where((section) => section.value > 0).toList();
}

@riverpod
List<String> insights(InsightsRef ref) {
  return [
    'You spent 15% more on Food this week than last week.',
    'Great job! You are within your Shopping budget.',
    'Consider setting a budget for Entertainment to save more.',
  ];
}
