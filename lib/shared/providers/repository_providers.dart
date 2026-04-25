import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:moneywise/features/budget/data/budget_repository_impl.dart';
import 'package:moneywise/features/budget/domain/i_budget_repository.dart';
import 'package:moneywise/features/categories/data/category_repository_impl.dart';
import 'package:moneywise/features/categories/domain/i_category_repository.dart';
import 'package:moneywise/features/loans/data/loan_repository_impl.dart';
import 'package:moneywise/features/loans/domain/i_loan_repository.dart';
import 'package:moneywise/features/transactions/data/transaction_repository_impl.dart';
import 'package:moneywise/features/transactions/domain/i_transaction_repository.dart';
import 'package:moneywise/shared/providers/isar_provider.dart';

final transactionRepositoryProvider = Provider<ITransactionRepository>((ref) {
  final isar = ref.watch(isarProvider);
  return TransactionRepositoryImpl(isar);
});

final loanRepositoryProvider = Provider<ILoanRepository>((ref) {
  final isar = ref.watch(isarProvider);
  return LoanRepositoryImpl(isar);
});

final categoryRepositoryProvider = Provider<ICategoryRepository>((ref) {
  final isar = ref.watch(isarProvider);
  return CategoryRepositoryImpl(isar);
});

final budgetRepositoryProvider = Provider<IBudgetRepository>((ref) {
  final isar = ref.watch(isarProvider);
  return BudgetRepositoryImpl(isar);
});
