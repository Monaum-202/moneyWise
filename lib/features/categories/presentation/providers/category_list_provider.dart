import 'package:flutter/material.dart';
import 'package:moneywise/features/categories/domain/category_model.dart';
import 'package:moneywise/shared/providers/repository_providers.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:uuid/uuid.dart';

part 'category_list_provider.g.dart';

@riverpod
class CategoryList extends _$CategoryList {
  @override
  Stream<List<CategoryEntity>> build() {
    return ref.watch(categoryRepositoryProvider).watchAll();
  }

  Future<void> addCategory(String name, IconData icon, Color color) async {
    final category = CategoryEntity(
      uuid: const Uuid().v4(),
      name: name,
      iconCodePoint: icon.codePoint,
      colorValue: color.toARGB32(),
      isCustom: true,
      isArchived: false,
      monthlyBudget: 0.0,
      createdAt: DateTime.now(),
    );
    await ref.read(categoryRepositoryProvider).add(category);
  }
}
