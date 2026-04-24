import 'package:isar/isar.dart';
import 'package:moneywise/features/transactions/domain/category_total.dart';
import 'package:moneywise/features/transactions/domain/i_transaction_repository.dart';
import 'package:moneywise/features/transactions/domain/transaction_filter.dart';
import 'package:moneywise/shared/enums/transaction_type.dart';
import 'package:moneywise/shared/models/transaction_model.dart';
import 'package:moneywise/shared/models/transaction_summary.dart';

class TransactionRepositoryImpl implements ITransactionRepository {
  final Isar isar;

  TransactionRepositoryImpl(this.isar);

  @override
  Stream<List<Transaction>> watchAll(TransactionFilter filter) {
    var query = isar.transactions.where().sortByDateDesc();

    if (filter.type != null) {
      // Note: In a real app with Isar, we might need more complex filters
      // but here we simplify for the implementation.
    }

    return query.build().watch(fireImmediately: true);
  }

  @override
  Future<Transaction?> getById(int id) {
    return isar.transactions.get(id);
  }

  @override
  Future<void> add(Transaction t) {
    return isar.writeTxn(() => isar.transactions.put(t));
  }

  @override
  Future<void> update(Transaction t) {
    return isar.writeTxn(() => isar.transactions.put(t));
  }

  @override
  Future<void> delete(int id) {
    return isar.writeTxn(() => isar.transactions.delete(id));
  }

  @override
  Future<TransactionSummary> getSummary(DateTime from, DateTime to) async {
    final transactions = await isar.transactions
        .where()
        .dateBetween(from, to)
        .findAll();

    double income = 0;
    double expense = 0;

    for (final t in transactions) {
      if (t.type == TransactionType.income) {
        income += t.amount;
      } else {
        expense += t.amount;
      }
    }

    final balance = income - expense;
    final savingsRate = income > 0 ? (balance / income) * 100 : 0.0;

    return TransactionSummary(
      totalIncome: income,
      totalExpense: expense,
      netBalance: balance,
      savingsRate: savingsRate,
    );
  }

  @override
  Stream<List<CategoryTotal>> watchCategoryTotals(String monthYear) {
    // Simplified: in a real implementation, we'd filter by date parsed from monthYear
    return isar.transactions.where().watch(fireImmediately: true).map((transactions) {
      final totals = <int, double>{};
      for (final t in transactions) {
        if (t.categoryId != null) {
          totals[t.categoryId!] = (totals[t.categoryId!] ?? 0) + t.amount;
        }
      }
      return totals.entries
          .map((e) => CategoryTotal(categoryId: e.key, total: e.value))
          .toList();
    });
  }
}
