import 'package:moneywise/shared/enums/transaction_type.dart';

class TransactionFilter {

  TransactionFilter({
    this.type,
    this.categoryId,
    this.startDate,
    this.endDate,
  });
  final TransactionType? type;
  final int? categoryId;
  final DateTime? startDate;
  final DateTime? endDate;
}
