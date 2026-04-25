import 'package:freezed_annotation/freezed_annotation.dart';

part 'category_total.freezed.dart';
part 'category_total.g.dart';

@freezed
class CategoryTotal with _$CategoryTotal {
  const factory CategoryTotal({
    required String categoryId,
    required String categoryName,
    required double total,
    required int colorValue,
    required int iconCodePoint,
  }) = _CategoryTotal;

  factory CategoryTotal.fromJson(Map<String, dynamic> json) => _$CategoryTotalFromJson(json);
}
