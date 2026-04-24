import 'package:isar/isar.dart';
import 'package:moneywise/features/loans/domain/i_loan_repository.dart';
import 'package:moneywise/shared/enums/loan_type.dart';
import 'package:moneywise/shared/models/loan_model.dart';
import 'package:moneywise/shared/models/repayment_model.dart';

class LoanRepositoryImpl implements ILoanRepository {
  final Isar isar;

  LoanRepositoryImpl(this.isar);

  @override
  Stream<List<Loan>> watchAll(LoanType? filter) {
    if (filter != null) {
      return isar.loans.where().filter().typeEqualTo(filter).watch(fireImmediately: true);
    }
    return isar.loans.where().watch(fireImmediately: true);
  }

  @override
  Future<void> add(Loan loan) {
    return isar.writeTxn(() => isar.loans.put(loan));
  }

  @override
  Future<void> addRepayment(int loanId, Repayment r) async {
    await isar.writeTxn(() async {
      final loan = await isar.loans.get(loanId);
      if (loan != null) {
        final updatedRepayments = List<Repayment>.from(loan.repayments)..add(r);
        final updatedLoan = loan.copyWith(repayments: updatedRepayments);
        await isar.loans.put(updatedLoan);
      }
    });
  }

  @override
  Future<void> markSettled(int loanId) async {
    await isar.writeTxn(() async {
      final loan = await isar.loans.get(loanId);
      if (loan != null) {
        final updatedLoan = loan.copyWith(isPaid: true, paidAt: DateTime.now());
        await isar.loans.put(updatedLoan);
      }
    });
  }

  @override
  Future<List<Loan>> getOverdue() {
    final now = DateTime.now();
    return isar.loans
        .where()
        .filter()
        .isPaidEqualTo(false)
        .and()
        .dueDateLessThan(now)
        .findAll();
  }
}
