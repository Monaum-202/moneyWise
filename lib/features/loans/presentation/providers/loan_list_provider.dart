import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:moneywise/features/loans/data/loan_repository_impl.dart';
import 'package:moneywise/features/loans/domain/i_loan_repository.dart';
import 'package:moneywise/features/loans/domain/loan_model.dart';
import 'package:moneywise/shared/enums/loan_type.dart';
import 'package:moneywise/shared/providers/isar_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'loan_list_provider.g.dart';

final loanRepositoryProvider = Provider<ILoanRepository>((Ref ref) {
  final isar = ref.watch(isarProvider);
  return LoanRepositoryImpl(isar);
});

@riverpod
class LoanList extends _$LoanList {
  @override
  Stream<List<Loan>> build({LoanType? filter}) {
    return ref.watch(loanRepositoryProvider).watchAll(filter);
  }

  Future<void> addLoan(Loan loan) async {
    await ref.read(loanRepositoryProvider).add(loan);
  }

  Future<void> markAsSettled(int id) async {
    await ref.read(loanRepositoryProvider).markSettled(id);
  }
}
