import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:moneywise/shared/enums/transaction_type.dart';

part 'transaction_filter.freezed.dart';

@freezed
class TransactionFilter with _$TransactionFilter {
  const factory TransactionFilter({
    DateTime? from,
    DateTime? to,
    String? categoryId,
    TransactionType? type,
    String? searchQuery,
  }) = _TransactionFilter;

  factory TransactionFilter.thisMonth() {
    final now = DateTime.now();
    return TransactionFilter(
      from: DateTime(now.year, now.month),
      to: DateTime(now.year, now.month + 1, 0),
    );
  }
}
