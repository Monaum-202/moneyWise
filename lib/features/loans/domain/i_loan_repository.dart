import 'package:moneywise/features/loans/domain/loan_model.dart';
import 'package:moneywise/shared/enums/loan_type.dart';
import 'package:moneywise/shared/models/loan_summary.dart';

abstract interface class ILoanRepository {
  Stream<List<LoanEntity>> watchAll({LoanType? type, bool? isPaid});
  Future<LoanEntity?> getById(String uuid);
  Future<void> add(LoanEntity loan);
  Future<void> update(LoanEntity loan);
  Future<void> delete(String uuid);
  Future<void> addRepayment(String loanUuid, RepaymentEntity repayment);
  Future<void> markSettled(String loanUuid);
  Future<List<LoanEntity>> getOverdue();
  Future<LoanSummary> getSummary();
}
