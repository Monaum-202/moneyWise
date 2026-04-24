import 'package:moneywise/shared/enums/loan_type.dart';
import 'package:moneywise/shared/models/loan_model.dart';
import 'package:moneywise/shared/models/repayment_model.dart';

abstract interface class ILoanRepository {
  Stream<List<Loan>> watchAll(LoanType? filter);
  Future<void> add(Loan loan);
  Future<void> addRepayment(int loanId, Repayment r);
  Future<void> markSettled(int loanId);
  Future<List<Loan>> getOverdue();
}
