import 'package:isar/isar.dart';
import 'package:moneywise/features/budget/domain/i_budget_repository.dart';
import 'package:moneywise/shared/models/budget_model.dart';

class BudgetRepositoryImpl implements IBudgetRepository {
  final Isar isar;

  BudgetRepositoryImpl(this.isar);

  @override
  Stream<List<Budget>> watchAll(String monthYear) {
    return isar.budgets.where().filter().monthYearEqualTo(monthYear).watch(fireImmediately: true);
  }

  @override
  Future<Budget?> getByCategory(int categoryId, String monthYear) {
    return isar.budgets
        .where()
        .filter()
        .categoryIdEqualTo(categoryId)
        .and()
        .monthYearEqualTo(monthYear)
        .findFirst();
  }

  @override
  Future<void> setBudget(Budget budget) {
    return isar.writeTxn(() => isar.budgets.put(budget));
  }

  @override
  Future<void> updateSpentAmount(int categoryId, String monthYear, double amount) async {
    await isar.writeTxn(() async {
      final budget = await getByCategory(categoryId, monthYear);
      if (budget != null) {
        await isar.budgets.put(budget.copyWith(spentAmount: amount));
      }
    });
  }
}
