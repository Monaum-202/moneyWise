import 'package:moneywise/features/transactions/domain/category_total.dart';
import 'package:moneywise/features/transactions/domain/transaction_filter.dart';
import 'package:moneywise/shared/models/transaction_model.dart';
import 'package:moneywise/shared/models/transaction_summary.dart';

abstract interface class ITransactionRepository {
  Stream<List<Transaction>> watchAll(TransactionFilter filter);
  Future<Transaction?> getById(int id);
  Future<void> add(Transaction t);
  Future<void> update(Transaction t);
  Future<void> delete(int id);
  Future<TransactionSummary> getSummary(DateTime from, DateTime to);
  Stream<List<CategoryTotal>> watchCategoryTotals(String monthYear);
}
