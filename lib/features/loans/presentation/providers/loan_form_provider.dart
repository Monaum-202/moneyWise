import 'package:moneywise/features/loans/domain/loan_model.dart';
import 'package:moneywise/shared/enums/loan_type.dart';
import 'package:moneywise/shared/providers/repository_providers.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:uuid/uuid.dart';

part 'loan_form_provider.g.dart';

@riverpod
class LoanForm extends _$LoanForm {
  @override
  LoanEntity build() {
    return LoanEntity(
      uuid: const Uuid().v4(),
      personName: '',
      amount: 0.0,
      type: LoanType.gave,
      date: DateTime.now(),
      isPaid: false,
      createdAt: DateTime.now(),
      repayments: [],
    );
  }

  void updateName(String name) => state = state.copyWith(personName: name);
  void updateAmount(double amount) => state = state.copyWith(amount: amount);
  void updateType(LoanType type) => state = state.copyWith(type: type);
  void updateDueDate(DateTime? date) => state = state.copyWith(dueDate: date);

  Future<void> submit() async {
    await ref.read(loanRepositoryProvider).add(state);
  }

  Future<void> addRepayment(String loanUuid, double amount, String? note) async {
    final repayment = RepaymentEntity(
      id: const Uuid().v4(),
      amount: amount,
      date: DateTime.now(),
      note: note,
    );
    await ref.read(loanRepositoryProvider).addRepayment(loanUuid, repayment);
  }
}
