import 'package:isar/isar.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:moneywise/shared/enums/loan_type.dart';

part 'loan_model.freezed.dart';
part 'loan_model.g.dart';

@collection
class LoanModel {
  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late String uuid;

  late String personName;
  late double amount;

  @Enumerated(EnumType.ordinal)
  late LoanType type;

  @Index()
  late DateTime date;

  DateTime? dueDate;
  String? purpose;
  
  @Index()
  late bool isPaid;
  
  DateTime? paidAt;
  late DateTime createdAt;

  List<RepaymentModel> repayments = [];
}

@embedded
class RepaymentModel {
  late String id;
  late double amount;
  late DateTime date;
  String? note;
}

@freezed
class LoanEntity with _$LoanEntity {
  const factory LoanEntity({
    required String uuid,
    required String personName,
    required double amount,
    required LoanType type,
    required DateTime date,
    DateTime? dueDate,
    String? purpose,
    required bool isPaid,
    DateTime? paidAt,
    required DateTime createdAt,
    required List<RepaymentEntity> repayments,
  }) = _LoanEntity;

  factory LoanEntity.fromJson(Map<String, dynamic> json) => _$LoanEntityFromJson(json);
}

@freezed
class RepaymentEntity with _$RepaymentEntity {
  const factory RepaymentEntity({
    required String id,
    required double amount,
    required DateTime date,
    String? note,
  }) = _RepaymentEntity;

  factory RepaymentEntity.fromJson(Map<String, dynamic> json) => _$RepaymentEntityFromJson(json);
}
