import 'package:moneywise/features/budget/data/budget_repository_impl.dart';
import 'package:moneywise/features/budget/domain/budget_model.dart';
import 'package:moneywise/features/budget/domain/i_budget_repository.dart';
import 'package:moneywise/shared/providers/isar_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:uuid/uuid.dart';

part 'budget_provider.g.dart';

final budgetRepositoryProvider = Provider<IBudgetRepository>((ref) {
  final isar = ref.watch(isarProvider);
  return BudgetRepositoryImpl(isar);
});

@riverpod
class BudgetList extends _$BudgetList {
  @override
  Stream<List<Budget>> build(String monthYear) {
    return ref.watch(budgetRepositoryProvider).watchAll(monthYear);
  }

  Future<void> setBudget(String categoryId, String monthYear, double limit) async {
    final existing = await ref.read(budgetRepositoryProvider).getByCategory(categoryId, monthYear);
    
    final budget = (existing ?? Budget())
      ..uuid = existing?.uuid ?? const Uuid().v4()
      ..categoryId = categoryId
      ..monthYear = monthYear
      ..limitAmount = limit
      ..spentAmount = existing?.spentAmount ?? 0.0;

    await ref.read(budgetRepositoryProvider).setBudget(budget);
  }
}
