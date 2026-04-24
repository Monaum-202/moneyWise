import 'package:freezed_annotation/freezed_annotation.dart';

part 'transaction_summary.freezed.dart';

@freezed
class TransactionSummary with _$TransactionSummary {
  const factory TransactionSummary({
    required double totalIncome,
    required double totalExpense,
    required double netBalance,
    required double savingsRate,
  }) = _TransactionSummary;

  factory TransactionSummary.zero() => const TransactionSummary(
        totalIncome: 0,
        totalExpense: 0,
        netBalance: 0,
        savingsRate: 0,
      );
}
