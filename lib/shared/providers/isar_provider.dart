import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import 'package:moneywise/features/budget/domain/budget_model.dart';
import 'package:moneywise/features/categories/domain/category_model.dart';
import 'package:moneywise/features/loans/domain/loan_model.dart';
import 'package:moneywise/features/transactions/domain/transaction_model.dart';
import 'package:path_provider/path_provider.dart';

final isarProvider = AsyncNotifierProvider<IsarNotifier, Isar>(IsarNotifier.new);

class IsarNotifier extends AsyncNotifier<Isar> {
  @override
  Future<Isar> build() async {
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
