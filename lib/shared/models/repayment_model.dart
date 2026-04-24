import 'package:isar/isar.dart';
import 'package:json_annotation/json_annotation.dart';

part 'repayment_model.g.dart';

@JsonSerializable()
@Embedded()
class Repayment {
  final int? loanId;
  final double amount;
  final DateTime? date;
  final String? note;

  Repayment({
    this.loanId,
    this.amount = 0.0,
    this.date,
    this.note,
  });

  factory Repayment.fromJson(Map<String, dynamic> json) => _$RepaymentFromJson(json);
  Map<String, dynamic> toJson() => _$RepaymentToJson(this);
}
