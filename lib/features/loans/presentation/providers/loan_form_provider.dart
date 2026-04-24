import 'package:isar/isar.dart';
import 'package:moneywise/features/loans/presentation/providers/loan_list_provider.dart';
import 'package:moneywise/shared/enums/loan_type.dart';
import 'package:moneywise/shared/models/loan_model.dart';
import 'package:moneywise/shared/models/repayment_model.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'loan_form_provider.g.dart';

@riverpod
class LoanForm extends _$LoanForm {
  @override
  Loan build() {
    return Loan(
      id: Isar.autoIncrement,
      personName: '',
      amount: 0.0,
      type: LoanType.gave,
      date: DateTime.now(),
      createdAt: DateTime.now(),
    );
  }

  void updateName(String name) => state = state.copyWith(personName: name);
  void updateAmount(double amount) => state = state.copyWith(amount: amount);
  void updateType(LoanType type) => state = state.copyWith(type: type);
  void updateDueDate(DateTime? date) => state = state.copyWith(dueDate: date);

  Future<void> submit() async {
    await ref.read(loanRepositoryProvider).add(state);
  }

  Future<void> addRepayment(int loanId, double amount, String? note) async {
    final repayment = Repayment(
      amount: amount,
      date: DateTime.now(),
      note: note,
      loanId: loanId,
    );
    await ref.read(loanRepositoryProvider).addRepayment(loanId, repayment);
  }
}
