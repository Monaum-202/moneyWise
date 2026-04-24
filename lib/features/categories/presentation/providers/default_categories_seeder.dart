import 'package:flutter/material.dart';
import 'package:isar/isar.dart';
import 'package:moneywise/features/categories/presentation/providers/category_list_provider.dart';
import 'package:moneywise/shared/models/category_model.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'default_categories_seeder.g.dart';

@riverpod
Future<void> categorySeeder(CategorySeederRef ref) async {
  final repository = ref.watch(categoryRepositoryProvider);
  final existing = await repository.getAll();

  if (existing.isEmpty) {
    final defaults = [
      ('Food', Icons.restaurant, Colors.orange),
      ('Transport', Icons.directions_bus, Colors.blue),
      ('Shopping', Icons.shopping_bag, Colors.pink),
      ('Entertainment', Icons.movie, Colors.purple),
      ('Health', Icons.medical_services, Colors.red),
      ('Bills', Icons.receipt, Colors.cyan),
      ('Salary', Icons.payments, Colors.green),
      ('Gift', Icons.card_giftcard, Colors.amber),
      ('Education', Icons.school, Colors.indigo),
      ('Other', Icons.category, Colors.grey),
    ];

    for (final def in defaults) {
      await repository.add(Category(
        id: Isar.autoIncrement,
        name: def.$1,
        iconCodePoint: def.$2.codePoint,
        colorValue: def.$3.value,
      ));
    }
  }
}
