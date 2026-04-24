import 'package:isar/isar.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:moneywise/shared/enums/transaction_type.dart';
import 'package:moneywise/shared/enums/recurring_type.dart';

part 'transaction_model.g.dart';

@JsonSerializable()
@Collection()
class Transaction {
  Id id;
  final String title;
  final double amount;

  @Enumerated(EnumType.name)
  @Index()
  final TransactionType type;

  @Index()
  final int? categoryId;

  @Index()
  final DateTime date;

  final String? note;
  final bool isRecurring;

  @Enumerated(EnumType.name)
  final RecurringType recurringType;

  final String? receiptImagePath;
  final DateTime createdAt;

  Transaction({
    this.id = Isar.autoIncrement,
    required this.title,
    required this.amount,
    required this.type,
    this.categoryId,
    required this.date,
    this.note,
    this.isRecurring = false,
    this.recurringType = RecurringType.none,
    this.receiptImagePath,
    required this.createdAt,
  });

  Transaction copyWith({
    Id? id,
    String? title,
    double? amount,
    TransactionType? type,
    int? categoryId,
    DateTime? date,
    String? note,
    bool? isRecurring,
    RecurringType? recurringType,
    String? receiptImagePath,
    DateTime? createdAt,
  }) {
    return Transaction(
      id: id ?? this.id,
      title: title ?? this.title,
      amount: amount ?? this.amount,
      type: type ?? this.type,
      categoryId: categoryId ?? this.categoryId,
      date: date ?? this.date,
      note: note ?? this.note,
      isRecurring: isRecurring ?? this.isRecurring,
      recurringType: recurringType ?? this.recurringType,
      receiptImagePath: receiptImagePath ?? this.receiptImagePath,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  factory Transaction.fromJson(Map<String, dynamic> json) => _$TransactionFromJson(json);
  Map<String, dynamic> toJson() => _$TransactionToJson(this);
}
