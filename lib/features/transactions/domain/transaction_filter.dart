import 'package:moneywise/shared/enums/transaction_type.dart';

class TransactionFilter {
  final TransactionType? type;
  final int? categoryId;
  final DateTime? startDate;
  final DateTime? endDate;

  TransactionFilter({
    this.type,
    this.categoryId,
    this.startDate,
    this.endDate,
  });
}
