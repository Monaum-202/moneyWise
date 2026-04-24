import 'package:isar/isar.dart';
import 'package:json_annotation/json_annotation.dart';

part 'budget_model.g.dart';

@JsonSerializable()
@Collection()
class Budget {
  Id id;

  @Index()
  final int categoryId;

  @Index()
  final String monthYear;

  final double limitAmount;
  final double spentAmount;

  Budget({
    this.id = Isar.autoIncrement,
    required this.categoryId,
    required this.monthYear,
    required this.limitAmount,
    this.spentAmount = 0.0,
  });

  Budget copyWith({
    Id? id,
    int? categoryId,
    String? monthYear,
    double? limitAmount,
    double? spentAmount,
  }) {
    return Budget(
      id: id ?? this.id,
      categoryId: categoryId ?? this.categoryId,
      monthYear: monthYear ?? this.monthYear,
      limitAmount: limitAmount ?? this.limitAmount,
      spentAmount: spentAmount ?? this.spentAmount,
    );
  }

  factory Budget.fromJson(Map<String, dynamic> json) => _$BudgetFromJson(json);
  Map<String, dynamic> toJson() => _$BudgetToJson(this);
}
