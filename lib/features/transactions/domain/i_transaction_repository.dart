import 'package:moneywise/features/transactions/domain/transaction_model.dart';
import 'package:moneywise/shared/enums/transaction_type.dart';
import 'package:moneywise/shared/models/category_total.dart';
import 'package:moneywise/shared/models/transaction_summary.dart';

abstract interface class ITransactionRepository {
  Stream<List<TransactionEntity>> watchAll({
    DateTime? from,
    DateTime? to,
    String? categoryId,
    TransactionType? type,
  });
  Future<TransactionEntity?> getById(String uuid);
  Future<void> add(TransactionEntity transaction);
  Future<void> update(TransactionEntity transaction);
  Future<void> delete(String uuid);
  Stream<TransactionSummary> watchSummary(DateTime from, DateTime to);
  Stream<List<CategoryTotal>> watchCategoryTotals(String monthYear);
}
