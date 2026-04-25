import 'package:moneywise/features/budget/domain/budget_model.dart';

abstract interface class IBudgetRepository {
  Stream<List<BudgetEntity>> watchByMonth(String monthYear);
  Future<void> setLimit(String categoryId, String monthYear, double limit);
  Future<void> updateSpent(String categoryId, String monthYear, double spent);
  Future<BudgetEntity?> getForCategory(String categoryId, String monthYear);
}
