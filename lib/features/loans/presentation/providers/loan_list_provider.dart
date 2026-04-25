import 'package:moneywise/features/loans/domain/loan_model.dart';
import 'package:moneywise/shared/enums/loan_type.dart';
import 'package:moneywise/shared/providers/repository_providers.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'loan_list_provider.g.dart';

@riverpod
class LoanList extends _$LoanList {
  @override
  Stream<List<LoanEntity>> build({LoanType? type, bool? isPaid}) {
    return ref.watch(loanRepositoryProvider).watchAll(type: type, isPaid: isPaid);
  }

  Future<void> markAsSettled(String uuid) async {
    await ref.read(loanRepositoryProvider).markSettled(uuid);
  }

  Future<void> deleteLoan(String uuid) async {
    await ref.read(loanRepositoryProvider).delete(uuid);
  }
}
