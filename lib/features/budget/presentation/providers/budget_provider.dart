import 'package:moneywise/features/budget/domain/budget_model.dart';
import 'package:moneywise/shared/providers/repository_providers.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'budget_provider.g.dart';

@riverpod
class BudgetList extends _$BudgetList {
  @override
  Stream<List<BudgetEntity>> build(String monthYear) {
    return ref.watch(budgetRepositoryProvider).watchByMonth(monthYear);
  }

  Future<void> setLimit(String categoryId, String monthYear, double limit) async {
    await ref.read(budgetRepositoryProvider).setLimit(categoryId, monthYear, limit);
  }
}
