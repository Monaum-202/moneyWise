import 'package:moneywise/shared/models/budget_model.dart';

abstract interface class IBudgetRepository {
  Stream<List<Budget>> watchAll(String monthYear);
  Future<Budget?> getByCategory(int categoryId, String monthYear);
  Future<void> setBudget(Budget budget);
  Future<void> updateSpentAmount(int categoryId, String monthYear, double amount);
}
