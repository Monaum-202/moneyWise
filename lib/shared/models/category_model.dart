import 'package:isar/isar.dart';
import 'package:json_annotation/json_annotation.dart';

part 'category_model.g.dart';

@JsonSerializable()
@Collection()
class Category {
  Id id;

  @Index(unique: true)
  final String name;

  final int iconCodePoint;
  final int colorValue;
  final bool isCustom;
  final bool isArchived;
  final double? monthlyBudget;

  Category({
    this.id = Isar.autoIncrement,
    required this.name,
    required this.iconCodePoint,
    required this.colorValue,
    this.isCustom = false,
    this.isArchived = false,
    this.monthlyBudget,
  });

  Category copyWith({
    Id? id,
    String? name,
    int? iconCodePoint,
    int? colorValue,
    bool? isCustom,
    bool? isArchived,
    double? monthlyBudget,
  }) {
    return Category(
      id: id ?? this.id,
      name: name ?? this.name,
      iconCodePoint: iconCodePoint ?? this.iconCodePoint,
      colorValue: colorValue ?? this.colorValue,
      isCustom: isCustom ?? this.isCustom,
      isArchived: isArchived ?? this.isArchived,
      monthlyBudget: monthlyBudget ?? this.monthlyBudget,
    );
  }

  factory Category.fromJson(Map<String, dynamic> json) => _$CategoryFromJson(json);
  Map<String, dynamic> toJson() => _$CategoryToJson(this);
}
