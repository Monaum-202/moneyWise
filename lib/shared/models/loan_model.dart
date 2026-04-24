import 'package:isar/isar.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:moneywise/shared/enums/loan_type.dart';
import 'package:moneywise/shared/models/repayment_model.dart';

part 'loan_model.g.dart';

@JsonSerializable()
@Collection()
class Loan {
  Id id;

  @Index()
  final String personName;

  final double amount;

  @Enumerated(EnumType.name)
  @Index()
  final LoanType type;

  @Index()
  final DateTime date;

  final DateTime? dueDate;
  final String? purpose;
  final bool isPaid;
  final DateTime? paidAt;
  final List<Repayment> repayments;
  final DateTime createdAt;

  Loan({
    this.id = Isar.autoIncrement,
    required this.personName,
    required this.amount,
    required this.type,
    required this.date,
    this.dueDate,
    this.purpose,
    this.isPaid = false,
    this.paidAt,
    this.repayments = const [],
    required this.createdAt,
  });

  Loan copyWith({
    Id? id,
    String? personName,
    double? amount,
    LoanType? type,
    DateTime? date,
    DateTime? dueDate,
    String? purpose,
    bool? isPaid,
    DateTime? paidAt,
    List<Repayment>? repayments,
    DateTime? createdAt,
  }) {
    return Loan(
      id: id ?? this.id,
      personName: personName ?? this.personName,
      amount: amount ?? this.amount,
      type: type ?? this.type,
      date: date ?? this.date,
      dueDate: dueDate ?? this.dueDate,
      purpose: purpose ?? this.purpose,
      isPaid: isPaid ?? this.isPaid,
      paidAt: paidAt ?? this.paidAt,
      repayments: repayments ?? this.repayments,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  factory Loan.fromJson(Map<String, dynamic> json) => _$LoanFromJson(json);
  Map<String, dynamic> toJson() => _$LoanToJson(this);
}
