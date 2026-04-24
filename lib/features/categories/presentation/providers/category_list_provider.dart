import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:moneywise/features/categories/data/category_repository_impl.dart';
import 'package:moneywise/features/categories/domain/i_category_repository.dart';
import 'package:moneywise/shared/models/category_model.dart';
import 'package:moneywise/shared/providers/isar_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'category_list_provider.g.dart';

final categoryRepositoryProvider = Provider<ICategoryRepository>((Ref ref) {
  final isar = ref.watch(isarProvider);
  return CategoryRepositoryImpl(isar);
});

@riverpod
class CategoryList extends _$CategoryList {
  @override
  Stream<List<Category>> build() {
    return ref.watch(categoryRepositoryProvider).watchAll();
  }

  Future<void> addCategory(String name, IconData icon, Color color) async {
    final category = Category(
      name: name,
      iconCodePoint: icon.codePoint,
      colorValue: color.value,
      isCustom: true,
    );
    await ref.read(categoryRepositoryProvider).add(category);
  }
}
