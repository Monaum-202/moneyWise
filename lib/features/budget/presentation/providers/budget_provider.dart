import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:moneywise/features/budget/data/budget_repository_impl.dart';
import 'package:moneywise/features/budget/domain/i_budget_repository.dart';
import 'package:moneywise/shared/models/budget_model.dart';
import 'package:moneywise/shared/providers/isar_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'budget_provider.g.dart';

final budgetRepositoryProvider = Provider<IBudgetRepository>((Ref ref) {
  final isar = ref.watch(isarProvider);
  return BudgetRepositoryImpl(isar);
});

@riverpod
class BudgetList extends _$BudgetList {
  @override
  Stream<List<Budget>> build(String monthYear) {
    return ref.watch(budgetRepositoryProvider).watchAll(monthYear);
  }

  Future<void> setBudget(int categoryId, String monthYear, double limit) async {
    final budget = Budget(
      categoryId: categoryId,
      monthYear: monthYear,
      limitAmount: limit,
    );
    await ref.read(budgetRepositoryProvider).setBudget(budget);
  }
}
