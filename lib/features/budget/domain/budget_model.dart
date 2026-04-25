import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:isar/isar.dart';

part 'budget_model.freezed.dart';
part 'budget_model.g.dart';

@collection
class BudgetModel {
  Id id = Isar.autoIncrement;

  late String uuid;

  @Index()
  late String categoryId;

  @Index()
  late String monthYear;

  late double limitAmount;
  late double spentAmount;
}

@freezed
class BudgetEntity with _$BudgetEntity {

  factory BudgetEntity.fromJson(Map<String, dynamic> json) => _$BudgetEntityFromJson(json);
  const BudgetEntity._();

  const factory BudgetEntity({
    required String uuid,
    required String categoryId,
    required String monthYear,
    required double limitAmount,
    required double spentAmount,
  }) = _BudgetEntity;

  double get percentage => limitAmount > 0 ? spentAmount / limitAmount : 0.0;
}
