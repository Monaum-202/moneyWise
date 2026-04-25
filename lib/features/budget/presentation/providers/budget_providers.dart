import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:moneywise/features/budget/domain/budget_model.dart';
import 'package:moneywise/features/categories/domain/category_model.dart';
import 'package:moneywise/features/categories/presentation/providers/category_providers.dart';
import 'package:moneywise/features/transactions/presentation/providers/transaction_providers.dart';
import 'package:moneywise/shared/providers/repository_providers.dart';

part 'budget_providers.freezed.dart';

final currentMonthYearProvider = Provider<String>((ref) {
  final now = DateTime.now();
  return '${now.year}-${now.month.toString().padLeft(2, '0')}';
});

final budgetListProvider = StreamProvider<List<BudgetEntity>>((ref) {
  final monthYear = ref.watch(currentMonthYearProvider);
  return ref.watch(budgetRepositoryProvider).watchByMonth(monthYear);
});

// Merged: category + budget together for UI
@freezed
class CategoryBudget with _$CategoryBudget {
  const factory CategoryBudget({
    required CategoryEntity category,
    required double limitAmount,
    required double spentAmount,
    required double percentage,
  }) = _CategoryBudget;
}

final categoryBudgetProvider = Provider<List<CategoryBudget>>((ref) {
  final categories = ref.watch(categoryListProvider).valueOrNull ?? [];
  final budgets = ref.watch(budgetListProvider).valueOrNull ?? [];
  final totals = ref.watch(categoryTotalsProvider).valueOrNull ?? [];
  final budgetMap = {for (final b in budgets) b.categoryId: b};
  final totalMap = {for (final t in totals) t.categoryId: t.total};

  return categories.map((cat) {
    final budget = budgetMap[cat.uuid];
    final spent = totalMap[cat.uuid] ?? 0.0;
    final limit = budget?.limitAmount ?? cat.monthlyBudget;
    return CategoryBudget(
      category: cat,
      limitAmount: limit,
      spentAmount: spent,
      percentage: limit > 0 ? (spent / limit).clamp(0.0, 1.0) : 0.0,
    );
  }).toList();
});
