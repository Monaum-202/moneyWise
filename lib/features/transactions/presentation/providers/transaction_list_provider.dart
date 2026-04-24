import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:moneywise/features/transactions/data/transaction_repository_impl.dart';
import 'package:moneywise/features/transactions/domain/i_transaction_repository.dart';
import 'package:moneywise/features/transactions/domain/transaction_filter.dart';
import 'package:moneywise/shared/models/transaction_model.dart';
import 'package:moneywise/shared/providers/isar_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'transaction_list_provider.g.dart';

final transactionRepositoryProvider = Provider<ITransactionRepository>((Ref ref) {
  final isar = ref.watch(isarProvider);
  return TransactionRepositoryImpl(isar);
});

@riverpod
class TransactionList extends _$TransactionList {
  @override
  Stream<List<Transaction>> build({TransactionFilter? filter}) {
    final repository = ref.watch(transactionRepositoryProvider);
    return repository.watchAll(filter ?? TransactionFilter());
  }

  Future<void> addTransaction(Transaction transaction) async {
    await ref.read(transactionRepositoryProvider).add(transaction);
  }

  Future<void> deleteTransaction(int id) async {
    await ref.read(transactionRepositoryProvider).delete(id);
  }
}
