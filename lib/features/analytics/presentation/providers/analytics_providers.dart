import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:moneywise/features/transactions/presentation/providers/transaction_providers.dart';
import 'package:moneywise/shared/enums/transaction_type.dart';
import 'package:moneywise/shared/models/transaction_summary.dart';
import 'package:moneywise/shared/providers/repository_providers.dart';

// Period selector
enum AnalyticsPeriod { week, month, year, custom }

final analyticsPeriodProvider = StateProvider<AnalyticsPeriod>((ref) => AnalyticsPeriod.month);
final analyticsCustomRangeProvider = StateProvider<DateTimeRange?>((ref) => null);

// Date range derived from period
final analyticsDateRangeProvider = Provider<DateTimeRange>((ref) {
  final period = ref.watch(analyticsPeriodProvider);
  final customRange = ref.watch(analyticsCustomRangeProvider);
  final now = DateTime.now();
  
  if (period == AnalyticsPeriod.custom && customRange != null) {
    return customRange;
  }

  return switch (period) {
    AnalyticsPeriod.week => DateTimeRange(
        start: DateUtils.dateOnly(now.subtract(const Duration(days: 7))),
        end: now,
      ),
    AnalyticsPeriod.month => DateTimeRange(
        start: DateTime(now.year, now.month),
        end: now,
      ),
    AnalyticsPeriod.year => DateTimeRange(
        start: DateTime(now.year),
        end: now,
      ),
    _ => DateTimeRange(
        start: DateTime(now.year, now.month),
        end: now,
      ),
  };
});

// Summary for the selected analytics range
final analyticsSummaryProvider = StreamProvider<TransactionSummary>((ref) {
  final range = ref.watch(analyticsDateRangeProvider);
  final repo = ref.watch(transactionRepositoryProvider);
  return repo.watchSummary(range.start, range.end);
});

// Pie chart data from category totals
final pieChartDataProvider = Provider<List<Map<String, dynamic>>>((ref) {
  final totals = ref.watch(categoryTotalsProvider).valueOrNull ?? [];
  return totals
      .map((t) => {
            'label': t.categoryName,
            'value': t.total,
            'color': Color(t.colorValue),
            'categoryId': t.categoryId,
          })
      .toList();
});

// Bar chart: daily income vs expense for selected period
final barChartDataProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final range = ref.watch(analyticsDateRangeProvider);
  final repo = ref.watch(transactionRepositoryProvider);
  
  // Use watchAll and take first to get current list matching the range
  final transactions = await repo.watchAll(from: range.start, to: range.end).first;
  final grouped = <String, Map<String, double>>{};
  
  for (final t in transactions) {
    final key = '${t.date.year}-${t.date.month.toString().padLeft(2, '0')}-${t.date.day.toString().padLeft(2, '0')}';
    grouped[key] ??= {'income': 0, 'expense': 0};
    if (t.type == TransactionType.income) {
      grouped[key]!['income'] = (grouped[key]!['income'] ?? 0) + t.amount;
    } else {
      grouped[key]!['expense'] = (grouped[key]!['expense'] ?? 0) + t.amount;
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

  if (summary.savingsRate > 20) {
    insights.add('Great job! You saved ${summary.savingsRate.toStringAsFixed(0)}% this month.');
  }
  if (summary.savingsRate < 0) {
    insights.add('You spent more than you earned this month. Review your expenses.');
  }
  if (totals.isNotEmpty) {
    final top = totals.reduce((a, b) => a.total > b.total ? a : b);
    insights.add('Biggest spend: ${top.categoryName} — ৳${top.total.toStringAsFixed(0)}');
  }
  return insights;
});
