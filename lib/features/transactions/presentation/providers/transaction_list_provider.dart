import 'package:moneywise/features/transactions/domain/transaction_model.dart';
import 'package:moneywise/shared/providers/repository_providers.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'transaction_list_provider.g.dart';

@riverpod
class TransactionList extends _$TransactionList {
  @override
  Stream<List<TransactionEntity>> build() {
    final repository = ref.watch(transactionRepositoryProvider);
    return repository.watchAll();
  }

  Future<void> deleteTransaction(String uuid) async {
    await ref.read(transactionRepositoryProvider).delete(uuid);
  }
}
