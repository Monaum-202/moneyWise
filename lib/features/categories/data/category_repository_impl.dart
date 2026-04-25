import 'package:flutter/material.dart';
import 'package:isar/isar.dart';
import 'package:moneywise/features/categories/domain/category_model.dart';
import 'package:moneywise/features/categories/domain/i_category_repository.dart';
import 'package:uuid/uuid.dart';

class CategoryRepositoryImpl implements ICategoryRepository {

  CategoryRepositoryImpl(this.isar);
  final Isar isar;

  @override
  Stream<List<CategoryEntity>> watchAll({bool includeArchived = false}) {
    return isar.categoryModels
        .where()
        .filter()
        .optional(!includeArchived, (q) => q.isArchivedEqualTo(false))
        .watch(fireImmediately: true)
        .map((list) => list.map(_toEntity).toList());
  }

  @override
  Future<void> add(CategoryEntity entity) async {
    final model = _toModel(entity);
    await isar.writeTxn(() => isar.categoryModels.put(model));
  }

  @override
  Future<void> update(CategoryEntity entity) async {
    await isar.writeTxn(() async {
      final model = await isar.categoryModels.where().uuidEqualTo(entity.uuid).findFirst();
      if (model != null) {
        final updatedModel = _toModel(entity)..id = model.id;
        await isar.categoryModels.put(updatedModel);
      }
    });
  }

  @override
  Future<void> archive(String uuid) async {
    await isar.writeTxn(() async {
      final model = await isar.categoryModels.where().uuidEqualTo(uuid).findFirst();
      if (model != null) {
        model.isArchived = true;
        await isar.categoryModels.put(model);
      }
    });
  }

  @override
  Future<void> seedDefaults() async {
    final count = await isar.categoryModels.count();
    if (count > 0) return;

    final defaults = [
      ('Food', Icons.restaurant, Colors.orange),
      ('Transport', Icons.directions_car, Colors.blue),
      ('Bills', Icons.receipt, Colors.red),
      ('Entertainment', Icons.movie, Colors.purple),
      ('Health', Icons.favorite, Colors.pink),
      ('Education', Icons.school, Colors.indigo),
      ('Shopping', Icons.shopping_bag, Colors.teal),
      ('Salary', Icons.work, Colors.green),
      ('Freelance', Icons.laptop, Colors.cyan),
      ('Other', Icons.category, Colors.grey),
    ];

    await isar.writeTxn(() async {
      for (final def in defaults) {
        final model = CategoryModel()
          ..uuid = const Uuid().v4()
          ..name = def.$1
          ..iconCodePoint = def.$2.codePoint
          ..colorValue = def.$3.toARGB32()
          ..isCustom = false
          ..isArchived = false
          ..monthlyBudget = 0.0
          ..createdAt = DateTime.now();
        await isar.categoryModels.put(model);
      }
    });
  }

  CategoryEntity _toEntity(CategoryModel model) {
    return CategoryEntity(
      uuid: model.uuid,
      name: model.name,
      iconCodePoint: model.iconCodePoint,
      colorValue: model.colorValue,
      isCustom: model.isCustom,
      isArchived: model.isArchived,
      monthlyBudget: model.monthlyBudget,
      createdAt: model.createdAt,
    );
  }

  CategoryModel _toModel(CategoryEntity entity) {
    return CategoryModel()
      ..uuid = entity.uuid
      ..name = entity.name
      ..iconCodePoint = entity.iconCodePoint
      ..colorValue = entity.colorValue
      ..isCustom = entity.isCustom
      ..isArchived = entity.isArchived
      ..monthlyBudget = entity.monthlyBudget
      ..createdAt = entity.createdAt;
  }
}
