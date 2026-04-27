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

class AnalyticsPieItem {
  AnalyticsPieItem({
    required this.label,
    required this.value,
    required this.color,
    required this.categoryId,
  });
  final String label;
  final double value;
  final Color color;
  final String categoryId;
}

// Pie chart data from category totals
final pieChartDataProvider = Provider<List<AnalyticsPieItem>>((ref) {
  final totals = ref.watch(categoryTotalsProvider).valueOrNull ?? [];
  return totals
      .map((t) => AnalyticsPieItem(
            label: t.categoryName,
            value: t.total,
            color: Color(t.colorValue),
            categoryId: t.categoryId,
          ))
      .toList();
});

class AnalyticsBarItem {
  AnalyticsBarItem({
    required this.date,
    required this.income,
    required this.expense,
  });
  final String date;
  final double income;
  final double expense;
}

// Bar chart: daily income vs expense for selected period
final barChartDataProvider = StreamProvider<List<AnalyticsBarItem>>((ref) {
  final range = ref.watch(analyticsDateRangeProvider);
  final repo = ref.watch(transactionRepositoryProvider);
  
  return repo.watchAll(from: range.start, to: range.end).map((transactions) {
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
        .map((e) => AnalyticsBarItem(
              date: e.key,
              income: e.value['income'] ?? 0,
              expense: e.value['expense'] ?? 0,
            ))
        .toList()
      ..sort((a, b) => a.date.compareTo(b.date));
  });
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
