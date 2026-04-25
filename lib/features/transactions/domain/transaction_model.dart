import 'package:isar/isar.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:moneywise/shared/enums/transaction_type.dart';
import 'package:moneywise/shared/enums/recurring_type.dart';

part 'transaction_model.freezed.dart';
part 'transaction_model.g.dart';

@collection
class TransactionModel {
  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late String uuid;

  late String title;
  late double amount;

  @Enumerated(EnumType.ordinal)
  late TransactionType type;

  @Index()
  late String categoryId;

  @Index()
  late DateTime date;

  String? note;
  
  @Index()
  late bool isRecurring;
  
  @Enumerated(EnumType.ordinal)
  late RecurringType recurringType;
  
  String? receiptImagePath;
  late DateTime createdAt;
}

@freezed
class TransactionEntity with _$TransactionEntity {
  const factory TransactionEntity({
    required String uuid,
    required String title,
    required double amount,
    required TransactionType type,
    required String categoryId,
    required DateTime date,
    String? note,
    required bool isRecurring,
    required RecurringType recurringType,
    String? receiptImagePath,
    required DateTime createdAt,
  }) = _TransactionEntity;

  factory TransactionEntity.fromJson(Map<String, dynamic> json) => _$TransactionEntityFromJson(json);
}
