import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:moneywise/features/transactions/presentation/providers/transaction_providers.dart';
import 'package:moneywise/shared/enums/transaction_type.dart';
import 'package:moneywise/shared/providers/repository_providers.dart';

// Period selector
enum AnalyticsPeriod { week, month, year, custom }

final analyticsPeriodProvider = StateProvider<AnalyticsPeriod>((ref) => AnalyticsPeriod.month);

// Date range derived from period
final analyticsDateRangeProvider = Provider<DateTimeRange>((ref) {
  final period = ref.watch(analyticsPeriodProvider);
  final now = DateTime.now();
  return switch (period) {
    AnalyticsPeriod.week => DateTimeRange(start: now.subtract(const Duration(days: 7)), end: now),
    AnalyticsPeriod.month => DateTimeRange(start: DateTime(now.year, now.month, 1), end: now),
    AnalyticsPeriod.year => DateTimeRange(start: DateTime(now.year, 1, 1), end: now),
    AnalyticsPeriod.custom => DateTimeRange(start: now, end: now),
  };
});

// Pie chart data from category totals
final pieChartDataProvider = Provider<List<Map<String, dynamic>>>((ref) {
  final totals = ref.watch(categoryTotalsProvider).valueOrNull ?? [];
  return totals
      .map((t) => {
            'label': t.categoryName,
            'value': t.total,
            'color': Color(t.colorValue),
          })
      .toList();
});

// Bar chart: daily income vs expense for selected period
final barChartDataProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final range = ref.watch(analyticsDateRangeProvider);
  final repo = ref.watch(transactionRepositoryProvider);
  // Query transactions, group by day, return list of {date, income, expense}
  final transactions = await repo.watchAll(from: range.start, to: range.end).first;
  final Map<String, Map<String, double>> grouped = {};
  for (final t in transactions) {
    final key = '${t.date.year}-${t.date.month}-${t.date.day}';
    grouped[key] ??= {'income': 0, 'expense': 0};
    if (t.type == TransactionType.income) {
      grouped[key]!['income'] = grouped[key]!['income']! + t.amount;
    } else {
      grouped[key]!['expense'] = grouped[key]!['expense']! + t.amount;
    }
  }
  return grouped.entries
      .map((e) => {'date': e.key, ...e.value})
      .toList()
    ..sort((a, b) => (a['date'] as String).compareTo(b['date'] as String));
});

// Smart insights strings
final insightsProvider = Provider<List<String>>((ref) {
  final summary = ref.watch(monthlySummaryProvider).valueOrNull;
  final totals = ref.watch(categoryTotalsProvider).valueOrNull ?? [];
  if (summary == null) return [];
  final insights = <String>[];
  final savingsRate = summary.totalIncome > 0 ? ((summary.totalIncome - summary.totalExpense) / summary.totalIncome) * 100 : 0;

  if (savingsRate > 20) insights.add('Great job! You saved \${savingsRate.toStringAsFixed(0)}% this month.');
  if (savingsRate < 0) insights.add('You spent more than you earned this month. Review your expenses.');
  if (totals.isNotEmpty) {
    final top = totals.reduce((a, b) => a.total > b.total ? a : b);
    insights.add('Biggest spend: \${top.categoryName} — ৳\${top.total.toStringAsFixed(0)}');
  }
  return insights;
});
