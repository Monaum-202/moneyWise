import 'package:isar/isar.dart';
import 'package:moneywise/features/budget/domain/budget_model.dart';
import 'package:moneywise/features/budget/domain/i_budget_repository.dart';
import 'package:uuid/uuid.dart';

class BudgetRepositoryImpl implements IBudgetRepository {

  BudgetRepositoryImpl(this.isar);
  final Isar isar;

  @override
  Stream<List<BudgetEntity>> watchByMonth(String monthYear) {
    return isar.budgetModels
        .where()
        .filter()
        .monthYearEqualTo(monthYear)
        .watch(fireImmediately: true)
        .map((list) => list.map(_toEntity).toList());
  }

  @override
  Future<void> setLimit(String categoryId, String monthYear, double limit) async {
    await isar.writeTxn(() async {
      final existing = await isar.budgetModels
          .where()
          .filter()
          .categoryIdEqualTo(categoryId)
          .and()
          .monthYearEqualTo(monthYear)
          .findFirst();

      if (existing != null) {
        existing.limitAmount = limit;
        await isar.budgetModels.put(existing);
      } else {
        final model = BudgetModel()
          ..uuid = const Uuid().v4()
          ..categoryId = categoryId
          ..monthYear = monthYear
          ..limitAmount = limit
          ..spentAmount = 0.0;
        await isar.budgetModels.put(model);
      }
    });
  }

  @override
  Future<void> updateSpent(String categoryId, String monthYear, double spent) async {
    await isar.writeTxn(() async {
      final existing = await isar.budgetModels
          .where()
          .filter()
          .categoryIdEqualTo(categoryId)
          .and()
          .monthYearEqualTo(monthYear)
          .findFirst();

      if (existing != null) {
        existing.spentAmount = spent;
        await isar.budgetModels.put(existing);
      }
    });
  }

  @override
  Future<BudgetEntity?> getForCategory(String categoryId, String monthYear) async {
    final model = await isar.budgetModels
        .where()
        .filter()
        .categoryIdEqualTo(categoryId)
        .and()
        .monthYearEqualTo(monthYear)
        .findFirst();
    return model != null ? _toEntity(model) : null;
  }

  BudgetEntity _toEntity(BudgetModel model) {
    return BudgetEntity(
      uuid: model.uuid,
      categoryId: model.categoryId,
      monthYear: model.monthYear,
      limitAmount: model.limitAmount,
      spentAmount: model.spentAmount,
    );
  }
}
