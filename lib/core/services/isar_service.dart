import 'package:isar/isar.dart';
import 'package:moneywise/features/budget/domain/budget_model.dart';
import 'package:moneywise/features/categories/domain/category_model.dart';
import 'package:moneywise/features/loans/domain/loan_model.dart';
import 'package:moneywise/features/transactions/domain/transaction_model.dart';
import 'package:path_provider/path_provider.dart';

class IsarService {
  static Future<Isar> open() async {
    final dir = await getApplicationDocumentsDirectory();
    return Isar.open(
      [
        TransactionModelSchema,
        LoanModelSchema,
        CategoryModelSchema,
        BudgetModelSchema,
      ],
      directory: dir.path,
    );
  }
}
