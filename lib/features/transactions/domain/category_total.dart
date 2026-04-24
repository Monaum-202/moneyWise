import 'package:freezed_annotation/freezed_annotation.dart';

part 'category_total.freezed.dart';

@freezed
class CategoryTotal with _$CategoryTotal {
  const factory CategoryTotal({
    required int categoryId,
    required double total,
  }) = _CategoryTotal;
}
