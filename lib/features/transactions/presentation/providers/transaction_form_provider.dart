import 'package:moneywise/features/transactions/domain/transaction_model.dart';
import 'package:moneywise/features/transactions/presentation/providers/transaction_summary_provider.dart';
import 'package:moneywise/shared/enums/recurring_type.dart';
import 'package:moneywise/shared/enums/transaction_type.dart';
import 'package:moneywise/shared/providers/repository_providers.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:uuid/uuid.dart';

part 'transaction_form_provider.g.dart';

@riverpod
class TransactionForm extends _$TransactionForm {
  @override
  TransactionEntity build() {
    return TransactionEntity(
      uuid: const Uuid().v4(),
      title: '',
      amount: 0.0,
      type: TransactionType.expense,
      categoryId: '',
      date: DateTime.now(),
      isRecurring: false,
      recurringType: RecurringType.none,
      createdAt: DateTime.now(),
    );
  }

  void updateTitle(String title) => state = state.copyWith(title: title);
  void updateAmount(double amount) => state = state.copyWith(amount: amount);
  void updateType(TransactionType type) => state = state.copyWith(type: type);
  void updateDate(DateTime date) => state = state.copyWith(date: date);
  void updateCategory(String categoryId) => state = state.copyWith(categoryId: categoryId);

  Future<void> submit() async {
    await ref.read(transactionRepositoryProvider).add(state);
    ref.invalidate(transactionSummaryProvider);
  }
}
