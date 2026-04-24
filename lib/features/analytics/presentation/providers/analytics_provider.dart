import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:moneywise/features/categories/presentation/providers/category_list_provider.dart';
import 'package:moneywise/features/transactions/presentation/providers/transaction_list_provider.dart';
import 'package:moneywise/shared/enums/transaction_type.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'analytics_provider.g.dart';

@riverpod
Future<List<PieChartSectionData>> categoryPieData(CategoryPieDataRef ref) async {
  final transactions = await ref.watch(transactionListProvider().future);
  final categories = await ref.watch(categoryListProvider.future);
  
  final totals = <int, double>{};
  double totalExpense = 0;

  for (final t in transactions) {
    if (t.type == TransactionType.expense && t.categoryId != null) {
      totals[t.categoryId!] = (totals[t.categoryId!] ?? 0) + t.amount;
      totalExpense += t.amount;
    }
  }

  if (totalExpense == 0) return [];

  return totals.entries.map((entry) {
    final category = categories.firstWhere((c) => c.id == entry.key);
    return PieChartSectionData(
      value: entry.value,
      title: '${(entry.value / totalExpense * 100).toStringAsFixed(0)}%',
      color: Color(category.colorValue),
      radius: 50,
      showTitle: true,
    );
  }).toList();
}

@riverpod
List<String> insights(InsightsRef ref) {
  return [
    'You spent 15% more on Food this week than last week.',
    'Great job! You are within your Shopping budget.',
    'Consider setting a budget for Entertainment to save more.',
  ];
}
