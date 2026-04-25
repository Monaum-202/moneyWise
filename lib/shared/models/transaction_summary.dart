import 'package:freezed_annotation/freezed_annotation.dart';

part 'transaction_summary.freezed.dart';
part 'transaction_summary.g.dart';

@freezed
class TransactionSummary with _$TransactionSummary {

  factory TransactionSummary.fromJson(Map<String, dynamic> json) => _$TransactionSummaryFromJson(json);
  const TransactionSummary._();

  const factory TransactionSummary({
    required double totalIncome,
    required double totalExpense,
  }) = _TransactionSummary;

  double get netBalance => totalIncome - totalExpense;
  double get savingsRate => totalIncome > 0 ? (netBalance / totalIncome) * 100 : 0;
}
