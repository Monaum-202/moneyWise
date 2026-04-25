import 'package:moneywise/features/transactions/presentation/providers/transaction_list_provider.dart';
import 'package:moneywise/shared/models/transaction_summary.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'transaction_summary_provider.g.dart';

@riverpod
Future<TransactionSummary> transactionSummary(TransactionSummaryRef ref) async {
  final repository = ref.watch(transactionRepositoryProvider);
  final now = DateTime.now();
  final firstDay = DateTime(now.year, now.month);
  final lastDay = DateTime(now.year, now.month + 1, 0);
  
  return repository.getSummary(firstDay, lastDay);
}
