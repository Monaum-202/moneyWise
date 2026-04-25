import 'package:moneywise/features/loans/domain/loan_model.dart';
import 'package:moneywise/features/loans/presentation/providers/loan_list_provider.dart';
import 'package:moneywise/shared/enums/loan_type.dart';
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
    final loan = Loan()
      ..uuid = state.uuid
      ..personName = state.personName
      ..amount = state.amount
      ..type = state.type
      ..date = state.date
      ..dueDate = state.dueDate
      ..purpose = state.purpose
      ..isPaid = state.isPaid
      ..paidAt = state.paidAt
      ..createdAt = state.createdAt
      ..repayments = state.repayments.map((e) => Repayment()
        ..id = e.id
        ..amount = e.amount
        ..date = e.date
        ..note = e.note
      ).toList();
      
    await ref.read(loanRepositoryProvider).add(loan);
  }

  Future<void> addRepayment(int loanId, double amount, String? note) async {
    final repayment = Repayment()
      ..id = const Uuid().v4()
      ..amount = amount
      ..date = DateTime.now()
      ..note = note;

    await ref.read(loanRepositoryProvider).addRepayment(loanId, repayment);
  }
}
