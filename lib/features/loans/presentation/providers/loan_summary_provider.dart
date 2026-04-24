import 'package:moneywise/features/loans/presentation/providers/loan_list_provider.dart';
import 'package:moneywise/shared/enums/loan_type.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'loan_summary_provider.g.dart';

@riverpod
Future<({double totalOwed, double totalToReceive})> loanSummary(LoanSummaryRef ref) async {
  final loans = await ref.watch(loanListProvider().future);
  
  double totalOwed = 0;
  double totalToReceive = 0;

  for (final loan in loans) {
    if (loan.isPaid) continue;
    
    double repaid = loan.repayments.fold(0, (sum, r) => sum + r.amount);
    double remaining = loan.amount - repaid;

    if (loan.type == LoanType.gave) {
      totalToReceive += remaining;
    } else {
      totalOwed += remaining;
    }
  }

  return (totalOwed: totalOwed, totalToReceive: totalToReceive);
}
