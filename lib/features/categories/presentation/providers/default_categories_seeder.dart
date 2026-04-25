import 'package:flutter/material.dart';
import 'package:moneywise/features/categories/domain/category_model.dart';
import 'package:moneywise/features/categories/presentation/providers/category_list_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:uuid/uuid.dart';

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
      final category = Category()
        ..uuid = const Uuid().v4()
        ..name = def.$1
        ..iconCodePoint = def.$2.codePoint
        ..colorValue = def.$3.toARGB32()
        ..isCustom = false
        ..isArchived = false
        ..monthlyBudget = 0.0
        ..createdAt = DateTime.now();
      await repository.add(category);
    }
  }
}
