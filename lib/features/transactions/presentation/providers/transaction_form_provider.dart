import 'package:isar/isar.dart';
import 'package:moneywise/features/transactions/presentation/providers/transaction_list_provider.dart';
import 'package:moneywise/features/transactions/presentation/providers/transaction_summary_provider.dart';
import 'package:moneywise/shared/enums/transaction_type.dart';
import 'package:moneywise/shared/models/transaction_model.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'transaction_form_provider.g.dart';

@riverpod
class TransactionForm extends _$TransactionForm {
  @override
  Transaction build() {
    return Transaction(
      id: Isar.autoIncrement,
      title: '',
      amount: 0.0,
      type: TransactionType.expense,
      date: DateTime.now(),
      createdAt: DateTime.now(),
    );
  }

  void updateTitle(String title) => state = state.copyWith(title: title);
  void updateAmount(double amount) => state = state.copyWith(amount: amount);
  void updateType(TransactionType type) => state = state.copyWith(type: type);
  void updateDate(DateTime date) => state = state.copyWith(date: date);
  void updateCategory(int? categoryId) => state = state.copyWith(categoryId: categoryId);

  Future<void> submit() async {
    await ref.read(transactionRepositoryProvider).add(state);
    ref.invalidate(transactionSummaryProvider);
  }
}
