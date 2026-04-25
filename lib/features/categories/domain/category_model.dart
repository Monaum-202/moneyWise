import 'package:isar/isar.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'category_model.freezed.dart';
part 'category_model.g.dart';

@collection
class CategoryModel {
  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late String uuid;

  @Index()
  late String name;
  
  late int iconCodePoint;
  late int colorValue;
  late bool isCustom;
  late bool isArchived;
  late double monthlyBudget;
  late DateTime createdAt;
}

@freezed
class CategoryEntity with _$CategoryEntity {
  const factory CategoryEntity({
    required String uuid,
    required String name,
    required int iconCodePoint,
    required int colorValue,
    required bool isCustom,
    required bool isArchived,
    required double monthlyBudget,
    required DateTime createdAt,
  }) = _CategoryEntity;

  factory CategoryEntity.fromJson(Map<String, dynamic> json) => _$CategoryEntityFromJson(json);
}
